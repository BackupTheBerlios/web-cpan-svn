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

<h2>Documents</h2>

<ul>
<li>
<a href="http://www.perl.com/pub/a/2005/07/07/navwidgets.html">"Building 
Navigation Menus" at Perl.com</a> - an article that covers common web-site
navigation and site flow patterns in general and then demonstrates how to
implement them using HTML-Widgets-NavMenu.
</li>
</ul>
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
        'perl_name' => "SVN-Pusher",
        'text' => "SVN::Pusher", 
        'title' => "Propagate Changesets between Subversion Repositories",
        'svn_dir' => "SVN-Pusher",
        'desc' => <<"EOF",
<p>
This module allows one to propagate changesets from one 
<a href="http://subversion.tigris.org/">Subversion repository</a> to the
other.
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
<h2>Demos</h2>
<ul>
<li>
<a href="http://freehackers.org/~shlomif/svn-raweb-light/berlios.cgi/">The 
web-cpan repository at berlios</a> - an SVN::RaWeb::Light web-interface to the
repository holding the sources of the modules here.
</li>
<li>
<a href="http://freehackers.org/~shlomif/svn-raweb-light/subversion.cgi/">Browse
Subversion's Repository</a> - browse the svn.collab.net repository that keeps
track of the code of Subversion itself.
</li>
</ul>
EOF
    },
    {
        'perl_name' => "Test-Run",
        'text' => "Test::Run", 
        'title' => "A new and improved test harness",
        'svn_dir' => "Test-Harness-NG",
        'desc' => <<"EOF",
<p>
Test::Run is a new and improved test harness. It is based on 
<a href="http://search.cpan.org/dist/Test-Harness/">Test-Harness</a>,
but incoroporates many internals improvement, a separation of the code
to a backend and frontend, etc.
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
    {
        'perl_name' => "WWW-OpenSVN",
        'text' => "WWW::OpenSVN",
        'title' => "An automated interface to http://opensvn.csie.org/",
        'svn_dir' => "www-opensvn",
        'desc' => <<"EOF"
<p>
WWW::OpenSVN is an automated interface for the 
<a href="http://opensvn.csie.org/">OpenSVN online Subversion repositories
service</a>. At the moment it allows one to backup the dumps of one's 
repositories.
</p>
EOF
    },
    {
        'perl_name' => "XML-CompareML",
        'text' => "XML::CompareML",
        'title' => "An XML Grammar for Managing Comparisons",
        'svn_dir' => "xml-compareml",
        'desc' => <<"EOF"
<p>
XML::CompareML is a module for managing multi-system and multi-item 
comparisons. The primary use of this module by its author was to manage
<a href="http://better-scm.berlios.de/comparison/">the Better SCM 
comparison of version control systems</a>.
</p>
<p>
The Perl versions can generate either HTML or 
<a href="http://www.docbook.org/">DocBook/XML</a>. (the latter can be
converted into many other formats). Also available is an XSLT stylesheet
for transforming the XML markup into HTML.
</p>
EOF
    },
    
);

sub get_module_list
{
    return \@modules_list,
}

1;


