package MediaWiki::Parser::Token;

use strict;
use warnings;

use Moose;

package MediaWiki::Parser::Token::TypeConstraints;

use Moose::Util::TypeConstraints;
enum "PositionValue" => qw(open close standalone);

package MediaWiki::Parser::Token;

=head1 NAME

MediaWiki::Parser::Token - a parser token.

=head1 SYNPOSIS

    my $token = MediaWiki::Parser::Token->new(
        type => "paragraph",
        position => "start",
    );

=head1 DESCRIPTION

This is the token class for the MediaWiki parser which encapsulates a single
token.

=head1 METHODS

=head2 $token = MediaWiki::Parser::Token->new(%args)

Accepts the following named arguments:

=over 4

=item * type

The type of the token - see type() below.

=item * position

See position() below.

=back

=head2 meta

[Added by Moose - ignore.]

=cut



has 'position' => (isa => "PositionValue", is => 'ro');

=head2 $token->position()

Can be C<"open"> (for opening) or C<"close"> (for closing), depending on the 
position.

=cut

has 'type' => (isa => "Str", is => 'ro');

=head2 $token->type()

The type of event. Can be:

=over 4

=item * 'paragraph'

=back

=cut

=head2 my $bool = $parser->is_opening()

Returns true if it's an opening tag event.

=cut

sub is_opening
{
    my $self = shift;

    return ($self->position() eq "open");
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

