# Code Review: Preimplementation gate classifies wrapped shell and PowerShell payloads, and adds the DEV-R3 rows (#1195), review at head ebacd29f1

---

**Review Date:** 2026-11-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195`
**Feature Folder Selection Rule:** named by the caller; matches the issue number in `issue.md` and the branch `bug/gate-wrapped-shell-test-commands`
**Base Branch:** `main` (merge base `b58f045bc58d237129963543e445c7c8d2987772`, equal to `origin/main` after `git fetch`)
**Head Branch:** `bug/gate-wrapped-shell-test-commands` at `ebacd29f19918dcced5caedefe91ecf7316a85a8` (PR #1196)
**Review Type:** First review, concurrent with CI on the head

---

## Executive Summary

The branch changes 58 files: the classify sibling in four byte-identical copies (+91/-1 each), one line in each gate and its bundle copy, four test files, six byte-identical brief copies, and the feature folder. `git merge-tree --write-tree origin/main HEAD` exits 0 and `origin/main` equals the merge base, so there is no base drift.

Evidence reviewed: the PR context summary (generated 2026-11-16 02:06:53 UTC at the reviewed head), the full diff, blob-hash identity of every mirror set, the executor's phase-gate, final-gate, fail-before, mutant-probe, scope, and contract evidence, the coverage report of the final gate, a reviewer scoped Pester run (283 passed, 0 failed), and three reviewer real-process probes (classification of 28 additional commands at the head and at a base-equivalent, the N2/N5/N6/N7 mutant probe, and a seven-mutant probe of the new function).

Specific checks requested by the caller, all verified:

- Every new stage-1 hit is confirmed by stage 2: the new indexes (1 to 4, never 0) join `$supplementalIndex`, and the unchanged loop calls `Test-OrchestrationGateInvocationConfirmed` for every non-structural index. Probes `sh -c "grep pytest docs"`, `sh -c "rg pytest docs"`, `sh -c "cat docs/pytest.md"`, `sh -c "which pytest"`, and `sh -c "echo pytest"` return false at the head.
- No existing classification row changed disposition: no existing Cases row text or expected value changed; the full final gate passed with 0 failures.
- The cycle-3 guards are byte-unchanged: the classify diff has two hunks, the help block and a pure append after the last line of `Get-OrchestrationGateSupplementalPatternIndex`.
- Four classify copies share blob `e9f0ed763`; Claude gate and bundle share `c662f90d7`; Codex gate and bundle share `5cdfc408e`; six brief copies share `93ca58a0c`.
- Codex gate logical line count is 485 at the merge base and the head.
- D18 exclusions are pinned by Negative rows: `sh -c "$CMD"`, `CMD=pytest; sh -c "$CMD"`, `pwsh -EncodedCommand cAB5AHQAZQBzAHQA`, `sh -c "$(cat cmd.txt)"`, `env -S "sh -c 'pytest'"`.
- The six DEV-R3 rows are present; the reviewer's in-memory rerun gives control 0, N2 2, N5 1, N6 3, N7 1 failed rows, identical to the evidence.
- Classify coverage is 96/96 on both surfaces with no zero-hit line.
- Evidence is append-only (no modify, delete, or rename commit in the evidence folder), stamps precede the adding commits, and no evidence names an absolute path.

**Top 3 risks:**
1. A combination of prefixes in which `env` with a value option follows another transparent prefix (`timeout 60 env -u X sh -c "pytest"`) is not classified, while the bare analogue is. Low impact; see Findings.
2. Hooks fired for isolated subagents use the default branch scripts, so the change reaches them only after merge (spec rollout section).
3. CI on the PR head is pending; the identical non-documentation tree passed in run `43788266034`.

**PR readiness recommendation:** **Go**, on the green CI of PR #1196.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` (and its three copies) | `Get-OrchestrationGateWrapperPayloadText`, env loop | The local env value-option handling runs only at the head of the segment. When `env -u NAME` follows another transparent prefix, `Skip-CommandLineTransparentWrapper` reads `NAME` as the command word and no payload is found: `timeout 60 env -u X sh -c "pytest"` returns false, while `timeout 60 env -u X pytest` is classified by the raw scan. `env -u X timeout 60 sh -c "pytest"` is unaffected. | No change required for this item. If a later change touches this helper, apply the env option skip after each transparent prefix. | The spec lists each prefix individually and every listed form is covered; this ordering is not enumerated and is uncommon. The gap is an allow-side miss of the same kind the item closes, not a false denial. | Reviewer real-process probe at the head and at a base-equivalent session |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | `Get-OrchestrationGateWrapperPayloadText`, `$hops -lt 8` | The xargs re-examination bound of 8 hops carries no comment. | Optional: name the bound or add a one-line reason. | Readability only; the loop terminates on every path. | Diff inspection |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | wrapper set | `find ... -exec sh -c 'pytest' \;` and `cmd /c "pytest"` stay unclassified. | No change. | `find -exec` and `cmd` are outside the spec wrapper list; `cmd /c` is a recorded non-goal pinned by a Negative row. | Reviewer probe |
| Info | process | AD-1 in the PR body | An extra planner revision was applied after the confirming preflight returned two substantive defects, instead of halting with `validator_failed`. | None. | Judged acceptable: OD-1 directs decisions over halts, an extra planner revision is an honorable class, no gate was bypassed, and the execution delegation opened with a preflight that found no defect before `[P0-T1]`. The decision is recorded in the PR body. | PR #1196 body; `evidence/other/preflight-fixes.2026-11-15T23-02.md` |
| Info | `artifacts/orchestration/owner-directive-decisions/atomic-executor-1195/` | executor decision line | The executor's OD-1 decision line names class `scheduling`, while the checkpoint entry for OD-1 has class `merge_timing`. | When the orchestrator appends `owner_directive_records`, repeat the entry class `merge_timing`. | The record rules require the record class to repeat the entry class; the mismatch is in an untracked orchestration file, not in the branch diff. | Checkpoint and decision file inspection |

No covered file is at or above 700 logical lines (largest: Claude gate 493). `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The gate change is one line per surface and adds no line, file, dot-source, or manifest entry; the stage-1 pattern array is passed to the new function rather than copied.
- The new function is pure and bounded: a queue with depth limit 4, segment-level `Unbalanced` skip, and a decline on `env -S`, Opaque PowerShell payloads, and encoded-command flags.
- Encoded-command detection reads the host flags from the words because `Get-CommandLineWrapperPayload` decodes encoded payloads; the comment states this.
- The function tests read the stage-1 patterns from the gate through the PowerShell parser, so the tests cannot drift from the gate literals.
- Every branch of the new function has a discriminating row: the reviewer's seven mutants (unbalanced skip removed, `env -S` decline removed, encoded decline removed, depth bound raised to 5, supplement call removed, env value skip removed, index 0 admitted) each fail at least one row, and the control fails none.

#### API and safety notes

- The new functions are internal to the gates and their tests.
- No I/O, no process start, no evaluation of command text.
- Backward compatibility: the union only adds indexes, so every command classified before remains classified.

#### Error handling and logging

- Malformed input yields no index; a failed dot-source of the classify sibling still denies naming the file (I2 on both surfaces).

---

## Test Quality Audit

The wrapped tables cover every wrapper family, prefix, env option form, decline path, depth bound, and output-contract property; Negative rows pin the mentions, the five D18 exclusions, and the four non-goals; Control rows pin forms that were already classified. Fail-before evidence shows every Positive row false and every Negative and Control row at its expected value against the unchanged hooks.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1`, both classify `Tests.ps1` files, and the classify `Parity.Tests.ps1`.
- `evidence/regression-testing/fail-before.2026-11-15T23-50.md`, `evidence/regression-testing/r3-mutant-probe.2026-11-16T00-34.md`.
- `evidence/qa-gates/phase-gate.P1.2026-11-16T00-08.md`, `evidence/qa-gates/phase-gate.P2.2026-11-16T01-05.md`, `evidence/qa-gates/final-qc-pester.2026-11-16T01-31.md`, `evidence/qa-gates/final-qc-static.2026-11-16T01-20.md`, `evidence/qa-gates/scope-verification.2026-11-16T01-46.md`, `evidence/other/contract-tests.2026-11-16T00-33.md`, `evidence/qa-gates/ci-run.2026-11-16T02-02.md`.

### Quality assessment prompts

- **Determinism:** in-memory rows; no clock, file, or process access.
- **Isolation:** one row per form.
- **Speed:** reviewer scoped run 283 tests in 125.87 s including worker startup.
- **Diagnostics:** `-Because` text names the row kind and expected indexes.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The new functions start no process and evaluate no text. |
| Input validation at boundaries | ✅ PASS | Variable, substituted, encoded, and split-string payloads yield no index. |
| Error handling remains explicit | ✅ PASS | No catch-all; I2 unchanged. |
| Configuration / path handling is safe | ✅ PASS | No path handling added. |
| No hook invokes Python | ✅ PASS | No Python call added to a hook. |

---

## Research Log

No external research was required. Behavior was confirmed by real-process probes of the item worktree's hook code; the base-equivalent probe replaced `Get-OrchestrationGateWrappedPatternIndex` with a function returning no index, which reproduces the merge-base gate because the only gate change is the union on that line.

---

## Verdict

The implementation meets the spec, the mirrors are byte-identical, the cycle-3 guards are untouched and now pinned, and coverage and evidence rules are met. No blocking finding. The branch is ready to merge once CI on the PR head succeeds.
