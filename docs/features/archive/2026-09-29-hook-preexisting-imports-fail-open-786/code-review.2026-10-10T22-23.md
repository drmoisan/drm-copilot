# Code Review: Hook pre-existing imports fail open (#786, bundled #792)

---

**Review Date:** 2026-10-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue 786.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (merge base `86e457a003be0c60b65e01156e4cccd6495dfd1a`, equal to the base tip)
**Head Branch:** `bug/hook-preexisting-imports-fail-open-exec-786` at `0dd3e5067` (PR #881)
**Review Type:** Re-review at the exit of remediation cycle 2 (prior review `code-review.2026-10-10T18-34.md`)

---

## Executive Summary

The production change set is unchanged since the 18-34 review: no file under `.claude/`, `.codex/`, `extensions/`, `scripts/`, or `config/` changed in remediation cycle 2 (reviewer `git diff --name-only f72a63752 HEAD -- .claude .codex extensions scripts config`: 0 paths). The cycle changed six test files that this branch created under `tests/scripts/codex-hooks/` to resolve CI-1 (18 Linux-only Pester failures on PR #881).

Two causes were diagnosed and fixed. Seventeen rows passed Windows drive-letter paths (`C:\repo`, `C:\state\...`, `C:/primary`) into hook functions whose readers are mocked only for some calls; on Linux those paths raise `DriveNotFoundException` or fall outside the mocks' parameter filters, which produced the recorded `ParameterBindingException` ('File', 'Raw') and exit-code-2 messages. These literals are replaced by `/synthetic-root/...`, which is a rooted path on Linux and a drive-relative rooted path on Windows. Row 6 failed only in the 200-container Linux order because an earlier suite leaves `EpicScopeResolution` bound to a replaced `WorktreeRunResolution` instance (census `INSTANCE-MISMATCH: yes`); the fix unloads the six worktree-resolution modules before `Register-EpicStateBaselineMock` re-imports them, so the baseline mocks bind to one coherent set.

All 20 PR checks pass on `d83e7af61`, including `CI / poshqc / PowerShell hook suites (Linux)`; commits after it change only feature-folder documents.

**What changed in cycle 2:**
Test: `b054e8a59` (33 insertions, 30 deletions over six files). Documents: remediation inputs and plan, 37 `r2-*` evidence files, `commits.md`, `deviations.md`, `ac-status.md`.

**Top 3 risks:**
1. The suite that leaves the stale module instance (row 6) is not identified (`R6-CULPRIT: not isolated`); other suites that register module-scoped baseline mocks after the same prefix can fail the same way when container order changes.
2. The `Remove-Module` in `hook-dependency-failure.Codex.Tests.ps1` changes session state for every later container. Both full runs pass after it, but a later suite that relied on an instance loaded earlier, without importing it itself, would now see a fresh instance.
3. Carried: the standard combined Pester run reports four changed Codex files below 85%; AC-24 is met on the per-surface route, and the decision must travel with the PR.

**PR readiness recommendation:** **Ready** — no Blocker or Major findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | lines 40-42 | The module-family unload fixes this suite only; the earlier suite that leaves `EpicScopeResolution` bound to a replaced sibling instance is not identified. | Record a potential issue against the #737 harness to identify the prefix suite, or move the unload into `Register-EpicStateBaselineMock` for Claude-surface module seams so every caller gets a coherent set. | The defect is order-dependent and can recur in another suite without a code change. | `r2-ci-diagnosis.md` `## Verdict` (`R6-CULPRIT: not isolated (ciorder prefix)`), [P1-T4] census. |
| Minor | `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversions.md` | line 27 | Carried: `AC-6 GAP: ... the 2026-10-09 amendment did not extend to AC-6` remains after the 2026-10-10 AC-6 amendment. | Append a resolution note citing the Change Log 2026-10-10 entry and `r1-ac6-verify.md`, or remove the line. | Evidence should not contradict the current AC text. | Reviewer grep. |
| Minor | `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/r1-coverage-diagnosis.md` | whole file | Carried: 4.7 MB of probe output committed; `## Verdict` timestamp later than the halt commit. | Condense or document the retention; correct the timestamp. | Repository size and timestamp consistency. | 18-34 review. |
| Minor | `.claude/hooks/validate-orchestrator-output.ps1` | lines 51 and 59 | Carried: `OrchestratorState.psm1` imported twice. | Remove the non-`-Global` import in a follow-up and mirror the change. | Duplicate `-Force` imports reload the module. | 18-34 review. |
| Minor | `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H8.md` | proof record | Carried: the record does not state that the CONVERT decision rests on the cited exit-1 tail rather than an exercised epic leg. | Add one sentence. | Proof evidence should state which leg it exercised. | 06-50 review. |
| Nit | `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | line 42 | `Remove-Module ... -ErrorAction SilentlyContinue` suppresses every error, not only "module not loaded". | Optionally filter the list with `Get-Module -Name ... | Remove-Module -Force` so no error is raised for absent modules and real failures surface. | Repository policy prefers explicit error handling; the impact in test setup is low because the next statement imports each module with `-ErrorAction Stop`. | File inspection. |
| Nit | `.claude/hooks/enforce-epic-wave-barrier.ps1`, `enforce-parallel-drift-gate.ps1`, `enforce-parallel-cohort-barrier.ps1` | H4 to H6 catch blocks | Carried: always-true conditional and stale comment. | Simplify when the exemption terms allow. | Dead conditional. | 06-50 review. |
| Nit | `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | lines 453, 468 | Carried: `finally` resets two variables that no longer exist. | Remove the stale resets. | Dead cleanup. | 06-50 review. |
| Info | `tests/scripts/codex-hooks/*.Coverage.Tests.ps1` (five files) | fixture literals | `/synthetic-root/...` matches the convention already used by the #737 harness (`$script:EpicStateProbeSessionRoot = '/synthetic-worktrees/local-checkout'`). 0 drive-letter literals remain in any test file added or modified on the branch. | None required. | Portability. | Reviewer grep; `EpicStateIsolation.Baseline.Helpers.ps1:33`. |
| Info | `artifacts/pr_context.summary.txt` | Close candidates | The local branch name (`...-resume-786`) differs from the PR head (`...-exec-786`, same SHA), so the collector reports no PR. | None for the code; run the collector from a checkout of the PR head branch name when PR metadata is needed. | Metadata only; the diff range is correct. | Regenerated summary header. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | whole file | Carried: exactly 500 lines (and mirror). | Extract a sibling before any further addition. | 500-line cap. | Reviewer `wc -l`. |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- **No production change.** The diagnosis traced each of the 17 drive-literal rows to a hook call site and recorded where production obtains that path: `$PSScriptRoot`-derived roots, `git worktree list` output, the launcher environment, or receipt content (`r2-ci-diagnosis.md` [P1-T5], `PROD-PATH` lines 1 to 18). The five hook files contain no drive-letter literal (`PROD-PATH-DRIVE-LITERAL ... | 0`). The reviewer agrees that the failures are fixture defects: a test that supplies `C:\repo` to a function running on Linux exercises a path that production never produces there.
- **Regression-first for the fix.** The drive simulation rewrote `C:` to an absent drive letter in shadow copies on the Windows host and reproduced the 17 CI failures with matching per-suite counts and test names (`r2-drive-simulation.md`, `SIM-MATCH: yes`). After the fix, the same simulation finds 0 literals to replace and 0 failures (`r2-postfix-local.md` (a)).
- **Minimal edits.** Each fix-evidence file records numstat equal to the planned literal count and an unchanged line count (`r2-fix-e-*.md`); no assertion and no row was added or removed, and per-container passed counts equal the cycle-2 baseline (29, 17, 14, 11, 21, 75).
- **Row 6 diagnosis.** The row passes alone and paired, fails only in the 200-container Linux order, and the census shows two instances of the module family with a mismatch between the module-table `WorktreeRunResolution` and the instance that `EpicScopeResolution` binds. Unloading the family before registration lets `Register-EpicStateBaselineMock` (which imports without `-Force`) load one coherent set; the interception probe then passes in the 192-container reproduction list and in the full 200-container order (`r2-fix-e-hdf.md`, `r2-final-ciparity.md`).

#### Portability assessment

- `/synthetic-root/...` resolves as a rooted path on both platforms. On Windows it is rooted on the current drive. Reviewer inspection of the changed rows indicates that the value reaches only mocked readers (`Get-ChildItem`, `Get-Content`, `Test-Path`, or a mocked authority function) or a pure hash (`Get-*AttestationKey`), so no row reads the real filesystem. Windows results are unchanged (9495 passed), and the Linux job passes.
- The `$launchReceiptText` fixture in `enforce-epic-wave-barrier.Coverage.Tests.ps1` now carries `"checkpoint_path":"/synthetic-root/epic-786.json"`; JSON escaping is no longer needed because the value contains no backslash.

#### #737 isolation compliance

- R-ISOLATION (`enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`) passes 315 of 315, including the AC-4 baseline-form row for each of the six cycle-2 files and the AC-6 "probe inside an It" row for the two probe suites (`r2-isolation.md`, `r2-final-isolation-scope.md`).
- The E-HDF insertion follows the last dot-source and precedes every `Register-EpicStateBaselineMock` call, so the guard's ordering clause holds (`r2-isolation.md`, form derivation).

#### Error handling and logging

- Unchanged from the 18-34 review. H1 to H6 remain fail-closed named exemptions; H7 and H8 are converted to the helper with exit 2 on SubagentStop.

---

## Test Quality Audit

The Windows combined Pester run passes (9495 passed, 0 failed, JUnit 9505 with 10 pre-existing skips; `r2-final-pester-coverage.md`). The Linux CI-parity order passes 5700 of 5700 (`r2-final-ciparity.md`), and the PR check `CI / poshqc / PowerShell hook suites (Linux)` passes on `d83e7af61` (`r2-pr-checks.md`).

### Reviewed test and QA artifacts

- `tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1`, `enforce-epic-root-invocation.Coverage.Tests.ps1`, `enforce-epic-wave-barrier.Coverage.Tests.ps1`, `validate-codex-subagent-routing.Coverage.Tests.ps1`, `validate-feature-review-coverage.Coverage.Tests.ps1` — literal substitutions only (reviewer `git diff a9e8e88fe HEAD -- tests/`).
- `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` — three added lines (two comment lines, one `Remove-Module`); 213 lines.
- `evidence/other/r2-ci-diagnosis.md`, `evidence/regression-testing/r2-drive-simulation.md`, `evidence/qa-gates/r2-postfix-local.md`, `r2-final-ciparity.md`, `r2-isolation.md`, `r2-coverage-comparison.md`, `r2-preexisting-tests.md`, `r2-pr-checks.md`.

### Quality assessment prompts

- **Determinism:** improved; results no longer depend on the host having drive `C:` or on container order for row 6.
- **Isolation:** the row-6 fix reduces cross-suite coupling for this suite; the source of the stale instance remains (Minor finding).
- **Temporary files:** none; reviewer grep over the six files and the added diff lines found no temporary-file API.
- **Diagnostics:** assertions unchanged.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Cycle-2 diff contains test fixture literals and documentation. |
| No unsafe subprocess or command construction | ✅ PASS | No production change; no Python invocation in hooks (reviewer grep). |
| Input validation at boundaries | ✅ PASS | Unchanged. |
| Error handling remains explicit | ✅ PASS | Unchanged in production; one test-setup `SilentlyContinue` (Nit). |
| Configuration / path handling is safe | ✅ PASS | Registrations in `.claude/settings.json` and `.codex/config.toml` unchanged; production paths are `$PSScriptRoot`- or runtime-derived (`r2-ci-diagnosis.md` [P1-T5]). |
| Fail-closed on dependency failure | ✅ PASS | Unchanged; B1 suites pass on both platforms. |

---

## Research Log

No external research was required. Linux path behaviour was assessed from the CI failure messages recorded in `remediation-inputs.2026-10-10T19-25.md` and the executor's drive simulation.

---

## Verdict

The branch delivers fail-closed dependency handling for every registered PreToolUse and SubagentStop hook on both surfaces. Remediation cycle 2 resolves the Linux CI blocker with test-only changes that make fixture paths host-neutral and remove an order dependency in one suite, without production changes, coverage change, or assertion changes. The isolation guard, mirror parity, and the full PR check set pass. Remaining findings are Minor, Nit, or Info and do not block merge.
