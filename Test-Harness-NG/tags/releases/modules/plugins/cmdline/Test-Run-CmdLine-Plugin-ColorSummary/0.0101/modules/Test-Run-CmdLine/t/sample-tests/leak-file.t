#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;

use Test::More tests => 1;

my $sample_tests_dir = File::Spec->catfile("t", "sample-tests");
my $test_file = File::Spec->catfile($sample_tests_dir, "one-ok.t");
my $leaked_files_dir = File::Spec->catfile($sample_tests_dir, "leaked-files-dir");
my $leaked_file = File::Spec->catfile($leaked_files_dir, "new-file.txt");

open O, ">", $leaked_file;
print O "This is a new file";
close(O);

# TEST
ok(1, "This test succeeded");

