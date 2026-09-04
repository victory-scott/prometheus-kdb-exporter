// KDB-X equivalent of q/exporter.q: expose the built-in kdb+ metrics using the kx.prometheus module.
//   q examples/kdbx/exporter.q -p 8080 [-noinit]
prom:use`kx.prometheus
if[not`noinit in key .Q.opt .z.x;prom.init[]]
