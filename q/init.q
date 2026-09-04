// kx.prometheus - Prometheus exporter for KDB-X.
// The same extract.q / exporter.q also run as plain kdb+ scripts (see docs/install.md).
// Loading this module has no side effects: init[] (opt-in) installs the .z.* wrappers globally.
\l ::extract.q
\l ::exporter.q
export:([
  newmetric;   / [metric;metrictype;labelnames;help] define a metric class
  addmetric;   / [metric;labelvals;params;startval] create an instance, returns its handle
  updval;      / [handle;func;arg] update a value (func is one of : + - ,)
  extractall;  / [] Prometheus text exposition of all metrics (what /metrics serves)
  sethook;     / [name;fn] install user logic for a hook (on_poll, before_pg, after_ts, ...)
  gethook;     / [name] current hook fn; wrap it to extend the built-in logic
  init         / [] wrap .z.po/pc/wo/wc/pg/ps/ph/pp/ws/ts (global side effect); call last
  ])
