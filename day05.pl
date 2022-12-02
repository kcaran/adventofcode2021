#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Vent;

 sub print {
   my ($self) = @_;
   for my $y (0 .. $self->{ max_y }) {
     for my $x (0 .. $self->{ max_x }) {
       print $self->{ points }[$y][$x] || '.';
      }
     print "\n";
    }
   return;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    points => [],
    max_x => 0,
    max_y => 0,
    overlaps => 0,
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $line (@lines) {
    my ($x1, $y1, $x2, $y2) = ($line =~ /^(\d+),(\d+)\D+(\d+),(\d+)/);
    if ($x1 == $x2) {
      ($y2, $y1) = ($y1, $y2) if ($y2 < $y1);
      for my $y ($y1 .. $y2) {
        $self->{ points }[$y][$x1]++;
        $self->{ overlaps }++ if ($self->{ points }[$y][$x1] == 2);
       }
     }
    elsif ($y1 == $y2) {
      ($x2, $x1) = ($x1, $x2) if ($x2 < $x1);
      for my $x ($x1 .. $x2) {
        $self->{ points }[$y1][$x]++;
        $self->{ overlaps }++ if ($self->{ points }[$y1][$x] == 2);
       }
     }
    elsif (abs($x2 - $x1) == abs($y2 - $y1)) {
      my $x_dir = ($x2 > $x1) ? 1 : -1;
      my $y_dir = ($y2 > $y1) ? 1 : -1;
      while ($x1 != $x2) {
        $self->{ points }[$y1][$x1]++;
        $self->{ overlaps }++ if ($self->{ points }[$y1][$x1] == 2);
        $x1 += $x_dir;
        $y1 += $y_dir;
       }
      # Do the last point
      $self->{ points }[$y1][$x1]++;
      $self->{ overlaps }++ if ($self->{ points }[$y1][$x1] == 2);
     }
    else {
      print "Illegal points: $line\n";
      next;
     }

    $self->{ max_x } = $x2 if ($x2 > $self->{ max_x });
    $self->{ max_y } = $y2 if ($y2 > $self->{ max_y });
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input05.txt';
my $vent = Vent->new( $input_file );

print "There are $vent->{ overlaps } overlaps.\n";

exit;
