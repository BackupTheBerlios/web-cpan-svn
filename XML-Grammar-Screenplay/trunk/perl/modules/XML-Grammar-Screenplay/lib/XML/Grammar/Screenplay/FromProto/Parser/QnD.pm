package XML::Grammar::Screenplay::FromProto::Parser::QnD;

use strict;
use warnings;

use Moose;

extends(
    'XML::Grammar::Screenplay::FromProto::Parser',
    'XML::Grammar::Fiction::FromProto::Parser::LineIterator',
);

use XML::Grammar::Screenplay::FromProto::Nodes;

sub _with_curr_line
{
    my ($self, $sub_ref) = @_;

    return $sub_ref->($self->curr_line_ref());
}

sub _init
{
    my $self = shift;

    return 0;
}

sub _start
{
    my $self = shift;

    return $self->_parse_top_level_tag();
}

my $id_regex = '[a-zA-Z_\-]+';


sub _new_node
{
    my $self = shift;
    my $args = shift;

    # t == type
    my $class = 
        "XML::Grammar::Screenplay::FromProto::Node::"
        . delete($args->{'t'})
        ;

    return $class->new(%$args);
}

sub _create_elem
{
    my $self = shift;
    my $open = shift;

    my $children = @_ ? shift(@_) : $self->_new_empty_list();

    return
        $self->_new_node(
            {
                t => "Element",
                name => $open->{name},
                children => $children,
                attrs => $open->{attrs},
            }
        );
}

sub _new_empty_list
{
    my $self = shift;
    return $self->_new_list([]);
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

sub _parse_opening_tag
{
    my $self = shift;

    my $l = $self->curr_line_ref();

    if ($$l !~ m{\G<($id_regex)}g)
    {
        Carp::confess("Cannot match opening tag at line " . $self->line_num());
    }

    my $id = $1;

    my @attrs;

    while ($$l =~ m{\G\s*($id_regex)="([^"]+)"\s*}cg)
    {
        push @attrs, { 'key' => $1, 'value' => $2, };
    }

    my $is_standalone = 0;

    if ($$l =~ m{\G\s*/\s*>}cg)
    {
        $is_standalone = 1;
    }
    elsif ($$l !~ m{\G>}g)
    {
        Carp::confess (
            "Cannot match the \">\" of the opening tag at line " 
            . $self->line_num()
        );
    }

    return
    {
        name => $id,
        is_standalone => $is_standalone,
        line => $self->line_num(),
        attrs => \@attrs,
    };
}

sub _parse_closing_tag
{
    my $self = shift;

    if (${$self->curr_line_ref()} !~ m{\G</($id_regex)>}g)
    {
        Carp::confess("Cannot match closing tag at line ". $self->line_num());
    }

    return
    {
        name => $1,
    };
}

sub _parse_text
{
    my $self = shift;

    my @ret;
    while (defined(my $unit = $self->_parse_text_unit()))
    {
        push @ret, $unit;
    }

    # If it's whitespace - return an empty list.
    if ((scalar(@ret) == 1) && (ref($ret[0]) eq "") && ($ret[0] !~ m{\S}))
    {
        return $self->_new_empty_list();
    }

    return $self->_new_list(\@ret);
}

sub _consume_paragraph
{
    my $self = shift;

    $self->skip_multiline_space();

    return $self->_parse_inner_text();
}

sub _parse_inner_desc
{
    my $self = shift;

    my $start_line = $self->line_num();

    # Skip the opening square bracket - '['
    ${$self->curr_line_ref()} =~ m{\G\[}g;

    my $inside = $self->_parse_inner_text();

    if (${$self->curr_line_ref()} !~ m{\G\]}g)
    {
        Carp::confess (
            "Inner description that started on line $start_line did "
            . "not terminate with a \"]\"!"
        );
    }

    return
        $self->_new_node(
            {
                t => "InnerDesc",
                start => $start_line,
                children => $self->_new_list($inside),
            }
        );
}

sub _parse_inner_tag
{
    my $self = shift;

    my $open = $self->_parse_opening_tag();

    if ($open->{is_standalone})
    {
        $self->skip_multiline_space();

        return $self->_create_elem($open);
    }

    my $inside = $self->_parse_inner_text();

    my $close = $self->_parse_closing_tag();

    if ($open->{name} ne $close->{name})
    {
        Carp::confess("Opening and closing tags do not match: " 
            . "$open->{name} and $close->{name} on element starting at "
            . "line $open->{line}"
        );
    }
    return $self->_create_elem($open, $self->_new_list($inside));
}

sub _determine_tag
{
    my $self = shift;

    my $l = $self->curr_line_ref();

    return
          ($$l =~ m{\G\[}) ? "open_desc"
        : ($$l =~ m{\G\&}) ? "entity"
        : ($$l =~ m{\G(?:</|\])}) ? "close"
        : ($$l =~ m{\G<}) ? "open_tag"
        : undef
        ;
}

sub _parse_inner_text
{
    my $self = shift;

    my @contents;

    my $start_line = $self->line_num();

    my $curr_text = "";

    CONTENTS_LOOP:
    while (${$self->curr_line_copy()} ne "\n")
    {
        # We need this to avoid appending the rest of the first line 
        my $l = $self->curr_line_ref();

        # Apparently, perl does not always returns true in this
        # case, so we need the defined($1) ? $1 : "" workaround.
        $$l =~ m{\G([^\<\[\]\&]*)}cgms;

        $curr_text .= (defined($1) ? $1 : "");

        my $which_tag = $self->_determine_tag();

        push @contents, $curr_text;

        $curr_text = "";

        if (!defined($which_tag))
        {
            # Do nothing - a tag was not detected.
        }
        else
        {
            if (($which_tag eq "open_desc") || ($which_tag eq "open_tag"))
            {
                push @contents, 
                (($which_tag eq "open_tag")
                    ? $self->_parse_inner_tag()
                    : $self->_parse_inner_desc()
                );
                # Avoid skipping to the next line.
                # Gotta love teh Perl!
                redo CONTENTS_LOOP;
            }
            elsif ($which_tag eq "close")
            {
                last CONTENTS_LOOP;
            }
            elsif ($which_tag eq "entity")
            {
                if (${$self->curr_line_ref()} !~ m{\G(\&\w+;)}g)
                {
                    Carp::confess("Cannot match entity (e.g: \"&quot;\") at line " .
                        $self->line_num()
                    );
                }

                push @contents, HTML::Entities::decode_entities($1);

                redo CONTENTS_LOOP;
            }
        }
    }
    continue
    {
        if (!defined(${$self->next_line_ref()}))
        {
            Carp::confess "End of file in an addressing paragraph starting at $start_line";
        }
    }

    if (length($curr_text) > 0)
    {
        push @contents, $curr_text;
    }

    return \@contents;
}

# TODO : _parse_saying_first_para and _parse_saying_other_para are
# very similar - abstract them into one function.
sub _parse_saying_first_para
{
    my $self = shift;

    if (${$self->curr_line_ref()} !~ /\G([^:\n\+]+): /cgms)
    {
        Carp::confess("Cannot match addressing at line " . $self->line_num());
    }

    my $sayer = $1;

    if ($sayer =~ m{[\[\]]})
    {
        Carp::confess("Tried to put an inner-desc inside an addressing at line " . $self->line_num());
    }

    my $saying_inner_text = $self->_parse_inner_text();

    return
    +{
        character => $sayer,
        para => $self->_new_para($saying_inner_text),
    };
}

sub _parse_saying_other_para
{
    my $self = shift;

    $self->skip_multiline_space();

    if (${$self->curr_line_ref()} !~ /\G\++: /cgms)
    {
        return;
    }

    my $what = $self->_parse_inner_text();

    return $self->_new_para($what);
}

sub _parse_speech_unit
{
    my $self = shift;

    my $first = $self->_parse_saying_first_para();

    my @others;
    while (defined(my $other_para = $self->_parse_saying_other_para()))
    {
        push @others, $other_para;
    }

    return
        $self->_new_node({
                t => "Saying",
                character => $first->{character},
                children => 
                    $self->_new_list([ $first->{para}, @others ]),
        });
}

sub _parse_desc_unit
{
    my $self = shift;

    my $start_line = $self->line_num();

    # Skip the opening square bracket - '['
    ${$self->curr_line_ref()} =~ m{\A\[}g;

    my @paragraphs;

    my $is_end = 1;
    my $para;
    PARAS_LOOP:
    while ($is_end && ($para = $self->_consume_paragraph()))
    {
        if (${$self->curr_line_ref()} =~ m{\G\]}cg)
        {
            $is_end = 0;
        }

        push @paragraphs, $para;
    }

    if ($is_end)
    {
        Carp::confess (qq{Description ("[ ... ]") that started on line $start_line does not terminate anywhere.});
    }

    return $self->_new_node({
            t => "Description",
            children => $self->_new_list(
            [
                map { 
                $self->_new_para($_),
                } @paragraphs
            ],),
    });
}

sub _parse_non_tag_text_unit
{
    my $self = shift;

    my $l = $self->curr_line_ref();

    if (pos($$l) == 0)
    {
        if (substr($$l, 0, 1) eq "[")
        {
            return $self->_parse_desc_unit();
        }
        elsif ($$l =~ m{\A[^:]+:})
        {
            return $self->_parse_speech_unit();
        }
        else
        {
            Carp::confess ("Line " . $self->line_num() . 
                " is not a description or a saying."
            );
        }
    }
    else
    {
        Carp::confess ("Line " . $self->line_num() . 
            " has leading whitespace."
            );
    }
}

sub _parse_text_unit
{
    my $self = shift;
    my $space = $self->consume(qr{\s});

    if (${$self->curr_line_ref()} =~ m{\G<})
    {
        # If it's a tag.

        # TODO : implement the comment handling.
        # We have a tag.

        # If it's a closing tag - then backtrack.
        if (${$self->curr_line_ref()} =~ m{\G</})
        {
            return undef;
        }
        else
        {
            return $self->_parse_top_level_tag();
        }
    }
    else
    {
        return $self->_parse_non_tag_text_unit();
    }
}

sub _parse_top_level_tag
{
    my $self = shift;

    $self->skip_multiline_space();

    if (${$self->curr_line_ref()} =~ m{\G<!--}cg)
    {
        my $text = $self->consume_up_to(qr{-->});

        return $self->_new_node({ t => "Comment", text => $text, });
    }

    my $open = $self->_parse_opening_tag();

    $self->skip_multiline_space();

    my $inside = $self->_parse_text();

    $self->skip_multiline_space();

    my $close = $self->_parse_closing_tag();

    $self->skip_multiline_space();

    if ($open->{name} ne $close->{name})
    {
        Carp::confess("Tags do not match: " 
            . "$open->{name} on line $open->{line} "
            . "and $close->{name} on line $close->{line}"
        );
    }
    return $self->_create_elem($open, $inside);
}

sub process_text
{   
    my ($self, $text) = @_;

    $self->setup_text($text);

    return $self->_start();
}

=head1 NAME

XML::Grammar::Screenplay::FromProto::Parser::QnD - Quick and Dirty parser
for the Screenplay-XML proto-text.

B<For internal use only>.

=head1 METHODS

=head2 $self->process_text($string)

Processes the text and returns the parse tree.

=head2 $self->meta()

Leftover from Moose.

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-xml-grammar-screenplay at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Grammar-Screenplay>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11.

=cut

1;

