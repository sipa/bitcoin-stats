set xdata time
set xlabel "Date"
set ylabel "million BTC"
set timefmt "%s"
# set format x "%b '%y"
set key bottom right
set xzeroaxis
set grid x y
set title "Bitcoin network: total monetary supply"
set terminal png large enhanced size 1280,800
set output "inflation.png"
plot "inflation.dat" using 2:(($3)/1000000) with line title "Bitcoin supply"

set terminal png small enhanced size 2560,1440
set output "inflation-larger.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "inflation-small.png"
replot
