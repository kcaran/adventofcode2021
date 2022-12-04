#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Octopuses;

 sub print {
   my ($self) = @_;

   my $max = @{ $self->{ points } } - 1;
   for my $y (0 .. $max) {
     for my $x (0 .. $max) {
       print $self->{ points }[$y][$x] || '.';
      }
     print "\n";
    }
   return;
  }

 sub energy {
   my ($self, $y, $x) = @_;

   my $pos = "$y,$x";

   return if ($self->{ flash }{ $pos });
   $self->{ points }[$y][$x]++;
   if ($self->{ points }[$y][$x] > 9) {
     $self->{ points }[$y][$x] = 0;
     $self->{ flash }{ $pos } = 1;

     my $max = @{ $self->{ points } } - 1;
     for my $y1 ($y - 1 .. $y + 1) {
       for my $x1 ($x - 1 .. $x + 1) {
         next if ($y1 == $y && $x1 == $x);
         next if ($y1 < 0 || $y1 > $max);
         next if ($x1 < 0 || $x1 > $max);
         $self->energy( $y1, $x1 );
        }
      }
    }

   return $self;
  }

 sub step {
   my ($self) = @_;

   $self->{ flash } = {};

   my $max = @{ $self->{ points } } - 1;
   for my $y (0 .. $max) {
     for my $x (0 .. $max) {
       $self->energy( $y, $x ); 
      }
    }

   return $self;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    points => [],
    flash => {},
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $line (@lines) {
    push @{ $self->{ points } }, [ split( '', $line ) ];
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input11.txt';
my $oct = Octopuses->new( $input_file );

my $steps = $ARGV[1] || 100;
my $flashes = 0;
for my $i (0 .. $steps - 1) {
  $oct->step();
  $flashes += scalar %{ $oct->{ flash } };
 }

print "There were $flashes total flashes after $steps steps\n";

while (scalar %{ $oct->{ flash } } < 100) {
  $steps++;
  $oct->step();
 }

print "The octopuses all flash after $steps steps\n";

exit;
