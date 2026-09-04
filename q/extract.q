// loaded two ways with the same source:
//   kdb+ script : \l extract.q          -> defines everything in .prom
//   KDB-X module: use`kx.prometheus     -> init.q loads this into the module's private namespace
if[`.~system"d";system"d .prom"]
NS:system"d"
qn:{[n]$[NS~`.;n;` sv NS,n]}
METRICS:qn`metrics
METRICVALS:qn`metricvals

// utils
wraplabels:{$[count x;"{",x,"}";""]}
wrapstring:{"\"",x,"\""}

// schema
metrics:([metric:`$()]metrictype:`$();labelnames:();hdr:())
metricvals:1#([name:`$()]metric:`$();params:();labelhdr:();val:())

// define metric class
newmetric:{[metric;metrictype;labelnames;help]
  hdr:enlist("# HELP ";"# TYPE "),'string[metric],/:" ",'(help;string metrictype);
  METRICS upsert(metric;metrictype;raze labelnames;hdr);}

// create metric instance
addmetric:{[metric;labelvals;params;startval]
  name:`$"|"sv enlist[string metric],labelvals;
  labelhdr:", "sv string[metrics[metric]`labelnames],'"=",'wrapstring each labelvals;
  METRICVALS upsert(name;metric;params;labelhdr;startval);
  name}

// fetch metric values (specific per metric type)
getval:{[d]enlist wraplabels[d`labelhdr]," ",string d`val}
quantile:{[q;x]r[0]+(p-i 0)*last r:0^deltas asc[x]i:0 1+\:floor p:q*-1+count x}
summary:{[d]
  svals:raze(sum;count;quantile q:d`params)@\:d`val;
  labelhdr:$[count d`labelhdr;enlist d`labelhdr;()];
  hdr:", "sv/:labelhdr,/:(();()),enlist each"quantile=",/:wrapstring each string q;
  hdr:(("_sum";"_count"),count[q]#enlist""),'wraplabels each hdr;
  hdr,'" ",'string svals}

histogram:{[d]
  svals:raze(sum d`val;count d`val;1+asc[d`val]bin q:asc d`params);
  labelhdr:$[count d`labelhdr;enlist d`labelhdr;()];
  hdr:", "sv/:labelhdr,/:(();()),enlist each"le=",/:wrapstring each string[q],enlist "+Inf";
  hdr:(("_sum";"_count"),(1+count[q])#enlist""),'wraplabels each hdr;
  hdr,'" ",'string svals,svals[1]
 };

// extract metric info
extractall:{[]
  aggmetrics:exec metric from metrics where metrictype in`summary`histogram;
  METRICVALS upsert select name,asc each val from metricvals where metric in aggmetrics;
  "\n"sv raze extractmetric each 0!metrics}
extractmetric:{[d]
  vals:extractmetricval[d`metrictype]each 0!select from metricvals where metric=d`metric;
  first[d`hdr],raze vals} 
extractmetricval:{[typ;d]
  $[typ=`summary;
     string[d`metric],/:summary d;
    typ=`histogram;
     string[d`metric],/:histogram d;
     string[d`metric],/:getval d
  ]}

// update metric values
updval:{[name;func;val].[METRICVALS;(name;`val);func;val];}

// logic run inside event handlers
// null logic, to be overwritten
on_poll  :{[msg]}
on_po    :{[hdl]}
on_pc    :{[hdl]}
on_wo    :{[hdl]}
on_wc    :{[hdl]}
before_pg:{[msg]}
after_pg :{[tmp;msg;res]}
before_ps:{[msg]}
after_ps :{[tmp;msg;res]}
before_ph:{[msg]}
after_ph :{[tmp;msg;res]}
before_pp:{[msg]}
after_pp :{[tmp;msg;res]}
before_ws:{[msg]}
after_ws :{[tmp;msg;res]}
before_ts:{[dtm]}
after_ts :{[tmp;dtm;res]}

// hook accessors (module users cannot assign into the namespace directly)
hooks:`on_poll`on_po`on_pc`on_wo`on_wc`before_pg`after_pg`before_ps`after_ps`before_ph`after_ph`before_pp`after_pp`before_ws`after_ws`before_ts`after_ts
sethook:{[hook;f]if[not hook in hooks;'"unknown hook: ",string hook];qn[hook]set f;}
gethook:{[hook]if[not hook in hooks;'"unknown hook: ",string hook];get qn hook}

// event handlers
po:{[f;hdl]on_po hdl;f hdl}
pc:{[f;hdl]on_pc hdl;f hdl}
wo:{[f;hdl]on_wo hdl;f hdl}
wc:{[f;hdl]on_wc hdl;f hdl}
pg:{[f;msg]tmp:before_pg msg;res:f msg;after_pg[tmp;msg;res];res}
ps:{[f;msg]tmp:before_ps msg;res:f msg;after_ps[tmp;msg;res];}
ph:{[f;msg]$["metrics"~msg 0;
  [on_poll[msg];.h.hy[`txt]extractall[]];
  [tmp:before_ph msg;res:f msg;after_ph[tmp;msg;res];res]
 ]}
pp:{[f;msg]tmp:before_pp msg;res:f msg;after_pp[tmp;msg;res];res}
ws:{[f;msg]tmp:before_ws msg;res:f msg;after_ws[tmp;msg;res];res}
ts:{[f;dtm]tmp:before_ts dtm;res:f dtm;after_ts[tmp;dtm;res];}

// overload existing event handlers
overloadhandler:{[nm;ol;def]
  fn:ol $[`err~rs:@[value;nm;`err];
    def;
    get(`$string[nm],"_orig")set rs
  ];
  nm set fn;}

// initialize library
init:{[]
  overloadhandler[`.z.po;po;{[x]}];
  overloadhandler[`.z.pc;pc;{[x]}];
  overloadhandler[`.z.wo;wo;{[x]}];
  overloadhandler[`.z.wc;wc;{[x]}];
  overloadhandler[`.z.pg;pg;value];
  overloadhandler[`.z.ps;ps;value];
  overloadhandler[`.z.ph;ph;{[x]}];
  overloadhandler[`.z.pp;pp;{[x]}];
  overloadhandler[`.z.ws;ws;{[x]}];
  overloadhandler[`.z.ts;ts;{[x]}];
 }
