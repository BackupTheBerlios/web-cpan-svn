#!/usr/bin/perl

use strict;
use warnings;

package MyView;

use base 'Pod::POM::View::HTML';

sub view_pod
{
    my ($self, $node) = @_;

    my $doctype = <<"EOF";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
EOF

    return ($doctype, 
        qq{<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">\n},
        qq{<head>\n},
        qq{  <title>perlsyn - perldoc.perl.org</title>\n},
        qq{  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />\n},
        qq{  <meta http-equiv="Content-Language" content="en-gb" />\n},
        qq{  <link href="css.css" rel="stylesheet" rev="stylesheet" type="text/css" media="screen" />\n},
        qq{  <link rel="search" type="application/opensearchdescription+xml" title="Perldoc" href="opensearch.html">\n},
        qq{</head>\n},
        qq{\n},
        qq{<script language="JavaScript" type="text/javascript" src="label.js"></script>\n},
        qq{\n},
        qq{<script language="JavaScript">
  pageDepth = 0;
  setPath();
</script>

<body onLoad="showToolbars();loadLabels()">
        },
        $node->content->present($self),
        qq{</body>\n},
        qq{</html>\n},
    );
}

sub view_head1
{
    my ($self, $node) = @_;

    my $title = $node->title->present($self);

    return qq{<a name="$title"></a>}, "<h1>", $title,"</h1>\n",
        $node->content->present($self);
}

package main;

use Pod::POM;
use IO::All;

my $parser = Pod::POM->new({});

# parse from a text string
my $pom = $parser->parse_file("perlsyn.pod")
    || die $parser->error();


io->file("got/perlsyn.html")->print(MyView->print($pom));
