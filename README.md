# PdataConv

_[Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/) for
OpenTelemetry Collector components Pdata SDKs.


**PdataConv** has three goals:
- Bring semantic conventions to OpenTelemetry Collector components.
- Rely on [Weaver](https://github.com/open-telemetry/weaver) for code-generation using (migrate Go templates to Jinja).
- Provide an API to transition `mdatagen` configurations to [Weaver Semantic
Conventions schema](https://github.com/open-telemetry/weaver/blob/main/schemas/semconv.schema.json).

This is an ongoing proof of concept, goals might be migrated gradually to the
upstream OpenTelemetry Collector project.

## Try it out!

1. Generate the pdata Go SDK using Weaver:

```bash
$ make generate-example
```

2. Check the generated files in [./internal/metadata/](./internal/metadata/).


**Repository structure based on: https://github.com/jsuereth/o11y-by-design/tree/main**
