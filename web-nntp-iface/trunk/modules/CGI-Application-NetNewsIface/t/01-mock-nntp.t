#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "t", "lib");

use CGI::Application::NetNewsIface::Test::MockNNTP;
use CGI::Application::NetNewsIface::Test::Data1;

{
    my $nntp = Net::NNTP->new("nntp.shlomifish.org");
    # TEST
    is ($nntp->{'_server'}, "nntp.shlomifish.org", "Checking for _server variable");
}

{
    local $Net::NNTP::groups = Data1::get_groups();
    {
        my $nntp = Net::NNTP->new("nntp.shlomifish.org");
        # TEST
        is_deeply($nntp->list(),
            {
                'perl.qa' => [25, 1, undef],
                'perl.advocacy' => [5, 1, undef],
            },
            "->list() is OK",
        );

        my $group_name = $nntp->group("perl.qa");
        # TEST
        is ($group_name, "perl.qa", "->group() in scalar context");
    }
    {
        my $nntp = Net::NNTP->new("nntp.shlomifish.org");

        my @info = $nntp->group("perl.qa");
        # TEST
        is_deeply (\@info, [25, 1, 25, "perl.qa"], 
            "->group() in list context"
        );
    }
}

