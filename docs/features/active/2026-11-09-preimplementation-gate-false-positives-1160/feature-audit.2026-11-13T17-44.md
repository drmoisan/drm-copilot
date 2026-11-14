# Feature Audit: Pre-Implementation Gate False Positives (Issue #1160)

**Audit Date:** 2026-11-13
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `4767fe8a35e9a1b8f404ff827f009098b7ed9855` (PR #1174)
**Base:** `main`; merge base `18520b3fce8b6273ac63a16fef03816f7119dcad`

## Scope and Baseline

- Scope: the full branch diff `18520b3fc..4767fe8a3`, 56 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated at this head) and direct `git diff`.
- Baseline: the merge base on `main`, a `git archive` copy of its hook files for behavior comparison, and the Phase 0 artifacts `evidence/baseline/pester-gate.2026-11-10T04-19.md`, `powershell-static.2026-11-10T03-40.md`, and `contract-tests.2026-11-10T03-44.md`.
- Requirements source and work mode: `issue.md` marker `Work Mode: full-bug`, so the AC source is `spec.md` `## Acceptance Criteria` only.
- Review mode: concurrent; CI on PR #1174 runs alongside this review.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Source |
|---|---|---|
| AC-1 | Section 6.3 false-positive rows unclassified on both surfaces, with fail-before evidence | `spec.md` |
| AC-2 | Every existing denial (6.2 rows, D15 amended) classified with byte-equal deny text on both surfaces | `spec.md` |
| AC-3 | Classification never widened; D2 non-goals unclassified; stage 2 only after a stage-1 hit | `spec.md` |
| AC-4 | Stage-2 fallbacks fail closed (Unbalanced, Opaque, evaluator, `rg --pre`, `git -O`, `ForEach-Object`, `find`, `::`, `.Invoke`) | `spec.md` |
| AC-5 | Mention-host table getter returns exactly the D2 table | `spec.md` |
| AC-6 | Agent-memory staging and committing allow with no checkpoint and default configuration | `spec.md` |
| AC-7 | Mixed bookkeeping forms per D5 as amended by D14 | `spec.md` |
| AC-8 | Non-exempt and unsafe staging still denies with unchanged text | `spec.md` |
| AC-9 | #539 exemption suites pass without modification | `spec.md` |
| AC-10 | Configuration absent: seam returns null, default root applies | `spec.md` |
| AC-11 | Configuration `[]` disables the leg with no suffix | `spec.md` |
| AC-12 | Invalid configuration disables the leg and appends the suffix after the cleanup suffix | `spec.md` |
| AC-13 | Unparseable commands keep fail-closed behavior and text | `spec.md` |
| AC-14 | Claude and Codex parity; `$script:SharedGateFunction` unchanged | `spec.md` |
| AC-15 | Four-copy SHA256 identity and fewer than 500 lines for both siblings | `spec.md` |
| AC-16 | Guarded loading of both siblings | `spec.md` |
| AC-17 | Existing gate suites pass without modification in the parallel gate | `spec.md` |
| AC-18 | Protected files unchanged; no `config/preimplementation-gate.json` | `spec.md` |
| AC-19 | Push-down consistency, manifests, contract tests, generator check | `spec.md` |
| AC-20 | Documentation in six brief copies, two orchestrate copies, and file headers | `spec.md` |
| AC-21 | No Python in the hook path | `spec.md` |
| AC-22 | New siblings at least 90% line coverage; changed gate lines not below baseline | `spec.md` |
| AC-23 | Test hygiene: seams mocked, no temporary files, leak scan clean | `spec.md` |
| AC-24 | CI green on the PR head (CI-dependent) | `spec.md` |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC-1 | PASS | FP-01 to FP-17 pass in both runners (`evidence/qa-gates/pester-gate.2026-11-13T17-27.md`, 128 tests each); fail-before `evidence/regression-testing/fail-before-classification.2026-11-11T04-52.md` shows exactly the 68 FP tests failing on the unfixed gates. Reviewer probes confirm `ps aux | grep pytest`, `Get-Process -Name pytest`, `rg pytest`, `echo git add docs`, and the FP-16 form return false on both surfaces. |
| AC-2 | PASS | ED-01 to ED-42 pass in both runners with byte-equal deny text. The listed rows are preserved. F1 concerns forms outside the listed 6.2 rows. |
| AC-3 | PASS | NG rows pass; stage-1-miss case in `-commands.Tests.ps1`; the call site invokes stage 2 only after a stage-1 hit, so the classified set is a subset of the base set. |
| AC-4 | PASS | Named fallback cases in `-commands.Tests.ps1` (71 tests, 0 failed); reviewer probes `rg --pre pytest foo`, `git log --grep pytest -O`, `find ... -exec black`, and `echo pytest | bash` return true. |
| AC-5 | PASS | Pin test of `Get-OrchestrationGateMentionHostTable`; reviewer reading of the getter matches the D2 table. |
| AC-6 | PASS | Allow rows in both leg suites; reviewer real-process probe of the shipped Claude gate in a scratch repository with no checkpoint: agent-memory `git add`, pathless `git commit -m` with an agent-memory-only index, and `git commit -F msg.txt -- <agent-memory path>` allow. |
| AC-7 | PASS | D5/D14 rows in `.BookkeepingLeg.Tests.ps1` (46) and `-bookkeeping-leg.Tests.ps1` (47), 0 failed. |
| AC-8 | PASS | Deny rows in both leg suites; reviewer real-process probe: `git add src/x.py` and a pathless commit with a mixed index deny with the unchanged text. |
| AC-9 | PASS | The three named suites are absent from the diff (all test paths in the diff are additions) and pass: 120, 60, and 61 tests. |
| AC-10 | PASS | Mocked-seam cases in `-bookkeeping.Tests.ps1` (126, 0 failed); the seam resolves `config/preimplementation-gate.json` from `$PSScriptRoot` with `Join-Path`. |
| AC-11 | PASS | `[]` rows in both leg suites; reviewer real-process probe with `[]` denies with no suffix. |
| AC-12 | PASS | Parser cases and suffix-ordering rows; reviewer real-process probe with a non-array `bookkeeping_roots` denies. |
| AC-13 | PASS | Unbalanced ED rows and the unbalanced leg row pass on both surfaces. |
| AC-14 | PASS | Both runners pass the same corpus; `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` is absent from the diff; `.Parity.Tests.ps1` passes (93). Reviewer comparison of 28 probe commands: identical decisions on both surfaces. |
| AC-15 | PASS | Reviewer `sha256sum`: one digest per sibling across four copies; logical lines 196 and 290. Parity suites pass (2 each). |
| AC-16 | PASS | Both gates carry the guarded `try { . ... } catch { Add-HookDependencyFailure ... }` lines; `hook-dependency-guard-completeness.Tests.ps1` (731), `hook-dependency-failure.Claude.Tests.ps1` (228), `hook-dependency-failure.Codex.Tests.ps1` (104) pass. |
| AC-17 | PASS | Every listed suite passes, none modified (`evidence/qa-gates/pester-gate.2026-11-13T17-27.md`). |
| AC-18 | PASS | Reviewer name-status diff against the merge base lists no protected file; `config/preimplementation-gate.json` is absent. |
| AC-19 | PASS | Reviewer `cmp`: both gate files equal their bundle copies; both manifests list both siblings; contract files 68 passed and generator check exit 0 (`evidence/qa-gates/contract-and-scope.2026-11-13T17-29.md`). |
| AC-20 | PASS | Reviewer diff: the bullet is present and identical in all six brief copies; the orchestrate paragraph is present and the bundle is byte-identical; gate and sibling headers describe the change. |
| AC-21 | PASS | No `.py` file in the diff; interpreter search recorded in `evidence/qa-gates/contract-and-scope.2026-11-13T17-29.md` (0 invocations). |
| AC-22 | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: commands sibling 98.68% (both copies), bookkeeping sibling 100.00% (both copies); changed gate lines 9 of 9 on each surface. Figures recorded under `evidence/qa-gates/` with the canonical-location override (code review N4). |
| AC-23 | PASS | Leak scan 0 failures; 0 temporary-file API matches in the new suites; both seams mocked in leg cases. |
| AC-24 | PENDING-CI | `gh pr checks 1174` at 17:44 UTC: PowerShell QC shards, hook suites, static, and `quality-checks7` pending; build, docs validation, extension tests passed. Not a blocking finding; checked off at S9 by the item's orchestrator run. |

## Findings Outside the Criterion Text

- F1 (blocking, related to issue #1160, autonomous, design scope): stage 2 judges each pipeline record alone, so a mention host whose output is piped into an executing consumer (`ForEach-Object { & $_ }`, `% { & $_ }`, `xargs env`) is no longer classified. Seven reviewer-probed forms are classified by the merge-base gate and unclassified at head on both surfaces. The issue's requirement is to classify only real invocations; these are real invocations. Detail in `code-review.2026-11-13T17-44.md` and `remediation-inputs.2026-11-13T17-44.md`.
- No finding unrelated to issue #1160 was identified.

## Summary

23 PASS, 1 pending CI, 0 FAIL. One blocking design finding outside the criterion text.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/spec.md`
- Total AC items: 24
- Checked off (delivered): 23
- Remaining (unchecked): 1
- Items remaining: AC-24 (CI-dependent): CI is green on the PR head.

## Acceptance Criteria Check-off

AC-1 to AC-23 were already checked in `spec.md` by the executor with evidence; this review confirms each as PASS and makes no new check-off. AC-24 stays unchecked as pending CI. No item was unchecked. A remediation of F1 that amends D2 must re-verify AC-1 to AC-4 and AC-14.
