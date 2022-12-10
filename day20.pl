#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Image;

 sub print {
   my ($self) = @_;

   my $output = '';
   for my $row (@{ $self->{ image } }) {
     my $str = join( '', @{ $row } );
     $str =~ s/0/./g;
     $str =~ s/1/#/g;
     $output .= $str . "\n";
    }

   $self->{ lit } = () = $output =~ /#/g;

   return $output;
  }

 sub read {
   my ($self, $y, $x) = @_;

   my $infinity = $self->{ alg }[$self->{ infinity }] eq '#' ? 1 : 0;
   my $code = '0b';
   for my $py ($y - 1 .. $y + 1) {
     for my $px ($x - 1 .. $x + 1) {
       $code .= ($py < 0 || $px < 0 || $py >= $self->{ size } || $px >= $self->{ size }) ? $infinity : $self->{ image }[$py][$px];
      }
    }

   return $self->{ alg }[ oct( $code ) ] eq '#' ? 1 : 0;
  }

 sub enhance {
   my ($self) = @_;

   my $enhanced = [];
   for my $y (-1 .. $self->{ size }) {
     my $row = [];
     for my $x (-1 .. $self->{ size }) {
       push @{ $row }, $self->read( $y, $x );
      }
     push @{ $enhanced }, $row;
    }

   $self->{ image } = $enhanced;
   $self->{ size } += 2;

   # Update what infinity looks like
   $self->{ infinity } = $self->{ alg }[$self->{ infinity }] eq '#' ? 511 : 0;
   return $self;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    image => [],
  };
  bless $self, $class;

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  $self->{ alg } = [ split( '', shift @lines ) ];

  for my $l (@lines) {
    next unless $l;
    $l =~ s/\./0/g;
    $l =~ s/#/1/g;
    push @{ $self->{ image } }, [ split( '', $l ) ];
   }

  $self->{ size } = scalar( @{ $self->{ image } } );
  $self->{ infinity } = $self->{ alg }[0] eq '#' ? 511 : 0;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input20.txt';
my $image = Image->new( $input_file );
$image->enhance();
$image->enhance();
print $image->print();
print "The number of pixels lit is ", $image->{ lit }, "\n";

$image->enhance() for (3..50);

print $image->print();
print "The number of pixels lit is ", $image->{ lit }, "\n";

exit;
