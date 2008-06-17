package Test::XML::Ordered;

use strict;
use warnings;

use XML::LibXML::Reader;

use Test::More;

use base 'Exporter';

use vars '@EXPORT_OK';

@EXPORT_OK = (qw(is_xml_ordered));

sub new
{
    my $class = shift;
    my $self = {};

    bless $self, $class;

    $self->_init(@_);

    return $self;
}

sub _got
{
    return shift->{got_reader};
}

sub _expected
{
    return shift->{expected_reader};
}

sub _init
{
    my ($self, $args) = @_;

    $self->{got_reader} =
        XML::LibXML::Reader->new(@{$args->{got_params}});
    $self->{expected_reader} =
        XML::LibXML::Reader->new(@{$args->{expected_params}});

    $self->{diag_message} = $args->{diag_message};

    return;
}

sub _next_elem
{
    my $self = shift;

    $self->_got->read();
    $self->_expected->read();

    return;
}

sub _compare_loop
{
    my $self = shift;

    my $calc_prob = sub {
        my $args = shift;

        if (!exists($args->{param}))
        {
            die "No 'param' specified.";
        }
        return 
        {
            verdict => 0,
            param => $args->{param},
        }
    };

    while ($self->_got->depth() && $self->_expected->depth())
    {
        my $type = $self->_got->nodeType();
        if ($type ne $self->_expected->nodeType())
        {
            return $calc_prob->({param => "nodeType"});
        }
        elsif ($type == XML_READER_TYPE_TEXT())
        {
            my $got_text = $self->_got->value();
            my $expected_text = $self->_expected->value();

            foreach my $t ($got_text, $expected_text)
            {
                $t =~ s{\A\s+}{}ms;
                $t =~ s{\s+\z}{}ms;
                $t =~ s{\s+}{ }ms;
            }
            return $calc_prob->({param => "text"});
        }
        elsif ($type == XML_READER_TYPE_ELEMENT())
        {
            if ($self->_got->name() ne $self->_expected->name())
            {
                return $calc_prob->({param => "element_name"});
            }
        }
    }
    continue
    {
        $self->_next_elem();
    }

    return { verdict => 1};
}

sub _get_diag_message
{
    my ($self, $status_struct) = @_;

    if ($status_struct->{param} eq "nodeType")
    {
        return 
            "Got: " . $self->_got->nodeType(). " at " . $self->_got->lineNumber() . " ; Expected: " . $self->_expected->nodeType() . " at " .$self->_expected->lineNumber();
    }
    elsif ($status_struct->{param} eq "text")
    {
        return 
            "Texts differ: Got at " . $self->_got->lineNumber(). " ; Expected at ". $self->_expected->lineNumber();
    }
    elsif ($status_struct->{param} eq "element_name")
    {
        return
            "Got name: " . $self->_got->name(). " at " . $self->_got->lineNumber() . 
            " ; " . 
            "Expected name: " . $self->_expected->name() . " at " .$self->_expected->lineNumber();
    }
    else
    {
        die "Unknown param";
    }
}

sub compare
{
    local $Test::Builder::Level = $Test::Builder::Level+1;

    my $self = shift;

    $self->_next_elem();

    my $status_struct = $self->_compare_loop();
    my $verdict = $status_struct->{verdict};

    if (!$verdict)
    {
        diag($self->_get_diag_message($status_struct));
    }

    return ok($verdict, $self->{diag_message});
}

sub is_xml_ordered
{
    local $Test::Builder::Level = $Test::Builder::Level+1;

    my ($got_params, $expected_params, $message) = @_;

    my $comparator =
        Test::XML::Ordered->new(
            {
                got_params => $got_params,
                expected_params => $expected_params,
                diag_message => $message,
            }
        );

    return $comparator->compare();
}

1;

