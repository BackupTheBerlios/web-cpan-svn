#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use IO::All;

use XML::LibXML;

# TEST:$num_files=9
# TEST*$num_files
my $dtd =
    XML::LibXML::Dtd->new(
            "Products Syndication Markup Language 0.1.1",
            "products-syndication.dtd",
            );

my @xml_files = (grep { /\.xml$/ } io("./valid-xmls")->all());
foreach my $xml_file (@xml_files)
{
    my $p = XML::LibXML->new();
    $p->validation(0);
    my $dom = $p->parse_file($xml_file);
    ok ($dom->validate($dtd));
}

# TEST:$num_xslt=1
# TEST*$num_xslt
foreach my $xml_file (@xml_files[0 .. 0])
{
    my $parser = XML::LibXML->new();
    my $xslt = XML::LibXSLT->new();

    my $source = $parser->parse_file($xml_file);
    my $style_doc = $parser->parse_file("products-syndication.xslt");
    my $stylesheet = $xslt->parse_stylesheet($style_doc);

    my $results = $stylesheet->transform($source);

    my $expected = io()->file(get_expected_fn($xml_file))->slurp();
    my $got = $stylesheet->output($results);
    is_xml(
        $got,
        $expected,
        "Testing output of XSLT with file $xml_file",
    );
}

sub get_expected_fn
{
    my $file = shift;
    if ($file =~ m{^./valid-xmls/(.*)\.xml$})
    {
        return "./outputs/$1.html";
    }
    else
    {
        die "Unknown filename";
    }
}
