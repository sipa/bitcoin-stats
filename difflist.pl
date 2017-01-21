#!/usr/bin/perl

my $last=0.0;
my $sum=0.0;

my $K = 1.0/139.696254564114497;

my $first=$ARGV[0] || 0;

while (<STDIN>) {
  chomp;
  if ($_ =~ /\A\s*(\d+)\s+\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*/) {
    my ($count,$start,$stop,$diff,$weight,$ntx,$ver)=($1,$2,$3,$4,$5,$6,$7);
    $sum += $diff*$K*600;
    $sumq += $diff*$diff*$K*$K*600*600;
    if ($count>=$first && $last != $diff) {
      print (($start+$stop)*0.5," ",$last*$K," ",$sum," ",sqrt($sumq),"\n") if ($last>0);
      print (($start+$stop)*0.5," ",$diff*$K," ",$sum," ",sqrt($sumq),"\n");
      $last=$diff;
    }
  }
}

print time," ",$last*$K," ",$sum," ",sqrt($sumq),"\n";
