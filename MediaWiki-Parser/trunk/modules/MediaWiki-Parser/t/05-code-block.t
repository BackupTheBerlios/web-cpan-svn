#!perl
#!perl -T

use strict;
use warnings;

use Test::More tests => 3;

use lib "./t/lib";

use MediaWiki::Parser::Test::IsTokens;

use MediaWiki::Parser;

use utf8;

{
    my $text = <<'EOF';
Normal text.


    Line with 4 spaces.
 Line with 1 space.
    Line with 4 spaces.


EOF

    my $parser = MediaWiki::Parser->new();

    $parser->input_text(
        {
            lines => [split(/^/, $text)],
        }
    );

    # TEST
    is_tokens_deeply(
        $parser,
        [
            {
                t => "para",
                p => "open",
            },
            { 
                text => "Normal text.\n",
            },
            {
                t => "para",
                p => "close",
            },
            {
                t => "code_block",
                p => "open",
            },
            {
                text => "   Line with 4 spaces.\nLine with 1 space.\n   Line with 4 spaces.\n"
            },
            {
                t => "code_block",
                p => "close",
            },
        ],
        "Code Block test 1",
    );
}

{
    my $text = <<'EOF';
    Open Bold '''hello''' No bold.
    Bold on ''' without off.
    no bold.
EOF

    my $parser = MediaWiki::Parser->new();

    $parser->input_text(
        {
            lines => [split(/^/, $text)],
        }
    );

    # TEST
    is_tokens_deeply(
        $parser,
        [
            {
                t => "code_block",
                p => "open",
            },
            { text => "   Open Bold ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "hello", },
            {
                t => "bold",
                p => "close",
            },
            { text => " No bold.\n   Bold on ", },
            {
                t => "bold",
                p => "open",
            },
            { text => " without off.\n", },
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            { text => "   no bold.\n" },
            {
                t => "code_block",
                p => "close",
            },
        ],
        "Code Block - with formattings",
    );
}

{
    my $text = <<'EOF';
    Code block 1
    More code block 1
Regular paragraph
    Code block 2
    More code block 2
EOF

    my $parser = MediaWiki::Parser->new();

    $parser->input_text(
        {
            lines => [split(/^/, $text)],
        }
    );

    # TEST
    is_tokens_deeply(
        $parser,
        [
            {
                t => "code_block",
                p => "open",
            },
            { text => "   Code block 1\n   More code block 1\n", },
            {
                t => "code_block",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { 
                text => "Regular paragraph\n",
            },
            {
                t => "para",
                p => "close",
            },
            {
                t => "code_block",
                p => "open",
            },
            { text => "   Code block 2\n   More code block 2\n", },
            {
                t => "code_block",
                p => "close",
            },
        ],
        "Code Block - without line-space difference",
    );
}

