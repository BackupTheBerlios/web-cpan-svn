#!/usr/bin/perl 

use strict;
use warnings;

use File::Spec;
use YAML;

opendir my $cwd, ".";
my @paths = sort { $a cmp $b } grep { /\.(jpg|png)$/ } (File::Spec->no_upwards(readdir($cwd)));
closedir ($cwd);

my $yaml_fn = "upload-spec.yml";
if (-e $yaml_fn)
{
    die "YAML File already exists!";
}
open my $yaml, ">", $yaml_fn;
print {$yaml} Dump(
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
    }
);
close($yaml);

