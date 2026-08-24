# Policy Compliance Audit: Codex PreToolUse Hook Transport Repair (#415) — Cycle-2 Re-Audit (R4)

**Audit Date:** 2026-07-26
**Code Under Test:** Full branch diff `bug/codex-pretooluse-hook-transport-415` (`d44a26ad85c0b542f51241e46a626f11585dc8ee`) vs base `main` (merge-base `5f24e0f6bc85f03303826746409935bb9ab94e1b`, which is current `origin/main` — the branch was rebased onto `main` after it advanced 21 commits for issues #421, #422, #423, #426). 136 files changed, +13731/−1352. Production surface: 11 root `.codex/hooks/*.ps1` files (1 shared module, 8 rewired hooks from cycle 1, 2 detached-HEAD null-guard fixes from cycle 2) plus byte-identical bundle mirrors, 2 `pester.runsettings.psd1` copies, `.gitignore`, `pack-manifests/core.json` (bundle), bundle-only deletion of `enforce-pr-author-skill.ps1`. Test surface: 10 Pester suites under `tests/scripts/codex-hooks/` (8 new, 2 extended; 3 of the new suites added in cycle 2), 1 Python contract test (1 deleted line). Remainder: feature docs and evidence under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/`.

**Review type:** Cycle-2 re-audit after remediation of CI-failure finding C1 (`enforce-epic-child-worktree-binding.ps1` exits 2 on a detached HEAD, caught by CI run 30213678367 on the `refs/pull/427/merge` detached checkout), the adjacent deliberate-behavior finding A1 (`enforce-epic-planning-only.ps1` push-path exit 2 on a detached HEAD, resolved per recorded decision RD-1), sweep S1, and coverage obligation R-COV. Remediation inputs: `remediation-inputs.2026-07-26T18-10.md`. Cycle-2 plan: `remediation-plan.2026-07-26T18-10.md` (31 tasks, all checked; verified against evidence, not accepted on assertion). Prior clean re-audit: `policy-audit.2026-07-26T13-42.md`. Template source: bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `template` resolves; the MCP resolver tool was unavailable in this session).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 28 files (11 root hooks + 11 bundle mirrors incl. 1 bundle deletion + 2 runsettings + tests counted below) | 1711 total (1702 pass + 9 skip, executor full run); 476 codex-hooks subset re-run by this audit at HEAD | ✅ 0 fail (executor full run and reviewer 476-test re-run) | 94.31% lines (2869/3042, 39 measured files — the cycle-1 clean re-audit endpoint, which is the cycle-2 baseline) | 94.34% lines (3148/3337, 41 measured files) | Cycle-2 changed files: 94.58% (279/295: worktree-binding 153/160 = 95.62%, planning-only 126/135 = 93.33%); whole-branch changed measured surface: 97.87% (1055/1078 across 11 files) |
| Python | 1 file (test-only: `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, 1 deleted line, unchanged since cycle 1) | 2123 tests (executor full suite, cycle 1); 9-test parity subset re-run by this audit | ✅ 0 fail | 91.00% lines, 81.84% branches | 91.00% lines (11175/12280), 81.84% branches (3642/4450) — re-summed by this reviewer; no movement, no production Python changed | N/A (test-only change; tests are excluded from the coverage denominator by policy) |
| JSON | 1 file (`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, +1 sorted entry, unchanged since cycle 1) | covered by manifest-completeness pytest contract | ✅ validation via passing contract test | N/A (config files) | N/A (config files) | N/A |

TypeScript and C#: zero changed files in the branch diff (`git diff --name-only main...HEAD` contains no `.ts`/`.tsx`/`.cs` paths, re-verified at the rebased head); no coverage verdict is owed for either language. The upstream rebase migrated the repository's TypeScript test runner to Jest (`.claude/rules/typescript.md`, current text read by this audit); with zero changed TypeScript files this changes nothing for this branch's verdicts.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript files on the branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero changed TypeScript files on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/remediation-baseline/phase0-poshqc-test-authoritative.2026-07-26T14-37.md` (cycle-2 baseline anchor, 2869/3042 = 94.31%, with the auditable negative record that both cycle-2 hooks were absent from the measured set)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (parsed independently by this audit: 41 files, 3148/3337 = 94.34%) with evidence records `evidence/qa-gates/remediation2-final-poshqc-test.2026-07-26T15-17.md` and `evidence/qa-gates/per-file-coverage-final.2026-07-26T15-17.md`
- Per-language comparison summary: Section 1.2.1 below, plus `evidence/qa-gates/remediation2-coverage-comparison.2026-07-26T15-17.md` (PowerShell) and `evidence/qa-gates/python-coverage.2026-07-26T11-41.md` (Python, artifact `artifacts/python/lcov.info`, re-summed by this reviewer at this audit)

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required. Satisfied: numeric baseline and post-change values are present above for both languages with changed files.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS. No required artifact is absent in this cycle.

**Evidence rule:** No evidence in this audit is synthesized. Every number was either re-derived by this reviewer from the on-disk artifacts (`artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`) or re-executed directly (476-test Pester re-run of all `tests/scripts/codex-hooks/` suites, 9-test pytest parity subset, evidence-locations validator, root/bundle file-by-file hash comparison, config.toml direct read, and an independent detached-worktree probe of both fixed hooks at the committed HEAD).

---

## Rejected Scope Narrowing

None. The caller prompt for this re-audit explicitly demanded the full feature-vs-base scope ("Re-audit with the same scope — no narrowing") and supplied no plan-subset, file-subset, or language-coverage narrowing. The audit scope used is the full branch diff `5f24e0f6..d44a26ad` against resolved base `main`.

The caller flagged four executor-reported deviations for adjudication on the merits; none is a scope narrowing. They are adjudicated in Section 8.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0, no violations (re-run by this audit).
- Branch-diff scan for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero matches (`git diff --name-only main...HEAD | grep -E '^artifacts/'` returns nothing — no `artifacts/`-rooted path of any kind is committed by this branch).
- All cycle-2 evidence artifacts (15 new) resolve under the canonical `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/<kind>/` tree.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller or plan instruction supplied a non-canonical evidence path this cycle.

**Verdict: PASS.**

---

## Executive Summary

This is the cycle-2 re-audit after the S9 CI green gate failed against the prior head: CI run 30213678367 failed `poshqc / PowerShell QC` on exactly one test — the config-driven integration case added by this branch — because `enforce-epic-child-worktree-binding.ps1` exited 2 on the detached HEAD that GitHub Actions produces when checking out `refs/pull/427/merge`. The integration test behaved correctly; it caught a real defect that named-branch local checkouts mask.

All four cycle-2 findings are resolved with independently re-verified evidence:

- **C1 (resolved, independently reproduced):** `Get-CodexChildGuardLiveBranch` was extracted above the dot-source guard; it returns `''` when git fails (`$LASTEXITCODE -ne 0`) **or** when git succeeds with null/whitespace output (the detached-HEAD condition where `[string](<empty pipeline>)` yields `$null`), and the entrypoint passes the already-trimmed value so no `.Trim()` can throw. This reviewer created its own detached worktree at the committed HEAD `d44a26ad` and piped the benign CI payload into the hook: **exit 0, empty stdout, empty stderr** — the fail-before state (exit 2, null-method stderr) is gone at the committed content, without any overlay.
- **A1 (resolved per RD-1, decision functions verified unmodified):** `enforce-epic-planning-only.ps1` gained wrapper `Invoke-EpicPlanningGit` and resolver `Get-EpicPlanningCurrentBranch`. Git *failure* keeps the pre-existing `EPIC_PLANNING_ONLY_BLOCKED` throw → exit 2 (fail closed); empty *successful* output resolves to `''`, which flows into the byte-unmodified decision layer. This reviewer verified `git diff main...21fc8c3b -- <both hooks>` is **empty**, so the cycle-2 diff is the entire branch change to these files, and every cycle-2 hunk is confined to the two new helper functions plus the entrypoint call-site — `Invoke-EpicPlanningOnlyDecision` and `Test-EpicPlanningBashAllowed` are byte-identical to `main`. The two deliberate entrypoint outcome changes (preparation-mode push on detached HEAD: exit-2 transport error → exit-0 policy deny via the existing envelope; dormant-mode push: exit-2 → allow) follow mechanically from feeding `''` to the unmodified policy: line 150's pre-existing `IsNullOrWhiteSpace($CurrentBranch)` withholds the push allowance in preparation mode, and line 171's pre-existing dormant guard returns `$null` when no checkpoint selects preparation. Both outcomes are pinned by committed decision-layer tests and were re-run green by this reviewer; the reviewer's own detached-worktree push probe confirmed the dormant allow at HEAD. This is correctly scoped: exit 2 was a transport misuse (the spec's contract reserves exit 2 for malformed or missing required Codex stdin; a detached HEAD is a legitimate repository state), and the policy applied to `''` is the hook's existing policy, not a new one.
- **S1 (sweep, independently re-executed):** this reviewer re-ran all three sweep greps and reproduced the executor's hit set exactly (4 + 7 pattern hits; 8 distinct `& git` call sites under `.codex`, all reconciled). Spot-verification of the SAFE verdicts against current source confirmed the null-safe `-notmatch` guards, array wraps, and count-checked pipelines. Zero new defects of the swept class.
- **R-COV (resolved on raw numbers):** both cycle-2 hooks were added to `CodeCoverage.Path` in both runsettings copies (additive-only: +6 lines each with an issue-#415 attribution comment, zero removals, `CoveragePercentTarget` unchanged at 0, copies byte-identical). This reviewer independently parsed the coverage XML: worktree-binding 153/160 = 95.62% raw, planning-only 126/135 = 93.33% raw — both above the 85% per-file gate with no residual computation needed. Repo-wide movement 94.31% → 94.34% reconciles exactly: denominator +295 = precisely the two newly measured files' instrumented lines (160+135), numerator +279 = precisely their covered lines (153+126), therefore **zero previously covered lines lost coverage**. The cycle-1 changed-file band (96.55%–100.00%) is byte-identical to its baseline, covered/missed/total triple by triple.

The cycle-2 delta is constraint-clean and was verified as such by this reviewer, not accepted from the executor: zero `.claude/` paths anywhere in the branch diff; `.codex/config.toml` has no diff at any range and carries 5 / 5 / 8 handler blocks in its three `PreToolUse` matcher groups (direct read); root `.codex/` and the bundled Codex copy are byte-identical file-by-file (0 hash differences across the full file sets, which are themselves identical); both runsettings copies byte-identical; no temp-file API appears in any branch-changed test; the largest changed file is 489 lines (cycle-2 files: hooks 334/310, tests 344/353/143); the cycle-2 test diff is purely additive (0 removed test lines) and contains no analyzer suppression; and the config-driven integration test that caught the CI failure is byte-unchanged in cycle 2, unskipped, and passed in this reviewer's 476-test re-run.

**Policy documents evaluated:**
- ✅ `CLAUDE.md` + `.claude/rules/general-code-change.md` (current post-rebase text read by this audit)
- ✅ `.claude/rules/general-unit-test.md` (current post-rebase text read by this audit)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- ✅ `.claude/rules/python.md` (test-only change; parity gates re-verified)
- N/A TypeScript, C#, Bash (no changed files; the Jest migration in the current TypeScript rule affects nothing on this branch)
- ✅ JSON: single sorted-position manifest entry (cycle 1), guarded by contract test

**Temporary artifacts cleanup:**
- ✅ Working tree clean at HEAD (`git status --porcelain` empty); no throwaway scripts in the diff
- ✅ `.codex/state/` does not exist on disk after the full reviewer re-run; `.gitignore` carries the cycle-1 `.codex/state/` entry
- ✅ Reviewer's own probe worktree removed and pruned after use (`git worktree list` clean)

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Cycle-2 cases are dot-sourced unit tests with mocked wrapper seams (no shared state) plus in-process entrypoint cases that restore console readers and environment in `finally`. Reviewer re-ran the full 10-suite codex-hooks set in one pass: 476/476. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per `It` throughout the three cycle-2 suites (empty-output resolver, git-failure throw, trimmed-name pass-through, `-C` argument pass-through, RD-1 deny, RD-1 dormant allow, entrypoint transport). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The 43 cycle-2 tests run in ~1.4s (reviewer-measured); the full codex-hooks set in 67.3s dominated by the deliberate process spawns of the cycle-1 contract suites. |
| **Determinism** - Consistent results | ✅ PASS | The detached-HEAD condition is made deterministic by mocking the git wrapper seam to emit nothing with `$global:LASTEXITCODE = 0` — the exact CI condition — rather than depending on checkout state. Entrypoint cases are deliberately environment-agnostic (assert transport, not which branch-resolution arm ran), so they pass on both named-branch and detached checkouts. The push-shaped payload is deliberately not driven through the planning-only entrypoint because that entrypoint reads the mutable repository checkpoint; the mapping is locked at the decision layer instead. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange–Act–Assert with intent comments; suite docstrings state the defect mechanism (`[string](<empty pipeline>)` → `$null`) and the CI context (refs/pull/N/merge). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (cycle-2 anchor = cycle-1 clean endpoint):** PowerShell 94.31% lines (2869/3042, 39 files) with the auditable negative record that both cycle-2 hooks were absent from the measured set; Python 91.00% lines / 81.84% branches.<br>**Command:** `Invoke-PoshQCTest -Root <repo>` (CI-path); `poetry run pytest --cov --cov-branch`<br>**Timestamp:** 2026-07-26 14:37 (`evidence/remediation-baseline/phase0-poshqc-test-authoritative.2026-07-26T14-37.md`) |
| **No Coverage Regression** | ✅ PASS | **Post-change:** PowerShell 94.34% (3148/3337, 41 files). Three-term reconciliation performed independently by this reviewer: denominator +295 = the two new files' totals (160+135); numerator +279 = their covered lines (153+126); every cycle-1 measured file's covered/missed/total triple byte-identical to baseline. Python 91.00%/81.84% (±0.00, re-summed). |
| **New Code Coverage ≥90%** | ✅ PASS on the governing uniform thresholds | The two cycle-2 changed files are modified production files measured for the first time: worktree-binding 95.62% raw, planning-only 93.33% raw — both above the uniform 85% line gate and above the baseline they had (previously outside the denominator entirely, so measurement itself is strictly improved). The whole-branch changed measured surface stands at 97.87% (1055/1078); the cycle-1 new module remains 101/101 = 100.00%. |
| **Comprehensive Coverage** | ✅ PASS | 16 residual uncovered lines across the two cycle-2 hooks, each itemized with a per-line reason in `per-file-coverage-final.2026-07-26T15-17.md` and verified by this reviewer against the XML (missed-line sets 303,309,314,319,328,332,333 and 252,281,288,289,290,295,304,308,309 match the itemization exactly) and against source: post-guard entrypoint wiring requiring on-disk attestation/receipt state that the no-temp-file rule forbids, `catch` arms the fix made unreachable for well-formed input, and one pre-guard wrapper-seam body line whose only content is the live `git` invocation that the mocking rules require tests not to execute. No exclusions: all 295 instrumented lines remain in the denominator. |
| **Positive Flows** - Valid inputs | ✅ PASS | Trimmed-branch pass-through cases; benign-payload entrypoint cases (exit 0, empty stdout); dormant-mode push allow (RD-1b); reviewer's independent detached-worktree probes at HEAD. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Git-failure throw (exit-2 transport preserved, RD-1a); preparation-mode push deny with empty branch (RD-1b) asserting the exact existing envelope reason; cycle-1 malformed-stdin sweep unchanged and re-run green. |
| **Edge Cases** - Boundary conditions | ✅ PASS | The empty-successful-output condition itself is the edge case under repair; both empty-output and whitespace handling covered at the resolver seam; `-C` argument pass-through pinned. |
| **Error Handling** - Error paths | ✅ PASS | RD-1a case pins the exact `*current branch could not be resolved*` transport message; entrypoint cases assert stderr does not contain the null-method or blocked messages. |
| **Concurrency** - If applicable | N/A | Hooks are single-shot short-lived processes; no concurrent state. |
| **State Transitions** - If applicable | ✅ PASS | Checkpoint-dependent RD-1 outcomes locked at the decision layer with explicit `CheckpointRaw` injection for both the preparation and dormant states. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.31% lines (2869/3042, 39 measured files) -> Post-change: 94.34% lines (3148/3337, 41 measured files). Change: +0.03 pp with +295 instrumented-line denominator growth from the 2 newly measured cycle-2 production files; numerator growth +279 equals their covered lines exactly, so zero previously covered lines lost coverage (reviewer-reconciled). New/changed-code coverage: 94.58% (279/295 for the cycle-2 changed files: `enforce-epic-child-worktree-binding.ps1` 153/160 = 95.62%, `enforce-epic-planning-only.ps1` 126/135 = 93.33%; whole-branch changed measured surface 1055/1078 = 97.87%; cycle-1 band 96.55%–100.00% held exactly). Branch coverage is not separately measurable in this toolchain (JaCoCo output carries no BRANCH counter; reviewer re-confirmed on the current XML) — a documented toolchain limitation per `spec.md:248`, not a waiver. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (independently parsed), `evidence/qa-gates/per-file-coverage-final.2026-07-26T15-17.md`, `evidence/qa-gates/remediation2-coverage-comparison.2026-07-26T15-17.md`.
- Python: Baseline: 91.00% lines / 81.84% branches -> Post-change: 91.00% lines (11175/12280) / 81.84% branches (3642/4450). Change: +0.00 pp, exactly as expected (the branch's only Python change is one deleted line in a test module; cycle 2 touched no Python at all). New/changed-code coverage: N/A - the single changed Python file is a test module and tests are excluded from the coverage denominator by policy. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (independently re-summed by this reviewer at this audit), `evidence/qa-gates/python-coverage.2026-07-26T11-41.md`.
- TypeScript: zero changed files on the branch. Disposition: N/A. Evidence: `git diff --name-only main...HEAD` contains no `.ts`/`.tsx` paths (re-verified at the rebased head).
- C#: zero changed files on the branch. Disposition: N/A. Evidence: `git diff --name-only main...HEAD` contains no `.cs` paths (re-verified at the rebased head).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact-message assertions (`Should -Throw -ExpectedMessage`, envelope-reason `Should -Match`); `Should -Invoke ... -ParameterFilter` pins the wrapper call shape. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Consistent AAA with section comments in all three cycle-2 suites (reviewer-inspected). |
| **Document Intent** | ✅ PASS | Suite docstrings explain the null-cast mechanism, the CI detached-ref context, and why the push payload is decision-layer-only. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Cycle-2 unit cases mock the git wrapper seam (never the executable, per `.claude/rules/powershell.md` mocking rule 1) with signature parity `param([string[]]$GitArgs)` and explicit `$global:LASTEXITCODE`. |
| **Use Mocks/Stubs** | ✅ PASS | Wrapper-seam mocks for git; fixture objects for receipts/payloads; no live executable in any cycle-2 unit case. |
| **Environment Stability** | ✅ PASS | No temp-file API in any branch-changed test (reviewer grep across `tests/scripts/codex-hooks/`; the only `GetTempPath` hit is in a pre-existing file outside this branch's diff). In-process stdin via `[System.Console]::SetIn([System.IO.StringReader]::new(...))` with readers and the full `CODEX_EPIC_CHILD_*` environment set saved and restored in `finally` (reviewer-inspected). Detached worktrees appear only in non-committed evidence probes outside the repository, per plan convention C4. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the cycle-2 re-audit; companion artifacts `code-review.2026-07-26T17-14.md` and `feature-audit.2026-07-26T17-14.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Objective fixed by `remediation-inputs.2026-07-26T18-10.md` (C1 with verbatim CI failure text, A1 with the deliberate-behavior question, S1 sweep, and a Do-Not-Do list). |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-07-26T18-10.md` v1.2, preflighted (`docs(415): clear cycle-2 remediation plan preflight`, commit 21fc8c3b), 31 tasks all checked. |
| **Document the plan** | ✅ PASS | Plan and its two revisions committed in the feature folder; recorded decisions RD-1..RD-6 govern the deliberate-behavior and measurement choices. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Each fix is a minimal extraction: one resolver function (C1) or one wrapper plus one resolver (A1), inserted above the dot-source guard, with a one-line entrypoint rewiring. No new abstractions. |
| **Reusability** | ✅ PASS | C1 reuses the existing `Invoke-CodexChildGuardGit` wrapper; A1 introduces the same wrapper-seam shape the repo standard mandates. |
| **Extensibility** | ✅ PASS | Resolver functions take `-RepositoryRoot` explicitly; no hidden state. |
| **Separation of concerns** | ✅ PASS | Transport (branch resolution) is now separated from policy (decision functions, byte-unchanged); the RD-1 outcome mapping lives entirely in the pre-existing decision layer. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | New functions placed with the hook they serve, above the dot-source guard for testability. |
| **Under 500 lines** | ✅ PASS | Reviewer-measured every changed code file at HEAD via `(Get-Content -LiteralPath $path).Count`: hooks 334 and 310; cycle-2 tests 344, 353, 143; branch maximum 489 (`codex-pretooluse-transport.Tests.ps1`, cycle 1). |
| **Public vs internal** | ✅ PASS | Resolver/wrapper functions are hook-internal; nothing new is exported or dot-sourced by other files. |
| **No circular dependencies** | ✅ PASS | No new dot-sourcing introduced in cycle 2. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-CodexChildGuardLiveBranch`, `Invoke-EpicPlanningGit`, `Get-EpicPlanningCurrentBranch` — approved verbs, noun consistency with each hook's existing prefix. |
| **Docs/docstrings** | ✅ PASS | `[CmdletBinding()]`, `[OutputType([string])]`, mandatory typed parameters on all three new functions. |
| **Comment why, not what** | ✅ PASS | Test suites carry the rationale comments; the hook functions are small enough to be self-describing. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` → exit 0, zero files changed, proven by SHA256 before/after comparison across all nine cycle-2 PowerShell files (`remediation2-final-poshqc-format.2026-07-26T15-17.md`; deviation adjudicated in Section 8, item 3). |
| **2. Linting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` → exit 0, 0 findings (`remediation2-final-poshqc-analyze.2026-07-26T15-17.md`). Zero suppressions in the cycle-2 diff (reviewer grep). |
| **3. Type checking** | N/A (PowerShell) | Cycle 2 changed no Python; cycle-1 Pyright evidence stands (`remediation-final-pyright.2026-07-26T11-41.md`, 0 errors). |
| **4. Testing** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` (RD-5: stale bundled runsettings, mandated loop stage) THEN authoritative `Invoke-PoshQCTest -Root <repo>` → 1702 pass / 0 fail / 9 skip with the coverage XML this audit parsed (`remediation2-final-poshqc-test.2026-07-26T15-17.md`). **Reviewer re-run at HEAD:** all 10 codex-hooks suites, 476/476 pass including the config-driven integration matrix; pytest parity 9/9. |
| **Full toolchain loop** | ✅ PASS | Final format → analyze → test pass uninterrupted; per-phase loop artifacts exist for every implementation phase (`remediation2-phase{1,2,4,5,6}-poshqc-loop.2026-07-26T15-17.md`). |
| **Explicit reporting** | ✅ PASS | Every gate has a Timestamp/Command/EXIT_CODE evidence record under `evidence/qa-gates/` or `evidence/other/`. |

**Adjudication of the dual-path measurement (carried forward from cycle 1, still correct):** the MCP `run_poshqc_test` tool executes the PoshQC module packaged in the published npx-cached server (v1.0.19), whose bundled runsettings predate both this branch's runsettings edits, so its measured set is stale for this branch; CI (`.github/workflows/_poshqc.yml:38-42`) imports the repo-checkout module whose `PoshQC.psm1:3` binds settings to the module directory. The executor's local `Invoke-PoshQCTest -Root <repo>` is therefore command-for-command the CI path and is the authoritative coverage measurement. Verdict: deviation remains accepted; the measurement is CI-reproducible.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Two conventional fix commits (`bb12591b`, `d44a26ad`); closeout `remediation2-verification.2026-07-26T15-17.md` maps each finding to its evidence with verdicts. |
| **Design choices explained** | ✅ PASS | RD-1 (behavior decision), RD-2 (committed regression strategy), RD-3 (seam design), RD-5 (measurement paths), RD-6 (language scope) recorded in the plan. |
| **Update supporting documents** | ✅ PASS | Evidence tree current; spec untouched in cycle 2 (verified — it appears in the branch diff only because cycle 1 authored it). |
| **Provide next steps** | ✅ PASS | Exit-gate statement: this re-audit (`blocking_count == 0`) plus a green `poshqc / PowerShell QC` check against the new PR head, performed by the orchestrator after push. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | Final gate exit 0, zero files changed (SHA256-proven). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | Final gate exit 0, 0 findings; no suppression added anywhere in the cycle-2 diff. |
| **Fix all findings** | ✅ PASS | No findings arose in cycle 2. |
| **PowerShell 7+ compatible** | ✅ PASS | Analyzer settings enforce compatibility; no new syntax beyond existing repo patterns. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All three new functions use `[CmdletBinding()]` with mandatory typed parameters and `[OutputType()]` where they return values. |
| **Wrapper-seam standard** | ✅ PASS | `Invoke-EpicPlanningGit -GitArgs <string[]>` matches the mandated `Invoke-<Tool>Exe -<Tool>Args <string[]>` shape exactly (splatting, no `Args` parameter-name collision); C1 reuses the existing `Invoke-CodexChildGuardGit` seam. Each wrapper preserves its hook's original stderr redirection (`2>$null` for planning-only, `2>&1` inside the pre-existing child-guard wrapper), so no diagnostic-stream behavior changed. |
| **Avoid global state** | ✅ PASS | No new script-scoped mutable state. |
| **Error handling** | ✅ PASS | RD-1a preserves the specific fail-closed throw for genuine git failure; no catch-alls added; the entrypoint try/catch contract is unchanged. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 334 / 310 lines post-fix (planning-time 325 / 292 plus the inserted functions). |
| **Approved verbs** | ✅ PASS | `Get-`, `Invoke-`; analyzer clean. |
| **Comment why** | ✅ PASS | Rationale carried in tests and plan RDs; production insertions minimal. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Exit 0, no changes. |
| **Step 2: Analyze** | ✅ PASS | Exit 0, no findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Both invocation paths exit 0 with 0 failures; reviewer re-run 476/476. |
| **Rerun loop if needed** | ✅ PASS | Single uninterrupted final pass. |

#### 3B.5 Change Budget

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Per-batch cap (3 production + 3 test)** | ✅ PASS | Verified from the plan's batch accounting and the scope-verification artifact: Phase 1 = 1 production unit (root + mirror) + 1 test file; Phase 2 = 1 + 1 (extension); Phase 4 = mirrored runsettings pair; Phase 5 = 2 test files; Phase 6 = none (`NO-FURTHER-GAP`). No batch exceeds the cap under the established mirror-accounting interpretation. |

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **All** | ✅ PASS (tooling) / N/A (design) | Cycle 2 changed no Python (RD-6). The branch's single Python change (one deleted test line) is unchanged since cycle 1; the runsettings-parity pytest and both codex-customization contracts were re-run by this reviewer: 9/9 pass. Cycle-1 Black/Ruff/Pyright evidence stands. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Structure and ordering** | ✅ PASS | Unchanged since cycle 1; manifest contract re-run green. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules Pester 5.0`; Describe/Context/It with modern Should across all three cycle-2 suites. |
| **Use PoshQC Configuration** | ✅ PASS | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` with the cycle-2 additive `CodeCoverage.Path` extension (both copies, byte-identical, reviewer-verified). |
| **Mocking Rules** | ✅ PASS | Executables never mocked; wrapper seams mocked with exact signature parity (`param([string[]]$GitArgs)`); mocks registered in each `It` before invocation; `$global:LASTEXITCODE` set explicitly. |
| **Organization** | ✅ PASS | All under `tests/scripts/codex-hooks/` mirroring `.codex/hooks/`; `*.Tests.ps1` naming; no colocation. |
| **Deterministic requirements** | ✅ PASS | No network, no PATH reliance, no working-directory assumptions in cycle-2 cases (repo root resolved from `$PSScriptRoot`). |

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest / coverage** | ✅ PASS | Unchanged since cycle 1; parity subset re-run 9/9; repo-wide 91.00% / 81.84%. |

---

## 5. Test Coverage Detail

### Cycle-2 changed production files (newly measured)

| File | Covered/Total | Raw % | Uncovered-line disposition |
|---|---|---|---|
| `.codex/hooks/enforce-epic-child-worktree-binding.ps1` | 153/160 | 95.62% | 7 lines, all post-guard entrypoint wiring: active-attestation file reads/hashes (require on-disk receipt/spec state that the no-temp-file rule forbids), the non-null-decision emit line (deny envelopes fully covered at the decision layer), and the two `catch`-arm lines the fix made unreachable for well-formed input. Reviewer matched the XML missed-line set to the itemized justification exactly. |
| `.codex/hooks/enforce-epic-planning-only.ps1` | 126/135 | 93.33% | 9 lines: 1 pre-guard wrapper-seam body line (its only content is the live `git` invocation the mocking rules require tests not to execute; all wrapper behaviors covered through the mock), plus 8 post-guard entrypoint lines (absent-checkpoint else-arm, staged-paths/push live-git blocks kept out of the entrypoint cases for determinism, non-null emit, `catch` arm). Reviewer matched the XML missed-line set to the itemized justification exactly. |

No residual computation used: both files pass the 85% gate raw; all 295 instrumented lines remain in the denominator.

### Cycle-1 measured files (regression check)

All nine cycle-1 changed measured files byte-identical to their baseline triples: shared module 101/101, purity hooks 67/67 and 62/62, evidence-locations 41/41, preimplementation-gate 98/98, completion-consistency 136/136, checkpoint-monotonic 103/104, batch budgets 84/87 each. Band 96.55%–100.00% held. `enforce-completion-helpers.ps1` (76.74%) is pre-existing, byte-unchanged on this branch (`git diff main...HEAD` empty for it), and identical to its baseline figure — outside this branch's verdict set.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (PoshQC full run, executor final gate) | 1711 (1702 pass, 9 skip) | ✅ |
| Reviewer re-run (all codex-hooks suites at HEAD) | 476 pass, 0 fail, 67.3s | ✅ |
| Cycle-2 new tests (3 suites) | 43 pass, 0 fail, ~1.4s (reviewer-run in isolation) | ✅ |
| Reviewer detached-worktree probes at HEAD | 2/2 hooks exit 0, empty stdout, empty stderr | ✅ |
| Python parity tests (reviewer re-run) | 9 pass, 0 fail | ✅ |
| PowerShell repo-wide line coverage | 94.34% (3148/3337, 41 files) | ✅ |
| Cycle-2 changed-file coverage | 95.62% / 93.33% raw | ✅ |
| Python line / branch coverage | 91.00% / 81.84% | ✅ |
| Largest changed file | 489 lines (≤ 500) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | 0 files changed (SHA256-proven across all 9 cycle-2 files) | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | 0 findings | ✅ |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` + `Invoke-PoshQCTest -Root <repo>` | 1702 pass / 0 fail / 9 skip with coverage XML | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Parity contracts | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py test_push_down_codex_and_agents_{pack_manifest_completeness,resource_contracts}.py -q` | 9 pass (reviewer re-run) | ✅ |
| Black / Ruff / Pyright / full pytest | cycle-1 evidence | clean / clean / 0 errors / 2123 pass | ✅ |

**Notes:** The three pre-existing sub-85% files in the measured set (`validate-bash.ps1`, `enforce-completion-helpers.ps1`, `new-claude-worktree-session.ps1`) are unchanged on this branch and identical to their baseline figures; they are not regressions and not in this branch's verdict set.

---

## 8. Gaps and Exceptions

### Adjudication of the four executor-reported deviations

1. **`<BASELINE_SHA>` = `21fc8c3b`, not the mid-execution HEAD — ACCEPTED.** The plan defines the baseline as the observed pre-implementation HEAD; the rebase rewrote that commit's SHA from `37d0ecb4` to `21fc8c3b` (both are the docs-only `docs(415): clear cycle-2 remediation plan preflight` commit — reviewer-verified: `git log` shows 21fc8c3b is docs-only and immediately precedes the two fix commits). Using the mid-cycle HEAD (`bb12591b`, which already contains the C1 fix) would have excluded the C1 fix surface from the P7-T6 scope assertion — the opposite of narrowing-resistance. This reviewer independently recomputed `git diff 21fc8c3b..HEAD --name-only`: it contains exactly the two root hooks, two mirrors, two runsettings copies, three test files, and FEATURE-folder paths — nothing else. The scope assertion is sound and did not silently narrow. Independently of the plan-scope check, this audit's own scope is the full `main...HEAD` diff.
2. **`[P5-T1]` coverage cases placed in 2 new files rather than extending the existing suite first — ACCEPTED (Info).** The plan's placement preference was "first in `codex-detached-head-transport.Tests.ps1` (headroom to 500 lines), then up to 2 new files." Headroom arithmetic verified: the transport suite is 344 lines, leaving 156 against ~450 needed, so new files were required regardless; the executor used exactly the 2 authorized new files (353 + 143 lines), keeping each hook's coverage suite coherent in one file. The file budget was respected; the deviation is placement order only. |
3. **`[P7-T1]` zero-change formatter proof by SHA256 rather than `git status` — ACCEPTED.** Methodologically stronger, not weaker: before the final commit the working tree already differed from HEAD by the plan's own edits, so `git status` cannot distinguish formatter output from plan edits; a before/after content hash across all nine changed PowerShell files can, and showed zero changes.
4. **`Get-CodexChildGitScalar` advisory not acted on — REASONING VERIFIED, ACCEPTED.** Reviewer read `.codex/scripts/epic-child-launch-runtime.ps1:29-37`: the function checks `$output.Count -ne 1 -or IsNullOrWhiteSpace` **before** `.Trim()`, so a detached HEAD produces the explicit fail-closed `EPIC_CHILD_LAUNCH_BLOCKED ... did not return one value.` throw, not a null-method exception — a different class from the swept defect. The launch/resume scripts are not registered in `.codex/config.toml` (reviewer grep: no hook command references them), do not run on CI merge refs, and bind to named branches by design. Out of scope is the correct disposition; no scope expansion was warranted.

### Identified Gaps

**None blocking.** Non-blocking observations: (a) the three carried-forward cycle-1 Info items (shared-parser `hook_event_name` hardening, the pre-existing checkpoint-monotonic dead branch, the bundled-MCP PoshQC release lag) remain recorded in `evidence/other/remediation-followups.2026-07-26T11-41.md` with rationale; (b) RD-1's dormant-mode allow means a `git push` on a detached HEAD is no longer blocked by this hook when no preparation checkpoint exists — this matches the hook's documented dormant no-op contract (it previously exited 2, which blocked nothing either, since exit 2 is a hook error, not a deny), and the preparation-mode deny is pinned by a committed test.

### Approved Exceptions

**None.** Every threshold is met on raw measurements; no residual/denominator adjustment was used anywhere in cycle 2.

### Removed/Skipped Tests

**None.** The cycle-2 test diff contains zero removed lines (reviewer-verified). The config-driven integration test that caught the CI failure is byte-unchanged in cycle 2, contains no skip/pending markers, and passed in the reviewer's re-run. The 9 skips in the full run are pre-existing and unchanged in count.

---

## 9. Summary of Changes

### Cycle-2 commits

1. **886cf755** — docs(415): record CI failure and plan the detached-HEAD null-guard fix
2. **21fc8c3b** — docs(415): clear cycle-2 remediation plan preflight (the cycle-2 baseline)
3. **bb12591b** — fix(codex-hooks): treat an empty live branch as unset on detached HEAD (#415) — C1 fix + mirror + transport suite
4. **d44a26ad** — fix(codex-hooks): resolve detached-HEAD exit 2 and measure both hooks (#415) — A1 fix + mirror, runsettings pair, coverage suites, evidence

### Files Modified (cycle-2 delta, `21fc8c3b..HEAD`)

1. **`.codex/hooks/enforce-epic-child-worktree-binding.ps1`** (+ bundle mirror) — `Get-CodexChildGuardLiveBranch` extraction; entrypoint rewiring; no decision-function change.
2. **`.codex/hooks/enforce-epic-planning-only.ps1`** (+ bundle mirror) — `Invoke-EpicPlanningGit` wrapper + `Get-EpicPlanningCurrentBranch` resolver per RD-1; entrypoint rewiring; no decision-function change.
3. **`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`** (+ bundled copy) — additive 6-line `CodeCoverage.Path` extension (2 entries + attribution comment); nothing removed.
4. **`tests/scripts/codex-hooks/`** — 3 new suites (43 tests): `codex-detached-head-transport.Tests.ps1` (344), `codex-worktree-binding-hook.Tests.ps1` (353), `codex-planning-only-hook.Tests.ps1` (143).
5. **Evidence artifacts** (15 new) plus plan-checkbox updates under the canonical feature evidence tree.

The delivery + cycle-1 delta is unchanged and was re-verified at the rebased HEAD (parity, config integrity, coverage band).

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All cycle-2 findings resolved and independently re-verified. **Blocking findings this re-audit: 0.**

- **C1 → resolved:** null-guard extraction verified in code; reviewer's own detached-worktree probe at committed HEAD reproduces exit 0 / empty stdout / empty stderr; regression pinned by deterministic mocked-seam tests plus the permanent CI-side integration net.
- **A1 → resolved per RD-1:** decision functions byte-identical to `main`; the two entrypoint outcome changes are deliberate, scoped, justified, and test-pinned; exit 2 reserved for genuine git failure.
- **S1 → clean:** sweep independently re-executed; 8 distinct `& git` sites all adjudicated; zero new defects.
- **R-COV → resolved:** both hooks measured at 95.62% / 93.33% raw; repo-wide 94.34%; exact reconciliation proves zero coverage loss; cycle-1 band held.

All eight caller-listed constraints re-verified at HEAD:
1. Zero `.claude/` paths created, modified, or deleted (branch diff and working tree). ✅
2. `.codex/config.toml` unmodified; 5 / 5 / 8 handler blocks in the three `PreToolUse` matcher groups (direct read). ✅
3. No decision-function logic changed beyond RD-1's scoped entrypoint outcome changes (verified: cycle-2 hunks touch only new helpers and entrypoint call sites; `main...21fc8c3b` empty for both hooks). ✅
4. Root `.codex/` byte-identical to the bundled copy (0 hash diffs, identical file sets); both runsettings copies byte-identical. ✅
5. No temporary files in tests. ✅
6. No file over 500 lines by `(Get-Content -LiteralPath $path).Count` (max 489). ✅
7. Nothing removed from `CodeCoverage.Path`; no threshold lowered; no denominator shrunk; no assertion weakened (0 removed test lines); no analyzer suppression added. ✅
8. The config-driven integration test is intact, unweakened, unnarrowed, unskipped, and passing. ✅

### Metrics Summary

- ✅ 1702 PoshQC tests pass (0 fail, 9 skip); 476-test reviewer re-run at HEAD, 0 failures
- ✅ Independent detached-worktree probes: both fixed hooks exit 0 with empty output at HEAD
- ✅ PowerShell 94.34% repo-wide lines; cycle-2 files 95.62% / 93.33% raw; cycle-1 band held exactly
- ✅ Python 91.00% lines / 81.84% branches (re-summed)
- ✅ Format, lint clean; zero suppressions; evidence-locations validator exit 0
- ✅ `modified-workflow-needs-green-run` not triggered (no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths in the branch diff)

### Recommendation

**Ready for merge (Go for PR update / CI re-run).** Blocking count: 0. The remaining exit-gate element outside this audit's control is the green `poshqc / PowerShell QC` check against this head SHA in CI, per the S9 gate; local evidence (reviewer probe + full suite) indicates the failing CI condition is resolved.

---

## Appendix A: Test Inventory

Reviewer re-executed suite set at HEAD `d44a26ad` (all pass, 476 tests):

1. `codex-detached-head-transport.Tests.ps1` — cycle-2: resolver seams (empty-output, git-failure, trimmed-name, argument shape), RD-1 decision-layer locks, in-process entrypoint transport cases
2. `codex-worktree-binding-hook.Tests.ps1` — cycle-2: guard/decision-branch coverage closure via fixtures
3. `codex-planning-only-hook.Tests.ps1` — cycle-2: planning-boundary function coverage closure
4. `codex-pretooluse-integration.Tests.ps1` — config-driven spawn matrix (the CI net), byte-unchanged in cycle 2
5. `codex-pretooluse-transport.Tests.ps1`, `codex-pretooluse-file-mapping.Tests.ps1`, `codex-test-purity-hooks.Tests.ps1`, `codex-batch-budget-hooks.Tests.ps1`, `codex-evidence-and-checkpoint-hooks.Tests.ps1`, `codex-completion-consistency-hook.Tests.ps1` — cycle-1 suites, unchanged, green
6. `legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1` + pre-existing epic/attestation suites — parity and contract gates, green

Python: `test_poshqc_bundled_parity.py` + both codex-customization contracts (9 tests, reviewer re-run green).

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# MCP gates (as executed by the executor)
# mcp__drm-copilot__run_poshqc_format / run_poshqc_analyze / run_poshqc_test

# CI-equivalent authoritative coverage path (verified against .github/workflows/_poshqc.yml:38-42)
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path
```

**For Python:**
```bash
poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**Reviewer verification commands (this audit):**
```bash
git rev-parse HEAD && git merge-base HEAD main
git diff --name-status main...HEAD
git diff 21fc8c3b..HEAD                      # cycle-2 delta inspection
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Independent XML/lcov parsing (session-local pwsh, no artifacts written)
# Pester re-run: Invoke-Pester -Path tests/scripts/codex-hooks (476/476)
# Detached probe: git worktree add --detach <short-path> d44a26ad; pipe BENIGN/PUSH payloads; worktree remove + prune
```

---

**Audit Completed By:** feature-review agent (cycle-2 re-audit R4)
**Audit Date:** 2026-07-26
**Policy Version:** Current (as of audit date, post-rebase rule text)
