# Emission-Shape Cross-Feature Assumption (P5-T3)

Timestamp: 2026-07-18T11-12

## Adopted pattern

The inventory analyzer emits a **collection of Evidence Reference v1 instances**, one
schema-conforming instance per inventoried unit, written under the resolved output root. It
does NOT emit a single bespoke aggregate "inventory" artifact.

## Reason

- The discovery v1 Evidence Reference schema (`schemas/discovery/v1/evidence-reference.schema.json`,
  feature #359) models a single captured artifact per instance (`id`, `kind`, `location`,
  `captured_at`, `description`, optional `content_hash`/`tool`/`metadata`). It is the shared leaf
  that other discovery artifacts reference by id. Emitting one instance per unit produces
  directly-referenceable, schema-conforming leaves.
- No aggregate "inventory" schema exists in `schemas/discovery/v1/`. Fabricating a bespoke
  aggregate artifact would emit a non-conforming shape, violating the artifact-emission contract.
- The spec's artifact-emission contract adopts the N-instances pattern; this document records
  the same decision at the code level.

## Revisit condition

This is a documented assumption, not a frozen decision. If feature #359 later confirms that an
aggregate artifact (for example a single `metadata`-carrying artifact enumerating all units) is
the intended pattern, the emission shape is revisited before it is frozen. The current
implementation isolates emission in `InventoryAnalyzer.emit` and `emitter.serialize_record`, so
switching to an aggregate shape would be a localized change.
