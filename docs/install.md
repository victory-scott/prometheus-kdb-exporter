# Installation

The exporter ships as two q files, `q/extract.q` and `q/exporter.q`, which can be used in two ways.

## KDB-X module

On KDB-X 5.0 or later the `q` folder is a module, loaded with `use`. The module takes its name from the directory it is installed into, so the folder is installed as `prometheus`. Modules can be loaded from anywhere on `QPATH`, but we recommend installing to `$HOME/.kx/mod/kx` to avoid name clashes with your own modules and to sit alongside other KX modules.

```bash
export QPATH="$QPATH:$HOME/.kx/mod"
mkdir -p ~/.kx/mod/kx/
cp -r q ~/.kx/mod/kx/prometheus
```

From any q session you can now load the module. Loading has no side effects; `init[]` installs the `.z.*` handlers that collect the built-in metrics and serve `/metrics`.

```q
q)prom:use`kx.prometheus
q)key prom
`newmetric`addmetric`updval`extractall`sethook`gethook`init
q)prom.init[]
```

Every function documented in the [reference](reference.md) as `.prom.<name>` is available as `prom.<name>`. Because a module's namespace is private, hooks are customised with `prom.sethook` rather than by assignment (see [event handlers](event-handlers.md)).

For development, symlink the working tree instead of copying so edits are picked up on the next `use`:

```bash
mkdir -p ~/.kx/mod/kx
ln -s "$(pwd)/q" ~/.kx/mod/kx/prometheus
q -q <<< 'show key use`kx.prometheus; exit 0'
```

## kdb+ scripts

On kdb+ 3.x/4.x (or on KDB-X without the module framework) install the two files into `$QHOME`/`%QHOME%` with the supplied scripts. `QHOME` must be set; KDB-X installs leave it unset, so export it first if you want the script install there.

```bash
## Linux/MacOS
chmod +x install.sh && ./install.sh

## Windows
install.bat
```

Then either run the ready-made exporter

```bash
q q/exporter.q -p 8080
```

or load the library into your own process with `\l extract.q` (or `\l exporter.q` for the built-in metrics; add `-noinit` on the command line to call `.prom.init[]` yourself once your own `.z.*` handlers are in place).
