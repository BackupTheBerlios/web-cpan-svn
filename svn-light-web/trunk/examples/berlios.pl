#!/usr/bin/perl -w

use strict;
use warnings;

use lib "./lib";

use SVN::RaWeb::Light;

my $app = SVN::RaWeb::Light->new(
    'url' => "svn://svn.berlios.de/web-cpan/",
);

$app->run();

