
use Test::More tests => 3;
use_ok( Catalyst::Test, 'WWW::BooksTracker' );
use_ok('WWW::BooksTracker::C::Main');

ok( request('main')->is_success );

