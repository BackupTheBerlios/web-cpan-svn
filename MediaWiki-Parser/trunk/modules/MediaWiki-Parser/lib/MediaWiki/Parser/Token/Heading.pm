package MediaWiki::Parser::Token::Heading;

use strict;
use warnings;

use Moose;

extends("MediaWiki::Parser::Token");

=head1 NAME

MediaWiki::Parser::Token::Heading - an heading token.

=head1 SYNPOSIS

    my $token = MediaWiki::Parser::Token::Heading->new(
        level => 2,
    );

=head1 DESCRIPTION

This is a token sub-class that represents a MediaWiki headin (akin to HTML's
<h1>..<h6).

=head1 METHODS

=head2 $token = MediaWiki::Parser::Token::HTML->new(%args)

For internal use.

=head2 meta

[Added by Moose - ignore.]

=cut

has "+type" => (default => "heading");

=head2 level

Returns the level of the heading - an integer.

=cut

has "level" => (isa => "Int", is => "rw");

=head2 type()

Returns C<"text"> for a text-based token.

=cut

override "_get_fields" => sub {
    my $self = shift;
    return [@{super()}, level => $self->level()];
};

=head2 matches()

See L<MediaWiki::Parser::Token>.

=cut

override "matches" => sub {
    my ($self, $args) = @_;

    return (super()
        && ($self->is_closing() || ($self->level() == $args->{level}))
    );
};

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

