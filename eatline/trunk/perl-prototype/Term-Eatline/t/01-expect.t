#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

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

{
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

    $exp->send("Hello\n");

    $exp->soft_close();

    my $contents = read_file($fn_with_output);
    # TEST
    is ($contents, "Hello\n", "Simple string entry is OK.");

    unlink($fn_with_output);
}

