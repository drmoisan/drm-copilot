# `legacy-discovery-reports` — User Story

- Issue: #368
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17T15-03

## Story Statement

- As a reviewer in a repository migrating a legacy application, I want a human-readable
  coverage report rendered from the Coverage Ledger, so that I can review which legacy
  behaviors have been discovered and their coverage status without reading raw JSON.
- As a reviewer in a repository migrating a legacy application, I want a human-readable
  parity report rendered from the Parity Matrix, so that I can review source-to-target parity
  status for each mapped feature without reading raw JSON.
- As a reviewer in a repository migrating a legacy application, I want a completion report
  presenting aggregate readiness across the discovery artifacts, so that I can judge overall
  migration-discovery readiness at a glance.
- As a reviewer running the report commands repeatedly against the same artifacts (for example,
  in a CI pipeline or before re-approving a review), I want byte-identical report output for
  identical input, so that I can diff reports across runs and trust that any difference in
  output reflects a real change in the underlying artifacts.

## Problem / Why

The legacy-discovery-and-parity capability produces machine-readable discovery artifacts
(a Coverage Ledger and a Parity Matrix). Consumers migrating a legacy application need
deterministic, human-readable reports derived from those artifacts to review coverage,
source-to-target parity, and aggregate completion readiness. Without a reporting layer,
the machine-readable artifacts are not directly consumable by reviewers.


## Personas & Scenarios

- **Persona: Migrating-Repository Reviewer**
  - Who they are: a maintainer or reviewer working in a repository that is migrating a legacy
    application to a modern architecture (for example, `TaskMaster` migrating to `TMW`), using
    the domain-neutral discovery-and-parity capability delivered by the parent epic.
  - What they care about: understanding, at review time, how much of the legacy system has
    been discovered and covered, how far source-to-target parity has progressed, and whether
    the overall discovery effort is ready to support the next migration decision.
  - Their constraints: they read machine-readable JSON artifacts (Coverage Ledger, Parity
    Matrix) only through generated reports, not by hand-parsing JSON; they need reports they can
    diff across runs without false-positive noise from non-deterministic formatting.
  - Their goals and frustrations: they want a quick, reliable, human-readable summary; they are
    frustrated by tooling that produces different output on unchanged input, or that renders a
    misleading report from a malformed artifact instead of failing with a clear error.
  - Their context and motivations: they typically run report generation from the command line as
    part of a review step, either interactively or from CI, before approving a migration
    decision or a parity update.
- **Scenario: Reviewing coverage before approving a parity update**
  - Who is acting: the Migrating-Repository Reviewer.
  - What triggered the action: a Coverage Ledger and a Parity Matrix have just been updated by
    the discovery workflow, and the reviewer needs to approve or reject a proposed parity
    change.
  - What steps do they take: the reviewer runs `dev.discovery.coverage-report` against the
    updated Coverage Ledger and `dev.discovery.parity-report` against the updated Parity Matrix,
    then runs `dev.discovery.completion-report` against both artifacts to see the aggregate
    readiness signal.
  - What obstacles or decisions occur: if one of the artifacts is malformed (for example, it
    fails the upstream schema validator), the corresponding report command fails fast with a
    non-zero exit code and a clear list of validation errors, rather than silently rendering a
    partial or misleading report; the reviewer must fix the artifact before a report is
    produced.
  - What outcome do they expect: given conforming artifacts, three deterministic, human-readable
    reports; given a malformed artifact, an immediate, clear failure with no report written; and
    given the same artifacts run twice, byte-identical report output both times.


## Acceptance Criteria

- [x] A coverage report is rendered deterministically from a Coverage Ledger artifact.
- [x] A parity report is rendered deterministically from a Parity Matrix artifact.
- [x] A completion report presents aggregate readiness across the discovery artifacts.
- [x] Given identical input artifacts, report output is byte-identical across runs.
- [x] Input artifacts are validated (via the validators) before rendering; a malformed artifact fails fast with a clear error and non-zero exit code.
- [x] Report generation is exposed as `dev.discovery.*` Poetry console-script CLI entry point(s) following the repository substrate convention.
- [x] The reporting framework contains no domain-specific identifiers.
- [x] Tests satisfy quality-tier policy (line >= 85%, branch >= 75%).


## Non-Goals

- **MCP tool and VS Code command exposure of the report commands.** These are owned by the
  sibling feature `legacy-discovery-mcp-vscode` (issue #9011), which wraps the `dev.discovery.*`
  CLI commands delivered here as MCP tools and VS Code commands in a later wave. This feature
  ships the CLI commands only.
- **Execution of an actual migration.** This feature reports on discovery-artifact contents; it
  does not perform, drive, or influence any migration action.
- **Any domain-specific behavior.** The reporting framework contains no
  TaskMaster/TMW/Outlook/VSTO/email/task-management-specific identifiers or logic; all
  human-facing labels come from the artifact's own field values, never from framework-hardcoded
  domain vocabulary.
- **Defining or modifying the Coverage Ledger / Parity Matrix schemas.** Schema definition is
  owned by `legacy-discovery-schemas` (#9002); this feature only consumes the documented
  contract.
- **Implementing the artifact validators.** Validation logic is owned by
  `legacy-discovery-validators` (#9003); this feature only invokes the validators through an
  injectable seam and fails fast on their reported errors.
- **Aggregating discovery-artifact categories beyond the Coverage Ledger and Parity Matrix in
  v1.** The completion report's v1 scope aggregates over Coverage Ledger and Parity Matrix only
  (this feature's declared `depends_on`); the aggregation function is structured so other
  artifact categories (Feature Contract, Runtime Characterization Scenario, Unspecified Behavior
  Record, Product Decision Record, Evidence Reference) can be added later without a rewrite, but
  adding them is out of scope for this feature.
