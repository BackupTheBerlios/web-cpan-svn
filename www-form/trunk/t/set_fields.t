#!/usr/bin/perl -w

use strict;

use Test::More tests => 7;

# TEST
BEGIN { use_ok("WWW::Form"); }

sub make_obj
{
    my $self = {};

    bless $self, "WWW::Form";

    $self->{fieldsOrder} = shift || [];

    return $self;
}

# Test Suite #1: a simple one.
{
    my $form = make_obj();
    my %fields_data = 
    (
        'first_name' =>
        {
            label => "First Name",
            defaultValue => "Joe",
            type => "text",
        },
        'comments' =>
        {
            label => "Your Comments",
            defaultValue => "Enter your comments here.",
            type => "textarea",
        },
    );
    
    $form->_setFields(\%fields_data, {});
    
    # TEST
    is($form->{fields}{first_name}{label}, "First Name", "simple-fn-label");
    # TEST
    is($form->{fields}{first_name}{defaultValue}, "Joe", "simple-fn-dv");
    # TEST
    is($form->{fields}{first_name}{type}, "text", "simple-fn-type");
    # TEST
    is($form->{fields}{comments}{label}, "Your Comments", "simple-comments-label");
    # TEST
    is($form->{fields}{comments}{defaultValue}, "Enter your comments here.", "simple-comments-dv");
    # TEST
    is($form->{fields}{comments}{type}, "textarea", "simple-comments-type");   
}

