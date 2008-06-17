package Text::Qantor;

use warnings;
use strict;

use XML::Writer;

=head1 NAME

Text::Qantor - a post-modern Typesetting System.

=head1 VERSION

Version v0.0.1

=cut

use version; our $VERSION = qv('0.0.1');


=head1 SYNOPSIS

    use Text::Qantor;

    my $qantor = Text::Qantor->new();
    
=head1 DESCRIPTION

B<FILL IN>

=head1 FUNCTIONS

=head2 my $qantor = Text::Qantor->new(\%args)

Initialises a new Qantor instance.

=cut

sub new
{
    my $class = shift;
    my $self = {};

    bless $self, $class;

    $self->_init(@_);

    return $self;
}

sub _init
{
    my ($self, $args) = @_;

    return;
}

=head2 $qantor->convert_input_to_xsl_fo({in_fh => \*STDIN, out_fh => \*STDOUT})

Converts the input from the C<in_fh> filehandle to XSL-FO and outputs it to
C<out_fh>.

=cut

sub convert_input_to_xsl_fo
{
    my ($self, $args) = @_;

    my $in_fh = $args->{in_fh};
    my $out_fh = $args->{out_fh};

    my $fo_ns = "http://www.w3.org/1999/XSL/Format";

    my $writer = XML::Writer->new(
        NAMESPACES => 1,
        OUTPUT => $out_fh,
        PREFIX_MAP =>
        {
            $fo_ns => "fo",
        },
        NEWLINES => 1,
        ENCODING => "utf-8",
    );

    $writer->xmlDecl("utf-8");
    $writer->startTag([$fo_ns, "root"]);
   
    $writer->startTag([$fo_ns, "layout-master-set"]);
    $writer->startTag([$fo_ns, "simple-page-master"], "master-name" => "A4");

    $writer->emptyTag([$fo_ns, "region-body"]);

    $writer->endTag(); # layout-master-set
    $writer->endTag(); # simple-page-master

    $writer->startTag([$fo_ns, "page-sequence"], "master-reference" => "A4");
    $writer->startTag([$fo_ns, "flow"], "flow-name" => "xsl-region-body");

    my $para_text = "";

    my $write_para = sub {
        if (length($para_text))
        {
            $writer->startTag([$fo_ns, "block"]);

            $para_text =~ s{\n+\z}{}ms;

            $writer->characters($para_text);

            $writer->endTag();
                $para_text = "";
        }        
    };
    while (my $line = <$in_fh>)
    {
        if ($line eq "\n")
        {
            $write_para->();
        }
        else
        {
            $para_text .= $line;
        }
    }
    $write_para->();

    $writer->endTag(); # flow
    $writer->endTag(); # page-sequence

    $writer->endTag(); # End the root element.

    return;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-qantor at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Qantor>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Qantor


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Qantor>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Qantor>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Qantor>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Qantor>

=back


=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: mit

=cut

1; # End of Text::Qantor
