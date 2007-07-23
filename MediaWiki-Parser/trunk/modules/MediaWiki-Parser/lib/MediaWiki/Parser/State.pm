package MediaWiki::Parser::State;

use strict;
use warnings;

use Moose;

use List::Util;

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

=head2 $token->status()

The status within the state machine of the parser.

=cut

has '_italics' => (isa => "Bool", is => 'rw', default => 0);
has '_bold'    => (isa => "Bool", is => 'rw', default => 0);

=head2 $state->get_toggle_tokens({type => $type})

Toggles the state specified by "type" and returns the appropriate opening
or closing markup tokens. Currently supported types are C<"italics"> and
C<"bold">.

We sometimes need more than one because of implicit open/close tokens due
to improper nesting in the markup.

=cut

has '_line_formats_stack' => (is => "rw", isa => "ArrayRef", default => sub { [] });

sub get_toggle_tokens
{
    my ($self, $args) = @_;

    my $type = $args->{type};
    my $field = "_$type";

    my @ret = ();

    my $push_actual_elem = sub {
        push @ret,
            MediaWiki::Parser::Token->new(
                type => $type,
                position => ($self->$field() ? "close" : "open"),
                ($args->{'implicit'} ? (implicit => 1) : ()),
            );
    };

    # If it's open - we should close it.
    if ($self->$field())
    {
        my $formats_stack = $self->_line_formats_stack();
        my $last = $#$formats_stack;

        my $type_occur_idx = 
            List::Util::first 
            { $formats_stack->[$_]->{type} eq $type }
            (reverse (0 .. $last ))
            ;

        foreach my $format_elem (@{$formats_stack}
            [ reverse($type_occur_idx+1 .. $last) ] )
        {
            push @ret,
                MediaWiki::Parser::Token->new(
                    type => $format_elem->{type},
                    position => "close",
                    implicit => 1,
                );
        }

        $push_actual_elem->();
        
        foreach my $format_elem (@{$formats_stack}
            [ $type_occur_idx+1 .. $last ] )
        {
            push @ret,
                MediaWiki::Parser::Token->new(
                    type => $format_elem->{type},
                    position => "open",
                    implicit => 1,
                );
        }

        # Remove the element from the stack
        splice(@{$formats_stack}, $type_occur_idx, 1);
    }
    else
    {
        # If it's closed - we'll open a new one.
        push @{$self->_line_formats_stack()}, { type => $type };
        $push_actual_elem->();
    }
        
    my $token =
        MediaWiki::Parser::Token->new(
            type => $type,
            position => ($self->$field() ? "close" : "open"),
            ($args->{'implicit'} ? (implicit => 1) : ()),
        );

    # Switch the field
    $self->$field(!$self->$field());

    return \@ret;
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

    # TODO : change to use _line_formats_stack().
    foreach my $type (qw(italics bold))
    {
        my $field = "_$type";
        if ($self->$field())
        {
            push @ret_tokens, 
                 @{$self->get_toggle_tokens({type => $type, implicit => 1})}
                 ;
        }
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

