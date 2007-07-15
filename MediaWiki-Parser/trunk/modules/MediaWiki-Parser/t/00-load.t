#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'MediaWiki::Parser' );
}

diag( "Testing MediaWiki::Parser $MediaWiki::Parser::VERSION, Perl $], $^X" );
