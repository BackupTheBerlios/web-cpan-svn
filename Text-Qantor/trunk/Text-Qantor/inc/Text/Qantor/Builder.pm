package Text::Qantor::Builder;

use strict;
use warnings;

use base 'Test::Run::Builder';

use File::Spec;

sub ACTION_yapp
{
    my $self = shift;

    my $p = $self->{'properties'};

    system(
        "yapp",
        "-o", File::Spec->catdir($p->{base_dir}, "lib", qw(Text Qantor Parser.pm)),
        "-m", "Text::Qantor::Parser",
        "qantor_grammar.yp",
    );
}

1;

