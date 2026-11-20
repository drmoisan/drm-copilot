# Code Review: Preimplementation gate classifies wrapped shell and PowerShell payloads (#1195), remediation cycle 1 re-audit at head 34ac24137

---

**Review Date:** 2026-11-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195`
**Feature Folder Selection Rule:** named by the caller; matches the issue number in `issue.md` and the branch `bug/gate-wrapped-shell-test-commands`
**Base Branch:** `main` (merge base `b58f045bc58d237129963543e445c7c8d2987772`, equal to `origin/main` after `git fetch`)
**Head Branch:** `bug/gate-wrapped-shell-test-commands` at `34ac24137b2ace314c3ac9186358ba16b3044583` (PR #1196)
**Review Type:** Re-audit after remediation cycle 1, concurrent mode; CI on the head completed

---

## Executive Summary

The branch changes 74 files against the merge base: the classify sibling in four byte-identical copies, one line in each gate and its bundle copy, four test files, six byte-identical brief copies, and the feature folder. `git merge-tree --write-tree origin/main HEAD` exits 0 and `origin/main` equals the merge base, so there is no base drift.

The local PR context summary was generated at `ebacd29f1`, not at the reviewed head, so the reviewer read the diff directly with `git -C`.

Cycle 1 (`ebacd29f1..34ac24137`) changed only the four classify copies (status M), `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (6 added, 0 removed lines), and feature-folder files. The four classify copies share SHA-256 `d2ff656bb2999e3bb9efd283c0bc989c88f493f57f509bc1aeb02c7de10927cb`.

F1 verification (real-process probe of `Test-ImplementationCommand`, loaded from each tree's own hooks):

| Command | Merge base | Pre-cycle `ebacd29f1` | Head |
|---|---|---|---|
| `timeout 60 env -u X sh -c "pytest"` | false | false | true |
| `nohup env --unset X bash -c "ruff check ."` | false | false | true |
| `timeout 60 env -S sh -c "pytest"` | false | false | false |
| `timeout 60 env -u X pytest` (control) | true | true | true |

Further head probes: `echo x \| xargs env -u X sh -c 'pytest'`, `timeout 60 env -C /tmp sh -c "pytest"`, `timeout 60 env --chdir=/tmp sh -c "pytest"`, `time env A=1 nohup env -u Y bash -c "pytest -q"`, `A=1 timeout 60 B=2 env -u X sh -c "pytest"`, `timeout 60 /usr/bin/env -u X sh -c "pytest"`, and `nohup env -u X pwsh -Command "Invoke-Pester"` are true; `nohup env --split-string=x sh -c "pytest"` and `timeout 60 env -u X sh -c "git status"` are false; `sh -c "pytest"` stays true and `echo pytest` stays false.

Mutant probe: removing `-Except 'env'` (mutant A) or replacing `if (-not $skip.SkippedWrapper) { break }` with `break` (mutant B) turns both Positive F1 forms false and the `env -S` decline true; the new rows fail on each mutant.

**Top 3 risks:**
1. `timeout` with a separate-value option before the duration (`timeout -s KILL 60 sh -c "pytest"`, `timeout -k 5 60 sh -c "pytest"`) is still not classified, identically at the merge base, the pre-cycle head, and the head. Low impact; see Findings.
2. Hooks fired for isolated subagents use the default branch scripts, so the change reaches them only after merge (spec rollout section).
3. None further identified; CI on the exact head succeeded.

**PR readiness recommendation:** **Go**.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` (and its three copies) | `Get-OrchestrationGateWrapperPayloadText`, prefix loop | Finding F1 is fixed: `env` with value options after `timeout`, `nohup`, `time`, assignments, or xargs-injected words is now stripped, and the `-S`/`--split-string` decline applies after a prefix. | None. | Verified by real-process probes at three trees and two killed mutants. | Reviewer probe; `evidence/regression-testing/fail-before.2026-11-16T02-38.md` |
| Low (non-blocking) | `.claude/hooks/hook-command-payload.ps1` (shared, unchanged) via the classify sibling | `Skip-CommandLineTransparentWrapper`, `timeout` arm | `timeout -s KILL 60 sh -c "pytest"` and `timeout -k 5 60 sh -c "pytest"` return false: the shared skip consumes dash tokens then one duration token, so `KILL` or `5` is read as the duration and `60` as the command word. `timeout --signal=KILL 60 sh -c "pytest"` is classified. | No change for this item. If a later item widens the timeout grammar, handle `-s`/`-k`/`--signal`/`--kill-after` with separate values. | Spec Part 1 defines the prefix as `timeout` "with its duration", so this form is outside the specified grammar; AC-7 requires the shared module to stay unchanged; the result is identical at the merge base, so it is not a regression. | Reviewer probe at merge base, `ebacd29f1`, and head |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | `Get-OrchestrationGateWrapperPayloadText`, `$hops -lt 8` | The hop bound of 8 carries no comment (carried over from the prior review). | Optional. | Readability only; every loop terminates. | Diff inspection |

No covered file is at or above 700 logical lines (largest: Claude gate 493; classify 232). `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The head-only prefix strip moved into the top of the existing hop loop, so it applies to the original words and to xargs-injected words alike, with no added function.
- The `-Except 'env'` argument to the unchanged shared skip stops it at the next `env`, so the local env value-option rule always handles `env`.
- The inner loop terminates: the env branch advances at least one word, and the shared skip reports `SkippedWrapper` only with `Index` of at least 1.
- Forms without `env` after another prefix take the same path as before; the full final gate (27476 passed, 0 failed) shows no disposition change.

#### API and safety notes

- No interface change; the function stays internal.
- No I/O, no process start, no evaluation of command text.

#### Error handling and logging

- Unchanged: malformed input yields no index; I2 still denies naming the file on a failed dot-source.

---

## Test Quality Audit

Five rows were added and none edited. Each failed before the fix on both surfaces (fail-before evidence, 10 failures) and passes after. The reviewer's two mutants of the new branch logic are each killed by these rows.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (cycle-1 rows).
- `evidence/remediation-baseline/baseline-reference.2026-11-16T02-30.md`, `evidence/regression-testing/fail-before.2026-11-16T02-38.md`.
- `evidence/qa-gates/phase-gate.P1.2026-11-16T03-28.md`, `evidence/qa-gates/final-qc-static.2026-11-16T03-37.md`, `evidence/qa-gates/final-qc-pester.2026-11-16T03-52.md`, `evidence/qa-gates/final-qc-pytest.2026-11-16T04-15.md`, `evidence/qa-gates/scope-verification.2026-11-16T04-15.md`, `evidence/qa-gates/self-review.2026-11-16T04-16.md`, `evidence/other/contract-tests.2026-11-16T02-48.md`.

### Quality assessment prompts

- **Determinism:** in-memory rows; no clock, file, or process access.
- **Isolation:** one row per prefix order.
- **Speed:** both classify suites in 102.5 s including worker startup.
- **Diagnostics:** existing `-Because` text names the row kind and expected indexes.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The function starts no process and evaluates no text. |
| Input validation at boundaries | ✅ PASS | Split-string `env` is still declined after any prefix. |
| Error handling remains explicit | ✅ PASS | No catch-all added. |
| Configuration / path handling is safe | ✅ PASS | No path handling added. |
| No hook invokes Python | ✅ PASS | No Python call added to a hook. |

---

## Research Log

No external research was required. Behavior was confirmed by real-process probes that dot-source the gate from archives of the merge base, the pre-cycle head, the head, and two mutated copies of the head, all in the session scratchpad.

---

## Verdict

Finding F1 is fixed, the cycle stayed within the classify copies, the Cases file, and the feature folder, the mirrors are byte-identical, coverage is 100% on the classify sibling, and CI on the exact head succeeded. No blocking finding. The branch is ready to merge.
