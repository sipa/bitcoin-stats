#!/usr/bin/perl -w

use strict;

my $first=$ARGV[0] || 0;

my @sums_csv;
my @sums_segwit;
my @sums_bip91;
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
    return ($lastx - $firstx) * 1.0 / $len;
}

while (<STDIN>) {
  chomp;
  if ($_ =~ /\A\s*(\d+)\s+\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*/) {
    my ($count,$start,$stop,$diff,$weight,$ntx,$ver)=($1,$2,$3,$4,$5,$6,$7);
    my $csv = (($ver & 0xE0000000) == 0x20000000) && (($ver & 1) == 1) && ($start > 1462060800);
    my $bip91 = (($ver & 0xE0000000) == 0x20000000) && (($ver & 16) == 16) && ($start > 1496275200);
    my $segwit = (($ver & 0xE0000000) == 0x20000000) && (($ver & 2) == 2) && ($start > 1479168000);
    my $bip9 = (($ver & 0xE0000000) == 0x20000000) && (($ver & 0x1FFFFFFF) == 0);
    $times[$count] = ($start+$stop)*0.5;
    if ($count > 0) {
        $sums_csv[$count] = $sums_csv[$count - 1] + $csv;
        $sums_segwit[$count] = $sums_segwit[$count - 1] + $segwit;
        $sums_bip91[$count] = $sums_bip91[$count - 1] + $bip91;
        $sums_bip9[$count] = $sums_bip9[$count - 1] + $bip9;
    } else {
        $sums_segwit[$count] = $segwit;
        $sums_csv[$count] = $csv;
        $sums_bip9[$count] = $bip9;
    }
  }
}

for my $count ($first..$#times) {
    my $csv_2016 = getsum(\@sums_csv, $count, 2016);
    my $segwit_2016 = getsum(\@sums_segwit, $count, 2016);
    my $bip91_336 = getsum(\@sums_bip91, $count, 336);
    my $bip9_2016 = getsum(\@sums_bip9, $count, 2016);
    my $csv_144 = getsum(\@sums_csv, $count, 144);
    my $segwit_144 = getsum(\@sums_segwit, $count, 144);
    my $bip91_144 = getsum(\@sums_bip91, $count, 144);
    my $bip9_144 = getsum(\@sums_bip9, $count, 144);
    print $times[$count]," ",$bip9_2016," ",$csv_2016," ",$segwit_2016," ",$bip9_144," ",$csv_144," ",$segwit_144," ",$bip91_336," ",$bip91_144,"\n";
}
