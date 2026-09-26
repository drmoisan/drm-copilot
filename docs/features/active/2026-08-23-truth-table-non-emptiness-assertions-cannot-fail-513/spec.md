# 2026-08-23-truth-table-non-emptiness-assertions-cannot-fail (Spec)

- **Issue:** #513
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25
- **Status:** Draft
- **Version:** 0.2

## Context
Three non-emptiness assertions in `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
cannot fail, because `@($null).Count` is `1` in PowerShell rather than `0`. Each reads
`@($x).Count | Should -BeGreaterThan 0`, so the assertion passes even when `$x` is null. The three
affected lines are:

- Line 72 (`Context 'Module map'`): `@($script:CommittedConfig['modules'].Keys).Count | Should -BeGreaterThan 0`
- Line 171 (`Context 'Shared surfaces'`): `@($script:CommittedConfig['shared_surfaces']).Count | Should -BeGreaterThan 0`
- Line 172 (same `Context`): `@($script:CommittedConfig['shared_surface_globs']).Count | Should -BeGreaterThan 0`

Each of these lines is intended as a non-vacuity floor: it exists to guarantee that a later
assertion iterating over the same collection cannot silently pass by iterating zero elements. On a
`$null` or missing-key input, `@($null)` wraps the scalar `$null` in a one-element array, so
`.Count` is `1` and `Should -BeGreaterThan 0` is satisfied even though the guarded collection does
not actually contain any usable elements. The floor therefore does not establish the property it
exists to establish.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (PowerShell / Pester)
- Command/flags used: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-lib/blast-radius`
- Data source or fixture: `config/blast-radius.json` and its bundled copy under `extensions/drm-copilot/resources/claude-customizations/config/`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low because the affected floors are currently compensated. The four-state floor added by issue #500's
cycle 3 covers the same ground, and the fifth case added by cycle 4 uses the sound form. The defect
is that the three older floors would not catch a regression on their own.

## Repro & Evidence
Steps to Reproduce:
1. In `pwsh`, evaluate `@($null).Count`. It returns `1`, not `0`.
2. Read `BlastRadius.TruthTable.Tests.ps1` at lines 72, 171, and 172. Each asserts
   `@($x).Count | Should -BeGreaterThan 0` as a non-vacuity floor.
3. Substitute a null value for the collection each line guards. The assertion still passes.

Expected:
A non-vacuity floor should fail when the collection it guards is null or empty, so that a later
assertion over that collection cannot silently iterate zero elements and report success.

Actual:
The floor passes on a null input. `@($null)` wraps the null in a single-element array, so `.Count`
is `1` and `Should -BeGreaterThan 0` is satisfied. The floor therefore does not establish the
property it exists to establish.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `pwsh -c '@($null).Count'` prints `1`.

## Scope & Non-Goals

- In scope:
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` only: rewrite the
    three floors at lines 72, 171, and 172; add a file-local helper function; add a negative-control
    `Context`/`It` block that exercises the helper directly.
- Out of scope / non-goals:
  - No production PowerShell file is changed. The defect is confined to test code.
  - Line 251 of this same file (`mandate_reads` check) is the identical defect expressed as a
    two-statement form (`$entries = @($script:CommittedConfig['mandate_reads'])` followed by
    `$entries.Count | Should -BeGreaterThan 0`). It is not rewritten in this fix; see D3 below.
  - Four other occurrences of the same defect class in other test files are not rewritten in this
    fix and are recorded as a follow-up candidate (see D3 and Rollout & Follow-up):
    `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:457`,
    `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1:155`,
    `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1:333`,
    `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:133`.
- Explicitly excluded systems, integrations, or datasets:
  - `config/blast-radius.json` and its bundled copy are not modified.
  - `.claude/lib/blast-radius/*.psm1` production modules are not modified.

## Root Cause Analysis
Pre-existing. The three lines are present at merge-base `bee15c06` and were not touched by the
issue #500 branch. Found during the issue #500 cycle-4 exit re-audit and recorded there as finding
I3; see
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md`.

The correct form is already in the same test tree, at line 226-238 (`$separatorFree = @($script:BundledConfig['shared_surfaces'] | Where-Object { -not $_.Contains('/') })` followed by
`$separatorFree.Count | Should -BeGreaterThan 0`). Piping `$null` into a `Where-Object` pipeline
stage produces zero output elements (a PowerShell-specific pipeline behavior distinct from
`@($null)`, which wraps a scalar `$null` as a one-element array). Wrapping the already-enumerated
pipeline output in `@()` is therefore safe: it is enumerating a real (possibly zero-length)
sequence, not re-wrapping a raw scalar. That is the pattern the three defective lines should adopt.

This is an instance of the recurring class tracked in `.claude/rules/plan-acceptance-gates.md`: a
verification step that reads as a gate but cannot fail with respect to the property it asserts.

## Proposed Fix

### Design summary (what changes where):
Rewrite the three floors to route through a new file-local helper function,
`Test-NonVacuousCollection`, defined in the file's existing top-level `BeforeAll` block (the same
block that already defines `Get-ReasonSignature`). The helper filters its input through
`Where-Object { $null -ne $_ }` before counting, which is the null-safe idiom already used
elsewhere in this file (line 226-238). Each of the three floors becomes a call to the helper
followed by `Should -BeTrue`, and a new `Context` block adds negative-control `It` cases that
exercise the helper directly against in-memory values.

### Design Decisions

The following decisions were adopted from the researcher's recommendation in
`docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/research/research.2026-09-25T22-10.md`
without operator review. Each is labeled accordingly.

**D1 — Work mode.** Adopted (researcher recommendation; operator review not obtained in
preparation mode): use `full-bug` rather than `minor-audit`, because the preparation route in use
for this feature requires a `prd-feature` spec as its authoritative acceptance-criteria source, and
`minor-audit` sources acceptance criteria from `issue.md` instead. `full-bug` was adopted over the
legacy `full` designation because the change is a defect fix with no new user-facing behavior, so a
`user-story.md` is not warranted.
- Options considered: `minor-audit` (rejected — the preparation route needs a `spec.md` AC
  source); `full-bug` (adopted); legacy `full` (rejected — normalizes to `full-feature`, which
  would additionally require a `user-story.md` that this bug fix does not justify).

**D2 — Replacement form.** Adopted (researcher recommendation; operator review not obtained in
preparation mode): add a file-local helper function

```powershell
function Test-NonVacuousCollection {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [object] $Value
    )
    return @($Value | Where-Object { $null -ne $_ }).Count -gt 0
}
```

in the file's existing top-level `BeforeAll` block, alongside `Get-ReasonSignature`, and rewrite
the three floors to:

```powershell
Test-NonVacuousCollection -Value <expr> | Should -BeTrue
```

- Options considered:
  - Inline `Where-Object` form repeated at each of the three call sites (rejected — duplicates the
    same filter-and-count expression three times with no single point of test coverage for the
    predicate itself).
  - `$x | Should -Not -BeNullOrEmpty` (rejected — Pester's built-in null/empty handling would also
    discriminate correctly, but it introduces a second idiom for the same property alongside the
    file's existing `Where-Object`-filtered pattern at line 226-238, rather than reusing one
    idiom consistently).
  - File-local helper function (adopted), because extracting the predicate into a named function
    makes it independently testable: a negative-control `It` block can assert the helper's return
    value directly against `$null`, `@()`, `@($null, $null)`, and non-empty inputs, which
    demonstrates that the floor can now fail. Neither of the other two options offers a unit
    directly callable from a negative control.

**D3 — Scope.** Adopted (researcher recommendation; operator review not obtained in preparation
mode): fix only lines 72, 171, and 172 in this change.
- Options considered:
  - Fix only the three named lines (adopted), consistent with the issue's own proposed-fix section
    and the general-code-change policy's guidance to avoid broad refactors across unrelated
    scripts.
  - Also fix line 251 (`mandate_reads`) in the same file, which is the identical defect expressed
    as a two-statement form (rejected for this change — not named in the issue's scope; recorded
    as a follow-up candidate).
  - Repository-wide sweep of the four other genuinely defective occurrences identified by pattern
    search (`enforcement-hooks-no-python-invocation.Tests.ps1:457`,
    `DiscoveryValidation.Tests.ps1:155` and `:333`, `codex-pretooluse-integration.Tests.ps1:133`)
    (rejected for this change — these live in unrelated test files and are better handled as a
    single, deliberately scoped follow-up issue for the whole defect class, per
    `.claude/rules/plan-acceptance-gates.md`).

### Boundaries and invariants to preserve:
- The rewritten floors must preserve the property they exist to establish: pass when the guarded
  collection has at least one non-null element, fail when it is `$null`, empty, or contains only
  `$null` elements.
- The file's other passing assertions (the already-sound floor at line 226-238, the `mandate_reads`
  checks at line 247-252, and the `Disjoint work items` context) must be unaffected.
- No change to `$script:CommittedConfig`, `$script:BundledConfig`, or `$script:ConfigPath`
  construction in the top-level `BeforeAll`.

### Dependencies or blocked work:
- None. This is a self-contained test-file edit with no dependency on other in-flight work.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` only.

#### Functions/classes/CLI commands impacted:
- New file-local function `Test-NonVacuousCollection`, defined in the top-level `BeforeAll` block.
- No production functions, classes, or CLI commands are impacted.

#### Data flow and validation changes:
- The three floors change from directly counting a `@()`-wrapped raw config value to counting a
  `Where-Object`-filtered, null-stripped version of the same value via the new helper. No change
  to what data is read from `config/blast-radius.json`.

#### Error handling and logging updates:
- None. This is a test-assertion correctness fix, not an error-handling or logging change.

#### Rollback/feature-flag considerations (if applicable):
- Not applicable. The change is test-only and has no runtime behavior or feature flag.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Test-NonVacuousCollection` accepts one parameter, `-Value` (type `[object]`, `[AllowNull()]`),
  and returns a `[bool]`.

#### Required configuration keys and defaults:
- None added or changed.

#### Backward-compatibility expectations:
- Not applicable. The helper and the rewritten floors are internal to a single test file with no
  external consumers.

#### Performance constraints (latency/throughput/memory):
- None beyond the existing test suite's execution characteristics. The helper adds a
  `Where-Object` pipeline pass over small, already-in-memory collections (at most tens of
  elements), which is not measurably different from the existing `@()`-wrapping cost.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): `config/blast-radius.json` continues to declare
  non-empty `modules`, `shared_surfaces`, and `shared_surface_globs` values, so the rewritten
  floors continue to pass against real committed data; the negative-control cases exercise the
  helper directly with literal in-memory values rather than depending on config content.
- Constraints (budget, performance, compatibility): the file must remain under the 500-line
  production/test file limit in `.claude/rules/general-code-change.md`.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: rewrite the three floors to the `@($x | Where-Object { ... })` form used
      by the cycle-4 case, then perturb each guarded collection to null and confirm each floor now
      fails. A floor that does not fail under that perturbation has not been fixed.
- [x] Integration scenario to retest: full `tests/scripts/claude-lib/blast-radius` directory run;
      the total should be unchanged aside from the intentional new negative-control cases.
- [x] Manual verification notes: confirm in `pwsh` that the replacement expression returns `0` for a
      null input before relying on it.

- Regression tests to add or update: a new `Context` block of negative-control `It` cases that
  call `Test-NonVacuousCollection` directly against `$null`, `@()`, `@($null, $null)`, and `@('a')`
  (and, if included, a non-empty hashtable's `.Keys`), all in-memory with no filesystem or network
  dependency.
- Unit tests (Pester) for the fixed behavior and boundaries: the rewritten floors plus the
  negative-control `Context` described above; no `pytest` is applicable (this is a PowerShell/
  Pester test file).
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): `$null` input,
  empty array input, array containing only `$null` elements, and (documented, not required) the
  `ConvertFrom-Json` single-element-array-to-scalar quirk, which is a genuine one-element case and
  not a false positive.
- Error handling and logging verification: not applicable; no error handling or logging is
  introduced.
- Coverage impact and targets for changed lines/modules: none required. `BlastRadius.TruthTable.Tests.ps1`
  is test code and is excluded from production coverage measurement per the general-unit-test
  policy; the production module it exercises (`.claude/lib/blast-radius/BlastRadius.psm1`) remains
  in `CodeCoverage.Path` and is unaffected by this change.
- Toolchain commands to run (format -> lint -> type-check -> test): `Invoke-PoshQCFormat`,
  `Invoke-PoshQCAnalyze` (PSScriptAnalyzer); type-checking is not applicable to PowerShell per
  `.claude/rules/powershell.md`; architecture-boundary and contract/schema stages are not
  applicable to a test-only text edit; `Invoke-Pester` against
  `tests/scripts/claude-lib/blast-radius` for the test stage.
- Manual validation steps (if required): run `Invoke-Pester` directly from `pwsh` rather than
  relying solely on the `mcp__drm-copilot__run_poshqc_test` MCP tool, which has been observed in
  this repository to return no usable output and to read installed-extension settings rather than
  freshly edited workspace files.

## Acceptance Criteria
- [ ] AC-1: None of the three original raw-count tokens
      (`@($script:CommittedConfig['modules'].Keys).Count`,
      `@($script:CommittedConfig['shared_surfaces']).Count`,
      `@($script:CommittedConfig['shared_surface_globs']).Count`) remain anywhere in
      `BlastRadius.TruthTable.Tests.ps1`; each of the three floors instead calls
      `Test-NonVacuousCollection -Value <expr> | Should -BeTrue`.
- [ ] AC-2: `Test-NonVacuousCollection` is defined once, in the file's existing top-level
      `BeforeAll` block, with an `[AllowNull()][object] $Value` parameter, and its body evaluates
      `@($Value | Where-Object { $null -ne $_ }).Count -gt 0`.
- [ ] AC-3: A new `Context` block of in-memory negative-control `It` cases asserts that
      `Test-NonVacuousCollection` returns `$false` for `-Value $null`, `-Value @()`, and
      `-Value @($null, $null)`, and returns `$true` for `-Value @('a')` and for a non-empty
      hashtable's `.Keys` property. None of these cases read from disk, the network, or any
      environment variable.
- [ ] AC-4 (optional, retained if included): a negative-control `It` case demonstrates that the
      legacy expression `@($null).Count -gt 0` evaluates to `$true`, documenting the defect the
      helper closes.
- [ ] AC-5: Running `Invoke-Pester -Path tests/scripts/claude-lib/blast-radius -Output Detailed`
      directly in `pwsh` (not through the MCP test runner) reports zero failed tests, and the
      file's `It` block count after the edit equals its `It` block count immediately before the
      edit plus exactly the number of newly added negative-control `It` cases (verified by
      comparing `grep -c '^\s*It '''` output taken before and after the edit).
- [ ] AC-6: `Invoke-PoshQCFormat` and `Invoke-PoshQCAnalyze` (PSScriptAnalyzer) report zero new
      findings on `BlastRadius.TruthTable.Tests.ps1` relative to its pre-edit baseline, and the
      file's total line count remains under 500 lines after the edit.
- [ ] AC-7: No test added or modified by this change creates or reads a temporary file, references
      a git remote ref (for example `origin/main`), reads gitignored state, or depends on a
      Windows-only path or drive root.
- [ ] AC-8: `git diff --stat` against the pre-change base commit shows changes limited to
      `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`; no production file
      is modified.

## Risks & Mitigations
- Technical or operational risks:
  - The negative-control helper could drift from the logic actually used by the three floors if
    the floors ever stop calling it directly.
    - Mitigation: the floors call `Test-NonVacuousCollection` directly rather than duplicating its
      body, so any change to the helper's behavior is automatically reflected at all three call
      sites and exercised by the negative controls.
  - PSScriptAnalyzer could flag the new helper function (for example, an unapproved verb or
    missing comment-based help).
    - Mitigation: the helper uses the approved verb `Test-` and mirrors the size and style of the
      existing `Get-ReasonSignature` helper in the same `BeforeAll` block.
  - The file could approach the 500-line limit after the additions.
    - Mitigation: per the research record, the projected total after the three rewritten floors,
      the new helper, and the new negative-control block remains comfortably under 500 lines;
      AC-6 verifies this directly.
- Mitigations and rollbacks: the change is a self-contained edit to one test file; reverting the
  commit fully rolls back the change with no other coordination required.

## Rollout & Follow-up
- Release/rollout steps: none beyond the standard PR merge; this is a test-only change with no
  runtime behavior.
- Post-fix monitoring or clean-up tasks: file a dedicated follow-up issue to sweep the remaining
  occurrences of the same defect class identified during research but left out of this change's
  scope (D3): `BlastRadius.TruthTable.Tests.ps1:251` (`mandate_reads`, two-statement form),
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:457`,
  `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1:155` and `:333`,
  and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:133`.
- Links: issue #513;
  research: `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/research/research.2026-09-25T22-10.md`;
  prior finding: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md`.
