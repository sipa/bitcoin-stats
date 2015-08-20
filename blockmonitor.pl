#!/usr/bin/perl -w

use strict;
use JSON::RPC::Client;
use JSON;
use Data::Dumper;

use IO::Socket::INET;

open URI, "<uri.secret";
my $URI = <URI>;
close URI;

my $port = 7777;
my $file = "dump";

my $JSON = new JSON;
my $client = new JSON::RPC::Client;

open FILE,"<$file";

my $count=0;

$|=1;

sub fetchData {
  my ($bn) = @_;
  my $callobj = {
    method => 'getblock',
    params => [0+$bn]
  };
  do {
    my $res = $client->call($URI, $callobj);
    if($res) {
      if ($res->is_error) {
        print "Error : ", $res->error_message;
        exit;
      }
      return $res->result;
    }
    print STDERR "Failed to fetch data. Retry in 30 seconds.\n";
    sleep 30;
  } while(1);
}

while (<FILE>) {
  chomp;
  if ($_ =~ /\s*(\d+)\s*\((\d+),(\d+)\)\s*([0-9.]+)\s*([0-9.]+)\s*([0-9.]+)\s*/) {
    my $blkid=$1;
    $count=$blkid if ($blkid>$count);
  }
}

sub proc {
  my ($json) = @_;
  my $num=$json->{blockcount};
  return if ($num<=$count);
  while ($json->{blockcount} > $count+1) {
    proc(fetchData($count+1));
  }
  open FILE,">>$file";
  print FILE "$num ($json->{time},$json->{time}) $json->{difficulty} 1 $#{$json->{tx}}\n";
  close FILE;
  print "\r          \r$num";
  $count=$num;
}

print Dumper(fetchData($count)),"\n";

my $socket = IO::Socket::INET->new('LocalPort' => $port, Proto => 'tcp', Listen => SOMAXCONN)  or die "Can't create socket ($!)\n";
print "Server listening...\n";
while (my $client = $socket->accept) {
#  my $name = gethostbyaddr($client->peeraddr, AF_INET);
#  my $port = $client->peerport;
  my $json;
#  print "Connection coming in\n";
  while (<$client>) {
    my $data=$_;
    eval {
      $json=$JSON->decode($_);
    };
    last if (defined $json);
  }
#  print "Closing connection\n";
  close $client or die "Can't close ($!)\n";
  if (defined $json) {
    proc($json->{params}->[0]);
  }
}
die "Can't accept socket ($!)\n";

