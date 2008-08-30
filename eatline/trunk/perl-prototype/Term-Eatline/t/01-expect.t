#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

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

# You can determine these things by issuing dump.tcl on the commands.
# See dump.tcl for more information.
my $right_key = "\eOC";
my $left_key  = "\eOD";

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

    # TEST
    test_output(
        "Inner\caPrefix-\ce==Suffix\n",
        "Prefix-Inner==Suffix\n",
        "Testing for Ctrl+A and Ctrl+E."
    );

    # TEST
    test_output(
        "[[]]\ca${right_key}hello${right_key}${right_key}row\n",
        "[hello[]row]\n",
        "Testing for KEY_RIGHT()."
    );

    # TEST
    test_output(
        "[]\ca${right_key}${right_key}${right_key}suffix\n",
        "[]suffix\n",
        "Testing for excessive KEY_RIGHT()."
    );

    # TEST
    test_output(
        "[[[]]]" . ($left_key x 3) . "String Inside\n",
        "[[[String Inside]]]\n",
        "Testing for LEFT_KEY()"
    );

}
