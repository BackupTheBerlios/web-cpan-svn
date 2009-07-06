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

use strict;
use warnings;

use YAML::XS;
use Carp;

use Flickr::Upload;

my $data = YAML::XS::LoadFile("upload-spec.yml");

my $common_tags = $data->{common_tags};

print "\$common_tags == $common_tags\n\n";

my $files = $data->{files};

foreach my $f (@$files)
{
    if (! -f $f->{filename})
    {
        confess "Unknown filename $f->{filename}!";
    }
}

sub get_total_desc
{
    my $f = shift;
    my $ret = join("\n", grep { length($_) > 0 } @{$f->{'description_parts'}});

    $ret = s/\n{3,}/\n\n/g;

    return $ret;
}

my $ua = Flickr::Upload->new(
    {
        key => "80ae1c17f5096f699b46a8256b918d2f",
        secret => "167830a9c74f74ac",
    }
);

open my $log, ">>", "dump.txt";
foreach my $f (@$files)
{
    $ua->upload(
            auth_token => '72157600129103080-4c0f738e272f0348',
            photo => "./" .$f->{filename},
            tags => "$common_tags $f->{tags}",
            title => $f->{'title'},
            description => get_total_desc($f),,
            is_public => 1,
    ) or die "Unknown";
    print {$log} $f->{filename}, "\n";
    $log->flush();
}
close($log);

