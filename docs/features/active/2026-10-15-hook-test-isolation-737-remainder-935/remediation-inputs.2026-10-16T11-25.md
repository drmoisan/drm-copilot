# Remediation Inputs — Cycle 3 (issue #935)

Review-Verdict: REMEDIATION_REQUIRED

Timestamp: 2026-10-16T11-25
Head reviewed: `1d364d0c16fa77a1ed38ce16c5506ee55b5bf38c` (PR #956)
Review artifacts:
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T11-25.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T11-25.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T11-25.md`
Prior inputs: `remediation-inputs.2026-10-16T07-55.md` (COV-1 autonomous; CR-R1..CR-R3, all fixed in cycle 2).

## Finding COV-1: PR CI line coverage remains below the baseline (AC-24)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The cycle-2 isolation run `evidence/other/r2-cov-iso-u4.2026-10-16T10-50.md` restored `WorktreeResolution.psm1` to 142 covered lines by reverting unit U4 alone. All nine U4 paths are listed in spec `## Write Set`. A per-file bisection inside U4 and a change in the identified file are executable within the item.

Observed:
- CI run 38890188058 (head `988ed2210`; isolation-guard files identical to HEAD), artifact `poshqc-test-results`, root LINE counter: covered 16383, missed 1787, 90.17%.
- Baseline 90.42% (`adb9aa5f0`, run 38730332356). Main at `b6be46b5e`: 90.44%. Prior PR head `da4ccf4f0`: 90.27%.
- `.claude/lib/worktree-resolution/WorktreeResolution.psm1`: covered 112 / missed 32 in the PR CI file, against 142 / 2 on main.

Cycle-2 investigation (`evidence/other/r2-cov-investigation.2026-10-16T10-51.md`):
- Reproduced locally: HEAD 127 vs BASE 142.
- Unit isolation: U2 NO-EFFECT, U1 NO-EFFECT, U4 RESTORES. U3 and U5 were skipped by the plan rule.
- Outcome `REPRODUCED-U2-DOES-NOT-RESTORE`, route BLOCKED, because the only pre-specified fix (FIX-U2) did not apply. No code was changed.

Classification note: `evidence/qa-gates/r2-cov-blocked.2026-10-16T10-52.md` says "root cause outside the write set". That phrase describes the suspected mechanism: Pester single-hit line breakpoints bound to the first compiled instance of the module, with no `UseBreakpoints` key in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The same line names the trigger unit as U4. U4 consists of these Write Set paths:
- Created: `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` and `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`.
- Edited: `EpicStateIsolation.Helpers.ps1`, `EpicStateIsolation.Discovery.Helpers.ps1`, `EpicStateIsolation.Compliance.Helpers.ps1`, and the Branches, Predicate, legacy and Discovery guard suites (all under `tests/scripts/claude-hooks/`).

Because the trigger lies inside the Write Set, the finding stays autonomous.

Expected:
- Post-change line coverage on the final PR head is not lower than the baseline and not lower than main at the merge-base (AC-24).
- No production file is excluded, and no coverage configuration or `scripts/` or `config/` file is changed (spec AC-21).

Suggested remediation:
1. Split U4 into components and repeat the D-ISO repo-scope isolation for each, reverting only that component to `b6be46b5e`:
   - U4a: the HookReference helper and its dot-source line in `EpicStateIsolation.Helpers.ps1`.
   - U4b: the new HookReference suite file.
   - U4c: the Discovery suite rows `AC-5b` and `F-3 non-vacuity`, together with the Discovery and Compliance helper additions.
   - U4d: the `$script:UnderTest` fixture-line edits in the Branches, Predicate and legacy guard suites, together with the Branches rows.
   Narrow further inside the component that restores 142.
2. Identify the construct that changes which compiled instance of `WorktreeResolution.psm1` Pester's breakpoints attach to. Candidates include suite order or timing (the new suite file), and any runtime load reached through the parse or report path. Change it inside the identified Write Set file without changing any row name or result.
3. Verify locally with a repo-scope run (142 covered for the module), then from the PR CI coverage file on the final head.
4. If no change inside the Write Set restores the attribution, stop and record the outcome for a human decision. The options are to accept the attribution loss against AC-24, or to authorize a change outside the Write Set such as the PoshQC runsettings or a claude-lib suite.

## Non-blocking related findings (fix in the same cycle; same files or same item)

- DOC-1 (Low): the PR #956 description covers cycle 1 only and describes COV-1 as a denominator mismatch. Update it with cycle 2 (CR-R1..CR-R3), the COV-1 investigation and the cycle-3 outcome.
- EV-1 (Low): the cycle-2 BLOCKED record conflates the mechanism location with the trigger location. Cycle-3 COV-1 evidence should state the trigger file and the mechanism on separate lines.
- CR-R5 (Info): `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` line 434. Add the missing space in `$seen =[System.Collections.Generic.HashSet[string]]::new(...)`.
- CR-R4 (Info, optional): `Get-EpicStateHookLiteral` in `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` (pre-existing on main) inlines the exclusion that `Test-EpicStateIsolationExcludedHookName` now provides. Reuse it only if the closure results stay identical (AC-13).

## Pending CI (non-blocking)

- PC-1: final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19 and AC-23 on run 38893096135 (in progress at review time). Each was satisfied in run 38890188058. Owner: orchestrator at S9.
