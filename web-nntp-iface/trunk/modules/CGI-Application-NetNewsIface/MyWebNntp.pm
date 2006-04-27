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
    require DBI;
    my $dbh = DBI->connect(get_dsn(), "", "");
    $dbh->do("CREATE TABLE groups (name varchar(255), idx INTEGER PRIMARY KEY AUTOINCREMENT, last_art INTEGER)");
    $dbh->do("CREATE TABLE articles (group_idx INTEGER, article_idx INTEGER, msg_id varchar(255), parent INTEGER, subject varchar(255), frm varchar(255), date varchar(255))");
}

1;

