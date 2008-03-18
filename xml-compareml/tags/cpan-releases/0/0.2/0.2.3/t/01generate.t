#!/usr/bin/perl -w

use Test::More tests => 2;

use strict;

use XML::CompareML::HTML;
use XML::CompareML::DocBook;
use IO::Scalar;

{
    my $buffer = "";
    my $file = IO::Scalar->new(\$buffer);
    my $converter = 
        XML::CompareML::HTML->new(
            'input_filename' => "t/files/scm-comparison.xml",
            'output_handle' => $file,
        );

    $converter->process();

    # TEST
    ok(length($buffer) > 0, "\$buffer was filled in");
}

{
    my $buffer = "";
    my $file = IO::Scalar->new(\$buffer);
    my $converter = 
        XML::CompareML::DocBook->new(
            'input_filename' => "t/files/scm-comparison.xml",
            'output_handle' => $file,
        );

    $converter->process();

    # TEST
    ok(length($buffer) > 0, "\$buffer was filled in");
}
