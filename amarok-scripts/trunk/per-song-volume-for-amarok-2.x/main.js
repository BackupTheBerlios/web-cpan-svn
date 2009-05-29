function chomp(raw_text)
{
  return raw_text.replace(/(\n|\r)+$/, '');
}

Importer.loadQtBinding("qt.core");

QByteArray.prototype.toString = function()
{
   ts = new QTextStream( this, QIODevice.ReadOnly );
   return ts.readAll();
}

var data_dir = QDir.home();

var components = [".kde4", "share", "apps" ,"amarok", "scripts-data"];
var c_idx;
for (c_idx in components)
{
    data_dir.cd(components[c_idx]);
}

var db_file = data_dir.path() + "/per-song-volume.sqlite";

var default_volume = 40;


{   
    var volume_settings = new QFile(data_dir.path() + "/per-song-volume.default-volume.txt");
    if (volume_settings.exists())
    {
        volume_settings.open(QIODevice.ReadOnly);

        var str = volume_settings.readLine().toString();
        volume_settings.close();
        var new_vol = parseInt(str.replace(/(\n|\r| |\t)/, ''));
        if ((new_vol >= 0) && (new_vol <= 100))
        {
            default_volume = new_vol;
        }
    }
}

// TODO : Remove later.
Amarok.alert("def-vol = " + default_volume);

// my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "");
// 
// # Don't check for success - if it already exists, we'll get an error
// # but we'll re-use the existing table
// $dbh->do("CREATE TABLE songs_volumes (path TEXT PRIMARY KEY, volume INTEGER)");
// 
// my $select_by_path_sth = $dbh->prepare("SELECT volume FROM songs_volumes WHERE path = ?");
// my $insert_sth = $dbh->prepare("INSERT OR REPLACE INTO songs_volumes (path, volume) VALUES (?, ?)");
// my $make_default_sth = $dbh->prepare("DELETE FROM songs_volumes WHERE path = ?");
// 
// $SIG{TERM} = sub {
//     foreach ($insert_sth, $select_by_path_sth, $make_default_sth)
//     {
//         $_->destroy;
//         $_ = undef;
//     }
//     $dbh->disconnect();
// };
// 
// my $bus = Net::DBus->find;
// 
// # Get a handle to the HAL service
// my $amarok_dbus_service = $bus->get_service("org.kde.amarok");
// 
// my $tracklist = $amarok_dbus_service->get_object("/TrackList", "org.freedesktop.MediaPlayer");
// 
// my $player = $amarok_dbus_service->get_object("/Player", "org.freedesktop.MediaPlayer");
// 
// sub _get_current_path
// {
//     return
//         $tracklist->GetMetadata($tracklist->GetCurrentTrack())
//             ->{'location'}
//             ;
// }
// 
// sub _get_current_volume
// {
//     return
//         $player->VolumeGet()
//             ;
// }
// 
// sub _set_current_volume
// {
//     my $vol = shift;
// 
//     return
//         $player->VolumeSet($vol)
//             ;
// }
// 
// my $old_path = _get_current_path();
// my $old_volume = _get_current_volume();
// while(my $input = <STDIN>)
// {
//     chomp($input);
//     if ($input eq "trackChange")
//     {
//         my $new_path = _get_current_path();
//         $select_by_path_sth->execute($new_path);
//         my $results = $select_by_path_sth->fetchrow_arrayref();
//         my $new_volume = (defined($results) ? $results->[0] : $default_volume);
//         if ($new_volume != $old_volume)
//         {
//             _set_current_volume($new_volume);
//             $old_volume = $new_volume;
//         }
//         $old_path = $new_path;
//     }
//     elsif ($input =~ m{^volumeChange: (\d+)})
//     {
//         my $new_volume = $1;
//         if ($new_volume == $default_volume)
//         {
//             $make_default_sth->execute($old_path);
//         }
//         else
//         {
//             $insert_sth->execute($old_path, $new_volume);
//         }
//         $old_volume = $new_volume;
//     }
// }
// 
// 
