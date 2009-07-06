#!/usr/bin/perl

use strict;
use warnings;

package Flickr::WxPerlUploader::App;

use base 'Wx::App';
use Wx ':everything';
use Wx::Event qw(EVT_LISTBOX_DCLICK);

sub new
{
    my ($class, $args) = @_;

    my $self = $class->SUPER::new();

    return $self;
}

sub OnInit
{
    my( $self ) = @_;

    my $frame = Wx::Frame->new( undef, -1, 'wxPerl', wxDefaultPosition, [ 200, 100 ] );

    my $sizer = Wx::BoxSizer->new(wxHORIZONTAL());

    $frame->SetSizer($sizer);

    $sizer->Add($frame->{board}, 1, wxALL(), 10);
    $frame->{list} = Wx::ListBox->new(
        $frame,
        -1,
        wxDefaultPosition(),
        wxDefaultSize(),
        [qw(
            surround_island
            surrounded_by_blacks
            adjacent_whites
            distance_from_islands
        )]
    );
    $sizer->Add($frame->{list}, 1, wxALL(), 10);

    $frame->SetSize(Wx::Size->new(600,400));
    $frame->Show( 1 );

    $self->{frame} = $frame;

    EVT_LISTBOX_DCLICK($frame->{list}, wxID_ANY(), sub {
            my $list = shift;
            my $event = shift;

            my $sel = $event->GetSelection();
            my $string = $list->GetString($sel);
            $frame->{board}->perform_solve($string);
        }
    );

    return 1;
}

package main;

Flickr::WxPerlUploader::App->new(
    {
        argv => [@ARGV],
    }
)->MainLoop();

