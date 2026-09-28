# Final QA — Post-Change Per-File PowerShell Line Coverage (cycle 2)

Task: `[P5-T7]`
Timestamp: 2026-09-07T22-55
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

**Result: PASS.** All seven orchestrator-supplied post-change percentages are numeric and at or
above 85.0000. The supplied SHA was independently confirmed to carry the fix before any figure was
consumed.

## Division of labour

The executor runs no coverage command for this task. Standing constraint 9 places the dispatch and
the figure-reading with the orchestrator: `gh` is not in this executor's tool allowlist, and the MCP
test runner cannot produce a valid figure for this branch (see the `TOOLCHAIN_SUBSTITUTION` note
below).

| Step | Owner | Status |
|---|---|---|
| Push the branch | orchestrator | done — `origin/bug/enforcement-hook-trigger-matches-whole-command-text-545-r4` |
| Dispatch `.github/workflows/_poshqc.yml` against the pushed head | orchestrator | done — run id `34181009673` |
| Read the `LINE` counters from `artifacts/pester/powershell-coverage.xml` | orchestrator | done — seven figures supplied |
| Confirm the measured SHA carries the fix | **executor** | done — recorded below |
| Record the figures and check the 85.0000 floor | **executor** | done — recorded below |

## Provenance (orchestrator-supplied, recorded verbatim)

| Field | Value |
|---|---|
| Workflow path | `.github/workflows/_poshqc.yml` |
| Run id | `34181009673` |
| Run URL | `https://github.com/drmoisan/drm-copilot/actions/runs/34181009673` |
| Measured commit SHA | `06d166e0f47e4c377618384c8d2904ac0ab1a306` |
| Run conclusion | `success` |
| Artifact | `poshqc-test-results`, file `powershell-coverage.xml` |
| Derivation method | sum of the JaCoCo `LINE` counters per `<sourcefile>` |

## Executor confirmation that the measured SHA carries the fix

The task requires the executor to confirm the supplied SHA carries the fix before consuming any
figure, so that a figure measured on a pre-fix tree cannot be recorded as a post-change value.

Command, with the supplied SHA substituted:

```
git show 06d166e0f47e4c377618384c8d2904ac0ab1a306:.claude/hooks/hook-command-scanner.ps1 | grep -F -c 'function Test-CommandLineSegmentRawScan {'
```

EXIT_CODE: 0
**Observed output: `1`.** Expected: `1`. Agrees.

`Test-CommandLineSegmentRawScan` is the function `[P1-T4]` creates, so its presence at that SHA is
positive evidence the measured tree is the post-fix tree rather than an earlier one. `git show`
resolved the SHA and the path without error, so neither the missing-commit nor the missing-path
blocking branch was reached.

Corroboration: `git rev-parse HEAD` in this worktree returns
`06d166e0f47e4c377618384c8d2904ac0ab1a306` — the measured commit is this executor's current head,
not an ancestor or a sibling.

## The seven post-change per-file percentages

| # | Canonical path | Post-change line % |
|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | **97.8142** |
| 2 | `.codex/hooks/hook-command-scanner.ps1` | **100.0000** |
| 3 | `.claude/hooks/enforce-epic-merge-gate.ps1` | **96.7213** |
| 4 | `.codex/hooks/enforce-epic-merge-gate.ps1` | **98.5915** |
| 5 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | **93.5897** |
| 6 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | **96.0000** |
| 7 | `.claude/hooks/validate-bash.ps1` | **94.6237** |

All seven canonical paths named by the task are present. All seven values are numeric. No
placeholder and no `BASELINE_NOT_REPORTED` marker appears; neither is an available outcome for this
artifact.

### 85.0000 floor check

| # | Path | Post-change | >= 85.0000 | Headroom |
|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | 97.8142 | yes | +12.8142 |
| 2 | `.codex/hooks/hook-command-scanner.ps1` | 100.0000 | yes | +15.0000 |
| 3 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.7213 | yes | +11.7213 |
| 4 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 98.5915 | yes | +13.5915 |
| 5 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 93.5897 | yes | +8.5897 |
| 6 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 96.0000 | yes | +11.0000 |
| 7 | `.claude/hooks/validate-bash.ps1` | 94.6237 | yes | +9.6237 |

Seven of seven at or above the uniform 85% line-coverage threshold set by
`.claude/rules/quality-tiers.md`. The lowest is
`.claude/hooks/enforce-parallel-abandon-gate.ps1` at 93.5897, carrying 8.5897 points of headroom.

## TOOLCHAIN_SUBSTITUTION

The MCP test runner (`mcp__drm-copilot__run_poshqc_test`) was **deliberately not used** to produce
any coverage figure in this artifact.

Reason: the MCP runner resolves its runsettings from the **installed VS Code extension payload**,
not from this branch's checkout. It therefore cannot see the `CodeCoverage.Path` entries this branch
declares — including the two `hook-command-scanner.ps1` registrations at lines 253 and 255 of
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. A figure produced by that runner would
be measured against a different denominator than the one the plan's threshold is defined over, so it
would not be comparable to the run `34158596238` baselines and would not be a valid substitute.

`pwsh`, `powershell`, and `cmd` are not invocable from this session, so no local route to a valid
figure exists. The CI dispatch of `.github/workflows/_poshqc.yml` is the only route that measures
this branch's declared denominator, and it is the route used.

## Additional CI evidence from the same run (recorded, not required by this task)

Run `34181009673` is a full PowerShell toolchain pass on a clean CI checkout of this exact head SHA:

- **Format** — the step runs `Invoke-PoshQCFormat` and then fails the job if `git status --porcelain`
  is non-empty. A `success` conclusion is therefore positive evidence the formatter **rewrote
  nothing**, not merely that it exited 0.
- **Analyze** — passed.
- **Test** — passed. `pester-junit.xml` reports **4363 tests, 0 failures, 0 errors, 0 suites with
  failures**.

This is stronger than the local picture: the MCP runner on this workstation consistently reports 2
failures, and CI reports 0. The plan's standing claim that those two failures are ambient to this
workstation and do not reproduce on a clean checkout has been asserted in every cycle-2 artifact but
was never directly evidenced until this run. It is now evidenced.

## Output Summary

Seven of seven post-change per-file line-coverage percentages recorded as numeric values from CI run
`34181009673` of `.github/workflows/_poshqc.yml` at commit
`06d166e0f47e4c377618384c8d2904ac0ab1a306` (conclusion `success`): 97.8142, 100.0000, 96.7213,
98.5915, 93.5897, 96.0000, 94.6237. All seven are at or above the 85.0000 floor; the lowest carries
8.5897 points of headroom. The executor's own
`git show 06d166e0f47e4c377618384c8d2904ac0ab1a306:.claude/hooks/hook-command-scanner.ps1 | grep -F -c 'function Test-CommandLineSegmentRawScan {'`
printed `1`, confirming the measured SHA carries the `[P1-T4]` fix, so no figure was consumed from a
pre-fix tree. The MCP test runner was deliberately not used for any figure. The same run additionally
records a clean-checkout format, analyze, and test pass with 4363 tests and 0 failures.
