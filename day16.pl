#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Packet;

 sub versions {
   my ($self, $packet) = @_;

   my $versions = $packet->{ version };
   for my $s (@{ $packet->{ subs } } ) {
     $versions += $self->versions( $s );
    }

   return $versions;
  }

 sub execute {
   my ($self, $packet) = @_;

   my $value;

   if ($packet->{ id } == 0) {
     $value = 0;
     for my $s (@{ $packet->{ subs } } ) {
       $value += $self->execute( $s );
      }
     return $value;
    }

   if ($packet->{ id } == 1) {
     $value = 1;
     for my $s (@{ $packet->{ subs } } ) {
       $value *= $self->execute( $s );
      }
     return $value;
    }

   if ($packet->{ id } == 2) {
     for my $s (@{ $packet->{ subs } } ) {
       my $sub_value = $self->execute( $s );
       $value = $sub_value if (!defined $value || $value > $sub_value);
      }
     return $value;
    }

   if ($packet->{ id } == 3) {
     for my $s (@{ $packet->{ subs } } ) {
       my $sub_value = $self->execute( $s );
       $value = $sub_value if (!defined $value || $value < $sub_value);
      }
     return $value;
    }

   if ($packet->{ id } == 4) {
     return $packet->{ value };
    }

   if ($packet->{ id } == 5) {
     my $sub_0 = $self->execute( $packet->{ subs }[0] );
     my $sub_1 = $self->execute( $packet->{ subs }[1] );
     return $sub_0 > $sub_1 ? 1 : 0;
    }

   if ($packet->{ id } == 6) {
     my $sub_0 = $self->execute( $packet->{ subs }[0] );
     my $sub_1 = $self->execute( $packet->{ subs }[1] );
     return $sub_0 < $sub_1 ? 1 : 0;
    }

   if ($packet->{ id } == 7) {
     my $sub_0 = $self->execute( $packet->{ subs }[0] );
     my $sub_1 = $self->execute( $packet->{ subs }[1] );
     return $sub_0 == $sub_1 ? 1 : 0;
    }

   die "Illegal packet id: $packet->{ id }\n";
  }

 sub parse {
  my ($self, $binary) = @_;

  die "Needs to be a reference" unless (ref($binary) eq 'SCALAR');
  my $original = $$binary;
  my $packet = {};

  $packet->{ version } = oct( '0b' . substr( $$binary, 0, 3, '' ) );
  $packet->{ id } = oct( '0b' . substr( $$binary, 0, 3, '' ) );
  while ($$binary && $$binary !~ /^0+$/) {
    if ($packet->{ id } == 4) {
      if ($$binary =~ s/^1(\d{4})//) {
        $packet->{ data } .= $1;
       }
      else {
        $$binary =~ s/^0(\d{4})//;
        $packet->{ data } .= $1;
        $packet->{ value } .= oct( '0b' . $packet->{ data } );
        $packet->{ length } = length( $original ) - length( $$binary );
        return $packet;
       }
     }
    else {
      $packet->{ lentype } = substr( $$binary, 0, 1, '' );
      my $length = oct( '0b' . substr( $$binary, 0, ($packet->{ lentype } ? 11 : 15), '' ) );
      while ($length) {
print "KAC: Need $length for $packet->{ lentype }\n";
        my $sub = $self->parse( $binary );
        push @{ $packet->{ subs } }, $sub;
        $length -= ($packet->{ lentype } ? 1 : $sub->{ length } );
print "KAC: Got ", $sub->{ length }, " for $packet->{ lentype }\n";
       }
      $packet->{ length } = length( $original ) - length( $$binary );
      return $packet;
     }
   }

  $packet->{ length } = length( $original ) - length( $$binary );
  return $packet;
 }

 sub new {
  my ($class, $hex) = @_;
  my $self = {
    hex => $hex,
    packets => [],
  };
  bless $self, $class;

  $self->{ binary } = join( '', map { sprintf "%04b", hex( $_ ) } split( '', $hex ) );
  while ($self->{ binary } && $self->{ binary } !~ /^0+$/) {
    push @{ $self->{ packets } }, $self->parse( \$self->{ binary } );
   }

  return $self;
 }
}

my $input_text = $ARGV[0] || path( 'input16.txt' )->slurp_utf8( { chomp => 1 } );

my $packet = Packet->new( $input_text );
my $total = 0;
for my $p (@{ $packet->{ packets } }) {
   $total += $packet->versions( $p );
  }

print "The total versions is $total\n";

print "The value of the outermost packet is ", $packet->execute( $packet->{ packets }[0] ), "\n";

exit;
