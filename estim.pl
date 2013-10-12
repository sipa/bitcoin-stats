#!/usr/bin/perl -w

use strict;
use POSIX qw(strftime);

my @WINDOW = (48,192,768,3072); # how many blocks primitive growths are computed over
#my @WINDOW = (8,12,16,20);
my $INTERVAL = 300; # how many seconds between data points

# Assume N events have occurred during interval [0..1].
# The times these events occurred are given by T[i].
# Assume a probability distribution of events: 
#
#   p(t) = N*log(G)/(G-1)*G^t
#
# This integrates to N on [0..1]. G gives the growth
# factor during this interval.
#
# The log-likelyhood L(G) is given by:
#
#   L(G) = sum(log(p(T[i]),i=1..N)
#        = sum(log(N*log(G)/(G-1)*G^T[i]),i=1..N)
#
# The derivative w.r.t. G:
#
#   L'(G) = -(-N*G-sum(T[i],i=1..N)*ln(G)*G+N*ln(G)*G+N+sum(T[i],i=1..N)*ln(G))/ln(G)/G/(G-1)
#
# Call sum(T[i],i=1..N) = S:
#
#   L'(G) = -(-N*G-S*log(G)*G+N*log(G)*G+N+S*log(G))/log(G)/G/(G-1)
#         = (N*G+S*log(G)*G-N*log(G)*G-N-S*log(G))/(log(G)*G*(G-1))
#
# Call S/N=A (the average time events occurred):
#
#   L'(G) = N*(G+A*log(G)*G-log(G)*G-1-A*log(G))/(log(G)*G*(G-1))
#
# Solve for L'(G)=0:
#
#       0 = L'(G)
#   <=> 0 = N*(G+A*log(G)*G-log(G)*G-1-A*log(G))/(log(G)*G*(G-1))
#   <=> 0 = G+A*log(G)*G-log(G)*G-1-A*log(G)
#   <=> 1-G+G*log(G) = A*log(G)*(G-1)
#   <=> A = (1-G+G*log(G))/(log(G)*(G-1))
#
# Power series around G=1:
#
#   A = 1/2 + 1/12*(G-1) - 1/24*(G-1)^2 + 19/720*(G-1)^3 - 3/160*(G-1)^4 + 863/60480*(G-1)^5 - 275/24192*(G-1)^6 + 33953/3628800*(G-1)^7 - 8183/1036800*(G-1)^8 + 3250433/479001600*(G-1)^9 - 4671/788480*(G-1)^10 + 13695779093/2615348736000*(G-1)^11 - 2224234463/475517952000*(G-1)^12 + 132282840127/31384184832000*(G-1)^13
#
# Solving for G:
#
#  G = 1 + 12*(A-1/2) + 72*(A-1/2)^2 + 1584/5*(A-1/2)^3 + 6048/5*(A-1/2)^4 + 744768/175*(A-1/2)^5 + 2477952/175*(A-1/2)^6 + 39585024/875*(A-1/2)^7 + 24509952/175*(A-1/2)^8 + 28486038528/67375*(A-1/2)^9 + 421064054784/336875*(A-1/2)^10 + 79494362025984/21896875*(A-1/2)^11 + 32486245834752/3128125*(A-1/2)^12 + 3209606646939648/109484375*(A-1/2)^13 + 62679078733381632/766390625*(A-1/2)^14 + 1337068880805298176/5922109375*(A-1/2)^15 + 3093789446631456768/5011015625*(A-1/2)^16

my $P32 = 4294967296.0;

sub getGrowth {
  my ($avg)=@_;
  my @COEF=(1.0,12.0,72.0,316.8,1209.6,4255.81714285714285714285714,14159.7257142857142857142857,45240.0274285714285714285714,140056.868571428571428571429,422798.345499072356215213358,1249911.85093580705009276438,3630397.58074994719566148138,10385213.4536669730269730270,29315659.3983355889824461253,81784767.0479810892780688699,225775782.941411509475878263,617397685.051412460522910463,1673835035.52160973926945412,4502379526.25848466612819910,12023429677.2630843953643007,31894140720.4089949674213472,84081012941.8208588730282971,220380692896.365786417376418,574513427900.284283465248163,1490126640961.34708314510503);
  my $x=$avg-0.5;
  my $inv=0;
  my $sum=0;
  if ($x<0) { $x=-$x; $inv=1; }
  for (my $c=24; $c>=0; $c--) {
    my $xp=1;
    foreach my $i (1..$c) { $xp*=$x }
    $sum += $xp*$COEF[$c];
  }
  $sum = 1.0/$sum if ($inv);
  return $sum;
}

sub circleWeight {
  my ($time,$low,$high)=@_;
  return 0 if ($time<=$low || $time>=$high);
  my $x=($time-$low)/($high-$low);
  my $r=0.5*(cos(3.1415926535897932384*(2.0*$x-1.0))+1.0);
#  printf STDERR "x=$x r=$r\n";
  return $r;
}

sub procWindow {
  my ($eff,@window) = @_;
  my $low=($window[0]->[0]+$window[1]->[0])/2;
  my $high=($window[$#window]->[0]+$window[$#window-1]->[0])/2;
  my $sum=0;
  my $num=0;
  my $n=0;
  foreach my $arg (@window[1..$#window-1]) {
    my ($time,$count)=@{$arg};
    $sum+=$time*$count;
    $num+=$count;
    $n++;
  }
  my $avg=($sum/$num-$low)/($high-$low);
  my $growth=getGrowth($avg);
#  print STDERR "low=$low high=$high avg=$avg growth=$growth rate=",$num/($high-$low),"\n";
  my $lgrowth=log($growth);
  my $sweight=0;
  my $ratefactor=log($num*$lgrowth/($growth-1)/($high-$low));
  my @pos=(int($low/$INTERVAL+0.5)..int($high/$INTERVAL+0.5));
  my $totalw=0;
  for my $pos (@pos) {
    $totalw += circleWeight($pos*$INTERVAL,$low,$high);
  }
  for my $pos (@pos) {
    my $w = circleWeight($pos*$INTERVAL,$low,$high)/$totalw*$n;
    my $rpos = ($pos*$INTERVAL-$low)/($high-$low);
    my $rate = $ratefactor+$lgrowth*$rpos;
    $eff->{$pos}=[0,0,0] if (!exists $eff->{$pos});
    $eff->{$pos}->[0] += $w*$rate;
    $eff->{$pos}->[1] += $w;
 #   print STDERR "_";
  }
#  print STDERR "add factor: ",($totaladd/$num),"\n";
#  print STDERR "\n";
  return ($num/($high-$low),$growth**(86400/($high-$low)));
}

sub procLoop {
  my @window;
  my @eff;
  my @diffs;
  my ($low,$high);
  my $lastdiff=0;
  for my $windowid (0..$#WINDOW) {
    $eff[$windowid]={};
  }
  while (<STDIN>) {
    chomp;
    if ($_ =~ /^\s*([-0-9.]+)\s+([-0-9.]+)\s+([-0-9.]+)\s+([-0-9.]+)\s*/) {
      my $pos=$1;
      my $time=$2;
      my $diff=$3;
      my $ntx=$4;
      if ($diff != $lastdiff) {
        push @diffs,[$time,$diff];
      }
      $low=$time if (!defined($low) || $time<$low);
      $high=$time if (!defined($high) || $time>$high);
      $pos++;
      @window = sort { $a->[0] <=> $b->[0] } (@window,[$time,$diff*$P32]);
      my ($rate,$growth);
      foreach my $windowid (0..$#WINDOW) {
        my $window = $WINDOW[$windowid];
        if ($#window+1 >= $window) {
          my @mwindow=@window[$#window-$window+1..$#window];
#          print STDERR "proc window size ",$#mwindow+1,"\n";
          ($rate,$growth)=procWindow($eff[$windowid],@mwindow);
        }
      }
      print STDERR "\r                                                                                                                 \r#$pos [".(strftime "%a %b %e %H:%M:%S %Y", localtime $time)."] rate=".(defined $rate ? sprintf("%.3fGhash/s",$rate/1000000000) : "?")." diff=$diff daily_growth=".(defined $growth ? sprintf("%.2f%%",100*($growth-1)) : "?");
      shift @window if ($#window+1>=$WINDOW[$#WINDOW]);
    }
  }
  print STDERR "\n";
  my $diffpos=0;
  my $first=1;
  for my $key (sort (keys %{$eff[0]})) {
    my $time=$key*$INTERVAL;
    $diffpos++ while ($diffpos<$#diffs && $time>=$diffs[$diffpos+1]->[0]);
    print $time," ",$diffs[$diffpos]->[1]*$P32/600.0,join('',map { " ".((defined $_->{$key}->[1] && $_->{$key}->[1]>0) ? exp($_->{$key}->[0]/$_->{$key}->[1]) : "-") } (@eff)),"\n";
  }
}

procLoop;
