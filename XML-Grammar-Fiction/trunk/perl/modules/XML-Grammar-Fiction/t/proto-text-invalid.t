#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;

use XML::LibXML;

use Exception::Class;

use XML::Grammar::Fiction::FromProto;
use XML::Grammar::Fiction::FromProto::Parser::QnD;

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

my $grammar = XML::Grammar::Fiction::FromProto->new({});

eval {
my $got_xml = $grammar->convert(
    {
        source =>
        {
            file => "t/data/proto-text-invalid/inner-desc-inside-char-addressing.txt",
        },
    }
);
};

my $err = Exception::Class->caught(
    "XML::Grammar::Fiction::Err::Parse::TagsMismatch"
);

# TEST
ok ($err, "TagsMismatch was caught");

# TEST
like(
    $err->error(),
    qr{\ATags do not match},
    "Text is OK."
);

# TEST
is(
    $err->opening_tag()->name(),
    "start",
    "Opening tag-name is OK.",
);

# TEST
is(
    $err->opening_tag()->line(),
    1,
    "Opening line is OK.",
);

# TEST
is(
    $err->closing_tag()->name(),
    "wrong-finish-tag",
    "Opening tag-name is OK.",
);

# TEST
is(
    $err->closing_tag()->line(),
    3,
    "Opening line is OK.",
);

1;
