#!/usr/bin/perl -w

use strict;

use Test::More tests => 3;

# TEST
BEGIN { use_ok("WWW::Form"); }

my $www_form = WWW::Form->new({});

# TEST
ok($www_form, "Initialization");

{
    my %attributes = 
        (
            'first' => "Hello", 
            "second" => "Good", 
            "third" => "yoohoo",
        );
    my $expected = q{ first="Hello" second="Good" third="yoohoo"};
    my $real = $www_form->_render_attributes(\%attributes);
    # TEST
    is ( $real, $expected, "Simple Attribute Rendering");
}


