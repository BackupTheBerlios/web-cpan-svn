package MediaWiki::Parser;

use warnings;
use strict;

use Moose;

use MediaWiki::Parser::LineMan;
use MediaWiki::Parser::Token;

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

sub get_next_token
{
    my $self = shift;

    return MediaWiki::Parser::Token->new(
        type => "paragraph",
        position => "open",
    );
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
