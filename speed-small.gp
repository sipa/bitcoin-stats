set xdata time
set timefmt "%s"
set format x "%d"
set key off
set terminal png small enhanced size 320,180
set output "speed-thumbnail.png"
#set yrange [1000 to 3000]
#set y2range [139696.25 to 419088.76]
#set mytics 10
#set my2tics 10
set grid y
set mxtics 7
plot "predictD-1k.dat" using 1:2 with line, \
     "predictDs-1k.dat" using 1:2 with line, \
     "diff-1k.dat" using 1:2 with line

