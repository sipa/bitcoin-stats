set xdata time
set xlabel "Date"
set ylabel "%/day"
set timefmt "%s"
set format x "%b '%y"
set key bottom right
set xzeroaxis
#set yrange [-2 to 8]
set grid x y
set title "Bitcoin network: computation speed growth"
set terminal png large enhanced size 1280,800
set output "growth.png"
plot "predictW-50k.dat" using 1:((($3)-1)*100) with line title "7-day estimate for growth", \
     "predict2W-50k.dat" using 1:((($3)-1)*100) with line title "14-day estimate for growth", \
     "predictM-50k.dat" using 1:((($3)-1)*100) with line title "30-day estimate for growth"

set terminal png small enhanced size 2560,1440
set output "growth-large.png"
replot

set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "growth-small.png"
replot
