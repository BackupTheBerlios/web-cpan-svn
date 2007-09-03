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
Before heading
== Heading 2 ==
After heading

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
                text => "Before heading\n",
            },
            {
                t => "para",
                p => "close",
            },
            {
                t => "heading",
                p => "open",
                level => 2,
            },
            { text => "Heading 2", },
            {
                t => "heading",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { 
                text => "After heading\n",
            },
            {
                t => "para",
                p => "close",
            },
        ],
        "Heading test 1",
    );
}

{
    my $text = <<'EOF';


Before heading


== Heading 2 ==


After heading


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
                text => "Before heading\n",
            },
            {
                t => "para",
                p => "close",
            },
            {
                t => "heading",
                p => "open",
                level => 2,
            },
            { text => "Heading 2", },
            {
                t => "heading",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { 
                text => "After heading\n",
            },
            {
                t => "para",
                p => "close",
            },
        ],
        "Heading test 1 with space in between",
    );
}

{
    my $text = <<'EOF';

=== 3 start - 2 end ==

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
                t => "heading",
                p => "open",
                level => 2,
            },
            { text => "= 3 start - 2 end", },
            {
                t => "heading",
                p => "close",
            },
        ],
        "Uneven heading mark - 3 start - 2 end",
    );
}

