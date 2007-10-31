package MediaWiki::Parser::State;

use strict;
use warnings;

use Moose;

use List::Util;

use MediaWiki::Parser::Token;
use MediaWiki::Parser::Token::HTML;

=head1 NAME

MediaWiki::Parser::State - the state of the parser.

=head1 SYNPOSIS

Used as part of MediaWiki::Parser - for internal use.

=head1 DESCRIPTION

This is the class that abstracts the state of the parser for 
L<MediaWiki::Parser>.

=head1 METHODS

=head2 $token = MediaWiki::Parser::State->new(%args)

Currently accepts no arguments.

=head2 meta

[Added by Moose - ignore.]

=cut

has 'status' => (isa => "Str", is => 'rw', default => "default");

=head2 $state->status()

The status within the state machine of the parser.

=cut

=head2 $state->incoming_text()

Sets/returns the incoming text for the next iteration of the parser. If there
was leftover text after a formatting (such as an irregular number of 
apostrophes, etc.), use this.

=cut

has 'incoming_text' => (isa => "Str", is => 'rw', default => "");

=head2 $state->flush_incoming_text()

Returns the current C<incoming_text()> and sets it to zero.

=cut

sub flush_incoming_text
{
    my $self = shift;

    my $ret = $self->incoming_text();

    $self->incoming_text("");

    return $ret;
}

has '_italics' => (isa => "Bool", is => 'rw', default => 0);
has '_bold'    => (isa => "Bool", is => 'rw', default => 0);

=head2 $state->get_toggle_tokens({token => $token})

Toggles the state specified by token and returns the appropriate opening
or closing markup tokens. Currently supported types are C<"italics"> and
C<"bold">.

We sometimes need more than one because of implicit open/close tokens due
to improper nesting in the markup.

=cut

has '_line_formats_stack' => (is => "rw", isa => "ArrayRef", 
    default => sub { [] }
);

has '_opened_html_elems' => (is => "rw", isa => "HashRef",
    default => sub { +{} }
);

sub _is_open
{
    my ($self, $args) = @_;

    my $type = $args->{type};

    my $field = "_$type";

    return +($args->{type} eq "html-tag")
        ?  $self->_opened_html_elems()->{$args->{element_name}} 
        :  $self->$field();
}

sub _close_token_state
{
    my ($self, $args) = @_;

    my $type = $args->{type};

    if ($args->{type} eq "html-tag")
    {
        delete ($self->_opened_html_elems()->{$args->{element_name}});
    }
    else
    {
        my $field = "_$type";
        $self->$field(0);
    }
}

sub _open_token_state
{
    my ($self, $args) = @_;

    my $type = $args->{type};

    if ($args->{type} eq "html-tag")
    {
        $self->_opened_html_elems()->{$args->{element_name}} = 1;
    }
    else
    {
        my $field = "_$type";
        $self->$field(1);
    }
}

sub get_toggle_tokens
{
    my ($self, $args) = @_;

    my $input_token = $args->{token};

    my $is_open = $self->_is_open($input_token);

    my @ret = ();

    my $push_actual_elem = sub {

        my $token = 
            $input_token->clone(
                {
                    extra_params =>
                    [
                        position => ($is_open ? "close" : "open"),
                        ($args->{'implicit'} ? (implicit => 1) : ()),
                    ],
                },
            );

        push @ret, $token;

        return $token;
    };

    # If it's open - we should close it.
    if ($is_open)
    {
        my $formats_stack = $self->_line_formats_stack();
        my $last = $#$formats_stack;

        my $type_occur_idx =
            List::Util::first
            { $formats_stack->[$_]->matches($input_token) }
            (reverse (0 .. $last ))
            ;

        foreach my $format_elem (@{$formats_stack}
            [ reverse($type_occur_idx+1 .. $last) ] )
        {
            push @ret, $format_elem->implicit_close();
        }

        $push_actual_elem->();
        
        foreach my $format_elem (@{$formats_stack}
            [ $type_occur_idx+1 .. $last ] )
        {
            push @ret, $format_elem->implicit_open();
        }

        # Remove the element from the stack
        splice(@{$formats_stack}, $type_occur_idx, 1);

        # Switch the field
        $self->_close_token_state($input_token);
    }
    else
    {
        # If it's closed - we'll open a new one.
        push @{$self->_line_formats_stack()},
            $push_actual_elem->()->clone();

        # Switch the field
        $self->_open_token_state($input_token);
    }

    return \@ret;
}

=head2 $state->get_html_tokens({ element_name => "tt", 'open' => $bool})

Retrieves the HTML tokens that are needed.

=cut

sub get_html_tokens
{
    # TODO : fix the assumption that the input is well-formed.
    my ($self, $args) = @_;

    my $name = $args->{element_name};
    my $open = $args->{'open'};

    if ($open)
    {
        $self->_opened_html_elems()->{$name} = 1;

        my $ret = 
            MediaWiki::Parser::Token::HTML->new(
                element_name => $name,
                position => "open",
            );
        push @{$self->_line_formats_stack()}, $ret->clone();
        return [ $ret ];
    }
    else
    {
        return $self->get_toggle_tokens(
            {
                token =>
                    MediaWiki::Parser::Token::HTML->new(
                        element_name => $name,
                        position => "close",
                    ),
            }
        );
    }
}

=head2 $state->get_simult_toggle_tokens({types => \@types})

Returns several simultaneous types as in the case of C<'''''> - italics+bold.
C<@types> specifies the types themselves and gives some order hints.

=cut

sub get_simult_toggle_tokens
{
    my ($self, $args) = @_;

    my $types_array = $args->{types};

    my %types_order = (map { $types_array->[$_] => $_ } (0 .. $#$types_array));

    my $stack = $self->_line_formats_stack();
    my %stack_order = 
        (map 
            { $stack->[$_]->{type} => (@$stack - $_) }
            (0 .. $#$stack)
        );

    my @order = 
        sort 
        {
            (($stack_order{$a} || (@$stack+1)) <=> 
             ($stack_order{$b} || (@$stack+1))
            ) 
            || ($types_order{$a} <=> $types_order{$b})
        }
        @$types_array;

    return [ map { 
        @{
            $self->get_toggle_tokens(
                {
                    token =>
                    MediaWiki::Parser::Token->new(
                        type => $_,
                        position => "open",
                    )
                }
            )
        } } @order
        ];
}

=head2 $state->get_standalone_tokens({ type => $type})

Get the tokens required for a standalone event. Currently supported types
are C<"linebreak">.

=cut

sub get_standalone_tokens
{
    my ($self, $args) = @_;

    return 
        [
            MediaWiki::Parser::Token->new(
                type => $args->{type},
                position => "standalone",
                (exists($args->{subtype}) ? 
                    (subtype => $args->{subtype}) : 
                    ()
                ),
            )
        ];
}

=head2 $state->line_end()

Performs a syntactical line end operation and implicity closes all the
opened events that must be closed on a line end, and returns them as an
array reference. If there's nothing to be closed - returns undef.

=cut


sub line_end
{
    my $self = shift;

    my @ret_tokens;

    while (@{$self->_line_formats_stack()})
    {
        my $tokens =
            $self->get_toggle_tokens(
                {
                    token => $self->_line_formats_stack()->[-1]->clone(
                        {
                            extra_params => [ implicit => 1, ],
                        }
                    ),
                }
            );
        
        push @ret_tokens, @{$tokens};
    }      

    if (@ret_tokens)
    {
        return \@ret_tokens;
    }
    else
    {
        return;
    }
}

has 'para_sub_state' => (isa => "ArrayRef", is => "rw", 
    default => sub { [] });

sub is_para_sub_state_paragraph
{
    my $self = shift;

    return 
    (
           (@{$self->para_sub_state()} == 1)
        && ($self->para_sub_state()->[0] eq "paragraph")
    );
}

=head2 $state->para_sub_state()

The sub-state within the paragraph state.

An array ref of items that can be:

=over 4

=item * 'none'

=item * 'code_block'

=item * 'paragraph'

=item * 'list'

=item * 'listitem'

=back

=head2 $state->is_para_sub_state_paragraph

Checks if the para_sub_state is a paragraph.

=cut

1;

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at iglu.org.il> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-mediawiki-parser at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MediaWiki-Parser>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MediaWiki::Parser

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MediaWiki-Parser>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MediaWiki-Parser>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MediaWiki-Parser>

=item * Search CPAN

L<http://search.cpan.org/dist/MediaWiki-Parser>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the MIT/X11 License:

L<http://www.opensource.org/licenses/mit-license.php>.

=cut

