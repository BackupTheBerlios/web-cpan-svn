#!/bin/bash
arg="$1"
shift
upload_to_base="shlomif@iglu.org.il:/iglu/Hosts/www.iglu.org.il/webapps/jobs-db/"
upload_to="${upload_to_base}new/"
if [ "$arg" = "--stable" ] ; then
    upload_to="$upload_to_base"
fi
cat App-debug.pl | sed -e '/^#!\/usr\/bin\/perl/ { s!-w!! }' > App.pl
chmod 755 App.pl
rsync -v --progress --rsh=ssh --relative \
    App.pl invalidate-records.pl populate-new-table.pl \
    MyConfig.pm style.css Shlomif/MiniReporter.pm \
    Shlomif/MiniReporter/HelperObj.pm \
    Consultants.pl ConsultantsConfig.pm update-rss-feed.pl \
    admin-password.txt \
    templates/*.tt \
    "$upload_to"

