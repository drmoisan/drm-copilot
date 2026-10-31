# `docs-profile-and-artifact-schemas` — User Story

- Issue: #1020
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-31
- Authoritative specification: `spec.md` in this folder (PowerShell design, version 0.6; the
  earlier Python package design is withdrawn)
- Requirements source: `docs/features/epics/documentation-estate-tooling/epic.md` on branch
  `origin/epic/documentation-estate-tooling-integration`

## Revision Note

This revision follows `spec.md` version 0.4, the requirements amendment for owner decisions D3 and
D5 (a new planning cycle under D1). It adds the analysis method (`native` or `scanner`) recorded
per snapshot element, snapshot analyzer and ledger entry; the declaration-lines digest; the
`-Json` envelope schema; the 1031 analyzer-registry anchor and the corrected anchor numbers
(1022 and 1024 replace stale placeholders); and the shared audience identifier pattern. Existing
acceptance criteria keep their order; changed wording is in U1, U8 and U9, and the new criteria are
appended as U15 to U18.

The follow-up revision for `spec.md` version 0.5 applies the binding 1031 preconditions of the
integration-branch epic and replaces every placeholder number with its real issue number (1031,
1033, 1034, 1036, 1037, 1038). U6 now excludes the `.claude/lib/docs/python/` subtree, which only
the python pack lists; U9 adds the separate native provider table; U8 and U17 name 1036; and U19
is appended for the process member and the `information` diagnostic severity.

The revision for `spec.md` version 0.6 applies owner decision P1. Criteria keep their number and
order. U9 no longer describes the registry tables as empty: registry tests assert that the anchors
and tables exist and find registered rows by membership, never by row count. U19 describes the
process member as a thin seam whose argument validation and result shaping are pure functions
tested in memory, with no test starting a process. The `patternProperties` walk, the empty-file
read and the repository-relative init template sources are specified in `spec.md` and need no
user-story criterion change.

## Story Statement

- As a destination repository maintainer, I want the documentation helpers to arrive with the
  existing Claude push-down and to generate and validate a starter docs profile with one PowerShell
  command, so that I can describe my repository's documentation estate as configuration without
  installing Python or changing framework code.
- As a downstream epic feature author, I want fixed, versioned schemas, a deterministic surface
  element identifier, a declaration-lines digest, an owner-anchored dispatch table and analyzer
  registry that admits a scanner and a native analyzer under one identifier, and one command
  result contract with its own schema, so that I can build page checks, analyzers, the coverage
  ledger, the reference generator and enforcement in parallel against the same contracts.
- As a documentation role agent or reviewer, I want each inventoried element and ledger entry to
  record whether a native analyzer or the text scanner produced it, and a page to become stale only
  when the documented declaration's own lines change, so that I can judge precision and avoid
  false staleness from unrelated edits.
- As a documentation role agent, I want every documentation artifact to validate against a closed
  schema that rejects unknown dispositions and element kinds and names the failing field, so that
  the artifacts I read and propose changes to have one unambiguous meaning.

## Problem / Why

The documentation-estate-tooling epic (#1019) needs a stable set of contracts before its analyzer,
page-check, ledger, generator, MCP and enforcement features can be built in parallel. No
documentation profile, documentation artifact schema, surface element model or analyzer contract
exists in the repository today. Without them, every downstream feature would invent its own shapes,
and the coverage ledger, parity matrix and `docs-complete` receipt could not be validated
consistently. Framework code must also stay domain-neutral: all repository specificity is runtime
configuration in a docs profile.

The owner's implementation-language rule requires that anything pushed down to destination
repositories is PowerShell or bash, so these contracts are delivered as PowerShell modules under
`.claude/lib/docs/` that need only PowerShell 7.4 or later in the destination.

## Personas & Scenarios

- Persona: Destination repository maintainer
  - Maintains one consumer repository that receives this repository's Claude customizations.
  - Cares that documentation correspondence can be checked without hand measurement, and that the
    tooling carries no other repository's names or assumptions.
  - Constraints: has no checkout of this repository and no Python or Node.js requirement for the
    documentation helpers; has PowerShell 7.4 or later.
  - Goals: a valid docs profile with minimal effort. Frustration: tooling that fails with messages
    that do not identify the faulty field.
  - Context: adopting the documentation estate tooling for the first time.
- Persona: Downstream epic feature author
  - Implements a later feature of the epic (page checker, surface analyzers, coverage ledger and
    receipt, reference generator, MCP tools or enforcement).
  - Cares that schema shapes, identifier rules, the dispatch table, the registry form and the
    command result contract are stated once and do not change under them.
  - Constraints: works in parallel with sibling features that insert rows into the same dispatch
    table, registry and pack manifest.
  - Goals: add a subcommand or analyzer, or produce an artifact that validates, on the first
    attempt. Frustration: contracts that are implied rather than written.
  - Context: wave-1 to wave-3 features of the epic.
- Persona: Documentation role agent
  - An agent role (architect, author, reconciler or coverage reviewer) that reads and proposes
    changes to documentation artifacts.
  - Cares that each artifact has a closed shape and that each disposition carries its required
    companion fields.
  - Constraints: has no direct write access to ledger or matrix artifacts; relies on validation
    findings to decide what to propose.
  - Goals: identify the undocumented or inconsistent element from a validation finding.
    Frustration: findings that do not point at a field.
  - Context: later documentation workflows built on these contracts.

- Scenario: Maintainer creates and validates a profile
  - Actor: destination repository maintainer.
  - Trigger: the maintainer decides to adopt the documentation estate tooling.
  - Steps: receives `.claude/lib/docs/` through the Claude push-down; runs
    `pwsh -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command init` to review the planned
    writes; runs it again with `-RepositoryId <id> -Write`; edits audiences, documentation roots and
    the Diataxis policy in `docs/documentation-estate/docs-profile.json`; runs
    `-Command validate-profile`.
  - Obstacles and decisions: an edit references an audience that is not declared; the command exits
    1 and names the pointer of the offending field; the maintainer corrects it. A second
    `init -Write` refuses to overwrite the edited profile unless `-Force` is given.
  - Outcome: `validate-profile` exits 0 and the profile is committed.
- Scenario: Feature author adds a subcommand and an analyzer
  - Actor: downstream epic feature author.
  - Trigger: a new command module or analyzer module under `.claude/lib/docs/` is ready.
  - Steps: inserts one row under the feature's own anchor in the dispatch table or the analyzer
    registry; computes element identifiers with `Get-DocsElementId` using the per-kind declaration
    conventions; lists the new file in the core pack manifest and mirrors it; validates its output
    artifact with `Test-DocsArtifactText`.
  - Obstacles and decisions: a sibling feature registered the same identifier with the same
    analysis method, a native row was added without a scanner row for its identifier, or a module
    path outside `.claude/lib/docs/` was used; registry validation reports an error and the module
    is never imported. An analyzer that returns a digest other than the declaration-lines digest of
    its element, or a method other than its row's method, has its output rejected.
  - Outcome: the table and registry validate with no findings, the manifest test passes, and the
    artifact validates against its schema.
- Scenario: Role agent reads a ledger entry
  - Actor: documentation role agent.
  - Trigger: a coverage ledger is supplied for review.
  - Steps: validates the ledger; reads each entry's disposition and companion fields.
  - Obstacles and decisions: an `excluded` entry lacks a rationale; validation rejects the ledger
    with a finding whose pointer locates the entry and field, and the agent proposes the missing
    rationale.
  - Outcome: the agent's proposal targets the exact entry and field named by the finding.

## Acceptance Criteria

- [ ] Every example under `examples/docs/v1/`, including the `-Json` envelope example, validates against its schema, and each artifact schema rejects an artifact that is missing a required field or that uses an unknown disposition or element kind, with a finding that locates the field (`tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1`).
- [ ] A maintainer running `Invoke-DocsCommand.ps1 -Command validate-profile` on the example profile gets exit code 0; on an invalid profile the command exits 1 and the finding's pointer and message name the failing field, including a field inside a nested shared definition, because field naming comes from the PowerShell structural walk rather than from `Test-Json` message text (`DocsProfileCommands.Tests.ps1`, `DocsSchema.Tests.ps1`).
- [ ] A maintainer running `Invoke-DocsCommand.ps1 -Command init` receives a starter profile that validates; nothing is written without `-Write`, and an existing profile is not overwritten without `-Force` (`DocsProfileCommands.Tests.ps1`).
- [ ] The same element kind, path and declaration always produce the same element identifier over a seeded set of inputs, distinct boundary inputs produce distinct identifiers, and recorded golden vectors match (`DocsSurface.Tests.ps1`).
- [ ] A neutrality test fails when a configured consumer identifier digest (SHA-256, never text) matches text under `.claude/lib/docs/` or `schemas/docs/`, so no consumer repository's name ships in the framework (`DocsNeutrality.Tests.ps1`).
- [ ] The push-down copy of every file under `.claude/lib/docs/` except `.claude/lib/docs/python/**` is byte-identical to its source and listed in the Claude core pack manifest, so a destination repository receives exactly what this repository tests, while the `.claude/lib/docs/python/` subtree stays reserved for the python pack (`Docs.Manifest.Tests.ps1`, including a test that its exclusion filter drops only `.claude/lib/docs/python/` paths, plus the existing push-down contract tests passing unmodified).
- [ ] The runtime schema copies under `.claude/lib/docs/schemas/v1/` are byte-identical to the canonical schemas under `schemas/docs/v1/`, so a destination validates against the same schemas this repository tests (`DocsSchemaContract.Tests.ps1`).
- [ ] Every subcommand reports exit code 0 for success, 1 for findings, 2 for usage errors and 3 for internal or environment errors (including PowerShell below 7.4), and with `-Json` writes exactly one deterministic envelope `{command, exit_code, findings, ok, result}`, with `command` `null` for a missing or unknown command, that 1036 can parse (`Invoke-DocsCommand.Tests.ps1`).
- [ ] A feature author can add a subcommand or analyzer by inserting a row under the feature's own anchor; the committed dispatch table carries the anchors 1020, 1021, 1022, 1023, 1024 and 1034 in that order, the scanner table of the analyzer registry carries the anchors 1022 and 1033 in that order, a separate native table carries the 1031 anchor so a native analyzer is added without editing the scanner table, the registry tests assert that these anchors and tables exist and find registered rows by membership rather than asserting a row count, so rows added by later features keep them passing, no anchor carries a placeholder number, the registry validates the rows of both tables, both the dispatch table and the registry validate with no findings, and invalid rows (duplicate name, duplicate identifier and analysis-method pair, reserved option, module outside `.claude/lib/docs/`) are rejected before any module is imported (`Invoke-DocsCommand.Tests.ps1`, `DocsAnalyzerRegistry.Tests.ps1`).
- [ ] `.claude/lib/docs` is classified in `quality-tiers.yml` (tier T3, provisional per OQ-4) and the tier check passes.
- [ ] No new Python or TypeScript file is added, and the plan's classification table shows every created or edited file's class and language.
- [ ] Discovery runtime, discovery schema and `.claude/lib/discovery-validation/` files are unchanged by this feature.
- [ ] Pester line coverage is at least 85% for each production file under `.claude/lib/docs/` (no branch-coverage gate applies to Pester), and no test creates a temporary file.
- [ ] (CI-dependent) The `poshqc / PowerShell QC` check on `windows-latest` passes on the pull request head.
- [ ] A reviewer can tell how each element was analyzed: every snapshot element, snapshot analyzer entry and ledger entry carries `analysis_method` `native` or `scanner`, a missing or unknown value is rejected with a finding that locates the field, the element identifier is the same for both methods, and the registry accepts a native analyzer only alongside a scanner for the same identifier (`DocsSchemaContract.Tests.ps1`, `DocsSurface.Tests.ps1`, `DocsAnalyzerRegistry.Tests.ps1`).
- [ ] A page is not marked stale by edits outside the documented declaration: a Pester test proves that the element digest is unchanged by edits outside the declaration's line range, by inserted lines above it, and by CRLF, BOM and final-newline differences, and changes for an edit inside the range; a declaration without a line range is rejected for every kind except `architecture-component`; and analyzer output whose digest differs from the recomputed declaration-lines digest is rejected (`DocsSurface.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `DocsAnalyzerRegistry.Tests.ps1`).
- [ ] 1036 and other callers can rely on a published envelope contract: `schemas/docs/v1/docs-command-envelope.schema.json` ships with a byte-identical runtime copy, bundle copy and `core.json` line, a Pester test validates `Invoke-DocsCommand.ps1 -Json` output against it for success, findings, usage-error, runtime-error and `-Help` runs, and envelopes that break the exit-code, `ok`, finding-count or key-set rules are rejected (`Invoke-DocsCommand.Tests.ps1`, `DocsSchemaContract.Tests.ps1`).
- [ ] A maintainer's audience identifiers follow one pattern shared with page metadata: the profile schema references the docs common `audience-id` definition, identifiers such as `maintainers` and `2nd-line` are accepted, and identifiers such as `Readers`, `docs.v2`, `a_b` and `-x` are rejected (`DocsProfile.Tests.ps1`, `DocsSchemaContract.Tests.ps1`).
- [ ] The author of the Python-native analyzer (1031) finds its preconditions in place: the command context offers a process member `InvokeProcess` (`FilePath`, `ArgumentList`, `StdinText`, `TimeoutSeconds`) that returns the exit code, standard output and standard error of a child process and reports a timeout; the member is a thin seam whose argument validation and result shaping are pure functions tested in memory with plain values, so no test starts a process, waits on a real timer or looks up an executable on PATH; tests can replace the member with an in-memory fake that records each call; and `New-DocsDiagnostic` accepts the severity `information`, which is never blocking (`Invoke-DocsCommand.Tests.ps1`, `DocsSurface.Tests.ps1`).

## Owner Questions

Carried from `spec.md` `## Owner Questions` with their provisional defaults: OQ-1 runtime schema
location (default: canonical `schemas/docs/v1/` plus a byte-identical runtime copy), OQ-2 Codex
reachability (default: Claude bundle only in 1020), OQ-3 PowerShell floor (default: 7.4, fail
closed below), OQ-4 tier (default: T3), OQ-5 `init -Write` scope (default: dry run by default,
create-only unless `-Force`), OQ-6 D5 self-contained fallback form (default: in-memory composed
schema from files that keep the docs common URN ref), OQ-7 `architecture-component` digest
exception (default: a null line range is allowed and the digest covers the whole normalized file),
OQ-8 granularity of the recorded method (default: per ledger entry, snapshot element and snapshot
analyzer entry; no method field on diagnostics), OQ-9 registry key and native selection (default:
unique on identifier and method, native requires scanner, native selected only when reported
available).

## Non-Goals

- The page checker, the `check` subcommand and the `page-metadata` schema (1021).
- Surface analyzers and the `inventory` subcommand (1022, 1033), and the Python-native analyzer
  and its pack packaging (1031); this feature defines only the registry, the analysis method, the
  digest contract, the process member and the diagnostic severities they follow, and creates no
  file under `.claude/lib/docs/python/`.
- Coverage ledger, parity matrix and evidence-pin semantics, staleness, the `docs-complete` receipt
  logic and their subcommands (1023); this feature defines only their schemas.
- The reference-page generator (1024), MCP tool wrappers (1036), CI and hook enforcement and
  the workflow template content (1034), documentation roles and skills (1037).
- Codex `.codex/lib/docs/` publication (OQ-2).
- A docs-site build.
- Any Python or TypeScript code, and any change to discovery runtime behavior or files.
- YAML profiles.
