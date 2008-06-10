#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Text::Qantor' );
	use_ok( 'Text::Qantor::Parser' );
}

diag( "Testing Text::Qantor $Text::Qantor::VERSION, Perl $], $^X" );
