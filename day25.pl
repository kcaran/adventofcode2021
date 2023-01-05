#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Cukes;

 sub move {
   my ($self) = @_;

   my $moves = 0;

   # First the east
   my $map = [];
   for my $row (@{ $self->{ map } }) {
     my $new = [];
     my $e = 0;
     while ($e < @{ $row } - 1) {
       if ($row->[$e] eq '>' && $row->[$e+1] eq '.') {
         push @{ $new }, '.';
         $e++;
         push @{ $new }, '>';
         $e++;
         next;
        }
       push @{ $new }, $row->[$e];
       $e++;
      }
     if ($e == @{ $row } - 1) {
       if ($row->[$e] eq '>' && $row->[0] eq '.') {
         push @{ $new }, '.';
         $new->[0] = '>';
        }
       else {
         push @{ $new }, $row->[$e];
        }
      }

     push @{ $map }, $new;
    }

   # Now the south
   my $vmap = [];
   for my $idx (0 .. @{ $map } - 2) {
     my $new = [];
     for my $e (0 .. @{ $map->[$idx] } - 1) {
       if ($map->[$idx][$e] eq 'v' && $map->[$idx+1][$e] eq '.') {
         $vmap->[$idx][$e] = '.';
         $vmap->[$idx+1][$e] = 'v';
        }
       else {
         $vmap->[$idx][$e] = $map->[$idx][$e] unless defined( $vmap->[$idx][$e] );
        }
       $e++;
      }
    }

   # Last line
   my $idx = @{ $map } - 1;
   for my $e (0 .. @{ $map->[-1] } - 1) {
     if ($map->[$idx][$e] eq 'v' && $map->[0][$e] eq '.') {
       $vmap->[$idx][$e] = '.';
       $vmap->[0][$e] = 'v';
      }
     else {
       $vmap->[$idx][$e] = $map->[$idx][$e] unless defined( $vmap->[$idx][$e] );
      }
    }

   my $row = 0;
   while (!$moves && $row < @{ $vmap }) {
     $moves = 1 if (join( '', @{ $vmap->[$row] } ) ne join( '', @{ $self->{ map }[$row] } ));
     $row++;
    }

   $self->{ map } = $vmap;

   return $moves;
  }

 sub print {
   my ($self) = @_;

   my $p = "\n";
   for my $row (@{ $self->{ map } }) {
     $p .= join( '', @{ $row } ) . "\n";
    }

   return $p;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    map => [],
  };

  for my $l (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
    push @{ $self->{ map } }, [ split( '', $l ) ];
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input25.txt';
my $cukes = Cukes->new( $input_file );

my $steps = 1;
while ($cukes->move()) {
  print "On step $steps\n" if ($steps % 10 == 0);
  $steps++;
 }

print "It took $steps steps for the cukes to stop\n";

exit;
