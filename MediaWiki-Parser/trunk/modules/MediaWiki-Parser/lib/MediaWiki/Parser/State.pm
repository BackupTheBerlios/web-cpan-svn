package MediaWiki::Parser::State;

use strict;
use warnings;

use Moose;

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

=head2 $state->get_toggle_token({type => $type})

Toggles the state specified by "type" and returns the appropriate opening
or closing markup token. Currently supported types are C<"italics">.

=cut

sub get_toggle_token
{
    my ($self, $args) = @_;

    my $token =
        MediaWiki::Parser::Token->new(
            type => "italics",
            position => ($self->_italics() ? "close" : "open"),
            ($args->{'implicit'} ? (implicit => 1) : ()),
        );

    # Switch the italic.
    $self->_italics(!$self->_italics());

    return $token;
}

=head2 $state->line_end()

Performs a syntactical line end operation and implicity closes all the
opened events that must be closed on a line end, and returns them as an
array reference. If there's nothing to be closed - returns undef.

=cut


sub line_end
{
    my $self = shift;

    if ($self->_italics())
    {
        return [ $self->get_toggle_token({type => "italics", implicit => 1}) ];
    }

    return;
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

