#!/usr/bin/perl 

use strict;
use warnings;

use File::Spec;
use YAML::XS;

opendir my $cwd, ".";
my @paths = sort { $a cmp $b } grep { /\.(jpg|png)$/ } (File::Spec->no_upwards(readdir($cwd)));
closedir ($cwd);

my $yaml_fn = "upload-spec.yml";
if (-e $yaml_fn)
{
    die "YAML File already exists!";
}
YAML::XS::DumpFile(
    $yaml_fn,
    {
        common_tags => [],
        files =>
        [
            (map
            {
                {
                    'filename' => $_,
                    'tags' => [],
                    title => "",
                    description_parts => 
                    [ map { "" } (1 .. 5) ],
                }
            }
            @paths),
        ],
    },
);

