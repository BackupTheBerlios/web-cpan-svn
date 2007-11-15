#!perl
#!perl -T

use strict;
use warnings;

use Test::More tests => 6;

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

{
    my $text = <<'EOF';
Before list
*Item1
*Item2
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
            { text => "Item1\n", },
            {
                t => "listitem",
                p => "close",
            },
            {
                t => "listitem",
                p => "open",
            },
            { text => "Item2\n", },
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

{
    my $text = <<'EOF';
Before list
*First List

*Second List
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
            { text => "First List\n", },
            {
                t => "listitem",
                p => "close",
            },
            {
                t => "list",
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
            { text => "Second List\n", },
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
        "Two one-item lists separated by an empty line",
    );
}

{
    my $text = <<'EOF';
Before list
*First List
*2nd Item

*Second List
*Item 2
*Item 3
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
            { text => "First List\n", },
            {
                t => "listitem",
                p => "close",
            },
            {
                t => "listitem",
                p => "open",
            },
            { text => "2nd Item\n", },
            {
                t => "listitem",
                p => "close",
            },
            {
                t => "list",
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
            { text => "Second List\n", },
            {
                t => "listitem",
                p => "close",
            },
            {
                t => "listitem",
                p => "open",
            },
            { text => "Item 2\n", },
            {
                t => "listitem",
                p => "close",
            },
            {
                t => "listitem",
                p => "open",
            },
            { text => "Item 3\n", },
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
        "Two separated lists with some items in each.",
    );
}

# Wrap the arguments in an open-close para.
sub p
{
    return
    (
        {
            t => "para",
            p => "open",
        },
        @_,
        {
            t => "para",
            p => "close",
        },
    );
}

sub ul
{
    return
    (
        {
            t => "list",
            p => "open",
            st => "unordered",
        },
        @_,
        {
            t => "list",
            p => "close",
        },
    );
}

sub li
{
    return
    (
        {
            t => "listitem",
            p => "open",
        },
        @_,
        {
            t => "listitem",
            p => "close",
        },
    );
}

{
    my $text = <<'EOF';
Before list
*List
**Inner List
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
            p("Before list\n",),
            ul(
                li(
                    "List\n",
                    ul(
                        li(
                            "Inner List\n",
                        )
                    ),
                ),
            ),
            p("After list\n",),
        ],
        "Nested lists.",
    );
}

{
    my $text = <<'EOF';
Before list
*List
**Inner List
**Another inner item
*Outer Item
*Start another list
**LI/LI1
**LI/LI2
**LI/LI3
*Outer Item
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
            p("Before list\n",),
            ul(
                li(
                    "List\n",
                    ul(
                        li( "Inner List\n",),
                        li( "Another inner item\n",),
                    ),
                ),
                li("Outer Item\n"),
                li(
                    "Start another list\n",
                    ul(
                        li( "LI/LI1\n",),
                        li( "LI/LI2\n",),
                        li( "LI/LI3\n",),
                    ),
                ),
                li("Outer Item\n"),
            ),
            p("After list\n",),
        ],
        "Nested lists with more than one item",
    );
}

# TODO:
# Test: 
# 1. more than one item.
# 2. Several depths of nesting at once.
# 3. Ordered lists
# 4. Definition lists.

