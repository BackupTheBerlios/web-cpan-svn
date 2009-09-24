package Text::Qantor::Parser;

use strict;
use warnings;

use Text::Qantor::Parser::Elem::Para;
use Text::Qantor::Parser::Elem::ParaList;
use Text::Qantor::Parser::Elem::MacroCall;

use Moose;

{
    use Regexp::Grammars;

    sub parse
    {
        my $self = shift;
        my $args = shift;

        my $text = $args->{'text'};

        my $parser = qr/
            \A <Raw_para>

            <logfile: - > 
            # <debug: on>

            <rule: Input>
                <Text>
            <rule: Text>
                <[Raw_Para]> ** <.Empty_Line>
            <rule: Raw_Para>
                <[Para_Text_Wrapper]>+
            <token: Single_Empty_Line>
                <.Match=(?:^\s*\$)>
            <rule: Empty_Line>
                <.Single_Empty_Line>+
            <rule: Para_Text_Wrapper>
                <Para_Text>
            <rule: Para_Text>
                <Macro_Para_Text>
                    |
                <Plain_Para_Text>
            <rule: Macro_Para_Text>
                <MACRO_START> <MACRO_NAME> <MACRO_BODY_START> <Para_Text> <MACRO_BODY_END>
            <token: MACRO_START> <.MATCH=(\\(?=\w))>
            <token: MACRO_NAME> <MATCH=(\w+)>
            <token: MACRO_BODY_START> <.MATCH=(?:\\\{)>
            <token: MACRO_BODY_END> <.MATCH=(?:\})>

            <token: Plain_Para_Text> <MATCH=([^\\\}\n]+)>
            /xms;

        if ($text =~ $parser)
        {
            return $/{'Input'};
        }
        else
        {
            die "Could not match text!";
        }
    }
}

=head1 NAME 

Text::Qantor::Parser - parser for Qantor.

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 my $qantor_parser = Text::Qantor::Parser->new()

Constructs a new parser instance.

=head2 my $tree = $qantor_parser->parse({text => $text});

Parses $text using the parser.

=cut

1;
