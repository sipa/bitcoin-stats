#!/usr/bin/perl

my $total=0.0;

while (<STDIN>) {
  chomp;
  if ($_ =~ /\A\s*(\d+)\s+\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*\Z/) {
    my ($count,$start,$stop,$diff,$weight,$ntx,$ver)=($1,$2,$3,$4,$5,$6,$7);
    $total += $diff*$weight;
    print (($start+$stop)*0.5," ",$count," ",$total*4295032833.0,"\n");
  }
}
