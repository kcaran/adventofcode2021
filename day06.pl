#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package LanternFish;

 sub spawn {
   my ($self) = @_;

   my $spawned = shift @{ $self->{ fish } } || 0;
   $self->{ fish }[8] = $spawned;
   $self->{ fish }[6] += $spawned;

   return $self;
 }

 sub new {
  my ($class, @initials) = @_;
  my $self = {
    day => 0,
    fish => [],
  };

  for my $fish (@initials) {
    $self->{ fish }[$fish]++;
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input06.txt';
my $final_day = $ARGV[1] || 80;

my @initials = split( ',', path( $input_file )->slurp_utf8( { chomp => 1 } ) );
my $fish = LanternFish->new( @initials );

my $day = 0;
while ($day < $final_day) {
  $fish->spawn( $day );
  $day++;
 # print $day, ":  ", join( ', ', @{ $fish->{ fish } } ), "\n";
 }

my $num_fish = 0;
for my $day (@{ $fish->{ fish } }) {
  $num_fish += ($day || 0);
 }

print "There are a total of $num_fish fish\n";
exit;
