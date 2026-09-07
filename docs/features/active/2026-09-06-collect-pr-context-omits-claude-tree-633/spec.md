# collect-pr-context-omits-claude-tree (Spec)

- **Issue:** #633
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening` (child H), non-blocking preparation-mode child
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06
- **Status:** Draft
- **Version:** 0.1

## Context

`collect_pr_context` (`mcp__drm-copilot__collect_pr_context`) renders a "Changed files
overview" section that only enumerates a changed file if it matches one of three
allowlist rules. The relevant code is the bucket-partition loop in
`extensions/drm-copilot/src/lib/pr-context/collector-core.ts:316-333`:

```typescript
  const bucketCore: BucketEntry[] = [];
  const bucketRenames: BucketEntry[] = [];
  const bucketDocs: BucketEntry[] = [];
  // Partition changed files into core/renames/docs buckets by status and path.
  for (const [path, status] of statusMap) {
    const stats = perFileStats.get(path) ?? [0, 0];
    if (status.startsWith("R")) {
      bucketRenames.push([path, stats]);
    } else if (path.endsWith(".py") || path.endsWith(".ps1")) {
      bucketCore.push([path, stats]);
    } else if (
      path.startsWith("docs/") ||
      path.startsWith(".github") ||
      path.includes("AGENTS")
    ) {
      bucketDocs.push([path, stats]);
    }
  }
```

There is no terminal `else`. A non-renamed file only reaches a bucket if it ends in
`.py`/`.ps1`, or starts with `docs/`/`.github`, or contains the case-sensitive substring
`AGENTS`. Every other changed file is silently dropped from all three buckets and never
appears in the "Changed files overview" section that `collector-output.ts` renders from
`bucketCore`/`bucketRenames`/`bucketDocs` (`collector-output.ts:230-235`,
`bucketText(...)` helper at `summary-helpers.ts:270`). A dropped file may still appear in
the raw diff appendix elsewhere in the PR context bundle, but not in the human-facing
overview reviewers read first.

Environment:
- OS/version: Windows 11 Pro (10.0.26200)
- Command/flags used: `mcp__drm-copilot__collect_pr_context` invoked during PR body
  preparation for a large consolidation PR
- Data source or fixture: a real PR diff touching 92 changed files, most under
  `.claude/**`

Impact / Severity: High. The overview is the primary artifact reviewers read; when it
covers only a small fraction of changed files, reviewers are silently misdirected to an
appendix for the majority of the changeset.

## Repro & Evidence

Steps to Reproduce:
1. Produce a changeset touching files that are not `.py`/`.ps1`, do not start with
   `docs/`/`.github`, and do not contain the substring `AGENTS` (for example, anything
   under `.claude/agents/**`, `.claude/rules/**`, `.claude/skills/**`, or any `.ts`,
   `.sh`, `.bats`, or `.json` file anywhere in the repository).
2. Run `collect_pr_context` (`mcp__drm-copilot__collect_pr_context`) against that
   changeset.
3. Inspect the rendered "Changed files overview" section.

Expected: every changed, non-renamed file is enumerated in exactly one of the three
overview buckets.

Actual: observed against a real 92-file changeset, only 2 of 92 changed files reached
the overview. Research (`research/pr-context-bucket-gap.2026-09-06.md`, Q1) independently
confirmed the mechanism by direct code read and enumerated concrete, currently-committed
repository paths that drop through the allowlist today, including:
- `extensions/drm-copilot/src/**/*.ts` and `extensions/drm-copilot/test/**/*.ts` (the
  entire extension source and test tree, over 100 files each by direct enumeration)
- `.claude/agents/*.md` (24 files) and `.claude/rules/*.md` (20 files) — lowercase
  `agents`/`rules`, so the case-sensitive `AGENTS` substring check never matches
- `.claude/skills/**/*.md` (100+ files) and the parallel `.agents/skills/**/SKILL.md`
  tree (~65 files) — same case-sensitivity gap
- `tests/shell/*.bats` (23 files)
- `scripts/bash/*.sh` (8 files) and `.claude/lib/bash/*.sh` (9 files)
- root/package JSON and YAML config outside `docs/`/`.github` (`package.json`,
  `extensions/drm-copilot/package.json`, `config/orchestration-routing.json`, etc.)

At least six broad, independently-populated file categories drop through in this
repository today. This confirms the observation's phrasing ("does not enumerate
`.claude/**`") describes a visible symptom of a materially larger, allowlist-shaped
defect, not a `.claude`-specific exclusion — there is no `.claude` string anywhere in the
bucketing code.

Logs / Screenshots:

```typescript
// extensions/drm-copilot/src/lib/pr-context/collector-core.ts:316-333 (current state)
  const bucketCore: BucketEntry[] = [];
  const bucketRenames: BucketEntry[] = [];
  const bucketDocs: BucketEntry[] = [];
  for (const [path, status] of statusMap) {
    const stats = perFileStats.get(path) ?? [0, 0];
    if (status.startsWith("R")) {
      bucketRenames.push([path, stats]);
    } else if (path.endsWith(".py") || path.endsWith(".ps1")) {
      bucketCore.push([path, stats]);
    } else if (
      path.startsWith("docs/") ||
      path.startsWith(".github") ||
      path.includes("AGENTS")
    ) {
      bucketDocs.push([path, stats]);
    }
  }
```

## Scope & Non-Goals

- In scope:
  - Add a terminal `else` branch to the bucket-partition loop in
    `extensions/drm-copilot/src/lib/pr-context/collector-core.ts:316-333` that routes
    every unmatched, non-renamed path into `bucketDocs` (the existing
    "Docs/templates/agents/tooling" bucket), so every changed, non-renamed file reaches
    exactly one bucket. This is the fully general fix identified by research as the
    correct scope, since the defect is a property of the allowlist's predicates
    (extension / prefix / case-sensitive substring), not of any single directory; a
    `.claude`-only patch would leave at least five other populated categories dropping
    (see Repro & Evidence above and `research/pr-context-bucket-gap.2026-09-06.md` Q1).
  - Add regression test coverage in
    `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` and
    `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` asserting that
    a representative previously-dropped path (e.g., a `.claude/skills/**/SKILL.md` path
    and a `.ts` source path) now reaches the overview, and that the empty-bucket fixture
    in `collector-output-freshness.test.ts:74-76` still passes with all buckets empty
    when there are genuinely no changed files.
- Out of scope / non-goals:
  - **The Python parity module (`scripts/dev_tools/pr_context/collector.py:320-330`).**
    Research (Q3) found the identical missing-terminal-else defect in this module, but
    also found **no enforced or binding parity contract** between the TypeScript and
    Python implementations: no CI job compares their output, no test asserts behavioral
    parity, and the only documented parity expectation (`docs/features/completed/2026-06-25-port-python-commands-to-typescript-240/spec.md:16-18`,
    AC-E1) is a completed, non-re-validated epic acceptance criterion. Per this bug's
    scope constraint ("confined to the extension and, if the parity contract requires
    it, the Python parity module"), and because no contract requires it, the Python
    module is explicitly **not** modified by this fix. See "Known Limitation" below.
  - Relabeling the `bucketCore`/`bucketDocs` bucket headings (e.g., moving `.ps1` hook
    files that are enforcement tooling rather than "Core logic changes" into a more
    accurate bucket). Research noted this as an existing, incidental labeling mismatch,
    but it is a separate, smaller decision that does not block closing the
    terminal-else gap and is not part of this bug's scope.
  - Any change to `scripts/bash/cleanup_worktrees_*` or `.claude/hooks/*` — those files
    are owned by other children of the `cleanup-merged-worktrees-hardening` epic;
    concurrent edits would conflict at fan-in.
  - Any change to `.claude/agent-memory/**` handling. Research (Q2) established that no
    path under the gitignored root `.claude/agent-memory/**` is currently tracked
    (`git ls-files -- .claude/agent-memory` returns zero results, independently
    verified), and that `collect_pr_context`'s file enumeration (`git diff --name-status`
    via `GitClient.diffRange`) only ever surfaces tracked content — an untracked,
    gitignored path cannot enter that diff regardless of the bucket defect. There is
    therefore no `.claude/agent-memory/**`-specific behavior to fix; the fix's general
    terminal-else branch would apply to such a path only if it were ever force-added and
    tracked in the future, which is out of scope to engineer for here.
  - Adding a fourth bucket. The fix reuses the existing third bucket
    ("Docs/templates/agents/tooling") as the catch-all destination rather than
    introducing a new bucket, to keep the change minimal (one partition-loop edit) and
    avoid touching the section-rendering pipeline, the section-order array in
    `collector-output.test.ts:102-121`, and other bucket-count-sensitive fixtures.
- Explicitly excluded systems, integrations, or datasets: none beyond the above.

## Known Limitation (Python Parity Module)

`scripts/dev_tools/pr_context/collector.py:320-330` has the identical
missing-terminal-else defect as the TypeScript loop this fix corrects (confirmed by
direct read in `research/pr-context-bucket-gap.2026-09-06.md`, Q3). Because no CI job,
test, or repository policy currently binds the two implementations to identical
behavior, this fix does not modify the Python module, and the two implementations will
diverge on this specific behavior after this fix ships (TypeScript enumerates every
changed file in the overview; Python continues to drop the same categories it drops
today). This is a known, intentionally out-of-scope gap, not an oversight.

**Recommendation:** file a follow-up bug against
`scripts/dev_tools/pr_context/collector.py` to apply the identical terminal-else fix
there, referencing this issue (#633) and the research finding at
`research/pr-context-bucket-gap.2026-09-06.md` (Q3). The follow-up should also consider
whether a lightweight parity test (e.g., a differential test running both
implementations against the same synthetic diff fixture and asserting identical bucket
membership) should be added at that time, given that a prior, unrelated Python/TypeScript
divergence in pr-context handling has already been separately documented
(`docs/features/potential/2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md`).

## Root Cause Analysis

- Root cause: the bucket-partition loop in `collector-core.ts:316-333` is an
  `if`/`else if`/`else if` chain with no terminal `else`. A file is included in the
  rendered overview only if it matches one of three predicates (rename status;
  `.py`/`.ps1` extension; `docs/`/`.github` prefix or `AGENTS` substring). Any file
  matching none of the three is silently omitted from `bucketCore`, `bucketRenames`, and
  `bucketDocs` alike, and therefore never appears in `collector-output.ts`'s
  "Changed files overview" section (`bucketText("Core logic changes", ...)`,
  `bucketText("Mechanical moves/renames", ...)`, `bucketText("Docs/templates/agents/tooling", ...)`
  at `collector-output.ts:231/233/235`, via the shared `bucketText` helper at
  `summary-helpers.ts:270`).
- The identical defect exists in the Python parity implementation
  (`scripts/dev_tools/pr_context/collector.py:320-330`), confirmed by direct quote in
  research; see "Known Limitation" and "Scope & Non-Goals" above for why this fix does
  not change that file.
- No existing test in `collector-core.test.ts` or `collector-output.test.ts` asserts the
  drop in either direction, so a fail-before regression test is available and required by
  this spec's Test Strategy.

## Proposed Fix

### Design summary (what changes where):
Add a terminal `else` to the bucket-partition loop in `collector-core.ts:316-333` that
pushes any path not matched by the existing three predicates into `bucketDocs`. This
guarantees every non-renamed, changed path reaches exactly one bucket. No change to
`collector-output.ts`, `summary-helpers.ts`, or the bucket-rendering pipeline is
required, since `bucketDocs` is already rendered under the existing
"Docs/templates/agents/tooling" heading.

### Boundaries and invariants to preserve:
- Rename detection (`status.startsWith("R")`) continues to take precedence over all
  other predicates, unchanged.
- The existing `.py`/`.ps1` → `bucketCore` and `docs/`/`.github`/`AGENTS` → `bucketDocs`
  predicates are preserved exactly as-is; only the final `else` is added.
- The empty-bucket case (no changed files, or all changed files are renames) must
  continue to render each section as empty exactly as it does today
  (`collector-output-freshness.test.ts:74-76`).
- `BucketEntry[]` shape and the `[path, stats]` tuple contract are unchanged.

### Dependencies or blocked work:
None. This is a self-contained, single-loop change with no upstream dependency on other
epic children's work.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (production fix)
- `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` (new/updated unit
  tests for the partition loop)
- `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` (new/updated
  test confirming a previously-dropped path now renders in the overview)

#### Functions/classes/CLI commands impacted:
- The bucket-partition loop inside the function containing lines 316-333 of
  `collector-core.ts` (the function that builds `bucketCore`/`bucketRenames`/
  `bucketDocs` from `statusMap`/`perFileStats`, immediately preceding the function's
  `return` statement at line 335).

#### Data flow and validation changes:
No change to how `statusMap`/`perFileStats` are computed (`git diff --name-status` /
`--numstat` via `GitClient.diffRange`, `collector-core.ts:264-280`); only the
downstream partition of already-computed entries changes.

#### Error handling and logging updates:
None required; the fix does not introduce a new failure mode.

#### Rollback/feature-flag considerations (if applicable):
None; this is a pure bug fix with no behavior-flag surface. Rollback is a plain revert
of the one-loop change.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
No change to `BucketEntry`, `statusMap`, or `perFileStats` types. Output change is
purely which bucket array a previously-dropped path lands in (now always `bucketDocs`
if it matches none of the other predicates, instead of no bucket at all).

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
The "Docs/templates/agents/tooling" section will now include additional file categories
(TypeScript source/tests, shell scripts, JSON/YAML config, `.claude/**` non-`.ps1`
content, etc.) that it did not include before. This is the intended fix, not a breaking
change — the section already served as a catch-all for non-core, non-rename changes; it
now actually catches them all. No consumer of the rendered PR-context markdown parses
bucket membership programmatically (the buckets exist only to produce human-readable
markdown sections), so no downstream contract is broken.

## Assumptions, Constraints, Dependencies

- Assumptions: no automated consumer of the rendered "Changed files overview" markdown
  depends on any specific file being absent from a bucket (verified by scope of
  `collector-output.ts`/`summary-helpers.ts`, which only produce markdown text).
- Constraints: TypeScript-only change (per this bug's assigned scope); Python parity
  module explicitly out of scope (see Known Limitation).
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: the rendered PR-context markdown's "Changed files
  overview" section will list more files than before for changesets that include
  non-`.py`/`.ps1`/`docs`/`.github`/`AGENTS` paths. No MCP tool signature or CLI flag
  changes.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: none; purely additive to the rendered section's file coverage.

## Test Strategy

- Regression tests to add or update:
  - `collector-core.test.ts`: a fail-before/pass-after unit test asserting that a
    non-`.py`/`.ps1`/`docs`/`.github`/`AGENTS` path (e.g., a `.claude/skills/example/SKILL.md`
    fixture path and a `src/example.ts` fixture path) is present in `bucketDocs` after
    the fix, and is absent from all three buckets before the fix (documented as the
    fail-before evidence per `evidence-and-timestamp-conventions`).
  - `collector-output.test.ts`: an assertion that the rendered "Changed files overview"
    section text contains the previously-dropped fixture path(s) after the fix.
  - `collector-output-freshness.test.ts`: confirm the existing empty-bucket fixture
    (lines 74-76) still renders all-empty sections when there are no changed files —
    i.e., the terminal `else` does not fabricate entries when `statusMap` is empty.
- Edge cases and negative scenarios: a renamed file still lands only in `bucketRenames`
  (rename precedence unaffected by the new `else`); a `.py`/`.ps1` file still lands only
  in `bucketCore`; a `docs/`/`.github`/`AGENTS` file still lands only in `bucketDocs` via
  the existing predicate (not the new `else` branch) — confirm no double-counting.
- Error handling and logging verification: not applicable (no new error paths).
- Coverage impact and targets for changed lines/modules: line coverage >= 85% and
  branch coverage >= 75% on `collector-core.ts` and `collector-output.ts` per
  `.claude/rules/typescript.md`, with no regression on already-covered lines. The new
  `else` branch itself must be covered by the new tests above (both the added branch and
  the pre-existing "no match" absence prior to the fix, captured as fail-before evidence).
- Toolchain commands to run (format -> lint -> type-check -> test): Prettier, ESLint,
  `tsc`, Jest with coverage, exactly as specified by `.claude/rules/typescript.md`, in
  the canonical loop order. `npm ci` must run in `extensions/drm-copilot` before any
  `npx tsc`/`npx eslint`/`npx prettier`/`npx jest` step (node_modules is gitignored and
  not populated by `git worktree add`).
- Manual validation steps: none beyond the automated toolchain; this is a small,
  test-covered logic change.

## Acceptance Criteria

- [ ] The bucket-partition loop in `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` routes every non-renamed changed path into exactly one bucket (no path is silently dropped).
- [ ] A regression test in `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` demonstrates a previously-dropped path (e.g., under `.claude/skills/**` or a `.ts` source path) now lands in `bucketDocs`, and the test fails against the pre-fix code (fail-before evidence recorded).
- [ ] A regression test in `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` confirms the previously-dropped path now appears in the rendered "Changed files overview" section text.
- [ ] The existing empty-bucket fixture in `collector-output-freshness.test.ts` (lines 74-76) continues to pass unmodified in behavior (all sections still render empty when there are no changed files).
- [ ] Rename precedence, `.py`/`.ps1` core-bucket routing, and `docs/`/`.github`/`AGENTS` docs-bucket routing are all unchanged for paths that already matched those predicates before the fix (no regression, no double-bucketing).
- [ ] `scripts/dev_tools/pr_context/collector.py` is explicitly left unmodified, and this spec's "Known Limitation" section documents the identical defect there plus a recommendation to file a follow-up bug.
- [ ] Full TypeScript toolchain pass completed (Prettier -> ESLint -> `tsc` -> Jest with coverage) with `npm ci` run first in `extensions/drm-copilot`.
- [ ] Line coverage >= 85% and branch coverage >= 75% maintained on changed files, with no production file excluded from coverage measurement.

## Risks & Mitigations

- Risk: routing every unmatched path into `bucketDocs` could make that section very
  large for changesets with many non-core files (e.g., the 92-file consolidation PR that
  originally surfaced this bug would now show ~90 files in one bucket instead of 2).
  Mitigation: this is the correct and intended behavior per the bug's expected outcome
  ("every changed file enumerated"); if reviewers find a single large bucket unwieldy,
  a follow-up could split `bucketDocs` further, but that is a separate enhancement, not
  a blocker for closing the silent-drop defect.
- Risk: the Python parity module remains unfixed, so TypeScript- and Python-generated
  PR context bundles will diverge on this behavior. Mitigation: documented explicitly in
  "Known Limitation" with a recommended follow-up bug.

## Rollout & Follow-up

- Release/rollout steps: standard PR merge through the epic's integration branch; no
  feature flag or staged rollout needed.
- Post-fix monitoring or clean-up tasks: file the Python parity follow-up bug described
  in "Known Limitation" once this fix merges.
- Links: issue #633 (`https://github.com/drmoisan/drm-copilot/issues/633`); research at
  `research/pr-context-bucket-gap.2026-09-06.md`; related divergence backlog entry
  `docs/features/potential/2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md`.
