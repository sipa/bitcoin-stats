#!/usr/bin/perl -w

use strict;
use JSON::RPC::Client;
use Data::Dumper;
use Math::BigRat;

open URI, "<uri.secret";
my $URI = <URI>;
close URI;

my $client = new JSON::RPC::Client;

sub fetchData {
  my ($bn) = @_;
  my $callobj = {
    method => 'getblockbycount',
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

sub dumpTx {
  my ($tx) = @_;
  my @ins = map { "In \"".($_->[0])."\" $_->[1]" } (@{$tx->[1]});
  my @outs = @{$tx->[2]};
  return "Tx \"$tx->[0]\" [".join(", ",@ins)."] [".join(", ",@outs)."]";
}

sub procLoop {
  my ($maxpos) = @_;
  my $pos=0;
  my %tx; #hash of array [$avgtx,$amount1,$amount2,...], used amounts are set to undef
  do {
    my $ret = fetchData($pos);
    my @tx = @{$ret->{tx}};
    my $gtx;
    my @otx;
    foreach my $tx (@tx) {
      my $gentx=0;
      my @inputs=();
      my @outputs=();
      foreach my $in (@{$tx->{in}}) {
        if (exists $in->{coinbase}) {
          $gentx=1;
        } else {
          my $prevtx = $in->{prev_out}->{hash};
          my $prevn  = $in->{prev_out}->{n};
          push @inputs,[$prevtx,$prevn];
        }
      }
      foreach my $out (@{$tx->{out}}) {
        my $value=(Math::BigRat->new($out->{value})*100000000)->as_int;
        push @outputs,$value;
      }
      if ($gentx) {
        $gtx=[$tx->{hash},\@inputs,\@outputs];
      } else {
        push @otx,[$tx->{hash},\@inputs,\@outputs];
      }
    }
    print "Block $pos (".dumpTx($gtx).") [".(join(", ",map { dumpTx($_) } @otx))."]\n";
    $pos++;
  } while ($pos<$maxpos);
}

procLoop(100519);
