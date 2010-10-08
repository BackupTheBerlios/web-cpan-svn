#!/usr/bin/perl

use strict;
use warnings;

use IO::All;

my ($version) = 
    (map { m{\$VERSION *= *'([^']+)'} ? ($1) : () } 
    io->file('lib/XML/Grammar/Fortune/Synd.pm')->getlines()
    )
    ;

if (!defined ($version))
{
    die "Version is undefined!";
}

my $mini_repos_base = 'https://svn.berlios.de/svnroot/repos/web-cpan/XML-Grammar-Fortune';

my @cmd = (
    "svn", "copy", "-m",
    "Tagging the XML-Grammar-Fortune-Synd release as $version",
    "$mini_repos_base/trunk",
    "$mini_repos_base/tags/releases/XML-Grammar-Fortune-Synd/cpan/$version",
);

print join(" ", @cmd), "\n";
exec(@cmd);

