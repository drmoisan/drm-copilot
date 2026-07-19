# `legacy-discovery-acceptance-scenarios` — User Story

- Issue: #364
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17T15-00

## Story Statement

- As a consumer-repository migration engineer, I want to generate executable acceptance
  scenarios from the discovery artifacts (Feature Contract, Parity Matrix, and Runtime
  Characterization Scenario), so that I can verify source-to-target parity against concrete,
  reproducible scenarios instead of prose.
- As a migration engineer, I want generation to be deterministic and domain-neutral, so that
  the same inputs always produce the same scenario document and the tool works for any
  migration without repository-specific behavior.
- As a migration engineer, I want to run the generator before the discovery schemas land, so
  that I am not blocked on a parallel feature (#9002) and can supply input paths explicitly in
  the interim.

## Problem / Why

The `legacy-discovery-and-parity` epic delivers a domain-neutral capability for migrating a
legacy application to a modern architecture. One required output is a set of executable
acceptance scenarios derived from the machine-readable discovery artifacts, so a consumer
repository can verify source-to-target parity against concrete, reproducible scenarios rather
than prose. This feature provides the generator that turns feature contracts and
parity/characterization evidence into executable acceptance scenarios.

## Personas & Scenarios

- Persona: Consumer-repository migration engineer.
  - Who they are: an engineer in a repository migrating a legacy application to a modern
    architecture. They author or receive the discovery artifacts and are responsible for
    demonstrating that the modern target preserves the behavior of the legacy source.
  - What they care about: concrete, reproducible verification of source-to-target parity;
    outputs that are stable across machines and runs; a tool that is generic and not tied to a
    single domain.
  - Their constraints: the discovery schema definitions (#9002) are prepared in parallel and
    may not be present yet; the output must be byte-identical for identical inputs; no
    temporary files may be used in tests; the tool must contain no domain-specific
    identifiers.
  - Their goals and frustrations: they want a single command that produces a machine-readable,
    human-reviewable scenario document. They are frustrated by prose-only parity claims that
    cannot be re-verified and by tooling that produces different output on different machines.
  - Their context and motivations: they operate in a CI-driven workflow where deterministic,
    validatable artifacts are required for gates and reviews.

- Scenario: Generating acceptance scenarios from discovery artifacts.
  - Who is acting: the migration engineer.
  - What triggered the action: the Feature Contract, Parity Matrix, and Runtime
    Characterization Scenario artifacts are available, and parity must be recorded as concrete
    scenarios.
  - Steps they take: invoke the `dev.discovery.generate-acceptance-scenarios` console-script,
    supplying the three input artifact paths (and, before #9002 lands, explicit input paths
    rather than relying on the schema tree). The generator projects the required fields,
    assembles scenario objects with structured Given/When/Then arrays, sorts them
    deterministically, and writes a single JSON acceptance-scenario-set document (or emits it
    to stdout).
  - Obstacles or decisions: if an input file is missing or malformed, the command exits with
    code `1` and a clear message. If the schema tree is absent because #9002 has not landed,
    the schema-location seam raises a clear error naming the expected `schemas/vN/` convention,
    and the engineer proceeds by supplying explicit input paths.
  - Outcome they expect: a byte-identical JSON scenario document that can be re-generated to
    the same bytes, reviewed by humans, validated by the repository JSON tooling, and consumed
    as a pytest-parametrizable data source.

## Acceptance Criteria

- [x] A Python module `scripts/dev_tools/generate_acceptance_scenarios.py` generates
      acceptance scenarios from the Feature Contract, Parity Matrix, and Runtime
      Characterization Scenario inputs.
- [x] The output is a single JSON acceptance-scenario-set document with the top-level fields
      `$schema`, `schema_version`, `generator`, `source_digest`, and `scenarios`, and scenario
      objects carry structured `given`, `when`, and `then` string arrays.
- [x] Generation is deterministic: identical inputs produce byte-identical output, and output
      is invariant to input ordering.
- [x] The output scenario format is defined in spec.md and is domain-neutral (no
      TaskMaster/TMW/Outlook/VSTO/email/task-management identifiers).
- [x] A `dev.discovery.generate-acceptance-scenarios` Poetry console-script exposes the
      generator with a `def main(argv=None) -> int` entry point and its own argparse parser,
      using the `0`/`1` exit-code convention.
- [x] The schema-location seam is isolated behind a single
      `resolve_discovery_schema(...)` function so execution can proceed before feature #9002
      lands, raising a clear error naming the expected `schemas/vN/` convention in the interim.
- [x] Each input schema is read through a named projection/adapter so a #9002 field-name change
      touches only the adapter, not the generation logic.
- [x] Tests cover positive generation, determinism, negative/malformed input, the
      schema-location seam, and the CLI; use no temporary files; and satisfy the repository
      quality-tier policy (line >= 85%, branch >= 75%).

## Non-Goals

- Reports (coverage, parity, completion) — owned by feature #9010.
- Static analyzers (repository/project inventory, .NET/C#, VSTO/Office) — owned by features
  #9006 and #9014.
- The concrete schema field names and the `schemas/vN/` directory tree — owned by feature
  #9002.
- MCP tool and VS Code command exposure — owned by feature #9011.
- Validators following the `validate_<artifact>_text` pattern — owned by feature #9003.
