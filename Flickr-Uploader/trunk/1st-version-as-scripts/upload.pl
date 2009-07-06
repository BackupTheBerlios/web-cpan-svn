#!/usr/bin/perl 

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

