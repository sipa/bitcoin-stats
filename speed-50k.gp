fact = 139.696254564
min = 10000
emin = 10000
set xdata time
set xlabel "Date"
set ylabel "Thash/s"
set y2label "Million difficulty"
set timefmt "%s"
set format x "%b '%y"
set key top left
set title "Bitcoin network: total computation speed"
set terminal png large enhanced size 1280,800
set output "speed.png"
set yrange [emin/1000 to emax/1000]
set y2range [emin*fact/1000000 to emax*fact/1000000]
set ytics nomirror tc lt -1
set logscale y
set logscale y2
#set mytics 10
#set my2tics 10
set y2tics nomirror tc lt -1
set grid x y
plot "diff-50k.dat" using 1:(($2)/1000) with line title "difficulty", \
     "predict3D-50k.dat" using 1:(($2)/1000) with line title "3-day window estimate", \
     "predictW-50k.dat" using 1:(($2)/1000) with line title "7-day window estimate", \
     "predict2W-50k.dat" using 1:(($2)/1000) with line title "14-day window estimate"


set terminal png large enhanced size 2560,1440
set output "speed-large.png"
replot

set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "speed-small.png"
replot

unset logscale y
unset logscale y2
unset mytics
unset my2tics
set yrange [0 to max/1000]
set y2range [0 to max*fact/1000000]
set format x "%b '%y"
set terminal png large enhanced size 1280,800
set output "speed-lin.png"
replot

set terminal png large enhanced size 2560,1440
set output "speed-large-lin.png"
replot


set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "speed-small-lin.png"
replot
