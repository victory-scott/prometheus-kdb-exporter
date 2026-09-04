// KDB-X module example: a kdb+ process exposing the built-in metrics plus one of its own.
//   q examples/kdbx/kdb_user_example.q -p 8080
// Requires the kx.prometheus module to be installed (see docs/install.md).
prom:use`kx.prometheus

// process logic: a table filled by a timer (define before init[] so the timer is monitored too)
trade:([]time:`timestamp$();sym:`$();price:`float$())
.z.ts:{`trade insert(.z.p;`AAPL;100+rand 1f);}
\t 1000

// custom metric: row count per table, labelled by table name
prom.newmetric[`kdb_table_rows;`gauge;`table;"number of rows in table"]
rows_trade:prom.addmetric[`kdb_table_rows;enlist"trade";();0f]

// refresh it on every scrape, keeping the built-in memory poll by wrapping the existing hook
poll:prom.gethook`on_poll
prom.sethook[`on_poll;{[poll;msg]poll msg;prom.updval[rows_trade;:;"f"$count trade];}[poll]]

// install the .z.* wrappers last
prom.init[]
