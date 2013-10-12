#define _POSIX_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

typedef struct {
  double time;
  double weight;
  double diff;
  int used;
} event_t;

int proc(FILE *input, int interval, int pstart) {
  event_t *events=malloc(sizeof(event_t)*interval);
  int pos=0;
  int go=0;
  int tel=0;
  for (int i=0; i<interval; i++) {
    events[i].time=0;
    events[i].weight=0;
    events[i].diff=0;
    events[i].used=0;
  }
  double sum=0,count=0;
  int amount=0;
  do {
    char c[256];
    char *s=fgets(c,256,input);
    if (s) {
      int num=0,tx=0;
      double start,stop,diff,weight;
      int ret=sscanf(s," %i (%lg,%lg) %lg %lg %i",&num,&start,&stop,&diff,&weight,&tx);
//      printf("got block %i (diff %g, weight %g, %i tx)\n",num,diff,weight,tx);
      if (ret>=5) {
        if (go) {
          double ocount=count,osum=sum;
          count -= events[pos].weight;
          sum   -= events[pos].diff;
          amount-= events[pos].used;
          events[pos].time=(start+stop)*0.5;
          events[pos].weight=weight;
          events[pos].diff=diff*weight;
          events[pos].used=1;
          count += events[pos].weight;
          sum   += events[pos].diff;
          amount+= events[pos].used;
//          printf("pos=%i tel=%i: time=%.17g count=%.17g->%.17g sum=%.17g->%.17g\n",pos,tel,events[pos].time,ocount,count,osum,sum);
          int opos=pos;
          pos=(opos+1) % interval;
          tel++;
          if (pos==0) {
            double tcount=count-0.5*(events[pos].weight+events[opos].weight);
            double tsum  =sum  -0.5*(events[pos].diff+events[opos].diff);
            double tamount=amount-1;
            double begin = events[pos].time;
            double end   = events[opos].time;
            printf("%.17g %.17g # range=[%.17g..%.17g] count=%.17g sum=%.17g\n",(begin+end)*0.5,tsum*tamount/(tcount*(end-begin))*4.295032833,begin,end,tcount,tsum);
          }
        }
      }
      if (num>=pstart) {
//        if (!go) { lasttime=r.time; }
        go++;
      }
    } else {
      break;
    }
  } while(1);
//  printf("current speed estime: %.4gGH/s (average %.4gGH/s)\n",N*N/T/tau*4.294967296,N/tau*4.294967296);
//  printf("current growth estimate: %.3f%%/day\n",100.0*(exp((N/T-1.0)/tau*86400)-1.0));
  return 1;
}

int main(int argc, char **argv) {
  int num=432;
  if (argc>1) num=strtol(argv[1],NULL,0);
  int start=0;
  if (argc>2) start=strtol(argv[2],NULL,0);
  proc(stdin,num,start);
  return 0;
}
