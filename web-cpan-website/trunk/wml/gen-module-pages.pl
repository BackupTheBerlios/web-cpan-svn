#!/usr/bin/perl

use strict;
use warnings;

use lib "./lib";

use MyModulesList;

my $modules = MyModulesList::get_module_list();

foreach my $m (@$modules)
{
    my $name = $m->{'perl_name'};
    my $dir_name = "src/modules/$name";
    if (! -d $dir_name)
    {
        mkdir($dir_name);
        system("svn", "add", "-N", $dir_name);
        my $file_name = "$dir_name/index.html.wml";
        open O, ">", $file_name;
        print O <<"EOF";
#include "../template.wml"

<gen_module_html "$name" />
EOF
        close(O);
        system("svn","add",$file_name);
        # Update the template.wml so the navigation menus will be rebuilt.
        my $t = time();
        utime($t, $t, "template.wml");
    }
}
1;
