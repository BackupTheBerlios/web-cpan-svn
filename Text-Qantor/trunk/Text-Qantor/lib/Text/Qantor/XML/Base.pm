package Text::Qantor::XML::Base;

use strict;
use warnings;

=head1 NAME

Text::Qantor::XML::Base - base class for Text::Qantor::XML

=head1 METHODS

=head2 $package->new({%args});

Constructs a new package

=cut

sub new
{
    my $class = shift;
    my $self = {};

    bless $self, $class;

    $self->_init(@_);

    return $self;
}

1;

