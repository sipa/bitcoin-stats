#!/bin/bash

cd /home/pw/bitcoin/stats

if [ -f pidfile ]; then
  exit
fi

echo $$ >pidfile

rm *.png

./keepdump.pl >/dev/null
./totalhashes.pl                            <dump >hashes.dat

BLOCKS=$(tail -n 1 <dump | cut -d ' ' -f 1)

START=2016
./predict 2592000       $((3600*24)) $START <dump >predictM-ever.dat
./predict $((604800*2)) $((3600*14)) $START <dump >predict2W-ever.dat
./predict 604800        $((3600*7))  $START <dump >predictW-ever.dat
./predict $((86400*3))  $((3600*3))  $START <dump >predict3D-ever.dat
./predict 86400         3600         $START <dump >predictD-ever.dat
./predict 28800         1200         $START <dump >predict8H-ever.dat
./slide   1000                       $START <dump >slide-1000-ever.dat
./slide   500                        $START <dump >slide-500-ever.dat
./difflist.pl                        $START <dump >diff-ever.dat
./verpct.pl                          $START <dump >ver-ever.dat

START=$(($BLOCKS-50400))
./predict 2592000       $((3600*24)) $START <dump >predictM-50k.dat
./predict $((604800*2)) $((3600*14)) $START <dump >predict2W-50k.dat
./predict 604800        $((3600*7))  $START <dump >predictW-50k.dat
./predict $((86400*3))  $((3600*3))  $START <dump >predict3D-50k.dat
./predict 86400         3600         $START <dump >predictD-50k.dat
./predict 28800         1200         $START <dump >predict8H-50k.dat
./slide   500                        $START <dump >slide-500-50k.dat
./slide   200                        $START <dump >slide-200-50k.dat
./difflist.pl                        $START <dump >diff-50k.dat
./verpct.pl                          $START <dump >ver-50k.dat

START=$(($BLOCKS-10080))
./predict 2592000       $((3600*24)) $START <dump >predictM-10k.dat
./predict $((604800*2)) $((3600*14)) $START <dump >predict2W-10k.dat
./predict 604800        $((3600*7))  $START <dump >predictW-10k.dat
./predict $((86400*3))  $((3600*3))  $START <dump >predict3D-10k.dat
./predict 86400         3600         $START <dump >predictD-10k.dat
./predict 28800         1200         $START <dump >predict8H-10k.dat
./slide   500                        $START <dump >slide-500-10k.dat
./slide   200                        $START <dump >slide-200-10k.dat
./difflist.pl                        $START <dump >diff-10k.dat
./verpct.pl                          $START <dump >ver-10k.dat

START=$(($BLOCKS-2016))
./predict 2592000       $((3600*24)) $START <dump >predictM-2k.dat
./predict $((604800*2)) $((3600*14)) $START <dump >predict2W-2k.dat
./predict 604800        $((3600*7))  $START <dump >predictW-2k.dat
./predict $((86400*3))  $((3600*3))  $START <dump >predict3D-2k.dat
./predict 86400         3600         $START <dump >predictD-2k.dat
./predict 28800         1200         $START <dump >predict8H-2k.dat
./slide   500                        $START <dump >slide-500-2k.dat
./slide   200                        $START <dump >slide-200-2k.dat
./difflist.pl                        $START <dump >diff-2k.dat
./verpct.pl                          $START <dump >ver-2k.dat

START=$(($BLOCKS-1008))
./predict 86400         1200         $START 0.3  <dump >predictD-1k.dat
./predict 86400         1200         $START 0.06 <dump >predictDs-1k.dat
./difflist.pl                        $START <dump >diff-1k.dat
./verpct.pl                          $START <dump >ver-1k.dat

gnuplot growth-50k.gp
gnuplot growth-10k.gp
gnuplot growth-2k.gp

gnuplot limits.gp speed-ever.gp
gnuplot limits.gp speed-50k.gp
gnuplot limits.gp speed-10k.gp
gnuplot limits.gp speed-2k.gp

gnuplot speed-small.gp

gnuplot hashes.gp

gnuplot powdays-ever.gp
gnuplot powdays-50k.gp

gnuplot work-ever.gp
gnuplot work-50k.gp

gnuplot ver-2k.gp
gnuplot ver-10k.gp
gnuplot ver-50k.gp
gnuplot ver-ever.gp

tail -n 1 predict3D-10k.dat | cut -d ' ' -f 2 >speed-3D.txt

cp *.png *.html *.css *txt /var/www/
gzip --best <~/git/bitcoin-seeder/dnsseed.dump >/var/www/seeds.txt.gz

rm -f pidfile
