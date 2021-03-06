#!/usr/bin/perl -w

use strict;

use Test::More tests => 15;

use HTML::Widgets::NavMenu;
use HTML::Widgets::NavMenu::HeaderRole;

use HTML::Widgets::NavMenu::Test::Data;
use HTML::Widgets::NavMenu::Test::Util;

my $test_data = get_test_data();

sub validate_nav_menu
{
    my $rendered = shift;
    my $expected_string = shift;
    
    my @result = (@{$rendered->{html}});

    my @expected = (split(/\n/, $expected_string));

    return (compare_string_arrays(\@expected, \@result) == 0);
}

{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/hello/",
        @{$test_data->{'minimal'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
<li>
<a href="../me/" title="About Myself">About Me</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu for minimal - 1"); 
}


{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/",
        @{$test_data->{'two_sites'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
<li>
<b>About Me</b>
<br />
<ul class="navbarnested">
<li>
<a href="../round/hello/personal.html" title="Biography of Myself">Bio</a>
</li>
<li>
<a href="../round/toto/" title="A Useful Conspiracy">Gloria</a>
</li>
</ul>
</li>
<li>
<a href="http://www.other-url.co.il/~shlomif/hoola/" title="Drumming is good for your health">Tam Tam Drums</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu for minimal - 2"); 
}

# This test tests that an expand_re directive should not cause
# the current coords to be assigned to it, thus marking a site
# incorrectly.
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/",
        @{$test_data->{'expand_re'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
<li>
<b>About Me</b>
</li>
<li>
<a href="../foo/" title="Fooish">Foo</a>
<br />
<ul class="navbarnested">
<li>
<a href="../foo/expanded/" title="Expanded">Expanded</a>
</li>
</ul>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu for expand_re"); 
}

# This test tests that an empty expand_re directive works after a successful
# pattern match.
{
    my $string = "aslkdjofisvniowgvnoaifnaoiwfb";
    $string =~ s{ofisvniowgvnoaifnaoiwfb$}{};
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/",
        @{$test_data->{'expand_re'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
<li>
<b>About Me</b>
</li>
<li>
<a href="../foo/" title="Fooish">Foo</a>
<br />
<ul class="navbarnested">
<li>
<a href="../foo/expanded/" title="Expanded">Expanded</a>
</li>
</ul>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string),
        "Nav Menu for empty expand_re after successful pattern match");
}

# This test tests the show_always directive which causes the entire
# sub-tree to expand at any URL.
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/",
        @{$test_data->{'show_always'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
<li>
<b>About Me</b>
</li>
<li>
<a href="../show-always/">Show Always</a>
<br />
<ul class="navbarnested">
<li>
<a href="../show-always/gandalf/">Gandalf</a>
</li>
<li>
<a href="../robin/">Robin</a>
<br />
<ul class="navbarnested">
<li>
<a href="../robin/hood/">Hood</a>
</li>
</ul>
</li>
<li>
<a href="../esther/">Queen Esther</a>
<br />
<ul class="navbarnested">
<li>
<a href="../haman/">Haman</a>
</li>
</ul>
</li>
</ul>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string),
        "Nav Menu with show_always");
}

# This test tests a menu auto-expands if the current URL is an item
# inside it.
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/bio.html",
        @{$test_data->{'items_in_sub'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="./../">Home</a>
</li>
<li>
<a href="./" title="About Myself">About Me</a>
<br />
<ul class="navbarnested">
<li>
<b>Bio</b>
</li>
<li>
<a href="./gloria/" title="A Useful Conspiracy">Gloria</a>
</li>
</ul>
</li>
<li>
<a href="./../hoola/" title="Drumming is good for your health">Tam Tam Drums</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string),
        "Nav Menu with a selected sub-item");
}

{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/",
        @{$test_data->{'separator'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
<li>
<b>About Me</b>
<br />
<ul class="navbarnested">
<li>
<a href="group-hug/">Group Hug</a>
</li>
<li>
<a href="cool-io/">Cool I/O</a>
</li>
</ul>
<ul class="navbarnested">
<li>
<a href="../resume.html">Resume</a>
</li>
</ul>
</li>
</ul>
<ul class="navbarmain">
<li>
<a href="../halifax/">Halifax</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu with Separators"); 
}

{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/",
        @{$test_data->{'hidden_item'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
<li>
<b>About Me</b>
<br />
<ul class="navbarnested">
<li>
<a href="visible/">Visible</a>
</li>
<li>
<a href="visible-too/">Visible Too</a>
</li>
</ul>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu with Hidden Item"); 
}


{
    my $nav_menu = HTML::Widgets::NavMenu::HeaderRole->new(
        'path_info' => "/good/",
        @{$test_data->{'header_role'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
</ul>
<h2>
<a href="../me/" title="About Myself">About Me</a>
</h2>
<ul class="navbarmain">
<li>
<a href="../me/sub-me1/">Sub Me</a>
</li>
<li>
<a href="../me/sub-me-two/">Sub Me 2</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu with a role of \"header\""); 
}

{
    my $nav_menu = HTML::Widgets::NavMenu::HeaderRole->new(
        'path_info' => "/me/",
        @{$test_data->{'header_role'}},
        'ul_classes' => [ "navbarmain", ("navbarnested") x 5 ],
    );

    my $rendered =
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="navbarmain">
<li>
<a href="../">Home</a>
</li>
</ul>
<h2>
<b>About Me</b>
</h2>
<ul class="navbarmain">
<li>
<a href="sub-me1/">Sub Me</a>
</li>
<li>
<a href="sub-me-two/">Sub Me 2</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu with a selected item with a role of \"header\" "); 
}

# Test the selective expand. (test #1)
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/me/bio/test.html",
        @{$test_data->{'selective_expand'}},
        'ul_classes' => [ "one", "two", "three" ],
    );

    my $rendered =
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="one">
<li>
<a href="./../../">Home</a>
</li>
<li>
<a href="./../" title="About Myself">About Me</a>
<br />
<ul class="two">
<li>
<a href="./../group-hug/">Group Hug</a>
</li>
<li>
<a href="./../cool-io/">Cool I/O</a>
</li>
<li>
<a href="./../../resume.html">Resume</a>
</li>
</ul>
</li>
<li>
<a href="./../../halifax/">Halifax</a>
</li>
<li>
<a href="./../../open-source/" title="Open Source Software I Wrote">Software</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Selective Expand Nav-Menu #1"); 
}

# Test the selective expand. (test #2)
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/open-source/bits.html",
        @{$test_data->{'selective_expand'}},
        'ul_classes' => [ "one", "two", "three" ],
    );

    my $rendered =
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul class="one">
<li>
<a href="./../">Home</a>
</li>
<li>
<a href="./../me/" title="About Myself">About Me</a>
</li>
<li>
<a href="./../halifax/">Halifax</a>
</li>
<li>
<a href="./" title="Open Source Software I Wrote">Software</a>
<br />
<ul class="two">
<li>
<a href="./fooware/">Fooware</a>
</li>
<li>
<a href="./condor-man/" title="Kwalitee">Condor-Man</a>
</li>
</ul>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Selective Expand Nav-Menu #2"); 
}

# This is a test for the url_type directive.
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/darling/",
        @{$test_data->{'url_type_menu'}},
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul>
<li>
<a href="../">Home</a>
</li>
<li>
<a href="/me/" title="About Myself">About Me</a>
</li>
<li>
<a href="http://www.hello.com/yowza/">Yowza</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu for url_type - 1"); 
}

# This is a test for the rec_url_type directive.
# Also test the behaviour of the url_type when a trailing_url_base
# is specified
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/darling/",
        @{$test_data->{'rec_url_type_menu'}},
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul>
<li>
<a href="http://www.hello.com/~shlomif/">Home</a>
</li>
<li>
<a href="/~shlomif/me/" title="About Myself">About Me</a>
</li>
<li>
<a href="http://www.hello.com/~shlomif/tedious/to/write/">Hoola</a>
</li>
<li>
<a href="../yowza/">Yowza</a>
<br />
<ul>
<li>
<a href="http://www.hello.com/~shlomif/yowza/howza/">This should be full_abs again</a>
</li>
</ul>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu for rec_url_type - 1"); 
}

# Test the url_is_abs directive
{
    my $nav_menu = HTML::Widgets::NavMenu->new(
        'path_info' => "/hello/",
        @{$test_data->{'url_is_abs_menu'}},
    );

    my $rendered = 
        $nav_menu->render();

    my $expected_string = <<"EOF";
<ul>
<li>
<a href="../">Home</a>
</li>
<li>
<a href="http://www.google.com/" title="Google it!">Link to Google</a>
</li>
</ul>
EOF

    # TEST
    ok (validate_nav_menu($rendered, $expected_string), 
        "Nav Menu for url_is_asb - 1"); 
}

