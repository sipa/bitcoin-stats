#!/usr/bin/perl -w

use strict;
use JSON::RPC::Client;
use Data::Dumper;

open URI, "<uri.secret";
my $URI = <URI>;
close URI;

my $client = new JSON::RPC::Client;

sub fetchData {
  my ($bn) = @_;
  my $callobj = {
    method => 'getblock',
    params => [$bn]
  };
  do {
    my $res = $client->call($URI, $callobj);
    if($res) {
      if ($res->is_error) {
        print "Error : ", $res->error_message;
        exit;
      }
      return ($res->result);
    }
    print STDERR "Failed to fetch data. Retry in 30 seconds.\n";
    sleep 30;
  } while(1);
}

sub procLoop {
  my ($maxpos) = @_;
  my $pos=0;
  my %tx; #hash of array [$avgtx,$amount1,$amount2,...], used amounts are set to undef
  do {
    my $ret = fetchData($pos);
    my @tx = @{$ret->{tx}};
    my $fees=0.0;
    my $feescount=0.0;
    my $feesgen=0.0;
    foreach my $tx (@tx[1..$#tx],$tx[0]) {
      my $amount=0.0;
      my $txcount=0.0;
      my $txgen=0.0;
      my $txhash=$tx->{hash};
      foreach my $in (@{$tx->{in}}) {
        if (exists $in->{coinbase}) {
          $amount += 5000000000.0;
          $amount += $fees;
          $txcount += $feescount;
          $txgen += 5000000000.0*$pos;
          $txgen += $feesgen;
          $fees = 0.0;
          $feescount = 0.0;
          $feesgen = 0.0;
        } else {
          my $prevtx = $in->{prev_out}->{hash};
          my $prevn  = $in->{prev_out}->{n};
          if (exists $tx{$prevtx}) {
            if (exists $tx{$prevtx}->[1+$prevn]) {
              my $prevtxcount = $tx{$prevtx}->[0]->[0];
              my $prevtxgen   = $tx{$prevtx}->[0]->[1];
              my $prevamount = $tx{$prevtx}->[1+$prevn];
              if ($prevamount == (-1)) {
                print STDERR "\nblock $pos: double spending!\n";
              } else {
                $amount += $prevamount;
                $txcount += $prevamount*($prevtxcount+1);
                $txgen   += $prevamount*$prevtxgen;
                $tx{$prevtx}->[1+$prevn]=(-1);
              }
            } else {
              print STDERR "\nblock $pos: reference to unknown transaction output\n";
            }
          } else {
            print STDERR "\nblock $pos: reference to unknown transaction\n";
          }
        }
      }
      if ($amount >= 0) {
        my @add=[$txcount/$amount,$txgen/$amount];
        my $tspent=0;
        foreach my $out (@{$tx->{out}}) {
          my $value=int($out->{value}*100000000+0.5);
          if ($value<0) {
            print STDERR "\nblock $pos: invalid amount output\n";
          } else {
            push @add,$value;
          }
          $tspent += $value;
        }
        $tx{$txhash}=\@add;
        if ($tspent>$amount) {
          print STDERR "\nblock $pos: inputs and outputs don't match by ",($amount-$tspent),"\n";
        }
        $fees += $amount - $tspent;
        $feescount += ($amount-$tspent)*(1.0 + ($txcount/$amount));
      } else {
        print STDERR "\nblock $pos: amount ($amount) < 0\n";
      }
    }
    if ($fees > 0.0) {
      print STDERR "\nblock $pos: $fees fees unspent\n";
    }
    print STDERR "\r                                     \rblock $pos";
    $pos++;
  } while ($pos<$maxpos);
  print STDERR "\r                                       \n";

#  my %res;
#  foreach my $tx (values %tx) {
#    my @tx=@{$tx};
#    my $avgtx=$tx[0]->[0];
#    foreach my $amount (@tx[1..$#tx]) {
#      $res{$avgtx} += $amount if ($amount > 0);
#    }
#  }
#  my $sum=0;
#  foreach my $avgtx (sort { $a <=> $b } (keys %res)) {
#    print $sum," ",$avgtx,"\n";
#    $sum += $res{$avgtx};
#    print $sum," ",$avgtx,"\n";
#  }

  my %res;
  foreach my $tx (values %tx) {
    my @tx=@{$tx};
    my $avgtx=$tx[0]->[0];
    my $avggen=$tx[0]->[1];
    foreach my $amount (@tx[1..$#tx]) {
      if ($amount > 0) {
        if (exists $res{$avggen}) {
          $res{$avggen}->[0] += $amount;
          $res{$avggen}->[1] += $amount*$avgtx;
        } else {
          $res{$avggen} = [$amount,$amount*$avgtx];
        }
      }
    }
  }
  my $sum=0.0;
  foreach my $avggen (sort { $a <=> $b } (keys %res)) {
    print $sum," ",$res{$avggen}->[1]/$res{$avggen}->[0]," ",$avggen,"\n";
    $sum += $res{$avggen}->[0];
    print $sum," ",$res{$avggen}->[1]/$res{$avggen}->[0]," ",$avggen,"\n";
  }
}

$|=1;

procLoop(100698);
