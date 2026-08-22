# blast-radius-bundled-config-stale-skeleton (Spec)

- **Issue:** #500
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-21T17-16
- **Status:** Draft
- **Version:** 1.0

Authoritative inputs, read in this order:

1. `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/issue.md` — its
   `## Suspected Cause / Notes` section supersedes its `## Summary`.
2. `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/research/2026-08-21T17-16-blast-radius-bundled-config-drift-research.md`
   — the authoritative technical account. This spec points at it and does not duplicate it.
3. `artifacts/orchestration/orchestrator-state.json` — `research_findings` and `design_decisions`.
   `design_decisions[0]` (DD-1) is settled and is encoded below as given.

## Context

The blast-radius truth table that the push-down publishes into a destination workspace is wrong in
two opposite directions at once, and a third defect is present in this repository's own truth table.
Together they make thematically unrelated work items contend (fail closed) while items editing the
same root build file do not contend (fail open). The measured consequence recorded in `issue.md:44`
is a conflict graph at 83.3% density and a maximum parallel width of 2 over 16 items, so a parallel
run configured for a large `max_concurrency` executes nearly serially.

The three causes live in different files and have opposite failure directions. They are kept
distinct throughout this spec.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.x via Poetry (`poetry run`); PowerShell 7.6.5; Node/TypeScript for the
  `extensions/drm-copilot` workspace.
- Command/flags used: `Get-BlastRadius` and `Test-BlastRadiusConflict` from
  `.claude/lib/blast-radius/BlastRadius.psm1`; the TypeScript push-down entry point
  `pushDownClaude` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`.
- Data source or fixture: `config/blast-radius.json`,
  `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`, and
  `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` at the branch head
  `bug/blast-radius-bundled-config-stale-skeleton-500`.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. No build fails. The cost is paid as wall-clock on every parallel run and as drift: a late
item's plan is prepared against a `main` many merges stale. The fail-open half additionally means a
genuine contention on a root build file is not reported at all.

## Repro & Evidence

Steps to Reproduce:
1. From the worktree root, import `.claude/lib/blast-radius/BlastRadius.psm1` and load the bundled
   document `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` with
   `ConvertFrom-Json -AsHashtable`.
2. Derive two radii with `Get-BlastRadius` from plan text citing two unrelated files under
   `.claude/**` in inline code (a hook for item A, a skill document for item B), then call
   `Test-BlastRadiusConflict` on the pair. Research `## 5.1` gives the exact command.
3. Repeat step 2 against `config/blast-radius.json` as the negative control (research `## 5.2`).
4. Derive two radii from plan text citing a separator-free root token such as
   `Directory.Build.targets` against the bundled document, and inspect
   `Get-ConfigRootSurface -Config $bundled` (research `## 5.3`).
5. Read `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:131-135` and
   `:153-159`, and compare the two committed copies of `config/blast-radius.json`.

Expected:
Step 2 reports `conflict=False`: a hook and a skill document are not a shared unit of contention.
Step 4 admits the root token and reports `conflict=True` on the pair, because a root build file two
items both edit is a genuine contention point.

Actual:
Step 2 reports `conflict=True` with `{"kind":"module_overlap","detail":"claude-runtime"}`
(`issue.md:52-57`). Step 4 reports `conflict=False`, because `Get-ConfigRootSurface` returns an
empty set and the token is dropped before resolution.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet, observed on `b9a9b92c` and recorded in `issue.md:52-63`:

  ```text
  claude-runtime globs : ['.claude/**']

  unrelated .claude files   -> conflict=True
     {"detail":"claude-runtime","kind":"module_overlap"}

  control, no placeholder   -> conflict=False
  ```

Research `## Tooling Limitation` declares that no command in the research document was executed;
the research thread had read-only tools. Every command in research `## 5` is therefore an executor
obligation, and the fail-before / pass-after evidence for both failure directions must be captured
under
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

## Scope & Non-Goals

- In scope: the source of the push-down payload in this repository — `PAYLOAD_MODULES` in
  `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, the bundled
  `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`, the
  self-hosted `config/blast-radius.json`, the governing rule
  `.claude/rules/parallel-orchestration.md` with its bundled mirror, and the drift gate plus
  regression tests that hold the corrected state in place.
- Out of scope / non-goals: see `## Out of Scope` below, which is binding.
- Explicitly excluded systems, integrations, or datasets: no fix is made in a push-down
  destination. Both files named in the original report are destinations, and the next
  `push_down_claude_customizations` run would destroy a downstream fix (`issue.md:107-109`). No
  generator script is introduced (research `## 4.4` Option C). No JSON Schema is authored,
  imported, or read; enforcement remains prose plus validator and test logic.

## Root Cause Analysis

Three distinct causes. Research is the authoritative account; the citations below are the load-
bearing ones.

**Cause A — fail closed. Not the bundled JSON file.** `claude-runtime -> .claude/**` reaches every
destination from the hardcoded constant `PAYLOAD_MODULES` at
`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:131-135`.
`assembleModules` in the same file builds the destination module map from the destination scan plus
that constant and never reads the source document's `modules` key, so the bundled document's
`modules` key is dead code. This is the whole of the near-clique conflict graph. The issue's own
TaskMaster observation of "20 modules — 18 hand-added C# project modules, plus `claude-runtime` and
`config`" (`issue.md:93`) is exactly 18 derived project directories plus the two `PAYLOAD_MODULES`
entries; the 18 were derived, not hand-added.

**Cause B — fail open. This is the bundled JSON file.** `CARRIED_KEYS`
(`claude-blast-radius-derive-core.ts:153-159`) copies `version`, `shared_surfaces`,
`shared_surface_globs`, `over_breadth_fraction`, and `mandate_reads` verbatim from the bundled
document into the published document. All three bundled `shared_surfaces` entries contain a path
separator, so `Get-ConfigRootSurface`
(`.claude/lib/blast-radius/BlastRadiusConfig.psm1:266-280`) returns an empty set in every
destination, and `Get-PathTokenKind`
(`.claude/lib/blast-radius/BlastRadiusExtraction.psm1:328-342`) can therefore accept no
separator-free root token at all. Root build files are dropped from the radius before resolution,
so two items editing the same one report `conflict=False`.

**Cause C — the four `mandate_reads` gaps apply to the self-hosted copy too.** The `mandate_reads`
lists are currently byte-identical in both copies (`config/blast-radius.json:20-27` and the bundled
file lines 9-16). In this repository the missing exclusions produce `path_overlap` rather than
`module_overlap`, because the self-hosted map has no `claude-runtime` umbrella to absorb them.
`acceptance-criteria-tracking` is a `required_skills` entry on five of six routes in
`config/orchestration-routing.json`, so near-universal co-citation is expected; the issue measured
6 of 16 plans (`issue.md:46`).

**Divergence mechanism — a parity-gate scope gap, not a broken generator. There is no generator.**
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:20` sets
`SCOPED_ROOTS = (Path(".claude"),)`, and lines 101-126 enforce byte-identity for `.claude/**` only.
Issue #462 added the `config` tree to the shipped payload
(`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:41-50`) without extending
`SCOPED_ROOTS`. That is why the bundled `.claude/rules/parallel-orchestration.md` carries the
current issue-#489 doctrine text while the bundled `config/blast-radius.json` beside it does not:
the rules file is inside the parity scope and the config file is not.
`config/orchestration-routing.json` escaped the same fate only because it received three bespoke
parity pins (research `## 1.3`).

**A factually incorrect existing comment records the skeleton as deliberate.**
`tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:96-98` exempts the bundled
module map from the `claude-runtime` prohibition on the stated ground that it "describes the
DESTINATION repository's subsystems". That ground is wrong: the bundled module map is never read.
The exemption protects a dead field while the live source of `claude-runtime` in a destination —
`PAYLOAD_MODULES` — is pinned positively at
`extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:474`.

## Proposed Fix

### Design summary (what changes where):

Five coordinated changes, each independently verifiable:

1. Remove `claude-runtime` from `PAYLOAD_MODULES`, leaving `{ config: ["config/**"] }`. Fixes
   Cause A.
2. Correct the bundled `config/blast-radius.json`: 6-entry portable `shared_surfaces`,
   `shared_surface_globs` left empty, four `mandate_reads` entries added, `modules` reduced to
   `{ "config": ["config/**"] }`. Fixes Cause B.
3. Add the same four `mandate_reads` entries to the self-hosted `config/blast-radius.json`. Fixes
   Cause C.
4. Amend `.claude/rules/parallel-orchestration.md` and mirror the amendment byte-identically into
   `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`.
5. Add a three-class key-partition drift gate in Python, mirror it in PowerShell, and add the
   TypeScript assertion on `PAYLOAD_MODULES`.

### Boundaries and invariants to preserve:

- **The governing asymmetry, stated as a design constraint.** Ship the broader set for
  `shared_surfaces`, `shared_surface_globs`, and `mandate_reads`; ship the narrower set for
  `modules`. The mechanism, not merely the conclusion:
  - An over-matching **module** glob costs concurrency on every pair it touches.
    `Resolve-BlastRadiusModule` (`.claude/lib/blast-radius/BlastRadiusNormalization.psm1:133-182`)
    admits a module as soon as one of its globs covers one radius entry, and two items whose only
    commonality is that shared match then contend at `module_overlap`
    (`.claude/lib/blast-radius/BlastRadius.psm1:457-468`).
  - A **surface** or **mandate-read** entry naming a path the destination lacks is inert.
    `Resolve-BlastRadiusSharedSurface` (`BlastRadiusConfig.psm1:408-460`) iterates the radius's
    concrete paths and tests each against the configured list, and `Test-MandateRead`
    (`BlastRadiusNormalization.psm1:185-242`) removes only entries a plan actually cited. A
    configured entry that no plan ever cites contributes nothing.
  - A **separator-free** shared surface is additionally the sole gate on whether the extractor
    accepts a separator-free token at all: `Get-ConfigRootSurface`
    (`BlastRadiusConfig.psm1:266-280`) returns exactly the `shared_surfaces` entries containing no
    `/`, and `Get-PathTokenKind` (`BlastRadiusExtraction.psm1:328-342`) accepts such a token if and
    only if it is an exact ordinal member of that set. Omitting a separator-free surface therefore
    does not merely lose one resolution input; it removes an entire token class from every radius.
  - Consequently the cost of a surface entry a destination lacks is zero, and the cost of a missing
    one is a false negative in a fail-closed relation; the cost of an over-broad module entry is
    paid on every pair.
- `shared_surface_globs` stays empty in the bundle. All three self-hosted globs are
  `scripts/dev_tools/*.py` patterns naming this repository's Python dev-tooling module families and
  describe no destination. An empty list is acceptable rather than merely tolerable because a glob
  is never a source of root-token acceptance (`BlastRadiusConfig.psm1:244-247`).
- The module-map granularity criterion in `.claude/rules/parallel-orchestration.md` is applied, not
  amended: `config/**` in a destination holds only the two published files, both declared shared
  surfaces, so `config` names a subsystem an item can plausibly not touch. Removing
  `claude-runtime` never weakens contention below the path level — two items editing the same hook
  still contend at `path_overlap`.
- The no-signal floor stays non-empty. `assembleModules` merges `PAYLOAD_MODULES`
  unconditionally, so with `{ config: ["config/**"] }` remaining the assembled map is never empty
  and `assertNoForbiddenGlob` has a non-vacuous input.
- Byte-identity of `.claude/**` between the repository and the bundle
  (`test_push_down_claude_resource_contracts.py:101-126`) is preserved: the rule edit lands in both
  copies in the same commit.
- `config/orchestration-routing.json` parity across its three copies is untouched.
- The derivation's byte-stability pin (`blast-radius-derive-core.test.ts`, ordinal-sort case) must
  continue to pass.

### Dependencies or blocked work:

None. No external service, release, or upstream change is required. The five changes are ordered so
each is independently verifiable, but they must land in one commit because the parity and drift
gates cross-check them.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production and data:
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` —
  `PAYLOAD_MODULES` (lines 131-135) and its doc comment (lines 123-130).
- `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` — all of
  `shared_surfaces`, `mandate_reads`, and `modules`.
- `config/blast-radius.json` — `mandate_reads` only.
- `.claude/rules/parallel-orchestration.md` and
  `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
  — identical amendment in both.

Tests:
- `tests/scripts/dev_tools/test_blast_radius_config.py` — extend with the drift gate.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` — mirror the gate;
  correct the incorrect comment at lines 96-98.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` — update the
  expectations at lines 137, 153, 240, 252, 338, 474 and add the negative assertion on
  `PAYLOAD_MODULES`.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` — update the seeded
  expectations at lines 44, 122, 292, 387.
- `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` — update the seeded
  `SOURCE_BLAST_RADIUS` constant (line 84) and its comment at lines 61-72 to mirror the corrected
  bundled file.
- `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` — narrow the AC8
  forbidden-substring list at lines 284-293 and rewrite its rationale comment per DD-1.

#### Functions/classes/CLI commands impacted:

- `PAYLOAD_MODULES` (exported constant) and `assembleModules` in
  `claude-blast-radius-derive-core.ts`. `assembleModules` logic is unchanged; only its constant
  input changes.
- No PowerShell library function is modified. `Get-ConfigRootSurface`, `Get-PathTokenKind`,
  `Resolve-BlastRadiusModule`, `Resolve-BlastRadiusSharedSurface`, and `Test-MandateRead` change
  behaviour only through the corrected data they read.
- No CLI command, MCP tool, or validator entry point gains a flag, parameter, or artifact type.

#### Data flow and validation changes:

The published document's `modules` key loses the `claude-runtime` entry. The published
`shared_surfaces` grows from 3 to 6 entries, three of them separator-free, which re-enables the
root-token branch of `Get-PathTokenKind` in every destination. The published `mandate_reads` grows
by four entries, which removes matching citations from the harvest before module and surface
resolution in both `derive_blast_radius` and `validate_blast_radius`, keeping V1 and V2
self-consistent. `shared_surface_globs` and `over_breadth_fraction` are unchanged.

#### Error handling and logging updates:

None. No new failure path is introduced. The `modules` key is retained in the bundled file rather
than deleted, because `tests/scripts/dev_tools/test_blast_radius_config.py` calls
`load_module_globs` on the bundled copy and that helper raises `TypeError` on an absent `modules`
key; deletion would require a test change that buys nothing (research `## 3.1`).

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Rollback is a revert of the single commit. The change is data plus one constant
plus tests, with no migration and no persisted state.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

The bundled `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
after the fix:

- `version`: `1` (unchanged).
- `shared_surfaces` (6 entries, per DD-1): `.claude/settings.json`, `config/blast-radius.json`,
  `config/orchestration-routing.json`, `package-lock.json`, `poetry.lock`, `quality-tiers.yml`.
- `shared_surface_globs`: `[]` (unchanged).
- `mandate_reads` (10 entries): the six existing entries plus
  `.claude/skills/acceptance-criteria-tracking/SKILL.md`,
  `.claude/skills/policy-compliance-order/SKILL.md`, `.claude/agent-memory/**`, and
  `.agents/skills/**`.
- `modules`: `{ "config": ["config/**"] }`.
- `over_breadth_fraction`: `0.25` (unchanged).

`config/blast-radius.json` after the fix: `mandate_reads` gains the same four entries. All other
keys are unchanged, including its 10 `shared_surfaces`, its 3 `shared_surface_globs`, and its seven
subsystem modules.

`PAYLOAD_MODULES` after the fix: `{ config: ["config/**"] }`.

#### Required configuration keys and defaults:

No key is added or removed from either document's top-level shape. `mandate_reads` remains optional
and fail-closed: a truth table that omits it excludes nothing.

#### Backward-compatibility expectations:

This is a behaviour change for push-down destinations, and must be described as such in the PR
body. A destination that receives a subsequent push-down gains three separator-free shared
surfaces and four mandate-read exclusions, and loses the `claude-runtime` module. Nothing in the
document's schema changes, so an older destination runtime reads the new document without error.
No version bump is demanded by the tier matrix at T4.

#### Performance constraints (latency/throughput/memory):

None binding. The blast-radius library performs no filesystem, subprocess, network, or wall-clock
access (`BlastRadiusConfig.psm1:16-17`), and the added entries change collection sizes by single
digits. The intended effect is a throughput improvement in parallel scheduling, which is not
asserted as a numeric target in this spec.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - The production push-down path is the TypeScript one
    (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:166-201` wires the MCP tool
    to `pushDownClaude` with `sourceRoot = <extensionRoot>/resources/claude-customizations`). The
    Python CLI publishes no `config/` tree; that divergence is a separate follow-up.
  - The bundled file is the push-down *source*, not a destination, so nothing overwrites it. The
    durability question the gate answers is whether a future self-hosted change silently fails to
    reach it.
  - The executor has `poetry`, `npm` in `extensions/drm-copilot`, PowerShell 7, and the PoshQC MCP
    functions available.
- Constraints (budget, performance, compatibility):
  - Policy reading order per `CLAUDE.md` before any code or test change.
  - `.claude/rules/general-code-change.md`: change only what is needed; no opportunistic refactor;
    500-line limit on production, test, and reusable script files (Markdown exempt).
  - `.claude/rules/general-unit-test.md`: tests live under `tests/` mirroring production structure;
    no temporary files; no production file excluded from coverage.
  - Every acceptance condition must be falsifiable per `.claude/rules/plan-acceptance-gates.md`:
    coverage targets expressed as importable dotted names with the `=` form, and search assertions
    stated as short single-line non-interpolated tokens.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact

- User-facing or API changes: none in this repository. In a push-down destination, the published
  `config/blast-radius.json` changes content as specified above. No MCP tool signature, CLI flag,
  or exported function signature changes.
- Data or migration considerations: none. Both documents are read-only configuration data with no
  persisted derivative.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): `version` stays `1`; the schema is
  unchanged, so no bump is warranted. `PAYLOAD_MODULES` and the bundled content are consumed across
  a repository boundary, so the change must be called out in the PR body as a destination-visible
  behaviour change.

## Test Strategy

Seeded from issue:

- [x] Unit coverage areas — bundled-config content, drift-gate logic, and the parity assertion.
- [x] Integration scenario to retest — derive two radii citing unrelated `.claude/**` files against
      the published document and assert `conflict=False`.
- [x] Manual verification notes — none required; every step is automatable (research
      `## Automation Feasibility`).

- Regression tests to add or update: a fail-before / pass-after test for each failure direction.
  Fail closed: two radii citing unrelated `.claude/**` files must report `conflict=False` against
  the published document. Fail open: two items citing the same separator-free root surface must
  report `conflict=True`. The natural home for the first is the TypeScript publish path; for the
  second, `tests/scripts/dev_tools/test_blast_radius_config.py` parametrized over both copies.
- Unit tests (pytest) for the fixed behavior and boundaries: the three-class key-partition gate of
  research `## 4.2` and `## 4.5`, extending the existing two-copy `COMMITTED_CONFIGS` pattern at
  `tests/scripts/dev_tools/test_blast_radius_config.py:474-499`. Class 1 (`version`,
  `over_breadth_fraction`, `mandate_reads`) byte-equal between the copies; Class 2
  (`shared_surfaces`, `shared_surface_globs`) equal to a declared `PORTABLE_SHARED_SURFACES`
  constant and a subset of the self-hosted values; Class 3 (`modules`) a subset of the
  `PAYLOAD_MODULES` name set with no member of the five-name umbrella denylist in either copy.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): a non-vacuity
  floor so a renamed key cannot make the gate pass silently (`COMMITTED_CONFIGS` has exactly two
  members; each compared collection intended to be non-empty is non-empty); every separator-free
  bundled `shared_surfaces` entry is wildcard-free, because a wildcard-bearing separator-free entry
  would be admitted by `Get-ConfigRootSurface` yet classified as a glob; a publish into a
  destination with no observable layout emits a `modules` map whose keys exclude `claude-runtime`.
- Error handling and logging verification: not applicable; no new failure path. Every gate failure
  message must carry the repo-relative label of the offending copy, matching the established
  pattern.
- Coverage impact and targets for changed lines/modules: line >= 85% and branch >= 75% for Python
  and TypeScript; line >= 85% only for PowerShell, which Pester cannot measure for branches. No
  coverage regression on changed lines — this is the binding constraint, because the TypeScript
  change edits an exported constant in a module whose test file already exists. No production file
  is excluded from measurement and no `exclude` entry is added.
- Toolchain commands to run (format -> lint -> type-check -> test):
  - Python: `poetry run black .`; `poetry run ruff check .`; `poetry run pyright`;
    `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`
  - TypeScript, from `extensions/drm-copilot`: `npm run format`; `npm run lint`;
    `npm run typecheck`; `npm run test:unit`
  - PowerShell: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`,
    `mcp__drm-copilot__run_poshqc_test`.
- Manual validation steps (if required): none.

## Acceptance Criteria

- [x] `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` declares
      `PAYLOAD_MODULES` as `{ config: ["config/**"] }` with no `claude-runtime` key, and its doc
      comment at lines 123-130 states why the `.claude` tree is not a module. Verified by
      `poetry run pytest`-independent inspection plus the TypeScript suite below.
- [x] `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` no longer
      positively pins `claude-runtime`: the expectations at lines 137, 153, 240, 252, 338, and 474
      are updated, and the file asserts that the `PAYLOAD_MODULES` key set excludes
      `claude-runtime` and that its glob set contains no member of `FORBIDDEN_GLOBS`. Verified by
      `npm run test:unit` in `extensions/drm-copilot`.
- [x] `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` seeded expectations at
      lines 44, 122, 292, and 387 are updated, and
      `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` `SOURCE_BLAST_RADIUS`
      (line 84) and its comment at lines 61-72 mirror the corrected bundled file. Verified by
      `npm run test:unit`.
- [x] `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` declares
      exactly the 6-entry portable `shared_surfaces` set `.claude/settings.json`,
      `config/blast-radius.json`, `config/orchestration-routing.json`, `package-lock.json`,
      `poetry.lock`, `quality-tiers.yml`; `shared_surface_globs` is `[]`; `mandate_reads` carries
      the four added entries; and `modules` is exactly `{ "config": ["config/**"] }`. Verified by
      the Class 2 and Class 3 assertions of the new gate in
      `tests/scripts/dev_tools/test_blast_radius_config.py`.
- [x] `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` AC8
      forbidden-substring list at lines 284-293 no longer forbids `poetry.lock` or
      `package-lock.json`, and its rationale comment states that the exclusion targets entries
      naming this repository's directory layout rather than ecosystem-standard root lockfile names
      (DD-1). Verified by `npm run test:unit`.
- [x] `config/blast-radius.json` `mandate_reads` carries the four added entries
      `.claude/skills/acceptance-criteria-tracking/SKILL.md`,
      `.claude/skills/policy-compliance-order/SKILL.md`, `.claude/agent-memory/**`, and
      `.agents/skills/**`, and its `shared_surfaces`, `shared_surface_globs`, and `modules` are
      otherwise unchanged. Verified by the Class 1 byte-equality assertion of the new gate.
- [x] `.claude/rules/parallel-orchestration.md` records, under the Blast-Radius Contention
      Doctrine, (a) that the destination module map is derived and the bundled `modules` key is not
      consumed, (b) that `PAYLOAD_MODULES` carries `config` only and `claude-runtime` is
      disqualified in a destination by the same granularity criterion that removed it here, and
      (c) that the bundled `shared_surfaces` and `shared_surface_globs` sets are the
      destination-portable subset, with the surfaces/modules asymmetry as the stated reason.
- [x] `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
      is byte-identical to `.claude/rules/parallel-orchestration.md` after that amendment, in the
      same commit. Verified by
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
      whose `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 101-126) fails
      otherwise.
- [x] `tests/scripts/dev_tools/test_blast_radius_config.py` carries the three-class key-partition
      gate, extending the existing two-copy `COMMITTED_CONFIGS` pattern at lines 474-499: Class 1
      byte-equality of `version`, `over_breadth_fraction`, and `mandate_reads` across the two
      copies; Class 2 bundled `shared_surfaces` equal to a declared `PORTABLE_SHARED_SURFACES`
      constant and a subset of the self-hosted list, with bundled `shared_surface_globs` empty;
      Class 3 bundled `modules` key set a subset of the `PAYLOAD_MODULES` name set. Verified by
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py`.
- [x] The same file asserts that neither copy declares any of the five disqualified umbrella module
      names `python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`,
      `agents-surface`, extending the existing two-name location-bucket pin; that every
      separator-free bundled `shared_surfaces` entry is wildcard-free; and a non-vacuity floor
      under which `COMMITTED_CONFIGS` has exactly two members and each collection intended to be
      non-empty is non-empty. Verified by the same pytest invocation.
- [x] `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` mirrors the Class 1
      equality, the Class 3 subset, the five-name umbrella denylist applied to both copies, and the
      separator-free-wildcard-free assertion, and stays under the 500-line limit. Verified by
      `mcp__drm-copilot__run_poshqc_test`.
- [x] The comment at `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:96-98`
      no longer states that the bundled module map describes the destination repository's
      subsystems, and instead records that the bundled `modules` key is never read and that
      `PAYLOAD_MODULES` is the live source of a destination's payload modules. Verified by reading
      the file and by `mcp__drm-copilot__run_poshqc_test`.
- [x] A regression test fails before the fix and passes after it for the fail-closed direction: two
      radii derived from plan text citing unrelated `.claude/**` files (a hook and a skill document)
      against the published document report `conflict=False`. The failing-before run is captured
      under `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/regression-testing/`
      and the passing-after run under `.../evidence/qa-gates/`.
- [x] A regression test fails before the fix and passes after it for the fail-open direction: two
      items citing the same separator-free root surface (for example `package-lock.json`) against
      the bundled document report `conflict=True`, with `Get-ConfigRootSurface` returning a
      non-empty set. Evidence captured in the same two locations.
- [x] Coverage obligations met and recorded: line coverage >= 85% and branch coverage >= 75% for
      Python (`poetry run pytest ... --cov=scripts.dev_tools --cov-branch`) and for TypeScript
      (`npm run test:coverage` in `extensions/drm-copilot`); line coverage >= 85% for
      PowerShell, which is exempt from the
      branch threshold only because Pester measures no branch coverage. No coverage regression on
      changed lines, and no `exclude` entry added. Per `.claude/rules/general-unit-test.md` and
      `.claude/rules/quality-tiers.md`.
- [x] Full toolchain pass in a single run for all three languages: Black, Ruff, Pyright, Pytest;
      Prettier, ESLint, tsc, Jest in `extensions/drm-copilot`; PoshQC format, analyze, and test.
- [x] `git log --follow` output for both copies of `config/blast-radius.json` is captured as
      evidence, confirming the parity-gate scope-gap divergence mechanism, and a byte compare
      (`Get-FileHash`) of `config/orchestration-routing.json` against
      `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`
      confirms that pair independently of its TypeScript test.

## Out of Scope

The five items below are reproduced from research `## Out of Scope (do not widen)` and are binding.
Each is a genuine finding; none is fixed here.

1. **The placeholder-extraction defect in `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`**
   (`Get-PlanPaths` harvesting `<FEATURE>/spec.md` as a real path). Filed separately
   (`issue.md:111-114`).
2. **The Python/TypeScript push-down `ROOT_FOLDERS` divergence.**
   `scripts/dev_tools/push_down_claude_customizations.py:101` sets
   `ROOT_FOLDERS = (Path(".claude"),)` while
   `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:50` sets
   `[".claude", "config"]`, so a destination pushed via the Python CLI receives no truth table at
   all. Follow-up.
3. **Neither `quality-tiers.yml` nor `docs/ci.research.md` exists in this repository**, even though
   `.claude/rules/quality-tiers.md` names both authoritative — the first as the repo-root tier map
   and the second as the tier-system source of truth. Globbing `**/quality-tiers.y*ml` returns no
   files and `.gitignore` carries no such entry. This is a real pre-existing defect and a
   follow-up, and it does **not** block this fix: `quality-tiers.yml` still belongs in the bundled
   portable set because `.claude/rules/quality-tiers.md` mandates a repo-root tier map in any
   repository using this runtime, and under the governing asymmetry an absent entry is inert. The
   consequence for this fix is only that the tier of each file in scope is inferred from the rule
   prose (T4 for the configuration data and the push-down tooling) rather than looked up.
4. **The absence of a merge decorator for `config/blast-radius.json`**, which means
   destination-local `shared_surfaces` additions are destroyed on every push
   (`claude-config-carriage.test.ts:297-321` pins the overwrite). Follow-up. It is the structural
   reason the portable set must be correct upstream.
5. **Parity coverage for the `.github/**` and `.mcp.json` dual-location pairs**, which research did
   not locate and did not assert either way. Follow-up rather than an assumption.

Additionally rejected, and not to be reintroduced (research `## 4.4`):

- Extending `SCOPED_ROOTS` to `config/` and requiring byte-identity (Option A) — forces
  drm-copilot-specific paths and a discarded 7-module map into every destination.
- A checked-in expected-delta manifest file (Option B) — a third artifact whose own staleness is
  unguarded, reproducing this defect one level up.
- A generated-from-source bundled file with a regeneration no-op gate (Option C) — scope widening
  on a bug fix; recommended as the follow-up that the chosen gate can be promoted into.
- A blanket `.claude/skills/**` mandate-read entry instead of the four named paths — skill
  documents are ordinary feature-work targets in this repository, so a blanket exclusion would
  strip genuine write claims from derived radii.
- Fixing the two files named in the original report downstream in the destination repository — both
  are push-down destinations and the next push-down would destroy the fix.

## Risks & Mitigations

- Technical or operational risks:
  - **Destination-visible behaviour change.** A destination that receives a subsequent push-down
    gains three separator-free shared surfaces and four mandate-read exclusions and loses the
    `claude-runtime` module. A destination whose plans genuinely write
    `.claude/skills/acceptance-criteria-tracking/SKILL.md` or `.claude/agent-memory/**` would no
    longer see those citations as contention.
  - **DD-1 narrows an assertion an earlier feature deliberately set.** The AC8 forbidden-substring
    list at `claude-config-carriage.test.ts:284-293` currently forbids `poetry.lock` and
    `package-lock.json`.
  - **Mirror drift.** An edit to `.claude/rules/parallel-orchestration.md` without the bundled
    mirror breaks `test_push_down_claude_resource_contracts.py`.
  - **The drift gate does not remove the manual step.** It guarantees only that skipping the manual
    propagation is caught, not that propagation happens automatically.
- Mitigations and rollbacks:
  - The mandate-read exclusion describes the default reading relationship, not a permanent ban:
    bounding constraint 1 in `.claude/rules/parallel-orchestration.md` obliges a planner to append
    a genuine write explicitly, and bounding constraint 3 (`detect_escaped_paths`) catches an item
    that wrote an excluded path against observed diff evidence rather than against prose.
  - DD-1 requires the list and its rationale comment to be narrowed in the same diff, so the
    decision is visible in review rather than implicit. Research also established that the AC8
    assertion runs against the hermetic in-memory constant `SOURCE_BLAST_RADIUS`
    (`config-carriage.test-helpers.ts:74-91`) rather than the real bundled file, so the change does
    not silently satisfy a test it contradicts.
  - The mirror obligation is stated as its own acceptance criterion and is enforced by an existing
    test that fails loudly.
  - Class 1 byte-equality and Class 2 portable-set equality both fail loudly when a future
    self-hosted change does not reach the bundle.
  - Rollback is a single-commit revert; there is no migration or persisted state.

## Rollout & Follow-up

- Release/rollout steps: land the five changes in one commit on
  `bug/blast-radius-bundled-config-stale-skeleton-500`, rebase onto `main` before opening the pull
  request, open the pull request against `main`, and state the destination-visible behaviour change
  in the PR body. No extension release, no configuration migration, and no destination action are
  required beyond the next ordinary `push_down_claude_customizations` run.
- Post-fix monitoring or clean-up tasks: re-derive the conflict graph over the committed plans under
  `docs/features/active/` after the fix and record the resulting density and cohort depth as
  evidence, so the measured improvement over the `issue.md:44` baseline (83.3% density, maximum
  width 2 over 16 items) is on record. File the five follow-ups enumerated in `## Out of Scope`.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/500
  - Issue record: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/issue.md`
  - Research: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/research/2026-08-21T17-16-blast-radius-bundled-config-drift-research.md`
  - Governing rule: `.claude/rules/parallel-orchestration.md`
  - Settled decision DD-1: `artifacts/orchestration/orchestrator-state.json`, `design_decisions[0]`
  - Source: `docs/features/potential/2026-08-21-blast-radius-claude-runtime-umbrella-serializes-all-work.md`
