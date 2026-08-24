# Remediation Closeout — Cycle 2 (Issue #415)

- **Issue:** #415
- **Task:** [P7-T7]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Work Mode:** full-bug (`spec.md` is the sole authoritative acceptance-criteria source)
- **Remediation cycle:** 2 of a cap of 3
- **Branch:** `bug/codex-pretooluse-hook-transport-415`
- **PR:** https://github.com/drmoisan/drm-copilot/pull/427
- **`<BASELINE_SHA>`:** `21fc8c3b7f549723097efe4d8dc0e1404dca1867`

Timestamp: 2026-07-26T15-17

## Finding-by-Finding Verdicts

### C1 (Blocking) — `enforce-epic-child-worktree-binding.ps1` exits 2 on a detached HEAD

**Verdict: PASS.**

| Evidence | Artifact / reference |
|---|---|
| Fail-before | `FEATURE/evidence/regression-testing/fail-before.2026-07-26T14-37.md` — BENIGN payload, exit **2**, stderr `[You cannot call a method on a null-valued expression.]`, reproducing CI run 30213678367 |
| Fix ([P1-T1]) | `Get-CodexChildGuardLiveBranch` extracted above the dot-source guard; returns `''` when `$LASTEXITCODE -ne 0` **or** the output is null/whitespace; the entrypoint passes the already-trimmed value. Diff confined to the new function plus the entrypoint rewiring; no allow/deny function changed. Root and bundle mirrors byte-identical (`Get-FileHash` match, `git diff --no-index` exit 0). |
| Regression tests ([P1-T2]) | `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1`, 5 cases: empty-output-with-exit-0 (the CI condition), non-zero-exit, trimmed name, `-C` argument pass-through, and an in-process entrypoint case (C5) |
| Pass-after | `FEATURE/evidence/regression-testing/pass-after.2026-07-26T15-17.md` — same payload in a real detached worktree, exit **0**, empty stdout, empty stderr |
| Final gate | `FEATURE/evidence/qa-gates/remediation2-final-poshqc-test.2026-07-26T15-17.md` — all suites green; hook measured at 153/160 = **95.62%** line coverage |

### A1 (Adjacent, deliberate-behavior) — `enforce-epic-planning-only.ps1` exits 2 for a push on a detached HEAD

**Verdict: PASS.**

| Evidence | Artifact / reference |
|---|---|
| RD-1 rationale | A detached HEAD is a legitimate repository state, not a transport failure. Deliberate behavior: git **fails** → keep `throw` → exit 2 (fail closed); git **succeeds with empty output** → `''` → the unmodified decision layer governs (preparation mode denies via the pre-existing `IsNullOrWhiteSpace($CurrentBranch)` check at line 150; dormant mode allows). No decision-function line changed. |
| Fail-before | `FEATURE/evidence/regression-testing/fail-before.2026-07-26T14-37.md` — PUSH payload, exit **2**, stderr `[EPIC_PLANNING_ONLY_BLOCKED: current branch could not be resolved before push.]` |
| Fix ([P2-T1]) | Wrapper `Invoke-EpicPlanningGit` and resolver `Get-EpicPlanningCurrentBranch` inserted above the dot-source guard; entrypoint push block calls the resolver. `Test-EpicPlanningBashAllowed`, `Invoke-EpicPlanningOnlyDecision`, and the staged-paths block are untouched. Root and bundle mirrors byte-identical. |
| Decision-layer cases ([P2-T2]) | 7 cases, including both RD-1 policy mappings locked without live git: preparation + empty branch → deny matching `outside the preparation read, branch, commit, push, or validator allowlist`; dormant + empty branch → `$null` (allow); and git-failure → throws `*current branch could not be resolved*`, preserving exit-2 for genuine transport failure |
| Pass-after | `FEATURE/evidence/regression-testing/pass-after.2026-07-26T15-17.md` — PUSH payload in a real detached worktree, exit **0**, empty stderr; the dormant-allow branch occurred and is identified with its reason (the probe worktree has no checkpoint) |
| Final gate | Hook measured at 126/135 = **93.33%** line coverage |

### S1 (Sweep) — other sites in the defect class

**Verdict: PASS.**

| Evidence | Artifact / reference |
|---|---|
| Sweep | `FEATURE/evidence/other/git-empty-output-sweep.2026-07-26T15-17.md` |

Both mandated greps plus a supplementary `rg -n "& git" .codex` completeness scan. All 8 distinct `& git`
call sites in `.codex` adjudicated, plus the 2 plan-directed sites that neither grep pattern matches:
6 distinct sites **SAFE**, 2 fixed by this plan, **0 new defects**. The FAILED branch was not taken and no
scope expansion occurred. One advisory recorded (`Get-CodexChildGitScalar` in the launch-runtime script
throws an explicit fail-closed message on a detached HEAD, which is not the swept defect class and is not a
PreToolUse hook).

### R-COV (Precedent obligation) — changed production surface absent from the coverage denominator

**Verdict: PASS.**

| Evidence | Artifact / reference |
|---|---|
| Baseline gap (auditable negative record) | `FEATURE/evidence/remediation-baseline/phase0-poshqc-test-authoritative.2026-07-26T14-37.md` — `SearchResult: none` for both filenames by two independent methods |
| Measurement added ([P4-T1]) | Two entries appended to `CodeCoverage.Path` in both `pester.runsettings.psd1` copies; zero deletions; `CoveragePercentTarget` unchanged; copies text-identical (verified three ways, including the [P7-T5] pytest) |
| Gap classification | `FEATURE/evidence/qa-gates/per-file-coverage.2026-07-26T15-17.md` — 83.75% and 86.67% raw; every missed line classified per C6 |
| Gap closure ([P5-T1]) | 31 cases across `codex-worktree-binding-hook.Tests.ps1` (21) and `codex-planning-only-hook.Tests.ps1` (10) |
| Interim | `FEATURE/evidence/qa-gates/per-file-coverage-interim.2026-07-26T15-17.md` |
| Final per-file | `FEATURE/evidence/qa-gates/per-file-coverage-final.2026-07-26T15-17.md` — **95.62%** and **93.33%** raw, both PASS; no C6 residual required; zero exercisable lines uncovered; per-line reason for every non-exercisable claim |
| Comparison | `FEATURE/evidence/qa-gates/remediation2-coverage-comparison.2026-07-26T15-17.md` — repo-wide 94.31% → **94.34%** with a 295-line larger denominator |

The RD-4 honest-failure branch was **not** required: no denominator was shrunk, no threshold lowered, no
file removed from measurement, no assertion weakened, and no analyzer suppression added.

## Complete Evidence Index (Cycle 2)

| Task | Artifact |
|---|---|
| [P0-T1] | `evidence/remediation-baseline/phase0-instructions-read.md` (cycle-2 section + post-rebase re-read section) |
| [P0-T2] | `evidence/remediation-baseline/phase0-git-baseline.2026-07-26T15-17.md` (supersedes the 14-37 pre-rebase record) |
| [P0-T3] | `evidence/remediation-baseline/phase0-poshqc-format.2026-07-26T14-37.md` |
| [P0-T4] | `evidence/remediation-baseline/phase0-poshqc-analyze.2026-07-26T14-37.md` |
| [P0-T5] | `evidence/remediation-baseline/phase0-poshqc-test-mcp.2026-07-26T14-37.md` |
| [P0-T6] | `evidence/remediation-baseline/phase0-poshqc-test-authoritative.2026-07-26T14-37.md` |
| [P0-T7] | `evidence/regression-testing/fail-before.2026-07-26T14-37.md` |
| [P1-T3] | `evidence/other/remediation2-phase1-poshqc-loop.2026-07-26T15-17.md` |
| [P2-T3] | `evidence/other/remediation2-phase2-poshqc-loop.2026-07-26T15-17.md` |
| [P3-T1] | `evidence/regression-testing/pass-after.2026-07-26T15-17.md` |
| [P3-T2] | `evidence/other/git-empty-output-sweep.2026-07-26T15-17.md` |
| [P4-T2] | `evidence/other/remediation2-phase4-poshqc-loop.2026-07-26T15-17.md` |
| [P4-T3] | `evidence/qa-gates/per-file-coverage.2026-07-26T15-17.md` |
| [P5-T2] | `evidence/other/remediation2-phase5-poshqc-loop.2026-07-26T15-17.md` |
| [P5-T3] | `evidence/qa-gates/per-file-coverage-interim.2026-07-26T15-17.md` |
| [P6-T2] | `evidence/other/remediation2-phase6-poshqc-loop.2026-07-26T15-17.md` |
| [P6-T3] | `evidence/qa-gates/per-file-coverage-final.2026-07-26T15-17.md` |
| [P7-T1] | `evidence/qa-gates/remediation2-final-poshqc-format.2026-07-26T15-17.md` |
| [P7-T2] | `evidence/qa-gates/remediation2-final-poshqc-analyze.2026-07-26T15-17.md` |
| [P7-T3] | `evidence/qa-gates/remediation2-final-poshqc-test.2026-07-26T15-17.md` |
| [P7-T4] | `evidence/qa-gates/remediation2-coverage-comparison.2026-07-26T15-17.md` |
| [P7-T5] | `evidence/qa-gates/remediation2-runsettings-parity.2026-07-26T15-17.md` |
| [P7-T6] | `evidence/other/remediation2-scope-verification.2026-07-26T15-17.md` |
| [P7-T7] | this artifact |

All paths resolve under `FEATURE/evidence/<kind>/`. No `artifacts/`-rooted evidence path was used
(Hard Constraint 9, convention C1).

## Hard-Constraint Compliance

| # | Constraint | Result | Where verified |
|---|---|---|---|
| 1 | No file under `.claude/` created, modified, or deleted | **PASS** | [P7-T6](a) — zero `.claude/` paths in the delta or working tree |
| 2 | Config-driven integration test not weakened, skipped, or narrowed | **PASS** | [P7-T3] — `git diff --stat HEAD -- codex-pretooluse-integration.Tests.ps1` empty; suite PASS |
| 3 | `.codex/config.toml` unmodified, unstaged, uncommitted | **PASS** | [P7-T6](c) — three independent diffs all empty |
| 4 | No decision-function logic changes | **PASS** | [P1-T1]/[P2-T1] diffs confined to new resolver functions plus entrypoint rewiring |
| 5 | Root/bundle byte-identity (hooks and runsettings) | **PASS** | [P7-T3] `Get-FileHash` matches; [P7-T5] pytest; parity suites green |
| 6 | No temporary files in committed tests | **PASS** | All stdin via `[System.Console]::SetIn([System.IO.StringReader]...)` with readers restored in `finally`; worktrees used only by non-committed C4 probes |
| 7 | No file over 500 lines | **PASS** | [P7-T3] — 334, 310, 344, 353, 143 |
| 8 | No coverage removal / threshold lowering / denominator shrinkage / assertion weakening / analyzer suppression | **PASS** | [P7-T4]; the [P5-T2] analyzer failure was fixed by renaming, not suppressing |
| 9 | All evidence under `FEATURE/evidence/<kind>/` | **PASS** | Evidence index above |
| 10 | Spec acceptance-criteria text neither unchecked nor edited | **PASS** | [P7-T6](e) — `spec.md` untouched in the cycle-2 delta |
| 11 | PowerShell per-batch cap 3 production / 3 test | **PASS** | P1: 1 prod unit + 1 test; P2: 1 prod unit + 1 test; P4: 2 prod (mirrored psd1 pair) + 0 test; P5: 0 prod + 2 test; P6: 0 + 0 |

## Final Toolchain Status

| Stage | Command | Exit | Result |
|---|---|---|---|
| Format | `mcp__drm-copilot__run_poshqc_format` | 0 | zero files changed (SHA256 before/after across all 9 delta files) |
| Lint | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 findings |
| Type check | n/a | — | not applicable to PowerShell |
| Test (MCP, mandated) | `mcp__drm-copilot__run_poshqc_test` | 0 | pass |
| Test (authoritative CI path) | `Invoke-PoshQCTest -Root <REPO>` | 0 | 1702 passed, 0 failed, 9 skipped |
| Coverage | JaCoCo extraction (C3) | 0 | repo-wide LINE **94.34%**; both changed hooks **95.62%** / **93.33%** |
| Python (runsettings parity) | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` | 0 | 1 passed |

All stages passed in a single uninterrupted pass. TypeScript is out of scope (RD-6): the cycle-2 delta
contains no TypeScript file, so the repository's Vitest → Jest migration (upstream issues #421–#426, landed
by the rebase) imposes no obligation on this plan. That was verified by re-reading
`.claude/rules/general-code-change.md` and `.claude/rules/general-unit-test.md` against the rebased tree at
[P0-T1].

## Cycle-2 Exit-Gate Status

Evidenced **by this plan**:

- **C1 resolved with regression coverage** — fail-before/pass-after probe pair in a real detached worktree,
  plus 12 committed regression cases and 31 gap-closure cases.
- **The PoshQC loop is green** — format (zero changes), analyze (zero findings), and both test paths at
  exit 0 in one pass, with repo-wide line coverage 94.34% and both changed hooks above 85% per-file raw.

Performed **outside this plan** by the orchestrator, per the S9 gate:

- The `blocking_count == 0` re-audit (`feature-review`).
- The green `poshqc / PowerShell QC` check against the **new** PR head SHA on CI, after push. This is the
  gate that originally triggered cycle 2: the defect reproduces only on a detached HEAD, so CI on
  `refs/pull/427/merge` is the authoritative confirmation. The [P3-T1] pass-after probe reproduces that
  exact repository state locally and both hooks now exit 0.

## Verdict

| Finding | Verdict |
|---|---|
| C1 (Blocking) | **PASS** |
| A1 (Adjacent, deliberate-behavior) | **PASS** |
| S1 (Sweep) | **PASS** |
| R-COV (Precedent obligation) | **PASS** |

Every finding verdict is PASS with named artifacts. The [P6-T3] failure branch was not taken. All 31 plan
tasks are complete and checked off. The plan outcome is **not** remediation-required.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md` (work mode
  `full-bug` → `spec.md` only; `user-story.md` absent by default and correctly so)
- Total AC items: **12**
- Checked off (delivered): **12**
- Remaining (unchecked): **0**
- Items remaining: none

All 12 acceptance criteria were already verified and checked off in cycle 1. Cycle 2 neither added,
edited, checked, nor unchecked any AC item; `spec.md` is untouched in the cycle-2 delta ([P7-T6](e)). The
cycle-2 work re-confirms two of them on the detached-HEAD path that cycle 1 could not exercise locally:
`spec.md:262` (every registered handler exits 0 with empty stdout and stderr for a valid safe payload) and
`spec.md:272`–`273` (PoshQC loop clean in a single pass; line coverage >= 85%).

Command: `awk '/^#+ .*Acceptance Criteria/,0' spec.md | grep -n "^- \[ \]"`
EXIT_CODE: 1 (no unchecked AC item found)

Output Summary: All four findings (C1, A1, S1, R-COV) verdict **PASS** with named artifacts on disk. All 31
plan tasks complete. Final toolchain: format exit 0 with zero files changed, analyze exit 0 with zero
findings, MCP test exit 0, authoritative local test exit 0 with 1702 passed / 0 failed / 9 skipped,
repo-wide line coverage **94.34%**, both changed hooks at **95.62%** and **93.33%** raw per-file line
coverage, runsettings-parity pytest 1 passed. All 11 hard constraints hold. All 12 acceptance criteria
remain delivered and unedited. Plan outcome: complete, not remediation-required.

EXIT_CODE: 0
