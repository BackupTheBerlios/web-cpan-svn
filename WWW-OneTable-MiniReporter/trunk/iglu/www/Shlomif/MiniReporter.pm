package Shlomif::MiniReporter;

use strict;
use warnings;
use DBI;
use POSIX qw();
use Template;
# Inherit from CGI::Application.
use base 'CGI::Application';
use base 'Class::Accessor';

use CGI::Application::Plugin::TT;

use XML::RSS;

use WWW::Form;

use WWW::FieldValidator;

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
        'func' => "admin_screen",
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
    record_tt
));

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

sub cgiapp_prerun
{
    my $self = shift;

    $self->tt_params(
        'path_to_root' => $self->get_path_to_root(),
        'with_rss' => $self->get_rss_table_name(),
        'show_all_records_url' => "search/?all=1",
        'encoding' => $self->config()->{encoding},
    );

    # TODO : There may be a more efficient/faster way to do it, but I'm 
    # anxious to get it to work. -- Shlomi Fish
    $self->tt_include_path(
        [ './templates', './templates-custom' ],
    );

    # This is so the CGI header won't print a character set.
    $self->query()->charset('');
}

sub redirect_to_main
{
    my $self = shift;

    return "<html><body><h1>URL Not Found</h1></body></html>";
}

sub get_area_list
{
    my $self = shift;
    return @{$self->config()->{'areas'}};
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

    my $q = $self->query();

    my $path = $q->path_info();

    return $path;
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

sub dbi_connect
{
    my $self = shift;
    return DBI->connect($self->get_dsn());
}

sub main_page
{
    my $self = shift;

    my $title = $self->get_string('main_title');
    return $self->tt_process(
        'main_page.tt',
        {
            'title' => $title,
            'header' => $title,
            'areas' => [ $self->get_area_list() ],
            (
                map { $_ => $self->get_string($_) } 
                (qw(show_all_records_text add_a_record_text remove_a_record_text))
            ),
        }
    );
}

sub htmlize
{
	my $string = shift || "";
	
	my $char_convert = 
	sub {
		my $char = shift;
        my $ascii = ord($char);
		
		if ($char eq '&')
		{
			return "&amp;";
		}
		elsif ($char eq '>')
		{
			return "&gt;";
		}
		elsif ($char eq '<')
		{
			return "&lt;";
        }
        elsif ($ascii > 127)
        {
            return sprintf("&#x%.4x;", $ascii);
        }
	};

	$string =~ s/([&<>\x80-\xFF])/$char_convert->($1)/ge;
	
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

    my $vars = { map { $fields->[$_] => htmlize($values->[$_]) } (0 .. $#$values)};

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

sub get_fields
{
    my $self = shift;

    return @{$self->config()->{'fields'}};
}

sub get_field_names
{
    my $self = shift;

    my @field_names = ("area", "id", (map { $_->{'sql'} } $self->get_fields()));

    return \@field_names;
}

sub sanitize_areas
{
    my ($self, $areas) = @_;

    my %map = (map { $_ => 1} $self->get_area_list());

    return [grep { exists($map{$_}) } @$areas];
}

sub construct_fetch_query
{
    my $self = shift;
    my $args = shift;

    my $keyword_param = $args->{'keyword'} || "";

    my $area_param = $args->{'area_choice'} || "";

    my $id_param = $args->{'id'};

    my ($where_clause_template, @areas);

    my @area_list = $self->get_area_list();

    if (defined($id_param))
    {
        # $id_param is guaranteed to be numeric so no need for quote() here.
        $where_clause_template = "WHERE status=1 AND id=$id_param";
    }
    elsif ($args->{'all_records'} eq "1")
    {
    	$where_clause_template = "WHERE status=1";
    	
    	@areas = @area_list;
    }
    else
    {
    	if ($keyword_param =~ /^\s*$/) {
    		$where_clause_template = "WHERE status=1";
    	}
    	else
    	{
    		$keyword_param =~ s/['%]/ /g;

    		my (@search_clauses);

    		foreach my $field ($self->get_fields())
    		{
    			push @search_clauses, "(" . $field->{'sql'} . " LIKE '%" . $keyword_param
    			. "%')";
    		}

    		$where_clause_template = "WHERE status=1 AND (" . join(" OR ", @search_clauses) . ")";
    	}

    	if ($area_param eq 'All')
    	{
    		@areas = @area_list;
    	}
    	else
    	{
    		@areas = ($area_param);
    	}
    }

    my $field_names = $self->get_field_names();

    push @$field_names, ('status');

    my $limit_clause = exists($args->{'max_num_records'}) ? 
        " LIMIT " . $args->{'max_num_records'} :
        "";

    my $query_str = "SELECT " . join(", ", @$field_names) .
                    " FROM " . $self->config()->{'table_name'} .
    		" " . $where_clause_template .
    		(" ORDER BY " . ($self->config()->{'order_by'} || "id DESC")) .
            $limit_clause;

    return
        {
            'field_names' => $field_names,
            'query' => $query_str,
            'areas' => $self->sanitize_areas(\@areas),
        };
}

sub get_display_records_query
{
    my $self = shift;
    my $args = shift;
    my $conn = $self->dbi_connect();
    my $query = $self->construct_fetch_query($args);

    my $sth = $conn->prepare($query->{'query'});

    $sth->execute();

    $query->{'rows'} = $sth->fetchall_arrayref();

    $conn->disconnect();

    return $query;
}

sub get_jobs_by_area
{
    my $self = shift;
    my $args = shift;

    my $display_toolbox = $args->{'toolbox'} || 0;

    my %jobs_by_area;

    my $query = $self->get_display_records_query($args);

    foreach my $values (@{$query->{'rows'}})
    {
        push @{$jobs_by_area{$values->[0]}},
            $self->render_record(
                'values' => $values,
                'fields' => $query->{'field_names'},
                'toolbox' => $display_toolbox,
            );
    }

    return
    [
        map { +{ 'name' => $_, 'records' => ($jobs_by_area{$_} || []), } }
        @{$query->{'areas'}},
    ];
}


=head2 $self->display_records(%args)

Accepts the following optional parameters:

    all_records - if set, display all records (by default only active ones)
    keyword - a keyword to search for.
    area_choice - an area to choose for (or All for all areas)
    toolbox - display the toolbox of admining a record (defaults to 0)
    show_disabled - show disabled records as well.
    show_enabled - show enabled records as well.
=cut


sub display_records
{
    my $self = shift;

    return $self->tt_process(
        'display_records_page.tt',
        {
            'header' => "Search Results",
            'title' => "Search Results",
            'jobs_by_area' => $self->get_jobs_by_area(@_),
        },
    );
}

sub search_results
{
    my $self = shift;

    my $q = $self->query();

    my $all_param = $q->param("all") || "";

    my $keyword_param = $q->param("keyword") || "";

    my $area_param = $q->param("area") || "";

    return $self->display_records(
        {
            'all_records' => $all_param,
            'keyword' => $keyword_param,
            'area_choice' => $area_param,
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

    # Don't forget to put the area - otherwise WWW::Form won't display it.
    push @ret, 'area';
    
    foreach my $f ($self->get_fields())
    {
        if ($self->_is_field_auto($f))
        {
            next;
        }
        push @ret, $f->{sql};
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
            $q->{Vars},
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

sub perform_insert
{
    my ($self, $field_names, $values) = @_;

    my $conn = $self->dbi_connect();
    my $query_str = "INSERT INTO " . $self->config()->{'table_name'} .
        " (" . join(",", "id", "status", "area", @$field_names) . ") " .
        " VALUES (0, 1, '" . $self->query()->param("area") . "'," .  join(",", (map { $conn->quote($_); } @$values)) . ")";

    $conn->do($query_str);

    $self->update_rss_feed($conn);

    $conn->disconnect();

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

    my $path_info = $self->query()->path_info();

    my $url = substr($script_uri, 0, - length($path_info));

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

    my $conn = shift;

    my $query = 
        $self->construct_fetch_query(
            {
                'all_records' => 1, 
                'max_num_records' => 15
            }
        );

    my $sth = $conn->prepare($query->{'query'});

    $sth->execute();

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

    while ($values = $sth->fetchrow_arrayref())
    {
        my %fields = 
            (map 
                { $query->{'field_names'}->[$_] => $values->[$_] } 
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
                    'fields' => $query->{'field_names'},
                    'for_rss' => 1,
                )),
            'author' => "Unknown",
            'pubDate' => scalar(localtime($date_time)),
            'category' => "Meetings",
        );
    }

    my $rss_data = $rss_feed->as_string();

    undef($rss_feed);

    $sth = $conn->prepare(
        "UPDATE " . $self->get_rss_table_name() . 
        " SET xmltext = ? WHERE relevance = 'all' AND format = 'rss'"
        );

    $sth->execute($rss_data);

    return 0;
}

sub admin_screen
{
    my $self = shift;

    return $self->display_records(
        {
            'all_records' => 1,
            'toolbox' => 1,
        }
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

    my $conn = $self->dbi_connect();

    my $sth = $conn->prepare("SELECT xmltext FROM jobs2_feeds " . 
        "WHERE relevance = 'all' AND format = 'rss'");

    $sth->execute();

    my $values = $sth->fetchrow_arrayref();

    $sth->finish();

    undef($sth);

    $self->header_props(-type => "text/rss");

    $conn->disconnect();

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
    $self->update_rss_feed($self->dbi_connect());
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

    my $conn = $self->dbi_connect();

    my $sth = $conn->prepare($query->{'query'});

    $sth->execute();

    my $values = $sth->fetchrow_arrayref();

    return ($query->{'field_names'}, $values);
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
            'title' => "Add a job to the Linux-IL jobs' list", 
            'header' => "Add a job"
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

sub get_area
{
    my $self = shift;

    return
    {
        label => "Area",
        defaultValue => ($self->query()->param("area") || "Tel Aviv"),
        type => 'select',
        optionsGroup => [
            map { +{ 'label' => $_, 'value' => $_, }, } @{$self->main()->config()->{'areas'}},
        ],
        validators => [],
        $self->get_attribs(),
        hint => $self->main()->get_string('area_hint'),
    }
}

sub shift_f
{
    my $self = shift;
    return $self->f(shift(@{$self->fields_seq()}));
}

sub set_f_auto_field
{
}

sub get_sameline_validator
{
    my $self = shift;
    if ($self->f()->{sameline})
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
    if ($self->f()->{sameline})
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

sub get_f_field_struct
{
    my $self = shift;
    my $f = $self->f();

    return
    {
        label => $f->{'pres'},
        defaultValue => ($self->query()->param($f->{sql}) || ""),
        type => ($f->{sameline} ? "text" : "textarea"),
        validators => $self->get_validators(),
        extraAttributes => $self->get_extra_attributes(),
        # Give the hint if it exists
        $self->get_hint(),
        # Highlight the odd numbered fields
        $self->get_attribs(),
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

sub get_form_fields
{
    my $self = shift;

    $self->set_field('area', $self->get_area());

    while ($self->shift_f())
    {
        $self->set_f_field();
    }

    return $self->fields();
}

1;

