#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Game;

 sub roll {
  my ($self, $player) = @_;

  my $roll = 0;
  for my $i (1..3) {
    $roll += $self->{ dice }++;
    $self->{ count }++;
   }

  $self->{ pos }[$player] = ($self->{ pos }[$player] + $roll) % 10;
  $self->{ score }[$player] += $self->{ pos }[$player] + 1;

  return ($self->{ score }[$player] >= 1000);
 }

 sub new {
  my ($class, $p1, $p2) = @_;
  my $self = {
    pos => [ $p1 - 1, $p2 - 1 ],
    score => [ 0, 0 ],
    dice => 1,
	count => 0,
  };
  bless $self, $class;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input21.txt';
my $input = Path::Tiny::path( $input_file )->slurp_utf8( { chomp => 1 } );

my ($p1, $p2) = ($input =~ /position: (\d+)$/smg);

my $game = Game->new( $p1, $p2 );

while (1) {
  last if ($game->roll(0));
  last if ($game->roll(1));
 }

print "The calculation is ", $game->{ count } * ($game->{ score }[0] >= 1000 ? $game->{ score }[1] : $game->{ score }[0]), "\n";

exit;
