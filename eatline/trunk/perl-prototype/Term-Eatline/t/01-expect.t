#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;

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
my $home_key  = "\eOH";
my $end_key   = "\eOF";

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
        "Testing for KEY_LEFT()"
    );

    # TEST
    test_output(
        "123" . ($left_key x 10) . "{Before}\ce\n",
        "{Before}123\n",
        "Testing for excessive KEY_LEFT()."
    );

    # TEST
    test_output(
        "tring${home_key}S\n",
        "String\n",
        "Testing for <Home>."
    );

    # TEST
    test_output(
        "Inner${home_key}Prefix-\ce==Suffix\n",
        "Prefix-Inner==Suffix\n",
        "Testing for <Home> and Ctrl+E."
    );

    # TEST
    test_output(
        "Inner\caPrefix-${end_key}==Suffix\n",
        "Prefix-Inner==Suffix\n",
        "Testing for <End>."
    );

    # TEST
    test_output(
        "Inner${home_key}Prefix-${end_key}==Suffix\n",
        "Prefix-Inner==Suffix\n",
        "Testing for <End> and <Home>."
    );

    # TEST
    test_output(
        "Sch\b\bhlomi Fish\n",
        "Shlomi Fish\n",
        "Testing for backspace."
    );
    
    # TEST
    test_output(
        "Quanta${home_key}\b${end_key}\b\btrumPOD\b\b\blo\n",
        "Quantrumlo\n",
        "backspace - don't delete from beginning and more"
    );
    
}
