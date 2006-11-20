package MyConfig;

use vars qw($config);

use POSIX;

sub get_admin_pass
{
    open my $in, "<admin-password.txt"; 
    my $l = <$in>; 
    chomp($l); 
    close($in);
    return $l;
}

$config = 
{
    'strings' => 
    {
        'main_title' => "Linux-IL Jobs Tracker",
        'add_result_title' => "Job was added to the database",
        'add_back_link_text' => "Back to the Jobs Database",
        'show_all_records_text' => "Show all the jobs",
        'add_a_record_text' => "Add a job to the database",
        'preview_result_title' => "Preview the Job Before Adding",
        'remove_a_record_text' => "Remove a Job from the database",
        'remove_result_title' => "Howto Remove a Job",
        'service' => "jobs tracker",
        'area_hint' => "The area in Israel of the employing firm.<br />" . 
                "If the work is from home, select the area of the office.",
        'add_form_title' => "Add a job to the Linux-IL jobs' list", 
        'add_form_header' => "Add a job",
    },
    'admin_password' => get_admin_pass(),
    'dsn' => 'dbi:mysql:test_jobs',
    'table_name' => 'jobs2',
    'encoding' => "iso-8859-1",
    'rss_table_name' => 'jobs2_feeds',
    'areas' => [ "Tel Aviv", "Haifa", "Jerusalem", "North", "South" ],
    'order_by' => "post_date DESC, id DESC",
    'fields' =>
    [
        {
            'sql' => "post_date",
            'pres' => "Post Date",
            'control_type' => "text",
            'gen' => 
                {
                    'auto' => 1,
                    'callback' =>
                        sub {
                            return POSIX::strftime("%Y-%m-%d",localtime(time()));
                        },      
                },
        },
        {
            'sql' => "title",
            'pres' => "Job Title",
            'control_type' => "text",
            'hint' => qq{A short title describing the job. Examples: <br />
            "Perl Programmer"<br />
            "System Administrator"<br />
            "Embedded Linux Developer"<br />
            "Web Designer".<br />},
            'len' => 40,
        },
        {
            'sql' => "workplace",
            'pres' => "Workplace",
            'control_type' => "text",
            'hint' => qq{The name of the company which will employ the 
            nominee. <br />
            <b>Bad entries:</b> "Work from home", <br />
            "Tel Aviv/Haifa/etc."<br />
            "On-site"<br />
            (You can write Confidential.)},
            'len' => 80,
        },
        {
            sql => 'description',
            pres => "Description",
            'control_type' => "textarea",
            hint => qq{
                Describe the job in detail. What it involves, <br/>
                what will the employee do, etc.
            },
            len => 65000,
        },
        {
            'sql' => "requirements",
            'pres' => "Requirements",
            'control_type' => "textarea",
            hint => qq{
                Requirements that the nominee would have to fullfill to<br />
                get the the Job. Examples: "2 years of experience<br />
                in SQL", "A Computer Science or similar B.Sc.",<br />
                "A driver's license", "Teamwork"<br />
            },
            len => 65000,
        },
        {
            'sql' => "address",
            'pres' => "Address",
            'control_type' => "textarea",
            hint => qq{
                The address of the company (in the real world). <br />
                Street,City, Zip-code. Optional
            },
            len => 65000,
        },
        {
            sql => "phone",
            pres => "Phone",
            control_type => "text",
            hint => qq{ 
                The telephone number in which you can be reached.
            },
            len => 30,
        },
        {
            'sql' => "cellphone",
            'pres' => "Cell Phone",
            'control_type' => "text",
            hint => qq{
                Cellular (mobile) Phone number in which you can be
                reached.
            },
            len => 30,
        },
        {
            'sql' => "fax",
            'pres' => "Fax",
            'control_type' => "text",
            hint => qq{
                Fax number where resumes can be sent.
            },
            len => 30,
        },
        {
            'sql' => "email",
            'pres' => "E-mail",
            'control_type' => "text",
            flags =>
            {
                'email' => 1,
            },
            hint => qq{
                E-mail address where you or the company can be contacted at.
            },
            len => 255,
        },
        {
            'sql' => "homepage",
            'pres' => "Homepage",
            'control_type' => "text",
            flags =>
            {
                'url' => 1,
            },
            hint => qq{
                The URL of your company's homepage, where people can learn
                more about your company.
            },
            len => 255,
        },
        {
            'sql' => 'contact_person',
            'pres' => 'Contact Person',
            'control_type' => "text",
            hint => qq{
                Name of the contact person in the company which the <br />
                nomineee should contact.
            },
            len => 100,
        },
    ],
    'record_template' => <<'EOF',
<div class="record[% IF toolbox %] recadmin[% END %]">
<h3>[% title %]</h3>
<p class="posted">
Posted at <b>[% post_date %]</b>
</p>
<p class="data">
<b>Company</b>: [% workplace %]<br />
<b>Area</b>: [% area %]<br />
<b>Job Description:</b><br />
</p>
<div class="desc">
[% description %]
</div>
<p>
<b>Requirements:</b>
</p>
<div class="desc">
[% requirements %]
</div>
<p class="data">
<b>Address:</b> [% address %]<br />
<b>Phone:</b> [% phone %]<br />
<b>Cell Phone:</b> [% cellphone %]<br />
<b>Fax:</b> [% fax %]<br />
<b>E-mail:</b> [% IF email %]<a rel="nofollow" href="mailto:[% email %]">[% email %]</a>[% END %]<br />
<b>Homepage:</b> [% IF homepage %]<a rel="nofollow" href="[% homepage %]">[% homepage %]</a>[% END %]<br />
<b>Contact Person Name:</b> [% contact_person %]<br />
</p>
[% UNLESS for_rss %]
<p>
<a href="[% path_to_root %]show-record/[% id %]/" title="A Permanent URL (until this item is removed or outdated) that describes only this particular item"><b>This Entry's Standalone URL</b></a>
</p>
[% END %]
</div>
[% IF toolbox %]
<div class="recordtoolbox">
<p>
<a href="./edit/?id=[% id %]">Edit</a><br />
[% IF enabled %]
<a href="./disable/?id=[% id %]">Disable</a><br />
[% ELSE %]
<a href="./enable/?id=[% id %]">Enable</a><br />
[% END %]
</p>
</div>
[% END %]
EOF
};

1;
