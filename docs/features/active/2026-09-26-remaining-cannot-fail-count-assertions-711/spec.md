# 2026-09-26-remaining-cannot-fail-count-assertions (Spec)

- **Issue:** #711
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27
- **Status:** Approved
- **Version:** 1.0

## Context

Issue #513 (PR #702) fixed three Pester non-emptiness assertions in
`tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` that could never fail,
because `@($null).Count` is `1` in PowerShell rather than `0`, so `@($x).Count | Should
-BeGreaterThan 0` passes vacuously on a `$null` input. #513's own scope decision (D3) deliberately
excluded five other occurrences of the same textual shape from its fix and recorded them as a
follow-up candidate. This issue (#711) addresses those five sites, one per acceptance criterion:

- AC-1: `mandate_reads` two-statement form, `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
  (issue-cited line 251; current line ~266, shifted by #513's merged edits).
- AC-2: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (issue-cited
  line 457).
- AC-3: `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (issue-cited
  line 155).
- AC-4: `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (issue-cited
  line 333).
- AC-5: `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (issue-cited line 133).

Research (`research/research.2026-09-27T03-00.md`) re-examined each site against its producer and
found that only two of the five (AC-1 and AC-5) are exploitable "cannot-fail" defects under the
current producer contract. The other three (AC-2, AC-3, AC-4) share the identical textual shape
(`@($x).Count | Should -BeGreaterThan 0`) but their guarded values are produced by functions that
always `return , $collection.ToArray()` (the unary-comma "prevent pipeline flattening" idiom),
which guarantees the captured variable is a real, possibly zero-length array and never a raw
`$null`. Because `@($null)` is the only input for which `@()`-wrapping fabricates a count of `1`,
and that input is unreachable through these three producers, the three assertions already fail
correctly on the reachable empty-collection case. See Decision D1 for the adopted treatment of this
asymmetry.

Observed environment(s): any OS; the affected suites are PowerShell/Pester test files with no
OS-specific behavior in the assertions themselves.

Customer impact and severity: test-only defect confined to non-emptiness floor assertions in Pester
test files; no production runtime behavior is affected. Severity is Low, matching #513's own
severity rating for the identical defect class.

First observed date and version(s) impacted: the affected lines predate #513 (PR #702) and were
recorded as a known follow-up at that time (2026-09-25/26); no specific extension or MCP server
version is impacted, as this is test-only code.

## Repro & Evidence

Steps to reproduce (with data/flags/inputs):

1. For each of the five sites, empty or null out the collection the assertion guards (per issue.md
   and research/research.2026-09-27T03-00.md's per-site producer analysis).
2. Observe that the assertion still passes, because `@($x).Count` is computed over a value that,
   for the two exploitable sites (AC-1, AC-5), is a `@($null)`-wrapped scalar with `.Count` `1`
   rather than `0`.

Expected vs actual behavior:

- Expected: each non-emptiness assertion fails when its guarded input is empty or null.
- Actual: at AC-1 (`mandate_reads`, a raw `Hashtable` indexer read with no null-safety) and AC-5
  (`Get-CodexPreToolUseRegistration`, a test-local helper whose `return` statement lacks the
  leading comma used by every other producer examined), the assertion passes vacuously on the
  empty/zero-registration case. At AC-2, AC-3, and AC-4, the assertion already fails correctly on
  the reachable empty-collection case, because each producer's `return , $collection.ToArray()`
  idiom forecloses a raw `$null` capture; this is confirmed in research, not inferred from the
  shared textual shape.

Logs/screenshots/error snippets:

- `research/research.2026-09-27T03-00.md`, sections "AC-1" through "AC-5", quotes the exact current
  assertion text and producer body for each site.

Frequency / determinism (always, intermittent, data-dependent): deterministic. The behavior follows
directly from documented PowerShell array-wrapping and pipeline semantics (`@($null).Count` is `1`;
piping `$null` through `Where-Object` yields zero output elements); it does not depend on timing,
environment, or external state.

## Scope & Non-Goals

- In scope:
  - Same-line replacement of the assertion at each of the five named sites in the four named test
    files (see Files/modules to change).
  - A new in-file `Context`/`It` pair in `codex-pretooluse-integration.Tests.ps1` documenting the
    legacy-vs-filtered discrimination for AC-5 (D3).
  - Fail-before/pass-after evidence artifacts under
    `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/`.
  - Edit-site identification by unique, quoted content anchor rather than line number (D7), because
    none of the concurrent parallel-run siblings (#706-#716) name these four files, but line
    numbers in shared files can still shift for unrelated reasons.
- Out of scope / non-goals:
  - `Get-CodexPreToolUseRegistration`'s missing leading comma (the root cause of AC-5's producer-side
    asymmetry) is not fixed in this change; see D5 and Rollout & Follow-up.
  - The already-sound occurrences identified during the file-scoped sweep are not touched (D4):
    `BlastRadius.TruthTable.Tests.ps1:253` (`$separatorFree.Count`, already pipeline-filtered),
    `BlastRadius.TruthTable.Tests.ps1:326` (the intentional legacy-expression documentation `It`
    added by #513), `BlastRadius.TruthTable.Tests.ps1:56` (`Test-NonVacuousCollection`'s own body),
    and `codex-pretooluse-integration.Tests.ps1:134` (the matcher-uniqueness count, already
    pipeline-filtered before its outer `@()`).
  - `user-story.md` is not created; this is a `full-bug` change with no new user-facing behavior
    (D6, D8).
- Explicitly excluded systems, integrations, or datasets:
  - No production file under `.claude/lib`, `.claude/hooks`, or `scripts` is modified (AC-9).
  - `config/blast-radius.json` and its bundled copy are read-only context; neither is modified.
  - `.claude/lib/discovery-validation/DiscoveryValidation.psm1` (the producer for AC-3 and AC-4) is
    read-only context; it is not modified.

## Root Cause Analysis

Confirmed root cause (per site, from research/research.2026-09-27T03-00.md):

- AC-1: `$script:CommittedConfig['mandate_reads']` is a raw `Hashtable` indexer read. An absent or
  explicitly `null` key returns `$null` with no throw; `$entries = @($null)` has `.Count` `1`, so
  `$entries.Count | Should -BeGreaterThan 0` is vacuous. This is the identical defect class #513
  fixed at three other lines in the same file, textually disguised across two statements, and was
  explicitly left out of #513's scope under its own D3.
- AC-2, AC-3, AC-4: the guarded values (`Get-GuardedPowerShellFile`'s result; the two
  `DiscoveryValidation.psm1` error-collector functions' results) are each produced via `return ,
  $collection.ToArray()`. The leading comma wraps the array in a one-element outer array before
  `return`; PowerShell's implicit `Write-Output` enumerates that outer array and emits exactly one
  pipeline object — the inner array itself, intact, whether zero-length or not. The captured
  variable can therefore never be `$null`, and `@($x).Count | Should -BeGreaterThan 0` already
  discriminates correctly on the reachable empty case.
- AC-5: `Get-CodexPreToolUseRegistration` returns `$registrations.ToArray()` with **no** leading
  comma. For zero matched registrations, `ToArray()` is a zero-length array; enumerating it onto the
  pipeline emits zero objects, and assigning the output of a zero-object pipeline to a variable
  binds that variable to `$null`. `@($script:Registrations).Count` is then `@($null).Count`, which
  is `1`, so the assertion passes vacuously on a zero-registration parse.

Signals/evidence supporting it: direct reading of each producer's source body
(`research/research.2026-09-27T03-00.md`, sections "AC-1" through "AC-5"), cross-checked against
documented PowerShell array-wrapping and pipeline-enumeration semantics.

Affected components/modules (paths): the four test files listed under Files/modules to change.
`Get-DiscoveryProfileValidationError` and `Get-DiscoverySchemaArtifactValidationError`
(`.claude/lib/discovery-validation/DiscoveryValidation.psm1`) and the two test-local helpers
`Get-GuardedPowerShellFile` and `Get-CodexPreToolUseRegistration` (defined within their own test
files) are read-only context: their behavior is analyzed but none of them is modified by this
change (D5).

## Proposed Fix

### Design summary (what changes where):

Replace the vacuous or textually-matching assertion at each of the five named sites, same line,
with a null-safe form. AC-1 reuses the `Test-NonVacuousCollection` helper #513 already added to
`BlastRadius.TruthTable.Tests.ps1`. AC-2 through AC-5 use the same-line inline
`Where-Object`-filtered form already proven sound elsewhere in this codebase (D1, D2). No production
file is modified; no new helper function is introduced in any of the three files that do not already
have one.

### Boundaries and invariants to preserve:

- Each rewritten or hardened assertion must preserve the property it exists to establish: pass when
  the guarded collection has at least one non-null element, fail when it is `$null`, empty, or
  contains only `$null` elements.
- `enforcement-hooks-no-python-invocation.Tests.ps1` (currently 500 lines, per research) must not
  gain any line; its AC-2 edit must be strictly same-line.
- `DiscoveryValidation.Tests.ps1` (currently 476 lines, 23 lines of headroom, per research) must
  keep its AC-3 and AC-4 edits same-line as well, to preserve headroom for unrelated future changes.
- No other assertion, `Context`, or `Describe` block in any of the four files is altered.

### Dependencies or blocked work:

None. `Test-NonVacuousCollection` (the dependency for AC-1) is already merged into
`BlastRadius.TruthTable.Tests.ps1` via #513/PR #702, which this branch's base already contains.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
- Documents and evidence under
  `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/` (this `spec.md` and
  evidence artifacts written during implementation and review).

Read-only context (not write targets): `.claude/lib/discovery-validation/DiscoveryValidation.psm1`
(producer for AC-3/AC-4); `config/blast-radius.json` (data source for AC-1); the test-local helpers
`Get-GuardedPowerShellFile` (in the AC-2 file) and `Get-CodexPreToolUseRegistration` (in the AC-5
file), each read and analyzed but not modified (D5).

#### Functions/classes/CLI commands impacted:

- No new function is introduced. AC-1 calls the existing `Test-NonVacuousCollection` helper. No
  production function, class, or CLI command is impacted.

#### Data flow and validation changes:

- AC-1: the `mandate_reads` floor changes from a raw `.Count` read on a `@()`-wrapped hashtable
  value to a call to `Test-NonVacuousCollection`, which internally filters through `Where-Object {
  $null -ne $_ }` before counting. `$entries` remains assigned as today, since it is consumed again
  by the adjacent whitespace check.
- AC-2 through AC-5: each assertion changes from `@($x).Count | Should -BeGreaterThan 0` to
  `@($x | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`, same line, same variable.
  No change to how any guarded value is produced.

#### Error handling and logging updates:

None. This is a test-assertion correctness fix with no error-handling or logging change.

#### Rollback/feature-flag considerations (if applicable):

Not applicable. Each change is a self-contained, same-line test-assertion edit with no runtime
behavior or feature flag; reverting the commit fully rolls back the change.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

No new public interface. `Test-NonVacuousCollection -Value <expr> | Should -BeTrue` and
`@(<expr> | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0` are the two assertion
forms adopted (D2); both consume the same guarded value type each site already produces and yield a
Pester pass/fail outcome.

#### Required configuration keys and defaults:

None added or changed.

#### Backward-compatibility expectations:

Not applicable. All five edits are internal to their respective test files with no external
consumers.

#### Performance constraints (latency/throughput/memory):

None beyond the existing suites' execution characteristics. The `Where-Object` filter pass operates
on small, already-in-memory collections (at most tens of elements per site).

## Decisions

- **D1 — Treatment of the three non-exploitable sites (AC-2, AC-3, AC-4).** Options: (A) leave the
  assertion code at these three sites unchanged and satisfy each AC via a documented,
  evidence-backed finding (the producer's guaranteed-array `return , $x.ToArray()` contract) with no
  diff to the test files at these lines; (B) apply the same-line inline `Where-Object`-filtered form
  at all three sites anyway, for defense-in-depth and literal-wording compliance. **Adopted: B.**
  The line-count cost is zero (same-line edit), the change closes the textual defect class uniformly
  across all five named sites rather than leaving three as a documented exception a future reader
  must re-derive, and it satisfies each AC's literal "fails when ... null" wording directly rather
  than by inspection alone.
- **D2 — Replacement form per site.** AC-1 (`mandate_reads` in
  `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`): replace
  `$entries.Count | Should -BeGreaterThan 0` with `Test-NonVacuousCollection -Value $entries |
  Should -BeTrue`, reusing the helper #513 added. AC-2
  (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`), AC-3 and AC-4
  (`tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`), and AC-5
  (`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`): same-line inline filtered
  form `@(<x> | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`.
  `enforcement-hooks-no-python-invocation.Tests.ps1` is exactly 500 lines today (per research), so
  its edit must be a same-line, net-zero-line replacement; the 500-line cap
  (`.claude/rules/general-code-change.md`) is an invariant for all four files in this change, not
  only the one file already at the ceiling.
- **D3 — Fail-before evidence.** AC-1: reuse the existing in-file "Non-vacuity floor helper" negative
  controls (already asserting `Test-NonVacuousCollection -Value $null | Should -BeFalse` and
  documenting the legacy `@($null).Count -gt 0` defect) plus a before/after content-token check
  (`Select-String` for the exact literal replaced). AC-5: add one small in-file `Context`/`It` pair
  in `codex-pretooluse-integration.Tests.ps1` proving the old form `@($null).Count -gt 0` is `$true`
  while the filtered form `@($null | Where-Object { $null -ne $_ }).Count -gt 0` is `$false`
  (mirroring #513's legacy-expression documentation `It`). AC-2/AC-3/AC-4: an inline `pwsh
  -NoProfile -Command` expression (no script file, no temporary file) evaluating the old and new
  forms against `$null` and `@()`, with its output recorded as an evidence artifact under
  `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/regression-testing/`.
  Options considered: new `It` blocks in every file (rejected for AC-2 due to the 500-line cap); a
  scratch script file (rejected — an inline command needs no file); inline `pwsh -NoProfile
  -Command` (adopted).
- **D4 — Additional occurrences found in the sweep.** `BlastRadius.TruthTable.Tests.ps1:253`
  (`$separatorFree.Count`) and its legacy-expression documentation `It` at `:326`, and
  `codex-pretooluse-integration.Tests.ps1`'s matcher-uniqueness count, are already sound (each is
  computed over a `Where-Object`-filtered pipeline result, or is the intentional legacy-defect
  documentation case). **No change.**
- **D5 — Producer-side helper left unchanged.** `Get-CodexPreToolUseRegistration`'s missing leading
  comma (the root cause of AC-5's producer-side asymmetry) is not fixed in this change; only the
  assertion line is edited (D2, "Assertion-side fix"). This follows #513's own D3 scoping
  precedent — touch only the assertion lines named in scope, not the surrounding helper/producer
  code — and keeps this "Low"-severity fix's diff to the assertions themselves. Recorded as a
  follow-up candidate in Rollout & Follow-up.
- **D6 — Work mode.** Used as instructed by the operator: `full-bug`, even though the raw GitHub
  issue #711 body carries `- Work Mode: minor-audit`. `issue.md` as promoted into this feature
  folder persists `- Work Mode: full-bug`, and `full-bug` is the mode this `spec.md` is authored
  under (acceptance criteria sourced from `spec.md` only; no `user-story.md`).
- **D7 — Edit-site location method.** Every edit site in this change is located by a unique, quoted
  content anchor (the exact current assertion text, or that text plus the enclosing `It` name where
  the text alone is not unique — e.g., AC-3 and AC-4 share the literal
  `@($errors).Count | Should -BeGreaterThan 0` and are disambiguated by the preceding
  `Get-DiscoveryProfileValidationError` vs `Get-DiscoverySchemaArtifactValidationError` call), never
  by line number. None of the concurrent parallel-run siblings #706-#716 name these four files in
  their issue bodies, but #707 (codex-gates-4-5-lack-epic-scope) and #709
  (gate-suites-read-unmocked-local-epic-state) work in adjacent codex-hook and gate-suite test areas
  and could plausibly shift line numbers nearby without colliding on content; anchor-based location
  keeps this change correct independent of merge order relative to those siblings.
- **D8 — No `user-story.md`.** Not created, consistent with the `full-bug` default (D6): the
  requirement is fully expressed in this `spec.md`.
- **D9 — AC-6's numeric baseline is not hard-coded.** Options: (A) state the specific per-file
  baseline `It`-block counts recorded in research (23 / 27 / 40 / 5 for the blast-radius,
  enforcement-hooks, discovery-validation, and codex-pretooluse suites respectively) as the literal
  AC-6 baseline; (B) phrase AC-6 as a relative regression check against a freshly captured pre-edit
  baseline, without citing those specific totals as the spec-level baseline of record. **Adopted:
  B.** The research's own "Numeric Derivation Evidence" section for this claim bases its cross-check
  member-set conclusion for three of the four files on "identical match counts" alone, without an
  independently enumerated cross-check line set for those three files, and its own Recommendations
  text states explicitly that "a future `spec.md` should re-derive its own baseline counts at
  plan-authoring time ... rather than citing the counts recorded here as of record." Citing an
  incompletely-derived count as a spec-level acceptance criterion would not meet this repository's
  numeric-evidence bar for a checked-off AC. AC-6 therefore requires each execution to capture its
  own pre-edit `It`-block count per file and compare it to the post-edit count, rather than asserting
  the specific totals recorded in research.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access): `config/blast-radius.json` continues to be readable by
  `BlastRadius.TruthTable.Tests.ps1`'s existing `BeforeAll`; the discovery-validation module's four
  and five return points continue to use the `return , $errors.ToArray()` idiom for AC-3/AC-4's
  "not vacuous" classification to remain accurate; the test-local helpers in the AC-2 and AC-5 files
  are not modified by any concurrent sibling change.
- Constraints (budget, performance, compatibility): all four files must remain at or under the
  500-line limit in `.claude/rules/general-code-change.md`; `enforcement-hooks-no-python-invocation.Tests.ps1`
  has zero headroom today, and `DiscoveryValidation.Tests.ps1` has 23 lines of headroom, so their
  edits must be same-line.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact

- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none.

## Test Strategy

- Regression tests to add or update: no new `It` blocks are required for AC-1 through AC-4 (D3); one
  new `Context`/`It` pair is added to `codex-pretooluse-integration.Tests.ps1` for AC-5's fail-before
  evidence (D3), which has ample headroom (203 lines, per research) for the addition.
- Unit tests (Pester) for the fixed behavior and boundaries: for each of the five sites, verify the
  rewritten or hardened assertion fails for a `$null` input and for an empty-array `@()` input, and
  continues to pass for the suite's existing real (non-empty) data.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): `$null` input
  and empty-array (`@()`) input at every site; for AC-1, an absent or explicitly `null`
  `mandate_reads` key in the committed config; for AC-5, a zero-registration parse of
  `codex-pretooluse-integration.Tests.ps1`'s configuration fixture.
- Error handling and logging verification: not applicable; no error handling or logging is
  introduced by this change.
- Coverage impact and targets for changed lines/modules: none required. All four changed files are
  test code and are excluded from production coverage measurement per
  `.claude/rules/general-unit-test.md`; no production module's coverage is affected by this change.
- Toolchain commands to run (format -> lint -> type-check -> test): `Invoke-PoshQCFormat` and
  `Invoke-PoshQCAnalyze` (PSScriptAnalyzer) for each changed file; type-checking is not applicable to
  PowerShell per `.claude/rules/powershell.md`; architecture-boundary and contract/schema stages are
  not applicable to test-only text edits; `Invoke-Pester` for the test stage, run directly against
  each changed file and against its containing directory (`tests/scripts/claude-lib/blast-radius`,
  `tests/scripts/claude-runtime`, `tests/scripts/claude-lib/discovery-validation`,
  `tests/scripts/codex-hooks`).
- Manual validation steps (if required): run `Invoke-Pester` directly from `pwsh` rather than relying
  solely on `mcp__drm-copilot__run_poshqc_test`, which has been observed in this repository to return
  no usable output and to read installed-extension settings rather than freshly edited workspace
  files (matching #513's own plan and this repository's memory record on the same tool).
- CI constraints: this repository's CI runs on Linux with a shallow (depth-1) checkout. No test
  added or modified by this change may depend on `origin/main` or any other remote-ref history, on
  gitignored state such as `artifacts/orchestration/*.json`, on temporary files (creating or reading
  temp files in tests is prohibited by `.claude/rules/general-unit-test.md`), or on a Windows-only
  path or drive root. The inline `pwsh -NoProfile -Command` evidence for AC-2/AC-3/AC-4 (D3) is
  evidence-gathering tooling run during implementation, not a committed test, and likewise must not
  depend on any of the above.

## Acceptance Criteria

- [ ] AC-1: The `mandate_reads` non-emptiness assertion in
      `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` (current text
      `$entries.Count | Should -BeGreaterThan 0`) is replaced, same line, with
      `Test-NonVacuousCollection -Value $entries | Should -BeTrue`, and the resulting assertion
      fails for `$entries = @($null)` (the empty/absent-key case) and for `$entries = @()`, while
      continuing to pass for the suite's existing non-empty `mandate_reads` data.
- [ ] AC-2: The non-emptiness assertion in
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (issue-cited
      line 457; current text `@($files).Count | Should -BeGreaterThan 0`) is replaced, same line,
      with `@($files | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`, which
      evaluates to a failing count of `0` for both `$files = $null` and `$files = @()`.
- [ ] AC-3: The non-emptiness assertion in
      `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` guarding
      `Get-DiscoveryProfileValidationError`'s result (issue-cited line 155; current text
      `@($errors).Count | Should -BeGreaterThan 0`) is replaced, same line, with
      `@($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`, which evaluates
      to a failing count of `0` for both `$errors = $null` and `$errors = @()`.
- [ ] AC-4: The non-emptiness assertion in the same file guarding
      `Get-DiscoverySchemaArtifactValidationError`'s result (issue-cited line 333; current text
      `@($errors).Count | Should -BeGreaterThan 0`) is replaced, same line, with
      `@($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`, which evaluates
      to a failing count of `0` for both `$errors = $null` and `$errors = @()`.
- [ ] AC-5: The non-emptiness assertion in
      `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (issue-cited line 133;
      current text `@($script:Registrations).Count | Should -BeGreaterThan 0`) is replaced, same
      line, with
      `@($script:Registrations | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`,
      which evaluates to a failing count of `0` for both `$script:Registrations = $null` and
      `$script:Registrations = @()`; `Get-CodexPreToolUseRegistration` itself is not modified (D5).
- [ ] AC-6: `Invoke-Pester` reports zero failed tests for each of the four affected suites
      (`tests/scripts/claude-lib/blast-radius`, `tests/scripts/claude-runtime`,
      `tests/scripts/claude-lib/discovery-validation`, `tests/scripts/codex-hooks`) after the
      change, and each file's post-edit `It`-block count is not less than its own
      immediately-pre-edit `It`-block count, captured via `Invoke-Pester -PassThru` (or an
      equivalent `It`-declaration count) run directly before and after the edit for each file. Per
      D9, the specific per-file totals recorded in `research/research.2026-09-27T03-00.md` (23 / 27
      / 40 / 5) are contextual only and are not adopted as the spec-level baseline of record; each
      execution captures its own pre-edit baseline.
- [ ] AC-7: Each of the four files named under Files/modules to change is at or under 500 lines
      after all edits. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
      is documented in research as exactly 500 lines pre-edit with zero headroom, so its AC-2 edit
      must be strictly same-line with no net line delta; `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`
      has 23 lines of headroom pre-edit, and its AC-3/AC-4 edits must likewise be same-line with no
      net line delta.
- [ ] AC-8: Fail-before evidence exists for each site per D3: AC-1's existing in-file "Non-vacuity
      floor helper" negative controls plus a before/after content-token check; AC-5's new in-file
      `Context`/`It` pair proving `@($null).Count -gt 0` is `$true` while
      `@($null | Where-Object { $null -ne $_ }).Count -gt 0` is `$false`; and, for AC-2/AC-3/AC-4, an
      inline `pwsh -NoProfile -Command` expression (no script file, no temporary file) evaluating the
      old and new forms against `$null` and `@()`, with its output recorded as an evidence artifact
      under `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/regression-testing/`.
- [ ] AC-9: No production file under `.claude/lib`, `.claude/hooks`, or `scripts` is modified by this
      change; a scope check (for example `git diff --stat` against the pre-change base commit) shows
      changes limited to the four named test files plus documents and evidence under
      `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/`.

## Risks & Mitigations

- Technical or operational risks:
  - A same-line edit at the two headroom-constrained files (`enforcement-hooks-no-python-invocation.Tests.ps1`,
    `DiscoveryValidation.Tests.ps1`) could inadvertently wrap or split if the replacement expression
    is longer than the line-length conventions PSScriptAnalyzer/the formatter enforce.
    - Mitigation: the inline filtered form (`@($x | Where-Object { $null -ne $_ }).Count | Should
      -BeGreaterThan 0`) is already used verbatim elsewhere in this codebase
      (`BlastRadius.TruthTable.Tests.ps1:253`, `codex-pretooluse-integration.Tests.ps1:134`), so its
      formatting is already accepted by the toolchain; run `Invoke-PoshQCFormat` after each edit to
      confirm.
  - The AC-2/AC-3/AC-4 "not vacuous" classification depends on the producers' `return ,
    $collection.ToArray()` contract continuing to hold; if a future change to
    `Get-GuardedPowerShellFile`, `Get-DiscoveryProfileValidationError`, or
    `Get-DiscoverySchemaArtifactValidationError` drops the leading comma, the hardened assertions
    (adopted under D1) still discriminate correctly, so this risk is already mitigated by the D1
    decision to harden uniformly rather than leave these three sites unchanged.
  - Editing by content anchor rather than line number (D7) could still fail to find its anchor if a
    concurrent sibling PR edits the exact same line first.
    - Mitigation: none of #706-#716's issue bodies name these four files; if a collision is
      discovered during implementation, re-resolve the anchor against the post-merge file content
      before editing.
- Mitigations and rollbacks: each of the five edits is a self-contained, same-line change to one
  assertion in one test file; reverting the commit fully rolls back the change with no other
  coordination required.

## Rollout & Follow-up

- Release/rollout steps: none beyond the standard PR merge; this is a test-only change with no
  runtime behavior.
- Post-fix monitoring or clean-up tasks: file or link a dedicated follow-up candidate to add the
  leading comma to `Get-CodexPreToolUseRegistration`'s `return $registrations.ToArray()` statement
  (D5), matching the `return , $collection.ToArray()` idiom used by every other producer examined in
  research, as a root-cause-level (not merely assertion-side) closure of AC-5's defect. This was not
  adopted for this change because it is a change to test-support helper code beyond the assertion
  lines named in scope, consistent with #513's own D3 scoping precedent.
- Links: issue #711; research: `research/research.2026-09-27T03-00.md`; precedent: issue #513, PR
  #702, `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/spec.md`.
