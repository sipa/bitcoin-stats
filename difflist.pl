#!/usr/bin/perl

my $last=0.0;

my $first=$ARGV[0] || 0;

while (<STDIN>) {
  chomp;
  if ($_ =~ /\A\s*(\d+)\s+\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*\Z/) {
    my ($count,$start,$stop,$diff,$weight,$ntx)=($1,$2,$3,$4,$5,$6);
    if ($count>=$first && $last != $diff) {
      print (($start+$stop)*0.5," ",$last/139.696254564114497,"\n") if ($last>0);
      print (($start+$stop)*0.5," ",$diff/139.696254564114497,"\n");
    }
    $last=$diff;
  }
}

print time," ",$last/139.696254564114497,"\n";
