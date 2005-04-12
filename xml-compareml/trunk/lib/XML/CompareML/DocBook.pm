package XML::CompareML::DocBook;

use strict;
use warnings;

use XML::LibXML::Common qw(:w3c);

use base 'XML::CompareML::Base';

sub print_header
{
    my $self = shift;
    my $o = $self->{o};
    print {*{$o}} <<"EOF";
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN"
"/usr/share/sgml/docbook/xml-dtd-4.1.2/docbookx.dtd"[
]>
<article>

EOF
}

# Do Nothing
sub start_rendering
{
}

# Do Nothing
sub finish_rendering
{
}

sub print_footer
{
    my $self = shift;
    print {*{$self->{o}}} "</article>\n";
}

sub render_section_start
{
    my $self = shift;
    my %args = (@_);

    my $depth = $args{depth};
    my $id = $args{id};
    my $title_string = $args{title_string};
    my $expl = $args{expl};
    my $sub_sections = $args{sub_sections};

    if ($depth)
    {
        $self->out("<section id=\"$id\">\n");
    }

    $self->out("<title>$title_string</title>\n");

    if ($depth == 0)
    {
        if (defined($self->timestamp()))
        {
            $self->out("<articleinfo><date>" . $self->timestamp() .
                "</date></articleinfo>\n");
        }
    }

    if ($expl)
    {
        $self->out("<para>\n" . $self->xml_node_contents_to_string($expl) . "\n</para>\n");
    }
}

sub render_sys_table_start
{
    my ($self,%args) = @_;

    my $title_string = $args{title_string};
    
    $self->out(<<"EOF");
<table frame=\"all\">
<title>Comparison - $title_string</title>
<tgroup cols=\"2\" align=\"left\" colsep=\"1\" rowsep=\"1\">
<colspec colname=\"system\" />
<colspec colname=\"description\" />
<thead>
<row>
<entry><emphasis>System</emphasis></entry>
<entry><emphasis>Description</emphasis></entry>
</row>
</thead>
<tbody>
EOF
}

sub html_to_docbook
{
    my $parent_node = shift;
    my $not_first = shift;
    my @child_nodes = $parent_node->childNodes();
    my $ret = "";

    foreach my $node (@child_nodes)
    {
        if ($node->nodeType() == ELEMENT_NODE())
        {            
            if ($node->nodeName() eq "a")
            {
                $ret .= "<ulink url=\"" . $node->getAttribute("href") . "\">";
            }
            else
            {
                my @attrs = $node->attributes();
                $ret .= "<" . $node->nodeName() . " " . join(" ", map { "$_=\"".$node->getAttribute($_)."\""} @attrs) . ">";
            }
            $ret .= html_to_docbook($node, 1);

            if ($node->nodeName() eq "a")
            {
                $ret .= "</ulink>";
            }
            else
            {
                $ret .= "</" . $node->nodeName() . ">";
            }
        }
        else
        {
            $ret .= $node->toString();
        }
    }
    # Remove leading and trailing space.
    if (1)
    {
        $ret =~ s!^\s+!!mg;
        $ret =~ s/\s+$//mg;
    }
    return $ret;
}

sub render_s_elem
{
    my ($self, $s_elem) = @_;
    return html_to_docbook($s_elem);
}

sub render_sys_table_row
{
    my ($self, %args) = @_;

    $self->out("<row>\n<entry>" . $args{name}. "</entry>\n" .
                "<entry>\n" . $args{desc} . "\n</entry>\n</row>\n");
}

sub render_sys_table_end
{
    my $self = shift;
    $self->out("</tbody>\n</tgroup>\n</table>\n");
}

sub render_section_end
{
    my ($self, %args) = @_;

    my $depth = $args{depth};

    if ($depth)
    {
        $self->out("</section>\n");
    }
}

1;

