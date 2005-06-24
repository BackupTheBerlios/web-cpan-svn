package WWW::BooksTracker::M::CDBI::Languages;

use strict;

__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->sequence('languages_id_seq');

__PACKAGE__->has_many('translations' => "WWW::BooksTracker::M::CDBI::Translations");

=head1 NAME

WWW::BooksTracker::M::CDBI::Languages - CDBI Model Component Table Class

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

