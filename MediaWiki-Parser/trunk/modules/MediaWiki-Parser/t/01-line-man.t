use strict;
use warnings;

use Test::More tests => 8;

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

    # TEST
    is_deeply(
        $manager->next_line(),
        \"Writing code in C is a Bad Idea<tm>.\n",
        "next_line() returns the next line."
    );

    # TEST
    is_deeply(
        $manager->curr_line(),
        \"Writing code in C is a Bad Idea<tm>.\n",
        "Now that it's incremented - curr_line returns the second line."
    );  
}

{
    my $manager = MediaWiki::Parser::LineMan->new(
        lines => [@lines1]
    );

    # Now we're at line 2
    $manager->next_line();
    # Now we're at line 3
    $manager->next_line();
    
    my $right_exception = 0;
    
    eval
    {
        $manager->next_line();
    };

    if (MediaWiki::Parser::LineMan::Exception::End->caught())
    {
        $right_exception = 1;
    }
    # TEST
    ok ($right_exception, "The ::End exception was thrown.");
}

my @lines2=split(/^/,<<'EOF');
First they came for my Perl programs.
Then they came for my C programs.
Then they tried to compile them.
And then they gave up.
EOF

{
    my $manager = MediaWiki::Parser::LineMan->new(
        lines => [@lines2],
    );

    $manager->with_curr_line(
        sub {
            my $l = shift;

            # TEST
            ok ($$l =~ m{^First }g, "with_curr_line works.");
        },
    );

    $manager->with_curr_line(
        sub {
            my $l = shift;

            # TEST
            ok ($$l =~ m{\Gthey came}g, "with_curr_line works again.");
        },
    );

    $manager->next_line();

    $manager->with_curr_line(
        sub {
            my $l = shift;

            # TEST
            ok ($$l =~ m{C programs}g, "with_curr_line works for next line.");
        },
    );
}

