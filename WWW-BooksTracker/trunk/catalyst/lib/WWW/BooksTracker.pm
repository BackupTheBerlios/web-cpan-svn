package WWW::BooksTracker;

use strict;
use Catalyst qw/-Debug Static Prototype Textile FormValidator SanitizeUrl/;

our $VERSION = '0.01';

WWW::BooksTracker->config(
    name => 'WWW::BooksTracker',
    root => '/home/shlomi/progs/perl/www/Catalyst/WWW-Books-Tracker/trunk/catalyst/root',
);

WWW::BooksTracker->setup;

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('/main/show');
}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward('WWW::BooksTracker::V::TT') unless $c->res->output;
}

sub static_css : Regex('^books_track.css$') {
    my ( $self, $c ) = @_;
    $c->req->path("books_track.css");
    $c->serve_static("text/css");
}

=head1 NAME

WWW::BooksTracker - A very nice application

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice application.

=head1 AUTHOR

Shlomi Fish

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

sub get_books_meta_data
{
    return [
        { 'name' => "title", 'label' => "Title", 'type' => "text",},
        { 'name' => "url", 'label' => "Link", 'type' => "text",},
        { 'name' => "authors", 'label' => "Authors", 'type' => "text",},
        { 'name' => "abstract", 'label' => "Abstract", 
            'type' => "textarea",},
        { 'name' => "year", 'label' => "Year", 'type' => "text",},
        { 'name' => "publisher", 'label' => "Publisher", 'type' => "text",},
        { 'name' => "isbn", 'label' => "ISBN", 'type' => "text",},    
   ];
}

1;

