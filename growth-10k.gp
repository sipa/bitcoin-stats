set xdata time
set xlabel "Date"
set ylabel "%/day"
set timefmt "%s"
# set format x "%b '%y"
set key bottom right
set xzeroaxis
set grid x y
set title "Bitcoin network: computation speed growth"
set terminal png large enhanced size 1280,800
set output "growth-10k.png"
plot "predict3D-10k.dat" using 1:((($3)-1)*100) with line title "3-day estimate for growth", \
     "predictW-10k.dat" using 1:((($3)-1)*100) with line title "7-day estimate for growth", \
     "predict2W-10k.dat" using 1:((($3)-1)*100) with line title "14-day estimate for growth"

set terminal png small enhanced size 2560,1440
set output "growth-large-10k.png"
replot

# set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "growth-small-10k.png"
replot
