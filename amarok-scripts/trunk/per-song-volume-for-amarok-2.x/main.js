function chomp(raw_text)
{
  return raw_text.replace(/(\n|\r)+$/, '');
}

Importer.loadQtBinding("qt.core");
Importer.loadQtBinding("qt.sql");

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

// Amarok.alert("def-vol = " + default_volume);

var dbh = QSqlDatabase.addDatabase("QSQLITE", "amarok-per-song-volume");
dbh.setDatabaseName(db_file);
dbh.open();

// Don't check for success - if it already exists, we'll get an error
// but we'll re-use the existing table
dbh.exec("CREATE TABLE songs_volumes (url TEXT PRIMARY KEY, volume INTEGER)");

var select_by_path_sth = new QSqlQuery(dbh);

select_by_path_sth.prepare("SELECT volume FROM songs_volumes WHERE url = ?");

var insert_sth = new QSqlQuery(dbh);

insert_sth.prepare("INSERT OR REPLACE INTO songs_volumes (url, volume) VALUES (?, ?)");

var make_default_sth = new QSqlQuery(dbh);

make_default_sth.prepare("DELETE FROM songs_volumes WHERE url = ?");

// my $tracklist = $amarok_dbus_service->get_object("/TrackList", "org.freedesktop.MediaPlayer");


// my $player = $amarok_dbus_service->get_object("/Player", "org.freedesktop.MediaPlayer");

function _get_current_path() {
    var track = Amarok.Engine.currentTrack();
    
    if (track)
    {
        return track.url;
    }
    else
    {
        return null;
    }
}

function _get_current_volume() {
    return Amarok.Engine.volume;
}

function _set_current_volume(vol) {
    // Amarok.alert("set_cur_vol to " + vol);
    Amarok.Engine.volume = vol;
}
 
var old_path = _get_current_path();
var old_volume = _get_current_volume();

Amarok.Engine.trackChanged.connect(
        function () {
            var new_path = _get_current_path();

            select_by_path_sth.addBindValue(new_path);
            select_by_path_sth.exec();

            var new_volume;

            if (select_by_path_sth.next())
            {
                new_volume = parseInt(select_by_path_sth.value(0));
            }
            else
            {
                new_volume = default_volume;
            }

            // Amarok.alert("new_vol = " + new_volume + "new_path = " + new_path);
            if (new_volume != old_volume)
            {
                _set_current_volume(new_volume);
                old_volume = new_volume;
            }
            old_path = new_path;
        }
        );

Amarok.Engine.volumeChanged.connect(
        function (new_volume) {
            if (new_volume == default_volume)
            {
                make_default_sth.addBindValue(old_path);
                make_default_sth.exec();
            }
            else
            {
                insert_sth.addBindValue(old_path);
                insert_sth.addBindValue(new_volume);
                insert_sth.exec();
                old_volume = new_volume;
            }
        }
        );

