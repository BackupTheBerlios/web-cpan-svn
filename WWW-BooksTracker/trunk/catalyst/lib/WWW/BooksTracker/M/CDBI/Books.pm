package WWW::BooksTracker::M::CDBI::Books;

use strict;
use warnings;

__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->sequence('books_id');

# Define some relationships.

__PACKAGE__->has_many('formats' => "WWW::BooksTracker::M::CDBI::BooksFormats");
__PACKAGE__->has_many('translations' => "WWW::BooksTracker::M::CDBI::BooksFormats");

__PACKAGE__->has_a('license' => "WWW::BooksTracker::M::CDBI::Licenses");

=head1 NAME

WWW::BooksTracker::M::CDBI::Books - CDBI Model Component Table Class

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

