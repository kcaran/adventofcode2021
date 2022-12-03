#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Display;

 sub unique {
   my ($self) = @_;

   my $count = 0;
   for my $digit (@{ $self->{ digits } }) {
     my $len = length( $digit );
     $count++ if ($len == 2); # 1
     $count++ if ($len == 4); # 4
     $count++ if ($len == 3); # 7
     $count++ if ($len == 7); # 8
    }

   return $count;
  }

 sub disp_uniq {
   my ($self) = @_;

   for my $signal (@{ $self->{ signals } }) {
     my $len = length( $signal );
     $self->{ display }{ $signal } = 1 if ($len == 2);
     $self->{ one } = $signal if ($len == 2);
     $self->{ display }{ $signal } = 4 if ($len == 4);
     $self->{ four } = $signal if ($len == 4);
     $self->{ display }{ $signal } = 7 if ($len == 3);
     $self->{ display }{ $signal } = 8 if ($len == 7);
    }

   return $self;
  }

 sub disp_5 {
   my ($self) = @_;

   for my $signal (@{ $self->{ signals } }) {
     next unless (length( $signal ) == 5);
     my $test_one = $signal;
     eval "\$test_one =~ tr/$self->{ one }//cd";
     if (length( $test_one ) == 2) {
       $self->{ display }{ $signal } = 3;
      }
     else {
       my $test_six = $signal;
       eval "\$test_six =~ tr/$self->{ six }//d";
       $self->{ display }{ $signal } = length( $test_six ) ? 2 : 5;
      }
    }

   return $self;
  }

 sub disp_6 {
   my ($self) = @_;

   for my $signal (@{ $self->{ signals } }) {
     next unless (length( $signal ) == 6);
     my $test_one = $signal;
     eval "\$test_one =~ tr/$self->{ one }//cd";
     if (length( $test_one ) != 2) {
       $self->{ display }{ $signal } = 6;
       $self->{ six } = $signal;
      }
     else {
       my $test_four = $signal;
       eval "\$test_four =~ tr/$self->{ four }//cd";
       $self->{ display }{ $signal } = (length( $test_four ) == 4) ? 9 : 0;
      }
    }

   return $self;
  }

 sub sort {
   my ($signal) = @_;

   return join( '', sort split( '', $signal ) );
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
    display => {},
  };

  my ($signals, $digits) = split( /\s+\|\s+/, $input );
  $self->{ signals } = [ map { Display::sort( $_ ) } split( /\s+/, $signals ) ];
  $self->{ digits } = [ map { Display::sort( $_ ) } split( /\s+/, $digits ) ];

  bless $self, $class;

  $self->disp_uniq()->disp_6()->disp_5();

  $self->{ value } = join( '', map{ $self->{ display }{ $_ } } @{ $self->{ digits } } );

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input08.txt';
my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
my $unique = 0;
my $values = 0;
for my $pattern (@lines) {
  my $display = Display->new( $pattern );
  $unique += $display->unique();
  $values += $display->{ value };
 }

print "There are $unique unique digits\n";

print "The total sum of values are $values\n";

exit;
