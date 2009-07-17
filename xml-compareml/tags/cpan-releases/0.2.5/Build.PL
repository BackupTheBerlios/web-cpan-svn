use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use XML::Grammar::Builder;

my $builder = XML::Grammar::Builder->new(
    module_name         => 'XML::CompareML',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    requires => {
        'Class::Accessor' => 0,
        'XML::LibXSLT' => 0,
        'XML::LibXML' => 0,
        'XML::LibXML::Common' => 0,
        'CGI' => 0,
        'strict' => 0,
        'warnings' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'IO::Scalar' => 0,
        'Test::Differences' => 0,
    },
    create_makefile_pl => 'passthrough',
    meta_merge => {
        resources => {
            homepage => "http://web-cpan.berlios.de/modules/XML-CompareML/",
            license => "http://www.opensource.org/licenses/mit-license.php",
            Repository => "https://svn.berlios.de/svnroot/repos/web-cpan/xml-compareml/",
            Demo => "http://better-scm.berlios.de/comparison/",
        },
        keywords =>
        [
            "Better SCM",
            "categories",
            "compare",
            "CompareML",
            "comparison",
            "criteria",
            "criterion",
            "grammar",
            "language",
            "markup",
            "scm-comparison",
            "systems",
            "tree",
            "version control",
            "xml",
            "XML",
        ]
    },
);

$builder->create_build_script();
