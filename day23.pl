#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my %energy = (
	A => 1,
	B => 10,
	C => 100,
	D => 1000,
);

{ package Amphipods;

 sub hall {
   my ($self) = @_;

   my @moves;
   my ($hall, $idx);
   for $idx (0 .. 10) {
     next unless ((my $pod = $self->{ hall }[$idx]) =~ /[A-D]/);
     # Check if we can move in
     my $room = ord( $pod ) - 65;
     next unless (!$self->{ rooms }[$room] || $self->{ rooms }[$room] =~ /^$pod+$/);
     if ($idx <= ($room * 2 + 2)) {
       $hall = $idx + 1;
       while (($self->{ hall }[$hall] ne lc($pod)) && ($self->{ hall }[$hall] !~ /[A-D]/)) {
         $hall++;
        }
       next if ($self->{ hall }[$hall] =~ /[A-D]/);
      }
     else {
       $hall = $idx - 1;
       while (($self->{ hall }[$hall] ne lc($pod)) && ($self->{ hall }[$hall] !~ /[A-D]/)) {
         $hall--;
        }
       next if ($self->{ hall }[$hall] =~ /[A-D]/);
      }

     my $next = Storable::dclone( $self );
     $next->{ energy } += abs($hall - $idx) * $energy{ $pod };
     $next->{ energy } += ($self->{ spots } - length( $self->{ rooms }[$room] )) * $energy{ $pod };
     $next->{ rooms }[$room] .= $pod;
     $next->{ hall }[$idx] = '';
     push @moves, $next;
    }

   return @moves;
  }

 sub moves {
   my ($self, $idx) = @_;

   return unless ($self->{ rooms }[$idx]);
   my $roomchar = chr(65 + $idx);
   return if ($self->{ rooms }[$idx] =~ /^${roomchar}+$/);

   my $pod = substr( $self->{ rooms }[$idx], -1, 1, '' );

   my @moves;
   my $out = ($self->{ spots } - length( $self->{ rooms }[$idx] )) * $energy{ $pod };
   my $left = 2 * ($idx + 1) - 1;
   while ($left >= $self->{ left }{ $pod }) {
     $out += $energy{ $pod };
     if ($self->{ hall }[$left] =~ /[A-D]/) {
       $left = -1;
       next;
      }
     if ($self->{ hall }[$left] =~ /[a-d]/) {
       # Check if we can move in
       my $room = ord($self->{ hall }[$left]) - 97;
       if ($self->{ hall }[$left] eq lc( $pod )
         && (!$self->{ rooms }[$room] || $self->{ rooms }[$room] =~ /^$pod+$/)) {
           my $next = Storable::dclone( $self );
           $next->{ energy } += $out + ($self->{ spots } - length( $self->{ rooms }[$room] )) * $energy{ $pod };
           $self->{ rooms }[$idx] .= $pod;
           $next->{ rooms }[$room] .= $pod;
           return( $next );
        }
       else {
         $left--;
         next;
        }
      }

     my $next = Storable::dclone( $self );
     $next->{ hall }[$left] = $pod;
     $next->{ energy } += $out;
     push @moves, $next;
     $left--;
    }

   $out = ($self->{ spots } - length( $self->{ rooms }[$idx] )) * $energy{ $pod };
   my $right = 2 * ($idx + 1) + 1;
   while ($right <= $self->{ right }{ $pod }) {
     $out += $energy{ $pod };
     if ($self->{ hall }[$right] =~ /[A-D]/) {
       $right = 11;
       next;
      }
     if ($self->{ hall }[$right] =~ /[a-d]/) {
       # Check if we can move in
       my $room = ord($self->{ hall }[$right]) - 97;
       if ($self->{ hall }[$right] eq lc( $pod )
         && (!$self->{ rooms }[$room] || $self->{ rooms }[$room] =~ /^$pod+$/)) {
           my $next = Storable::dclone( $self );
           $next->{ energy } += $out + ($self->{ spots } - length( $self->{ rooms }[$room] )) * $energy{ $pod };
           $self->{ rooms }[$idx] .= $pod;
           $next->{ rooms }[$room] .= $pod;
           return( $next );
        }
       else {
         $right++;
         next;
        }
      }

     my $next = Storable::dclone( $self );
     $next->{ hall }[$right] = $pod;
     $next->{ energy } += $out;
     push @moves, $next;
     $right++;
    }

   # Put the pod back for this room!
   $self->{ rooms }[$idx] .= $pod;

   return @moves;
  }

 sub sig {
   my ($self) = @_;

   my $key = join( '|', @{ $self->{ rooms } }, @{ $self->{ hall } } );
  }

 sub rooms {
   my ($self) = @_;

   return join( '', @{ $self->{ rooms } } );
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    rooms => [ '', '', '', '' ],
    energy => 0,
    hall => [ '', '', 'a', '', 'b', '', 'c', '', 'd', '', '' ],
    left => { A => 0, B => 0, C => 0, D => 0 },
    right => { A => 10, B => 10, C => 10, D => 10 },
    spots => 0,
  };

  for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
    $line =~ tr/ABCD//cd;
    next unless $line;
    $self->{ spots }++;
    for my $i (0 .. length( $line ) - 1) {
      $self->{ rooms }[$i] = substr( $line, $i, 1 ) . $self->{ rooms }[$i];
     }
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input23.txt';
my $amp = Amphipods->new( $input_file );
my $match = 'A' x $amp->{ spots }
          . 'B' x $amp->{ spots }
          . 'C' x $amp->{ spots }
          . 'D' x $amp->{ spots };
my $min_energy = -1;
my @moves = ( $amp );
my %found;
while (@moves) {
   print "There are ", scalar @moves, " possible moves\n";
   my $move = shift @moves;
   next unless ($move);
   my $key = $move->sig();
   next if ($found{ $key } && $found{ $key }->{ energy } <= $move->{ energy });
   $found{ $key } = $move;

   if ($move->rooms eq $match) {
     $min_energy = $move->{ energy } if ($min_energy < 0 || $min_energy > $move->{ energy });
    }

   push @moves, $move->hall();
   push @moves, $move->moves( 0 );
   push @moves, $move->moves( 1 );
   push @moves, $move->moves( 2 );
   push @moves, $move->moves( 3 );
  }

print "The minimum energy found is $min_energy\n";

exit;
