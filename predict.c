#define _POSIX_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

typedef struct {
  double tau;
  double time;
  double S0,S1,S2,S3,S4;
} ravg_t;

void static inline ravg_move(ravg_t *r, double t) {
  if (t>r->time) {
    double dist=(t-r->time)/r->tau;
    double factor=exp(-dist);
    r->S0 = r->S0*factor;
    r->S1 = r->S1*factor +                                                   dist*r->S0;
    r->S2 = r->S2*factor +                                  dist*( 2.0*r->S1-dist*r->S0);
    r->S3 = r->S3*factor +                 dist*( 3.0*r->S2+dist*(-3.0*r->S1+dist*r->S0));
    r->S4 = r->S4*factor + dist*(4.0*r->S3+dist*(-6.0*r->S2+dist*( 4.0*r->S1-dist*r->S0)));
    r->time=t;
  }
}

void static inline ravg_event(ravg_t *r, double weight, double t) {
  ravg_move(r,t);
  double age=(r->time-t)/r->tau;
  double cw = weight*exp(-age);
  r->S0 += cw;
  r->S1 += cw*age;
  r->S2 += cw*age*age;
  r->S3 += cw*age*age*age;
}

/*
void static inline ravg_event_interval(ravg_t *r, double weight, double begin, double end) {
  ravg_move(r,end);
  double width=(begin-end)/r->tau; // negative number!
  if (width>=0) {
    N += weight;
  } else {
    N += weight*(expm1(width)/width);
    T += weight*(expm1(width)/width-exp(width));
  }
}
*/



int proc(FILE *input, double tau, double interval,int pstart, double effect, int skip) {
  double lasttime=0.0; // time of last ouputted data
  char c[256];
  ravg_t r={.tau=tau, .time=0, .S0=0, .S1=0, .S2=0, .S3=0};
  double aRate=0.0,aGrowth=0.0,aTime=0.0,aCorr=0.0;
  double maxrate=0.0, ghdays=0.0, powdays=0.0;
  int go=0;
  int skipped=0;
  do {
    char *s=fgets(c,256,input);
    if (s) {
      int num=0,tx=0,ver=0;
      double start=0.0,stop=0.0,diff=0.0,weight=0.0;
      int ret=sscanf(s," %i (%lg,%lg) %lg %lg %i %i",&num,&start,&stop,&diff,&weight,&tx,&ver);
//      printf("N=%.17g T=%.17g: got block %i (diff %g, weight %g, %i tx)\n",N,T,num,diff,weight,tx);
      if (ret>=5) {
        while (go && lasttime+interval<start) {
          lasttime += interval;
          ravg_move(&r,lasttime);
          double N=r.S0, T=r.S1/r.S0;
          double age=(lasttime-r.time)/tau;
          double lRate=log(N/T/tau*4.294967296)+(1.0/T-1.0)*age; // log() of rate estimate in Gh/s
          double lGrowth=(1.0/T-1.0)/tau*86400.0; // log() of daily growth factor
//          printf("# %.17g %.17g %.17g\n",r.time,exp(lRate),exp(lGrowth));
          aRate = aRate*(1.0-effect)+lRate*effect;       // accumulated log() of rate estime
          aGrowth = aGrowth*(1.0-effect)+lGrowth*effect; // accumulated log() of growth estime
          aTime = aTime*(1.0-effect)+r.time*effect;      // accumulated time
          aCorr = aCorr*(1.0-effect)+effect;             // accumulated weight (correction for previous values)
          if (exp(aRate/aCorr) > maxrate)
              maxrate = exp(aRate/aCorr);
          skipped++;
          if (skipped==skip) {
            skipped=0;
            printf("%.17g %.17g %.17g %.17g\n",aTime/aCorr,exp(aRate/aCorr),exp(aGrowth/aCorr),powdays);
          }
        }
//        fprintf(stderr,"# weight=%g diff=%g r.N=%g r.T=%g\n",weight,diff,r.N,r.T);
        ravg_event(&r,weight*diff,start);
        ghdays += diff/20116.26065723248757421970;
        powdays = ghdays/maxrate;
        if (num>=pstart) {
          if (!go) { lasttime=r.time; }
          go++;
        }
//        fprintf(stderr,"# weight=%g diff=%g r.N=%g r.T=%g\n",weight,diff,r.N,r.T);
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
  double tau=500000;
  if (argc>1) tau=strtod(argv[1],NULL);
  double interval=tau*0.25;
  if (argc>2) interval=strtod(argv[2],NULL);
  int start=0;
  if (argc>3) start=strtol(argv[3],NULL,10);
  double effect=0.50;
  if (argc>4) effect=strtod(argv[4],NULL);
  int samples=64;
  if (argc>5) samples=strtol(argv[5],NULL,10);
  proc(stdin,tau,interval/samples,start,1.0-pow(1.0-effect,1.0/samples),samples);
  return 0;
}
