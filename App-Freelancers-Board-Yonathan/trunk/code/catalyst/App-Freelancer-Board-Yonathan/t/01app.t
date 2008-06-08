use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'App::Freelancer::Board::Yonathan' }

ok( request('/')->is_success, 'Request should succeed' );
