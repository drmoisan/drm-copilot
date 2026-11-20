# Policy Compliance Audit: enforcement-hook-trigger-matches-whole-command-text (#545)

**Audit Date:** 2026-09-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
**Base Branch:** `epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
**Head Branch:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` @ `77cb427df4e219dc2603fad791b8669eaf96629b`
**Work Mode:** `full-bug` (marker at `issue.md:12`) → AC source is `spec.md` only

**Code Under Test (full branch diff, 168 files, +9928 / −149):**

- PowerShell production, canonical: 11 files under `.claude/hooks/` and 7 under `.codex/hooks/` (9 in-scope hooks + 2 new shared parser files)
- PowerShell production, bundle mirrors: 18 files under `extensions/drm-copilot/resources/**`
- PowerShell tests: 27 files under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`
- PowerShell data: 2 × `pester.runsettings.psd1`
- JSON: 2 × `pack-manifests/core.json`
- Markdown: 101 files (spec, plan, evidence, two potential entries, one additive annotation to the #539 spec)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 63 files (18 canonical production, 18 bundle mirrors, 27 test) | 4326 collected | ✅ 4315 pass, 2 fail (both ambient, see §8), 9 skipped | per-file baselines recorded in `evidence/baseline/baseline-selfhosted-per-file-coverage.2026-09-07T10-57.md`; repo-wide aggregate baseline not recorded | repo-wide 95.4618% lines; 18/18 changed canonical files ≥ 85% | 4 new production files: 96.7742% – 100.0000% lines |
| JSON | 2 files | N/A | ✅ pack-manifest assertions pass (2 passed, 16 passed) | N/A (config files) | N/A (config files) | N/A |

Python, TypeScript, C#, and Bash have **zero changed files** in the branch diff (verified by
`git diff --name-only <base>..HEAD | sed 's/.*\.//' | sort | uniq -c` → `2 json`, `101 md`,
`63 ps1`, `2 psd1`). Their coverage verdicts are therefore legitimately `N/A - out of scope`.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed `.ts` files)
- TypeScript post-change coverage artifact: `N/A - out of scope`
- Python baseline / post-change coverage artifact: `N/A - out of scope` (zero changed `.py` files)
- C# baseline / post-change coverage artifact: `N/A - out of scope` (zero changed `.cs` files)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-selfhosted-per-file-coverage.2026-09-07T10-57.md`
- PowerShell post-change coverage artifact: `evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md`, sourced from `artifacts/pester/powershell-coverage.xml` emitted by CI run `34145103168`
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-09-07T17-00.md`, and §1.2.1 below
- Local corroborating artifact inspected by this audit: `artifacts/pester/powershell-coverage.xml` (partial run, 13:20 local)

**Verdict-rule compliance:** numeric baseline and post-change coverage figures are present for the
only in-scope coverage language (PowerShell), with per-file new-code figures. No required artifact
is missing.

---

## Rejected Scope Narrowing

**None detected.** The delegating prompt explicitly stated "Scope determination is your
responsibility. Determine it from the branch diff." No caller instruction attempted to narrow the
audit to a plan, task, phase, or file subset, and no caller instruction marked any language's
coverage as out of scope, informational only, or not applicable. The audit was performed against
the full branch diff `6dff80ed4596bec088d548b23013e6077e32c484..77cb427df4e219dc2603fad791b8669eaf96629b`.

Two adjudications and four findings were referred to this reviewer by the orchestrator. Referral for
adjudication is not scope narrowing; each was evaluated independently on the evidence and the
conclusions below differ from the orchestrator's stated view in one case (AC-09).

## Evidence Location Compliance

**PASS.** Zero violations.

- `git diff --name-only <base>..HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` → no matches (exit 1).
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` → **EXIT 0**, no output.
- All 100 evidence artifacts produced by this feature are written under
  `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`
  with kinds `baseline/`, `qa-gates/`, `regression-testing/`, `issue-updates/`, and `other/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

## Policy Rule: modified-workflow-needs-green-run

**Does not fire.** The branch diff modifies no path matching `.github/workflows/**`,
`scripts/benchmarks/**`, or `.github/actions/**`. Verified by inspecting the full changed-file list.

Note for completeness: `.github/workflows/_poshqc.yml` was *dispatched* (runs `34139262327` and
`34145103168`) as the coverage measurement route, but it was not *modified*. The rule keys on
modification, not invocation, so no Blocking finding is emitted.

---

## Executive Summary

The change replaces raw-whole-command-text trigger matching in nine PowerShell enforcement hooks
with a shared, pure, dot-sourced two-file command-line parser (`hook-command-scanner.ps1` +
`hook-command-invocation.ps1`), delivered across four copy locations for the five dual-runtime hooks
and two Claude locations for the four Claude-only hooks. The parser masks quoted spans and heredoc
bodies, segments on shell operators, keeps wrapper-led and live-substitution segments on raw text,
and adds a structural `git`/`gh`/`npx` invocation classifier that absorbs modeled global options.
Four classes of genuine bypass (global-option relocation, subshell/group openers, command
substitution, adjacency-defeating options) newly deny, and quoted-prose over-matches newly allow.

Toolchain, coverage, parity, registration, file-size, evidence-location, and test-location
obligations are all met and independently corroborated where local tooling permitted. Test design is
strong: 27 test files, all in the mirrored `tests/` tree, no temporary files, no wall-clock or sleep
dependencies, regression-first fail-before/pass-after pairs recorded for both directions.

Two substantive gaps prevent an unqualified PASS:

1. **A previously-existing denial in `validate-bash.ps1` is weakened and unpinned** (Major). Leg 1 of
   `Get-BlockedPatternMatch` compares the six denylist literals against `$segment.Tokens` rather than
   against `$segment.ScanText`, so the wrapper carve-out that spec D3 rows 2 and 4 guarantee never
   reaches it. `bash -c "rm -rf /tmp/x"`, `sh -c 'rm -rf /'`, and
   `pwsh -Command "Remove-Item -Recurse -Force x"` denied before this change and allow after it. No
   test in any of the four `validate-bash` suites pins a wrapper form. This is not enumerated in the
   D4 accepted-residual list.
2. **AC-07 is internally unsatisfiable as written** (specification defect, not implementation
   defect). Four of its five literal groups are verified byte-unchanged; the fifth clause is directly
   contradicted by the same spec's D12 call-site rewrite table and by AC-31.

**Policy documents evaluated:**
- ✅ `CLAUDE.md` — standing instructions and policy compliance order
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change` + `python-unit-test` — zero changed `.py` files
- ✅ `.claude/rules/powershell.md` (and `powershell-code-change` / `powershell-unit-test`)
- N/A `typescript-code-change` + `typescript-unit-test` — zero changed `.ts` files
- N/A `csharp-code-change` + `csharp-unit-test` — zero changed `.cs` files
- N/A Bash: shfmt + shellcheck + bats — zero changed `.sh` / `.bats` files
- ✅ JSON: pack-manifest completeness assertions

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were added by the branch. The changed-file list contains no
  throwaway script; every added `.ps1` is either a production hook file or a `tests/`-tree suite.
- ✅ No temporary files are created by any changed test
  (`New-TemporaryFile`, `$env:TEMP`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `Out-File`,
  `Set-Content` all absent from the 27 changed test files).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** — Tests run in any order | ✅ PASS | Every new suite dot-sources the hook under test in `BeforeAll` and drives pure functions with literal command strings. No suite writes shared state. The one order/ambient-coupled case in the repository is a *pre-existing, unmodified* suite (`enforce-pr-author-skill.Tests.ps1` line 142), analysed in §8. |
| **Isolation** — Each test targets single behavior | ✅ PASS | Suites are split by concern: `hook-command-scanner.Tests.ps1` (segmentation), `hook-command-invocation.Tests.ps1` (structural matching), `*.TriggerScoping.Tests.ps1` (per-hook scope filter), `*-decision-surface.Tests.ps1` (per-hook decision), `hook-command-parser.AcceptanceCases.Tests.ps1` (AT-1…AT-7 in one suite so a fail-open regression surfaces in one place, per AC-27). |
| **Fast Execution** — Tests complete quickly | ✅ PASS | The parser is pure string logic with no I/O. Local partial run: 1520 test cases executed in a single MCP PoshQC invocation. Full CI run `34145103168` completed and was watched to a zero exit status. No test declares a timeout or retry. |
| **Determinism** — Consistent results | ✅ PASS | No `Start-Sleep`, no `[Threading.Thread]::Sleep`, no wall-clock read in any changed test. The two `Start-Sleep` string occurrences in `legacy-codex-hook-contracts.Tests.ps1` lines 172 and 182 are *fixture text* asserting the PowerShell purity checker rejects such a patch, not executed sleeps. Grep evidence in Appendix B. |
| **Readability & Maintainability** — Clear structure | ✅ PASS | Test names state the asserted decision and the form under test, e.g. `denies D4 row 14b - a directory-relocating option before the subcommand`, `AT-8 git push --force-with-lease origin HEAD allows`. Spec rows are named in the test name, so traceability is readable from the test list alone. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** per-file line coverage for 10 of the 18 changed canonical production files, recorded pre-change in `evidence/baseline/baseline-selfhosted-per-file-coverage.2026-09-07T10-57.md`. Eight files carry the literal `absent from CodeCoverage.Path at baseline` (4 new parser files + 4 Codex hooks that were not in the coverage allow-list before this change). **Note:** the repository-wide aggregate baseline was not captured; the gate applied is per-file, so this does not block. |
| **No Coverage Regression** | ✅ PASS | 10 numeric deltas: 8 positive, 2 negative. The two negative deltas (`enforce-epic-worktree-removal-gate.ps1` 95.6989 → 94.9495; `enforce-parallel-worktree-removal-gate.ps1` 94.1176 → 93.2432) are ratio decreases accompanied by **covered-count increases** (89→94 and 64→69), caused by each file gaining executable lines at the call site. Both remain well above 85%. **Documented limitation:** the artifact records counts, not line identities, so it does not affirmatively prove that no individual changed line lost coverage. |
| **New Code Coverage ≥ 85% (uniform tier rule)** | ✅ PASS | Four new production files: `.claude/hooks/hook-command-scanner.ps1` 97.7778% (176/4), `.claude/hooks/hook-command-invocation.ps1` 98.3871% (122/2), `.codex/hooks/hook-command-scanner.ps1` 100.0000% (180/0), `.codex/hooks/hook-command-invocation.ps1` 96.7742% (120/4). All four exceed both the 85% policy threshold and the 90% new-file trigger in the review workflow. |
| **Repo-wide ≥ 85%** | ✅ PASS | 95.4618% line coverage, CI run `34145103168`. |
| **Branch coverage ≥ 75%** | N/A — exempt | PowerShell is a coverage language subject to the line threshold, but Pester emits no `BRANCH` counter in any output format. Independently verified: parsing `artifacts/pester/powershell-coverage.xml` for top-level `counter` elements yields `LINE` only; no `BRANCH` element exists at any level. Per `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`, no branch threshold applies and an absent figure is **not** a FAIL. |
| **Comprehensive Coverage** | ✅ PASS | Each of the six D12 public functions plus the three constant accessors carries a named Pester case per AC-30. `hook-command-scanner.Tests.ps1` (347 lines) covers all seven heredoc rules of D2 Piece 1; `hook-command-invocation.Tests.ps1` (330 lines) covers the six structural steps of D2 Piece 3. |
| **Positive Flows** — Valid inputs | ✅ PASS | Allow-side pins: `git push --force-with-lease origin HEAD` (AT-8), `git log --grep add` non-classification, `gh --repo drmoisan/drm-copilot issue list`, quoted `--body-file` inside a JSON receipt value, promotion tool names as receipt *values*. |
| **Negative Flows** — Invalid inputs | ✅ PASS | Deny-side pins: `git -C ../wt push --force origin HEAD` (AT-9), `git -C /repo/main worktree remove …` against an unauthorizing epic checkpoint (AT-1), `gh --repo … issue create` / `issue new` (AT-5), the seven D3 wrapper deny pins on the preimplementation-gate side. |
| **Edge Cases** — Boundary conditions | ✅ PASS | Bare `--`, bare `-`, `--flag=value` inline form, `--body` vs `--body-file` token distinction, unterminated heredoc body, `<<<` here-string, non-literal heredoc delimiter, multiple pending heredocs on one physical line. |
| **Error Handling** — Error paths | ✅ PASS | `$null`-on-missing-value contract for `Get-CommandLineFlagValue` pinned by AC-25 paired negatives (`gh pr merge --merge` → `$null`); empty-array-never-`$null` contract for `Get-CommandLineOperand`; empty/whitespace/`$null` `CommandText` returns an empty segment array. |
| **Concurrency** | N/A | The parser is pure and stateless; the hooks are single-shot processes. No concurrency surface. |
| **State Transitions** | ✅ PASS | The scanner is a documented state machine (single-quote span, double-quote span, backslash escape, heredoc pending list). Its transitions are exercised by named heredoc and quoting cases. |

### 1.2.1 Per-Language Coverage Comparison

- **PowerShell:** Baseline: per-file, 10 numeric rows (84.5679% – 96.4286% lines); aggregate baseline not captured → Post-change: repo-wide **95.4618%** lines, 18/18 changed canonical files ≥ 85% (lowest 88.3117%). Change: 8 positive per-file deltas, 2 negative (both ratio-only, covered counts rose), 8 rows newly entering the denominator. New/changed-code coverage: **96.7742% – 100.0000%** on the four new files. Disposition: **PASS**. Evidence: `evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md`, `evidence/qa-gates/coverage-delta.2026-09-07T17-00.md`, corroborated locally against `artifacts/pester/powershell-coverage.xml`.
- **Python:** `N/A - out of scope` (zero changed `.py` files in the branch diff).
- **TypeScript:** `N/A - out of scope` (zero changed `.ts` files in the branch diff).
- **C#:** `N/A - out of scope` (zero changed `.cs` files in the branch diff).
- **Bash:** `N/A - out of scope` (zero changed `.sh` / `.bats` files in the branch diff).

**Independent corroboration of the PowerShell figures.** The coverage evidence was measured at commit
`5903d0c7`, which is the pre-rebase equivalent of `HEAD~1`. This audit verified that the measurement
is valid for the branch head: `git diff --name-only 5903d0c7 77cb427d -- '.claude/hooks/*.ps1'
'.codex/hooks/*.ps1' 'extensions/drm-copilot/resources/**/*.ps1' 'tests/scripts/claude-hooks/**'
'tests/scripts/codex-hooks/**' '**/pester.runsettings.psd1' '**/pack-manifests/core.json'` returns
**no output** — every in-scope file is byte-identical between the measured commit and the head. The
only difference between `HEAD~1` and `HEAD` is 15 Markdown files. Separately, nine Claude-side
per-file percentages were re-derived independently from the local
`artifacts/pester/powershell-coverage.xml` by package-qualified XML parsing and match the recorded CI
figures to four decimal places (96.6102, 94.9495, 88.3117, 92.7536, 93.2432, 95.5224, 92.3077,
93.3333, 94.3182).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use `Should -Be`, `Should -BeNullOrEmpty`, `Should -Match` against single values. The one observed failure produced an actionable message: `Expected: 'allow' / But was: 'deny'` with file and line. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Consistent shape across the new suites: literal command string (Arrange), single function call (Act), single `Should` (Assert). Data-driven rows use `-ForEach` tables. |
| **Document Intent** | ✅ PASS | Every new suite opens with a comment block naming the spec section or acceptance case it discharges (e.g. `validate-bash.TriggerScoping.Tests.ps1` lines 12–16 name AT-8, AT-9, AT-10). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The parser touches no disk, process, network, clock, or environment. The hook suites mock `Get-*CheckpointContent` / `Get-PrContextArtifactExistence` rather than reading real files. No changed test contacts a network or database. |
| **Use Mocks/Stubs** | ✅ PASS | `Mock -CommandName Get-PrAuthorCheckpointContent`, `Invoke-OrchestratorStatePreflight`, `Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, `Get-PrContextSummaryLastWriteUtc` are used at the I/O boundary. |
| **Environment Stability** | ⚠️ PARTIAL | **No changed test creates a temporary file** (verified by grep — PASS). However, two *pre-existing, unmodified* suites read gitignored ambient state and fail locally as a result: `enforce-pr-author-skill.Tests.ps1` line 142 (reads the real `artifacts/orchestration/orchestrator-state.json`) and `codex-pretooluse-integration.Tests.ps1` (reads the gitignored epic checkpoint). Both are green on a clean CI checkout. Analysed in §8; not caused by this change, and out of the nine-hook scope D11 defines. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document, together with `code-review.2026-09-07T17-44.md`, `feature-audit.2026-09-07T17-44.md`, and `remediation-inputs.2026-09-07T17-44.md`, constitutes the required pre-PR review. Outstanding items are enumerated in §8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Policy files read in the mandated order | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-09-07T10-57.md` and `phase0-feature-documents-read.2026-09-07T10-57.md` record the reading order for Phase 0. |
| Baseline captured before edits | ✅ PASS | Twelve baseline artifacts under `evidence/baseline/` timestamped `2026-09-07T10-57`, covering git state, file inventory, environment facts, format, analyze, test, per-file coverage, Codex contract suite, Python contracts, targeted Pester, and coverage-list length. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | A single left-to-right scan producing one record type, plus a structural matcher expressed as four ordered fail-closed rules. No recursion into nested command lines, no shell re-implementation. Deliberate simplicity is documented in D4.1 as the reason the design refuses to recursively scan wrapper arguments. |
| **Reusability** | ⚠️ PARTIAL | The core win is real: eleven independent raw-text regexes across nine hooks and two runtimes now delegate to one parser, and the previously *divergent* `Get-EpicWorktreeRemovalCommandPath` / `Get-ParallelWorktreeRemovalCommandPath` implementations were reconciled. However, they were reconciled to **two byte-identical copy-pasted function bodies in two files** rather than to one shared implementation. The docstring at `enforce-parallel-worktree-removal-gate.ps1` acknowledges this: "This body is identical to `Get-EpicWorktreeRemovalCommandPath`". See code review finding CR-3. |
| **Extensibility** | ✅ PASS | All public functions are advanced functions with named, typed, `[Parameter(Mandatory)]` parameters and `[OutputType]`. Constant tables are exposed through getters (`Get-CommandLineWrapperName`, `Get-CommandLineTransparentWrapperName`, `Get-CommandLineGlobalOption`) so membership is pinned against a public surface and extension is a one-line, test-pinned change. `Get-CommandLineGlobalOption` returns an empty-arrays record for an unmodeled command word, so adding a new command word is additive. |
| **Separation of concerns** | ✅ PASS | Pure string logic (`hook-command-scanner.ps1`, `hook-command-invocation.ps1`) is fully separated from I/O. Neither parser file reads stdin, touches disk, starts a process, reads a clock, or references `$env:CLAUDE_*` — verified by grep. The hooks retain all checkpoint I/O. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size ≤ 500 lines** | ✅ PASS | All 63 changed `.ps1` files verified ≤ 500. Largest: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle mirror at **exactly 500**; then `.claude` copies at 495; `legacy-codex-hook-contracts.Tests.ps1` at 494; the four `hook-command-invocation.ps1` copies at 483; the four `hook-command-scanner.ps1` copies at 450. See CR-5 for the zero-headroom note. |
| **Two-file parser split** | ✅ PASS | D11.2 required the parser ship as two files from the start. Delivered as `hook-command-scanner.ps1` (450) and `hook-command-invocation.ps1` (483), both `.ps1` (not `.psm1`), both function-definition-only, dot-sourced with `. (Join-Path $PSScriptRoot '<name>')`. No `Export-ModuleMember`. |
| **Eight parser files across four locations** | ✅ PASS | All eight verified present. Claude and Codex canonical copies of both parser files are byte-identical to each other (`cmp -s` → identical), and each canonical copy is byte-identical to its bundle mirror. |
| **No file added under `.claude/lib/`** | ✅ PASS | `git diff --name-only <base>..HEAD -- '.claude/lib/**'` → no matches. |
| **Test file location mirrors production** | ✅ PASS | All 27 changed test files live under `tests/scripts/claude-hooks/` or `tests/scripts/codex-hooks/`, mirroring `.claude/hooks/` and `.codex/hooks/`. Zero colocation in a production source tree. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names, approved verbs | ✅ PASS | `Read-CommandLineSegment`, `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, `Test-CommandLineMention`, `ConvertTo-CommandLineToken`, `Resolve-CommandLineInvocation`, `Skip-CommandLineOption`. All use approved PowerShell verbs and singular nouns. |
| Comment-based help on public functions | ✅ PASS | Every function in both parser files carries `.SYNOPSIS`, `.DESCRIPTION`, and `.OUTPUTS`; the six D12 public functions additionally carry `.PARAMETER` blocks. |
| Comments explain *why*, not *what* | ✅ PASS | Notable examples: the `$script:CommandLineStandaloneFlagNames` comment explains that omitting `--force` would break AT-7; the `enforce-parallel-abandon-gate.ps1` dot-source placement comment explains it sits *below* the token assignments so lines 41–42 keep their line numbers; the `Get-BlockedPatternMatch` help explains why leg 1 must complete before leg 2. |

### 2.5 After Making Changes — Toolchain Execution

The seven-stage loop, as it applies to a PowerShell-only change:

| Stage | Applicable | Status | Evidence |
|---|---|---|---|
| 1. Formatting | Yes | ✅ PASS | `evidence/qa-gates/final-poshqc-format.2026-09-07T17-03.md` — `ok: true`; `git status --porcelain` captured before and after, set-difference **0**, so the formatter rewrote nothing. |
| 2. Linting | Yes | ✅ PASS | `evidence/qa-gates/final-poshqc-analyze.2026-09-07T17-05.md` — `ok: true`, **0** diagnostics repository-wide, at or below the `[P0-T6]` baseline of 0. |
| 3. Type checking | No | N/A | PowerShell has no type-check stage (`.claude/rules/powershell.md`). |
| 4. Architecture-boundary tests | Partial | ✅ PASS | The Codex contract suite enforces the architectural boundaries that apply here: shared-module registration, byte identity across the canonical/bundle pair, parse validity, and the 500-line cap. 43 tests, **0 failures** (`evidence/qa-gates/final-codex-contract-suite.2026-09-07T17-18.md`). |
| 5. Unit tests | Yes | ✅ PASS with documented carve-out | `evidence/qa-gates/final-selfhosted-test.2026-09-07T17-11.md` — 4315 passed / 2 failed / 9 skipped. Both failures are members of the `[P0-T7]` baseline failing set and are ambient-state, not change-caused. See §8. |
| 6. Contract / schema compatibility | Yes | ✅ PASS | `evidence/qa-gates/final-python-contracts.2026-09-07T17-14.md` (three commands, all exit 0) and `final-pack-manifest-completeness.2026-09-07T17-27.md` (2 passed, 16 passed). D12 is the consumed parser contract; its signatures are pinned by a named case per function. |
| 7. Integration tests | Yes | ✅ PASS | `evidence/qa-gates/manual-replay.2026-09-07T16-05.md` records the five 2026-08-24 over-match instances each proceeding and `git -C <dir> add .` denying against a not-ready checkpoint. |

**Single-pass claim: accepted.** Format 17-03 → analyze 17-05 → test 17-11, strictly monotonic, no
restart. The supporting observation is a formatter set-difference of 0 plus a working tree in which
every outstanding path at 17-28 is Markdown — zero `.ps1`, `.psm1`, or `.psd1` changed after the
format stage ran.

**TOOLCHAIN_SUBSTITUTION (material; recorded, not waived).** `pwsh`, `powershell`, and `cmd` are not
invocable in this session — this reviewer independently confirmed the runtime guard refuses `pwsh`
outright. Consequently:

- Format, lint, and test ran through `mcp__drm-copilot__run_poshqc_*`, with per-suite results read
  from `artifacts/pester/pester-junit.xml`.
- **Coverage did not use the MCP runner.** This reviewer verified the stated reason is correct: the
  local `artifacts/pester/powershell-coverage.xml` produced by the MCP route contains **zero**
  occurrences of `hook-command-scanner`, confirming that the MCP runner resolves its runsettings from
  the installed VS Code extension and cannot see the eight `CodeCoverage.Path` entries this change
  added. The coverage route was therefore a `workflow_dispatch` of `.github/workflows/_poshqc.yml`,
  which imports the same self-hosted `scripts/powershell/PoshQC/PoshQC.psm1` and resolves the same
  checked-out `pester.runsettings.psd1`. This is a **route** substitution, not a measurement
  substitution, and it was the correct choice.
- This reviewer could not re-run any PowerShell stage. Verification of those stages is by artifact
  inspection plus independent re-derivation of the coverage XML, the JUnit XML, byte-parity by `cmp`,
  line counts by `wc -l`, and diff inspection.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Change documented in the feature folder | ✅ PASS | `spec.md` (119 KB, D1–D12), `plan.2026-08-25T08-13.md` (124 KB), 100 evidence artifacts. |
| Deferred work filed, not buried | ✅ PASS | Two potential entries created: `docs/features/potential/2026-09-07-codex-preimplementation-gate-modes-module-unregistered.md` and `…-parallel-abandon-equals-joined-disposition-runtime-confirmation.md`. Both cite this spec and D11.6. Epic amendment EA-3's merge-gate hole is recorded in the spec and surfaced to review rather than silently dropped. |
| Public API compatibility | ✅ PASS | `Get-EpicWorktreeRemovalCommandPath`, `Get-ParallelWorktreeRemovalCommandPath`, and `Get-EpicMergeGateCommandPrNumber` retain their names, signatures, and `$null`-on-miss contracts, so existing pinning cases are unaffected. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

**N/A — out of scope.** Zero changed `.py` files in the branch diff. AC-19 requires this explicitly
("No Python is introduced anywhere in the change"), and it is satisfied:
`git diff --name-only <base>..HEAD | grep '\.py$'` → no matches;
`evidence/qa-gates/no-python-scan.2026-09-07T15-58.md` records the corresponding hook-scan pass.

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| `Invoke-Formatter` clean | ✅ PASS | `final-poshqc-format.2026-09-07T17-03.md`, set-difference 0. |
| PSScriptAnalyzer 0 findings | ✅ PASS | `final-poshqc-analyze.2026-09-07T17-05.md`, 0 diagnostics repository-wide. |
| Advanced functions with `[CmdletBinding()]` | ✅ PASS | All 15 functions across the two parser files, and every added hook function, declare `[CmdletBinding()]` and `[OutputType(...)]`. |
| Parameter validation | ✅ PASS | `[ValidateNotNullOrEmpty()]` on `$SubcommandPath`, `$FlagName`, `$CommandWord` where a value is required; `[AllowEmptyString()]` / `[AllowNull()]` / `[AllowEmptyCollection()]` used deliberately where the empty case is a defined input. |
| Approved verbs | ✅ PASS | `Read-`, `Test-`, `Get-`, `ConvertTo-`, `Resolve-`, `Skip-` — all approved. |
| No `Write-Host` in library code | ✅ PASS | Neither parser file emits output; both return values only. |
| Fail-fast / explicit error behavior | ✅ PASS | The four fail-closed rules of D12 are implemented as explicit early returns in `Resolve-CommandLineInvocation`, each with a comment naming the rule it discharges. There is no broad `catch`. |
| No dead code | ⚠️ PARTIAL | `$script:CdChainedReadCommandPattern` at `.claude/hooks/validate-bash.ps1:204` is now **write-only**: verified referenced nowhere in either hook copy and pinned by no test. It is retained solely to keep AC-07's byte-unchanged obligation visibly discharged. See CR-4. |

### Section 3C: Bash Script Policy Compliance

**N/A — out of scope.** Zero changed `.sh` files.

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Both pack manifests updated | ✅ PASS | `claude-customizations/pack-manifests/core.json` gains `.claude/hooks/hook-command-invocation.ps1` and `.claude/hooks/hook-command-scanner.ps1`; `codex-and-agents-customizations/pack-manifests/core.json` gains the `.codex/hooks/` pair. Entries inserted in sorted position. |
| Manifest completeness asserted | ✅ PASS | `final-pack-manifest-completeness.2026-09-07T17-27.md`: both suites 0 failed (2 passed, 16 passed). |
| Registration set complete (AC-14) | ✅ PASS | **Fourteen entries across five registry files**, verified by diff inspection: 2 pack manifests × 2 helpers = 4; `$script:SharedModuleNames` × 2 helpers = 2; 2 PoshQC coverage lists × 2 helpers × 2 runtime paths = 8. The two `pester.runsettings.psd1` hunks are **textually identical**, as `test_poshqc_bundled_parity.py` requires (that test passes locally). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

**N/A — out of scope for production code.** Four pre-existing Python contract modules were *executed*
as gate checks (`test_push_down_claude_resource_contracts.py`, `test_poshqc_bundled_parity.py`,
`test_parallel_abandon_token_seam.py`, and the pack-manifest suites) but none was modified.

This reviewer executed them: `poetry run python -m pytest … -q --no-cov` → **21 passed, 1 failed**.
The single failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which
asserts every repo `.claude` file exists in the bundle and trips on
`.claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json` — an untracked
file in a **gitignored** directory (`git check-ignore -v` → `.gitignore:68:.claude/state/`). This is
the known issue #510 defect, unrelated to #545, and green on a clean CI checkout. Crucially, the
assertions that AC-16 depends on — `test_bundled_claude_payload_contains_required_runtime_files` and
`test_poshqc_bundled_module_files_match_repo_root_sources` — both **pass**.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5 `Describe`/`Context`/`It` structure | ✅ PASS | All 27 changed test files use the v5 shape with `BeforeAll` dot-sourcing. |
| Naming convention `<name>.Tests.ps1` | ✅ PASS | All 27 files end in `.Tests.ps1`. |
| Location mirrors production tree | ✅ PASS | `tests/scripts/claude-hooks/**`, `tests/scripts/codex-hooks/**`. |
| Mocks used at the I/O boundary | ✅ PASS | Checkpoint readers and artifact-existence probes are mocked. |
| **No temporary files** | ✅ PASS | Grep for `New-TemporaryFile`, `$env:TEMP`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `Out-File`, `Set-Content` across all 27 changed test files → **no matches**. |
| Regression-first (fail-before recorded) | ✅ PASS | Seven `[expect-fail]` artifacts under `evidence/regression-testing/`, each paired with a pass-after run; `pass-after-both-directions.2026-09-07T17-22.md` records **zero unpaired**. |
| Coverage entries added for new production files | ✅ PASS | Four new `CodeCoverage.Path` entries per settings file, plus four previously-unregistered Codex hooks. No entry was removed or altered. |
| **Coverage Exclusion Policy** | ✅ PASS | No `exclude` entry matching a production source path was added. `CodeCoverage.Path` is an explicit allow-list; the change **adds** eight files to the denominator and removes none. The 18 bundle mirrors sit outside the denominator because the list holds zero entries under `extensions/drm-copilot/resources/` — a pre-existing repository convention, unchanged here, with parity enforced by content comparison (Claude) and SHA-256 (Codex) instead. |

---

## 5. Test Coverage Detail

### `hook-command-scanner.ps1` — 4 public/internal functions, 97.7778% – 100% lines

- `Read-CommandLineSegment` — segmentation, quoting, escaping, heredoc state machine. Cases cover `<<`, `<<-` with leading tabs, quoted delimiter, multiple pending heredocs on one physical line, unterminated body masking to end of text, `<<<` here-string, non-literal delimiter forcing a raw scan (AC-04).
- `Get-CommandLineWrapperName` — exact 14-member set membership pinned (AC-05).
- `ConvertTo-CommandLineToken` — quote-stripping, whitespace-in-quote non-splitting.
- `Get-CommandLineSegmentCommandWord` — `VAR=value` prefix skipping.
- `ConvertTo-CommandLineSegmentRecord` — the three ordered `ScanText` clauses.
- Uncovered: 4 lines (Claude copy), 0 (Codex copy).

### `hook-command-invocation.ps1` — 9 functions, 96.7742% – 98.3871% lines

- `Test-CommandLineInvocation` / `Resolve-CommandLineInvocation` — the six numbered steps of D2 Piece 3 and the four fail-closed rules of D12. Named cases: `git -C <dir> add` classifies; `git --git-dir=<x> commit` classifies; `git --work-tree=<x> add` classifies; unmodeled dash-leading token classifies; `git log --grep add` does **not** classify (AC-06).
- `Get-CommandLineOperand` — matched-segment-only operand extraction (the direct #591 fix), `--` separator, zero-argument flag handling.
- `Get-CommandLineFlagValue` — separated and equals forms, `$null` on absent / valueless / dash-led-value.
- `Test-CommandLineFlag` — presence-only; `--body` does not match `--body-file` (AC-31).
- `Test-CommandLineMention`, `Test-CommandLineRawContainment`, `Skip-CommandLineOption`, `Get-CommandLineTransparentWrapperName`, `Get-CommandLineGlobalOption`.
- Uncovered: 2 lines (Claude copy), 4 (Codex copy).

### Nine in-scope hooks — 88.3117% – 100% lines

Each carries a `TriggerScoping` or `decision-surface` suite asserting the post-fix decision for its
own trigger. Lowest figure: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at
88.3117% (136 covered / 18 missed), 3.31 points above threshold.

---

## 6. Test Execution Metrics

| Metric | Value | Source |
|---|---|---|
| Total tests collected (full run) | 4326 | `final-selfhosted-test.2026-09-07T17-11.md`, CI run `34145103168` |
| Passed | 4315 | same |
| Failed | 2 (both ambient, §8) | same |
| Skipped | 9 | same |
| Errors | 0 | same |
| Repo-wide line coverage | 95.4618% | same |
| Local partial run (this reviewer's corroboration) | 1520 cases, 1 failure, 0 errors | `artifacts/pester/pester-junit.xml`, parsed directly |
| Codex contract suite | 43 tests, 0 failures | `final-codex-contract-suite.2026-09-07T17-18.md` |
| Acceptance-case suite (AT-1…AT-7 + 4 paired negatives) | 11 tests, 0 failures | `pass-after-acceptance-cases.2026-09-07T17-20.md` |
| Python contract modules (this reviewer's run) | 22 collected, 21 passed, 1 failed (issue #510, ambient) | `poetry run python -m pytest … -q --no-cov` |

---

## 7. Code Quality Checks

| Check | Status | Evidence |
|---|---|---|
| Formatting | ✅ PASS | Set-difference 0 |
| Linting | ✅ PASS | 0 PSScriptAnalyzer diagnostics |
| Type checking | N/A | No PowerShell type-check stage |
| File size ≤ 500 lines | ✅ PASS | Max 500, verified by `wc -l` over all 63 changed `.ps1` files |
| Canonical ↔ bundle byte parity | ✅ PASS | `cmp -s` over all 18 pairs → all identical |
| Claude ↔ Codex parser byte identity | ✅ PASS | `cmp -s` on both parser files → identical |
| Evidence locations | ✅ PASS | `validate_evidence_locations.py --root .` exit 0 |
| Policy files untouched | ✅ PASS | Zero changed paths under `.claude/rules/`, `.github/instructions/`, or `.github/copilot-instructions.md` |
| Hook scope confined to the nine + parser | ✅ PASS | Exactly 11 canonical `.claude/hooks/` and 7 canonical `.codex/hooks/` files changed; no hook outside the D11 list of nine |
| Secrets | ✅ PASS | No credential, token, or `.env` introduced |
| Unsafe command construction | ✅ PASS | The parser starts no process and constructs no command; it only classifies text |
| **Deny-side behavioral preservation** | ❌ **FAIL** | `validate-bash.ps1` leg 1 lost the wrapper carve-out. See §8 finding G-1 and code review CR-1. |

---

## 8. Gaps and Exceptions

### Identified Gaps

**G-1 — `validate-bash.ps1` denylist weakened for wrapper-with-quoted-argument forms. Severity: Major. Remediation required.**

`Get-BlockedPatternMatch` leg 1 compares each of the six byte-unchanged denylist literals against
`$segment.Tokens`, never against `$segment.ScanText`. Because `ConvertTo-CommandLineToken` collapses a
quoted span into a **single token**, the multi-token literals cannot form a contiguous run inside a
wrapper's quoted argument. The wrapper carve-out — which exists precisely so that
`bash -c '<nested command line>'` keeps scanning raw text — is bypassed, because leg 1 never consults
the field the carve-out populates.

Traced explicitly for `bash -c "rm -rf /tmp/x"`:
- Scanner yields one segment; `IsWrapperLed` is `$true`; `ScanText` = `RawText` (carve-out applied correctly).
- `Tokens` = `['bash', '-c', 'rm -rf /tmp/x']`.
- Pattern tokens for `'rm -rf'` = `['rm', '-rf']`. Candidate runs are `['bash','-c']` and `['-c','rm -rf /tmp/x']`. Neither matches.
- Leg 2 (`Get-BlockedStructuralGitMatch`) tests only `git push` / `git reset`, so it does not apply.
- Result: `$null` → **allow**.

Before this change the same input returned `'rm -rf'` from `$Command.Contains('rm -rf')` → **deny**.
The same reasoning applies to `sh -c 'rm -rf /'` and to
`pwsh -Command "Remove-Item -Recurse -Force x"`.

Both runtimes are affected identically (`.claude/hooks/validate-bash.ps1:146-151` and
`.codex/hooks/validate-bash.ps1:146-151` both read `@($segment.Tokens)`). **No test in any of the
four `validate-bash` suites contains a `bash -c`, `sh -c`, `pwsh -Command`, or `pwsh -NoProfile`
fixture** — grep across `validate-bash.Tests.ps1`, `validate-bash.TriggerScoping.Tests.ps1`,
`validate-bash-decision-surface.Tests.ps1`, and `validate-bash-trigger-scoping.Tests.ps1` returns no
matches. The gap is therefore unpinned as well as unfixed.

This contradicts spec D3 rows 2 and 4, which state that `bash -c` / `sh -c` and `pwsh -Command` are
`neutral` because "wrapper carve-out scans raw". It is not covered by D4's accepted residuals: D4.1
concerns *over*-match inside wrappers, D4.2 concerns obfuscated respellings, and D4.3 concerns
*unlisted* wrappers — whereas `bash`, `sh`, and `pwsh` are all listed members of the carve-out set.
The root cause is a seam between D3 (written before validate-bash was in scope) and D11.3 (which
specified `Tokens` for validate-bash without re-deriving the D3 guarantee).

Mitigating context, recorded so the severity is not overstated: spec D4.2 documents the hook family
as "a policy deterrent, not a security boundary", and obfuscated respellings such as `git${IFS}add`
were already ungated before and after. The finding is nonetheless a measurable loss of an existing
denial through a spelling that is ordinary rather than adversarial.

**G-2 — AC-07 is internally unsatisfiable as written. Severity: Minor (specification defect). Remediation required (documentation only).**

Adjudicated on the merits; this reviewer's conclusion is stated in the feature audit. Four of the five
literal groups AC-07 names are verified byte-unchanged against **this audit's** merge-base
`6dff80ed` (the evidence artifact used base `288ca214`, so the check was re-performed):
`git diff <base>..HEAD -- '*.ps1'` contains **no `-` line** removing any of the six `validate-bash`
denylist literals, the four promotion forbidden-token literals, the five preimplementation trigger
patterns, `$ghApiIssuesPostPattern`, `$script:CdChainedReadCommandPattern`, or the two abandon token
constants. Only *usages* were removed.

The fifth clause — "the pr-author hook's `gh pr create` / `gh pr edit` expressions are likewise
byte-unchanged" — is falsified: `'(?i)\bgh\s+pr\s+create\b'` and `'(?i)\bgh\s+pr\s+edit\b'` are
deleted at diff lines 397/398 and 3430/3431 (`enforce-pr-author-skill-helpers.ps1`, both Claude
copies) and `'(?i)\bgh\s+pr\s+create\b'` at 441/3474
(`enforce-pr-author-skill.epic-base-branch.ps1`, both Claude copies).

The conflict is internal to `spec.md`, not between spec and implementation. D12's "Call-site rewrites
for the D11 hooks" table directs `enforce-pr-author-skill-helpers.ps1 L170–171` →
`Test-CommandLineInvocation`, which takes no pattern operand. That same table marks four *other*
rows explicitly "**byte-unchanged**" and pointedly does **not** so mark the pr-author rows — the
asymmetry is deliberate drafting. AC-31 independently requires `Test-EpicBaseBranchOverride` to
evaluate through `Test-CommandLineInvocation`, which necessarily removes the third literal. The
implementation is conformant to D12 and AC-31; AC-07's fifth clause is a residual sentence superseded
by two later, more specific parts of the same document.

**G-3 — AC-22 is blocked on an artifact that does not yet exist. Severity: Minor. Not remediable at this stage.**

The supersession text exists at `evidence/issue-updates/issue-591.2026-09-07T15-41.md` with
`PostedAs: unknown`, and no separate follow-up candidate was filed for the merge-gate,
worktree-removal, abandon-gate, or `validate-bash` instances (verified: the only two new potential
entries are the D11.6 pair, neither of which is a #591 instance). The one clause that cannot be
satisfied — "The pull-request body states the supersession and names issue #591" — depends on a PR
body that does not exist. This is a **pre-PR gate condition for `pr-author`**, not a code gap.

**G-4 — Structural under-match on a path-spelled wrapper. Severity: Minor. Recommend filing.**

`Get-CommandLineWrapperName` membership is exact string equality against the `CommandWord` token, so
`/bin/bash -c 'git add .'` and `/usr/bin/env git add .` are not wrapper-led: their quoted argument is
masked and no hook classifies. Before this change the raw-text regexes matched inside them. The
implementation is spec-conformant — AC-05 pins **exact** membership of the 14-name set and leaf-of-path
resolution is specified nowhere — so this is a spec gap, not an implementation defect. It is the same
class as accepted residual D4.3, but D4.3's justification ("no such wrapper appears in any repository
skill, rule, or test") does not hold for an absolute-path spelling of a wrapper that *is* in the set.
The orchestrator surfaced this as an unclosed residual; that characterization is accurate.

**G-5 — `Unbalanced` classifies unconditionally in `Test-CommandLineInvocation`. Severity: Info. Accepted.**

Per D12, an `Unbalanced` segment returns a match for **any** `CommandWord`/`SubcommandPath`, so
`echo don't` (an unclosed single quote) causes every gated hook to classify and then consult its
checkpoint. Direction is fail-closed, which is correct for this hook family, and D12 states the rule
explicitly. The cost is over-classification on benign apostrophes. Recorded, not remediated.

**G-6 — Deferred merge-gate authorization hole (epic amendment EA-3). Severity: Info. Deliberately deferred, correctly scoped out.**

`Test-ChildCheckpointAllowsEpicMerge` takes only a `$Checkpoint` parameter and is consulted first, so
an `epic_mode` / `step9_status: passed` checkpoint authorizes merging any PR. Phase 9 found the Codex
sibling `Test-CodexCheckpointAllowsMerge` has the same shape, so a fix needs both copies. This is a
pre-existing authorization defect that #545 neither introduces nor widens, and fixing it would exceed
the nine-hook scope D11 defines. **Recommendation:** ensure EA-3 is carried into the epic's follow-up
register rather than resting only in this spec, since its scope grew during execution.

**G-7 — Two ambient test failures in unmodified suites. Severity: Info. Not change-caused.**

Both were independently reproduced or corroborated by this reviewer.

*`enforce-pr-author-skill.Tests.ps1`, case `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (line 142).* Reproduced locally: `Expected: 'allow' / But was: 'deny'`. Diagnosis
confirmed: the enclosing `Context 'allowed commands'` `BeforeEach` (lines 127–140) mocks five
collaborators but **not** `Get-PrAuthorCheckpointContent`, whereas three sibling contexts mock it at
lines 297, 317, and 363. The unmocked case therefore reads the real
`artifacts/orchestration/orchestrator-state.json`, which this run wrote with `"epic_mode": true` and
`"integration_branch": "epic/cleanup-merged-worktrees-hardening-integration"`, while the fixture
command carries no `--base`. `artifacts/` is gitignored (`.gitignore:6`), so the file is absent on a
clean CI checkout and the epic-mode branch is never taken. **This reviewer independently confirms the
failure is not change-caused:** the pre-#545 code path produces the identical deny for the identical
ambient state — the old `$CommandText -match '(?i)\bgh\s+pr\s+create\b'` classifies this fixture just
as the new `Test-CommandLineInvocation` does, and the old
`-cnotmatch [regex]::Escape("--base $integrationBranch")` returns `EPIC_BASE_BRANCH_MISMATCH` for a
command with no `--base` just as `Get-CommandLineFlagValue` returning `$null` does now. The decision
to leave an unrelated suite's isolation defect unfixed is correct under D11's scope. The earlier
mis-attribution to the baseline set was corrected in the record, which is the right handling.

*`codex-pretooluse-integration.Tests.ps1`.* Not present in this reviewer's local partial run (1520
cases, 1 failure), so it was not independently reproduced. The recorded cause —
`enforce-epic-wave-barrier.ps1` reading this worktree's gitignored epic checkpoint — is consistent
with the same ambient-state mechanism and with the file being gitignored. Accepted on the evidence.

**G-8 — Duplicated worktree-path helper bodies. Severity: Minor.** See code review CR-3.

**G-9 — Write-only retained constant. Severity: Minor.** See code review CR-4.

### Approved Exceptions

- **PowerShell branch-coverage threshold**: not applied. Pester emits no `BRANCH` counter in any
  output format — independently verified by parsing the coverage XML. Per `.claude/rules/quality-tiers.md`
  this is a capability limit on an unevaluable threshold, not a file exclusion; all 18 canonical
  production files remain in the line-coverage denominator.
- **Bundle mirrors outside the coverage denominator**: pre-existing repository convention
  (`CodeCoverage.Path` holds zero entries under `extensions/drm-copilot/resources/`), unchanged by
  this branch, with parity enforced by content and hash comparison instead. Not a new exclusion.
- **`pwsh` unavailability**: all PowerShell stages ran through documented substitute routes. Every
  test-bearing evidence artifact carries a `TOOLCHAIN_SUBSTITUTION` note.

### Removed/Skipped Tests

None. Two `It` assertions reversed their expected decision — the heredoc case named
`denies a message-body payload that merely contains the staging literal` on each side — which is the
intended over-match fix and is recorded in
`evidence/regression-testing/intended-assertion-reversal.2026-09-07T11-52.md`. The deny-preservation
audit confirms no third assertion reversed.

---

## 9. Summary of Changes

### Commits in This Branch

```
77cb427d docs(545): complete phase 13 final QA loop and coverage evidence
1a68a817 test(545): add coverage suites for codex enforcement hooks
b0c2c30f docs(545): record supersession annotations and cross-cutting verification evidence
fdf1c84c fix(545): match enforcement hooks on structural command segments
71498961 fix(545): rewire remaining enforcement hooks onto structural parser
b5c59430 fix(545): scope preimplementation and promotion gate triggers per segment
237c4d07 feat(545): add shared command-line parser for enforcement hooks
8e2a8fd2 test(545): add baseline evidence and regression-first trigger-scoping tests
```

### Files Modified — production PowerShell (canonical)

| File | Δ lines | Role |
|---|---|---|
| `.claude/hooks/hook-command-scanner.ps1` | +450 (new) | Segment scanner, D2 Piece 1 + 2 |
| `.claude/hooks/hook-command-invocation.ps1` | +483 (new) | Structural matcher, D2 Piece 3 + D12 |
| `.codex/hooks/hook-command-scanner.ps1` | +450 (new) | Byte-identical Codex copy |
| `.codex/hooks/hook-command-invocation.ps1` | +483 (new) | Byte-identical Codex copy |
| `.claude/hooks/validate-bash.ps1` | +184/−? | Token-run primitive + structural `git` leg (D11.3) |
| `.codex/hooks/validate-bash.ps1` | +114/−? | Same, Codex shape |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | +49 | `Get-CommandLineOperand` / `Get-CommandLineFlagValue` PR-number resolution (AT-2, #591) |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | +40 | Same; no unanchored digit scan acquired (AC-29) |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | +32 | Structural scope filter + operand extraction (AT-1) |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | +42 | Same |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | +39 | Same; cross-runtime divergence closed (AT-7) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | +8 | Per-segment `ScanText` evaluation + structural `git` staging leg |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | +7 | Same |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | +42 | Per-segment token scan + structural `gh issue create/new` (D10, AT-5) |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | +41 | Same |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | +22 | `Test-CommandLineInvocation` / `Test-CommandLineFlag` trigger |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | +15 | Structural trigger + `--base` from matched segment |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | +87 | Per-segment disposition test, equals-joined spelling (AT-11, AT-12) |

Each of the 18 has a byte-identical bundle mirror under `extensions/drm-copilot/resources/**`.

### Files Modified — registration, test, and docs

- 2 × `pester.runsettings.psd1` (+19 each, textually identical)
- 2 × `pack-manifests/core.json` (+2 each)
- 27 test files (13 new Claude, 12 new Codex, 3 modified — 2 for the intended assertion reversal, 1 for the `$script:SharedModuleNames` registration)
- `docs/features/active/…-539/spec.md` — additive annotations at five locations (AC-20)
- 2 new `docs/features/potential/` entries (AC-33)

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

### Policy-by-Policy Summary

| Policy | Verdict | Note |
|---|---|---|
| `CLAUDE.md` policy-compliance order | ✅ PASS | Phase 0 reading evidence present |
| `general-code-change.md` — design principles | ⚠️ PARTIAL | Reusability partial: two byte-identical copy-pasted helper bodies (CR-3) |
| `general-code-change.md` — file size | ✅ PASS | Max 500 |
| `general-code-change.md` — toolchain loop | ✅ PASS | Single pass, format → analyze → test, no restart |
| `general-code-change.md` — error handling | ✅ PASS | Explicit fail-closed early returns, no broad catch |
| `general-code-change.md` — I/O boundaries | ✅ PASS | Parser is pure; no disk, process, network, clock, env |
| `general-unit-test.md` — five core principles | ✅ PASS | All five satisfied for the changed suites |
| `general-unit-test.md` — coverage thresholds | ✅ PASS | 95.4618% repo-wide, 18/18 files ≥ 85%, new files 96.77–100% |
| `general-unit-test.md` — Coverage Exclusion Policy | ✅ PASS | Eight files added to the denominator, none removed |
| `general-unit-test.md` — no temporary files | ✅ PASS | Verified by grep across all 27 changed test files |
| `general-unit-test.md` — test file location | ✅ PASS | All in the mirrored `tests/` tree, zero colocation |
| `general-unit-test.md` — determinism | ✅ PASS | No sleep, no wall-clock, no RNG |
| `quality-tiers.md` — uniform thresholds | ✅ PASS | Line ≥ 85% met; branch exempt for PowerShell with reason recorded |
| `powershell.md` — format / lint / advanced functions | ✅ PASS | 0 diagnostics, set-difference 0 |
| `powershell.md` — no dead code | ⚠️ PARTIAL | One write-only retained constant (CR-4) |
| **Deny-side behavioral preservation** | ❌ **FAIL** | G-1 / CR-1: `validate-bash.ps1` wrapper denial weakened and unpinned |
| `tonality.md` | ✅ PASS | Artifacts and code comments are factual and measured |

### Metrics Summary

- Changed files: 168 (63 `.ps1`, 2 `.psd1`, 2 `.json`, 101 `.md`)
- Coverage languages with changed files: **PowerShell only** → verdict **PASS**
- Coverage languages with zero changed files: Python, TypeScript, C#, Bash → `N/A - out of scope`
- Repo-wide PowerShell line coverage: **95.4618%** (threshold 85%)
- New production files: 4, coverage **96.7742% – 100.0000%**
- Modified production files: 14, all ≥ 88.3117%, 8 improved / 2 ratio-decreased with rising covered counts
- Branch coverage: not evaluable (Pester emits no `BRANCH` counter) — exempt, not FAIL
- Tests: 4326 collected, 4315 passed, 2 ambient failures, 9 skipped, 0 errors
- Blocking findings: **1** (G-1)
- Non-blocking findings: 8

### Recommendation

**Conditional Go.** The engineering is disciplined and the evidence chain is unusually complete: the
parser is pure and well-tested, coverage exceeds threshold on every changed file, parity and
registration are complete across all four copy locations, and regression-first evidence exists in both
directions. Every claim this reviewer could independently re-derive — coverage figures, byte parity,
line counts, evidence locations, literal preservation, test locations, temp-file absence — checked out.

One finding should be closed before merge: **G-1**, the `validate-bash.ps1` wrapper-with-quoted-argument
denial loss. It is a small, well-understood fix (make leg 1 additionally test the segment's `ScanText`
for wrapper-led and live-substitution segments) plus three pinning cases. Leaving it open trades a
concrete, ordinary-spelling loss of a destructive-command denial for a short delay.

**G-2** (AC-07) requires only a specification amendment recording that D12 and AC-31 supersede the
pr-author clause; no code change. **G-3** (AC-22) is a `pr-author` gate condition, not a code gap.
**G-4** and **G-6** should be filed as follow-ups rather than fixed here.

---

## Appendix A: Test Inventory

### New Claude-side suites (13)

`enforce-epic-merge-gate.TriggerScoping.Tests.ps1` (133) · `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` (107) · `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` (332) · `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` (69) · `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` (88) · `enforce-pr-author-skill.TriggerScoping.Tests.ps1` (281) · `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` (57) · `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` (197) · `hook-command-invocation.Tests.ps1` (330) · `hook-command-parser.AcceptanceCases.Tests.ps1` (228) · `hook-command-scanner.Tests.ps1` (347) · `validate-bash.TriggerScoping.Tests.ps1` (82)

### New Codex-side suites (12)

`enforce-epic-merge-gate-decision-surface.Tests.ps1` (161) · `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` (86) · `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` (251) · `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (110) · `enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` (205) · `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` (350) · `enforce-promotion-mcp-only-decision-surface.Tests.ps1` (214) · `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` (183) · `hook-command-invocation.Tests.ps1` (267) · `hook-command-scanner.Tests.ps1` (321) · `validate-bash-decision-surface.Tests.ps1` (329) · `validate-bash-trigger-scoping.Tests.ps1` (45)

### Modified suites (3)

`enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (+41, one intended assertion reversal) · `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (+43, same reversal) · `legacy-codex-hook-contracts.Tests.ps1` (+2/−2, `$script:SharedModuleNames` registration only)

### Coverage gap: no wrapper-form case in any `validate-bash` suite

Grep for `bash -c`, `sh -c`, `pwsh -Command`, `pwsh -NoProfile` across all four `validate-bash`
suites returns **no matches**. This is the test-surface half of finding G-1.

---

## Appendix B: Toolchain Commands Reference

### Commands this reviewer executed

```bash
# Scope determination (full branch diff, no narrowing)
git diff --name-status 6dff80ed4596bec088d548b23013e6077e32c484..HEAD
git diff --stat      6dff80ed4596bec088d548b23013e6077e32c484..HEAD
git diff --name-only 6dff80ed4596bec088d548b23013e6077e32c484..HEAD | sed 's/.*\.//' | sort | uniq -c

# Evidence-location compliance
git diff --name-only 6dff80ed...HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'   # exit 1, no matches
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .                      # EXIT 0

# Coverage-evidence validity: measured commit vs branch head
git diff --name-only 5903d0c7 77cb427d -- '.claude/hooks/*.ps1' '.codex/hooks/*.ps1' \
  'extensions/drm-copilot/resources/**/*.ps1' 'tests/scripts/claude-hooks/**' \
  'tests/scripts/codex-hooks/**' '**/pester.runsettings.psd1' '**/pack-manifests/core.json'      # no output

# Independent coverage re-derivation (package-qualified XML parse)
poetry run python <scratch>/cov.py        # 9 Claude rows match recorded CI figures to 4 dp
                                          # no BRANCH counter present at any level
# Independent test-result re-derivation
poetry run python <scratch>/junit.py      # 1520 cases, 1 failure, 0 errors
poetry run python <scratch>/junitmsg.py   # Expected: 'allow' / But was: 'deny'

# Python contract modules
poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py \
  tests/scripts/dev_tools/test_poshqc_bundled_parity.py \
  tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -q --no-cov   # 21 passed, 1 failed (#510)
git check-ignore -v .claude/state/powershell-batch-budget.worktree-*.json   # .gitignore:68
git check-ignore -v artifacts/orchestration/orchestrator-state.json         # .gitignore:6

# File-size cap
git diff --name-only 6dff80ed...HEAD -- '*.ps1' > /tmp/ps1list.txt
while read f; do printf "%5d  %s\n" "$(wc -l < "$f")" "$f"; done < /tmp/ps1list.txt | sort -rn

# Byte parity, canonical vs bundle and Claude vs Codex
cmp -s .claude/hooks/<file>.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<file>.ps1
cmp -s .codex/hooks/<file>.ps1  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<file>.ps1
cmp -s .claude/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-scanner.ps1

# Literal preservation (AC-07), re-checked against THIS audit's merge-base
git diff 6dff80ed...HEAD -- '*.ps1' > /tmp/full.diff
grep -E "^-" /tmp/full.diff | grep -E "<each protected literal>"     # only usages removed
grep -nE "^[-+].*bgh" /tmp/full.diff                                  # pr-author literals removed

# Scope constraints
grep '^\.claude/lib/' /tmp/all.txt                                    # none
grep -E '^(\.claude/rules/|\.github/instructions/)' /tmp/all.txt       # none
grep '\.py$' /tmp/all.txt                                             # none
grep -E '^(\.claude|\.codex)/hooks/' /tmp/all.txt                     # exactly the nine + parser

# Test hygiene
grep -nE 'New-TemporaryFile|\$env:TEMP|TestDrive|GetTempPath|GetTempFileName|Out-File|Set-Content' $(cat /tmp/tl.txt)
grep -nE 'Start-Sleep|Thread\]::Sleep|Get-Date -' $(cat /tmp/tl.txt)

# Finding G-1 substantiation
grep -n 'segment.Tokens\|ScanText' .claude/hooks/validate-bash.ps1 .codex/hooks/validate-bash.ps1
grep -rn 'bash -c\|sh -c\|pwsh -Command\|pwsh -NoProfile' tests/scripts/*/validate-bash*.ps1   # no matches
grep -n 'CdChainedReadCommandPattern' .claude/hooks/validate-bash.ps1 .codex/hooks/ tests/     # 1 hit: the declaration
```

### PowerShell toolchain (executed by the implementer; NOT re-runnable by this reviewer)

```
# Formatting
mcp__drm-copilot__run_poshqc_format   → evidence/qa-gates/final-poshqc-format.2026-09-07T17-03.md

# Linting
mcp__drm-copilot__run_poshqc_analyze  → evidence/qa-gates/final-poshqc-analyze.2026-09-07T17-05.md

# Type checking
# (none — PowerShell has no type-check stage)

# Testing
mcp__drm-copilot__run_poshqc_test     → artifacts/pester/pester-junit.xml
                                      → evidence/qa-gates/final-selfhosted-test.2026-09-07T17-11.md

# Coverage (route substitution: MCP runner cannot see this branch's new CodeCoverage.Path entries)
gh workflow run .github/workflows/_poshqc.yml
gh run watch 34145103168              → artifacts/pester/powershell-coverage.xml
                                      → evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md
```

**Availability note.** `pwsh`, `powershell`, and `cmd` are refused by the session runtime guard, and
the `mcp__drm-copilot__*` tools are not exposed to this reviewer. Review artifact templates were
therefore read from the repo-side bundled asset path
`extensions/drm-copilot/resources/templates/policy_audit/` — the exact path
`resolveBundledPolicyAuditTemplateAsset` in `extensions/drm-copilot/src/policy-audit-template-assets.ts`
resolves for the `template`, `code-review-template`, and `feature-audit-template` selectors — rather
than through `mcp__drm-copilot__resolve_policy_audit_template_asset`. This is a route substitution
against the same checked-out asset, recorded here rather than silently taken. For the same reason,
`mcp__drm-copilot__validate_orchestration_artifacts` could not be run; each artifact was instead
checked by hand against the canonical heading list in
`.claude/skills/policy-audit-template-usage/SKILL.md`.
