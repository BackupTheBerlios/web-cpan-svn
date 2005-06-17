package WWW::BooksTracker::M::CDBI::CRUD;

use base 'Catalyst::Model::CDBI::CRUD';

__PACKAGE__->config(
    dsn           => 'dbi:Pg:dbname=books_tracker1',
    user          => '',
    password      => '',
    options       => {},
    relationships => 1
);    

1;

