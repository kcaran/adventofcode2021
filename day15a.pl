#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Storable qw( dclone );

my $cave;

{ package Path;

 sub next {
   my ($self, $y, $x) = @_;

   return if ($y < 0 || $y > $cave->{ max });
   return if ($x < 0 || $x > $cave->{ max });
   my $pos = "$y,$x";
   return if ($self->{ visited }{ $pos });

   my $risk = $cave->risk( $y, $x, $self->{ risk } );
   return unless ($risk);

   # We can finally move!
   my $next = Storable::dclone( $self );
   $next->{ visited }{ $pos } = 1;
   $next->{ pos_x } = $x;
   $next->{ pos_y } = $y;
   $next->{ risk } = $risk;

   return $next;
  }

 sub move {
   my ($self) = @_;

   my @moves = ();

   my $next = $self->next( $self->{ pos_y } - 1, $self->{ pos_x } );
   push @moves, $next if ($next);

   $next = $self->next( $self->{ pos_y } + 1, $self->{ pos_x } );
   push @moves, $next if ($next);

   $next = $self->next( $self->{ pos_y }, $self->{ pos_x } - 1 );
   push @moves, $next if ($next);

   $next = $self->next( $self->{ pos_y }, $self->{ pos_x } + 1 );
   push @moves, $next if ($next);

   return @moves;
  }

 sub new {
  my ($class, $org_y, $org_x) = @_;
  my $self = {
    visited => { "0,0" => 1 },
    pos_x => $org_x,
    pos_y => $org_y,
    risk => 0,
  };

  bless $self, $class;
  return $self;
 }
}

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

 # Check if this is the lowest risk for this point
 sub risk {
   my ($self, $y, $x, $risk) = @_;

   my $pos = "$y,$x";
   my $new_risk = $risk + $self->{ points }[$y][$x];
   return if ($self->{ visited }{ $pos } && $self->{ visited }{ $pos } < $new_risk);

   $self->{ visited }{ $pos } = $new_risk;
   return $new_risk;
  }

 sub end {
   my ($self, $path) = @_;

   my $max = $self->{ max };
   return ($path->{ pos_x } == $max && $path->{ pos_y } == $max) ? 1 : 0;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    points => [],
    max => 0,
    visited => {},
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $line (@lines) {
    push @{ $self->{ points } }, [ split( '', $line ) ];
   }
  $self->{ max } = scalar @{ $self->{ points } } - 1;

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input15.txt';

$cave = Cave->new( $input_file );
my @paths = ( Path->new( 0, 0 ) );

my $min_risk = 1000000000;
while (@paths) {
  my $path = shift @paths;
  if ($cave->end( $path )) {
    my $risk = $path->{ risk };
    $min_risk = $risk if ($risk < $min_risk);
    next;
   }
  my @moves = $path->move();
  for my $i (0 .. @paths - 1) {
    for my $m (0 .. @moves - 1) {
      next unless ($moves[$m]);
      if (($paths[$i]->{ pos_x } == $moves[$m]->{ pos_x })
       && ($paths[$i]->{ pos_y } == $moves[$m]->{ pos_y })) {
        $paths[$i] = $moves[$m] if ($moves[$m]->{ risk } < $paths[$i]{ risk });
        $moves[$m] = undef;
       }
     }
   }
  push @paths, grep { $_ } @moves;
 }

print "The path with minimum risk is $min_risk\n";

exit;
