#!perl
#!perl -T

use strict;
use warnings;

use utf8;

use Test::More tests => 88;

use lib "./t/lib";

use MediaWiki::Parser::Test::IsTokens;

use MediaWiki::Parser;

sub is_paragraph
{
    my ($parser, $para_id, $text) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $open_token = $parser->get_next_token();

    # Assert #1.
    is ($open_token->type(),
        "paragraph",
        "$para_id - Token is a paragraph"
    );

    # Assert #2.
    ok ($open_token->is_opening(), 
        "$para_id - token is paragraph opening event"
    );

    my $text_token = $parser->get_next_token();

    # Assert #3.
    is ($text_token->type(),
        "text",
        "$para_id - Token is text"
    );

    # Assert #4.
    is ($text_token->text(),
        $text,
        "$para_id - text token is the text of the paragraph"
    );

    

    my $close_token = $parser->get_next_token();

    # Assert #5.
    is ($close_token->type(),
        "paragraph",
        "$para_id - Token is a (closing) paragraph"
    );

    # Assert #6.
    ok ($close_token->is_closing(),
        "$para_id - closing paragraph was finished"
    );

    # TEST:$para_asserts=6
}

{
    my $text = <<'EOF';
Hello there. I have a proposition for you.
It's not pretty. It's MediaWiki!
EOF

    my $parser = MediaWiki::Parser->new();

    $parser->input_text(
        {
            lines => [split(/^/, $text)],
        }
    );

    {
        my $token1 = $parser->get_next_token();

        # TEST
        is ($token1->type(),
            "paragraph",
            "Token is a paragraph"
        );

        # TEST
        ok ($token1->is_opening(), "First token is paragraph opening event");
    }

    {
        my $token2 = $parser->get_next_token();

        # TEST
        is ($token2->type(),
            "text",
            "Token is text"
        );

        # TEST
        is ($token2->text(),
            ("Hello there. I have a proposition for you.\n" .
            "It's not pretty. It's MediaWiki!\n"),
            "Second token is the text of the paragraph"
        );
    }

    {
        my $token3 = $parser->get_next_token();

        # TEST
        is ($token3->type(),
            "paragraph",
            "Token is a (closing) paragraph"
        );

        # TEST
        ok ($token3->is_closing(), "Paragraph was finished");
    }

    {
        my $end_token = $parser->get_next_token();

        # TEST
        ok (!defined($end_token),
            "We reached the end of the tokens."
        );
    }

    {
        my $end_token = $parser->get_next_token();

        # TEST
        ok (!defined($end_token),
            "Another end token."
        );
    }
}

{
    my $text = <<'EOF';
First paragraph.
More of the first paragraph.

Second paragraph.
Yes, it's the second para.
And it's definitely the second.

Third paragraph if anyone cares.
I'm not so bothered by it.
EOF

    my $parser = MediaWiki::Parser->new();

    $parser->input_text(
        {
            lines => [split(/^/, $text)],
        }
    );

    my $is_paragraph = sub {
        return is_paragraph($parser,@_);
    };

    # TEST*3*$para_asserts
    $is_paragraph->(
        "Multiple Paragraphs - 1st Paragraph",
        "First paragraph.\nMore of the first paragraph.\n",
    );

    $is_paragraph->(
        "Multiple Paragraphs - 2nd Paragraph",
        ("Second paragraph.\nYes, it's the second para.\n"
        . "And it's definitely the second.\n"),
    );
 
    $is_paragraph->(
        "Multiple Paragraphs - 3rd Paragraph",
        ("Third paragraph if anyone cares.\n"
            . "I'm not so bothered by it.\n"),
    );

    {
        my $end_token = $parser->get_next_token();

        # TEST
        ok (!defined($end_token),
            "Multiple paragraphs - we reached the end of the tokens."
        );
    }

    {
        my $end_token = $parser->get_next_token();

        # TEST
        ok (!defined($end_token),
            "Multiple paragraphs - another end token."
        );
    }
}

{
    my $text = <<'EOF';


First paragraph after leading whitespace.

Second paragraph.

Third paragraph.

Fourth paragraph before trailing whitespace.



EOF

    my $parser = MediaWiki::Parser->new();

    $parser->input_text(
        {
            lines => [split(/^/, $text)],
        }
    );

    my $is_paragraph = sub {
        return is_paragraph($parser,@_);
    };

    # TEST*4*$para_asserts
    $is_paragraph->(
        "Trail/Lead WS - 1st Paragraph",
        "First paragraph after leading whitespace.\n"
    );

    $is_paragraph->(
        "Trail/Lead WS - 2nd Paragraph",
        "Second paragraph.\n",
    );
 
    $is_paragraph->(
        "Trail/Lead WS - 3rd Paragraph",
        "Third paragraph.\n",
    );

    $is_paragraph->(
        "Trail/Lead WS - 4th Paragraph",
        "Fourth paragraph before trailing whitespace.\n"
    );

    {
        my $end_token = $parser->get_next_token();

        # TEST
        ok (!defined($end_token),
            "Trail/Lead WS - we reached the end of the tokens."
        );
    }

    {
        my $end_token = $parser->get_next_token();

        # TEST
        ok (!defined($end_token),
            "Trail/Lead WS - another end token."
        );
    }
}

{
    my $text = <<'EOF';

Just say 'hello'.

EOF

    my $parser = MediaWiki::Parser->new();

    $parser->input_text(
        {
            lines => [split(/^/, $text)],
        }
    );

    # TEST*1*$para_asserts
    is_paragraph(
        $parser,
        "Single single-quotes pass as normal text.",
        "Just say 'hello'.\n",
    );
}

{
    my $text = <<'EOF';
Text and some ''italic text''. And some more text.
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
            { text => "Text and some ", },
            {
                t => "italics",
                p => "open",
            },
            { text => "italic text"},
            {
                t => "italics",
                p => "close",
            },
            { text => ". And some more text.\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Simple italic test on one line",
    );
}

{
    my $text = <<'EOF';
Hello ''Open Italic.
Non-italicized text.


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
            { text => "Hello ", },
            {
                t => "italics",
                p => "open",
            },
            { text => "Open Italic.\n"},
            {
                t => "italics",
                p => "close",
                implicit => 1,
            },
            { text => "Non-italicized text.\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Italic text will implicitly close at the end of the line",
    );
}

{
    my $text = <<'EOF';
Hello ''it1'' for ''Italic(2)'' ''
Another line ''italic'' - ''more''.

Another paragraph with ''italic''.

And another one.

He said: ''hello''.

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
            { text => "Hello ", },
            {
                t => "italics",
                p => "open",
            },
            { text => "it1"},
            {
                t => "italics",
                p => "close",
            },
            { text => " for " },
            {
                t => "italics",
                p => "open",
            },
            { text => "Italic(2)" },
            {
                t => "italics",
                p => "close",
            },
            { text => " " },
            {
                t => "italics",
                p => "open",
            },
            { text => "\n" },
            {
                t => "italics",
                p => "close",
                implicit => 1,
            },
            { text => "Another line " },
            {
                t => "italics",
                p => "open",
            },
            { text => "italic" },
            {
                t => "italics",
                p => "close",
            },
            { text => " - " },
            {
                t => "italics",
                p => "open",
            },
            { text => "more" },
            {
                t => "italics",
                p => "close",
            },
            { text => ".\n"},
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "Another paragraph with " },
            {
                t => "italics",
                p => "open",
            },
            { text => "italic" },
            {
                t => "italics",
                p => "close",
            },
            { text => ".\n" },
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "And another one.\n" },
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "He said: " },
            {
                t => "italics",
                p => "open",
            },
            { text => "hello" },
            {
                t => "italics",
                p => "close",
            },
            { text => ".\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "More comprehensive tests for \"''\".",
    );
}

{
    my $text = <<'EOF';
Paragraph with trailing italic ''

Another paragraph.
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
            { text => "Paragraph with trailing italic ", },
            {
                t => "italics",
                p => "open",
            },
            { text => "\n"},
            {
                t => "italics",
                p => "close",
                implicit => 1,
            },
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "Another paragraph.\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Paragraph with trailing italics.",
    );
}

# Start tests for standalone bold.

{
    my $text = <<'EOF';
Text and some '''bold text'''. And some more text.
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
            { text => "Text and some ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "bold text"},
            {
                t => "bold",
                p => "close",
            },
            { text => ". And some more text.\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Simple bold test on one line",
    );
}

{
    my $text = <<'EOF';
Hello '''Open Bold.
Non-boldized text.


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
            { text => "Hello ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "Open Bold.\n"},
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            { text => "Non-boldized text.\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Bold text will implicitly close at the end of the line",
    );
}

{
    my $text = <<'EOF';
Hello '''b1''' for '''Bold(2)''' '''
Another line '''bold''' - '''more'''.

Another paragraph with '''bold'''.

And another one.

He said: '''hello'''.

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
            { text => "Hello ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "b1"},
            {
                t => "bold",
                p => "close",
            },
            { text => " for " },
            {
                t => "bold",
                p => "open",
            },
            { text => "Bold(2)" },
            {
                t => "bold",
                p => "close",
            },
            { text => " " },
            {
                t => "bold",
                p => "open",
            },
            { text => "\n" },
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            { text => "Another line " },
            {
                t => "bold",
                p => "open",
            },
            { text => "bold" },
            {
                t => "bold",
                p => "close",
            },
            { text => " - " },
            {
                t => "bold",
                p => "open",
            },
            { text => "more" },
            {
                t => "bold",
                p => "close",
            },
            { text => ".\n"},
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "Another paragraph with " },
            {
                t => "bold",
                p => "open",
            },
            { text => "bold" },
            {
                t => "bold",
                p => "close",
            },
            { text => ".\n" },
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "And another one.\n" },
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "He said: " },
            {
                t => "bold",
                p => "open",
            },
            { text => "hello" },
            {
                t => "bold",
                p => "close",
            },
            { text => ".\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "More comprehensive tests for \"'''\".",
    );
}

{
    my $text = <<'EOF';
Paragraph with trailing bold '''

Another paragraph.
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
            { text => "Paragraph with trailing bold ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "\n"},
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },
            { text => "Another paragraph.\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Paragraph with trailing bolds.",
    );
}

{
    my $text = <<'EOF';
''Italics '''Italics and Bold''' Only Italics'' Nothing.

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
                t => "italics",
                p => "open",
            },
            { text => "Italics ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "Italics and Bold" },
            {
                t => "bold",
                p => "close",
            },
            { text => " Only Italics", },
            {
                t => "italics",
                p => "close",
            },
            { text => " Nothing.\n"},
            {
                t => "para",
                p => "close",
            },
        ],
        "Nested bold and italics.",
    );
}

{
    my $text = <<'EOF';
''Italics '''Italics and Bold'' Only Bold''' Nothing.

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
                t => "italics",
                p => "open",
            },
            { text => "Italics ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "Italics and Bold" },
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            {
                t => "italics",
                p => "close",
            },
            {
                t => "bold",
                p => "open",
                implicit => 1,
            },
            { text => " Only Bold", },
            {
                t => "bold",
                p => "close",
            },
            { text => " Nothing.\n"},
            {
                t => "para",
                p => "close",
            },
        ],
        "Interlaced (= Improperly nested) bold and italics.",
    );
}

{
    my $text = <<'EOF';
'''Bold ''Bold and Italics''' Only Italics'' Nothing.

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
                t => "bold",
                p => "open",
            },
            { text => "Bold ", },
            {
                t => "italics",
                p => "open",
            },
            { text => "Bold and Italics" },
            {
                t => "italics",
                p => "close",
                implicit => 1,
            },
            {
                t => "bold",
                p => "close",
            },
            {
                t => "italics",
                p => "open",
                implicit => 1,
            },
            { text => " Only Italics", },
            {
                t => "italics",
                p => "close",
            },
            { text => " Nothing.\n"},
            {
                t => "para",
                p => "close",
            },
        ],
        "Interlaced (= Improperly nested) italics and bold - 2.",
    );
}

{
    my $text = <<'EOF';
'''Bold ''And Italics
Hello

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
                t => "bold",
                p => "open",
            },
            { text => "Bold ", },
            {
                t => "italics",
                p => "open",
            },
            { text => "And Italics\n" },
            {
                t => "italics",
                p => "close",
                implicit => 1,
            },
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            {text => "Hello\n"},
            {
                t => "para",
                p => "close",
            },
        ],
        "Closing both bold and italics at the end of the line",
    );
}

{
    my $text = <<'EOF';
''Italics '''And Bold
Hello

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
                t => "italics",
                p => "open",
            },
            { text => "Italics ", },
            {
                t => "bold",
                p => "open",
            },
            { text => "And Bold\n" },
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            {
                t => "italics",
                p => "close",
                implicit => 1,
            },
            {text => "Hello\n"},
            {
                t => "para",
                p => "close",
            },
        ],
        "Closing both italics and bold at the end of the line",
    );
}

{
    my $text = <<'EOF';
'''''Italics and Bold'''''

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
                t => "italics",
                p => "open",
            },
            {
                t => "bold",
                p => "open",
            },
            { text => "Italics and Bold", },
            {
                t => "bold",
                p => "close",
            },
            {
                t => "italics",
                p => "close",
            },
            { text => "\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Quintuple Apostrophe - Bold and Italics",
    );
}

{
    my $text = <<'EOF';
'''B and '''''I''.

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
                t => "bold",
                p => "open",
            },
            { text => "B and ",},
            {
                t => "bold",
                p => "close",
            },
            {
                t => "italics",
                p => "open",
            },
            { text => "I", },
            {
                t => "italics",
                p => "close",
            },
            { text => ".\n", },
            {
                t => "para",
                p => "close",
            },
        ],
        "Quintuple Apostrophe - End B and Start I",
    );
}

{
    my $text = <<'EOF';
''I and '''''B'''.

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
                t => "italics",
                p => "open",
            },
            { text => "I and ",},
            {
                t => "italics",
                p => "close",
            },
            {
                t => "bold",
                p => "open",
            },
            { text => "B", },
            {
                t => "bold",
                p => "close",
            },
            { text => ".\n", },
            {
                t => "para",
                p => "close",
            },
        ],
        "Quintuple Apostrophe - End I and Start B",
    );
}

{
    my $text = <<'EOF';
''I and '''''B.

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
                t => "italics",
                p => "open",
            },
            { text => "I and ",},
            {
                t => "italics",
                p => "close",
            },
            {
                t => "bold",
                p => "open",
            },
            { text => "B.\n", },
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            {
                t => "para",
                p => "close",
            },
        ],
        "Quintuple Apostrophe - Implicit B at end.",
    );
}

{
    my $text = <<'EOF';
'''''''InB''''''''''''''''''''''.

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
                t => "italics",
                p => "open",
            },
            {
                t => "bold",
                p => "open",
            },
            { text => "''InB",},
            {
                t => "bold",
                p => "close",
            },
            {
                t => "italics",
                p => "close",
            },
            { text => "'''''''''''''''''.\n", },
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing more than 5 Apostrophes at once - should be appended to text.",
    );
}

{
    my $text = <<'EOF';
''''Bold''''.

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
                t => "bold",
                p => "open",
            },
            { text => "'Bold",},
            {
                t => "bold",
                p => "close",
            },
            { text => "'.\n", },
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing 4 Apostrophes",
    );
}

{
    my $text = <<'EOF';
OneLine<br>TwoLine<br />ThreeLine<br/>FourLine<br  / >FiveLine

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
            { text => "OneLine",},
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "TwoLine",},
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "ThreeLine",},
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "FourLine", },
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "FiveLine\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing newline",
    );
}

{
    my $text = <<'EOF';
One '''Line<br>Two''' Line<br />ThreeLine<br/>FourLine<br  / >FiveLine

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
            { text => "One ",},
            {
                t => "bold",
                p => "open",
            },
            {text => "Line"},
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "Two",},
            {
                t => "bold",
                p => "close",
            },
            {text => " Line",},
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "ThreeLine",},
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "FourLine", },
            {
                t => "linebreak",
                p => "standalone",
            },
            { text => "FiveLine\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing bold across newlines",
    );
}

{
    my $text = <<'EOF';
Sign: ~~~ Sign+Date: ~~~~ Date-Alone: ~~~~~

11 tildes: ~~~~~~~~~~~

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
            { text => "Sign: ",},
            {
                t => "signature",
                p => "standalone",
                st => "username",
            },
            {text => " Sign+Date: "},
            {
                t => "signature",
                p => "standalone",
                st => "username+date",
            },
            { text => " Date-Alone: ",},
            {
                t => "signature",
                p => "standalone",
                st => "date",
            },
            { text => "\n", },
            {
                t => "para",
                p => "close",
            },
            {
                t => "para",
                p => "open",
            },            
            {text => "11 tildes: ",},
            {
                t => "signature",
                p => "standalone",
                st => "date",
            },
            {
                t => "signature",
                p => "standalone",
                st => "date",
            },
            { text => "~\n",},
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing the signature - multiple tildes",
    );
}

{
    my $text = <<'EOF';
Hello <tt>Teletype</tt>!

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
            { text => "Hello ",},
            {
                t => "html",
                p => "open",
                helem => "tt",
            },
            { text => "Teletype", },
            {
                t => "html",
                p => "close",
                helem => "tt",
            },
            { text => "!\n", },
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing HTML element - tt",
    );
}

{
    my $text = <<'EOF';
Hello ''It <tt>Teletype</tt> EndIt''!

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
            { text => "Hello ",},
            {
                t => "italics",
                p => "open",
            },
            { text => "It ", },
            {
                t => "html",
                p => "open",
                helem => "tt",
            },
            { text => "Teletype", },
            {
                t => "html",
                p => "close",
                helem => "tt",
            },
            { text => " EndIt", },
            {
                t => "italics",
                p => "close",
            },
            { text => "!\n", },
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing HTML element in combination with Italics - well formed.",
    );
}

{
    my $text = <<'EOF';
Hello <tt>Tt ''Italics'' EndTt</tt>!

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
            { text => "Hello ",},
            {
                t => "html",
                p => "open",
                helem => "tt",
            },
            { text => "Tt ", },
            {
                t => "italics",
                p => "open",
            },
            { text => "Italics", },
            {
                t => "italics",
                p => "close",
            },
            { text => " EndTt", },
            {
                t => "html",
                p => "close",
                helem => "tt",
            },
            { text => "!\n", },
            {
                t => "para",
                p => "close",
            },
        ],
        "Testing HTML element in combination with Italics - well formed (#2)",
    );
}

{
    my $text = <<'EOF';
<tt>TT ''' Bold - End TT </tt> End Bold.'''

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
                t => "html",
                p => "open",
                helem => "tt",
            },
            { text => "TT ", },
            {
                t => "bold",
                p => "open",
            },
            { text => " Bold - End TT "},
            {
                t => "bold",
                p => "close",
                implicit => 1,
            },
            {
                t => "html",
                p => "close",
                helem => "tt",
            },
            {
                t => "bold",
                p => "open",
                implicit => 1,
            },
            { text => " End Bold.", },
            {
                t => "bold",
                p => "close",
            },
            { text => "\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Interlaced HTML Markup and normal wiki markup",
    );
}

{
    my $text = <<'EOF';
'''Start Bold <tt>Start TT - End Bold''' End TT </tt>
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
                t => "bold",
                p => "open",
            },
            { text => "Start Bold ", },
            {
                t => "html",
                p => "open",
                helem => "tt",
            },
            { text => "Start TT - End Bold", },
            {
                t => "html",
                p => "close",
                helem => "tt",
                implicit => 1,
            },
            {
                t => "bold",
                p => "close",
            },
            {
                t => "html",
                p => "open",
                helem => "tt",
                implicit => 1,
            },
            { text => " End TT ", },
            {
                t => "html",
                p => "close",
                helem => "tt",
            },
            { text => "\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "Interlaced HTML Markup and normal wiki markup - 2",
    );
}

{
    my $text = <<'EOF';
Hello &lt;fi&gt; &amp;&amp; &eacute; There
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
            { text => "Hello <fi> && é There\n" },
            {
                t => "para",
                p => "close",
            },
        ],
        "SGML Entities",
    );
}
