use strict;
use warnings;

use List::Util ();

package XML::Grammar::Screenplay::FromProto::Node;

use Moose;

package XML::Grammar::Screenplay::FromProto::Node::Element;

use Moose;

has 'name' => (isa => 'Str', is => 'rw');
has 'children' => (
    isa => 'XML::Grammar::Screenplay::FromProto::Node::List', 
    is => 'rw'
);
has 'attrs' => (isa => 'ArrayRef', is => 'rw');

sub lookup_attr
{
    my ($self, $attr_name) = @_;

    my $pair = List::Util::first { $_->{key} eq $attr_name } (@{$self->attrs()});

    if (!defined($pair))
    {
        return undef;
    }
    else
    {
        return $pair->{value};
    }
}

package XML::Grammar::Screenplay::FromProto::Node::List;

use Moose;

has 'contents' => (isa => "ArrayRef", is => "rw");

package XML::Grammar::Screenplay::FromProto::Node::Text;

use Moose;

extends("XML::Grammar::Screenplay::FromProto::Node");

has 'content' => (isa => "ArrayRef", is => "rw");

package XML::Grammar::Screenplay::FromProto::Node::Saying;

use Moose;

extends("XML::Grammar::Screenplay::FromProto::Node::Text");

has 'character' => (isa => "Str", is => "rw");

package XML::Grammar::Screenplay::FromProto::Node::Description;

use Moose;

extends("XML::Grammar::Screenplay::FromProto::Node::Text");

package XML::Grammar::Screenplay::FromProto::Node::Paragraph;

use Moose;

extends("XML::Grammar::Screenplay::FromProto::Node");

has 'content' => (isa => "Str", is => "rw");

1;


=head1 NAME

XML::Grammar::Screenplay::FromProto::Nodes - contains several nodes for
use in XML::Grammar::Screenplay::FromProto.

=head1 DESCRIPTION

Contains several nodes.

=cut

