package Shlomif::MiniReporter;

use strict;
use warnings;
use DBI;
use POSIX qw();
use Template;
# Inherit from CGI::Application.
use base 'CGI::Application';
use base 'Class::Accessor';

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

__PACKAGE__->mk_accessors(qw(config));

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

    $self->{'record_tt'} = $tt;

    $self->{'record_rss_tt'} = Template->new(
        {
            'BLOCKS' => 
                {
                    'main' => $config->{'record_rss_template'},
                },
        },
    );

	return 0;
}

sub get_record_template_gen
{
    my $self = shift;

    return $self->{record_tt};
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

sub linux_il_header
{
    my $self = shift;
	my $title = shift;
	my $header = shift;
    my $path = $self->get_path();
	
	my ($ret, $title1, $title2);
	
	if ($title)
	{
		$title1 = "<title>" . $title . "</title>\n";
	}
	else
	{	
		$title1 = "";
	}
	
	if ($header)
	{	
		$title2 = "<h1>" . $header . "</h1>\n";
	}
	else
	{
		$title2 = "";
	}

    my $path_to_root = $self->get_path_to_root();

    my $index_rss = $self->get_rss_table_name() ? 
        qq(<link rel="alternate" title="Better SCM RSS Feed" href="./${path_to_root}index.rss" type="application/rss+xml" />) :
        "";

	$ret .= <<"EOF"
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<?xml version="1.0" encoding="iso-8859-1"?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
<head>
$title1
<link rel="stylesheet" href="./${path_to_root}style.css" type="text/css" />
$index_rss
</head>
<body>
<p>
<a href="/" title="Back to the IGLU Homepage"><img 
    src="/images/IGLU-banner.jpg" 
    width="499" height="86" 
    alt="IGLU - Israeli Group of Linux Users" 
    style="border : 0" /></a>
</p>
<p style="margin-bottom : 2em">[<a href="/">Home</a> |
<a href="/IGLU/">News</a> |
<a href="/about.shtml">About</a> |
<a href="/faq/">FAQ</a> |
<a href="/mailing-lists/">Mailing Lists</a> |
<a href="/events/">Events</a> |
<a href="/faq/cache/52.html">Help!</a> |
<a href="/faq/cache/8.html">Hebrew</a>]</p>

$title2	
EOF
	;
	
	return $ret;
}

sub linux_il_footer
{
    my $ret;
    
    $ret .= <<'EOF';
<hr />
<div class="footer">
<p>For more info or
for website remarks mail the 
<a href="mailto:webmaster@iglu.org.il"><em>webmasters</em></a>.
</p>
<p>
All Trademarks and copyrights are owned by their respective owners, Linux is a Tradmark of Linus Torvalds.
</p>
<p>
The information contained herein is CopyLeft IGLU, you are granted permission to
copy it and distribute it.
</p>
</div>
</body>
</html>
EOF

	;
    
    return $ret;
}

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

    my $ret = "";
    
    my $title = $self->get_string('main_title');
    
    $ret .= $self->linux_il_header($title, $title);
    
    $ret .= <<'EOF'
<h3>Search the Database</h3>

<form action="./search/" method="post">

<p>Area: 
<select name="area">
<option selected="selected">All</option>
EOF

    ;

    foreach my $area ($self->get_area_list())
    {
    	$ret .= ( "<option>" . $area . "</option>\n");
    }

    $ret .= <<'EOF';
</select>
</p>
<p>
Keyword from description: <input name="keyword" />
</p>
<p>
<input type="submit" value="Search" />
</p>
</form>
EOF
	;

    $ret .= "<ul>\n";
    $ret .= "<li><a href=\"./search/?all=1\">" . $self->get_string('show_all_records_text') . "</a></li>\n";
    $ret .= "<li><a href=\"./add/\">" . $self->get_string('add_a_record_text') . "</a></li>\n";
    $ret .= "<li><a href=\"./remove/\">" . $self->get_string('remove_a_record_text') . "</a></li>\n" ;
    if ($self->get_rss_table_name())
    {
        $ret .= "<li><a href=\"./index.rss\">Subscribe to our RSS Feed</a></li>\n";
    }
    $ret .= "</ul>\n";

    $ret .= linux_il_footer();

    return $ret;
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
    my $template = $args{'template'} || "record_tt";

    my $vars = { map { $fields->[$_] => htmlize($values->[$_]) } (0 .. $#$values)};

    foreach my $flag (qw(for_rss toolbox))
    {
        if ($args{$flag})
        {
            $vars->{$flag} = 1;
        }
    }

    $vars->{'path_to_root'} = $self->get_path_to_root();

    $self->{$template}->process('main', $vars, \$ret);

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
    		@areas = $area_param;
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
            'areas' => \@areas,
        };
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

    my %args = (@_);

    my $display_toolbox = $args{'toolbox'} || 0;

    my $conn = $self->dbi_connect();

    my $ret = "";

    my %does_area_exists_map = (map { $_ => 1} $self->get_area_list());

    $ret .= $self->linux_il_header("Search Results", "Search Results");

    my $query = $self->construct_fetch_query(\%args);

    my $sth = $conn->prepare($query->{'query'});

    $sth->execute();

    my (%areas_jobs);

    foreach my $a ($self->get_area_list())
    {
    	$areas_jobs{$a} = [ ];
    }

    my ($string);

    my $values;

    while ($values = $sth->fetchrow_arrayref())
    {
        my $string =
            $self->render_record(
                'values' => $values,
                'fields' => $query->{'field_names'},
                'toolbox' => $display_toolbox,
            );

        push @{$areas_jobs{$values->[0]}}, $string;
    }

    AREA_LOOP: foreach my $area (@{$query->{'areas'}})
    {
        # Check if the area is a valid one and if not skip this 
        # iteration.
        if (!exists($does_area_exists_map{$area}))
        {
            next AREA_LOOP;
        }
    	$ret .= "<h2>" . $area . "</h2>\n\n";

    	$ret .= join("", @{$areas_jobs{$area}});
    }

    $ret .= linux_il_footer();

    $conn->disconnect();

    return $ret;
}

sub search_results
{
    my $self = shift;

    my $q = $self->query();

    my $all_param = $q->param("all") || "";

    my $keyword_param = $q->param("keyword") || "";

    my $area_param = $q->param("area") || "";

    return $self->display_records(
        'all_records' => $all_param,
        'keyword' => $keyword_param,
        'area_choice' => $area_param,
    );
}

sub get_form_fields
{
    my $self = shift;

    my $q = $self->query();

    my $config = $self->{config};

    my %fields = ();

    my $field_idx = 0;

    my $get_alternate_style = sub {
        my $ret = (($field_idx % 2 == 1) ? "hilight" : "hilight2");

        $field_idx++;
        
        return $ret;
    };

    my $get_attribs = sub {
        my $class = $get_alternate_style->();
        return ('container_attributes' => 
                { 'class' => $class, },
                'hint_container_attributes' => 
                { 'class' => "$class space", },
               );
    };
   
    $fields{area} = {
        label => "Area",
        defaultValue => ($q->param("area") || "Tel Aviv"),
        type => 'select',
        optionsGroup => [
            map { +{ 'label' => $_, 'value' => $_, }, } @{$config->{'areas'}},
        ],
        validators => [],
        $get_attribs->(),
        hint => $self->get_string('area_hint'),
    };

    # Number of characters for the input tag or textarea to be as wide;
    my $input_length = 40;
    my $input_height = 10;

    

    foreach my $f ($self->get_fields())
    {
        if ($f->{'gen'}->{'auto'})
        {
            next;
        }

        $fields{$f->{sql}} = 
        {
            label => $f->{'pres'},
            defaultValue => ($q->param($f->{sql}) || ""),
            type => ($f->{sameline} ? "text" : "textarea"),
            validators => 
            [ 
                ($f->{sameline} ? 
                (
                    WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
                    "No newlines allowed",
                    '^([^\n\r]*)$'
                    ), 
                ): 
                ()),
                ($f->{len} ?
                (
                    WWW::FieldValidator->new(
                        WWW::FieldValidator::MAX_STR_LENGTH,
                        "$f->{pres} is limited to $f->{len} characters",
                        $f->{len}
                    ),
                ) :
                ()),
            ],
            extraAttributes => 
                ($f->{sameline} ? 
                    " size=\"$input_length\" " :
                    " cols=\"$input_length\" rows=\"$input_height\""
                ),
            # Give the hint if it exists
            (exists($f->{hint}) ? (hint => $f->{hint}) : ()),
            # Highlight the odd numbered fields
            $get_attribs->(),
        };
    }

    return \%fields;
}

sub get_form_fields_sequence
{
    my $self = shift;

    my $config = $self->{config};

    my @ret;

    # Don't forget to put the area - otherwise WWW::Form won't display it.
    push @ret, 'area';
    
    foreach my $f ($self->get_fields())
    {
        if ($f->{'gen'}->{'auto'})
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

sub get_form_html
{
    my $self = shift;

    my $form = shift;

    my $params = shift;

    my $ret = "";

    $ret .= "<p class=\"warning\"><b>Note:</b> all entries must be in English.".
            "(or else they won't be displayed correctly</p>";

    $ret .= $form->get_form_HTML(@$params);

    return $ret;
}

sub add_form
{
    my $self = shift;

    my $q = $self->query();

    # return join("\n<br />\n", (map { "$_ = " . $q->param($_) } $q->param()));
    
    my $config = $self->{config};

    my $id = 0;

    # Prepare the insert statement

    my (@values, @field_names);

    foreach my $a ($self->get_fields())
    {
    	push @field_names, $a->{'sql'};
        my $v;
        if (exists($a->{'gen'}))
        {
            $v= $a->{'gen'}->{callback}->($q->param($a->{'sql'}));
        }
        else
        {
    	    $v = $q->param($a->{'sql'});
        }
        push @values, $v;
    }

    my $ret = "";

    my $form = $self->get_form();

    $form->validate_fields();
    
    my $valid_params = $form->is_valid();

    my $no_cgi_params = (scalar($q->param()) ? 0 : 1);

    if ($q->param('preview') || (! $valid_params) || $no_cgi_params)
    {
        if ($no_cgi_params)
        {
            $ret .= $self->linux_il_header("Add a job to the Linux-IL jobs' list", "Add a job");
        }
        elsif ($valid_params)
        {
            $ret .= $self->linux_il_header($self->get_string('preview_result_title'), "Preview the Added Record");
        }
        else
        {
            $ret .= $self->linux_il_header("Invalid Parameters Entered", 
            "Invalid Parameters Entered");
        }

        if (! $no_cgi_params)
        {
            $ret .= 
                $self->render_record(
                    'fields' => \@field_names,
                    'values' => \@values,
                );
        }

        $ret .= $self->get_form_html($form,
            [
                'action' => "",
                'buttons' =>
                [
                    {
                        submit_label => "Preview", 
                        submit_name => "preview",
                        submit_class => "preview",
                    },
                    (($valid_params && ! $no_cgi_params)?
                    ({
                        submit_label => "Submit",
                        submit_name => "submit",
                    },) :
                    (),
                    )
                ],
                attributes => { 'class' => "myform" },
            ]
         );
    }
    else
    {
        $ret .= $self->linux_il_header($self->get_string('add_result_title'), "Success");

        my $conn = $self->dbi_connect();
        my $query_str = "INSERT INTO " . $config->{'table_name'} .
            " (" . join(",", "id", "status", "area", @field_names) . ") " .
            " VALUES ($id, 1, '" . $q->param("area") . "'," .  join(",", (map { $conn->quote($_); } @values)) . ")";

        $conn->do($query_str);

        $self->update_rss_feed($conn);

        $conn->disconnect();

        $ret .= <<'EOF';
The job was added to the database.<br>
<br>
EOF
        ;

        $ret .= "<a href=\"../\">" . $self->get_string('add_back_link_text') . "</a>\n";
    }

    $ret .= linux_il_footer();

    return $ret;
}

sub css_stylesheet
{
    my $self = shift;

    local (*I);
    open I, "<style.css";
    $self->header_props(-type => "text/css");
    my $output = join("", <I>);
    close(I);
    
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

        my $item_url = $self->get_url_to_main() . "show-record/" . $fields{'id'} . "/";
    
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
       'all_records' => 1,
       'toolbox' => 1,
    );
}

sub remove
{
    my $self = shift;

    my $config = $self->{config};
    
    my $service = $self->get_string('service');

    my $ret = "";

    $ret .= $self->linux_il_header($self->get_string('remove_result_title'), "Remove a Job");

    $ret .= <<"EOF" ;
<p>
In order to remove your entry from the $service, please send a personal
E-mail to <a href="mailto:webmaster\@iglu.org.il">webmaster\@iglu.org.il</a>
specifying the entry you wish to remove. (please be as clear as possible,
and as detailed as necessary.) We will disable it (so it won't be seen)
and let you know about it.
</p>
<p>
We regret the fact that there isn't an automated mechanism for disabling 
an entry. However, this will require much more work to be conducted in the
$service. This may be done in the future, but at the moment the gain
is far below the effort that would need to be invested.
</p>
EOF

    ;
    
    $ret .= linux_il_footer();

    return $ret;
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
    $self->get_path() =~ /\/show-record\/(\d+)\// or
        return $self->redirect_to_main();
    my $record_id = $1;

    my $ret = "";
    $ret .= $self->linux_il_header();

    my $query = $self->construct_fetch_query({'id' => $record_id});

    my $conn = $self->dbi_connect();

    my $sth = $conn->prepare($query->{'query'});

    $sth->execute();

    my $values = $sth->fetchrow_arrayref();

    if (!defined($values))
    {
        $ret .= "<h1>Record not found - sorry</h1>";
    }
    else
    {
        $ret .= $self->render_record(
                'values' => $values,
                'fields' => $query->{'field_names'},
                'toolbox' => 0,
            );
    }

    $ret .= $self->linux_il_footer();

    return $ret;
}
1;


