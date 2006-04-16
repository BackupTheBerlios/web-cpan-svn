#!/usr/bin/perl

use strict;
use warnings;

use lib "./lib/";

use CGI::Application::NetNewsIface;

my $app = CGI::Application::NetNewsIface->new(
    PARAMS => {
        'nntp_server' => "nntp.perl.org",
        'articles_per_page' => 10,
    },
);

$app->run();

1;

