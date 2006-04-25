#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "t", "lib");

use CGI::Application::NetNewsIface::Test::MockNNTP;
use CGI::Application::NetNewsIface::Test::Data1;

use DBI;

use CGI::Application::NetNewsIface::Cache::DBI;

my $db_file = File::Spec->catfile("t", "data", "testdb.sqlite");
my $dsn = "dbi:SQLite:dbname=$db_file";

sub create_db
{
    unlink($db_file);
    my $dbh = DBI->connect($dsn, "", "");
    $dbh->do("CREATE TABLE groups (name varchar(255), idx INTEGER PRIMARY KEY AUTOINCREMENT, last_art INTEGER)");
    $dbh->do("CREATE TABLE articles (group_idx INTEGER, article_idx INTEGER, msg_id varchar(255), parent INTEGER, subject varchar(255), frm varchar(255), date varchar(255))");
}

{
    local $Net::NNTP::groups = Data1::get_groups();
    {
        my $nntp = Net::NNTP->new("nntp.shlomifish.org");
        create_db();
        my $cache = CGI::Application::NetNewsIface::Cache::DBI->new(
            {
                'nntp' => $nntp,
                'dsn' => $dsn,
            },
        );
        # TEST
        ok ($cache, "Cache was initialized");
    }
    {
        my $nntp = Net::NNTP->new("nntp.shlomifish.org");
        create_db();
        my $cache = CGI::Application::NetNewsIface::Cache::DBI->new(
            {
                'nntp' => $nntp,
                'dsn' => $dsn,
            },
        );
        # TEST
        is ($cache->select("perl.qa"), 0, "select() worked");
    }
    {
        my $nntp = Net::NNTP->new("nntp.shlomifish.org");
        create_db();
        my $cache = CGI::Application::NetNewsIface::Cache::DBI->new(
            {
                'nntp' => $nntp,
                'dsn' => $dsn,
            },
        );
        # TEST
        is ($cache->select("perl.qa"), 0, "select() worked");
        # TEST
        is ($cache->get_index_of_id(
            "44439745.6060604\@modperlcookbook.org"
            ),
            11,
            "get_index_of_id() - 1"
        );
        # TEST
        is ($cache->get_index_of_id(
            "20060418012117.GA6582\@yi.org",
            ),
            16,
            "get_index_of_id() - 2"
        );
        
    }
}
1;

