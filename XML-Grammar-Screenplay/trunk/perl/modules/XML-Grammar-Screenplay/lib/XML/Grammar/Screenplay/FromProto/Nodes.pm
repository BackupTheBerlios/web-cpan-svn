use strict;
use warnings;

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

package XML::Grammar::Screenplay::FromProto::Node::List;

use Moose;

has 'contents' => (isa => "ArrayRef", is => "rw");

1;

=head1 NAME

XML::Grammar::Screenplay::FromProto::Nodes - contains several nodes for
use in XML::Grammar::Screenplay::FromProto.

=head1 DESCRIPTION

Contains several nodes.

=cut

