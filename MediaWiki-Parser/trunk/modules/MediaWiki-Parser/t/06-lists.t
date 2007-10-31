#!perl
#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use lib "./t/lib";

use MediaWiki::Parser::Test::IsTokens;

use MediaWiki::Parser;

use utf8;

{
    my $text = <<'EOF';
Before list
*In list
After list

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
                text => "Before list\n",
            },
            {
                t => "para",
                p => "close",
            },
            {
                t => "list",
                p => "open",
                st => "unordered",
            },
            {
                t => "listitem",
                p => "open",
            },
            { text => "In list\n", },
            {
                t => "listitem",
                p => "close",
            },
            {
                t => "list",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { 
                text => "After list\n",
            },
            {
                t => "para",
                p => "close",
            },
        ],
        "Simple one-item unordered list.",
    );
}

