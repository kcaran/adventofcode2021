#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Cave;

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

  sub basin {
    my ($self, $input, $basin) = @_;

    return $self if ($basin->{ $input });

    my ($y, $x) = split( ',', $input );
    return $self if ($self->{ points }[$y][$x] == 9);

    $basin->{ $input } = 1;
    my $max_y = @{ $self->{ points } } - 1;
    my $max_x = @{ $self->{ points }[0] } - 1;
	$y != 0 && $self->basin( ($y-1) . ",$x", $basin );
	$y < $max_y && $self->basin( ($y+1) . ",$x", $basin );
	$x != 0 && $self->basin( "$y," . ($x-1), $basin );
	$x < $max_x && $self->basin( "$y," . ($x+1), $basin );

    return $self;
   }

  sub risk {
    my ($self) = @_;
    my $max_y = @{ $self->{ points } } - 1;
    my $max_x = @{ $self->{ points }[0] } - 1;
    my $score = 0;
    for my $y (0 .. $max_y) {
      for my $x (0 .. $max_x) {
        my $val = $self->{ points }[$y][$x];
        my $risk = 
			($y == 0 || $val < $self->{ points }[$y-1][$x])
			&& ($y == $max_y || $val < $self->{ points }[$y+1][$x])
			&& ($x == 0 || $val < $self->{ points }[$y][$x-1])
			&& ($x == $max_x || $val < $self->{ points }[$y][$x+1]);
        if ($risk) {
          $score += $val + 1;
          my $basin = {};
          $self->basin( "$y,$x", $basin );
          push @{ $self->{ basins } }, scalar keys( %{ $basin } );
         }
       }
     }

    return $score;
   }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    points => [],
    basins => [],
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $line (@lines) {
    push @{ $self->{ points } }, [ split( '', $line ) ];
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input09.txt';
my $cave = Cave->new( $input_file );
my $risk = $cave->risk();

print "The risk level is ", $risk, ".\n";

my @top = sort { $b <=> $a } @{ $cave->{ basins } };

print "The three largest basins product is ", $top[0] * $top[1] * $top[2], "\n";

exit;
