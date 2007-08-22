#!perl
#!perl -T

use strict;
use warnings;

use Test::More tests => 2;

use lib "./t/lib";

use MediaWiki::Parser::Test::IsTokens;

use MediaWiki::Parser;

{
    my $text = <<'EOF';
Hello <nowiki> There ''Lambda Pi'' Fill
There for you ''' Lambda '''
</nowiki>


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
                text => ("Hello  There ''Lambda Pi'' Fill\n"
                    . "There for you ''' Lambda '''\n\n" )
            },
            {
                t => "para",
                p => "close",
            },
        ],
        "<nowiki> - 1",
    );
}

{
    my $text = <<'EOF';
Foo bar <nowiki>There ''Yes</nowiki> Baz Quux Lom <nowiki>Kom
Trude <tt>Plus</nowiki>. On the house.

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
                text => 
                    ("Foo bar There ''Yes Baz Quux Lom Kom\n"
                    . "Trude <tt>Plus. On the house.\n"),
            },
            {
                t => "para",
                p => "close",
            },
        ],
        "<nowiki> - 2 - multiple nowikis are concatenated",
    );
}
