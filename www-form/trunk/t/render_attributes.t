#!/usr/bin/perl -w

use strict;

use Test::More tests => 5;

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

{
    my %attributes = 
        (
            'first' => "D&D", 
        );
    my $expected = q{ first="D&amp;D"};
    my $real = $www_form->_render_attributes(\%attributes);
    # TEST
    is ( $real, $expected, "Attribute Rendering with Ampersand (& -> &amp;)");
}

{
    my %attributes = 
        (
            'style' => "font : \"Helvetica\"",
        );
    my $expected = q{ style="font : &quot;Helvetica&quot;"};
    my $real = $www_form->_render_attributes(\%attributes);
    # TEST
    is ( $real, $expected, "Attribute Rendering with Double Quotes (\" -> &quot;)");
}

