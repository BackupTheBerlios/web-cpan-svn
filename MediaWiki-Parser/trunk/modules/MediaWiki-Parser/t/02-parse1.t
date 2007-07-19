#!perl -T

use strict;
use warnings;

use Test::More tests => 54;

use MediaWiki::Parser;

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
        my ($para_id, $text) = @_;

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
        my ($para_id, $text) = @_;

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
