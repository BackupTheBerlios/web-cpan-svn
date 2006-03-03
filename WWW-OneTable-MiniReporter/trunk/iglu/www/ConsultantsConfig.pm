package ConsultantsConfig;

use vars qw($config);

use POSIX;

$config = 
{
    'strings' => 
    {
        'main_title' => "Linux-IL Consultants List",
        'add_result_title' => "You were added to the database",
        'add_back_link_text' => "Back to the Consultants List",
        'show_all_records_text' => "Show all the consultants",
        'add_a_record_text' => "Add yourself to the list",
        'preview_result_title' => "Preview your Entry Before Adding",
        'remove_a_record_text' => "Remove an entry from the list",
        'remove_result_title' => "How to Remove an Entry",
        'service' => "consultants list",
        'area_hint' => "The area in Israel where you live.", 
    },
    'dsn' => 'dbi:mysql:test_jobs',
    'table_name' => 'consultants2',
    'areas' => [ "Tel Aviv", "Haifa", "Jerusalem", "North", "South" ],
    'order_by' => "id DESC",
    'fields' =>
    [
        {
            'sql' => "name",
            'pres' => "Name",
            'sameline' => 1,
            'hint' => qq{Your name. Examples: <br />
            "Yossef Cohen"<br />
            "Shlomi Fish"<br />
            "John Doe"<br />},
            'len' => 80,
        },
        {
            'sql' => "knowledge_area",
            'pres' => "Knowledge Areas",
            'sameline' => 0,
            'len' => 65535,
            'hint' => qq{Areas of Knowledge. <br/> Examples:<br />
                "Perl Programming"<br />
                "Postfix Administration"<br />
                "Shell scripting"<br />},
        },
        {
            sql => 'other_os',
            pres => "Other Operating Systems",
            sameline => 1,
            hint => qq{
                Which other operating systems do you know?
            },
            len => 255,
        },
        {
            qw(sql address pres Address sameline 0),
            hint => qq{
                Your address (in the real world). <br />
                Street,City, Zip-code. Optional
            },
            len => 65535,
        },
        {
            qw(sql phone pres Phone sameline 1),
            hint => qq{ 
                The telephone number in which you can be reached.
            },
            len => 30,
        },
        {
            'sql' => "cellphone",
            'pres' => "Cell Phone",
            'sameline' => 1,
            hint => qq{
                Cellular (mobile) Phone number in which you can be
                reached.
            },
            len => 30,
        },
        {
            qw(sql fax pres Fax sameline 1),
            hint => qq{
                Fax number.
            },
            len => 30,
        },
        {    
            qw(sql email pres E-mail sameline 1),
            flags =>
            {
                'email' => 1,
            },
            hint => qq{
                E-mail address where you can be contacted at.
            },
            len => 255,
        },
        {    
            qw(sql website sameline 1),
            'pres' => "Web site",
            hint => qq{
                Your personal web-site.
            },
            len => 255,
        },
        
    ],
    'record_template' => <<EOF
<div class="record[% IF toolbox %] recadmin[% END %]">
<h3>[% name %]</h3>
<p class="data">
<b>Knowledge Areas</b>: <br />
</p>
<div class="desc">
[% knowledge_area %]
</div>
<p>
<b>Other Operating Systems:</b> [% other_os %]
</p>
<p>
<b>Address:</b><br />
</p>
<div class="desc">
[% address %]
</div>
<p>
<b>Phone:</b> [% phone %]<br />
<b>Cellular Phone:</b> [% cellphone %]<br />
<b>Fax:</b> [% fax %]<br />
<b>E-mail:</b> [% email %]<br />
<b>Web-site:</b> [% website %]<br />
</p>
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
