use Test::More tests => 4;

BEGIN {
use_ok( 'XML::CompareML::Base' );
use_ok( 'XML::CompareML::DocBook' );
use_ok( 'XML::CompareML::HTML' );
use_ok( 'XML::CompareML' );
}

diag( "Testing XML::CompareML::Base $XML::CompareML::Base::VERSION, Perl 5.008006, /usr/bin/perl5.8.6" );
