// kdb+ script: enter .prom and load the engine. KDB-X module: init.q has already loaded extract.q
if[`.~system"d";system"d .prom";system"l extract.q"]

// command line arguments
argv:.Q.opt .z.x

// static info
infokeys:`release_date`release_version`os_version`process_cores`license_expiry_date
infovals:string[(.z.k;.z.K;.z.o;.z.c)],enlist .z.l 1

// metric classes
newmetric[`kdb_info;`gauge;infokeys;"process information"]
newmetric[`memory_usage_bytes;`gauge;();"memory allocated"]
newmetric[`memory_heap_bytes;`gauge;();"memory available in the heap"]
newmetric[`memory_heap_peak_bytes;`gauge;();"maximum heap size so far"]
newmetric[`memory_heap_limit_bytes;`gauge;();"limit on thread heap size"]
newmetric[`memory_mapped_bytes;`gauge;();"mapped memory"]
newmetric[`memory_physical_bytes;`gauge;();"physical memory available"]
newmetric[`kdb_syms_total;`counter;();"number of symbols"]
newmetric[`kdb_syms_memory_bytes;`counter;();"memory use of symbols"]
newmetric[`kdb_ipc_opened_total;`counter;();"number of ipc sockets opened"]
newmetric[`kdb_ipc_closed_total;`counter;();"number of ipc sockets closed"]
newmetric[`kdb_ws_opened_total;`counter;();"number of websockets opened"]
newmetric[`kdb_ws_closed_total;`counter;();"number of websockets closed"]
newmetric[`kdb_handles_total;`gauge;();"number of open handles (ipc and websocket)"]
newmetric[`kdb_sync_total;`counter;();"number of sync requests"]
newmetric[`kdb_async_total;`counter;();"number of async requests"]
newmetric[`kdb_http_get_total;`counter;();"number of http get requests"]
newmetric[`kdb_http_post_total;`counter;();"number of http post requests"]
newmetric[`kdb_ws_total;`counter;();"number of websocket messages"]
newmetric[`kdb_ts_total;`counter;();"number of timer calls"]
newmetric[`kdb_sync_err_total;`counter;();"number of errors from sync requests"]
newmetric[`kdb_async_err_total;`counter;();"number of errors from async requests"]
newmetric[`kdb_http_get_err_total;`counter;();"number of errors from http get requests"]
newmetric[`kdb_http_post_err_total;`counter;();"number of errors from http post requests"]
newmetric[`kdb_ws_err_total;`counter;();"number of errors from websocket messages"]
newmetric[`kdb_ts_err_total;`counter;();"number of errors from timer calls"]
newmetric[`kdb_sync_summary_seconds;`summary;();"duration of sync requests"]
newmetric[`kdb_async_summary_seconds;`summary;();"duration of async requests"]
newmetric[`kdb_http_get_summary_seconds;`summary;();"duration of http get requests"]
newmetric[`kdb_http_post_summary_seconds;`summary;();"duration of http post requests"]
newmetric[`kdb_ws_summary_seconds;`summary;();"duration of websocket messages"]
newmetric[`kdb_ts_summary_seconds;`summary;();"duration of timer calls"]
newmetric[`kdb_sync_histogram_seconds;`histogram;();"duration of sync requests"]
newmetric[`kdb_async_histogram_seconds;`histogram;();"duration of async requests"]
newmetric[`kdb_http_get_histogram_seconds;`histogram;();"duration of http get requests"]
newmetric[`kdb_http_post_histogram_seconds;`histogram;();"duration of http post requests"]
newmetric[`kdb_ws_histogram_seconds;`histogram;();"duration of websocket messages"]
newmetric[`kdb_ts_histogram_seconds;`histogram;();"duration of timer calls"]

// metric instances
info      :addmetric[`kdb_info;infovals;();1f]
mem       :addmetric[`memory_usage_bytes;();();0f]
mem_heap  :addmetric[`memory_heap_bytes;();();0f]
mem_peak  :addmetric[`memory_heap_peak_bytes;();();0f]
mem_wmax  :addmetric[`memory_heap_limit_bytes;();();0f]
mem_map   :addmetric[`memory_mapped_bytes;();();0f]
mem_phys  :addmetric[`memory_physical_bytes;();();0f]
sym_num   :addmetric[`kdb_syms_total;();();0f]
sym_mem   :addmetric[`kdb_syms_memory_bytes;();();0f]
ipc_opened:addmetric[`kdb_ipc_opened_total;();();0f]
ipc_closed:addmetric[`kdb_ipc_closed_total;();();0f]
ws_opened :addmetric[`kdb_ws_opened_total;();();0f]
ws_closed :addmetric[`kdb_ws_closed_total;();();0f]
hdl_open  :addmetric[`kdb_handles_total;();();0f]
qry_sync  :addmetric[`kdb_sync_total;();();0f]
qry_async :addmetric[`kdb_async_total;();();0f]
qry_http  :addmetric[`kdb_http_get_total;();();0f]
qry_post  :addmetric[`kdb_http_post_total;();();0f]
qry_ws    :addmetric[`kdb_ws_total;();();0f]
qry_ts    :addmetric[`kdb_ts_total;();();0f]
err_sync  :addmetric[`kdb_sync_err_total;();();0f]
err_async :addmetric[`kdb_async_err_total;();();0f]
err_http  :addmetric[`kdb_http_get_err_total;();();0f]
err_post  :addmetric[`kdb_http_post_err_total;();();0f]
err_ws    :addmetric[`kdb_ws_err_total;();();0f]
err_ts    :addmetric[`kdb_ts_err_total;();();0f]
summ_sync :addmetric[`kdb_sync_summary_seconds;();.25 .5 .75;0#0f]
summ_async:addmetric[`kdb_async_summary_seconds;();.25 .5 .75;0#0f]
summ_http :addmetric[`kdb_http_get_summary_seconds;();.25 .5 .75;0#0f]
summ_post :addmetric[`kdb_http_post_summary_seconds;();.25 .5 .75;0#0f]
summ_ws   :addmetric[`kdb_ws_summary_seconds;();.25 .5 .75;0#0f]
summ_ts   :addmetric[`kdb_ts_summary_seconds;();.25 .5 .75;0#0f]
hist_sync :addmetric[`kdb_sync_histogram_seconds;();.25 .5 1 5 10;0#0f]
hist_async:addmetric[`kdb_async_histogram_seconds;();.25 .5 1 5 10;0#0f]
hist_http :addmetric[`kdb_http_get_histogram_seconds;();.25 .5 1 5 10;0#0f]
hist_post :addmetric[`kdb_http_post_histogram_seconds;();.25 .5 1 5 10;0#0f]
hist_ws   :addmetric[`kdb_ws_histogram_seconds;();.25 .5 1 5 10;0#0f]
hist_ts   :addmetric[`kdb_ts_histogram_seconds;();.25 .5 1 5 10;0#0f]

// memory metrics (.Q.w[])
memmetrics:value each`mem`mem_heap`mem_peak`mem_wmax`mem_map`mem_phys`sym_num`sym_mem

// define logic to run in event handlers
on_poll:{[msg]updval[;:;]'[memmetrics;value"f"$.Q.w[]];}

on_po:{[msg]
  updval[ipc_opened;+;1];
  updval[hdl_open;:;"f"$count .z.W];}
on_pc:{[msg]
  updval[ipc_closed;+;1];
  updval[hdl_open;:;"f"$count .z.W];}
on_wo:{[msg]
  updval[ws_opened;+;1];
  updval[hdl_open;:;"f"$count .z.W];}
on_wc:{[msg]
  updval[ws_closed;+;1];
  updval[hdl_open;:;"f"$count .z.W];}
H:{x!value each x}`$raze("qry_";"err_";"summ_";"hist_"),/:\:("sync";"async";"http";"post";"ws";"ts")
before:{[met;msg]
  updval[H`$"qry_",met;+;1];
  updval[H`$"err_",met;+;1];
  .z.p}
after:{[met;tmp;msg;res]
  updval[H`$"err_",met;-;1];
  tm:(10e-10)*.z.p-tmp;
  updval[H`$"summ_",met;,;tm];
  updval[H`$"hist_",met;,;tm];}
before_pg:before"sync"
after_pg :after"sync"
before_ps:before"async"
after_ps :after"async"
before_ph:before"http"
after_ph :after"http"
before_pp:before"post"
after_pp :after"post"
before_ws:before"ws"
after_ws :after"ws"
before_ts:before"ts"
after_ts :after"ts"

// initialize library (kdb+ script only; as a KDB-X module the user calls init[] explicitly)
if[`.prom~system"d";
  if[not `noinit in key argv;
    init[]
    ]
  ]
