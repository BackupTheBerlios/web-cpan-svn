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

