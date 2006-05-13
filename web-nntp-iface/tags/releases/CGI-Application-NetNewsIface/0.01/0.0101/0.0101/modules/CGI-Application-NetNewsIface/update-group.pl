#!/usr/bin/perl

use strict;
use warnings;

use MyWebNntp;

MyWebNntp::get_app()->update_group(shift(@ARGV));

1;

