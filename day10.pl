#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

sub parse {
  my ($line) = @_;

  my $open = {
    '(' => { close => ')', score => 1 },
    '[' => { close => ']', score => 2 },
    '{' => { close => '}', score => 3 },
    '<' => { close => '>', score => 4 },
  };

  my $close = {
    ')' => { open => '(', score => 3 },
    ']' => { open => '[', score => 57 },
    '}' => { open => '{', score => 1197 },
    '>' => { open => '<', score => 25137 },
  };

  my @stack;
  for my $char (split( '', $line )) {
    if ($open->{ $char }{ close }) {
      push @stack, $char;
     }
    else {
      my $closing = $close->{ $char }{ open };
      my $next = pop( @stack );
      return { corrupt => $close->{ $char }{ score } } unless ($closing eq $next);
     }
   }

  my $complete = 0;
  for my $char (reverse @stack) {
    $complete = ($complete * 5) + $open->{ $char }{ score };
   }

  return { complete => $complete };
 }

my $input_file = $ARGV[0] || 'input10.txt';
my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );

my $corrupt_score = 0;
my @complete_scores;
for my $line (@lines) {
  my $score = parse( $line );
  if ($score) {
    $corrupt_score += $score->{ corrupt } || 0;
    push @complete_scores, $score->{ complete } if ($score->{ complete });
   }
 }

print "The total corrupt score is $corrupt_score\n";

my $mid = [ sort { $a <=> $b } @complete_scores ]->[@complete_scores / 2];
print "The middle complete score is $mid\n";

exit;
