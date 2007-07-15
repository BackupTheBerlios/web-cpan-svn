package MediaWiki::Parser::LineMan;

=head1 NAME

MediaWiki::Parser::LineMan - Line manager for MediaWiki parser.

=head1 SYNPOSIS

    my $manager = MediaWiki::Parser::LineMan->new(
        lines => [@lines],
    );

=head1 DESCRIPTION

This is the line manager for MediaWiki parser which manages the various
lines of the text being parsed.

=head1 METHODS

=head2 new(%args)

Accepts the following named arguments:

=over 4

=item * lines

The lines to be parsed.

=back

=head2 meta

[Added by Moose - ignore.]

=cut

use strict;
use warnings;

use Moose;

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

