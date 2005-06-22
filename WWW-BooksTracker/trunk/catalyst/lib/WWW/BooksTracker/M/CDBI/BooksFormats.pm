package WWW::BooksTracker::M::CDBI::BooksFormats;

use strict;

__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->sequence('books_formats_id_seq');

# Define some relationships
__PACKAGE__->has_a(book => "WWW::BooksTracker::M::CDBI::Books");
__PACKAGE__->has_a(format => "WWW::BooksTracker::M::CDBI::Formats");

=head1 NAME

WWW::BooksTracker::M::CDBI::BooksFormats - CDBI Model Component Table Class

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

