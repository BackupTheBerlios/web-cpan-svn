#!/usr/bin/perl -w

use strict;

use DBI;
use MyConfig;

my $dbh = DBI->connect($config{'dsn'});

sub handle_return
{
    my $rv = shift;
    if (!defined($rv))
    {
        die "Error = " . $dbh->err() . "\nErrstr = " . 
            $dbh->errstr() ."\n";
    }
}

my @fields =
(
    {
        'f' => "id",
        't' => "int",
        'pkey' => 1,
        'auto_inc' => 1,        
    },
    {
        'f' => "PostDate",
        'new' => "post_date",
        't' => 'date',
    },
    {
        'f' => "title",
        'add' => 1,
        't' => "varchar(120)",
    },
    {
        'f' => "workplace",
        't' => "varchar(80)",
    },
    {
        'f' => "description",
        't' => "blob",
    },
    {
        'f' => "requirements",
        't' => "blob",
    },
    {
        'f' => "area",
        't' => "varchar(20)",
    },
    {
        'f' => "phone",
        't' => "varchar(30)",
    },
    {
        'f' => "fax",
        't' => "varchar(30)",
    },
    {
        'f' => "cellphone",
        't' => "varchar(30)",
        'add' => 1,
    },
    {
        'f' => "email",
        't' => "varchar(255)",
    },
    {
        'f' => "contact_person",
        't' => "varchar(100)",
    },
    {
        'f' => "address",
        't' => "blob",
    },
    {
        'f' => "status",
        't' => "int",
    }
);

my @field_strings;
foreach (@fields)
{
    my $f = ($_->{new} || $_->{'f'}) . " " . $_->{'t'};
    if ($_->{'auto_inc'})
    {
        $f .= " AUTO_INCREMENT";
    }
    if ($_->{'pkey'})
    {
        $f .= " PRIMARY KEY";
    }
    push @field_strings, $f;
}

my $new_table_name = "jobs2";
$dbh->do("DROP TABLE $new_table_name\n");
my $create_table_query = "CREATE TABLE $new_table_name (" . join(", ", @field_strings). ")";

print "\$create_table_query =\n<<<\n$create_table_query\n>>>\n";
handle_return($dbh->do($create_table_query));

@field_strings = ();
foreach (@fields)
{
    push @field_strings, ($_->{'add'} ? 'id' : $_->{'f'});
}
my $select_query = "SELECT " . join(", ", @field_strings) . " FROM jobs ORDER BY id";
my $sth = $dbh->prepare($select_query);
my $array_ref;
my @results;
handle_return($sth->execute());
while ($array_ref = $sth->fetchrow_arrayref())
{
    push @results, [ @$array_ref];
}

foreach my $rec (@results)
{
    my @field_names = ();
    my @values = ();
    for my $i (0 .. $#fields)
    {
        my $v = $dbh->quote($rec->[$i]);
        if ($fields[$i]->{auto_inc})
        {
            $v = 0;
        }
        if ($fields[$i]->{add})
        {
            $v = $dbh->quote("");
        }
        push @field_names, ($fields[$i]->{new} || $fields[$i]->{f});
        push @values, $v;
    }
    handle_return($dbh->do("INSERT INTO $new_table_name (" . join(", ", @field_names) . ") VALUES (". join(", ", @values) . ")"));
}
print "Everything is fine!\n";

