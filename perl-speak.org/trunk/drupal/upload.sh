#!/bin/bash
rsync -a -v --progress --rsh=ssh \
    --exclude="**/.svn/**" \
    --exclude="sites/default/password.php" \
    --exclude="sites/default/settings.php" \
    --exclude="**/*~" \
    * \
    ragnar:perl-speak/public_html/
