# Code Review: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T12-56
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 3)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `bcdb4c9e0fdd35e279981b60a716a941e56c5882`
- Base: `main`; merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`
- Scope: full branch diff `git diff 5bdf22d0f..HEAD` (204 files). Production code reviewed: `.claude/hooks/hook-docs-only-diff.ps1` (new; byte-identical at `.codex/hooks` and both bundle mirrors, hash `7e429ae6c`), `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1` (header), `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, both `pack-manifests/core.json`. Test code reviewed: all changed suites, with full reads of the cycle 3 hunks in `hook-docs-only-diff.BoundedNative.Tests.ps1` and `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. Documentation reviewed: cycle 3 inputs, plan, evidence, and closure record.
- Cycle 3 change set: `git diff d7b4da075..HEAD -- . ':!docs'` (helper at four paths, +10/-1 each; two runner suites); production commit `f8adac1c9`.

## Executive Summary

The cycle 3 code change addresses CR-N1 and CR-N2. In `Invoke-DocsOnlyBoundedNative`, the standard error read is now held in `$errorRead` (`.claude/hooks/hook-docs-only-diff.ps1:204`). On the expiry path, after the `Kill` attempt, each of `$output` and `$errorRead` is checked once with `Wait(0)`, each inside its own `try`/`catch`, before the `finally` block disposes the process (`:212-219`, `:235-237`). The exit code 124, the empty output, the 3000 ms and 7000 ms wait limits, the 1000 ms output wait, and the `-ProcessStarter` seam are unchanged. The Claude-copy fake now records an ordered event list; the four expiry rows assert the exact order, and the normal-path row asserts that no zero-wait check occurs. The Codex-copy suite gains an LF-terminated output row that executes the trim statement at `.codex/hooks/hook-docs-only-diff.ps1:226`.

`Wait(0)` returns immediately. It observes a read that has already completed or faulted, so such a fault no longer goes unobserved, but it does not wait for a read that is still pending. Such a read is abandoned at `Dispose()`. The executor recorded this residual as decision D-R3-1, consistent with D-RUN-10's constraint that no wait be added. The hook process exits after one decision, so the residual has no effect on the decision.

The full-population local run and CI run `38900960142` both report tests=10647, failures=0, errors=0. Coverage of every changed hook file is at or above 85% and at or above its baseline.

No code defect blocks merge. The observations below are Low or Info.

## Prior Observation Disposition

| Prior ID | Disposition | Reviewer verification |
|---|---|---|
| CR-N1 (pending reads at disposal) | Closed, with residual CR-N5 | Source read of `hook-docs-only-diff.ps1:201-237`; ordering assertions at `BoundedNative.Tests.ps1:95, 149`; lines 212, 214, 217 `ci` 2, 1, 1 on the Claude copy in the local and CI artifacts. |
| CR-N2 (Codex trim not executed) | Closed | Row at `codex-hooks/hook-docs-only-diff.Tests.ps1:204`; `.codex/hooks/hook-docs-only-diff.ps1:226` `ci=1` in the local and CI artifacts. |
| CR-N3 (local XML predates merge) | Closed | Coverage XML mtime 08:25:25 -04:00 is after the last code commit `f8adac1c9` (08:11:23 -04:00); no merge commit follows it, and `git rev-list --count HEAD..origin/main` returned 0. |
| CR-R2 (real process path) | NO_ACTION (D-RUN-10) | Carried as Low; the default starter is now at line 189. |
| CR-R3 (Codex timeout margin) | NO_ACTION (D-RUN-10) | Carried as Info; the cycle 3 checks add no wait, so the 20 s worst case is unchanged. |
| CR-R4 (Codex entry-point line) | NO_ACTION (D-RUN-10) | Line 403 `ci=0` in CI run `38900960142`, also uncovered at baseline. |
| CR-R5 (gate size) | NO_ACTION (D-RUN-10) | `enforce-epic-merge-gate.ps1` still 491 lines; not edited in cycle 3. |
| CR-R6 (Claude seams in Codex suite) | NO_ACTION (D-RUN-10) | Carried as Info. |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (non-blocking) | `.claude/hooks/hook-docs-only-diff.ps1` | line 189 (default `-ProcessStarter`); missed lines 189, 314, 358 | CR-R2 (carried): no test runs the real `[System.Diagnostics.Process]::Start` path, so tree termination (`Kill($true)`), disposal, and the cycle 3 read checks of a real process are verified only against the fake. | No action in this item; consider an integration row outside the unit suites if the runner changes again. | The fake verifies control flow, not .NET process behavior. | Local and CI coverage artifacts (reviewer parse) |
| Low (non-blocking) | `.claude/hooks/hook-docs-only-diff.ps1` (and its three copies) | whole file, 493 lines | CR-N4 (new): the helper is 7 lines below the 500-line limit; cycle 3 added 9 lines. | Plan the next change to the helper with an extraction, for example moving the bounded runner into its own file with the same byte-identical copy discipline. | File-size headroom; a further edit of similar size would exceed the limit at four paths. | Reviewer `wc -l` |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` | lines 212-219 | CR-N5 (new, residual of CR-N1): `Wait(0)` observes a read that has already completed or faulted, but a read still pending at the check is abandoned; if it faults after `Dispose()`, the fault is not observed. The commit subject of `f8adac1c9` ("settle output reads before disposal") describes more than the code does; the help text at line 170 ("each read is checked once without waiting") is accurate. | No action; D-R3-1 records the residual. If the runner is reused in a long-lived host, attach a continuation that observes each read or wait a bounded time after `Kill`. | The hook process exits after one decision, and .NET does not terminate a process for unobserved task exceptions. | Source read; `evidence/qa-gates/r3-remediation-closure.2026-10-16T12-51.md` (D-R3-1) |
| Info | `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` | lines 24-33 and 135 | CR-N6 (new): only the standard error fake can fault (`$drain.Wait` throws when `Faults`); the standard output fake's `Wait` never throws. No row shows that a fault in the first check (standard output) still lets the second check and `Dispose()` run. | Optional: add a `ReadFaults` option to the output fake and a row asserting `output-wait 0|error-wait 0|dispose` when the first check faults. | The per-iteration `try`/`catch` makes this behavior correct by reading; a row would pin it against a future refactor that moves the `try` outside the loop. | Source read |
| Info | `.codex/hooks/hook-docs-only-diff.ps1` | line 217 | CR-N7 (new): the catch body of the read check is `ci=0` on the Codex copy because the Codex-copy suite has no faulting-read row; the Claude copy covers the identical statement (`ci=1`). Whole-file coverage of the Codex copy is 97.60%. | Optional: add a faulting-read row to the Codex-copy runner rows. | The copies are byte-identical, so the behavior is covered; the gap is per-path measurement only. | `evidence/qa-gates/r3-coverage-delta.2026-10-16T12-29.md` (CHANGED_CODE_INFO, decision D-R3-2); reviewer parse |
| Info | `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-inputs.2026-10-16T14-05.md`, `remediation-plan.2026-10-16T14-05.md` | filename timestamps | CR-N8 (new): the filename timestamp 14-05 is later than the commit that added both files (`bcdc59909`, 2026-10-16T11:52:18Z), so the cycle 3 inputs and plan sort after this review set (12-56). | Do not rename (renames of committed artifacts are prohibited by the cycle's Do Not Do list); tooling that selects the newest artifact by filename should be aware of the ordering. | Filename ordering is used to find the latest review and remediation artifacts. | `git log --format="%h %cI %s" d7b4da075..HEAD` |
| Info | `.claude/hooks/hook-docs-only-diff.ps1` | header lines 50-56; registration `.codex/config.toml:144` (`timeout = 30`) | CR-R3 (carried): the 20 s worst case leaves about 10 s under the Codex 30 s timeout once start-up is included. | No action; revisit if more calls are added to the docs-only branch. | Headroom record. | Header text and registration |
| Info | `.codex/hooks/enforce-epic-merge-gate.ps1` | line 403 | CR-R4 (carried): the changed entry-point statement is uncovered (`ci=0`) in CI run `38900960142`; also uncovered at baseline, and named as the exception in AC-M24. | No action. | No-regression rule satisfied. | Reviewer parse of the CI artifact |
| Info | `.claude/hooks/enforce-epic-merge-gate.ps1` | whole file (491 lines) | CR-R5 (carried): 9 lines below the 500-line limit. | Plan the next change to this gate with an extraction. | File-size headroom. | `wc -l` |
| Info | `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` | lines 21-28 | CR-R6 (carried): Claude seam mocks retained because the epic-state isolation discovery guard requires them. | Remove if the discovery guard later distinguishes Codex suites. | Records why the earlier recommendation was not applied. | `evidence/qa-gates/r1-remediation-closure.2026-10-16T09-12.md:13` |

## Detailed Notes

### Cycle 3 change

- Structure: `$errorRead = $process.StandardError.ReadToEndAsync()` (line 204) replaces the discarded `$null = ...`. In the expiry branch (lines 205-222), the `Kill` attempt is followed by `foreach ($pendingRead in @($output, $errorRead)) { try { $null = $pendingRead.Wait(0) } catch { $null = $_ } }`, then `LASTEXITCODE` 124 and `return`; the `finally` at lines 235-237 disposes the process.
- Order: standard output then standard error, fixed by the array literal; each check is guarded separately, so a fault in one does not skip the other.
- Short-circuit: when `WaitForExit` returns `$false`, `$output.Wait(1000)` is not called, so the exit-wait expiry row records `output-wait 0|error-wait 0|dispose`, while the output-wait expiry row records `output-wait 1000|output-wait 0|error-wait 0|dispose`. Both orders match the code.
- Normal path: the row at `BoundedNative.Tests.ps1:95` asserts `output-wait 1000|dispose`, showing that the zero-wait checks run only on the expiry path.
- Codex-copy fake: the `$drain.Wait` member returns `$Milliseconds -ge 0` (`codex-hooks/hook-docs-only-diff.Tests.ps1:45`), which is always `$true` for the values used; it exists so the expiry rows do not fail on a missing member and makes no ordering claim.

### Coverage cross-check

- Local artifact (route B) and CI artifact of run `38900960142` agree for all seven changed files: helper copies 97.60%, docs-only 100.00%, pr-author 92.98%, Claude gate 99.29%, resolution sibling 95.65%, Codex gate 88.41%. AC-9 lines 78, 79, 82, 84 of `enforce-pr-author-skill.docs-only.ps1` have `ci` 2, 1, 1, 4 in the CI artifact.

## Verdict

No code-level blocker. Ten non-blocking observations (CR-R2 and CR-N4 Low; CR-N5, CR-N6, CR-N7, CR-N8, CR-R3, CR-R4, CR-R5, CR-R6 Info). The review-level verdict is PASS.
