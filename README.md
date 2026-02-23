# otelcol - Custom OpenTelemetry Collector Distribution

A custom [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) distribution built with the [OpenTelemetry Collector Builder](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder). Bundles 170+ components from the core collector, the contrib repository, and several custom components for infrastructure and hardware monitoring.

## Custom Components

In addition to the standard core and [contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib) components, this distribution includes the following custom components:

### nodeexporterreceiver

[github.com/elek/otel-node-exporter](https://github.com/elek/otel-node-exporter)

Repackages Prometheus [node_exporter](https://github.com/prometheus/node_exporter) as an OpenTelemetry Collector receiver. Useful when you want to reuse existing dashboards and alerting rules built for Prometheus node_exporter. Rather than forking node_exporter, this keeps the collector directory vanilla while replacing only the kingpin import path, simplifying maintenance and upstream synchronization.

```yaml
receivers:
  nodeexporter:
    interval: 10s
    flags:
      collector.cpu: "false"
      collector.vmstat: "false"
```

The `flags` field mirrors node_exporter's command-line flags, allowing you to enable/disable individual collectors.

### smartctlreceiver

[github.com/elek/otel-smartctl-receiver](https://github.com/elek/otel-smartctl-receiver)

Repackages the prometheus-community [smartctl_exporter](https://github.com/prometheus-community/smartctl_exporter) as an OpenTelemetry Collector receiver. Collects S.M.A.R.T. disk health metrics from attached storage devices.

```yaml
receivers:
  smartctl:
    interval: 10s
```

### nvmereceiver

[github.com/elek/otel-nvme-receiver](https://github.com/elek/otel-nvme-receiver)

Collects NVMe drive metrics using the `nvme-cli` tool. Provides telemetry for NVMe storage devices (temperature, wear, read/write stats, etc.).

```yaml
receivers:
  nvme:
    interval: 10s
```

### attrcol (Attribute Collection Processor)

[github.com/elek/otel-attrcol-processor](https://github.com/elek/otel-attrcol-processor)

A trace processor that collects and propagates span attributes through trace hierarchies. It builds parent-child span relationship maps, then propagates attributes both upward (from children to parents) and downward (from parents to children). A `focus` option filters traces to a specific span name.

```yaml
processors:
  attrcol:
    focus: storj.io/storj/satellite/metainfo.(*Endpoint).CompressedBatch
```

### bigqueryexporter

[github.com/elek/otel-bigquery-exporter](https://github.com/elek/otel-bigquery-exporter)

Exports trace spans to Google BigQuery. Extracts span metadata (ID, parent ID, trace ID, name), timing information, scope info, and attributes as tags. Table names can be explicitly set or auto-generated from span names.

```yaml
exporters:
  bigquery:
    project: my-gcp-project
    dataset: my_dataset
    table: traces
    resource_tags: true
```

| Option | Description |
|--------|-------------|
| `project` | GCP project ID |
| `dataset` | BigQuery dataset name |
| `table` | Target table name (optional; defaults to sanitized span name) |
| `resource_tags` | Include resource-level attributes as tags |

## Contrib Components

Based on OpenTelemetry Collector **v0.145.0** / Collector Contrib **v0.145.0**.

<details>
<summary><strong>Receivers (54)</strong></summary>

apache, chrony, dockerstats, expvar, filelog, filestats, fluentforward, github, gitlab, googlecloudmonitoring, googlecloudpubsub, googlecloudspanner, haproxy, hostmetrics, httpcheck, jaeger, jmx, journald, k8scluster, k8sevents, k8sobjects, kafkametrics, kubeletstats, loki, memcached, mysql, namedpipe, nginx, ntp, otlpjsonfile, otelarrow, podman, postgresql, prometheus, prometheusremotewrite, receivercreator, redis, simpleprometheus, snmp, sqlquery, sqlserver, sshcheck, statsd, syslog, tcpcheck, tcplog, tlscheck, udplog, webhookevent, windowseventlog, windowsperfcounters, zipkin

</details>

<details>
<summary><strong>Exporters (14)</strong></summary>

elasticsearch, file, googlecloud, googlecloudpubsub, googlecloudstorage, googlemanagedprometheus, honeycombmarker, loadbalancing, otelarrow, prometheus, prometheusremotewrite, syslog, zipkin

</details>

<details>
<summary><strong>Processors (26)</strong></summary>

attributes, cumulativetodelta, deltatocumulative, deltatorate, filter, geoip, groupbyattrs, groupbytrace, interval, isolationforest, k8sattributes, logdedup, metricsgeneration, metricsstarttime, metricstransform, probabilisticsampler, redaction, remotetap, resourcedetection, resource, schema, span, tailsampling, transform, unroll

</details>

<details>
<summary><strong>Extensions (38)</strong></summary>

ack, asapauth, awsproxy, azureauth, basicauth, bearertokenauth, cgroupruntime, datadog, encoding (awscloudwatchmetricstreams, awslogs, googlecloudlogentry, jaeger, jsonlog, otlp, skywalking, text, zipkin), googleclientauth, headersetter, healthcheck, httpforwarder, jaegerremotesampling, oauth2clientauth, observer (docker, ecs, host, k8s, kafkatopics), oidcauth, opamp, pprof, sigv4auth, storage (file, db, redis), sumologic, k8sleaderelector

</details>

<details>
<summary><strong>Connectors (13)</strong></summary>

count, datadog, exceptions, failover, grafanacloud, otlpjson, roundrobin, routing, servicegraph, spanmetrics, sum, signaltometrics

</details>

### Configuration Providers

env, file, http, https, yaml, aes, s3, secretsmanager, googlesecretmanager

## Building

### Prerequisites

- Go 1.25.3+
- [OpenTelemetry Collector Builder](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder) (`builder`)

### Generate and Compile

```bash
# Regenerate components.go and go.mod from manifest.yaml
builder --config=manifest.yaml --skip-compilation

# Build the binary
go build -tags grpcnotrace -o otelcol .
```

### Release Build

Uses [GoReleaser](https://goreleaser.com/) to produce Linux (amd64) and Windows (amd64) binaries:

```bash
goreleaser release --snapshot --clean
```

## Usage

```bash
./otelcol --config=collector-config.yaml
```

See `collector-config.yaml` for a complete configuration example.

## Updating Components

Edit `manifest.yaml` to add, remove, or update components, then regenerate:

```bash
bash update.sh
go mod tidy
```
