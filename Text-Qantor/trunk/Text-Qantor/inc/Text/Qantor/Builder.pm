package Text::Qantor::Builder;

use strict;
use warnings;

use base 'Test::Run::Builder';

use File::Spec;

sub ACTION_yapp
{
    my $self = shift;

    my $p = $self->{'properties'};

    my $output = File::Spec->catdir($p->{base_dir}, "lib", qw(Text Qantor Parser.pm));
    my $input = "qantor_grammar.yp";

    if ($self->up_to_date($input, $output))
    {
        return;
    }

    my @cmd = (
        "yapp",
         "-o", $output,
        "-m", "Text::Qantor::Parser",
        $input,
    );

    print join(" ", @cmd), "\n";
    if (system(@cmd))
    {
        die "Yapp Failed";
    }
}

sub ACTION_code
{
    my $self = shift;

    $self->depends_on('yapp');

    return $self->SUPER::ACTION_code();
}

1;

