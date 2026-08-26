# Pass-After: Layer B Verification Module (P2-T18)

Timestamp: 2026-08-26T00-01

Filename-stamp substitution: the plan-fixed suffix `.2026-08-24T13-10.md` was replaced with
`.2026-08-26T00-01.md` for this execution minute, as the plan's "Evidence filename timestamps"
governing rule directs. The path prefix and base name are unchanged.

Command: `mcp__drm-copilot__run_poshqc_test` (workspace_root =
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`)

EXIT_CODE: 3

No `ExpectedExitCode` field is declared. The Pester runner's exit code tracks the failure COUNT
rather than a fixed value, so declaring an expectation here would pin a number that changes as soon
as the count does. The three failures are named below and are the deliberate Phase 1 `[expect-fail]`
regression tests, not defects introduced by Phase 2.

## Result for the File This Task Gates

Counts parsed from `artifacts/pester/pester-junit.xml` by selecting every `testcase` whose
`classname` resolves to `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`:

| Metric | Value |
|---|---|
| Tests in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | 24 |
| Passed | 24 |
| **Failed** | **0** |
| Skipped | 0 |

The task's acceptance condition — zero failures for that test file — is satisfied.

## Named Tests Added by Phase 2, All Passing

Twenty-four tests across six contexts, mapped to the tasks that required them:

| Task | Named tests | Count |
|---|---|---|
| P2-T9 | dot-sources the module and resolves all three mocked seams | 1 |
| P2-T10 | passes the package operand in exact-version form to the npm seam | 1 |
| P2-T11 | reports failure when the exact version is absent while the latest dist-tag resolves | 1 |
| P2-T12 | six state tests (RESOLVED, NO_RUN, RUN_FAILED, STEP_SKIPPED, STEP_MISSING, UNRESOLVED) plus "does not invoke the npm seam when the registry-resolution check is skipped" | 7 |
| P2-T13 | treats a missing publish step as a non-zero failure rather than absence of evidence | 1 |
| P2-T14 | emits pairwise distinct recovery instructions for NO_RUN, STEP_SKIPPED, and UNRESOLVED | 1 |
| P2-T15 | three checks x {first attempt, later attempt, budget exhausted}, each asserting the exact `Invoke-Sleep` invocation count | 9 |
| P2-T16 | distinguishes an exhausted run-existence budget from a negative publish-step result | 1 |
| P2-T17 | two Codex-pin tests, both supplying config content in memory | 2 |

## Whole-Suite Result

| Metric | Baseline (P0-T5) | This run | Delta |
|---|---|---|---|
| Total tests | 3592 | 3619 | +27 |
| Passed | 3583 | 3607 | +24 |
| Failed | 0 | 3 | +3 |
| Skipped | 9 | 9 | 0 |

The +27 total is the three Phase 1 `[expect-fail]` regression tests plus the twenty-four Phase 2
tests. The three failures are exactly the Phase 1 expect-fail set and no others:

1. `Invoke-ReleaseTagPush.ps1 - Invoke-ReleaseTagPushGuarded.tag push ordering.pushes the mcp-server tag before the extension tag` — turns green at P3-T4.
2. `publish-mcp-npm.yml workflow invariants.declares a pull_request trigger scoped to the mcp-server package and the workflow file` — turns green at P4-T1.
3. `publish-mcp-npm.yml workflow invariants.guards the publish step on the tag ref and not on the event name` — turns green at P4-T2.

No other test regressed.

## Mutation Sensitivity Checks

The acceptance conditions of P2-T10, P2-T11, and P2-T14 each require that the named test would FAIL
against a specified defective implementation. Each was verified empirically by mutating the
production module, running the suite, and restoring the module. The module was byte-restored and
re-verified green afterwards; the restored file's operand construction was re-read at line 148 and
the 24 tests were re-run to 24 passed / 0 failed.

| Mutation applied to `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | Tests killed |
|---|---|
| Package operand switched to the bare-package form (`$packageOperand = $PackageName`) | "passes the package operand in exact-version form to the npm seam"; "reports failure when the exact version is absent while the latest dist-tag resolves"; "reads the pinned mcp version from in-memory config content and passes it to the registry check" |
| Recovery table replaced with one generic message for every state | "emits pairwise distinct recovery instructions for NO_RUN, STEP_SKIPPED, and UNRESOLVED" |

The first probe initially left the P2-T11 test alive: its arrangement returns a DIFFERENT present
version for the bare-package operand, so a bare-package implementation that also compares stdout
still reports failure and the test still passed. An operand assertion was added to that test so the
reported failure must demonstrably come from the exact-version query. The probe was re-run and the
test is now killed by the mutation, which is what makes the P2-T11 acceptance condition able to
fail rather than merely able to pass.

## Coverage Measurement and Which Runner Produced It

`mcp__drm-copilot__run_poshqc_test` resolves its Pester runsettings from the INSTALLED VS Code
extension, not from `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The
`CodeCoverage.Path` entry added by P2-T8 was therefore ignored by that runner and
`Invoke-ReleaseVerification.ps1` produced no coverage row in the MCP run's
`artifacts/pester/powershell-coverage.xml`. This is the known tooling behaviour and is NOT evidence
that the registration failed.

Coverage was therefore measured by invoking the SELF-HOSTED module directly:

```
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path
```

That run reported the same 3607 passed / 3 failed / 9 skipped and emitted a coverage document that
does include the new file. Per-file figures were parsed by keying on the enclosing `package` element
(the full directory path), never on the bare `sourcefile` name.

| File | Covered lines | Total lines | Line coverage |
|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 76 | 92 | **82.61%** |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 46 | 48 | 95.83% |
| Overall (all measured files) | 6732 | 7015 | 95.97% |

Runner attribution: the whole-suite pass and fail counts above are from the MCP runner; the per-file
and overall coverage percentages are from the self-hosted `Invoke-PoshQCTest` run.

### Threshold Exposure Recorded, Not Remediated

82.61% is BELOW the uniform 85% line-coverage threshold that P7-T6 asserts against this exact file.
Phase 2 has no coverage acceptance condition, and the plan enumerates the tests this phase adds, so
no test beyond the P2-T9 through P2-T17 set was authored. The exposure is recorded here and
escalated rather than silently closed.

The sixteen uncovered lines, by cause:

| Lines | Cause | Reachable by a unit test? |
|---|---|---|
| 57, 58, 74, 75, 92 | Bodies of the three wrapper seams (`& gh`, `& npm`, `Start-Sleep`) | No. Every test mocks these by design; executing them would violate AC21 and AC22. |
| 485, 496, 497, 498 | Entry-point block, skipped on dot-source | No, without executing the script. |
| 114, 121 | `ConvertFrom-JsonSafely` empty-text and malformed-text branches | Yes |
| 243 | `Resolve-PublishStepConclusion` absent-JOB branch (the absent-STEP branch is covered) | Yes |
| 258 | `Resolve-PublishStepConclusion` fall-through for a step conclusion that is neither skipped nor success | Yes |
| 340 | `Get-RecoveryInstruction` unrecognized-token branch | Yes |
| 398, 404 | `Get-CodexPinnedMcpVersion` empty-content and no-match branches | Yes |

Seven of the sixteen are reachable. Covering all seven would take the file to 83 of 92 lines, or
90.22%, clearing the threshold with margin. That is a plan delta for the orchestrator to approve, not
an executor decision.

Output Summary: The Layer B verification module suite passes 24 of 24 with zero failures and zero
skips, satisfying P2-T18's acceptance condition. The whole suite is 3607 passed / 3 failed / 9
skipped against a 3583 / 0 / 9 baseline; the three failures are exactly the Phase 1 `[expect-fail]`
tests for push order and the two publish-mcp-npm workflow invariants, and no other test regressed.
The MCP runner exited 3, which tracks that failure count rather than a fixed value, so no
`ExpectedExitCode` is declared. Mutation probes confirm the P2-T10, P2-T11, and P2-T14 acceptance
conditions are able to fail; the P2-T11 test required a strengthening operand assertion to become
so. Coverage of `scripts/dev-tools/Invoke-ReleaseVerification.ps1` is 82.61% (76 of 92 lines),
measured by the self-hosted `Invoke-PoshQCTest` runner because the MCP runner reads the installed
extension's runsettings and ignored the new `CodeCoverage.Path` entry. That figure is below the 85%
threshold P7-T6 asserts; seven reachable uncovered branches are itemized above and are escalated as
a proposed plan delta.
