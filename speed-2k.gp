fact = 139.696254564
min = 400000
emin = 200000
set xdata time
set xlabel "Date"
set ylabel "Thash/s"
set y2label "Million ifficulty"
set timefmt "%s"
#set format x "%b '%y"
set key top left
set title "Bitcoin network: total computation speed"
set terminal png large enhanced size 1280,800
set output "speed-2k.png"
set yrange [emin/1000 to emax/1000]
set y2range [emin*fact/1000000 to emax*fact/1000000]
set ytics nomirror tc lt -1
set ytics (100,200,500,1000,2000,5000,10000,20000,50000,100000,200000,500000)
set y2tics nomirror tc lt -1
set y2tics (1,2,5,10,20,50,100,200,500,1000)
set logscale y
set logscale y2
set mytics 10
set my2tics 10
set grid x y
plot "diff-2k.dat" using 1:(($2)/1000) with line title "difficulty", \
     "predict8H-2k.dat" using 1:(($2)/1000) with line title "8-hour window estimate", \
     "predictD-2k.dat" using 1:(($2)/1000) with line title "1-day window estimate", \
     "predict3D-2k.dat" using 1:(($2)/1000) with line title "3-day window estimate", \
     "slide-200-2k.dat" using 1:(($2)/1000) with points title "200-block sliding window"

set terminal png large enhanced size 2560,1440
set output "speed-large-2k.png"
replot

#set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "speed-small-2k.png"
replot

unset logscale y
unset logscale y2
unset mytics
unset my2tics
unset ytics
unset y2tics
set y2tics nomirror tc lt -1
set ytics nomirror tc lt -1
set yrange [0 to max/1000]
set y2range [0 to max*fact/1000000]
#set format x "%b '%y"
set terminal png large enhanced size 1280,800
set output "speed-lin-2k.png"
replot

set terminal png large enhanced size 2560,1440
set output "speed-large-lin-2k.png"
replot


#set format x "%m'%y"
set terminal png small enhanced size 720,480
set output "speed-small-lin-2k.png"
replot
