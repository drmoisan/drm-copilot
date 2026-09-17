# Code Review: Preimplementation Gate Worktree Selector (LACS) (#671) — Re-review after Remediation R1

---

**Review Date:** 2026-09-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671`
**Feature Folder Selection Rule:** Supplied by the caller. It matches the branch name suffix `-671`.
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration` (merge base `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
**Head Branch:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671` (`685bcbf50f492ae1540a50c57b15952d4fdf91e8`)
**Review Type:** Re-review after remediation (prior review: `code-review.2026-09-17T08-40.md`)

---

## Executive Summary

The branch widens the issue #539 orchestration-bookkeeping staging exemption along a single axis: the repository selector. One `git -C <value>` is accepted between `git` and `add`/`commit` when the value meets the eight lexical LACS conditions. Remediation commit `685bcbf5` makes three changes:
- adds `[AllowEmptyString()]` to the `$Token` parameter of `Test-ExemptOrchestrationSegmentToken`;
- wraps the per-segment loop of `Test-ExemptOrchestrationStagingCommand` in a fail-closed `try`/`catch`;
- replaces the L3a/L3b fixtures with commands that match the gate trigger, and adds 22 nodes per suite: 5 empty-token rows, 16 predicate-level rows, and the guard test.

The change is applied byte-identically to all four surface copies.

The reviewer inspected the full diff. The reviewer independently:
- re-derived the JUnit and coverage figures from `artifacts/pester/`;
- ran PSScriptAnalyzer and a check-only `Invoke-Formatter` comparison on all seven PowerShell files;
- ran a 21-row read-only probe of `Test-ExemptOrchestrationStagingCommand`;
- re-ran the Python push-down contract tests.

All three prior blockers (CR-1, CR-2, CR-3) are resolved. Prior findings CR-4 (no predicate-level rows) and CR-5 (L3 split across two functions, undocumented) are also resolved.

**What changed since the prior review:**
- Helpers (four copies, 433 → 441 lines): `[AllowEmptyString()]` on the caller's `$Token`, a fail-closed `try`/`catch`, and a help-text sentence stating that the caller enforces subcommand identity.
- Command-exemption suites (Claude and Codex):
  - L3a is now `git -C C:/repo/wt && git add -- docs/...`, and L3b is now `git -C C:/repo/wt --no-pager add -- docs/...`.
  - A new deny row covers `selector followed by an unmodelled subcommand`.
  - A new Context `issue #671 empty-token fail-closed cases` has 1 allow row and 4 deny rows.
  - A new Context `issue #671 selector predicate and fail-closed guard` has 3 accept rows, 12 reject rows, and a mocked-throw guard test.

**Top 3 residual risks (all non-blocking):**
1. The fail-closed `catch` swallows the error without any diagnostic, so a future regression that throws would be invisible apart from a deny (CR-R1).
2. Lexically valid but degenerate selectors, such as a drive root (`C:/`) or a POSIX root (`/`), are accepted. The operand constraints still apply, so the content-class invariant holds (CR-R2).
3. Two pre-existing Pester failures remain in the full run, and spec criterion 20 was amended to tolerate them. The reviewer did not find a tracking issue for them in the feature evidence (CR-R4).

**PR readiness recommendation:** **Ready** — 0 blocking findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and 3 copies) | lines 428–439 (`try { foreach ... } catch { return $false }`) | CR-R1: The fail-closed guard returns `False` without recording why. Every selector rejection in the same module writes a `PREIMPL_SELECTOR_*` `Write-Debug` token, but this branch writes none. If a later change makes classification throw on a legitimate exempt command, the only symptom is an unexplained `PREIMPLEMENTATION_GATE_BLOCKED`. | In a follow-up, add `Write-Debug "PREIMPL_SEGMENT_CLASSIFICATION_ERROR: $($_.Exception.Message)"` before `return $false`. All four copies must change together, and the parity suite enforces that. | The general code-change policy discourages catch-all handlers that neither re-raise nor add context. The fail-closed direction is correct, so this is a diagnosability gap, not a safety gap. | Diff inspection; the `returns false when segment classification raises an error` node passes. |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `Test-ExemptOrchestrationSelector` L4/L5 checks | CR-R2: `git -C C:/ add -- docs/...`, `git -C / add -- docs/...`, `git -C C:/repo//wt add ...`, and `git -C C:/repo/wt/ add ...` all return `True`. They satisfy L1–L8 as written: rooted, no `.`/`..` segment, no wildcard, and no stray colon. `git -C C: add ...` (no separator) returns `False`. | No change required. Optionally mention the drive-root form in the "Accepted widening" comment. It belongs to the same class as the nested-subdirectory widening, because the selector relocates a still-relative, still-exempt operand. | The operand classifier is unchanged, so the pathspec still has to be under the five exempt trees. | Reviewer probe (`qa.ps1`): the rows above returned `True`/`False` as stated, each with `errors=0`. |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `try`/`catch` scope | CR-R3: `catch` handles terminating errors only. A non-terminating error (`Write-Error`) raised inside classification would not reach the guard. No function in the module calls `Write-Error`. The binding error that caused the original fail-open no longer occurs, because `[AllowEmptyString()]` is present. | No change required. If a helper ever emits non-terminating errors, pass `-ErrorAction Stop` at the call site. | Keeps the guard's coverage claim accurate. | Reviewer Grep: no `Write-Error` in the helpers file; probe rows report `errors=0`. |
| Info | `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` | AC 20 (amended) | CR-R4: Amendment R1 changed criterion 20 from "`run_poshqc_test` reports zero failed tests" to "no failing node except the two baseline failures". The two nodes (`enforce-pr-author-skill ... pr_body_12.md` and `Every registered Codex PreToolUse handler ...`) fail at the merge base, and the branch does not touch their suites or hooks. | Confirm that both baseline failures are tracked by a repository issue. If they are not, file one through the MCP promotion route. | Pre-existing failures that are tolerated by amendment should have an owner. | `evidence/baseline/poshqc-test-coverage.2026-09-13T22-40.md` lines 16–23; reviewer JUnit parse (failures=2, both baseline). |
| Info | `artifacts/pr_context.summary.txt` | Close candidates | CR-R5 (carried from CR-10): the PR-context tool lists `#516`, `#539`, `#554`, `#INV-1`…`#INV-7`, `#SHA-256`, and `#UTF-8` as author-asserted close candidates. | The PR body should use a closing keyword only for #671. | Prevents unintended issue closure. | `artifacts/pr_context.summary.txt` lines 38–51 |
| Nit | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `Test-ExemptOrchestrationSegmentToken` selector absorption | CR-R6 (carried from CR-9): the `$Token` parameter is reassigned after the selector is stripped. | Optional: assign to a local such as `$effectiveToken`. | Readability only. | Diff inspection |

Blocking findings: 0.

### Disposition of prior findings

| Prior ID | Severity | Status | Evidence |
|---|---|---|---|
| CR-1 (empty-token fail-open) | Blocker | Resolved | `[AllowEmptyString()]` added; fail-closed `try`/`catch` added. The reviewer probe returned `False`, `errors=0` for the four RF-1 rows and for `git commit -m "" -- src/foo.ts`. `git commit -m "" -- docs/features/active/x/spec.md` returns `True`, which is the decision recorded in the spec. |
| CR-2 (L3a/L3b fixtures) | Blocker | Resolved | The new fixtures match the gate trigger. Both nodes pass in both suites (reviewer JUnit parse). The L3 `Write-Debug` line is among the 38 executed changed lines. |
| CR-3 (coverage regression) | Blocker | Resolved | Helpers file 147/152 = 96.71% (baseline 94.92%). Changed lines with zero hits: none. The `selector followed by an unmodelled subcommand` row passes in both suites. |
| CR-4 (no predicate-level rows) | Major | Resolved | The Context `issue #671 selector predicate and fail-closed guard` has 16 nodes per suite, all passing. |
| CR-5 (L3 split undocumented) | Minor | Resolved | The comment-based help now states that the caller rejects subcommands other than add or commit, and `predicate accept 3` pins that choice. |
| CR-6 (plan bookkeeping) | Minor | Resolved | `evidence/other/remediation-plan-checkbox-reconciliation.2026-09-17T10-45.md` records the disposition of all ten tasks: 4 checked, and 6 left unchecked because their original artifacts record failures that the remediation plan supersedes. |
| CR-7, CR-8 | Info | Unchanged | No action was required. |
| CR-9 | Nit | Carried as CR-R6 | — |
| CR-10 | Info | Carried as CR-R5 | — |

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The remediation edits are minimal: one attribute, and one `try`/`catch` around the unchanged loop body. The added lines inside the `try` block match the removed loop lines once whitespace is trimmed, as the amended AC 11 requires.
- Declaring `[AllowEmptyString()]` on the caller means an empty token now reaches the explicit checks: L8 for a selector value, and the operand classifier for a pathspec. A binding exception no longer decides the outcome.
- The protected files are unchanged. `git diff --stat 79fd5a95 -- <13 protected paths>` produced no output.
- The four helpers copies are byte-identical: SHA256 `AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989` on all four (reviewer `sha256sum`), and the parity suite passes.
- Purity is preserved. A Grep over the four copies found no `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, `env:`, or `Import-Module`. The purity sentence appears once per copy (line 5), and `Accepted widening` appears once per copy (line 45).

#### API and safety notes

- `Test-ExemptOrchestrationStagingCommand` keeps its signature and `[OutputType([bool])]`.
- The recorded spec decision allows `git commit -m "" -- <exempt path>`. An empty message is not a pathspec, and every operand is still exempt. The `allows issue #671 empty commit message beside an exempt operand` row pins this.
- PSScriptAnalyzer (1.25.0) reports 0 findings with `pssa.settings.psd1` on all seven files (reviewer run).

#### Error handling and logging

- The guard converts any terminating classification error into `False`, which is the safe direction for an allow-side predicate. See CR-R1 for the missing diagnostic, and CR-R3 for the scope of `catch`.

---

## Test Quality Audit

The reviewer independently parsed:
- `artifacts/pester/pester-junit.xml`: tests=4641, failures=2, errors=0, disabled=9. The two failures are the baseline nodes. All 94 `issue #671` nodes passed.
- `artifacts/pester/powershell-coverage.xml`: report LINE 8986/9404 = 95.56%; `.claude/hooks` helpers 147/152 = 96.71%.

Both reports postdate the last source edits, and the worktree is clean at HEAD.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`: 105 nodes, all passed. This includes 45 pre-existing `D4 row` deny rows, the pre-existing `D4 row 18` allow node, and 8 pre-existing issue #539 allow rows.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`: 105 nodes, all passed, with the same composition.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`: 2 nodes, both passed.
- Must-not-regress suites (reviewer JUnit roll-up), all passed:
  - `enforce-epic-merge-gate.Tests.ps1`: 56/56
  - `enforce-epic-merge-gate.TriggerScoping.Tests.ps1`: 12/12
  - Claude mode-resolution: 87/87
  - Codex mode-resolution: 55/55
  - Codex mode-routing: 11/11
  - `legacy-codex-hook-contracts.Tests.ps1`: 43/43, including `keeps the canonical hooks byte-identical to their bundled copies` and `parse-checks each root and bundled hook and keeps every file within 500 lines`
- `evidence/regression-testing/remediation-pass-after-probe.2026-09-17T09-30.md`:
  - Q1–Q11 are recorded with results, error counts, and gate decisions.
  - Of the twenty rows, rows 1–19 are identical to the prior pass-after capture.
  - Row 20 changes from True to False, which is the intended RF-1 outcome.
- `evidence/qa-gates/remediation-diff-additive-only.2026-09-17T10-15.md`: numstat `135 0` and `136 0`. The reviewer confirmed this with `git diff`.

### Quality assessment prompts

- **Determinism:** fixed strings; no clock, RNG, or process.
- **Isolation:** the predicate is now tested directly, and the gate-level rows remain as integration guards.
- **Speed:** in-memory only; the full repository run took 156.3 s.
- **Diagnostics:** every assertion carries `-Because` text. The guard test also asserts the invocation count, which confirms that the mocked path ran.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection. |
| No unsafe subprocess or command construction | ✅ PASS | No process start, `Invoke-Expression`, or dynamic script construction. |
| Input validation at boundaries | ✅ PASS | Empty tokens reach explicit checks. The reviewer probe covered 21 rows, including empty tokens, a drive-less `C:`, UNC, and operand traversal. None produced an error record, and each result matches the LACS rules. |
| Error handling remains explicit | ✅ PASS | Fail-closed guard; see CR-R1 for the missing diagnostic. |
| Configuration / path handling is safe | ✅ PASS | The selector must be rooted and non-UNC, with no dot segment, no wildcard, and no stray colon. Operands must still be repo-relative and under exempt trees. |
| Diff confinement (gate, modes, shared parser untouched) | ✅ PASS | Reviewer `git diff --stat` over 13 protected paths: no output. |
| Surface parity | ✅ PASS | Four identical SHA256 values. |

---

## Research Log

No external research was required. The reviewer relied on two points of PowerShell behavior:
- `try`/`catch` handles statement-terminating errors, including parameter-binding errors.
- `[AllowEmptyString()]` permits empty elements in a mandatory `[string[]]` parameter.

The reviewer confirmed both empirically with the probe run (`errors=0` for every empty-token row) and with the passing mocked-throw guard test.

---

## Verdict

The remediation resolves every blocking and major finding from the prior review with minimal, confined edits. The fail-open is closed and pinned by tests at both the gate level and the unit level. Coverage on the modified file is above its baseline, and every changed line is executed. The toolchain loop closed in a single pass. The remaining observations (CR-R1 to CR-R6) are non-blocking follow-ups.

Blocking findings: 0.
