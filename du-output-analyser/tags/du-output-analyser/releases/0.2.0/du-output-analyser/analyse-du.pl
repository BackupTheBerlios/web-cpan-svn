#!/usr/bin/perl

# Copyright (c) 2008, Shlomi Fish
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

our $VERSION = "0.2.0";

my $prefix = "";
my $depth = 1;
my $sort = 1;
my $man = 0;
my $help = 0;
my $version = 0;

GetOptions(
    "prefix|p=s" => \$prefix,
    "depth|d=n" => \$depth,
    "sort" => \$sort,
    "help|h" => \$help, 
    "man" => \$man,
    "version" => \$version,
) or pod2usage(2);

if ($help)
{
    pod2usage(1)
}

if ($man)
{
    pod2usage(-verbose => 2);
}

if ($version)
{
    print "analyse-du.pl version $VERSION\n";
    exit(0);
}

my @results=();
while(my $line = <>)
{
    chomp($line);
    if ($line =~ /^(\d+)\t.\/(.*)$/)
    {
        my ($size, $path) = ($1, $2);
        if (
                (substr($path, 0, length($prefix)) eq $prefix)
                    &&
                ((substr($path, length($prefix)) =~ tr{/}{/}) == $depth)
           )
        {
            push @results, [$path, $size];
        }
    }
}

if ($sort)
{
    @results = (sort { $a->[1] <=> $b->[1] } @results);
}

print map { "$_->[1]\t$_->[0]\n" } @results;

=head1 NAME

analyse-du.pl - analyse the output of C<\du .>

=head1 SYNPOSIS

B<analyse-du.pl> --prefix=progs/ --depth=1 --sort

=head1 VERSION

0.2.0

=head1 DESCRIPTION

This analyses the output of C<\du .> looking for directories with a certain
prefix, a certain depth and possibly sorting the output by size. It aims to
aid in finding the most space-consuming components in the directory tree
on the disk.

=head1 OPTIONS

=over 4

=item B<--prefix> | B<-p>

This specifies a prefix for the directories according which to filter them. 

=item B<--depth> | B<-d>

This specifies a depth of the directories and their component numbers.

Defaults to 1.

=item B<--nosort>

When specified, this option instructs not to sort the items according to their
size.

=item B<--help> B<-h>

Displays the help.

=item B<--man>

Displays the man page.

=item B<--version>

Displays the version.

=back

=head1 CREDITS

Written by Shlomi Fish - L<http://www.shlomifish.org/> .

=head1 COPYRIGHTS & LICENSE

Copyright by Shlomi Fish, 2008. All rights reserved.

This file is licensed under the MIT X11 License:

L<http://www.opensource.org/licenses/mit-license.php>

=cut
