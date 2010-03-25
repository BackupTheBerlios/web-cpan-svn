#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET6;

use Test::More;

my ($server,$port);
# try to create inet6 listener on some port, w/o given
# LocalHost (should use :: then)
for( my $i=0;$i<100;$i++) {
	$port = int(rand(50000)+2000);
	$server = IO::Socket::INET6->new(
		LocalPort => $port,
		Listen => 10,
	) or next;
}
if (!$server)
{
    plan skip_all => "failed to create inet6 listener";
}
elsif ( $server->sockhost ne '::' )
{
	plan skip_all => "not listening on ::, maybe inet6 not available";
}
else
{
    plan tests => 1;

    my $client = IO::Socket::INET6->new( "[::1]:$port" );

    # TEST
    ok($client, "Client was initialised - connected.");
}
