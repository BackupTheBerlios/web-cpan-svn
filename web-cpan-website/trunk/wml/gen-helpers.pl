#!/usr/bin/perl

use strict;
use warnings;

use HTML::Latemp::GenMakeHelpers;

my $generator = 
    HTML::Latemp::GenMakeHelpers->new(
        'hosts' =>
        [
            {
                'id' => "common",
                'source_dir' => "common",
                'dest_dir' => "common",
            },
            {
                'id' => "src",
                'source_dir' => "src",
                'dest_dir' => "dest",
            }
        ],
    );
    
$generator->process_all();

use IO::All;

my $text = io("include.mak")->slurp();
$text =~ s!^(T2_DOCS = .*)humour/fortunes/fortunes-index.html!$1!m;
io("include.mak")->print($text);

1;

