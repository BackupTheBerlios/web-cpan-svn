package Net::NNTP;

use warnings;
use strict;

BEGIN
{
    $INC{'Net/NNTP.pm'} = "/usr/lib/perl5/site_perl/5.8.6/Net/NNTP.pm";
}

our @groups = ();

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    my $server = shift;
    $self->{'_server'} = $server;
    return $self;
}

1;

