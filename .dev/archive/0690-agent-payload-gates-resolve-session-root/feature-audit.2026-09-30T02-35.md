# Feature Audit: agent-payload-gates-resolve-session-root (#690)

---

**Audit Date:** 2026-09-30
**Feature Folder:** `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`
**Base Branch:** `main`
**Head Branch:** `bug/agent-payload-gates-resolve-session-root-690`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation pass 1 (prior audit: `feature-audit.2026-09-30T01-45.md`)

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `72d7ebbfda7dc6f1d6c5c321c1d01c00b8e4f8b4`)
- **Head branch/commit:** `bug/agent-payload-gates-resolve-session-root-690` (commit `268d635963e1a2d5f4a4eadb32abbc6b4508d969`)
- **Merge base:** `72d7ebbfda7dc6f1d6c5c321c1d01c00b8e4f8b4` (moved from `91805f15` by merge commit `268d6359`, which brought `origin/main` into the branch)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-30 02:27:26 UTC, head `268d6359`, merge base `72d7ebbf`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same head and range)
  - Feature evidence: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/**` (baseline, remediation-baseline, qa-gates, regression-testing, other)
  - Additional evidence: reviewer-run check-only commands at head `268d6359` (listed below), `artifacts/pester/powershell-coverage.xml` (02:22 UTC, repository PoshQC runsettings), and `artifacts/python/lcov.info` (02:07 UTC)
- **Feature folder used:** `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` line 10 carries the explicit marker `- Work Mode: full-bug`. Under the work-mode contract, `spec.md` is the sole acceptance-criteria source. `user-story.md` maps its scenarios to `spec.md` and does not duplicate the criteria. The `issue.md` early-draft checkboxes are not authoritative in this mode.
- **Scope note:** The audit covers the full branch diff against the merge base (272 files), including the remediation commits `465e1ec5` to `973e8bfc` and the merge `268d6359`. The merge changed no production or test file that the branch changes. Where the merge touched shared files that the branch also changes (both runsettings copies, `core.json`, `invoke-python-engineer` and `parallel-orchestrate` skills and their mirrors), it added main's entries alongside the branch's without removing any. Criterion numbers AC-01 to AC-63 follow the order of `spec.md` `## Acceptance Criteria`. `spec.md` has not changed since the pass-1 audit.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md` — only source (63 checkbox items; 62 checked, 1 unchecked at the start of this audit)

### Acceptance criteria

The criterion text is unchanged from the pass-1 inventory in `feature-audit.2026-09-30T01-45.md` and is not repeated in full here. Groups and numbering:

- Reproduction: AC-01 to AC-03
- Run-resolution module: AC-04 to AC-13
- Preimplementation gate: AC-14 to AC-20
- Epic-scope resolution: AC-21 to AC-23
- Epic wave barrier and parallel cohort barrier: AC-24 to AC-26
- Merge gate: AC-27 to AC-31
- Worktree-removal gates: AC-32 to AC-33
- Parallel drift gate: AC-34
- Import failure (fail-closed): AC-35 to AC-36
- Plain single-worktree regression guards: AC-37 to AC-39
- Identity contract (documented callers): AC-40 to AC-43
- Registration, mirrors, and guard test: AC-44 to AC-48
- Tests and determinism: AC-49 to AC-53
- File size: AC-54 to AC-56
- Rollout safety: AC-57 to AC-60
- Toolchain and follow-ups: AC-61 to AC-63

The one unchecked item, AC-44 (verbatim from `spec.md` line 80): "Each `.claude` file created or changed by this work has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes."

---

## Acceptance Criteria Evaluation

Reviewer runs at head `268d6359` referenced below:
- **RV-PESTER-FULL**: Pester 5 over `tests/scripts/claude-hooks`, `claude-lib`, `claude-runtime`, and `codex-hooks`: 5430 total, 5429 passed, 0 failed, 1 skipped (pre-existing), 217 s. This run includes every added or modified suite, `ClaudeLibModuleConvention.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1`.
- **RV-QC**: `Invoke-Formatter` comparison and `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the 72 added or modified `.ps1`/`.psm1`/`.psd1` files: 0 formatting differences, 0 diagnostics, 0 files over 500 lines.
- **RV-MIRROR**: SHA-256 of each of the 19 added or modified `.claude` files against its bundle mirror: 19 equal, 0 unequal. The two runsettings copies are equal (`cf9fa2f1...`).
- **RV-COV**: parse of `artifacts/pester/powershell-coverage.xml` against `git diff -U0 72d7ebbf HEAD`.
- **RV-PY**: `poetry run pytest -q -rf --no-cov` over the resource-contract, pack-manifest, PoshQC-parity, and parallel-surface suites: 52 passed, 1 failed (the KL-510 node).
- **RV-DIFF**: `git diff --name-only 72d7ebbf...HEAD` path checks (`.codex` 0 files; `*.py` 1 file; protected files 0).

Carried rows: where a criterion's evidence is unchanged since pass 1 and the reviewer's run at the merged head passes, the row cites the pass-1 evidence together with RV-PESTER-FULL.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01 reproduction admitted (preimplementation gate) | PASS | Row R1 asserts `Get-EpicCheckpointContent` invoked once with the `/synthetic-worktrees/w-epic/...` path | RV-PESTER-FULL | Carried |
| 2 | AC-02 reproduction admitted at the wave barrier | PASS | `enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1` (9 rows) | RV-PESTER-FULL | Carried |
| 3 | AC-03 reproduction denied with `TARGET_WORKTREE_NOT_DERIVABLE` in both hooks | PASS | Preimplementation row R2; wave barrier rows W1/W2 | RV-PESTER-FULL | Carried |
| 4 | AC-04 module exists with the five exports | PASS | `Export-ModuleMember` lists the five named functions plus `Get-WorktreeRunCheckpointPath` and `Resolve-WorktreeOperandTarget`; unchanged by remediation | module read | Carried |
| 5 | AC-05 result shape and reason codes via accessors | PASS | Rows X1, C1; B13 asserts `ReasonCode` equals the accessor's NoTarget code | RV-PESTER-FULL | B13 adds evidence |
| 6 | AC-06 signal extraction | PASS | `WorktreeRunResolution.Signal.Tests.ps1` signal rows | RV-PESTER-FULL | Carried |
| 7 | AC-07 epic resolver zero/one/slug-disagreement | PASS | Rows E1-E6 | RV-PESTER-FULL | Carried |
| 8 | AC-08 tie-break and handoff remedy | PASS | Rows E7-E9 | RV-PESTER-FULL | Carried |
| 9 | AC-09 non-matching checkpoint shapes | PASS | Rows E10-E15, R4-R7 | RV-PESTER-FULL | Carried |
| 10 | AC-10 parallel resolver | PASS | Rows R1-R3 | RV-PESTER-FULL | Carried |
| 11 | AC-11 record resolver | PASS | `WorktreeRunResolution.Record.Tests.ps1` (28 rows including B13); CR-1 guard makes an out-of-range `pr_number` resolve `NoTarget` | RV-PESTER-FULL; `git diff c127db6d 973e8bfc -- .claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | UNC case-sensitivity (CR-4) tracked in a potential entry |
| 12 | AC-12 single filesystem read, no subprocess/cwd/clock/env/network | PASS | `Test-Path` (line 115) and `ReadAllText` (line 117) occur only in `Get-WorktreeRunCheckpointText`. The CR-2 stderr write is a stream write, not a filesystem read. No `$env:`, `Get-Date`, `Start-Process`, or location call. AST rows U1-U3 pass | `grep -nE` over the module; RV-PESTER-FULL | Re-verified after CR-2 |
| 13 | AC-13 shared labelling function | PASS | `WorktreeItemResolution.psm1` export change; module calls `ConvertTo-WorktreeItemResolvedResult` | diff read | Carried |
| 14 | AC-14 epic-mode delegation resolution | PASS | `Resolve-OrchestrationGateTarget` epic branch | RV-PESTER-FULL | Carried |
| 15 | AC-15 parallel-mode delegation resolution | PASS | Row R4 | RV-PESTER-FULL | Carried |
| 16 | AC-16 single-feature Agent leg resolution and deny | PASS | Rows R7-R10 | RV-PESTER-FULL | Carried |
| 17 | AC-17 Write/Edit path leg | PASS | `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` (10 rows) | RV-PESTER-FULL | Carried |
| 18 | AC-18 Bash `git -C` leg | PASS | OperandResolution suite | RV-PESTER-FULL | Carried |
| 19 | AC-19 mandatory absolute path on read seams | PASS | `ValidatePattern('^([A-Za-z]:[\\/]|/)')` on all three seams | diff read | Carried |
| 20 | AC-20 injection bypass and existing suites unchanged | PASS | Rows R13-R15; modified preimplementation suites pass | RV-PESTER-FULL | Carried |
| 21 | AC-21 epic-scope checkpoint from resolved root | PASS | `EpicScopeResolution.RunTarget.Tests.ps1` (4 rows) | RV-PESTER-FULL | Carried |
| 22 | AC-22 NoTarget/Ambiguous reasons in epic scope | PASS | RunTarget rows N1-N3 | RV-PESTER-FULL | Carried |
| 23 | AC-23 caller suites pass, caller hooks unedited | PASS | `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1` not in the branch diff; their suites pass | RV-DIFF; RV-PESTER-FULL | Re-verified at the merged head |
| 24 | AC-24 wave barrier conversion | PASS | Changed executable lines 14/14 covered | RV-PESTER-FULL; RV-COV | Carried |
| 25 | AC-25 cohort barrier conversion | PASS | Cohort WorktreeResolution suite; changed lines 14/14 covered | RV-PESTER-FULL; RV-COV | Carried |
| 26 | AC-26 `Find-EpicWaveBarrierFeatureFolderFromPrompt` unchanged | PASS | The function name appears only on diff context lines | `git diff 72d7ebbf...HEAD -- .claude/hooks/enforce-epic-wave-barrier.ps1` | Re-verified against the new merge base |
| 27 | AC-27 merge gate epic branch by PR number | PASS | Merge WorktreeResolution suite (10 rows) | RV-PESTER-FULL | Carried |
| 28 | AC-28 merge gate parallel branch by PR number | PASS | Same suite | RV-PESTER-FULL | Carried |
| 29 | AC-29 child-branch `pr_gate.pr_number` binding | PASS | `Test-ChildCheckpointPrGateBinding` rows | RV-PESTER-FULL | Carried |
| 30 | AC-30 bare merge evaluated at session root | PASS | Gate uses the session worktree when no PR number is present | diff read; RV-PESTER-FULL | Carried |
| 31 | AC-31 unresolved run branches deny with reason code | PASS | `Get-EpicMergeGateUnresolvedReason` prefix | RV-PESTER-FULL | Carried |
| 32 | AC-32 epic removal gate by worktree_path | PASS | Epic removal WorktreeResolution suite (6 rows) | RV-PESTER-FULL | Carried |
| 33 | AC-33 parallel removal gate by worktree_path | PASS | Parallel removal WorktreeResolution suite (6 rows) | RV-PESTER-FULL | Carried |
| 34 | AC-34 drift gate conversion | PASS | Drift WorktreeResolution suite (6 rows) | RV-PESTER-FULL | Carried |
| 35 | AC-35 import-failure fail-closed per gate | PASS | Rows O7-O8, W7, C5, M10, V6, Y6, D6 | RV-PESTER-FULL | Carried |
| 36 | AC-36 potential entry for pre-existing imports | PASS | `docs/features/potential/2026-09-29-hook-preexisting-imports-fail-open.md` | RV-DIFF | Carried |
| 37 | AC-37 plain single-worktree Write/Edit/Bash unchanged | PASS | Rows R11-R12 and OperandResolution session rows | RV-PESTER-FULL | Carried |
| 38 | AC-38 session-root-only kickoff unchanged | PASS | Row R11, wave W5-W6, cohort C4 | RV-PESTER-FULL | Carried |
| 39 | AC-39 no session-root-first fast path | PASS | Row R12 | RV-PESTER-FULL | Carried |
| 40 | AC-40 orchestrate skill contract | PASS | Added paragraph in `.claude/skills/orchestrate/SKILL.md` | `git diff 72d7ebbf...HEAD -- .claude/skills/` | Carried |
| 41 | AC-41 epic and parallel skill contract | PASS | Paragraphs in `epic-orchestrate` and `parallel-orchestrate`. The merge added main's `parallel-orchestrate` changes alongside them, and the branch paragraph remains in the diff. The parallel-surface contract suite passes (RV-PY) | same; RV-PY | Re-verified at the merged head |
| 42 | AC-42 invoke-*-engineer contract | PASS | `## Delegation Identity Lines` in the Python, PowerShell, and C# invoke skills | same | Carried; no `invoke-typescript-engineer` skill exists |
| 43 | AC-43 contract text before gate wiring | PASS | Commit `0dcb1cf5` precedes `25069b47` | `git log --oneline 72d7ebbf..HEAD` | Carried |
| 44 | AC-44 mirrors byte-identical and bundle contract test passes | UNVERIFIED | Mirror half verified at the merged head (RV-MIRROR 19/19). The named node fails locally with `Repo file missing from bundle: .claude\state\current-session-id`. That path is gitignored host session state, and the node failed identically at baseline and in every run since (KL-510, issue #510). No PR and no CI run exist for the branch (`gh run list` returned an empty list) | RV-MIRROR; RV-PY | Requires a green CI run on the PR head. Left unchecked. No branch change can close it |
| 45 | AC-45 core.json registration | PASS | `WorktreeRunResolution.psm1` count 1; each new `-resolution.ps1` sibling count 1 (after the merge) | `grep -c` on `pack-manifests/core.json` | Re-verified at the merged head |
| 46 | AC-46 manifest test | PASS | `WorktreeResolution.Manifest.Tests.ps1` 19/19 (`remediation-size-mirror.2026-09-30T02-24.md`); passes in RV-PESTER-FULL | RV-PESTER-FULL | |
| 47 | AC-47 runsettings entries and parity | PASS | Entries at lines 48, 51, 325 of the repository copy; both copies hash-equal after the merge | RV-MIRROR | Re-verified at the merged head |
| 48 | AC-48 isolation guard extension | PASS | Guard extended to `Get-WorktreeRunCheckpointText`; suite passes | RV-PESTER-FULL | Carried |
| 49 | AC-49 per-gate other-worktree / NoTarget / Ambiguous rows | PASS | Eight gate WorktreeResolution suites pass | RV-PESTER-FULL | Carried |
| 50 | AC-50 no file-writing tests, no `TestDrive:` | PASS | B13 and T4 create no file. T4 routes `ReadAllText` to an existing directory through a mocked `Test-Path`. Added test lines contain no `TestDrive`, file-writing cmdlet, sleep, or `$env:` | `git diff c127db6d 973e8bfc -- tests/` read | Re-verified for remediation rows |
| 51 | AC-51 default seam mocks, existing rows pass | PASS | Four trees 5429/5430 with 0 failures | RV-PESTER-FULL | |
| 52 | AC-52 WRR coverage >= 85% and no changed-line regression | PASS | Canonical artifact: WRR 149/149 = 100%. The 10 modified production files are at 92.86%-100%, each at or above its baseline. Changed-line coverage 93.94%-100%. Remediation changed lines 5/5 | RV-COV; `evidence/qa-gates/powershell-coverage-artifact.2026-09-30T02-23.md` | Pass-1 gap G-2 closed: the figure now comes from the canonical artifact |
| 53 | AC-53 module convention and no-Python scan | PASS | Both suites run in RV-PESTER-FULL and pass | RV-PESTER-FULL | |
| 54 | AC-54 two files byte-unchanged | PASS | `WorktreeResolution.psm1` and `enforce-orchestration-preimplementation-gate-helpers.ps1` not in the branch diff | RV-DIFF | Re-verified against the new merge base |
| 55 | AC-55 500-line limit | PASS | 0 of 72 PowerShell files over 500; maximum 497 (`WorktreeRunResolution.psm1` and one test suite) | RV-QC | 3-line headroom noted in code review CR-11 |
| 56 | AC-56 modes file gains no parsing; glue in epic-scope sibling | PASS | `enforce-orchestration-preimplementation-gate-modes.ps1` not in the diff | RV-DIFF | Carried |
| 57 | AC-57 module commit changes no hook | PASS | `d120a539` touches 0 files under `hooks/` | `git show --name-only --format= d120a539` | Carried |
| 58 | AC-58 single-Write wiring and recorded order | PASS | `evidence/qa-gates/gate-wiring-order.md`. The remediation live writes followed the same procedure (`cr1-write.2026-09-30T02-10.md`, `cr2-write.2026-09-30T02-12.md`) | file read | The write method is attested by executor records; the reviewer cannot observe tool calls |
| 59 | AC-59 pending delegation identity confirmed | PASS | `evidence/qa-gates/pending-delegation-identity.2026-09-29T23-42.md` | file read | Carried |
| 60 | AC-60 gate commits include siblings and mirrors | PASS | Each gate commit carries hook, sibling, and mirrors. Remediation commits `197cacfa` and `5e783d51` carry WRR and its mirror together | `git show --name-only` per commit | |
| 61 | AC-61 PowerShell toolchain single pass | PASS | `remediation-format.2026-09-30T02-24.md` (ChangedCount=0, hashes equal, clean tree), `remediation-analyze.2026-09-30T02-24.md` (0), canonical PoshQC run 0 failures; reviewer RV-QC and RV-PESTER-FULL reproduce a clean pass at the merged head | RV-QC; RV-PESTER-FULL | |
| 62 | AC-62 no `.codex` change; only the pin among Python files | PASS | `.codex` 0 files in the branch diff; the only `.py` file is `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; `validate-orchestrator-output.ps1` not in the diff | RV-DIFF | Re-verified against the new merge base; criterion amended 2026-09-30 per the spec Change Log |
| 63 | AC-63 potential entries for follow-ups | PASS | `2026-09-29-validate-orchestrator-output-session-relative-read.md` and `2026-09-29-merge-gate-child-branch-without-pr-gate.md` present | RV-DIFF | Carried |

---

## Summary

**Overall Feature Readiness:** PASS

62 of 63 criteria pass on evidence verified at head `268d6359`. Every remediation item from pass 1 is closed: the Python coverage artifact exists (93.11% lines, 85.92% branches), the canonical PowerShell artifact includes the three new files, and CR-1 and CR-2 are fixed with tests shown failing before each fix. The one criterion not yet verified is AC-44. Its only open half is a CI result for a test node that fails locally because of gitignored host state, and no PR or CI run exists yet. No criterion is PARTIAL or FAIL, so remediation is not triggered. The PASS verdict depends on AC-44 being confirmed by the CI run on the PR head, which is also the normal pre-merge gate.

**Criteria summary:**
- **PASS:** 62 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-44: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` needs a green CI run on the PR head (issue #510 pattern). This is not a branch defect.

**Recommended follow-up verification steps:**

1. After the PR is opened, read the CI result for `test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the head SHA, record it in `evidence/qa-gates/ci-bundle-contract.<timestamp>.md`, and check off AC-44 in `spec.md`.
2. Do not delete or modify `.claude/state/current-session-id` to force a local pass.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md`
- Total AC items: 63
- Checked off (delivered): 62
- Remaining (unchecked): 1
- Items remaining: AC-44 "Each `.claude` file created or changed by this work has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 63 | 62 | 1 | Checkbox-backed; authoritative for `full-bug` |
| `issue.md` | 4 (early draft) | 4 | 0 | Not authoritative in `full-bug` mode; not evaluated here |

No source-file checkbox change was made in this review. Every criterion evaluated PASS was already checked (`evidence/other/ac-checkoff.2026-09-30T01-37.md`), and AC-44 remains unchecked because it is UNVERIFIED.
