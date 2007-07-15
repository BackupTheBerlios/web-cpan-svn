use strict;
use warnings;

use Test::More tests => 2;

# Tests for the line manager.

use MediaWiki::Parser::LineMan;

my @lines1 = split(/^/, <<'EOF');
Hello world!
Writing code in C is a Bad Idea<tm>.
The more I know, the more I know that I do not know.
EOF

{
    my $manager = MediaWiki::Parser::LineMan->new(
        lines => [@lines1]
    );

    # TEST
    ok ($manager, "Calling the constructor");

    # TEST
    is_deeply(
        $manager->curr_line(),
        \"Hello world!\n",
        "->curr_line() works"
    );
}
