#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use Expect;
use File::Spec;
use Carp;

sub read_file
{
    my $path = shift;

    open my $in, "<", $path;
    binmode $in, ":utf8";
    my $contents;
    {
        local $/;
        $contents = <$in>
    }
    close($in);
    return $contents;
}

sub test_output
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ($input, $result, $msg) = @_;

    my $exp = Expect->new();
    # To disable echoing.
    $exp->raw_pty(1);
    $exp->log_stdout(0);

    my $fn_with_output = File::Spec->catfile(qw(t data test.txt));

    $exp->spawn(
        $^X, File::Spec->catfile(qw(t data bin read-line-to-file.pl)),
        "-o", $fn_with_output,
    )
        or Carp::confess("Cannot spawn read-line-to-file");

    $exp->send($input);

    $exp->soft_close();

    my $contents = read_file($fn_with_output);
    is ($contents, $result, $msg);

    unlink($fn_with_output);
}

{
    # TEST
    test_output("Hello\n", "Hello\n", "Testing for simple output - 1");

    # TEST
    test_output("Welcome to Israel!\n", "Welcome to Israel!\n", 
        "Testing for simple output - 2"
    );

    # TEST
    test_output(
        "tring\caS\n",
        "String\n",
        "Testing for Ctrl+A."
    );
}
