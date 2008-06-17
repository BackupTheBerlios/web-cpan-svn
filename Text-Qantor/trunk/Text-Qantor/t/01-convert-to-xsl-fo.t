#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use lib "./t/lib";

use Test::XML::Ordered qw(is_xml_ordered);

use IO::String;

use Text::Qantor;

# TEST:$num_files=2
my @files =
(
    qw(
        t/data/to-xsl-fo/input/three-paras.qant
        t/data/to-xsl-fo/input/several-paras.qant
    )
);

sub read_file
{
    my $path = shift;

    open my $in, "<", $path;
    binmode $in, ":utf8";
    my $contents;
    {
        local $/;
        $contents = <$in>
    }
    close($in);
    return $contents;
}



foreach my $input_file (@files)
{
    if ($input_file !~ m{\At/data/to-xsl-fo/input/([^\.]+)\.qant\z})
    {
        die "File is not the correct format.";
    }

    my $base = $1;

    my $expected_file = "t/data/to-xsl-fo/xsl-fo/$base.fo";

    my $qantor = Text::Qantor->new();

    open my $input_file_fh, "<", $input_file;

    my $got_buffer = "";
    my $got_output_fh = IO::String->new($got_buffer);

    $qantor->convert_input_to_xsl_fo(
        {
            in_fh => $input_file_fh,
            out_fh => $got_output_fh,
        },
    );

    close($input_file_fh);
    close($got_output_fh);

    # Now let's compare the XMLs.
    # TEST*$num_files
    is_xml_ordered(
        [ string => $got_buffer ],
        [ location => $expected_file ],
        "'$input_file' generated good output"
    );
}
