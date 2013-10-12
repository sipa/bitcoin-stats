#!/usr/bin/perl -w

use strict;
use JSON;
use WWW::Mechanize;
use Time::Local;

my $mech = WWW::Mechanize->new();

my $URI = 'http://mining.bitcoin.cz/stats/json/?history=1000';

$mech->get($URI);

my $content = $mech->content;

my $json = decode_json $content;

sub parseDate {
  my ($str) = @_;
  if ($str =~ /(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)/) {
    return timegm($6,$5,$4,$3,$2-1,$1);
  }
}

for my $num (sort { $a+0 <=> $b+0 } (keys %{$json->{blocks}})) {
  my $block=$json->{blocks}->{$num};
  my $start=parseDate $block->{date_started};
  my $stop=parseDate $block->{date_found};
  my $diff=$block->{total_shares};
  print "$num ($start,$stop) 1 $diff\n";
}

