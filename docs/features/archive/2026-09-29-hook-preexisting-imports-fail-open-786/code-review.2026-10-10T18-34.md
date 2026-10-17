# Code Review: Hook pre-existing imports fail open (#786, bundled #792)

---

**Review Date:** 2026-10-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue 786.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (merge base `86e457a003be0c60b65e01156e4cccd6495dfd1a`, equal to the base tip)
**Head Branch:** `bug/hook-preexisting-imports-fail-open-exec-786` at `5f919f2dc`
**Review Type:** Re-review at the exit of remediation cycle 1 (prior review `code-review.2026-10-10T06-50.md`)

---

## Executive Summary

The production change set is unchanged since the 06-50 review: no file under `.claude/`, `.codex/`, or `extensions/` changed in remediation cycle 1 (`git diff 76559b6df HEAD --stat` lists only feature-folder documents and one test file). The cycle added one assertion to `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1`, amended AC-6 through a Change Log entry, and resolved the coverage finding through a diagnosis and a recorded measurement-route decision.

The 06-50 Blocker (Codex coverage in the combined run) is resolved by the AC-24 per-surface route, which this review accepts on the evidence (see "Assessment of the AC-24 per-surface decision"). The 06-50 Major (AC-6 for the exempt edges) is resolved by the AC-6 amendment. The H8 Minor (missing leading-token assertion) is resolved. Remaining items are Minor, Nit, and Info.

**What changed in cycle 1:**
Test: one added line at `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1:248`. Documents: `spec.md` (AC-6 amendment, Change Log 2026-10-10, AC-6 and AC-24 check-offs), remediation plan, and 37 new or re-recorded evidence files.

**Top 3 risks:**
1. The standard combined Pester run still reports four changed Codex files below 85% and five below baseline; AC-24 is met on a per-surface route. A later reviewer who reads only the combined artifact can reach the opposite conclusion unless the decision travels with the PR.
2. The Pester attribution cause is not identified; the same loss may affect other Codex hook files touched by later branches.
3. The H8 conversion changes the block token to `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and broadens the block to every orchestrator artifact type; this is now asserted and documented, but consumers of the old token are not enumerated.

**PR readiness recommendation:** **Ready** — no Blocker or Major findings remain; carry the cycle-1 PR-body notes into the PR description.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversions.md` | last line | The line `AC-6 GAP: named-exemption edges H1, H4, H5, H6 ... the 2026-10-09 amendment did not extend to AC-6` remains after the 2026-10-10 AC-6 amendment and reads as an open gap. | Append a resolution note that cites the Change Log 2026-10-10 entry and `r1-ac6-verify.md`, or remove the line. | Evidence files should not contradict the current AC text. | `git diff 76559b6df HEAD -- .../handler-conversions.md` changes only the `:246` row. |
| Minor | `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/r1-coverage-diagnosis.md` | whole file; `## Verdict` | The file is 4.7 MB (60,888 lines) of probe output committed to the repository. Its `## Verdict` records `Timestamp: 2026-10-10T18-55`, which is later than the halt commit `f40d403fa` (16-35) that recorded the verdict and later than this review's start (18-34). | Keep the verdict, culprit, and per-file summary lines and move the raw probe listings out of the committed file, or document why the full listing is retained; correct the verdict timestamp. | Repository size and evidence timestamp consistency. The verdict content agrees with `blocked-state.md` and `r1-ac24-decision.md`, so the timestamp defect does not change any conclusion. | `ls -la`; `git log --date=format:%Y-%m-%dT%H-%M`. |
| Minor | `.claude/hooks/validate-orchestrator-output.ps1` | lines 51 and 59 | Carried from 06-50: `OrchestratorState.psm1` is imported twice (once without and once with `-Global`). The cycle-1 E4 trial removed line 51 and showed no effect on the coverage loss, so the duplicate has no coverage role. | Remove the non-`-Global` import in a follow-up and mirror the change. | Duplicate `-Force` imports reload the module and add ambiguity about which instance tests mock. | `r1-coverage-diagnosis.md` (E4-LINE51, E4-LINE59, trial `h2-trial-c1-E4`). |
| Minor | `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H8.md` | proof record | Carried from 06-50: the H8 proof row did not reach the epic leg at proof time; the CONVERT decision rests on the cited exit-1 tail. The record does not state this. | Add one sentence stating that the decision rests on the cited code path. | Proof evidence should state which leg it exercised. | 06-50 review. |
| Nit | `.claude/hooks/enforce-epic-wave-barrier.ps1`, `enforce-parallel-drift-gate.ps1`, `enforce-parallel-cohort-barrier.ps1` | H4 to H6 catch blocks | Carried: always-true `if (-not $script:<Name>ResolutionImportFailure)` and a stale comment after the #690 migration. | Simplify when the exemption terms allow edits to the handler text. | Dead conditional. | File inspection (06-50). |
| Nit | `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | lines 453, 468 | Carried: `finally` resets two variables that no longer exist in production. | Remove the stale resets. | Dead cleanup. | File inspection (06-50). |
| Info | `.codex/hooks/enforce-epic-child-worktree-binding.ps1`, `enforce-epic-planning-only.ps1`, `hook-dependency-guard.ps1`, `validate-bash.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1` | coverage | Combined-run figures 74.70, 82.25, 57.89, 80.25, 86.55, 98.09; per-surface 95.78, 95.86, 100.00, 100.00, 100.00, 98.73; BASE per-surface 95.62, 95.71, new, 100.00, 100.00, 98.68. | Record a potential issue for the Pester attribution loss (reproducer `List(234, 42)` and the culprit pair) so that it can be investigated independently of this feature. | The cause is unidentified and can recur. | `r1-ac24-per-surface.md`; `final-pester-coverage.md`; `r1-coverage-diagnosis.md` `## Verdict`. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | whole file | Carried: exactly 500 lines (and mirror); no headroom. | Extract a sibling before any further addition. | 500-line cap. | Reviewer `wc -l`. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | Last written 18:18 by the MCP route; no helper entries. Values for the PS-SET Codex hooks match the combined-run evidence. | None required; the per-file record of record is in `evidence/qa-gates/`. | Source currency. | Reviewer parse (`cov.py`). |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Cycle 1 made no production change, as the remediation plan's rule 10 required when the diagnosis reached `VERDICT: measurement artifact`. Formatting, analysis, mirror parity, and the full test run remain green on the unchanged production set (`r1-final-qc-loop.md`, pass 1).
- The H12 row of `validate-orchestrator-output.WaveBarrier.Tests.ps1` now asserts `$result.Reason.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal)`. The prefix equals the `-ReasonPrefix` that `.claude/hooks/validate-orchestrator-output.ps1:347` passes to the helper. The suite passes 13/13 and the isolation guard (AC-4, AC-6 rows) passes for the suite (`r1-h8-assertion.md`). `handler-conversions.md` records the added assertion in the `:246` row, so the converted-handler assertion inventory is seven changed lines carrying eight assertions (two resets, five changed assertions, and the added token assertion).

#### Assessment of the AC-24 per-surface decision

- **Diagnosis quality.** The H2 hosting reproduces the R-PESTER invocation (`Invoke-PoshQCTest` with its default Pester and trampoline seams), and `POPULATION-MATCH` and `HOSTING-PARITY: yes` confirm the same coverage population (192 files). R-VALID compares pass and fail counts for all 61 Codex containers across runs (0 mismatches), so the loss predicate compares runs that executed the same tests with the same outcomes. The two-stage bisection isolated two culprit containers that each are necessary (`LOSS-WITHOUT=no`), neither creates a module instance (census), and module and function cleanup at the insertion point does not remove the loss. One culprit parses hook files with the AST and executes none; the other reads one workflow YAML file. Lines executed by the Codex suites lose attribution only when unrelated containers run around them; adding containers cannot remove executed lines, so this is an attribution loss, not a test gap.
- **Limits of the diagnosis.** The bisection predicate is a single yes or no over all T-SET files, so it isolates the first contributor only; containers 235 to 238 contribute further loss on four files (recorded in the verdict observations). The Pester-internal mechanism is not identified (`MECHANISM: other`).
- **Measurement soundness.** The per-surface XML is produced by the same R-PESTER hosting and coverage population, with only the container list changed (`r1-ac24-per-surface.md` (a), (d); `BASE-HOSTING-IDENTICAL: yes`). The BASE comparison runs the BASE tree's 52 Codex suites over the BASE extraction at `86e457a0`, which is the same scope, so the no-regression comparison is like for like. The current-tree run was repeated after the cycle's test edit ([P5-T4] pass 1: 61 containers, 1652 passed, `PER-SURFACE-RESULT: pass`). The judged changed lines (PAIRING-RULE) are all covered for all six PS-SET files. PoshQC configuration, thresholds, exclusions, and the gate run are unchanged (`git diff 86e457a0 HEAD -- scripts/powershell/PoshQC config/poshqc-*.json` empty).
- **Conclusion.** The decision satisfies the text of AC-24 ("measured per file from the Pester coverage XML"; "no changed line loses coverage") and the Coverage Exclusion Policy (no production file is excluded). It does not lower the uniform threshold. The combined-run figures are retained and reported next to the per-surface figures.

#### Error handling and logging

- Unchanged from the 06-50 review. H1 to H6 remain fail-closed named exemptions; H7 and H8 are converted to the helper with exit 2 on SubagentStop.

---

## Test Quality Audit

The combined Pester run passes (9495 passed, 0 failed, JUnit 9505 with 10 pre-existing skips). The B1 suite passes 139/139, and the filtered H1/H4/H5/H6 FailClosed rows pass 10/10 (`r1-ac6-verify.md`). The isolation guard passes 315/315.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1` — one added leading-token assertion in H12; 250 lines.
- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:24-30` — B1 excludes, per handler file, only the leaf listed by `Get-HookImportFailureExemption` (`feature-folder-resolution.ps1`), so the AC-6 exception covers exactly the amended edges.
- `evidence/qa-gates/r1-ac24-per-surface.md` — per-surface and BASE per-surface values, changed-line pairing, combined-run figures.
- `evidence/qa-gates/coverage-comparison.md` — 57 files; the `.claude/hooks/validate-orchestrator-output-resolution.ps1` baseline row is now recorded (98.96 -> 98.94, missed 1 -> 1).
- `evidence/qa-gates/r1-preexisting-tests.md`, `r1-ac17-confirm.md` — AC-17 unchanged (SHA-256 equal to the [P0-T2] value) and AC17-RESULT pass.

### Quality assessment prompts

- **Determinism:** pass and fail results are identical across the combined and per-surface runs for the Codex containers; attribution depends on container order.
- **Isolation:** unchanged; the new assertion lives in an existing row.
- **Speed:** about 56 ms per test.
- **Diagnostics:** the new assertion carries `-Because $result.Reason`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Cycle-1 diff contains documentation and one test line. |
| No unsafe subprocess or command construction | ✅ PASS | No production change; no Python invocation in hooks (reviewer grep). |
| Input validation at boundaries | ✅ PASS | Dependency check precedes payload parsing for every non-exempt edge; exempt edges are covered by fail-closed proofs. |
| Error handling remains explicit | ✅ PASS | Unchanged. |
| Configuration / path handling is safe | ✅ PASS | Registrations in `.claude/settings.json` and `.codex/config.toml` unchanged. |
| Fail-closed on dependency failure | ✅ PASS | Every dependency failure denies or blocks; the AC-6 exception is limited to the four exempt edges with recorded proofs. |

---

## Research Log

No external research was required. Coverage behaviour was assessed from the recorded probe evidence; the Pester-internal mechanism was not investigated by this review.

---

## Verdict

The branch delivers fail-closed dependency handling for every registered PreToolUse and SubagentStop hook on both surfaces, and the cycle-1 remediation closes both blocking findings of the 06-50 review without production changes. The AC-24 per-surface route is supported by a reproducible diagnosis and like-for-like BASE comparison. Remaining findings are Minor, Nit, or Info and do not block merge. Recommended: carry `evidence/other/r1-pr-body-notes.md` and the `handler-conversions.md` PR-BODY-NOTE into the PR description, and record a potential issue for the Pester attribution loss.
