#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "t", "lib");

use CGI::Application::NetNewsIface::Test::MockNNTP;

{
    my $nntp = Net::NNTP->new("nntp.shlomifish.org");
    # TEST
    is ($nntp->{'_server'}, "nntp.shlomifish.org", "Checking for _server variable");
}


