
use Test::More tests => 3;
use_ok( Catalyst::Test, 'WWW::BooksTracker' );
use_ok('WWW::BooksTracker::C::Book');

ok( request('book')->is_success );

