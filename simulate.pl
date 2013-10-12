#!/usr/bin/perl -w

use strict;

# gigahash/s
my $GHps=$ARGV[0] || 500;

# difficult
my $diff=$ARGV[1] || 68978.89245792;

# end time
my $etime=time;

# number of blocks
my $nblocks=$ARGV[2] || 50000;

# blocks/(difficulty*s)
my $Bpds=$GHps/4.295032833;

my @blocks;

while ($#blocks < $nblocks) {
  my $Bps = $Bpds/$diff;
  print "# GHps=$GHps diff=$diff etime=$etime nblocks=$nblocks Bpds=$Bpds Bps=$Bps\n";
  $etime += int(log(rand(1))/$Bps+0.5); # negative number, $etime decreases
  push @blocks,[$etime,$diff];
}

@blocks = reverse @blocks;

my $n=1;
for my $block (@blocks) {
  print "$n ($block->[0],$block->[0]) $block->[1] 1 0\n";
  $n++;
}
