package MediaWiki::Parser;

use warnings;
use strict;

use Moose;

use MediaWiki::Parser::LineMan;
use MediaWiki::Parser::Token;
use MediaWiki::Parser::Token::Text;
use MediaWiki::Parser::State;

use Exception::Class;

=head1 NAME

MediaWiki::Parser - A module for parsing MediaWiki syntax.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use MediaWiki::Parser;

    my $parser = MediaWiki::Parser->new();

    $parser->input_text({'lines' => \@lines});

    while (my $token = $parser->get_next_token())
    {
        # Do something with token.
    }

=head1 METHODS

=cut

has '_line_man' => (
    isa => "MediaWiki::Parser::LineMan", 
    is => "rw",
    handles => 
    {
        map { '_'.$_ => $_ } 
        qw(curr_line next_line with_curr_line)
    },
);

=head2 $parser->input_text({ lines => [@lines] })

Inputs the text of @lines into the parser for processing.

=cut

sub input_text
{
    my ($self, $args) = @_;

    $self->_line_man(
        MediaWiki::Parser::LineMan->new(
            lines => $args->{lines},
        )
    );

    return;
}

=head2 my $token = $parser->get_next_token()

Retrieves the next token.

=cut

sub _new_empty_array_ref
{
    return [];
}

# has '_state' => (is => "rw", isa => "Str", default => "default");
# has '_italics' => (is => "rw", isa => "Bool", default => 0);

has '_state' => (
    is => "rw", 
    isa => "MediaWiki::Parser::State", 
    default => sub { return MediaWiki::Parser::State->new() },
);

has "_tokens_queue" => (is => "rw", isa => "ArrayRef", 
    default => \&_new_empty_array_ref
);

sub _is_queue_empty
{
    my $self = shift;

    return (scalar(@{$self->_tokens_queue()}) == 0);
}

sub _dequeue
{
    my $self = shift;

    if ($self->_is_queue_empty())
    {
        return;
    }
    else
    {
        return shift(@{$self->_tokens_queue()});
    }
}

sub _enq_multiple
{
    my ($self, $tokens_ref) = @_;

    push @{$self->_tokens_queue()}, @{$tokens_ref};

    return;
}

sub _enq
{
    my ($self, $token) = @_;

    return $self->_enq_multiple([$token]);
}

sub get_next_token
{
    my $self = shift;

    if ($self->_is_queue_empty())
    {
        $self->_enqueue_more_tokens();
    }

    return $self->_dequeue();
}

sub _skip_empty_lines
{
    my $self = shift;

    my $line_ref = $self->_curr_line();

    while (defined($line_ref) && $$line_ref =~ m{\A\s*\z}ms)
    {
        $line_ref = $self->_next_line();
    }

    return $line_ref;
}

sub _next_non_empty_line
{
    my $self = shift;

    my $line_ref = $self->_next_line();

    if (!defined($line_ref))
    {
        return;
    }
    elsif ($$line_ref =~ m{\S})
    {
        return $line_ref;
    }
    else
    {
        return;
    }
}

sub _enqueue_more_tokens
{
    my $self = shift;

    my $callback = "_enqueue_tokens_in__" . $self->_state->status();

    my $callback_ret = $self->$callback();

    if (defined($callback_ret))
    {
        $self->_state->status($callback_ret->{'next_state'});
    }

    return;
}

sub _enqueue_tokens_in__document_end
{
    my $self = shift;

    # Do nothing - don't enqueue more tokens.
    return;
}

sub _enqueue_tokens_in__default
{
    my $self = shift;

    if (!defined($self->_skip_empty_lines()))
    {
        return { next_state => "document_end" };
    }
    else
    {
        $self->_enq(
            MediaWiki::Parser::Token->new(
                type => "paragraph",
                position => "open",
            )
        );
        return { next_state => "para" };
    }
}

sub _enqueue_tokens_in__para
{
    my $self = shift;

    my $text = $self->_state->flush_incoming_text();

    my $use_line = 1;

    my $line_ref = $self->_curr_line();

    my $found_markup;

    my $implicit_line_end_tokens;

    # Consume the text.
    PARAGRAPH_LINE_LOOP:
    while ($use_line || defined($line_ref = $self->_next_non_empty_line()))
    {
        $use_line = 0;

        # It's placed here because we still need to move to the next line.
        if (defined($implicit_line_end_tokens))
        {
            last PARAGRAPH_LINE_LOOP;
        }

        if ($$line_ref =~ m{\G(.*?)((?:'{2,})|<)}cg)
        {
            my ($up_to_text, $markup) = ($1, $2);
            
            $text .= $up_to_text;
            $found_markup = $markup;

            last PARAGRAPH_LINE_LOOP;
        }
        else
        {
            # Extract the remaining $line_ref.
            $text .= substr($$line_ref, pos($$line_ref) || 0);

            $implicit_line_end_tokens = $self->_state()->line_end();
        }
    }

    if (length($text))
    {
        $self->_enq(
            MediaWiki::Parser::Token::Text->new(
                text => $text,
            )
        );
    }

    if (defined($implicit_line_end_tokens))
    {
        $self->_enq_multiple($implicit_line_end_tokens);
    }

    if (defined($found_markup))
    {
        if ($found_markup eq q{''})
        {
            $self->_enq_toggle_tokens({type => "italics"});
        }
        elsif ($found_markup =~ m{\A'''('?)\z})
        {
            my $rest = $1;

            $self->_enq_toggle_tokens({type => "bold"});

            $self->_state->incoming_text($rest);
        }
        elsif ($found_markup =~ m{\A'{5}('*)\z})
        {
            my $rest = $1;

            $self->_enq_toggle_tokens_for_simultaneous_formattings(
                {
                    types => [qw(italics bold)],
                }
            );

            $self->_state->incoming_text($rest);
        }
        elsif ($found_markup eq "<")
        {
            if ($$line_ref =~ m{\Gbr */? *>}cg)
            {
                $self->_enq_multiple(
                    $self->_state->get_standalone_tokens(
                        {
                            type => "linebreak"
                        }
                    )
                );
            }
        }
        return;
    }
    elsif (!defined($line_ref))
    {
        $self->_enq(
            MediaWiki::Parser::Token->new(
                type => "paragraph",
                position => "close",
            )
        );

        return { next_state => $self->_get_status_after_paragraph()};
    }

    return;
}

sub _enq_toggle_tokens
{
    my ($self, $args) = @_;

    return
        $self->_enq_multiple(
            $self->_state->get_toggle_tokens({type => $args->{type}})
        );
}

sub _enq_toggle_tokens_for_simultaneous_formattings
{
    my ($self, $args) = @_;

    return
        $self->_enq_multiple(
            $self->_state->get_simult_toggle_tokens({types => $args->{types}})
        );
}

sub _get_status_after_paragraph
{
    my $self = shift;

    return
        $self->_line_man()->is_end_of_lines()
            ? "document_end"
            : "default";
}

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

1; # End of MediaWiki::Parser
