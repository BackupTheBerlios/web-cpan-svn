#!/usr/bin/perl

use strict;
use warnings;

use Test::XML tests => 2;

use XML::Grammar::Screenplay::FromProto;

sub load_xml
{
    my $path = shift;

    open my $in, "<", $path;
    my $contents;
    {
        local $/;
        $contents = <$in>;
    }
    close($in);
    return $contents;
}

my @tests = (qw(
        nested-s
        two-nested-s
    ));

# TEST:$num_tests=2

foreach my $fn (@tests)
{
    my $grammar = XML::Grammar::Screenplay::FromProto->new(
        {
            source =>
            {
                file => "t/data/proto-text/$fn.txt",
            },
        }
    );

    my $got_xml = $grammar->convert();

    # TEST*$num_tests
    is_xml ($got_xml, load_xml("t/data/xml/$fn.xml"),
        "Output of the Proto Text \"$fn\""
    );
}


1;
