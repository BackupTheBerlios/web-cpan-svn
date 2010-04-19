package rejects::FromProto_Parser::QnD;

use strict;
use warnings;

=begin Removed

    # If it's whitespace - return an empty list.
    if ((scalar(@ret) == 1) && (ref($ret[0]) eq "") && ($ret[0] !~ m{\S}))
    {
        return $self->_new_empty_list();
    }

    return $self->_new_list(\@ret);

=end Removed

=cut

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

=begin Removed
    if (${$self->curr_line_ref()} =~ m{\G<!--}cg)
    {
        my $text = $self->consume_up_to(qr{-->});

        return $self->_new_node({ t => "Comment", text => $text, });
    }

=end Removed

=cut

