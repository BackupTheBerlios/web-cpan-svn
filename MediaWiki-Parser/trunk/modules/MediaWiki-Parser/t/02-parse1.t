#!perl -T

use strict;
use warnings;

use Test::More tests => 71;

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

# Token position (open/close/etc.)
sub token_pos
{
    my $token = shift;

    return   $token->is_opening() ? "open" 
           : $token->is_closing() ? "close"
           : "unknown";
}

my %pos_tokens_map =
(
    "paragraph" => "para",
    "italics" => "italics",
    "bold" => "bold",
);

sub get_token_representation
{
    my $token = shift;

    if (exists($pos_tokens_map{$token->type()}))
    {
        my $ret =
        {
            t => $pos_tokens_map{$token->type()},
            p => token_pos($token),
        };

        if ($token->is_implicit())
        {
            $ret->{implicit} = 1;
        }

        return $ret;
    }
    elsif ($token->type() eq "text")
    {
        return { text => $token->text() };
    }
    else
    {
        return "UNKNOWN_TOKEN";
    }
}

sub is_tokens_deeply
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($parser, $expected_tokens, $blurb) = @_;

    my @got_tokens;

    while (defined(my $token = $parser->get_next_token()))
    {
        push @got_tokens, get_token_representation($token);
    }

    if (defined(scalar($parser->get_next_token())))
    {
        ok(0, "$blurb - does not return undef twice at end");
    }
    else
    {
        is_deeply(
            \@got_tokens,
            $expected_tokens,
            $blurb
        );
    }
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
