package XML::Grammar::Fiction::RendererBase;

use strict;
use warnings;

use Carp;
use File::Spec;

use XML::LibXSLT;

use XML::Grammar::Fiction::ConfigData;

use XML::LibXML;
use XML::LibXSLT;

use Moose;

has '_data_dir' =>
(
    isa => 'Str', 
    is => 'rw',
    lazy => 1,
    init_arg => "data_dir",
    default => sub {
        my $self = shift;

        return $self->_get_default_data_dir();
    },
);
has '_rng' =>
(
    isa => 'XML::LibXML::RelaxNG', 
    is => 'rw',
    lazy => 1,
    default => sub {
        my $self = shift;

        return $self->_get_rng_schema();
    },
);

has '_xml_parser' => 
(
    isa => "XML::LibXML", 
    is => 'rw',
    lazy => 1,
    default => sub {
        return XML::LibXML->new();
    },
);

has '_stylesheet' => 
(
    isa => "XML::LibXSLT::StylesheetWrapper", 
    is => 'rw',
    lazy => 1,
    default => sub {
        my $self = shift;

        return $self->_get_stylesheet();
    },
);

=head1 NAME

XML::Grammar::Fiction::RendererBase - base module for Fiction-XML-to-something
renderers

=head1 VERSION

Version 0.1.1

=cut

our $VERSION = '0.1.1';

=head2 new()

Accepts no arguments so far. May take some time as the grammar is compiled
at that point.

=head2 meta()

Internal - (to settle pod-coverage.).

=cut

sub _get_default_data_dir
{
    my $self = shift;

    return XML::Grammar::Fiction::ConfigData->config('extradata_install_path')->[0];
}

sub _get_rng_schema
{
    my $self = shift;

    return
        XML::LibXML::RelaxNG->new(
            location =>
            File::Spec->catfile(
                $self->_data_dir(), 
                $self->_get_relaxng_base_path(),
            ),
        );
}

sub _get_stylesheet
{
    my $self = shift;

    my $xslt = XML::LibXSLT->new();

    my $style_doc = $self->_xml_parser()->parse_file(
            File::Spec->catfile(
                $self->_data_dir(), 
                $self->_get_xslt_base_path(),
            ),
        );

    return $xslt->parse_stylesheet($style_doc);
}



=head2 generic_translate

=over 4

=item * my $final_source = $converter->generic_translate({source => {file => $filename}, output => "string" })

=item * my $final_source = $converter->generic_translate({source => {string_ref => \$buffer}, output => "string" })

=item * my $final_dom = $converter->generic_translate({source => {file => $filename}, output => "dom" })

=item * my $final_dom = $converter->generic_translate({source => {dom => $libxml_dom}, output => "dom" })

=back

Does the actual conversion. The C<'source'> argument points to a hash-ref with
keys and values for the source. If C<'file'> is specified there it points to the
filename to translate (currently the only available source). If 
C<'string_ref'> is specified it points to a reference to a string, with the
contents of the source XML. If C<'dom'> is specified then it points to an XML
DOM as parsed or constructed by XML::LibXML.

The C<'output'> key specifies the return value. A value of C<'string'> returns 
the XML as a string, and a value of C<'dom'> returns the XML as an 
L<XML::LibXML> DOM object.

=cut

sub _undefize
{
    my $v = shift;

    return defined($v) ? $v : "(undef)";
}

sub _calc_and_ret_dom_without_validate
{
    my $self = shift;
    my $args = shift;

    my $source = $args->{source};

    return
          exists($source->{'dom'})
        ? $source->{'dom'}
        : exists($source->{'string_ref'})
        ? $self->_xml_parser()->parse_string(${$source->{'string_ref'}}) 
        : $self->_xml_parser()->parse_file($source->{'file'})
        ;
}

sub _get_dom_from_source
{
    my $self = shift;
    my $args = shift;
  
    my $source_dom = $self->_calc_and_ret_dom_without_validate($args);

    my $ret_code;

    eval
    {
        $ret_code = $self->_rng()->validate($source_dom);
    };

    if (defined($ret_code) && ($ret_code == 0))
    {
        # It's OK.
    }
    else
    {
        confess "RelaxNG validation failed [\$ret_code == "
            . _undefize($ret_code) . " ; $@]"
            ;
    }

    return $source_dom;
}

sub generic_translate
{
    my ($self, $args) = @_;

    my $source_dom = $self->_get_dom_from_source($args);

    my $stylesheet = $self->_stylesheet();

    my $results = $stylesheet->transform($source_dom);

    my $medium = $args->{output};

    if ($medium eq "string")
    {
        return $stylesheet->output_string($results);
    }
    elsif ($medium eq "dom")
    {
        return $results;
    }
    else
    {
        confess "Unknown medium";
    }
}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-xml-grammar-fiction at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Grammar-Fiction>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11.

=cut

1;

