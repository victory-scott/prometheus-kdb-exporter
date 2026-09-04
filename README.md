# ![Prometheus Exporter](prometheus.png) Prometheus Exporter for kdb+

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kxsystems/prometheus-kdb-exporter?include_prereleases)](https://github.com/kxsystems/prometheus-kdb-exporter/releases)



This interface provides a method by which to expose metrics from a kdb+ process or multiple processes to Prometheus for monitoring. This is done via the script `q/exporter.q` which exposes kdb+ process metrics which can be consumed by Prometheus. The same code is also available as a KDB-X module, `kx.prometheus`.

This interface is part of the [_Fusion for kdb+_](https://code.kx.com/q/interfaces#fusion/) project.

## New to kdb+ ?

Kdb+ is the world's fastest time-series database, optimized for ingesting, analyzing and storing massive amounts of structured data. To get started with kdb+, visit https://code.kx.com/q/learn/ for downloads and developer information. For general information, visit https://kx.com/

## What is Prometheus ?

Prometheus is an open source monitoring solution which facilitates metrics gathering, querying and alerting for a wealth of different 3rd-party languages and applications. It also provides integration with Kubernetes for automatic discovery of supported applications.

Visualization and querying can be done through the Prometheus built in expression browser, or more commonly via Grafana. 
The repo includes [an example](examples) of this using Docker.

## Quick start

### KDB-X (module)

Install the module and load it with `use` (full details in [`docs/install.md`](docs/install.md))

```bash
mkdir -p ~/.kx/mod/kx && cp -r q ~/.kx/mod/kx/prometheus
```

```q
q)prom:use`kx.prometheus
q)prom.init[]
```

or run the supplied script, which does the same and exposes metrics on port 8080

```bash
q examples/kdbx/exporter.q -p 8080
```

### kdb+ (scripts)

Install the q scripts to `$QHOME`/`%QHOME%` using the `install.sh`/`install.bat` files

```bash
## Linux/MacOS
chmod +x install.sh && ./install.sh

## Windows
install.bat
```

Run kdb+ with the supplied q script. This script will expose metrics on port 8080 which can be monitored by Prometheus

```bash
q q/exporter.q -p 8080
```

Once running, use your web browser to view the currently exposed statistics on the metrics URL e.g. http://localhost:8080/metrics. The metrics exposed will be the metric values at the time at which the URL is requested.

## Unsupported functionality

This interface does not provide service discovery. Prometheus itself has support for multiple mechanisms such as DNS, Kubernetes, EC2, file based config, etc., to discover all the kdb+ instances within your environment.


## Documentation

:open_file_folder: [`docs`](docs)


## Status

The prometheus-kdb-exporter interface is provided here under an Apache 2.0 license.

If you find issues with the interface or have feature requests please [raise an issue](../../issues). 

To contribute to this project, please follow the [contribution guide](CONTRIBUTING.md).
