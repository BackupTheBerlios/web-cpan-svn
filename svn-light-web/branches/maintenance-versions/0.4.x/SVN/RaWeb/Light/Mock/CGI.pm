use warnings;
use strict;

package CGI;

# The purpose of this package is to mock the CGI object.

our @new_params;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    $self->initialize(@new_params);
    
    return $self;
}

sub initialize
{
    my $self = shift;

    my (%args) = (@_);

    $self->{'params'} = $args{'params'};
    $self->{'path_info'} = $args{'path_info'};
    $self->{'script_name'} = $args{'script_name'};

    $self->{'out'} = "";
}

sub param
{
    my $self = shift;
    my $param_id = shift;

    return $self->{'params'}->{$param_id};
}

sub path_info
{
    my $self = shift;
    return $self->{'path_info'};
}

sub script_name
{
    my $self = shift;
    return $self->{'script_name'};
}

sub redirect
{
    my $self = shift;
    my $where = shift;
    die +{
        'type' => "redirect",
        'redirect_to' => $where,
    };
}

sub header
{
    my $self = shift;

    my %args = (@_);

    my $type = "text/html";
    if (exists($args{-type}))
    {
        $type = $args{-type};
    }
    
    return "Content-Type: $type\n\n";
}

sub escapeHTML
{
    my $string = shift;
    $string =~ s{&}{&amp;}gso;
    $string =~ s{<}{&lt;}gso;
    $string =~ s{>}{&gt;}gso;
    $string =~ s{"}{&quot;}gso;
    return $string;
}

BEGIN
{
    $INC{'CGI.pm'} = "/usr/lib/perl5/site_perl/5.8.6/CGI.pm",
}

1;

