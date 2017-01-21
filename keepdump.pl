#!/usr/bin/perl -w

use strict;
use JSON::RPC::Client;
use JSON;
use Data::Dumper;

use IO::Socket::INET;

my $port = 7777;
my $file = "dump";
my $db = "keepdump.dat";

open URI, "<uri.secret";
my $URI = <URI>;
close URI;

my $JSON = new JSON;
my $client = new JSON::RPC::Client;

my @data;

sub loadDb {
    if (-f $db) {
        open FILE,"<$db";
        while (<FILE>) {
            chomp;
            my ($id,$hash,$ts,$diff,$tx,$version,$size) = split(/ /,$_);
            $data[$id]=[$hash,$ts,$diff,$tx,$version,$size];
        }
        close FILE;
    }
}


sub fetch {
  my ($cmd,@args) = @_;
  my $callobj = {
    method => "$cmd",
    params => \@args
  };
  do {
    my $res = $client->call($URI, $callobj);
    if($res) {
      if ($res->is_error) {
        print "Error : ", $res->error_message;
        print "Call: ",Dumper($callobj),"\n";
        exit;
      }
      return $res->result;
    }
    print STDERR "Failed to fetch data. Retry in 30 seconds.\n";
    sleep 30;
  } while(1);
}

my $updated = 0;

sub update {
    my $blkcount = fetch("getblockcount");
    my $blkhash = fetch("getblockhash", $blkcount);
    while($blkhash) {
        last if (defined $data[$blkcount] && $data[$blkcount]->[0] eq $blkhash);
        my $blk = fetch("getblock", $blkhash);
        $data[$blkcount] = [$blkhash, $blk->{time}, $blk->{difficulty}, $#{$blk->{tx}}+1, $blk->{version}, $blk->{size}];
        print "Update #$blkcount: hash=$blkhash time=$blk->{time} diff=$blk->{difficulty} tx=",($#{$blk->{tx}}+1)," ver=$blk->{version} size=$blk->{size}\n";
        $updated++;
        $blkcount--;
        $blkhash = $blk->{previousblockhash};
    }
}

sub dumper {
    return if ($updated == 0);
    open FILE,">${file}.new";
    for my $i (0..$#data) {
        print FILE "$i ($data[$i]->[1],$data[$i]->[1]) $data[$i]->[2] 1 $data[$i]->[3] $data[$i]->[4] $data[$i]->[5]\n";
    }
    close FILE;
    rename "${file}.new","${file}";
    open FILE,">${db}.new";
    for my $i (0..$#data) {
        print FILE "$i $data[$i]->[0] $data[$i]->[1] $data[$i]->[2] $data[$i]->[3] $data[$i]->[4] $data[$i]->[5]\n";
    }
    close FILE;
    rename "${db}.new","${db}";
    $updated = 0;
}

loadDb;
update;
dumper;
