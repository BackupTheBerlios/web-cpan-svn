#!/usr/bin/perl

use strict;
use warnings;

use Net::DBus;
use Data::Dumper;

my $bus = Net::DBus->find;

# Get a handle to the HAL service
my $amarok = $bus->get_service("org.kde.amarok");

my $tracklist = $amarok->get_object("/TrackList", "org.freedesktop.MediaPlayer");

print Dumper($tracklist->GetMetadata(0));
