# Prometheus function reference


`.prom`   **Prometheus Exporter interface**

Create metrics<br>
[`addmetric`](#promaddmetric)         Create a metric instance<br>
[`newmetric`](#promnewmetric)         Define a new metric class

Update metric values<br>
[`updval`](#promupdval)            Update a metric value

Extract metrics<br>
[`extractall`](#promextractall)   Render all metrics in the Prometheus text format

Event handler hooks<br>
[`sethook`](#promsethook)         Install user logic for a hook<br>
[`gethook`](#promgethook)         Retrieve the current logic for a hook

Initialize library<br>
[`init`](#prominit)              Initialize the library

> On KDB-X the library is also available as the module `kx.prometheus`. Every function below is exported, so `prom:use`kx.prometheus` followed by `prom.newmetric[...]` is the module equivalent of `.prom.newmetric[...]`. See the [install guide](install.md).


Once the relevant event handlers have been defined to update the metric values, initialize the library with a call to `.prom.init`.

:point_right:
[Modify the behavior of event handlers that control the logic of metric updates](event-handlers.md)


---


## `.prom.addmetric`

_Create a metric instance_

```txt
.prom.addmetric[metric;labelvals;params;startval]
```


Where

-   `metric` is a symbol denoting the metric class being used
-   `labelvals` are the values of labels used to differentiate metric characteristics as a symbol/list of symbols
-   `params` are the parameters relevant to the metric type as a list of floats
-   `startval` is a float denoting the starting value of the metric

returns identifier/s for the metric, to be used in future updates.

```q
// Tables
q)numtab1:.prom.addmetric[`number_tables;`amer;();0f]
q)numtab2:.prom.addmetric[`number_tables;`emea;();0f]
q)numtab3:.prom.addmetric[`number_tables;`apac;();0f]

// Updates
q)updsz:.prom.addmetric[`size_updates;();0.25 0.5 0.75;`float$()]
```

Once created, a metric will automatically be included in each HTTP response to a request from Prometheus.


## `.prom.extractall`

_Render all metrics_

```txt
.prom.extractall[]
```

Returns the current values of every metric as a string in the Prometheus text exposition format. This is what `/metrics` serves; it is exposed so a process with its own `.z.ph` can serve the metrics itself.


## `.prom.gethook`

_Retrieve the current logic for an event handler hook_

```txt
.prom.gethook[name]
```

Where `name` is one of the hook names listed in [event handlers](event-handlers.md) (`on_poll`, `on_po`, `before_pg`, `after_ts`, ...).

Returns the function currently installed for that hook. Wrap it to extend the built-in logic rather than replace it.

```q
q)poll:.prom.gethook`on_poll
q).prom.sethook[`on_poll;{[poll;msg]poll msg;.prom.updval[numtab1;:;"f"$count tables[]]}[poll]]
```


## `.prom.init`

_Initialize metric monitoring_

```txt
.prom.init[]
```


```q
q).prom.init[]
```

Updating `.z.*` handlers after the call to `.prom.init` will overwrite the Prometheus logic. 

> Tip: Load all process logic before loading the Prometheus library.


## `.prom.newmetric`

_Define a metric class_

```txt
.prom.newmetric[metric;metrictype;labelnames;helptxt]
```


Where

-   `metric` is a symbol denoting the name of the metric class
-   `metrictype` is a symbol outlining the type of metric
-   `labelnames` is a symbol or list of symbols denoting the names of labels used to differentiate metric characteristics
-   `helptxt` is a string providing the HELP text which is provided with the metric values

```q
// Tables
q).prom.newmetric[`number_tables;`gauge;`region;"number of tables"]

// Updates
q).prom.newmetric[`size_updates;`summary;();"size of updates"]
```


## `.prom.sethook`

_Install user logic for an event handler hook_

```txt
.prom.sethook[name;fn]
```

Where

-   `name` is one of the hook names listed in [event handlers](event-handlers.md)
-   `fn` is the function to install, with the signature documented for that hook

Equivalent to assigning `.prom.<name>` directly, which is not possible when the library is loaded as a KDB-X module. Signals an error for an unknown hook name.

```q
q).prom.sethook[`before_pg;{[msg]-1 "sync request: ",.Q.s1 msg;.z.p}]
```


## `.prom.updval`

_Update a metric value_

```txt
.prom.updval[name;func;arg]
```


Where

-   `name` is a symbol denoting the metric instance being updated
-   `func` is a function/operator used to update the value
-   `arg` is the second argument provided to `func` (the first argument being the value itself)

When updating a single-value metric (`counter` or `gauge`), the value will typically be incremented, decremented or assigned to. This value will be reported directly to Prometheus.

When updating a sample metric (`histogram` or `summary`), a list of numeric values will typically be appended to. This list will be aggregated to provide statistics to Prometheus according to the metric type and parameters provided.

```q
// Tables
q).prom.updval[`numtab1;:;count tables[]] // set
q).prom.updval[`numtab2;+;1]              // increment
q).prom.updval[`numtab3;-;1]              // decrement

// Updates
q).prom.updval[`updsz;,;10 15 20f]        // append
```


