use Test::More tests => 2;
use_ok( Catalyst::Test, 'WWW::BooksTracker' );

ok( request('/')->is_success );

