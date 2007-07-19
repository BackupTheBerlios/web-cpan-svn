#!perl -T

use strict;
use warnings;

use Test::More tests => 8;

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
