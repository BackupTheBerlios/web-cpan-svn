#!/usr/bin/perl 

# Copyright (c) 2009 Shlomi Fish
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# $Id$
#
# Written by Shlomi Fish:
# http://www.shlomifish.org/

use strict;
use warnings;

use Getopt::Long;
use XML::Feed;
use Time::HiRes;

my $rand = 0;
my @authors_blacklist;
my $output_fn;

GetOptions(
    'rand' => \$rand,
    'blacklist=s' => \@authors_blacklist,
    'o|output=s' => \$output_fn,
);

my %authors_to_exclude = (map { $_ => 1 } @authors_blacklist);

# If --rand is specified - sleep for a given time before reading the
# feeds so to not overload the servers simultaneously.
if ($rand)
{
    open my $in, "<", "/dev/urandom";
    my $buf;
    read($in, $buf, 4);
    close($in);
    my $l = unpack("l", $buf);
    Time::HiRes::sleep(($l%7000)/10);
}

my $feed = XML::Feed->parse(
    URI->new('http://use.perl.org/search.pl?op=journals;content_type=atom')
);

my $new_feed = XML::Feed->new('Atom');

foreach my $entry ($feed->entries())
{
    if ( ! exists( $authors_to_exclude{$entry->author()} ) )
    {
        $new_feed->add_entry($entry);
    }
}

open my $out_fh, ">", $output_fn
    or die "Could not open destination - $!";
print {$out_fh} $new_feed->as_xml();
close($out_fh);
