package WWW::BooksTracker::M::CDBI;

use Class::DBI::FromForm;

use strict;
use base 'Catalyst::Model::CDBI';

__PACKAGE__->config(
    dsn           => 'dbi:Pg:dbname=books_tracker1;host=localhost',
    user          => 'shlomi',
    password      => '',
    options       => {},
    relationships => 1,
    additional_classes => [
        qw/Class::DBI::Plugin::AbstractCount Class::DBI::Plugin::Pager/
    ],
);    

=head1 NAME

WWW::BooksTracker::M::CDBI - CDBI Model Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;

