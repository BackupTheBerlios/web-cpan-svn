package MediaWiki::Parser;

use warnings;
use strict;

use Moose;

use MediaWiki::Parser::LineMan;
use MediaWiki::Parser::Token;
use MediaWiki::Parser::Token::Text;

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

has '_state' => (is => "rw", isa => "Str", default => "default");

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

sub _enq
{
    my ($self, $token) = @_;

    push @{$self->_tokens_queue()}, $token;
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

sub _enqueue_more_tokens
{
    my $self = shift;

    if ($self->_state() eq "document_end")
    {
        # Do nothing - don't enqueue more tokens.
    }
    elsif ($self->_state() eq "default")
    {
        $self->_state("para");
        $self->_enq(
            MediaWiki::Parser::Token->new(
                type => "paragraph",
                position => "open",
            )
        );
    }
    elsif ($self->_state() eq "para")
    {
        my $text = "";

        my $use_line = 1;

        my $line_ref = $self->_curr_line();

        # Consume the text.
        while ($use_line || defined($line_ref = $self->_next_line()))
        {
            $use_line = 0;

            $text .= ${$line_ref};
        }

        $self->_enq(
            MediaWiki::Parser::Token::Text->new(
                text => $text,
            )
        );

        $self->_enq(
            MediaWiki::Parser::Token->new(
                type => "paragraph",
                position => "close",
            )
        );

        # TODO : This is temporary to get the tests passed.
        $self->_state("document_end");
    }

    return;
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
