#!/usr/bin/perl

use DBI;
use File::Spec;

my $data_dir = 
    File::Spec->catdir(
        $ENV{HOME}, ".kde", "share", "apps" ,"amarok", "scripts-data",
    );

my $db_file = File::Spec->catfile($data_dir, "per-song-volume.sqlite");

my $default_volume = 40;
SET_DEFAULT_VOLUME: 
{
    open my $volume_settings, "<", File::Spec->catfile($data_dir, "per-song-volume.default-volume.txt") or last SET_DEFAULT_VOLUME;
    $default_volume = int(<$volume_settings>);
    close ($volume_settings);
}

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "");

# Don't check for success - if it already exists, we'll get an error
# but we'll re-use the existing table
$dbh->do("CREATE TABLE songs_volumes (path TEXT PRIMARY KEY, volume INTEGER)");

my $select_by_path_sth = $dbh->prepare("SELECT volume FROM songs_volumes WHERE path = ?");
my $insert_sth = $dbh->prepare("INSERT OR REPLACE INTO songs_volumes (path, volume) VALUES (?, ?)");
my $make_default_sth = $dbh->prepare("DELETE FROM songs_volumes WHERE path = ?");

$SIG{TERM} = sub {
    foreach ($insert_sth, $select_by_path_sth, $make_default_sth)
    {
        $_->destroy;
        $_ = undef;
    }
    $dbh->disconnect();
};

my @dcop_command = (qw(dcop amarok player));

sub _get_current_path
{
    my $path = `@dcop_command path`;
    chomp($path);

    return $path;
}

sub _get_current_volume
{
    my $ret = `@dcop_command getVolume`;
    chomp($ret);

    return $ret;
}

my $old_path = _get_current_path();
my $old_volume = _get_current_volume();
while(my $input = <STDIN>)
{
    chomp($input);
    if ($input eq "trackChange")
    {
        my $new_path = _get_current_path();
        $select_by_path_sth->execute($new_path);
        my $results = $select_by_path_sth->fetchrow_arrayref();
        my $new_volume = (defined($results) ? $results->[0] : $default_volume);
        if ($new_volume != $old_volume)
        {
            system(@dcop_command, "setVolume", $new_volume);
            $old_volume = $new_volume;
        }
        $old_path = $new_path;
    }
    elsif ($input =~ m{^volumeChange: (\d+)})
    {
        my $new_volume = $1;
        if ($new_volume == $default_volume)
        {
            $make_default_sth->execute($old_path);
        }
        else
        {
            $insert_sth->execute($old_path, $new_volume);
        }
        $old_volume = $new_volume;
    }
}


