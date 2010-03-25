#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 13;

use File::Spec;

use lib "./t/lib";

use Test::XML::Ordered qw(is_xml_ordered);

use IO::String;

use Text::Qantor;
use Text::Qantor::XML::ToXSL_FO;

# TEST:$num_files=3
my @files =
(
    qw(
        t/data/to-xsl-fo/input/three-paras.qant
        t/data/to-xsl-fo/input/several-paras.qant
        t/data/to-xsl-fo/input/with-bold.qant
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

    my $expected_file = "t/data/to-xsl-fo/qantor-xml/$base.xml";

    my $qantor = Text::Qantor->new(
        {
            data_dir => File::Spec->catdir(File::Spec->curdir(), "extradata"),
        }
    );

    open my $input_file_fh, "<", $input_file;

    my $got_file = "t/data/to-xsl-fo/output-qantor-xml/$base.xml";
    open my $got_output_fh, ">", $got_file
        or die "Could not open got_out_fh - $!";

    $qantor->convert_input_to_xml(
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
        [ location => $got_file ],
        [ location => $expected_file ],
        "'$input_file' generated good output"
    );

    # Now let's validate the XMLs.
    
    {
        open my $in, "<", $expected_file
            or die "Could not open '$expected_file' - $!";
        binmode $in, ":encoding(utf-8)";

        my $error_code = $qantor->validate_xml({ in_fh => $in });
        # TEST*$num_files
        ok(
            !$error_code,
            "XML of '$expected_file' validates according to the RelaxNG",
        ) or
        diag(explain($error_code));
        ;
    }

    # Now let's convert the XML to XSL-FO
    {
        my $fo_converter = Text::Qantor::XML::ToXSL_FO->new(
            {
                data_dir => File::Spec->catdir(File::Spec->curdir(), "extradata"),
            }
        );

        # TEST
        ok ($fo_converter, "Initialised converter");

        my $string;
        eval {
            $string = $fo_converter->translate_to_xsl_fo(
                {
                    source => { file => $got_file },
                    output_type => "string",
                }
            );
        };

        my $err = $@;

        # TEST*$num_files
        is ($err, "", "No exception was thrown");

        my $got_fo_file = "t/data/to-xsl-fo/output-xsl-fo/$base.fo";
        {
            open my $got_fo_fh, ">:encoding(utf-8)", $got_fo_file
                or die "could not open";
            print {$got_fo_fh} $got_fo_file;
            close($got_fo_fh);
        }

        my $expected_fo_file = "t/data/to-xsl-fo/xsl-fo/$base.fo";

        # TEST*$num_files
        is_xml_ordered(
            [ location => $got_fo_file ],
            [ location => $expected_fo_file ],
            "'$input_file' generated good output"
        );
    }
}
