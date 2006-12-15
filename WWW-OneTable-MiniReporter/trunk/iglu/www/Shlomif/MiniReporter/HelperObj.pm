package Shlomif::MiniReporter::HelperObj;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(
    main
));

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->_initialize(@_);
    return $self;
}

sub _initialize
{
    my ($self, $args) = @_;
    $self->main($args->{'main'});

    return 0;
}

sub query
{
    my $self = shift;
    return $self->main()->query();
}

sub _get_dbh
{
    my $self = shift;
    return $self->main()->_get_dbh();
}

sub detach
{
    my $self = shift;
    $self->main(undef);
}

1;

