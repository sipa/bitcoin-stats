fact = 139.696254564
min = 20000
emin = 20000
set xdata time
set xlabel "Date"
set ylabel "Thash/s"
set y2label "Million difficulty"
set timefmt "%s"
#set format x "%b '%y"
set key top left
set title "Bitcoin network: total computation speed"
set terminal pngcairo enhanced size 1280,800 font 'Verdana,10'
set output "speed-10k.png"
set yrange [emin/1000 to max/1000]
set y2range [emin*fact/1000000 to emax*fact/1000000]
set ytics nomirror tc lt -1
set ytics (0.1,0.2,0.5,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000,20000,50000,100000,200000)
set y2tics nomirror tc lt -1
set y2tics (0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200,500,1000)
set logscale y
set logscale y2
set mytics 10
set my2tics 10
set y2tics nomirror tc lt -1
set grid x y
set pointsize 2
plot "diff-10k.dat" using 1:(($2)/1000) with line title "difficulty", \
     "predictD-10k.dat" using 1:(($2)/1000) with line title "1-day window estimate", \
     "predict3D-10k.dat" using 1:(($2)/1000) with line title "3-day window estimate", \
     "predictW-10k.dat" using 1:(($2)/1000) with line title "7-day window estimate", \
     "slide-500-10k.dat" using 1:(($2)/1000) with points title "500-block sliding window"

set terminal pngcairo enhanced size 2560,1440 font 'Verdana,16'
set output "speed-large-10k.png"
replot

#set format x "%m'%y"
set terminal pngcairo enhanced size 720,480 font 'Verdana,12'
set output "speed-small-10k.png"
replot

unset logscale y
unset logscale y2
unset mytics
unset my2tics
unset ytics
unset y2tics
set ytics nomirror tc lt -1
set y2tics nomirror tc lt -1
set yrange [0 to max/1000]
set y2range [0 to max*fact/1000000]
#set format x "%b '%y"
set terminal pngcairo enhanced size 1280,800 font 'Verdana,12'
set output "speed-lin-10k.png"
replot

set terminal pngcairo enhanced size 2560,1440 font 'Verdana,16'
set output "speed-large-lin-10k.png"
replot


#set format x "%m'%y"
set terminal pngcairo enhanced size 720,480 font 'Verdana,9'
set output "speed-small-lin-10k.png"
replot
