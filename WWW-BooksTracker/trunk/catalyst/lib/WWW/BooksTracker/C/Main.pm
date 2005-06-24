package WWW::BooksTracker::C::Main;

use strict;
use base 'Catalyst::Base';

=head1 NAME

WWW::BooksTracker::C::Main - Catalyst component

=head1 SYNOPSIS

See L<WWW::BooksTracker>

=head1 DESCRIPTION

Catalyst component.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->output('Congratulations, WWW::BooksTracker::C::Main is on Catalyst!');
}

sub show : Private
{
    my ($self, $c) = (@_);

    $c->stash->{template} = "main.tt";
}

=back


=head1 AUTHOR

Shlomi Fish

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
