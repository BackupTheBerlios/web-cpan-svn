#!/usr/bin/perl -w

use Test::More tests => 3;

use strict;

use XML::CompareML::HTML;
use XML::CompareML::DocBook;
use IO::Scalar;
use Test::Differences;

{
    my $buffer = "";
    my $file = IO::Scalar->new(\$buffer);
    my $converter = 
        XML::CompareML::HTML->new(
            'input_filename' => "t/files/scm-comparison.xml",
            'output_handle' => $file,
            'data_dir' => "./extradata",
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
            'data_dir' => "./extradata",
        );

    $converter->process();

    # TEST
    ok(length($buffer) > 0, "\$buffer was filled in");
}

# Check for actual content.
{
    my $buffer = "";
    my $file = IO::Scalar->new(\$buffer);
    my $converter = 
        XML::CompareML::HTML->new(
            'input_filename' => "examples/scm-comparison.xml",
            'output_handle' => $file,
            'data_dir' => "./extradata",
        );

    $converter->process();

    open my $good_html_fh, "<", "examples/scm-comparison.output.html";
    binmode $good_html_fh, ":utf8";
    my $good_content;
    {
        local $/;
        $good_content = <$good_html_fh>;
    }
    close($good_html_fh);
    # TEST
    eq_or_diff ($buffer, $good_content, "XSLT Works");
}
