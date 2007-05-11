package XML::Grammar::Screenplay::FromProto;

use strict;
use warnings;

use Carp;

use base 'XML::Grammar::Screenplay::Base';

use XML::Writer;
use Parse::RecDescent;
use HTML::Entities ();

__PACKAGE__->mk_accessors(qw(
    _filename
    _writer
));

=head1 NAME

XML::Grammar::Screenplay::FromProto - module that converts well-formed
text representing a Screenplay to an XML format.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

sub _init
{
    my ($self, $args) = @_;

    $self->_filename($args->{source}->{file}) or
        confess "Wrong filename given.";
}

=head2 $self->convert()

Converts to XML and returns it.

=cut

sub _calc_grammar
{
    my $self = shift;

    return <<'EOF';

start : text  {$thisparser->{ret} = $item[1]; }

text: tag { $item[0] = $item[1]; }
      | space { +{ 'empty' => 1} }

tag: space openingtag space text space closingtag space
     {
        my (undef, $open, undef, $inside, undef, $close) = @item[1..$#item];
        if ($open->{name} ne $close->{name})
        {
            Carp::confess("Tags do not match: $open->{name} and $close->{name}");
        }
        $item[0] = { 'tag' => $open->{name}, 'attrs' => $open->{attrs}, 'inside' => $inside };
     }

openingtag: '<' id attribute(s) '>'
    { $item[0] = { 'name' => $item[2], 'attrs' => $item[3] }; }

closingtag: '</' id '>'
    { $item[0] = { 'name' => $item[2], }; }

attribute: space id '="' attributevalue '"' space
    { $item[0] = { 'key' => $item[2] , 'value' => $item[4] }; }

attributevalue: /[^"]+/
    { $item[0] = HTML::Entities::decode_entities($item[1]); }

space: /\s*/

id: /[a-zA-Z_\-]+/

EOF
}

sub _write_scene
{
    my ($self, $args) = @_;

    my $scene = $args->{scene};

    my $tag = $scene->{tag};
    
    if (($tag eq "s") || ($tag eq "scene"))
    {
        my ($id) = (grep { $_->{key} eq "id" } @{$scene->{attrs}});

        if (!defined($id))
        {
            confess "Unspecified id for scene!";
        }
        $self->_writer->startTag("scene", id => $id->{value});
        
        my $inside = $scene->{inside};

        if ($inside->{empty})
        {
            # Do nothing;
        }
        else
        {
            $self->_write_scene({scene => $inside});
        }

        $self->_writer->endTag();
    }
    else
    {
        confess "Improper scene tag - should be '<s>' or '<scene>'!";
    }

    return;
}

sub convert
{
    my $self = shift;

    my $parser = Parse::RecDescent->new($self->_calc_grammar());

    open my $in, "<", $self->_filename();
    my $contents;

    {
        local $/;
        $contents = <$in>;
    }
    close($in);

    $parser->start($contents);

    my $tree = $parser->{ret};

    my $buffer = "";
    my $writer = XML::Writer->new(OUTPUT => \$buffer, ENCODING => "utf-8",);

    $writer->xmlDecl("utf-8");
    $writer->doctype("document", undef, "screenplay-xml.dtd");
    $writer->startTag("document");
    $writer->startTag("head");
    $writer->endTag();
    $writer->startTag("body");

    # Now we're inside the body.
    $self->_writer($writer);

    $self->_write_scene({scene => $tree});

    # Ending the body
    $writer->endTag();

    $writer->endTag();
    
    return $buffer;
}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-xml-grammar-screenplay at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Grammar-Screeplay>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11.

=cut

1;

