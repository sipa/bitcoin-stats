#!/bin/bash

for WIDTH in 2k 10k 50k ever; do
  WIDTHEXT="-ever"
  MIN="0.001"
  if [ "d$WIDTH" == "d2k" ]; then
    WIDTHEXT="-2k"
    MIN="1000000000.0"
  elif [ "d$WIDTH" == "d10k" ]; then
    WIDTHEXT="-10k"
    MIN="1000000000.0"
  elif [ "d$WIDTH" == "d50k" ]; then
    WIDTHEXT=""
    MIN="100000000.0"
  fi
  for SIZE in small medium large; do
    SIZEEXT=""
    TERM="1280,800 font \"Verdana,12\""
    FORMATX="\"%b '%y\""
    if [ "d$SIZE" == "dsmall" ]; then
      SIZEEXT="-small"
      TERM="720,480 font \"Verdana,9\""
      FORMATX="\"%m'%y\""
    elif [ "d$SIZE" == "dlarge" ]; then
      SIZEEXT="-large"
      TERM="2560,1440 font \"Verdana,16\""
    fi
    for LOG in lin log; do
      LOGEXT=""
      if [ "d$LOG" == "dlin" ]; then
        LOGEXT="-lin"
      fi
      echo "fact = 139.696254564"
      echo "min = $MIN"
      echo "max = 3000000000.0"
      echo "emax = 5000000000.0"
      echo "set xdata time"
      echo "set xlabel \"Date\""
      echo "set ylabel \"PHash/s\""
      echo "set y2label \"Billion difficulty\""
      echo "set timefmt \"%s\""
      if [ "d$WIDTH" == "2k" ]; then
        echo "unset format x"
      else
        echo "set format x $FORMATX"
      fi
      echo "set key top left"
      echo "set title \"Bitcoin network: total computation speed\""
      echo "set terminal pngcairo enhanced size $TERM"
      echo "set output \"speed${SIZEEXT}${LOGEXT}${WIDTHEXT}.png\""
      echo "set ytics nomirror tc lt -1"
      echo "set y2tics nomirror tc lt -1"
      echo "set grid x y"
      if [ "d$LOG" == "dlog" ]; then
        echo "set yrange [min/1000000 to emax/1000000]"
        echo "set y2range [min*fact/1000000000 to emax*fact/1000000000]"
        echo "set logscale y"
        echo "set logscale y2"
      else
        echo "set yrange [min/1000000 to max/1000000]"
        echo "set y2range [min*fact/1000000000 to max*fact/1000000000]"
        echo "unset logscale y"
        echo "unset logscale y2"
        echo "unset mytics"
        echo "unset my2tics"
      fi

      echo "plot \"diff-${WIDTH}.dat\" using 1:((\$2)/1000000) with line title \"difficulty\", \\"
      if [ "d$WIDTH" == "d2k" ]; then
        echo "     \"predictD-${WIDTH}.dat\" using 1:((\$2)/1000000) with line title \"1-day window estimate\", \\"
      fi
      if [ "d$WIDTH" == "d2k" -o "d$WIDTH" == "d10k" ]; then
        echo "     \"predict3D-${WIDTH}.dat\" using 1:((\$2)/1000000) with line title \"3-day window estimate\", \\"
      fi
      echo "     \"predictW-${WIDTH}.dat\" using 1:((\$2)/1000000) with line title \"7-day window estimate\", \\"
      if [ "d$WIDTH" != "d2k" ]; then
        echo "     \"predict2W-${WIDTH}.dat\" using 1:((\$2)/1000000) with line title \"14-day window estimate\", \\"
      fi
      if [ "d$WIDTH" == "dever" ]; then
        echo "     \"predictM-${WIDTH}.dat\" using 1:((\$2)/1000000) with line title \"30-day window estimate\", \\"
      fi
      echo
    done
  done
done
