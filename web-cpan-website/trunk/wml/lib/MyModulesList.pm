package MyModulesList;

use strict;

my @modules_list =
(
    {
        'perl_name' => "HTML-Strip-Whitespace",
        'text' => "Strip Whitespace",
        'title' => "Strip Unnecessary Whitespace from HTML",
        'svn_dir' => "html-strip-ws",
        'desc' => <<"EOF",
<p>
This is a module to strip whitespace out of HTML pages. As opposed to other
solutions (like 
<a href="http://search.cpan.org/dist/HTML-Clean/">HTML-Clean</a>), it does not
touch whitespace inside <tt>&lt;pre&gt;</tt> tags (and in the future possibly
other whitespace-aware markup.) 
</p>
<p>
Using the <a href="http://search.cpan.org/dist/HTML-Tidy/">HTML-Tidy</a> (or
otherwise <a href="http://tidy.sourceforge.net/">the HTML Tidy library</a>) for
that may be preferable, because they are probably faster, but this module still
exists and will be maintained.
</p>
EOF
    },
    {
        'perl_name' => "HTML-Widgets-NavMenu",
        'text' => "Navigation Menu",
        'title' => "Generate Navigation Menus",
        'svn_dir' => "nav-menu",
        'desc' => <<"EOF",
<p>        
This is a module to generate HTML navigation menus, such as those found in
the side-bar of various sites (like that of this one, or of
<a href="http://www.shlomifish.org/">Shlomi Fish' Homepage</a>). It supports
many advanced features such as building relative links or absolute links, 
selective expansion, and multi-host sites.
</p>
<p>
Furthermore, it is extensively tested, and the author believes its code can
be easily extended and customized, given a small amount of studying.
</p>
<h2>Web-Sites that Use HTML::Widgets::NavMenu</h2>
<ul>
<li>
<a href="http://www.shlomifish.org/">Shlomi Fish' Homepage</a> 
(<a href="http://stalker.iguide.co.il:8080/svn/shlomif-homepage/homepage/trunk/">Code</a>)
</li>
<li>
<a href="http://perl-begin.berlios.de/">The Perl Beginners' Site</a>
(<a href="http://opensvn.csie.org/perlbegin/perl-begin/trunk/">Code</a>)
</li>
<li>
<a href="http://www.aspetersen.de/">Alexia &amp; Stephan Petersen</a> 
</li>
</ul>
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
        'svn_dir' => "www-form",
        'desc' => <<"EOF"
<p>
WWW::Form is a module for handling the world-wide-web form process. It
enables generating forms, filling them from user input, verifying them,
and re-displaying them in case something is wrong.
</p>
EOF
    },
);

sub get_module_list
{
    return \@modules_list,
}

1;


