#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Term::Eatline' );
}

diag( "Testing Term::Eatline $Term::Eatline::VERSION, Perl $], $^X" );
