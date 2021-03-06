#!/bin/bash
app_url="$(cat app.url)"
wget -q -O main.html "$app_url"
diff -u main.html{.expected,}
wget -q -O add.html "$app_url"add/
diff -u add.html{.expected,}
wget -q -O remove.html "$app_url"remove/
diff -u remove.html{.expected,}
wget -q -O search-all.html "$app_url"'search/?all=1'
diff -u search-all.html{.expected,}
wget -q -O show-record1.html "$app_url"'show-record/46/'
diff -u show-record1.html{.expected,}
wget -q -O add-with-params.html "$app_url"'add/?area=Tel+Aviv&title=Perl+Programmer+for+Horace&workplace=Horace+Inc.&description=&requirements=&address=&phone=&cellphone=&fax=&email=shlomif%40iglu.org.il&contact_person=Shlomi+Fish&preview=Preview'
diff -u add-with-params.html{.expected,}
