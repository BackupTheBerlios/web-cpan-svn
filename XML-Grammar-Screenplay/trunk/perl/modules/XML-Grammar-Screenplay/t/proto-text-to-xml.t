#!/usr/bin/perl

use strict;
use warnings;

use Test::XML tests => 10;

use XML::Grammar::Screenplay::FromProto;

sub load_xml
{
    my $path = shift;

    open my $in, "<", $path;
    my $contents;
    {
        local $/;
        $contents = <$in>
    }
    close($in);
    return $contents;
}

my @tests = (qw(
        nested-s
        two-nested-s
        with-dialogue
        dialogue-with-several-paragraphs
        with-description
        with-tags-inside-paragraphs
        with-internal-description
        with-comments
        with-multi-para-desc
        with-multi-line-comments
    ));

# TEST:$num_tests=10

my $grammar = XML::Grammar::Screenplay::FromProto->new();

foreach my $fn (@tests)
{
    my $got_xml = $grammar->convert(
        {
            source =>
            {
                file => "t/data/proto-text/$fn.txt",
            },
        }
    );

    # TEST*$num_tests
    is_xml ($got_xml, load_xml("t/data/xml/$fn.xml"),
        "Output of the Proto Text \"$fn\""
    );
}

1;

