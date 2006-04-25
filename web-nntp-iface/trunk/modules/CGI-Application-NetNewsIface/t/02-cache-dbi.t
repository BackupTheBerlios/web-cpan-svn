#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

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
    $dbh->do("CREATE TABLE groups (name varchar(255) PRIMARY KEY, idx INTEGER, last_art INTEGER)");
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
}
1;

