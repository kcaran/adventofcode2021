#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Game;

 sub rolls {
   my ($self) = @_;

   return $self->{ rolls } if ($self->{ rolls });

   $self->{ rolls } = {};
   for my $one (1 .. 3) {
     for my $two (1 .. 3) {
       for my $thr (1 .. 3) {
         my $roll = $one + $two + $thr;
         $self->{ rolls }{ $roll }++;
        }
      }
    }

   return $self->{ rolls };
  }

 sub roll {
  my ($self, $player) = @_;

  my %rolls = %{ $self->rolls() };
  my $games = {};
  my $winner = 21;
  for my $scen (keys %{ $self->{ games } }) {
    my $num = $self->{ games }{ $scen };
    my ($pos1, $score1, $pos2, $score2) = split( ',', $scen );
    for my $roll (keys %rolls) {
      my $count = $rolls{ $roll };
      my ($pos, $score, $next);
      if ($player) {
        $pos = ($pos2 + $roll) % 10;
        $score = $score2 + $pos + 1;
        $next = "$pos1,$score1,$pos,$score"
       }
      else {
        $pos = ($pos1 + $roll) % 10;
        $score = $score1 + $pos + 1;
        $next = "$pos,$score,$pos2,$score2";
       }
      if ($score >= $winner) {
        $self->{ wins }[$player] += $num * $count;
       }
      else {
        $games->{ $next } += $num * $count;
       }
     }
   }

  $self->{ games } = $games;

  return %{ $self->{ games } } == 0;
 }

 sub new {
  my ($class, $p1, $p2) = @_;
  $p1--;
  $p2--;
  my $self = {
    games => { "$p1,0,$p2,0" => 1 },
    wins => [0, 0],
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

print "Player 1 wins in $game->{ wins }[0] universes\n";
print "Player 2 wins in $game->{ wins }[1] universes\n";

exit;
