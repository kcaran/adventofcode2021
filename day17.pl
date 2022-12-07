#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my $target;

{ package Launch;

 sub new {
  my ($class, $vel_x, $vel_y) = @_;
  my $self = {
    vel_y => $vel_y,
    vel_x => $vel_x,
    max_y => 0,
    pos => [0,0],
  };
  bless $self, $class;

  my $hit;
  while (($hit = $target->test( $self )) == 0) {
    $self->{ pos }[0] += $self->{ vel_y }--;
    $self->{ pos }[1] += $self->{ vel_x };
    $self->{ vel_x }++ if ($self->{ vel_x } < 0);
    $self->{ vel_x }-- if ($self->{ vel_x } > 0);
    if ($self->{ pos }[0] > $self->{ max_y }) {
      $self->{ max_y } = $self->{ pos }[0];
     }
   }

  return $hit > 0 ? $self : $hit;
 }
}

{ package Target;

 sub test {
   my ($self, $launch) = @_;

#print "KAC: LAUNCH: $launch->{ pos }[0], $launch->{ pos }[1]\n";
   # We'll miss entirely if y is too high
   return -2 if ($launch->{ pos }[1] > $self->{ max_x });
  # return -2 if ($launch->{ pos }[0] < $self->{ min_y } && $launch->{ vel_x } == 0);
   return -1 if ($launch->{ pos }[0] < $self->{ min_y });
   #return -2 if ($launch->{ pos }[1] < $self->{ min_x } && $launch->{ vel_x } == 0);

   return 1 if (($launch->{ pos }[1] <= $self->{ max_x })
             && ($launch->{ pos }[1] >= $self->{ min_x })
             && ($launch->{ pos }[0] <= $self->{ max_y })
             && ($launch->{ pos }[0] >= $self->{ min_y }));
   return 0;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
  };
  bless $self, $class;

  $input =~ /x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)/;
  $self->{ min_x } = $1;
  $self->{ max_x } = $2;
  $self->{ min_y } = $3;
  $self->{ max_y } = $4;

  return $self;
 }
}

my $input_text = $ARGV[0] || path( 'input17.txt' )->slurp_utf8( { chomp => 1 } );

$target = Target->new( $input_text );

my $max_y = 0;
my ($x, $y) = (1, 1);

$x = 0;
my $count = 0;
while ($x <= $target->{ max_x }) {
  my $overshoot = 0;
  $y = $target->{ min_y };
  my $this_max = 0;
  while ($overshoot == 0) {
    if ($y > abs($target->{ min_y })) {
      $overshoot = 1;
      next;
     }
    my $launch = Launch->new( $x, $y );
    if (ref($launch)) {
      if ($max_y <= $launch->{ max_y }) {
        $max_y = $launch->{ max_y };
       }
      if ($this_max <= $launch->{ max_y }) {
        $this_max = $launch->{ max_y };
       }
      else {
        $overshoot = 1;
       }
print "$x, $y, $launch->{ max_y }\n";
$count++;
     }
    else {
      $overshoot = 1 if ($launch == -3);
     }
    $y++; 
   }
  print "The tallest for $x is ", $y - 1, "\n";
  $x++; 
 }

print "The maximum y-height is $max_y\n";
print "The number is $count\n";
exit;
