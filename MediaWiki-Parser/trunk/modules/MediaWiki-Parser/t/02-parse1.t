#!perl -T

use strict;
use warnings;

use Test::More tests => 2;

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

    my $token1 = $parser->get_next_token();

    # TEST
    is ($token1->type(),
        "paragraph",
        "Token is a paragraph"
    );

    # TEST
    ok ($token1->is_start(), "First token is paragraph start");
}
