#!/usr/bin/perl

use Test::Run::Obj;

my $tester = 
    Test::Run::Obj->new(
        # 'test_files' => ["t/sample-tests/simple_fail"]
        'test_files' => ["t/sample-tests/head_end"]
    );
$tester->runtests();

