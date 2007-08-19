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

has 'subtype' => (isa => "Str", is => 'ro');

=head2 $token->subtype()

The subtype of the event. For the "signature" type it can be C<'username'>,
C<'username+date'> and C<'date'>.

=head2 my $bool = $parser->is_opening()

Returns true if it's an opening tag event.

=cut

sub is_opening
{
    my $self = shift;

    return ($self->position() eq "open");
}

=head2 my $bool = $parser->is_closing()

Returns true if it's an closing tag event.

=cut

sub is_closing
{
    my $self = shift;

    return ($self->position() eq "close");
}

=head2 my $bool = $parser->is_standalone()

Returns true if it's a standalone tag event.

=cut

sub is_standalone
{
    my $self = shift;

    return ($self->position() eq "standalone");
}

has '_implicit' => (isa => "Bool", is => 'ro', init_arg => "implicit");

=head2 my $bool = $token->is_implicit()

Returns true if it's an implicit event. I.e: one that was added by the parser
to maintain HTML/XML integrity and not specified explicitly by the user.

An example of this is an implicit closing italics at the end of the line:

    Hello ''Italics
    Another Line.

C<"Another Line."> will not be italicized.

=cut

sub is_implicit
{
    my $self = shift;

    return $self->_implicit();
}

=head2 implicit_close()

Returns an implicit close token for this one. This is useful with interlaced
tokens.

=cut

sub implicit_close
{
    my $self = shift;

    return $self->clone(
        {
            extra_params =>
            [
                implicit => 1,
                position => "close",
            ]
        }
    );
}

=head2 implicit_open()

Returns an implicit open token for this one. This is useful with interlaced
tokens.

=cut


sub implicit_open
{
    my $self = shift;

    return $self->clone(
        {
            extra_params =>
            [
                implicit => 1,
                position => "open",
            ]
        }
    );
}

=head2 clone()

Clones the token.

=cut

sub clone
{
    my ($self, $args) = @_;

    $args ||= {};

    my $extra_params = $args->{extra_params} || [];

    return ref($self)->new(
        @{$self->_get_clone_params()},
        @{$extra_params},
    );
}

sub _get_fields
{
    my $self = shift;

    return 
    [
        type => $self->type(),
        subtype => $self->subtype(),
    ];
}

sub _get_clone_params
{
    my $self = shift;

    return
    [
        position => $self->position(),
        implicit => $self->_implicit(),
        @{$self->_get_fields()},
    ];
}

=head2 $token->matches({%args})

Whether the token matches the spec in %args.

=cut

sub matches
{
    my ($self, $args) = @_;

    return (
           ($self->type() eq $args->{type})
        && (defined($self->subtype()) 
            ? ($self->subtype() eq $args->{subtype})
            : 1
        )
    );
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

