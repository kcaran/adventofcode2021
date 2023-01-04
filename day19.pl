#!/usr/bin/env perl

#
# Needed some help from:
# https://www.ericburden.work/blog/2021/12/29/advent-of-code-2021-day-19/
#
use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Sensor;

 sub check {
   my ($self, $base, $orient, $dim, $off) = @_;

   my $matches;
   for my $b (@{ $base->{ beacons } }) {
     for my $o (@{ $orient }) {
       push @{ $matches }, $o if ($b->[$dim] == $o->[$dim] + $off);
      }
    }

   return $matches;
  }

 sub offset {
   my ($self, $base, $orient, $dim) = @_;

   for my $b (@{ $base->{ beacons } }) {
     for my $o (@{ $orient }) {
       my $off = $b->[$dim] - $o->[$dim];
       my $matches = $self->check( $base, $orient, $dim, $off );
       return ($off, $matches) if (@{ $matches } >= 12);
      }
    }

   return;
  }

 sub match {
   my ($self, $base) = @_;

   for my $idx (0 .. 23) {
     my ($x_off, $y_off, $z_off);
     my $o = [ $self->orient( $idx ) ];
     ($x_off, $o) = $self->offset( $base, $o, 0 );
     next unless defined($x_off);
     ($y_off, $o) = $self->offset( $base, $o, 1 );
     next unless defined($y_off);
     ($z_off, $o) = $self->offset( $base, $o, 2 );
     next unless defined($z_off);

     # Return translated version of this base
     $self->{ origin } = [ $x_off, $y_off, $z_off ];
     my @translated = $self->orient( $idx );
     for my $b (0 .. @translated - 1) {
       $translated[$b][0] += $x_off;
       $translated[$b][1] += $y_off;
       $translated[$b][2] += $z_off;
      }
     $self->{ beacons } = [ @translated ];

     return ($self);
    }

   return;
  }

 # https://www.reddit.com/r/adventofcode/comments/rjwhdv/comment/hp65cya/?utm_source=share&utm_medium=web2x&context=3
 sub orient {
  my ($self, $idx) = @_;

  my @orients;
  for my $b (@{ $self->{ beacons } }) {
    my ($x, $y, $z) = @{ $b };
    # Positive x
    push @orients, [+$x,+$y,+$z] if ($idx == 0);
    push @orients, [+$x,-$z,+$y] if ($idx == 1);
    push @orients, [+$x,-$y,-$z] if ($idx == 2);
    push @orients, [+$x,+$z,-$y] if ($idx == 3);
    # Negative x
    push @orients, [-$x,-$y,+$z] if ($idx == 4);
    push @orients, [-$x,+$z,+$y] if ($idx == 5);
    push @orients, [-$x,+$y,-$z] if ($idx == 6);
    push @orients, [-$x,-$z,-$y] if ($idx == 7);
    # Positive y
    push @orients, [+$y,+$z,+$x] if ($idx == 8);
    push @orients, [+$y,-$x,+$z] if ($idx == 9);
    push @orients, [+$y,-$z,-$x] if ($idx == 10);
    push @orients, [+$y,+$x,-$z] if ($idx == 11);
    # Negative y
    push @orients, [-$y,-$z,+$x] if ($idx == 12);
    push @orients, [-$y,+$x,+$z] if ($idx == 13);
    push @orients, [-$y,+$z,-$x] if ($idx == 14);
    push @orients, [-$y,-$x,-$z] if ($idx == 15);
    # Positive z
    push @orients, [+$z,+$x,+$y] if ($idx == 16);
    push @orients, [+$z,-$y,+$x] if ($idx == 17);
    push @orients, [+$z,-$x,-$y] if ($idx == 18);
    push @orients, [+$z,+$y,-$x] if ($idx == 19);
    # Negative z
    push @orients, [-$z,-$x,+$y] if ($idx == 20);
    push @orients, [-$z,+$y,+$x] if ($idx == 21);
    push @orients, [-$z,+$x,-$y] if ($idx == 22);
    push @orients, [-$z,-$y,-$x] if ($idx == 23);
   }

  return @orients;
 }

 sub new {
  my ($class, $idx) = @_;
  my $self = {
    idx => $idx,
    beacons => [],
    origin => [ 0, 0, 0 ],
  };

  bless $self, $class;
  return $self;
 }
}

sub scanner_distance {
  my (@sensors) = @_;

  my $max_dist = 0;
  for my $i (0 .. @sensors - 2) {
    for my $j ($i+1 .. @sensors - 1) {
      my $dist = 0;
      for my $dim (0 .. 2) {
        $dist += abs( $sensors[$i]->{ origin }[$dim] - $sensors[$j]->{ origin }[$dim] );
       }
      $max_dist = $dist if ($dist > $max_dist);
     }
   }

  return $max_dist;
 }

sub count_beacons {
  my (@sensors) = @_;

  my %beacons;

  for my $s (@sensors) {
    for my $b (@{ $s->{ beacons } }) {
      my $pos = join( ',', @{ $b } );
      $beacons{ $pos } = 1;
     }
   }

  return scalar keys %beacons;
 }

my $input_file = $ARGV[0] || 'input19.txt';
my @sensors;
my $sensor;
for my $line (Path::Tiny::path( $input_file )->lines( { chomp => 1 } )) {
  next unless ($line);
  if ($line =~ /scanner (\d+)/) {
    push @sensors, $sensor if ($sensor);
    $sensor = Sensor->new( $1 );
   }
  else {
    my ($x, $y, $z) = split( ',', $line );
    push @{ $sensor->{ beacons } }, [$x, $y, $z];
   }
 }
push @sensors, $sensor if ($sensor);

my @found = ( shift @sensors );

while (@sensors) {
  my $s = shift @sensors;
  my $m;
  for my $i (0 .. @found - 1) {
    $m = $s->match( $found[$i] );
    if ($m) {
      print "Matched scanner $m->{ idx }\n";
      push @found, $m;
      last;
     }
   }
  push @sensors, $s unless ($m);
 }

print "There are ", count_beacons( @found ), " beacons found\n";

print "The largest distance is ", scanner_distance( @found ), "\n";

exit;
