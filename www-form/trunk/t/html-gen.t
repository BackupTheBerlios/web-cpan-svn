#!/usr/bin/perl -w

use strict;

use Test::More tests => 1;

use WWW::Form;

# Test that _getTextAreaHTML escapes its HTML.
{
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
    
    my %fields_values = 
    (
        'first_name' => "Josephine",
        'comments' => "</textarea><h1>You have been Exploited! (& more)</h1>",
    );
    
    my $form = WWW::Form->new(
        \%fields_data,
        \%fields_values,
    );

    my $retrieved_text = $form->_getTextAreaHTML("comments", "");

    # TEST
    is ($retrieved_text, 
        q{<textarea name='comments'>&lt;/textarea&gt;&lt;h1&gt;You have been Exploited! (&amp; more)&lt;/h1&gt;</textarea>},
        "Textarea HTML Escape"
       );
}

