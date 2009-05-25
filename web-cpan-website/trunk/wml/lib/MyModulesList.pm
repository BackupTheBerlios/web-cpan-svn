package MyModulesList;

use strict;
use warnings;

my @modules_list =
(
    {
        'perl_name' => "App-XML-DocBook-Builder",
        'subject' => "Docmake",
        'text' => "Docmake",
        'title' => "Translate DocBook/XML to Other Formats using XSLT",
        'svn_dir' => "App-XML-DocBook-Builder",
        'desc' => <<"EOF",
<p>
Docmake is a command line tool to translate 
<a href="http://en.wikipedia.org/wiki/DocBook">DocBook/XML</a> code into
various resultnats formats such as XHTML, RTF, PDF and XSL-FO, using the
more low-level tools. It aims to be a replacement for 
<a href="http://cyberelk.net/tim/software/xmlto/">xmlto</a>.
</p>

<h2>Project Resources</h2>
<ul>
<li>
<a href="http://freshmeat.net/projects/docmake/">Freshmeat Record</a>
</li>
</ul>
EOF
    },

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
<a href="http://perl-begin.org/">The Perl Beginners' Site</a>
(<a href="http://opensvn.csie.org/perlbegin/perl-begin/trunk/">Code</a>)
</li>
<li>
<a href="http://www.aspetersen.de/">Alexia &amp; Stephan Petersen</a> 
</li>
</ul>
<h2>Project Resources</h2>
<ul>
<li>
<a href="http://freshmeat.net/projects/html-widgets-navmenu/">Freshmeat Record</a>
</li>
</ul>
EOF
    },
    {
        'perl_name' => "Statistics-Descriptive",
        'subject' => "Statistics-Descriptive",
        'text' => "Statistics-Descriptive",
        'title' => "Module for Performing Statistical Analysis on Numeric Data",
        'svn_dir' => "Statistics-Descriptive",
        'desc' => <<"EOF",
<p>
Statistics-Descriptive is a module to perform Statistical Analysis on
numeric data. It can retrieve such things as the mean (or average), the median,
the standard deviation, a histogram / frequency analysis, etc.
</p>

<p>
Statistics-Descriptive has seen work from several people, the latest of
whom was <a href="http://search.cpan.org/~colink/">Colin Kuskie</a>, and
was recently adopted by us.
</p>

<h2>Project Resources</h2>
<ul>
<li>
Freshmeat Record - FILL IN.
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
<p>
URLs are broken due to lack of use.
</p>
EOF
    },
    {
        'perl_name' => "Test-Run",
        'text' => "Test::Run", 
        'title' => "A new and improved test harness",
        'svn_dir' => "Test-Harness-NG",
        'desc' => <<"EOF",
<p>
Test::Run is a new and improved test harness for processing 
<a href="http://testanything.org/">TAP (Test Anything Protocol)</a>-based
test files. It is based on 
<a href="http://search.cpan.org/dist/Test-Harness/">Test-Harness</a>,
but incorporates many internals improvement, a separation of the code
to a backend and frontend, etc.
</p>

<p>
To get started with Test::Run <a href="http://search.cpan.org/dist/Task-Test-Run-AllPlugins/lib/Task/Test/Run/AllPlugins.pm">see the instructions on its 
CPAN "AllPlugins" Task</a>.
</p>

<h2>Project Resources</h2>

<ul>

<li>
<a href="http://freshmeat.net/projects/test-run/">Freshmeat Record</a>
</li>

</ul>

<h2>Links</h2>

<ul>

<li>
<a href="http://testanything.org/">TAP - The Test Anything Protocol</a>
</li>

<li>
<a href="http://perl-qa.yi.org/">The Perl Quality Assurance and Testing
Wiki</a>
</li>

<li>
<a href="http://www.shlomifish.org/lecture/Perl/Lightning/Test-Run/">Lightning
Talk about Test::Run</a>.
</li>

<li>
<a href="http://www.shlomifish.org/lecture/Perl/Lightning/Test-Run/updates/2006-05-09/">Test::Run update for 9-May-2006</a>
</li>
</ul>

<h3>Blog Entries about Test::Run</h3>

<h4>By Shlomi Fish</h4>

<ul>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/27467">Test::Shlomif::Harness - 
Giving Test::Harness a Face Life</a> (6 November, 2005)
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/27887">"Test::Run (formerly Test::Shlomif::Harness) Developments (7 December, 2005)</a> 
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/30953">"CPAN Modules Hacktivity" (10 September, 2006)</a>
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/31076">Test::Run work (22 September, 2006</a>
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/31651">First non-Developer 
Release of Test::Run</a>
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/32493">Test::Run Update from 
24 February, 2007</a>
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/32725">Oh no, 
it's Another Test::Run Update!</a>
</li>

</ul>

<h4>By Ovid</h4>

<ul>
<li>
<a href="http://use.perl.org/~Ovid/journal/31009">TAPx::Parser tools</a> (15 September, 2006)
</li>
</ul>

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
    {
        'perl_name' => "XML-Grammar-Fortune",
        'text' => "XML-Grammar-Fortune",
        'title' => "An XML Grammar for Defining Collections of Quotes",
        'svn_dir' => "XML-Grammar-Fortune",
        'desc' => <<"EOF",
<p>
XML-Grammar-Fortune allows one to collect quotes (or Unix-like fortune
cookies) using an XML grammar, with a lot of rich meta-data, and to produce 
XHTML and plaintext from them.
</p>

<h2>Project Resources</h2>

<ul>
<li>
<a href="http://freshmeat.net/projects/fortune-xml/">Freshmeat Record</a>
</li>
</ul>

<h3>Examples</h3>

<ul>
<li>
<a href="http://www.shlomifish.org/humour/fortunes/">"Fortune Cookie
Files" on Shlomi Fish's Homepage</a>
</li>
</ul>

<h3>Blog Entries about XML-Grammar-Fortune</h3>

<h4>By Shlomi Fish</h4>

<ul>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/36668">XML-Grammar-Fortune</a>
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/36915">"Reflections
on Syndicating my Fortune Cookies as Atom"</a>
</li>

<li>
<a href="http://use.perl.org/~Shlomi+Fish/journal/36997">Overcoming
Misbheaviours in Code I Did not Write</a>
</li>

</ul>

EOF
    },
    {
        'perl_name' => "XML-Grammar-Screenplay",
        'text' => "XML-Grammar-Screenplay",
        'title' => "An XML Grammar for Rendering Screenplays",
        'svn_dir' => "XML-Grammar-Screenplay",
        'desc' => <<"EOF",
<p>
XML-Grammar-Screenplay is a processor for well-formed plain text representing
Screenplays. This in turn is rendered into a specialized XML format, and
that in turn can be converted to HTML or DocBook/XML.
</p>

<h2>Project Resources</h2>

<ul>
<li>
<a href="http://freshmeat.net/projects/screenplay-xml/">Freshmeat.net
Record</a>
</li>
</ul>

<h3>Examples</h3>

<ul>
<li>
<a href="http://www.shlomifish.org/humour/TOWTF/">The One with the 
Fountainhead</a> - original text, but fan fiction of the T.V. show 
"Friends".
</li>
<li>
<a href="http://www.shlomifish.org/humour/humanity/">Humanity - The 
Movie</a> - all original text and concept. Under the CC-by-sa license.
</li>
<li>
<a href="http://www.shlomifish.org/humour/Star-Trek/We-the-Living-Dead/">Star
Trek - "We The Living Dead"</a> - all original text, but fan fiction of
Star Trek.
</li>
<li>
Some shorter and sillier examples can be found <a href="http://svn.berlios.de/svnroot/repos/web-cpan/XML-Grammar-Screenplay/trunk/perl/modules/XML-Grammar-Screenplay/t/data/">in the test data directory</a>. 
</li>
</ul>
EOF
    }
    
);

sub get_module_list
{
    return \@modules_list,
}

1;


