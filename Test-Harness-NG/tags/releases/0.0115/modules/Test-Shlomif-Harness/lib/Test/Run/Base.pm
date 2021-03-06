package Test::Run::Base;

use strict;
use warnings;

=head1 NAME

Test::Run::Base - base class for all of Test::Run.

=head1 DESCRIPTION

This is the base class for all Test::Run classes. It inherits from
L<Class::Accessor> and provides some goodies of its own.

=head1 METHODS

=cut

use base 'Class::Accessor';

use Text::Sprintf::Named;
use Test::Run::Sprintf::Named::FromAccessors;

use Test::Run::Class::Hierarchy (qw(hierarchy_of rev_hierarchy_of));

__PACKAGE__->mk_accessors(qw(
    _formatters
));

=head2 $package->new({%args})

The default constructor. Do not over-ride it. Instead over-ride
L<_initialize()>, which accepts the same arguments on an already constructed
and blessed object reference. It would probably be re-named to _init()
soon.

=cut

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->_formatters({});
    $self->_initialize(@_);
    return $self;
}


=head2 $dest->copy_from($source, [@fields])

Assigns the fields C<@fields> using their accessors based on their values
in C<$source>.

=cut

sub copy_from
{
    my ($dest, $source, $fields) = @_;

    foreach my $f (@$fields)
    {
        $dest->$f($source->$f());
    }

    return;
}

sub _get_formatter
{
    my ($self, $fmt) = @_;

    return
        Text::Sprintf::Named->new(
            { fmt => $fmt, },
        );
}

sub _register_formatter
{
    my ($self, $name, $fmt) = @_;

    $self->_formatters->{$name} = $self->_get_formatter($fmt);

    return;
}

sub _get_obj_formatter
{
    my ($self, $fmt) = @_;

    return
        Test::Run::Sprintf::Named::FromAccessors->new(
            { fmt => $fmt, },
        );    
}

sub _register_obj_formatter
{
    my ($self, $name, $fmt) = @_;

    $self->_formatters->{$name} = $self->_get_obj_formatter($fmt);

    return;
}

sub _format
{
    my ($self, $format, $args) = @_;

    if (ref($format) eq "")
    {
        return $self->_formatters->{$format}->format({ args => $args});
    }
    else
    {
        return $self->_get_formatter(${$format})->format({ args => $args});
    }
}

sub _format_self
{
    my ($self, $format, $args) = @_;

    $args ||= {};

    return $self->_format($format, { obj => $self, %{$args}});
}

=head2 $self->accum_array({ method => $method_name })

This is a more simplistic version of the :CUMULATIVE functionality
in Class::Std. It was done to make sure that one can collect all the
members of array refs out of methods defined in each class into one big 
array ref, that can later be used.

=cut

sub accum_array
{
    my ($self, $args) = @_;

    my $method_name = $args->{method};

    my $class = ((ref($self) eq "") ? $self : ref($self));

    my $hierarchy = hierarchy_of($class);

    my @results;
    foreach my $isa_class (@$hierarchy)
    {
        no strict 'refs';
        my $method = ${$isa_class . "::"}{$method_name};
        if (defined($method))
        {
            push @results, @{$method->($self)};
        }
    }
    return \@results;
}

sub _list_pluralize
{
    my ($self, $noun, $list) = @_;

    return $self->_pluralize($noun, scalar(@$list));
}

sub _pluralize
{
    my ($self, $noun, $count) = @_;

    return sprintf("%s%s",
        $noun,
        (($count > 1) ? "s" : "")
    );
}

=head2 $self->_run_sequence(\@params)

Runs the sequence of commands specified using 
C<_calc__${calling_sub}__callbacks> while passing @params to 
each one. Generates a list of all the callbacks return values.

=cut

sub _run_sequence
{
    my $self = shift;
    my $params = shift || [];

    my $sub = (caller(1))[3];

    $sub =~ s{::_?([^:]+)$}{};

    my $calc_cbs_sub = "_calc__${1}__callbacks";

    return 
    [ 
        map { my $cb = $_; $self->$cb(@$params); }
        @{$self->$calc_cbs_sub(@$params)}
    ];
}

=head2 $package->delegate_methods($field, \@methods)

Delegates the methods listed in @methods (as strings) to the accessor
specified by $field.

=cut

sub delegate_methods
{
    my ($pkg, $field, $methods) = @_;

    no strict 'refs';
    foreach my $method (@$methods)
    {
        *{$pkg."::".$method} =
            do {
                my $m = $method;
                sub { my $self = shift; return $self->$field->$m(@_); };
            };
    }

    return;
}

1;

__END__

=head1 LICENSE

This file is licensed under the MIT X11 License:

http://www.opensource.org/licenses/mit-license.php

=cut

