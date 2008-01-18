use strict;
use warnings;

use Test::More tests => 1;

use IO::Socket::INET6;

my $listen = IO::Socket::INET6->new(Listen => 2,
				Proto => 'tcp',
				# some systems seem to need as much as 10,
				# so be generous with the timeout
				Timeout => 15,
			       ) or die "$@";

# TEST
ok ($listen->sockhost(), "Checking for sockhost() success");

