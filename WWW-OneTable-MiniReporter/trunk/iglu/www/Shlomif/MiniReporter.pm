package Shlomif::MiniReporter;

use strict;
use warnings;
use DBI;
use POSIX qw();
use Template;
use File::Spec ();
use List::Util;

# Inherit from CGI::Application.
use base 'CGI::Application';
use base 'Class::Accessor';

use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::Session;

use XML::RSS;

use WWW::Form;

use WWW::FieldValidator;

use Shlomif::MiniReporter::FetchQuery;

my %modes =
(
    'main' => 
    {
        'url' => "/",
        'func' => "main_page",
    },
    'add' =>
    {
        'url' => "/add/",
        'func' => "add_form",
    },
    'remove' =>
    {
        'url' => "/remove/",
        'func' => "remove",
    },
    'search' =>
    {
        'url' => "/search/",
        'func' => "search_results",
    },
    'css' =>
    {
        'url' => "/style.css",
        'func' => "css_stylesheet",
    },
    'admin' =>
    {
        'url' => "/admin/",
        'func' => "_admin_screen",
    },
    'rss' =>
    {
        'url' => "/index.rss",
        'func' => "rss_feed",
    },
    'update_rss' => 
    {
        'url' => "/update-rss/",
        'func' => "update_rss",
    },
    'show_record' =>
    {
        'url' => "/show-record/",
        'func' => "show_record",
    },
);

my %urls_to_modes = (map { $modes{$_}->{'url'} => $_ } keys(%modes));

__PACKAGE__->mk_accessors(qw(
    config
    _dbh
    _group_by_field
    record_tt
    _sql_to_field
    _captcha_value
));

sub _set_captcha_value
{
    my $self = shift;
    my $v = shift;
    $self->_captcha_value($v);
}

sub setup
{
    my $self = shift;

    $self->initialize($self->param('config'));

    $self->start_mode("main");
    $self->mode_param(\&determine_mode);

    $self->run_modes(
        (map { $_ => $modes{$_}->{'func'}, } keys(%modes)),
        # Remmed out:
        # I think of deprecating it because there's not much difference
        # between it and add.
        # "add_form" => "add_form",
        'redirect_to_main' => "redirect_to_main",
        'correct_path' => "correct_path",
    );
}

sub cgiapp_init
{
    my $self = shift;

    my $dir = File::Spec->rel2abs("./data/session");

    $self->session_config(
        CGI_SESSION_OPTIONS =>
        [ 
            "driver:File",
            $self->query, 
            {
                Directory => $dir,
            } 
        ],
        COOKIE_PARAMS => 
        {
            -path  => ($self->query->script_name()."/"),
            -expires => '+7d',
        },
        SEND_COOKIE         => 1,
    );
}

sub cgiapp_prerun
{
    my $self = shift;

    $self->tt_params(
        'path_info' => $self->get_path(),
        'path_to_root' => $self->get_path_to_root(),
        'with_rss' => $self->get_rss_table_name(),
        'show_all_records_url' => "search/?all=1",
        'encoding' => $self->config()->{encoding},
    );

    # TODO : There may be a more efficient/faster way to do it, but I'm 
    # anxious to get it to work. -- Shlomi Fish
    $self->tt_include_path(
        [ './templates-custom', './templates',  ],
    );

    # This is so the CGI header won't print a character set.
    $self->query()->charset('');
}

sub cgiapp_postrun
{
    my $self = shift;

    if ($self->_dbh())
    {
        $self->_dbh()->disconnect();

        $self->_dbh(undef);
    }

    if (defined($self->_captcha_value()))
    {
        $self->session()->param("captcha1", $self->_captcha_value());
    }
}

sub _get_dbh
{
    my $self = shift;

    if (! $self->_dbh())
    {
        $self->_dbh($self->_dbi_connect());
    }

    return $self->_dbh();
}

sub redirect_to_main
{
    my $self = shift;

    return "<html><body><h1>URL Not Found</h1></body></html>";
}

sub correct_path
{
    my $self = shift;

    my $path = $self->get_path();

    $path =~ m#([^/]+)/*$#;

    my $last_component = $1;

    # This is in case we were passed the script name without a trailing /
    # in which case the last component would be undefined. So consult
    # the request uri.
    if (!defined($last_component))
    {
        # Extract the Request URI
        my $request_uri = $ENV{REQUEST_URI} || "";
        $request_uri =~ m#([^/]+)/*$#;
        $last_component = $1;
        if (!defined($last_component))
        {
            $last_component = "";
        }
    }

    $self->header_type('redirect');
    $self->header_props(-url => "./$last_component/");
}

sub get_path
{
    my $self = shift;

    return $self->query()->path_info();
}

sub determine_mode
{
    my $self = shift;
    
    my $path = $self->get_path();

    if ($path =~ /\/\/$/)
    {
        return "correct_path";
    }

    if ($path ne "/")
    {
        $path =~ m{^(/[^/]+/?)};

        $path = $1;
    }

    my $mode = $urls_to_modes{$path};

    if (!defined($mode))
    {
        my $slash_mode = $urls_to_modes{"$path/"};
        if (defined($slash_mode))
        {
            return "correct_path";
        }
        return "redirect_to_main";
    }
    else
    {
        return $mode;
    }
}

sub initialize
{
	my $self = shift;
	
    my $config = shift;
	$self->config($config); 

    $self->_group_by_field(
        exists($self->config()->{group_by}) ?
            $self->config()->{group_by}->[0] :
            undef
        );

    my $tt = Template->new(
        {
            'BLOCKS' => 
                {
                    'main' => $config->{'record_template'},
                },
        },
    );

    $self->record_tt($tt);

	return 0;
}

sub remove_leading_slash
{
    my ($self, $string) = @_;
    $string =~ s{^/}{};
    return $string;
}

sub get_path_wo_leading_slash
{
    my $self = shift;
    return $self->remove_leading_slash($self->get_path());
}

sub get_rel_url_to_root
{
    my ($self, $string) = @_;
    return join("", (map { "../" } split(/\//, $string)));
}

sub get_path_to_root
{
    my $self = shift;

    return $self->get_rel_url_to_root($self->get_path_wo_leading_slash());
}

# TODO : Add and implement a parameter for the title of the RSS feed.

sub get_string
{
    my $self = shift;
    my $string_id = shift;

    return $self->config()->{'strings'}->{$string_id};
}

sub get_dsn
{
    my $self = shift;

    return $self->config()->{'dsn'};
}

sub _table_name
{
    my $self = shift;

    return $self->config()->{'table_name'};
}

sub _dbi_connect
{
    my $self = shift;
    return DBI->connect($self->get_dsn());
}

sub main_page
{
    my $self = shift;

    my $title = $self->get_string('main_title');

    my @group_params;

    if (defined($self->_group_by_field()))
    {
        @group_params = 
        (
            'group_by_field' => $self->_group_by_field(),
            'groups' => $self->_get_group_list(),
            'group_by_field_record' =>
                $self->_get_field_by_name($self->_group_by_field()),
        );
    }
    else
    {
        @group_params =
        (
            'group_by_field' => undef,
        )
    }

    return $self->tt_process(
        'main_page.tt',
        {
            'title' => $title,
            'header' => $title,
            (
                map { $_ => $self->get_string($_) } 
                (qw(show_all_records_text add_a_record_text remove_a_record_text))
            ),
            @group_params,
        }
    );
}

sub htmlize
{
    my $string = shift;

    if (!defined($string))
    {
        $string = "";
    }

    $string = CGI::escapeHTML($string);

    $string =~ s/\n\r?/<br \/>\n/g;

    return $string;
}

sub render_record
{
    my $self = shift;

    my $ret = "";
    my %args = (@_);

    my $values = $args{'values'};
    my $fields = $args{'fields'};

    my $mapping =
        $self->_lookup_values (
            {map { $fields->[$_] => $values->[$_] } (0 .. $#$values)}
        );
   
    my $vars = { map { $_ => htmlize($mapping->{$_}) } keys(%$mapping) };
    foreach my $flag (qw(for_rss toolbox))
    {
        if ($args{$flag})
        {
            $vars->{$flag} = 1;
        }
    }

    $vars->{'path_to_root'} = $self->get_path_to_root();

    $self->record_tt()->process('main', $vars, \$ret);

    return $ret;
}

sub _lookup_values
{
    my ($self, $mapping) = @_;

    my $ret = {};

    while (my ($field, $init_val) = each(%$mapping))
    {
        my $record = $self->_get_field_by_name($field);

        $ret->{$field} =
            (defined($record) && ($record->{control_type} eq "select")) ?
                $self->_lookup_select_value($field, $record, $init_val) :
                $init_val
                ;
    }

    return $ret;
}

sub _lookup_select_value
{
    my $self = shift;

    my ($field, $record, $value) = @_;
   
    my $params = $record->{'values'};

    if ($params->{'from'} eq "sql")
    {
        return $self->_lookup_sql_select_value(@_);
    }
    elsif ($params->{'from'} eq "list")
    {
        return $self->_lookup_list_select_value(@_);
    }
    else
    {
        die "Unknown ->{values}->{from} value in field \"$field\"";
    }
}

sub _lookup_sql_select_value
{
    my $self = shift;

    my ($field, $record, $value) = @_;

    my $params = $record->{'values'};
    
    my $dbh = $self->_get_dbh();

    my $sth = $dbh->prepare(
        "SELECT $params->{display_field} " .
        "FROM $params->{table} " .
        "WHERE $params->{id_field} = ?"
    );

    $sth->execute($value);

    my $db_vals = $sth->fetchrow_arrayref();

    my $ret = $db_vals->[0];

    undef($sth);

    return $ret;
}

sub _lookup_list_select_value
{
    my $self = shift;

    my ($field, $record, $value) = @_;

    my $params = $record->{'values'};
    
    # TODO : Optimize - it's currently a linear scan.
    foreach my $entry (@{$params->{'list'}})
    {
        if ($entry->{id} eq $value)
        {
            return $entry->{display};
        }
    }

    return undef;
}


sub get_fields
{
    my $self = shift;

    return @{$self->config()->{'fields'}};
}

sub _get_field_by_name
{
    my ($self, $name) = @_;

    my @fields = $self->get_fields();

    if (! $self->_sql_to_field())
    {    
        $self->_sql_to_field(
            { map { $fields[$_]->{'sql'} => $_ } (0 .. $#fields) }
        );
    }

    return exists($self->_sql_to_field()->{$name}) ?
        $fields[$self->_sql_to_field()->{$name}] :
        undef;
}

sub get_field_names
{
    my $self = shift;

    my @field_names = ("id", (map { $_->{'sql'} } $self->get_fields()));

    return \@field_names;
}

sub _get_group_list
{
    my $self = shift;

    my $group_by_field = $self->_group_by_field();

    my $record = $self->_get_field_by_name($group_by_field);

    if (exists($record->{values}) &&
        ($record->{values}->{from} eq "list"))
    {
        return [ @{$record->{values}->{list}} ];
    }
    else
    {
        return [];
    }
}



sub _get_active_status_value
{
    return 0;
}

sub _get_disabled_status_value
{
    return 1;
}

sub construct_fetch_query
{
    my ($self, $args) = @_;

    my $query =
        Shlomif::MiniReporter::FetchQuery->new({%$args, main => $self});

    $query->prepare_sth();

    return $query;
}

sub _get_jobs_by_group
{
    my $self = shift;
    my $args = shift;

    my $display_toolbox = $args->{'toolbox'} || 0;

    my %jobs_by_group;

    # Currently we support only one level of grouping
    my $group_by_field = $self->_group_by_field();

    my $fields_seq = $self->get_field_names();

    my $index;

    if (defined($group_by_field))
    {
        $index = (List::Util::first { $fields_seq->[$_] eq $group_by_field } (0 .. $#$fields_seq));
    }

    my $query = $self->construct_fetch_query($args);

    while (my $values = $query->fetch_row())
    {
        push @{$jobs_by_group{defined($index) ? $values->[$index] : "All"}},
            $self->render_record(
                'values' => $values,
                'fields' => $query->field_names(),
                'toolbox' => $display_toolbox,
            );
    }

    my $ret =
    [
        map
        {
            +{
                'name' => $_->{display},
                'records' => ($jobs_by_group{$_->{id}} || []), 
            }
        }
        @{$query->groups()},
    ];

    $query->detach();

    return $ret;
}


=head2 $self->display_records(%args)

Accepts the following optional parameters:

    all_records - if set, display all records (by default only active ones)
    keyword - a keyword to search for.
    group_choice - a group to choose for (or All for all groups). 
      If _group_by_field is undef should be undef.
    toolbox - display the toolbox of admining a record (defaults to 0)
    show_disabled - show disabled records as well.
    show_enabled - show enabled records as well.
=cut


sub display_records
{
    my ($self, $args) = @_;

    return $self->tt_process(
        'display_records_page.tt',
        {
            'header' => ($args->{header} || "Search Results"),
            'title' => ($args->{title} || "Search Results"),
            'jobs_by_group' => $self->_get_jobs_by_group($args),
            wrapper_start => ($args->{wrapper_start} || ""),
            wrapper_end => ($args->{wrapper_end} || ""),
        },
    );
}

sub search_results
{
    my $self = shift;

    my $q = $self->query();

    my $all_param = $q->param("all") || "";

    my $keyword_param = $q->param("keyword") || "";

    my $group_param =
        defined($self->_group_by_field()) ?
            ($q->param($self->_group_by_field()) || "") :
            undef;

    return $self->display_records(
        {
            'all_records' => $all_param,
            'keyword' => $keyword_param,
            'group_choice' => $group_param,
        }
    );
}

sub _is_field_auto
{
    my ($self, $field) = @_;
    return (
        exists($field->{'gen'}) &&
        exists($field->{'gen'}->{'auto'}) &&
        $field->{'gen'}->{'auto'}
    );
}

sub get_form_fields
{
    my $self = shift;

    my $fields_gen =
        Shlomif::MiniReporter::FormFieldsGen->new(
            { 'main' => $self }
        );

    my $fields = $fields_gen->get_form_fields();

    $fields_gen->detach();
    
    return $fields;
}

sub get_form_fields_sequence
{
    my $self = shift;

    my @ret;

    foreach my $f ($self->get_fields())
    {
        if ($self->_is_field_auto($f))
        {
            next;
        }
        push @ret, $f->{sql};
    }

    if ($self->config->{captcha})
    {
        push @ret, "f65Yoower";
    }

    return \@ret;
}

sub get_form
{
    my $self = shift;
    my $q = $self->query();

    my $form = 
        WWW::Form->new(
            $self->get_form_fields(),
            scalar($q->Vars()),
            $self->get_form_fields_sequence(),
        );

    return $form;
}

sub get_add_form_single_field_value
{
    my $self = shift;
    my $a = shift;

    my $value = scalar($self->query()->param($a->{'sql'}));

    if ($self->_is_field_auto($a))
    {
        return $a->{'gen'}->{callback}->($value);
    }
    else
    {
        return $value;
    }
}

sub get_add_form_single_field
{
    my $self = shift;
    my $a = shift;
    return
        {
            'field' => $a->{sql},
            'value' => $self->get_add_form_single_field_value($a),
        };
}

sub get_add_form_fields
{
    my $self = shift;

    my @ret =
    (
        map { $self->get_add_form_single_field($_) } 
            $self->get_fields()
    );
    return 
        (
            [ map { $_->{'field'} } @ret], 
            [ map { $_->{'value'} } @ret], 
        );
}

sub _get_text_delimiter
{
    return " ; "
}

sub _update_text_for_record
{
    my ($self, $id, $names) = @_;

    my $table_name = $self->_table_name;

    my $query = "SELECT " . join(",", @$names) . " FROM $table_name WHERE id = ?";

    my $dbh = $self->_get_dbh();

    my $sth = $dbh->prepare($query);

    $sth->execute($id);

    my @sql_values = $sth->fetchrow_array();

    my $text_values =
        $self->_lookup_values(
            { map { $names->[$_] => $sql_values[$_] } (0 .. $#sql_values) }
        );

    my $text_table = $self->config()->{text_table_name};

    my $check_sth = $dbh->prepare(
        "SELECT id FROM $text_table WHERE id = ?"
    );

    $check_sth->execute($id);

    if (my @fetched_id = $check_sth->fetchrow_array())
    {
        # Do Nothing - there is such a row
    }
    else
    {
        # We execute this so the record with this ID will be present so we can
        # later safely UPDATE it.        
        my $insert_dummy_sth = $dbh->prepare(
            "INSERT INTO $text_table (id, mytext) VALUES (?, '')"
        );
        $insert_dummy_sth->execute($id);
    }

    my $text = join($self->_get_text_delimiter(), 
        map { my $s = $text_values->{$_}; defined($s) ? $s : "" } @$names
    );
    my $update_text_sth = $dbh->prepare(
        "UPDATE $text_table SET mytext = ? WHERE id = ?"
    );
    $update_text_sth->execute($text, $id);

    return;
}

sub update_texts_for_all_records
{
    my $self = shift;

    my $dbh = $self->_get_dbh();

    my $sth = $dbh->prepare("SELECT id FROM " . $self->_table_name());

    $sth->execute();

    my @ids;
    while (my @row = $sth->fetchrow_array())
    {
        push @ids, $row[0];
    }

    my $fields = [ map { $_->{sql} } $self->get_fields() ];

    foreach my $id (@ids)
    {
        $self->_update_text_for_record($id, $fields);
    }

    return;
}

sub perform_insert
{
    my ($self, $names, $values) = @_;

    my $dbh = $self->_get_dbh();

    my @map;

    push @map, ['id', "null"];
    push @map, ['status', $self->_get_active_status_value()];
    push @map,
        (map { [$names->[$_], $dbh->quote($values->[$_])] } 
            (0 .. $#$names)
        );
    
    my $query_str = "INSERT INTO " . $self->_table_name() .
        " (" . join(",", map { $_->[0] } @map) . ") " .
        " VALUES (" . join(",", map { $_->[1] } @map) . ")";

    $dbh->do($query_str);

    my $inserted_id =
        $dbh->last_insert_id(undef, undef, $self->_table_name(), 'id');

    $self->_update_text_for_record($inserted_id, $names);

    $self->update_rss_feed();

    return $self->tt_process(
        'perform_insert_page.tt',
        {
            'title' => $self->get_string('add_result_title'),
            'header' => "Success",
            (map { $_ => $self->get_string($_) } ('add_back_link_text')),
        }
    );
}

sub get_add_form_handler
{
    my $self = shift;
    return Shlomif::MiniReporter::Form->new({'main' => $self});
}

sub add_form
{
    my $self = shift;

    my $form = $self->get_add_form_handler();

    my $ret = $form->get_page();

    $form->detach();

    return $ret;
}

sub css_stylesheet
{
    my $self = shift;

    local $/;
    open my $in, "<style.css";
    $self->header_props(-type => "text/css");
    my $output = <$in>;
    close($in);
    
    return $output;
}

sub get_url_to_main
{
    my $self = shift;

    # SCRIPT_URI requires Apache 1.3.x's mod_rewrite
    my $script_uri = $ENV{'SCRIPT_URI'};

    my $url = substr($script_uri, 0, - length($self->get_path()));

    return $url.'/';
}

sub get_rss_table_name
{
    my $self = shift;
    return $self->config()->{'rss_table_name'};
}

sub get_url_to_item
{
    my $self = shift;
    my $id = shift;
    return $self->get_url_to_main() . "show-record/$id/";
}

sub update_rss_feed
{
    my $self = shift;

    if (! $self->get_rss_table_name())
    {
        return;
    }

    my $query = 
        $self->construct_fetch_query(
            {
                'all_records' => 1, 
                'max_num_records' => 15
            }
        );

    my $rss_feed = XML::RSS->new('version' => "2.0");

    $rss_feed->channel(
        'title' => $self->get_string('main_title'),
        'link' => $self->get_url_to_main(),
        'language' => "en-us",
        'description' => $self->get_string('main_title'),
        'rating' => '(PICS-1.1 "http://www.classify.org/safesurf/" 1 r (SS~~000 1))',
        'copyright' => "Copyright by the Posters",
        'pubDate' => (scalar(localtime())),
        'lastBuildDate' => (scalar(localtime())),
        'docs' => "http://blogs.law.harvard.edu/tech/rss",
        'ttl' => "360",
        'generator' => "Perl and XML::RSS",
        );

    my $values;

    while ($values = $query->fetch_row())
    {
        my %fields = 
            (map 
                { $query->field_names()->[$_] => $values->[$_] } 
                (0 .. $#$values)
            );

        $fields{'post_date'} =~ /^(\d{4})-(\d{2})-(\d{2})$/;
        my ($date_year, $date_month, $date_day) = ($1,$2,$3);
        my $date_time =
            POSIX::mktime(0, 30, 18, $date_day, $date_month-1, $date_year-1900);

        my $item_url = $self->get_url_to_item($fields{'id'});

        $rss_feed->add_item(
            'title' => $fields{'title'},
            (map { $_ => $item_url, } (qw(permaLink link))),
            'enclosure' => { 'url' => $item_url},
            'description' => 
                htmlize($self->render_record(
                    'values' => $values,
                    'fields' => $query->field_names(),
                    'for_rss' => 1,
                )),
            'author' => "Unknown",
            'pubDate' => scalar(localtime($date_time)),
            'category' => "Meetings",
        );
    }

    $query->detach();

    my $rss_data = $rss_feed->as_string();

    undef($rss_feed);

    my $sth = $self->_get_dbh()->prepare(
        "UPDATE " . $self->get_rss_table_name() .
        " SET xmltext = ? WHERE relevance = 'all' AND format = 'rss'"
        );

    $sth->execute($rss_data);

    return 0;
}

sub _admin_screen
{
    my $self = shift;

    my $path = $self->get_path();

    if ($path eq "/admin/login/")
    {
        my $username = $self->query->param('username');
        my $password = $self->query->param('password');

        if (($username eq "admin") && ($password eq $self->config()->{'admin_password'}))
        {
            $self->session->param('username', 'admin');
            return $self->tt_process(
                'admin_logged_in_page.tt',
                {
                    'title' => "You are now Logged In",
                    'header' => "You are now Logged In",
                }
            );
        }
        else
        {
            return "Login failed. Press the back button and try again.";
        }
    }
    if (!defined($self->session->param("username")))
    {
        return $self->tt_process(
            'admin_login_page.tt',
            {
                'title' => "Login to the Admin Page",
                'header' => "Login to the Admin Page",
            },
        );
    }

    if ($path eq "/admin/")
    {
        return $self->tt_process(
            'admin_main_page.tt',
            {
                'title' => "Admin Page",
                'header' => "Admin Page",
                'select_fields' => $self->_get_editable_select_fields(),
            },
        );
    }
    elsif ($path eq "/admin/main-table/set-status/")
    {
        return $self->_admin_set_status();
    }
    elsif ($path =~ m{^/admin/resource-list/([^/]+)/$})
    {
        return $self->_admin_select({'field' => $1});
    }
}

sub _get_editable_select_fields
{
    my $self = shift;

    return 
    [ 
        grep { $_->{control_type} eq "select" } 
        ($self->get_fields())
    ];
}

sub _admin_select
{
    my ($self, $args) = @_;

    my $name = $args->{field};

    my $field = $self->_get_field_by_name($name);

    if (!defined($field))
    {
        return "Unknown Resource List " . CGI::escapeHTML($field) . "!";
    }

    my $op = $self->query()->param("op") || "";

    my $table = $field->{'values'};

    if (($op eq "enable") || ($op eq "disable"))
    {
        my $new_status = $op eq "enable" ? 0 : 1;

        my $id = $self->query()->param("id");

        if (!defined($id) || ($id !~ /^(\d+)$/))
        {
            return "You've reached a wrong URL.";
        }

        my $sth = $self->_get_dbh()->prepare(
            "UPDATE $table->{table} SET status = ? WHERE id = ?"
        );

        $sth->execute($new_status, $id);
    }
    elsif ($op eq "add")
    {
        my $name = $self->query->param("name");

        # To make sure name is not empty which probably means the form was
        # submitted by mistake.
        if ($name =~ /\S/)
        {
            my $sth = $self->_get_dbh->prepare(
                "INSERT INTO $table->{table} (id, name, status) ". 
                "VALUES (null, ?, 0)"
            );

            $sth->execute($name);
        }

        # This redirect is done so upon reload the record won't be
        # submitted again.
        $self->header_type('redirect');
        $self->header_props(-url => "./");

        return "";
    }
    elsif ($op eq "rename")
    {
        my $id = $self->query()->param("id");

        if (!defined($id) || ($id !~ /^(\d+)$/))
        {
            return "You've reached a wrong URL.";
        }

        my $sth = $self->_get_dbh()->prepare(
            "SELECT $table->{display_field} " .
            "FROM $table->{table} WHERE $table->{id_field} = ?"
        );

        $sth->execute($id);

        my $values = $sth->fetchrow_arrayref();

        if (!defined($values))
        {
            return "You've reached a wrong URL.";
        }

        my $name = $values->[0];

        # Display the rename form.
        return $self->tt_process(
            'admin_select_rename_form_page.tt',
            {
                (map { $_ => "Rename Project" } qw(header title)),
                name => $name,
                id => $id,
            },
        );
    }
    elsif ($op eq "rename_commit")
    {
        my $id = $self->query()->param("id");

        if (!defined($id) || ($id !~ /^(\d+)$/))
        {
            return "You've reached a wrong URL.";
        }

        my $sth = $self->_get_dbh()->prepare(
            "UPDATE $table->{table} SET name = ? WHERE id = ?"
        );

        $sth->execute($self->query()->param("name"), $id);
    }

    my $sth = $self->_get_dbh()->prepare(
        "SELECT $table->{id_field}, $table->{display_field}, status " .
        "FROM $table->{table} " .
        "ORDER BY $table->{display_field} "
    );

    $sth->execute();

    my @records = (
        {label => "Enabled", records => [], 'en' => 1,}, 
        {label => "Disabled", records => [], 'en' => 0,},
    );

    while (my $row = $sth->fetchrow_arrayref())
    {
        push @{$records[($row->[2] eq 0) ? 0 : 1]->{records}},
            { 'id' => $row->[0], 'name' => $row->[1] };
    }

    return $self->tt_process(
        'admin_select_page.tt',
        {
            (map { $_ => 
                "Administer Resource List for " . htmlize($field->{pres}),
            } (qw(header title))),
            records => \@records,
        },
    );
}

sub _admin_set_status
{
    my $self = shift;

    if ($self->query()->param("commit"))
    {
        return $self->_admin_set_status_commit();
    }

    my $mode = $self->query()->param("mode");
    my $esc_mode = htmlize($mode);

    return $self->display_records(
        {
            'all_records' => 1,
            'toolbox' => 1,
            'status_value' => 
                ($mode eq "disable" ?
                    $self->_get_active_status_value() :
                    $self->_get_disabled_status_value()
                ),
            'header' => "Set the Status for the Records",
            'title' => "Set the Status for the Records",
            wrapper_start => <<"EOF",
<form method="post" action=".">
<input type="hidden" name="mode" value="$esc_mode" />
<input type="hidden" name="commit" value="1" />
EOF
            wrapper_end => <<"EOF",
<p>
<input type="submit" value="Submit" />
</p>
</form>
EOF
        }
    );
}

sub _admin_set_status_commit
{
    my $self = shift;

    my $cgi = $self->query();

    my $mode = $cgi->param("mode");

    my $new_status =
        ($mode eq "disable") ?
            $self->_get_disabled_status_value() :
            $self->_get_active_status_value()
            ;

    my @ids = $cgi->param("toggle");

    my $sth = $self->_get_dbh()->prepare(
        "UPDATE " . $self->_table_name() .
        " SET status = ?" .
        " WHERE id = ?"
    );

    foreach my $id (@ids)
    {
        $sth->execute($new_status, $id);
    }

    undef($sth);

    return $self->tt_process(
        "admin_set_status_done.tt",
        {
            'title' => "Operation was Succesful",
            'header' => "Operation was Succesful",
        },
    );
}

sub remove
{
    my $self = shift;

    return $self->tt_process(
        'remove_page.tt',
        {
            'title' => $self->get_string('remove_result_title'),
            'header' => "Remove a Job",
            (map { $_ => $self->get_string($_) } ('service')),
        },
    );
}

sub rss_feed
{
    my $self = shift;

    if (! $self->get_rss_table_name())
    {
        return "";
    }

    my $dbh = $self->_get_dbh();

    my $sth = $dbh->prepare("SELECT xmltext FROM jobs2_feeds " . 
        "WHERE relevance = 'all' AND format = 'rss'");

    $sth->execute();

    my $values = $sth->fetchrow_arrayref();

    $sth->finish();

    undef($sth);

    $self->header_props(-type => "text/rss");

    return $values->[0];
}

sub update_rss
{
    my $self = shift;
    
    # A security measurement to make sure this feature is not abused.
    # requires passing the password as a CGI parameter
    if ($self->query()->param('password') ne $self->config()->{'admin_password'})
    {
        return "<p>You are unauthorized to do this. Either the password is wrong or you should go away.</p>";
    }
    $self->update_rss_feed();
    return "<p>RSS Feed Updated.</p>";
}

sub show_record
{
    my $self = shift;
    if ($self->get_path() =~ m!/show-record/(\d+)/!)
    {
        return $self->show_record_by_id($1);
    }
    else
    {
        return $self->redirect_to_main();
    }
}

sub get_record_fields
{
    my ($self, $record_id) = @_;

    my $query = $self->construct_fetch_query({'id' => $record_id});

    my @ret = ($query->field_names(), $query->fetch_row());

    $query->detach();

    return @ret;
}

sub get_show_record_params
{
    my ($self, $record_id) = @_;

    my ($field_names, $values) = $self->get_record_fields($record_id);

    if (defined($values))
    {
        return (
            "Displaying Record $record_id",
            $self->render_record(
                'values' => $values,
                'fields' => $field_names,
                'toolbox' => 0,
            )
        );
    }
    else
    {
        return (
            "Record not found - sorry",
            "",
        );
    }
}

sub show_record_by_id
{
    my ($self, $record_id) = @_;

    my ($title, $record) = $self->get_show_record_params($record_id);

    return $self->tt_process(
        'show_record_page.tt',
        {
            (map { $_ => $title } qw(header title)),
            'record' => $record,
            'url' => $self->get_url_to_item($record_id),
        }
    );
}

1;

package Shlomif::MiniReporter::Form;

use base 'Shlomif::MiniReporter::HelperObj';

__PACKAGE__->mk_accessors(qw(
    field_names
    form
    values_
));

sub _initialize
{
    my $self = shift;
    $self->SUPER::_initialize(@_);
    $self->form($self->main()->get_form());
    $self->form()->validate_fields();

    my ($field_names, $values) = $self->main()->get_add_form_fields();
    $self->field_names($field_names);
    $self->values_($values);

    return 0;
}

sub is_valid
{
    my $self = shift;
    return $self->form()->is_valid();
}

sub no_cgi_params
{
    my $self = shift;
    return (scalar($self->query()->param()) ? 0 : 1);
}

sub _should_display_form
{
    my $self = shift;
    return 
    (
        $self->query()->param('preview') || 
        (! $self->is_valid()) || 
        $self->no_cgi_params()
    );
}

sub get_page
{
    my $self = shift;
    
    if ($self->_should_display_form())
    {
        return $self->get_add_form_page();
    }
    else
    {
        return $self->perform_insert();
    }
}

sub perform_insert
{
    my $self = shift;
    return $self->main()->perform_insert(
        $self->field_names(),
        $self->values_(),
    );
}

sub record_html
{
    my $self = shift;
    return 
        $self->no_cgi_params() ?
            "" :
            $self->main()->render_record(
                'fields' => $self->field_names(),
                'values' => $self->values_(),
            );
}

sub get_submit_button
{
    my $self = shift;
    if ($self->is_valid() && ! $self->no_cgi_params())
    {
        return
        {
            submit_label => "Submit",
            submit_name => "submit",
        };
    }
    else
    {
        return ();
    }
}

sub get_buttons
{
    my $self = shift;
    
    return
    [
        {
            submit_label => "Preview", 
            submit_name => "preview",
            submit_class => "preview",
        },
        $self->get_submit_button(),
    ];
}

sub get_form_header
{    
    my $self = shift;
    return "<p class=\"warning\"><b>Note:</b> all entries must be in English.".
           "(or else they won't be displayed correctly</p>"
}

sub get_form_html_from_params
{
    my ($self, $params) = @_;

    return $self->get_form_header($params) .
        $self->form()->get_form_HTML(@$params);
}

sub get_form_attributes
{
    return { 'class' => "myform" };
}

sub get_form_params
{
    my $self = shift;
    return
    [
        'action' => "",
        'buttons' => $self->get_buttons(),
        'attributes' => $self->get_form_attributes(),
    ];
}

sub form_html
{
    my $self = shift;

    return
        $self->get_form_html_from_params(
            $self->get_form_params(),
        );
}

sub get_add_form_titles
{
    my $self = shift;
    if ($self->no_cgi_params())
    {
        return
        [
            'title' => $self->main()->get_string('add_form_title'),
            'header' => $self->main()->get_string('add_form_header'),
        ];
    }
    elsif ($self->is_valid())
    {
        return
        [
            'title' => $self->main()->get_string('preview_result_title'), 
            'header' => "Preview the Added Record"
        ];
    }
    else
    {
        return
        [
            'title' => "Invalid Parameters Entered", 
            'header' => "Invalid Parameters Entered"
        ];
    }
}

sub get_add_form_page
{
    my $self = shift;

    return $self->main()->tt_process(
        'add_form_page.tt',
        {
            @{$self->get_add_form_titles()},
            'record_html' => $self->record_html(),
            'form_html' => $self->form_html(),
        },
    );
}

1;

package Shlomif::MiniReporter::FormFieldsGen;

use base 'Shlomif::MiniReporter::HelperObj';

__PACKAGE__->mk_accessors(qw(
    _dbh
    f
    field_idx
    fields
    fields_seq
    input_length
    input_height
));

sub _initialize
{
    my $self = shift;
    $self->SUPER::_initialize(@_);
    $self->fields({});
    $self->field_idx(0);
    $self->fields_seq([$self->main()->get_fields()]);

    # Number of characters for the input tag or textarea to be as wide;
    $self->input_length(40);
    $self->input_height(10);

    return 0;
}

sub get_alternate_style
{
    my $self = shift;

    my $ret = (($self->field_idx() % 2 == 1) ? "hilight" : "hilight2");

    $self->field_idx($self->field_idx()+1);

    return $ret;
}

sub get_attribs
{
    my $self = shift;
    my $class = $self->get_alternate_style();
    return ('container_attributes' =>
            { 'class' => $class, },
            'hint_container_attributes' =>
            { 'class' => "$class space", },
           );
}

sub set_field
{
    my ($self, $name, $value) = @_;
    $self->fields()->{$name} = $value;
}

sub shift_f
{
    my $self = shift;
    return $self->f(shift(@{$self->fields_seq()}));
}

sub set_f_auto_field
{
}

sub _is_sameline
{
    my $self = shift;
    return ($self->f()->{control_type} ne "textarea");
}

sub get_sameline_validator
{
    my $self = shift;
    if ($self->_is_sameline())
    {
        return
            WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
            "No newlines allowed",
            '^([^\n\r]*)$'
            );
    }
    else
    {
        return ();
    }
}

sub get_len_validator
{
    my $self = shift;
    if ($self->f()->{len})
    {
        return 
            WWW::FieldValidator->new(
                WWW::FieldValidator::MAX_STR_LENGTH,
                sprintf("%s is limited to %s characters",
                    $self->f()->{pres}, $self->f()->{len}),
                $self->f()->{len}
            );
    }
    else
    {
        return ();
    }
}

sub get_url_validator
{
    my $self = shift;
    if ($self->f()->{flags}->{url})
    {
        return
            WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
            "URL Should start with http://",
            '^(?:|http://.*)$'
            );
    }
    else
    {
        return ();
    }
}

sub get_email_validator
{
    my $self = shift;
    if ($self->f()->{flags}->{email})
    {
        return
            WWW::FieldValidator->new(WWW::FieldValidator::WELL_FORMED_EMAIL,
            "Should be a well-formed Email Address",
            1,
            );
    }
    else
    {
        return ();
    }
}

sub return_false
{
    return 0;
}

sub get_captcha_validator
{
    my $self = shift;

    my $main = $self->main();

    # We don't have to validate if it's just a preview
    if ($self->query()->param('preview') 
        || (     (!defined($self->query->param('preview')))
              && (!defined($self->query->param('submit' )))
           )
       )
    {
        return ();
    }

    # If the captcha1 session value does not exist - it's wrong.
    if (!defined($self->main->session->param('captcha1')))
    {
        return WWW::FieldValidator->new(
            WWW::FieldValidator::USER_DEFINED_SUB(),
            "Go away spammer!",
            \&return_false,
        );
    }

    return WWW::FieldValidator->new(
        WWW::FieldValidator::USER_DEFINED_SUB,
        "You should answer the security question correctly.",
        sub {
            print STDERR "\@_ = ", join(",",@_), "\n";
            my $value = shift;
            print STDERR "Value = ", $value, "\n";
            print STDERR "capt1 = ", $main->session->param("captcha1"), "\n";
            return ($main->session->param("captcha1") eq $value);
        }
    );
}

sub get_validators
{
    my $self = shift;
    return 
    [ 
        $self->get_sameline_validator(),
        $self->get_len_validator(),
        $self->get_url_validator(),
        $self->get_email_validator(),
    ];
}

sub get_extra_attributes
{
    my $self = shift;
    if ($self->f()->{control_type} eq "text")
    {
        return " size=\"" . $self->input_length() . "\" ";
    }
    else
    {
        return sprintf(' cols="%d" rows="%d"',
            $self->input_length(), $self->input_height()
        );
    }
}

sub get_hint
{
    my $self = shift;
    if (exists($self->f()->{hint}))
    {
        return (hint => $self->f()->{hint});
    }
    else
    {
        return ();
    }
}

sub _get_select_control_options
{
    my $self = shift;
    
    my $f = $self->f();

    my $params = $f->{'values'};

    my $from = $params->{from};

    if ($from eq "sql")
    {
        return $self->_get_sql_select_control_options();
    }
    elsif ($from eq "list")
    {
        return $self->_get_list_select_control_options();
    }
    else
    {
        die "Unknown ->{values}->{from} value. Should be SQL.";
    }
}

sub _get_list_select_control_options
{
    my $self = shift;

    my $f = $self->f();

    my $params = $f->{'values'};

    my @ret;
    foreach my $entry (@{$params->{list}})
    {
        push @ret, { label => $entry->{display}, value => $entry->{id} };
    }

    return \@ret;
}

sub _get_sql_select_control_options
{
    my $self = shift;

    my $f = $self->f();

    my $params = $f->{'values'};

    my $dbh = $self->_get_dbh();

    my $sth = $dbh->prepare(
        "SELECT $params->{id_field}, $params->{display_field} " . 
        "FROM $params->{table} " .
        "WHERE status = 0 " .
        "ORDER BY $params->{display_field} " .
        ""
    );

    $sth->execute();
    
    my @ret;

    while (my $values = $sth->fetchrow_arrayref())
    {
        push @ret, +{ label => $values->[1], value => $values->[0] };
    }

    undef($sth);

    return \@ret;
}

sub _get_select_control_default
{
    my $self = shift;
    my $f = $self->f();

    my $params = $f->{values};
    if (exists($params->{default_value}))
    {
        return [ defaultValue => $params->{default_value} ];
    }
    else
    {
        return [];
    }
}

sub _get_select_control_attrs
{
    my $self = shift;
    my $f = $self->f();

    if ($f->{control_type} ne "select")
    {
        return [];
    }

    return
    [
        optionsGroup => $self->_get_select_control_options(),
        @{$self->_get_select_control_default()}
    ];
}

sub _get_control_type
{
    my $self = shift;

    my $control_type = $self->f()->{control_type};

    if ($control_type =~ /^(text|textarea|select)$/)
    {
        return $control_type;
    }
    else
    {
        die "Unknown control type \"$control_type\"!";
    }
}

sub get_f_field_struct
{
    my $self = shift;
    my $f = $self->f();

    return
    {
        label => $f->{'pres'},
        defaultValue => ($self->query()->param($f->{sql}) || ""),
        type => $self->_get_control_type(),
        validators => $self->get_validators(),
        extraAttributes => $self->get_extra_attributes(),
        # Give the hint if it exists
        $self->get_hint(),
        # Highlight the odd numbered fields
        $self->get_attribs(),
        @{$self->_get_select_control_attrs()},
    };
}

sub set_f_nonauto_field
{
    my $self = shift;

    my $f = $self->f();

    $self->set_field($f->{sql}, $self->get_f_field_struct());
}

sub set_f_field
{
    my $self = shift;
    if ($self->main()->_is_field_auto($self->f()))
    {
        return $self->set_f_auto_field();
    }
    else
    {
        return $self->set_f_nonauto_field();
    }
}

sub set_captcha_field
{
    my $self = shift;

    if (!$self->main()->config->{captcha})
    {
        return;
    }

    open RAND, "<", "/dev/urandom";
    my $buf;
    read(RAND, $buf, 10);
    close(RAND);

    my $n1 = ord(substr($buf,0,1))%10;
    my $n2 = ord(substr($buf,1,1))%10;

    $self->set_field("f65Yoower",
        {
            label => "$n1 + $n2 = ",
            defaultValue => "",
            type => "text",
            validators => [$self->get_captcha_validator()],
            hint => q{Please answer the security question.},
            $self->get_attribs(),
        },
    );

    $self->main()->_set_captcha_value($n1+$n2);

    return;
}

sub get_form_fields
{
    my $self = shift;

    while ($self->shift_f())
    {
        $self->set_f_field();
    }

    $self->set_captcha_field();

    return $self->fields();
}

1;

