package MyModulesList;

use strict;

my @modules_list =
(
    {
        'perl_name' => "HTML-Strip-Whitespace",
        'text' => "Strip Whitespace",
        'title' => "Strip Unnecessary Whitespace from HTML",
    },
    {
        'perl_name' => "HTML-Widgets-NavMenu",
        'text' => "Navigation Menu",
        'title' => "Generate Navigation Menus",
        'svn_dir' => "nav-menu",
        'desc' => <<"EOF",
<p>        
This is a module to generate HTML navigation menus, such as those found in
the side-bar of various sites (like this one, or 
<a href="http://www.shlomifish.org/">Shlomi Fish' Homepage</a>). It supports
many advanced features such as building relative links or absolute links, 
selective expansion, and multi-host sites.
</p>
<p>
Furthermore, it is extensively tested, and the author believes its code can
be easily extended and customized, given a small amount of studies.
</p>
EOF
    },
    {
        'perl_name' => "SVN-RaWeb-Light",
        'text' => "Light SVN Interface",
        'title' => "A Lightweight Web-based Subversion Interface",
        'svn_dir' => "svn-light-web",
        'desc' => <<"EOF",
<p>
This module once installed and driven by a CGI script provides a lightweight
Web-based browser for remote 
<a href="http://subversion.tigris.org/">Subversion</a> repositories, not 
unlike the default HTML one for http:// repositories. (with some improvements)
</p>
<p>
If you deploy this module in a public URL with a good bandwidth, let me know 
so I can link to it here for demonstration purposes.
</p>
EOF
    },
    {
        'perl_name' => "WWW-Form",
        'text' => "WWW::Form",
        'title' => "Manage Forms Flow Using Perl",
    },
);

sub get_module_list
{
    return \@modules_list,
}

1;


