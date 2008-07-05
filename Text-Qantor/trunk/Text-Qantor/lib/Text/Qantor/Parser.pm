####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package Text::Qantor::Parser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			"\\" => 7,
			"[^\\]+" => 8
		},
		GOTOS => {
			'para_text' => 1,
			'macro_para_text' => 2,
			'input' => 3,
			'text' => 5,
			'plain_para_text' => 4,
			'para' => 6
		}
	},
	{#State 1
		ACTIONS => {
			"^\s*\n" => 10
		},
		GOTOS => {
			'empty_line' => 9
		}
	},
	{#State 2
		DEFAULT => -7
	},
	{#State 3
		ACTIONS => {
			'' => 11
		}
	},
	{#State 4
		DEFAULT => -6
	},
	{#State 5
		ACTIONS => {
			"\\" => 7,
			"[^\\]+" => 8
		},
		DEFAULT => -1,
		GOTOS => {
			'para_text' => 1,
			'macro_para_text' => 2,
			'plain_para_text' => 4,
			'para' => 12
		}
	},
	{#State 6
		DEFAULT => -2
	},
	{#State 7
		ACTIONS => {
			"\w+" => 14
		},
		GOTOS => {
			'macro_ident' => 13
		}
	},
	{#State 8
		DEFAULT => -10
	},
	{#State 9
		DEFAULT => -4
	},
	{#State 10
		DEFAULT => -5
	},
	{#State 11
		DEFAULT => 0
	},
	{#State 12
		DEFAULT => -3
	},
	{#State 13
		ACTIONS => {
			"{" => 15
		}
	},
	{#State 14
		DEFAULT => -9
	},
	{#State 15
		ACTIONS => {
			"\\" => 7,
			"[^\\]+" => 8
		},
		GOTOS => {
			'para_text' => 16,
			'macro_para_text' => 2,
			'plain_para_text' => 4
		}
	},
	{#State 16
		ACTIONS => {
			"}" => 17
		}
	},
	{#State 17
		DEFAULT => -8
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'input', 1, undef
	],
	[#Rule 2
		 'text', 1,
sub
#line 8 "qantor_grammar.yp"
{ Text::Qantor::Parser::Elem::Para->new({ contents => $_[1] }); }
	],
	[#Rule 3
		 'text', 2,
sub
#line 9 "qantor_grammar.yp"
{ 
        my $l = Text::Qantor::Elem::ParaList->new($_[1]);
        $l->append($_[2]);
        $l
        }
	],
	[#Rule 4
		 'para', 2, undef
	],
	[#Rule 5
		 'empty_line', 1, undef
	],
	[#Rule 6
		 'para_text', 1, undef
	],
	[#Rule 7
		 'para_text', 1, undef
	],
	[#Rule 8
		 'macro_para_text', 5,
sub
#line 24 "qantor_grammar.yp"
{ Text::Qantor::Parser::Elem::MacroCall->new({ name => $_[2], body => $_[4] }) }
	],
	[#Rule 9
		 'macro_ident', 1, undef
	],
	[#Rule 10
		 'plain_para_text', 1, undef
	]
],
                                  @_);
    bless($self,$class);
}

#line 34 "qantor_grammar.yp"


use Text::Qantor::Parser::Elem::Para;
use Text::Qantor::Parser::Elem::ParaList;
use Text::Qantor::Parser::Elem::MacroCall;

1;
