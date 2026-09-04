# KDB-X module examples

The scripts in this folder do the same as the kdb+ scripts in the parent folder, but load the exporter as the KDB-X module `kx.prometheus` instead of via `\l`. They need KDB-X 5.0 or later with the module installed as described in [`docs/install.md`](../../docs/install.md) (or `QPATH` pointing at a directory that contains `kx/prometheus`).

## Built-in metrics only

From the repository root:

```bash
q examples/kdbx/exporter.q -p 8080
```

This is the module-based equivalent of `q q/exporter.q -p 8080` and exposes the same metrics on http://localhost:8080/metrics. Pass `-noinit` to load the module without installing the `.z.*` handlers.

## Built-in metrics plus a custom metric

```bash
q examples/kdbx/kdb_user_example.q -p 8080
```

This process fills a `trade` table from a timer and adds a labelled gauge, `kdb_table_rows{table="trade"}`, refreshed on every scrape by wrapping the built-in `on_poll` hook with `gethook`/`sethook`. It is a minimal template for instrumenting your own process.

## Prometheus and Grafana

Either process is a drop-in replacement for the one used by the [Docker Compose demo](../README.md): the scrape target (`host.docker.internal:8080`) is unchanged, so start the `DockerCompose` stack exactly as described there. The load generator `../kdb_user_example.q` can be pointed at either process as well.
