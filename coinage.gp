set xlabel "Coins moved in the last X days"
set ylabel "Age in days"
set y2label "BTC"
set autoscale ymax
set autoscale y2max
set xrange [0:1000]
set y2tics
set grid x y
set title "Coin age"
set terminal png large enhanced size 1280,800
set output "coinage.png"
plot "coinage.dat" using 1:5 with line title "Average age", \
     "coinage.dat" using 1:(($1)/3) with line title "1/3 of theoretical maximum age", \
     "coinage.dat" using 1:4 axes x1y2 with line title "Total amount"

set terminal png small enhanced size 2560,1440
set output "coinage-large.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "coinage-small.png"
replot
