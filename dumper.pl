#!/usr/bin/perl -w

use strict;
use JSON::RPC::Client;

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
      my $nbits=$res->result->{bits};
      my $diff= 2.0**(224-8*(($nbits>>24)-3)) / ($nbits & 0xFFFFFF);
      return ($res->result->{time},$diff,$#{$res->result->{tx}},$res->result->{version});
    }
    print STDERR "Failed to fetch data. Retry in 30 seconds.\n";
    sleep 30;
  } while(1);
}

sub procLoop {
  my ($minpos,$maxpos) = @_;
  my $pos=$minpos;
  do {
    my ($time,$diff,$ntx) = fetchData($pos);
    print "$pos ($time,$time) $diff 1 $ntx $version\n";
    $pos++;
  } while ($pos<$maxpos);
}

$|=1;

procLoop(100700,100776);
