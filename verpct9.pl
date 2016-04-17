#!/usr/bin/perl -w

use strict;

my $first=$ARGV[0] || 0;

my @sums_csv;
my @sums_bip9;
my @times;

sub getsum {
    my ($sums, $last, $len) = @_;
    if ($len <= 0) {
        return 0;
    }
    my $first = $last - $len;
    if ($last > $#{$sums}) {
        $last = $#{$sums};
    }
    my $lastx = $sums->[$last];
    if ($first > $#{$sums}) {
        $first = $#{$sums};
    }
    my $firstx;
    if ($first < 0) {
        $firstx = 0;
    } else {
        $firstx = $sums->[$first];
    }
    return $lastx - $firstx;
}

while (<STDIN>) {
  chomp;
  if ($_ =~ /\A\s*(\d+)\s+\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*\Z/) {
    my ($count,$start,$stop,$diff,$weight,$ntx,$ver)=($1,$2,$3,$4,$5,$6,$7);
    my $csv = (($ver & 0xE0000000) == 0x20000000) && (($ver & 1) == 1) && ($start > 1462060800);
    my $bip9 = (($ver & 0xE0000000) == 0x20000000) && (($ver & 0x1FFFFFFE) == 0);
    $times[$count] = ($start+$stop)*0.5;
    if ($count > 0) {
        $sums_csv[$count] = $sums_csv[$count - 1] + $csv;
        $sums_bip9[$count] = $sums_bip9[$count - 1] + $bip9;
    } else {
        $sums_csv[$count] = $csv;
        $sums_bip9[$count] = $bip9;
    }
  }
}

for my $count ($first..$#times) {
    my $csv = getsum(\@sums_csv, $count, 2016) / 2016.0;
    my $bip9 = getsum(\@sums_bip9, $count, 2016) / 2016.0;
    print $times[$count]," ",$bip9," ",$csv,"\n";
}
