package MediaWiki::Parser::Test::IsTokens;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = (qw(is_tokens_deeply));

use Test::More;

# Token position (open/close/etc.)
sub token_pos
{
    my $token = shift;

    return   $token->is_opening() ? "open" 
           : $token->is_closing() ? "close"
           : $token->is_standalone() ? "standalone"
           : "unknown";
}

my %pos_tokens_map =
(
    "paragraph" => "para",
    "italics" => "italics",
    "bold" => "bold",
    "linebreak" => "linebreak",
    "signature" => "signature",
    "html-tag" => "html",
    "heading" => "heading",
    "code_block" => "code_block",
    "listitem" => "listitem",
    "list" => "list",
);

my %has_subtype = (map { $_ => 1 } qw(signature list));

sub get_token_representation
{
    my $token = shift;

    if (exists($pos_tokens_map{$token->type()}))
    {
        my $ret =
        {
            t => $pos_tokens_map{$token->type()},
            p => token_pos($token),
        };

        if ($token->is_implicit())
        {
            $ret->{implicit} = 1;
        }

        if (exists($has_subtype{$token->type()}) && ($ret->{p} ne "close"))
        {
            $ret->{st} = $token->subtype();
        }

        if ($token->type() eq "html-tag")
        {
            $ret->{helem} = $token->element_name();
        }
        elsif ($token->type() eq "heading")
        {
            if ($token->is_opening())
            {
                $ret->{level} = $token->level();
            }
        }

        return $ret;
    }
    elsif ($token->type() eq "text")
    {
        return { text => $token->text() };
    }
    else
    {
        return "UNKNOWN_TOKEN";
    }
}

sub is_tokens_deeply
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($parser, $expected_tokens, $blurb) = @_;

    my @got_tokens;

    while (defined(my $token = $parser->get_next_token()))
    {
        push @got_tokens, get_token_representation($token);
    }

    if (defined(scalar($parser->get_next_token())))
    {
        ok(0, "$blurb - does not return undef twice at end");
    }
    else
    {
        is_deeply(
            \@got_tokens,
            $expected_tokens,
            $blurb
        );
    }
}

1;
