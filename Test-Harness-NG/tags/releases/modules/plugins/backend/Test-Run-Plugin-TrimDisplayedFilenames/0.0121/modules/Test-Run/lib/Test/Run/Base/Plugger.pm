package Test::Run::Base::Plugger;

use strict;
use warnings;

use Moose;

use MRO::Compat;

extends ("Test::Run::Base");

use Carp;

require UNIVERSAL::require;

=head1 NAME

Test::Run::Base::Plugger - an object class with plug-ins.

=head1 DESCRIPTION

This is a class that abstracts an object class with plugins.

=head1 METHODS

=cut

has '_base' => (is => "rw", isa => "Str");
has '_into' => (is => "rw", isa => "Str");
has '_plugins' => (is => "rw", isa => "ArrayRef");

=head2 $plugger = Test::Run::Base::Plugger->new({base => $base, into => $into})

$base is the base class and $into is the namespace to put everything into.

=cut

sub _init
{
    my ($self, $args) = @_;

    $self->maybe::next::method($args);

    $self->_base($args->{base});
    $self->_into($args->{into});

    $self->_plugins([]);

    $self->_update_ISA();
    
    return 0;
}

sub _update_ISA
{
    my $self = shift;
    
    my $base_class = $self->_base();
    my $into_class = $self->_into();

    my $isa_ref = do { no strict 'refs'; \@{"${into_class}::ISA"} };

    @$isa_ref = ();

    foreach my $plugin (@{$self->_plugins()})
    {
        $plugin->require();
        if ($@)
        {
            die $@;
        }
        push @$isa_ref, $plugin;
    }    

    $base_class->require();
    if ($@)
    {
        die $@
    }

    push @$isa_ref, $base_class;

    return;
}

=head2 $plugger->add_plugins(\@plugins)

Adds @plugins to the list of plugins used by the $into module.

=cut

sub add_plugins
{
    my $self = shift;
    my $more_plugins = shift;

    push @{$self->_plugins()}, @{$more_plugins};

    $self->_update_ISA();
}

=head2 $pluggin->create_new(@args)

Constructs a new instance of $into.

=cut

sub create_new
{
    my $self = shift;

    return $self->_into()->new(@_);
}

=head1 LICENSE

This file is freely distributable under the MIT X11 license.

L<http://www.opensource.org/licenses/mit-license.php>

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>.

=cut

1;

