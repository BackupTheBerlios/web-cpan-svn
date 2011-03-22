package XML::Grammar::Fiction::FromProto::Parser::MGC;

use Moose;

use XML::Grammar::Fiction::Err;
use XML::Grammar::Fiction::Struct::Tag;
use XML::Grammar::Fiction::Event;

=head1 NAME

XML::Grammar::Fiction::FromProto::Parser::MGC - parser for the Fiction-Text
proto-text based on Parser::MGC

B<For internal use only>.

=head1 VERSION

Version 0.1.3

=head1 METHODS

=cut

our $VERSION = '0.1.3';

extends(
    'Parser::MGC',
    'XML::Grammar::Fiction::FromProto::Parser::XmlIterator',
);

sub new
{
    my $class = shift;

    my $self = $class->Parser::MGC::new(patterns => { ws => qr// }, @_);
    
    return $self;
}

sub _get_id_regex
{
    return qr{[a-zA-Z_\-]+};
}


sub _parse_opening_tag_attrs
{
    my ($self, $l) = @_;

    my @attrs;

    my $id_regex = $self->_get_id_regex();

    $l =~ m{^};

    while ($l =~ m{\G\s*($id_regex)="([^"]+)"\s*}cg)
    {
        push @attrs, { 'key' => $1, 'value' => $2, };
    }

    return \@attrs;
}

sub _parse_opening_tag
{
    my ($self) = @_;

    my $id_regex = $self->_get_id_regex();

    my (undef, $tag_name, $attrs, $trail_slash) = $self->expect( 
        qr/<($id_regex)\s*((?:\s+${id_regex}="[^"]+")*)(?:\s*\/\s*)?>/
    );

    return XML::Grammar::Fiction::Struct::Tag->new(
        name => $tag_name,
        is_standalone => (length($trail_slash) > 0),
        # TODO : put something meaningful here
        line => 1,
        attrs => $self->_parse_opening_tag_attrs($attrs),
    );
}

sub _parse_closing_tag
{
    my $self = shift;

    my $id_regex = $self->_get_id_regex();

    if (my (undef, $id) = $self->expect(qr{($id_regex)>}))
    {
        return XML::Grammar::Fiction::Struct::Tag->new(
            name => $id,
            # TODO : replace with a more meaningful line number.
            line => 1,
        );
    }
    else
    {
        $self->throw_text_error(
            'XML::Grammar::Fiction::Err::Parse::WrongClosingTagSyntax',
            "Cannot match closing tag",
        );
    }
}

sub _merge_tag
{
    my ($self, $open_tag, $inner) = @_;

    my $new_elem = 
        $self->_create_elem(
            $open_tag, 
            $self->_new_list($inner),
        );

    return $new_elem;
}

sub _open_close_tag
{
    my ($self) = @_;

    my $id_regex = $self->_get_id_regex();

    my $open = $self->_parse_opening_tag();

    my $inner = $self->scope_of(
        undef, sub { 
            return $self->sequence_of(
                sub {
                    return $self->any_of(
                        sub {
                            my (undef, $text) = $self->expect(qr/([^<]+)/ms);

                            $self->commit;

                            return $self->_new_text([$text]);
                        },
                        sub {
                            $self->_open_close_tag(),
                        },
                    );
                },
            );
        }, qr{</}
    );

    my $close = $self->_parse_closing_tag();

    if ($open->name() ne $close->name())
    {
        XML::Grammar::Fiction::Err::Parse::TagsMismatch->throw(
            error => "Tags do not match",
            opening_tag => $open,
            closing_tag => $close,
        );
    }

    return $self->_merge_tag($open, [$inner]);
}

=head2 $self->parse()

Needed by L<Parser::MGC> - ignore.

=cut

sub parse
{
    my ($self) = @_;

    $self->expect(qr/[\s\n]*/);

    return $self->scope_of(undef,
        sub { return $self->_open_close_tag(); },
        qr/\s*/ms
    );
}

=head2 $self->process_text($string)

processes the text and returns the parse tree.
=cut

sub process_text
{
    my ($self, $string) = @_;

    # Don't skip whitespace.
    $self->{patterns}->{ws} = qr//;

    return $self->from_string($string);
}

1;

=head2 $self->meta()

leftover from moose.

=head1 COPYRIGHT & LICENSE

Copyright 2011 by Paul Evans. 
Copyright 2011 by Shlomi Fish. 

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut
