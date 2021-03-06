package WWW::BooksTracker::C::Book;

use strict;
use base 'Catalyst::Base';

use WWW::BooksTracker;
use WWW::BooksTracker::M::CDBI;
use WWW::BooksTracker::Const qw(STATUS_DISABLED);

use Data::Dumper;

sub default : Private
{
    my ( $self, $c ) = @_;
    $c->res->output('Congratulations, WWW::BooksTracker::C::Book is on Catalyst!');
}

sub wrong_url : Regex('^books/(\d+)$')
{
    my ($self, $c ) = @_;
    $c->res->output("Wrong URL!");
}

sub init_form
{
    my ($self, $c) = @_;
    $c->form( optional => [ WWW::BooksTracker::M::CDBI::Books->columns() ] );
}

sub book_add : Regex('^books/add/$')
{
    my ($self, $c) = @_;

    $self->init_form($c);

    my $req = $c->req;
    my $mode = $req->params()->{'mode'} || "";

    $self->reg_books_meta($c);
    
    if ($mode eq "do_add")
    {
        $c->forward('book_do_add');
    }
    else
    {
        $c->stash->{template} = 'book_edit.tt';
        $c->stash->{mode} = "do_add";
        $c->stash->{title} = "Add New Book";
    }    
}

sub list : Regex('^books/list/$')
{
    my ($self, $c) = @_;
    
    my $pager = WWW::BooksTracker::M::CDBI::Books->pager();

    $pager->per_page(20);
    $pager->page( $c->req->params->{'page'} || 1);

    # TODO: Change to search_where() once we know the query better.
    $c->stash->{'all_objects'} = 
        [ 
            $pager->search_where(
                where => { 'status' => 0 },
            )
        ];
    $c->stash->{'pager'} = $pager;
    $c->stash->{'template'} = "book_list.tt";
}

sub show : Regex('^books/(\d+)/(disable/|)$')
{
    my ( $self, $c ) = @_;
    $self->reg_books_meta($c);
    my $req = $c->req;
    my $mode = $req->params()->{'mode'} || "";
    my $id = $c->req->snippets->[0] || 1;
    my $disable = $c->req->snippets->[1];
    my $query = { id => $id };
    my $book = WWW::BooksTracker::M::CDBI::Books->find_or_create($query);
    $c->stash->{book} = $book;
    my $path = $c->req->path;
    $c->stash->{rel_url_to_root} =
        "./" . join("/", ("..") x (1+(() = $path =~ m!/!g)));
    
    $self->init_form($c);
    
    if ($disable)
    {
        # TODO: Make sure the confirm CGI param is processed.
        if (($req->method() eq "POST")
            && ($mode eq "disable")
            && $req->params()->{'confirm'})
        {
            $book->status(STATUS_DISABLED());
            $book->dbi_commit();
            $c->stash->{template} = 'book_after_disable.tt';
        }
        else
        {
            $c->stash->{template} = 'book_disable.tt';
        }
    }
    elsif ($mode eq "edit")
    {
        $c->stash->{template} = 'book_edit.tt';
        $c->stash->{mode} = "do_edit";
        $c->stash->{title} = "Edit " . $book->get('title');
        $c->forward('book_edit');
    }
    elsif ($mode eq "do_edit")
    {
        $c->forward('book_do_edit');
    }
    else
    {
        $c->stash->{template} = 'book.tt';
    }
}

sub reg_books_meta
{
    my ($self, $c) = @_;
    $c->stash->{books_meta} = WWW::BooksTracker::get_books_meta_data();
}

sub book_edit : Private
{
    my ($self, $c) = @_;
    $self->reg_books_meta($c);
}

sub book_do_edit : Private
{
    my ($self, $c) = @_;
    my $book = $c->stash->{book};
    $book->update_from_form( $c->form );
    $book->dbi_commit();
    $c->res->redirect("./");
}

sub book_do_add : Private
{
    my ($self, $c) = @_;
    my $book = WWW::BooksTracker::M::CDBI::Books->create_from_form( $c->form );
    $book->set('status', 0);
    $book->dbi_commit();
    $c->res->redirect("../list/");
}

=head1 NAME

WWW::BooksTracker::C::Book - A Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Shlomi Fish

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;

