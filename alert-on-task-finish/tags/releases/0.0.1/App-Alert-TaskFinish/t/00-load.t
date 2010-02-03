#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Alert::TaskFinish' );
}

diag( "Testing App::Alert::TaskFinish $App::Alert::TaskFinish::VERSION, Perl $], $^X" );
