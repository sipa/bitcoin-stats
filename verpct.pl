#!/usr/bin/perl -w

use strict;

my $MAXVER = 4;

my @all1001;
my @all288;
my @all100;
my $sum1001 = 0;
my $sum288 = 0;
my $sum100 = 0;

my $first=$ARGV[0] || 0;

my @sums;
my @times;
my $sum = 0;

sub getsum {
    my ($last, $len) = @_;
    if ($len <= 0) {
        return 0;
    }
    my $first = $last - $len;
    if ($last > $#sums) {
        $last = $#sums;
    }
    my $lastx = $sums[$last];
    if ($first > $#sums) {
        $first = $#sums;
    }
    my $firstx;
    if ($first < 0) {
        $firstx = 0;
    } else {
        $firstx = $sums[$first];
    }
    return $lastx - $firstx;
}

while (<STDIN>) {
  chomp;
  if ($_ =~ /\A\s*(\d+)\s+\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s/) {
    my ($count,$start,$stop,$diff,$weight,$ntx,$ver)=($1,$2,$3,$4,$5,$6,$7);
    if ($ver > $MAXVER) {
        $ver = $MAXVER;
    }
    $times[$count] = ($start+$stop)*0.5;
    if ($count > 0) {
        $sums[$count] = $sums[$count - 1] + $ver;
    } else {
        $sums[$count] = $ver;
    }
  }
}

my $togo = 0;
my $togoexp = 0;
for my $count ($first..$#sums) {
    my $sum1001 = getsum($count, 1001) / 1001.0;
    my $sum288 = getsum($count, 288) / 288.0;
    my $sum100 = getsum($count, 100) / 100.0;
    my $sum1000 = getsum($count, 1000);
    $togo = 0;
    if ($sum1000 < ($MAXVER-1) * 1000) {
        $togo = 950;
    } elsif ($sum1000 < $MAXVER*1000 - 50) {
        $togo = $MAXVER*1000 - 50 - $sum1000;
        while (getsum($count, 1000 - $togo) + $togo * $MAXVER < $MAXVER*1000 - 50) {
            $togo++;
        }
    }
    print $times[$count]," ",$sum1001," ",$sum288," ",$sum100," ",(600*$togo),"\n";
}
