#define _POSIX_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "alist.h"

#define RANGE 16

typedef struct {
  int num;
  double start;
  double stop;
  double difficulty;
  double weight;
} event_t;

typedef struct {
  alist_declare(event_t,list);
} events_t;

typedef struct {
  double val;
  double w;
  double avg_daily_growth;
  double direct_daily_growth;
  double difficulty;
} graphel_t;

typedef struct {
  time_t base;
  size_t count;
  double interval;
  graphel_t *val;
} graph_t;

int compare_events(const event_t *a, const event_t *b) {
  if (a->start+a->stop < b->start+b->stop) return -1;
  if (b->start+b->stop < a->start+b->stop) return 1;
  return 0;
}

void read_events(FILE *file, events_t *events) {
  alist_init(events->list);
  char c[256];
  do {
    char *s=fgets(c,256,file);
    if (s) {
      event_t new;
      int ret=sscanf(s," %i (%lg,%lg) %lg %lg",&new.num,&new.start,&new.stop,&new.difficulty,&new.weight);
      new.difficulty *= new.weight;
      if (ret==5) {
        alist_add(events->list,new);
      }
    } else {
      break;
    }
  } while(1);
  qsort(alist_ptr(events->list,0),alist_len(events->list),sizeof(event_t),(int (*)(const void*, const void*))compare_events);
}

void init_graph(graph_t *graph, time_t begin, time_t end, int interval) {
  unsigned long dur=end-begin;
  graph->base=begin;
  graph->count=dur/interval+1;
  graph->interval=interval;
  graph->val=malloc(graph->count*sizeof(graphel_t));
  for (int i=0; i<graph->count; i++) {
    graph->val[i].val=0.0;
    graph->val[i].w=0.0;
    graph->val[i].avg_daily_growth=0.0;
    graph->val[i].direct_daily_growth=0.0;
  }
}

double static inline get_weight(double pos, double mu, double sigma) {
  return exp(-(pos-mu)*(pos-mu)/(2.0*sigma*sigma))/(2.5066282746310005*sigma);
}

// calculate average of weight between start and stop
double static inline get_weight_range(double start, double stop, double mu, double sigma) {
  if (start==stop) return get_weight(0.5*(start+stop),mu,sigma);
  double startw=erf((start-mu)/(1.4142135623730950*sigma));
  double stopw= erf((stop-mu)/(1.4142135623730950*sigma));
//  if (stopw/startw<1.0000001) return get_weight(0.5*(start+stop),mu,sigma);
  return (0.5*(stopw-startw))/(stop-start);
}

double static inline get_weight_t(double pos, double mu, double sigma) {
  return pos*get_weight(pos,mu,sigma);
}

// calculate average of weight*t between start and stop
double static inline get_weight_range_t(double start, double stop, double mu, double sigma) {
  if (start==stop) return get_weight_t(0.5*(start+stop),mu,sigma);
  double startw=mu*2.5066282746310005*erf((start-mu)/(1.4142135623730950*sigma))-2.0*sigma*exp(-(start-mu)*(start-mu)/(2.0*sigma*sigma));
  double stopw=mu*2.5066282746310005*erf((stop-mu)/(1.4142135623730950*sigma))-2.0*sigma*exp(-(stop-mu)*(stop-mu)/(2.0*sigma*sigma));
//  if (stopw/startw<1.0000001 && startw/stopw<1.0000001) return get_weight_t(0.5*(start+stop),mu,sigma);
  return (0.19947114020071634*(stopw-startw))/(stop-start);
}


typedef struct {
  double N; // estimate for events/s
  double T; // estimate for time around which events occur mostly (relative to mu and sigma)
  double W; // average weight for events seen
  double cD; // closest difficulty;
} estimate_t;

void static estimate(int n, const event_t *e, estimate_t *r, double mu, double sigma) {
  double N=0.0, S=0.0, W=0.0;
  double low=e[0].start, high=e[0].stop;
  double cD=0;
  double cDd=1.0/0.0;
  for (int i=0; i<n; i++) {
    if (e[i].stop>mu-RANGE*sigma && e[i].start<mu+RANGE*sigma) {
      if (e[i].start<low) low=e[i].start;
      if (e[i].stop>high) high=e[i].stop;
      double w = get_weight_range(e[i].start,e[i].stop,mu,sigma);
      double wt = get_weight_range_t(e[i].start,e[i].stop,mu,sigma);
      N += w*e[i].difficulty;
      S += wt*e[i].difficulty;
      W += w*e[i].weight;
      double ncDd=fabs(mu-0.5*(e[i].start+e[i].stop));
      if (ncDd<cDd) { cDd=ncDd; cD=e[i].difficulty; }
    }
  }
  double avg=get_weight_range(low,high,mu,sigma);
  double avgt=get_weight_range_t(low,high,mu,sigma);
  double total = avg*(high-low);
  double rmu=avgt/avg;
//  fprintf(stderr,"mu=%g rmu=%g\n",mu,rmu);
  r->N = N/total;
  r->T = (S/N-rmu)/sigma;
  r->W = W/total;
  r->cD = cD;
}

void proc(int n, const event_t *e, graph_t *r, double sigma) {
  char str[256];
  for (int i=0; i<r->count; i++) {
    double mu=r->base+r->interval*i;
    estimate_t est={};
    estimate(n,e,&est,mu,sigma);
    double B=est.T;
    double A=log(est.N)-0.5*B*B;
//    fprintf(stderr,"rate=%.17g*exp(%.17g*(t-%.17g)/%.17g)\n",A,B,mu,sigma);
//    fprintf(stderr,"mu=%.17g N=%.17g T=%.17g\n",mu,est.N,est.T);
    struct tm tm;
    time_t t=mu;
    localtime_r(&t,&tm);
    strftime(str,255,"[%Y-%m-%d %H:%M:%S] ",&tm);
    fprintf(stderr,"\r                                                                 \r%srate=%.3fGhash/s growth=%.3f%%/day",str,est.N*pow(2.0,32.0)/1000000000.0,100.0*(exp(86400.0*B/sigma)-1.0));
    double daily_growth=86400.0*B/sigma;
    for (int j=0; j<r->count; j++) {
      double t=r->base+r->interval*j;
      if (t>mu-RANGE*sigma && t<mu+RANGE*sigma) {
        double w=get_weight(t,mu,sigma);
        double rate=A+B*(t-mu)/sigma;
        r->val[j].val += w*rate*est.W;
        r->val[j].w += w*est.W;
        r->val[j].avg_daily_growth += daily_growth*w*est.W;
      }
    }
    r->val[i].direct_daily_growth = daily_growth;
    r->val[i].difficulty=est.cD;
  }
  fprintf(stderr,"\r                                                            \n");
}

int main(void) {
  events_t events;
  read_events(stdin,&events);
  int n=alist_len(events.list);

  double sigmas[]={3600,14400,57600,86400,230400,604800,2629800};
  for (int s=0; s<sizeof(sigmas)/sizeof(sigmas[0]); s++) {
    graph_t graph;
    init_graph(&graph,alist_get(events.list,0).start,alist_get(events.list,n-1).stop,3600);
    double sigma=sigmas[s];
    proc(n,alist_ptr(events.list,0),&graph,sigma);
    char fn[256];
    snprintf(fn,256,"estim-%lu.csv",(unsigned long)sigma);
    FILE *f=fopen(fn,"w");
    double ptime=0;
    double pspeed=0;
    for (int i=0; i<graph.count; i++) {
      double time=graph.base+graph.interval*i;
      double speed=exp(graph.val[i].val/graph.val[i].w)*pow(2.0,32.0);
      if (graph.val[i].w>0.0) fprintf(f,"%.17g %.17g %.17g %.17g %.17g %.17g\n",time,speed,graph.val[i].difficulty,exp(graph.val[i].direct_daily_growth),exp(graph.val[i].avg_daily_growth/graph.val[i].w),ptime > 0 ? pow(speed/pspeed,86400/(time-ptime)) : sqrt(-1.0));
      ptime=time;
      pspeed=speed;
    }
    fclose(f);
  }

  return 0;
}
