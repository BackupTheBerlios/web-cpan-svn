package Text::Qantor;

use warnings;
use strict;

use Carp;

use XML::Writer;
use Text::Qantor::Parser;

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

    my $parser = Text::Qantor::Parser->new();

    my $doc_tree = $parser->YYParse(yylex => 
        sub {
            return $self->_lexer($args, [@_]);
        },
        yyerror =>
        sub {
            return $self->_parser_error($args, [@_]);
        },
        yydebug => 0x1F,
    );

    foreach my $p (@{$doc_tree->_list()})
    {
        $writer->startTag([$fo_ns, "block"]);

        $writer->characters($p->body());

        $writer->endTag();
    }

    $writer->endTag(); # flow
    $writer->endTag(); # page-sequence

    $writer->endTag(); # End the root element.

    return;
}

sub _lexer
{
    my $self = shift;
    my @ret = $self->_lexer2(@_);

    use Data::Dumper;
    print Dumper(\@ret);
    return @ret;
}

sub _lexer2
{
    my ($self, $args, $yylex_params) = @_;

    my $in_fh = $args->{in_fh};

    my $parser = $yylex_params->[0];

    $parser->YYData->{STATE} ||= "text";

    if ($parser->YYData->{STATE} eq "EOF")
    {
        return ('', undef);
    }

    my $read_line = sub {
        $parser->YYData->{LINE_COUNT}++;
        if (!defined($parser->YYData->{LINE} = <$in_fh>))
        {
            $parser->YYData->{STATE} = "EOF";
            return ['', undef];
        }
        elsif ($parser->YYData->{LINE} =~ m{\A\s*\z})
        {
            return ['EMPTY_LINE', [$parser->YYData->{LINE}, 
                $parser->YYData->{LINE_COUNT}]];
        }
        return;
    };
    

    if (!defined($parser->YYData->{LINE}))
    {
        $parser->YYData->{STATE} = "text";
        if (my $ret = $read_line->())
        {
            return @$ret
        }
    }
    
    while (1)
    {
        my $state = $parser->YYData->{STATE};

        if ($state eq "text")
        {
            if ($parser->YYData->{LINE} =~ m{\G\z}cgms)
            {
                if (my $ret = $read_line->())
                {
                    return @$ret;
                }
            }
            elsif ($parser->YYData->{LINE} =~ m{\G(\\)(?=\w)}cgms)
            {
                $parser->YYData->{STATE} = "after_macro_start";
                return ("MACRO_START", [$1, $parser->YYData->{LINE_COUNT}]);
            }
            elsif ($parser->YYData->{LINE} =~ m{\G(\\\W)}cgms)
            {
                return ("BS_ESCAPE_SEQ", [$1, $parser->YYData->{LINE_COUNT}]);
            }
            elsif ($parser->YYData->{LINE} =~ m{\G(\})}cgms)
            {
                return ("MACRO_BODY_END", [$1, $parser->YYData->{LINE_COUNT}]);
            }
            elsif ($parser->YYData->{LINE} =~ m{\G([^\\\}]+)}cgms)
            {
                return ("TEXT", [$1, $parser->YYData->{LINE_COUNT}]);
            }
        }
        elsif ($state eq "after_macro_start")
        {
            $parser->YYData->{LINE} =~ m{\G(\w+)}cgms;

            my $macro_name = $1;

            $parser->YYData->{STATE} = "after_macro_name";

            return ("MACRO_NAME", [$macro_name, $parser->YYData->{LINE_COUNT}]);
        }
        elsif ($state eq "after_macro_name")
        {
            if ($parser->YYData->{LINE} =~ m{\G(\{)}cgms)
            {
                $parser->YYData->{STATE} = "text";
                return ("MACRO_BODY_START", [$1, $parser->YYData->{LINE_COUNT}]);
            }
            else
            {
                die "No { after macro name in Line No. " . $parser->YYData->{LINE_COUNT} ;
            }
        }
    }
    die "Should not happen."
}

sub _parser_error
{
    my ($self, $args, $yylex_params) = @_;
 
    my $parser = $yylex_params->[0];

    if (exists $parser->YYData->{ERRMSG})
    {
        die $parser->YYData->{ERRMSG};
    }

    Carp::confess("Syntax error.");

    return 1;
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
