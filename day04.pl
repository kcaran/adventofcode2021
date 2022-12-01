#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Card;

 sub unmarked {
   my ($self, $number) = @_;

   my $unmarked = 0;
   for my $value (keys %{ $self->{ values } }) {
     $unmarked += $value if ($self->{ values }{ $value }[2] == 0);
    }

   return $unmarked;
  }

 sub mark {
   my ($self, $value) = @_;

   if (my $pos = $self->{ values }{ $value }) {
     $pos->[2] = 1;
     $self->{ row_marked }[$pos->[0]]++;
     $self->{ col_marked }[$pos->[1]]++;
     if (($self->{ row_marked }[$pos->[0]] == $self->{ num_rows })
      || ($self->{ col_marked }[$pos->[1]] == $self->{ num_rows })) {
       $self->{ score } = $self->unmarked() * $value;
       return $self;
      }
    }

   return;
  }

 sub new {
  my ($class, @values) = @_;
  my $self = {
    values => {},
    row_marked => [],
    col_marked => [],
    num_rows => 0,
    score => 0,
  };

  my $row_num = 0;
  for my $row (@values) {
    $row =~ s/^\s+//;
    $row =~ s/\s+$//;
    my @cols = split( /\s+/, $row );
    my $col_num = 0;
    for my $value (@cols) {
      $self->{ values }{ $value } = [ $row_num, $col_num, 0 ];
      $col_num++;
     }
    $row_num++;
   }

  $self->{ num_rows } = $row_num;

  bless $self, $class;
  return $self;
 }
}

{ package Bingo;

 sub number {
   my ($self) = @_;
   my $number = shift @{ $self->{ nums } };
   die "No more numbers found. No winners!" unless (defined $number);

   return $number;
  }

 sub play {
   my ($self, $number) = @_;

   my $bingo;
   my $next_cards = [];
   for my $idx (0 .. @{ $self->{ cards } } - 1) {
     my $card = $self->{ cards }[$idx];
     $bingo = $card->mark( $number );
     push @{ $next_cards }, $card unless ($bingo);
    }

   $self->{ cards } = $next_cards;

   return $bingo;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    nums => [],
    cards => [],
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  my $nums = shift @lines;
  @{ $self->{ nums } } = split( ',', $nums );
  shift @lines;
  push @lines, '';

  my @card = ();
  for my $line (@lines) {
    if ($line) {
      push @card, $line;
     }
    else {
      push @{ $self->{ cards } }, Card->new( @card );
      @card = (); 
     }
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input04.txt';
my $bingo = Bingo->new( $input_file );
my $winner;
my $number;
while (!$winner) {
  $number = $bingo->number();
  $winner = $bingo->play( $number );
 }

print "The winning score is ", $winner->unmarked() * $number, "\n";

while (@{ $bingo->{ cards } }) {
  $number = $bingo->number();
  $winner = $bingo->play( $number );
 }

print "The final winning score is ", $winner->unmarked() * $number, "\n";

exit;
