#!/bin/bash
app_url="$(cat app.url)"
wget -q -O main.html "$app_url"
diff -u main.html{.expected,}
wget -q -O add.html "$app_url"add/
diff -u add.html{.expected,}
wget -q -O search-all.html "$app_url"'search/?all=1'
diff -u search-all.html{.expected,}
