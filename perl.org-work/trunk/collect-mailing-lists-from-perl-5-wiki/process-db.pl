#!/usr/bin/perl

use strict;
use warnings;

use Common;
use YAML::XS qw(LoadFile DumpFile);
use DBIx::Simple;
# use autodie qw(:all);

# Load the database.
system("mysql " . Common::get_mysql_db_name() . "< lists.sql");

my $db = DBIx::Simple->connect(
    "dbi:mysql:database=" . Common::get_mysql_db_name() . ";host=localhost", 
    scalar(getpwuid($<)), 
    $ENV{'MYSQL_PASSWORD'},
);

if (!defined($db))
{
    die DBIx::Simple->error();
}

{
    $db->query("ALTER TABLE mlists ADD COLUMN (defunct BOOLEAN)")
        or die $db->error;

    $db->query("UPDATE mlists SET defunct=TRUE")
        or die $db->error;
}

my $yaml = LoadFile(Common::get_yaml_fn());

sub get_item_blurb
{
    my $item = shift;

    return $item->{'value_prelude'} .  " " . $item->{'value_content'};
}

foreach my $page (keys(%$yaml))
{
    my $page_mls = $yaml->{$page}->{'mailing_lists'};

    MAILING_LIST_LOOP:
    foreach my $ml (@$page_mls)
    {
        my $description = $ml->{'desc'};
        my $items_raw = $ml->{'items'};

        my $items = 
        {
            map 
            { $_->{'canon_key'} => $_ } 
            @$items_raw
        };

        my $name = $items->{'basename'}->{'value_content'};

        if (!defined($name))
        {
            die "The name of Page '$page' and ML '$description' is undefined!";
        }

        my $result = $db->query("SELECT * FROM mlists WHERE name = ?", $name)
            or die $db->error;

        my $record = $result->hash();

        if (!defined($record))
        {
            # print "New mailing list '$name'\n";
            # New mailing list.
            $db->query("INSERT INTO mlists (name) VALUES (?)", $name)   
                or die $db->error;
        }

        # print "Found mailing list '$name'\n";
        
        $db->query("UPDATE mlists SET defunct = FALSE WHERE name = ?", $name)
            or die $db->error;

        my %new_vals;

        my $subscribe = 
            $items->{'subscribe'} || $items->{'all_in_one_ml_settings'}
            ;

        if (!defined($subscribe))
        {
            warn "The subscribe of Page '$page' and ML '$description' is undefined!";
        }

        $new_vals{'sub'} = get_item_blurb($subscribe);

        my $unsub = 
            $items->{'unsubscribe'} || $items->{'all_in_one_ml_settings'}
            ;

        if (!defined($unsub))
        {
            warn "The unsubscribe of Page '$page' and ML '$description' is undefined!";
        }

        $new_vals{'unsub'} = get_item_blurb($unsub);

        my $help = $items->{'help'};

        if ($help)
        {
            $new_vals{'help'} = get_item_blurb($help);
        }

        my $hp = $items->{'homepage'};

        if ($hp)
        {
            $new_vals{'url'} = get_item_blurb($hp);
        }

        my @fields = keys(%new_vals);
        my $query_string = "UPDATE mlists SET "
            . join(", ", map { "$_ = ?" } @fields)
            . " WHERE name = ?"
            ;
        $db->query(
            $query_string, 
            @new_vals{@fields},
            $name
        );
    }
}
