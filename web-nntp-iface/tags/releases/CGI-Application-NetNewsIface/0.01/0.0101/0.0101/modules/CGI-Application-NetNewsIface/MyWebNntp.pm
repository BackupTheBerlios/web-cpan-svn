package MyWebNntp;

use strict;
use warnings;

use lib "./blib/lib/";
use File::Spec;

use CGI::Application::NetNewsIface;

sub get_dsn
{
    return "dbi:SQLite:dbname=./data/mynntp.sqlite"
}
sub get_app
{
    return CGI::Application::NetNewsIface->new(
        PARAMS => {
            'nntp_server' => "nntp.perl.org",
            'articles_per_page' => 10,
            'dsn' => get_dsn(),
        },
    );        
}

sub create_db
{
    get_app()->init_cache__sqlite();
}

1;

