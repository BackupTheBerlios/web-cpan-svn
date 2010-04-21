package XML::Grammar::Fiction::FromProto::Parser::QnD;

use strict;
use warnings;

use Moose;

extends("XML::Grammar::Fiction::FromProto::Parser::XmlIterator");

has "_in_para" => (isa => "Bool", is => "rw");

use XML::Grammar::Fiction::FromProto::Nodes;

use XML::Grammar::Fiction::Struct::Tag;
use XML::Grammar::Fiction::Err;

=head1 NAME

XML::Grammar::Fiction::FromProto::Parser::QnD - Quick and Dirty parser
for the Fiction-XML proto-text.

B<For internal use only>.

=head1 VERSION

Version 0.0.4

=cut

our $VERSION = '0.0.4';

my $id_regex = '[a-zA-Z_\-]+';

sub _new_node
{
    my $self = shift;
    my $args = shift;

    # t == type
    my $class = 
        "XML::Grammar::Fiction::FromProto::Node::"
        . delete($args->{'t'})
        ;

    return $class->new(%$args);
}

sub _create_elem
{
    my $self = shift;
    my $open = shift;
    my $children = shift || $self->_new_empty_list();

    return
        $self->_new_node(
            {
                t => "Element",
                name => $open->name(),
                children => $children,
                attrs => $open->attrs(),
            }
        );
}

sub _new_list
{
    my $self = shift;
    my $contents = shift;

    return $self->_new_node(
        {
            t => "List",
            contents => $contents,
        }
    );
}

sub _new_para
{
    my $self = shift;
    my $contents = shift;

    return $self->_new_node(
        {
            t => "Paragraph",
            children => $self->_new_list($contents),
        }
    );
}

sub _new_text
{
    my $self = shift;
    my $contents = shift;

    return $self->_new_node(
        {
            t => "Text",
            children => $self->_new_list($contents),
        }
    );
}

sub _new_comment
{
    my $self = shift;
    my $text = shift;

    return $self->_new_node(
        {
            t => "Comment",
            text => $text,
        }
    );
}

sub _parse_opening_tag_attrs
{
    my $self = shift;

    my $l = $self->curr_line_ref();

    my @attrs;

    while (my ($name, $val) = $$l =~ m{\G\s*($id_regex)="([^"]+)"\s*}cg)
    {
        push @attrs, { 'key' => $name, 'value' => $val, };
    }

    return \@attrs;
}

sub _parse_opening_tag
{
    my $self = shift;

    my $l = $self->curr_line_ref();

    if ($$l !~ m{\G<($id_regex)}cg)
    {
        $self->throw_text_error(
            'XML::Grammar::Fiction::Err::Parse::CannotMatchOpeningTag',
            "Cannot match opening tag.",
        );
    }

    my $id = $1;

    my $attrs = $self->_parse_opening_tag_attrs();

    my $is_standalone = 0;
    if ($$l =~ m{\G\s*/\s*>}cg)
    {
        $is_standalone = 1;
    }
    elsif ($$l !~ m{\G>}g)
    {
        $self->throw_text_error(
            'XML::Grammar::Fiction::Err::Parse::NoRightAngleBracket',
            "Cannot match the \">\" of the opening tag",
        );
    }
    
    return XML::Grammar::Fiction::Struct::Tag->new(
        name => $id,
        is_standalone => $is_standalone,
        line => $self->line_num(),
        attrs => $attrs,
    );
}

sub _parse_closing_tag
{
    my $self = shift;

    my $l = $self->curr_line_ref();

    if ($$l !~ m{\G</($id_regex)>}g)
    {
        $self->throw_text_error(
            'XML::Grammar::Fiction::Err::Parse::WrongClosingTagSyntax',
            "Cannot match closing tag",
        );
    }

    return XML::Grammar::Fiction::Struct::Tag->new(
        name => $1,
        line => $self->line_num(),
    );
}

sub _parse_text
{
    my $self = shift;

    my @ret;
    while (my $unit = $self->_parse_text_unit())
    {
        push @ret, $unit;
        my $type = $unit->{'type'};
        if (($type eq "close") || ($type eq "open"))
        {
            push @ret, @{$self->_events_queue()};
            $self->_events_queue([]);
            return \@ret;
        }
    }

=begin Removed

    # If it's whitespace - return an empty list.
    if ((scalar(@ret) == 1) && (ref($ret[0]) eq "") && ($ret[0] !~ m{\S}))
    {
        return $self->_new_empty_list();
    }

    return $self->_new_list(\@ret);

=end Removed

=cut

}

sub _find_next_inner_text
{
    my $self = shift;

    my $which_tag;
    my $text = "";

    my $l = $self->curr_line_ref();

    # Apparently, perl does not always returns true in this
    # case, so we need the defined($1) ? $1 : "" workaround.
    $$l =~ m{\G([^\<\[\]\&]*)}cgms;

    $text .= (defined($1) ? $1 : "");

    if ($$l =~ m{\G\&})
    {
        $which_tag = "entity";
    }                
    elsif ($$l =~ m{\G(?:</|\])})
    {
        $which_tag = "close";
    }
    elsif ($$l =~ m{\G<})
    {
        $which_tag = "open_tag";
    }

    return ($which_tag, $text);
}


sub _parse_non_tag_text_unit
{
    my $self = shift;

    my $l = $self->curr_line_ref();

    my $text = $self->consume_up_to(qr{(?:\<|^\n?$)}ms);

    $l = $self->curr_line_ref();

    my $ret_elem = $self->_new_text([$text]);
    my $is_para_end = 0;

    # Demote the cursor to before the < of the tag.
    #
    if (pos($$l) > 0)
    {
        pos($$l)--;
        if (substr($$l, pos($$l), 1) eq "\n")
        {
            $is_para_end = 1;
        }
    }
    else
    {
        $is_para_end = 1;
    }

    return
    {
        elem => $ret_elem,
        para_end => $is_para_end,
    };
}

sub _parse_text_unit
{
    my $self = shift;

    if (defined(my $event  = $self->_extract_event()))
    {
        return $event;
    }
    else
    {
        $self->_generate_text_unit_events();
        return $self->_extract_event();
    }
}

sub _generate_tag_event
{
    my $self = shift;

    my $l = $self->curr_line_ref();
    my $orig_pos = pos($$l);

    if (my ($tag_opener) = $$l =~ m{\G(<(?:/)?)}cg)
    {
        # If it's a tag.

        # TODO : implement the comment handling.
        # We have a tag.

        my $is_closing_tag = $tag_opener =~ m{/};

        pos($$l) = $orig_pos;

        $self->_enqueue_event(
            {'type' => ($is_closing_tag ? "close" : "open")}
        );

        return 1;
    }
    else
    {
        return;
    }
}

sub _generate_text_unit_events
{
    my $self = shift;

    $self->skip_multiline_space();

    if (! $self->_generate_tag_event())
    {
        my $is_para = ($self->curr_pos() == 0);

        my $status = $self->_parse_non_tag_text_unit();
        my $elem = $status->{'elem'};
        my $is_para_end = $status->{'para_end'};

        my $in_para = $self->_in_para();
        if ($is_para && !$in_para)
        {
            $self->_enqueue_event({type => "open", tag => "para"});
            $in_para = 1;
        }

        $self->_enqueue_event({type => "elem", elem => $elem});

        if ($is_para_end && $in_para)
        {
            $self->_enqueue_event({ type => "close", tag => "para" });
            $in_para = 0;
        }
    }
    return;
}

sub _handle_open_para
{
    my ($self, $event) = @_;

    my $new_elem = 
        XML::Grammar::Fiction::Struct::Tag::Para->new(
            name => "p",
            is_standalone => 0,
            line => $self->line_num(),
            attrs => [],
        );

    $new_elem->children([]);

    $self->_push_tag($new_elem);

    $self->_in_para(1);

    return;
}

sub _handle_close_para
{
    my ($self, $event) = @_;

    my $open = $self->_pop_tag;

    my $new_elem =
        $self->_new_para(
            $open->detach_children(),
        );

    $self->_add_to_top_tag($new_elem);

    $self->_in_para(0);

    return;
}

sub _handle_event
{
    my ($self, $event) = @_;

    if ($self->_is_event_a_para($event))
    {
        $self->_handle_paragraph_event($event);
    }
    elsif ($self->_is_event_elem($event))
    {
        $self->_handle_elem_event($event);
    }

    return;
}

sub _handle_open_tag
{
    my $self = shift;

    my $open = $self->_parse_opening_tag();

    $open->children([]);

    $self->_push_tag($open);

    return;
}

before '_handle_close_tag' => sub { 
    my $self = shift;

    $self->skip_space();
};

sub _look_ahead_for_tag
{
    my $self = shift;

    my $l = $self->curr_line_copy();

    my $is_tag_cond = ($$l =~ m{\G<}cg);
    my $is_close = $is_tag_cond && ($$l =~ m{\G/}cg);

    return ($is_tag_cond, $is_close);
}

sub _main_loop_iter
{
    my $self = shift;

    if ($self->_look_ahead_for_comment())
    {
        return;
    }

    $self->skip_space();

    $self->_ret_tag(scalar($self->_look_for_and_handle_tag()));

    return;
}

before '_parse_all' => sub {
    my $self = shift;

    $self->skip_space();

    return;
};

=head1 METHODS

=head2 $self->process_text($string)

Processes the text and returns the parse tree.

=head2 $self->meta()

Leftover from Moose.

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-xml-grammar-fiction at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Grammar-Fiction>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11.

=cut

1;

