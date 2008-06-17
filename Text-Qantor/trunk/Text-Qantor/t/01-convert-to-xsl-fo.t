#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use IO::String;
use XML::LibXML::Reader;

use Text::Qantor;

my @files =
(
    qw(
        t/data/to-xsl-fo/input/three-paras.qant
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

# TEST:$num_files=1


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
    
    my $got_reader = XML::LibXML::Reader->new(string => $got_output_fh);
    my $expected_reader = XML::LibXML::Reader->new(location => $expected_file);

    my $next_elem = sub {
        $got_reader->read();
        $expected_reader->read();
    };

    my $all_ok = 1;
    XML_READERS_LOOP:
    while ($got_reader->depth() && $expected_reader->depth())
    {
        my $type = $got_reader->nodeType();
        if ($type ne $expected_reader->nodeType())
        {
            $all_ok = 0;
            diag("Got: " . $got_reader->nodeType(). " at " . $got_reader->lineNumber() . " ; Expected: " . $expected_reader->nodeType() . " at " .$expected_reader->lineNumber());
            last XML_READERS_LOOP;
        }
        elsif ($type == XML_READER_TYPE_TEXT())
        {
            my $got_text = $got_reader->value();
            my $expected_text = $expected_reader->value();

            foreach my $t ($got_text, $expected_text)
            {
                $t =~ s{\A\s+}{}ms;
                $t =~ s{\s+\z}{}ms;
                $t =~ s{\s+}{ }ms;
            }
            if ($got_text ne $expected_text)
            {
                diag ("Texts differ: Got[" . $got_reader->lineNumber(). "] Expected [". $expected_reader->lineNumber(). "]");
                last XML_READERS_LOOP;
            }
        }
        # Move to the next element.
        $next_elem->();
    }
    # TEST
    ok ($all_ok, "XML comparison was OK.");
}
