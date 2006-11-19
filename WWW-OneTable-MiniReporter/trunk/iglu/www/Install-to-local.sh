#!/bin/bash
for I in "Shlomif/MiniReporter.pm" "Shlomif/MiniReporter/HelperObj.pm" ; do 
    dir="/home/shlomi/apps/perl/modules/lib/perl5/site_perl/5.8.8/$(dirname "$I")"
    mkdir -p "$dir"
    cp -f "$I" "$dir"
done
