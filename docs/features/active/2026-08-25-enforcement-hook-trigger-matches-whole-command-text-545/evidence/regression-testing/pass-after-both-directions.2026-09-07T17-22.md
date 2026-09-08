# [P13-T8] Pass-after summary for both regression directions

Timestamp: 2026-09-07T17-22

Command:

```
# no new test execution; this task reconciles runs already recorded
mcp__drm-copilot__run_poshqc_test    # the [P13-T3] whole-suite run supplies the current per-suite figures
# per-suite results read from artifacts/pester/pester-junit.xml by matching each testsuite element by name
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh` is not invocable anywhere in this session, so no `Invoke-Pester`
invocation appears in any of the runs referenced below. Every pass-after run cited here was executed
through the MCP PoshQC test runner at a folder scope and read back from
`artifacts/pester/pester-junit.xml` by matching the `testsuite` element for the named file. The
current-state column below is read from the [P13-T3] whole-suite run, so all seven rows describe one
measurement of the final tree rather than seven separately-timed observations.

## The two regression directions

- **Over-match direction.** A hook denies a command it should allow, because its trigger literal
  matched text that is not an invocation — quoted prose, a heredoc body, a search term, a message
  body. Fixing it means the hook now allows.
- **Under-match direction.** A hook allows a command it should deny, because its trigger literal did
  not match a relocating, flag-reordered, or equals-joined spelling of a genuine invocation. Fixing
  it means the hook now denies.

Both directions must close, and closing one must not reopen the other. That is why every
`[expect-fail]` suite below contains cases in both directions and why the paired negatives are
carried alongside.

## Fail-before to pass-after pairing, all seven `[expect-fail]` artifacts

| # | Task | Side | Suite | Fail-before artifact | Fail-before result | Pass-after artifact | Current result |
|---|---|---|---|---|---|---|---|
| 1 | [P1-T3] | Claude | `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` | `evidence/regression-testing/fail-before-acceptance-cases.2026-09-07T11-35.md` | 11 tests, **6 failed**, 5 passed; AT-1, AT-2, AT-3, AT-4, AT-5, AT-7 failing | `evidence/regression-testing/pass-after-acceptance-cases.2026-09-07T17-20.md` ([P13-T7]) | 11 tests, **0 failed** |
| 2 | [P1-T5] | Claude | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `evidence/regression-testing/fail-before-claude-triggerscoping.2026-09-07T11-40.md` | 19 tests, **13 failed**, 6 passed | `evidence/regression-testing/pass-after-claude-preimplementation.2026-09-07T13-17.md` ([P5-T3]) | 19 tests, **0 failed** |
| 3 | [P1-T7] | Codex | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `evidence/regression-testing/fail-before-codex-triggerscoping.2026-09-07T11-44.md` | 23 tests, **13 failed**, 10 passed | `evidence/regression-testing/pass-after-codex-preimplementation.2026-09-07T13-31.md` ([P5-T7]) | 23 tests, **0 failed** |
| 4 | [P1-T9] | Claude | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `evidence/regression-testing/fail-before-claude-commandexemption.2026-09-07T11-48.md` | 59 tests, **1 failed**, 58 passed; the single intended reversal | `evidence/regression-testing/pass-after-claude-preimplementation.2026-09-07T13-17.md` | 59 tests, **0 failed** |
| 5 | [P1-T11] | Codex | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `evidence/regression-testing/fail-before-codex-commandexemption.2026-09-07T11-52.md` | 59 tests, **1 failed**, 58 passed; the same intended reversal | `evidence/regression-testing/pass-after-codex-preimplementation.2026-09-07T13-31.md` ([P5-T7]) | 59 tests, **0 failed** |
| 6 | [P10-T2] | Claude | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `evidence/regression-testing/fail-before-validate-bash.2026-09-07T15-10.md` | 5 tests, **4 failed**, 1 passed; AT-8, AT-9, AT-10 and the quoted `cd`-chain over-match | `evidence/regression-testing/pass-after-validate-bash.2026-09-07T15-14.md` ([P10-T6]) | 7 tests, **0 failed** |
| 7 | [P10-T14] | Claude | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `evidence/regression-testing/fail-before-parallel-abandon.2026-09-07T15-28.md` | 3 tests, **3 failed**, 0 passed | `evidence/qa-gates/batch-b19-toolchain.2026-09-07T15-32.md` ([P10-T16]) | 3 tests, **0 failed** |

**Seven `[expect-fail]` artifacts, seven paired pass-after runs. Zero unpaired fail-before
artifacts.**

Row 6 grew from 5 tests to 7 between the fail-before and the current state, because [P10-T4] added
two named cases after the fix — `git push origin main` returns `$null` and `git reset --soft HEAD~1`
returns `$null` — pinning that the structural leg does not classify on a bare subcommand. The four
originally-failing cases are among the 7 and all pass; no case was removed.

## Both-sides coverage where both sides exist

| Defect | Claude side | Codex side | Both sides covered |
|---|---|---|---|
| Preimplementation-gate trigger scoping | rows 2 and 4 | rows 3 and 5 | **yes** |
| `validate-bash.ps1` matching primitive | row 6, `validate-bash.TriggerScoping.Tests.ps1`, 7 tests / 0 failed | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`, 3 tests / 0 failed | **yes** |
| `enforce-parallel-abandon-gate.ps1` | row 7 | no Codex copy exists | n/a, Claude-only two-copy hook |
| Acceptance cases AT-1 to AT-7 | row 1 | AT-7 asserts across both removal gates from within row 1's suite | **yes**, within one suite |

The Codex validate-bash suite `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`
carries no `[expect-fail]` artifact of its own, and this is a deliberate ordering fact rather than a
gap: [P10-T10] created that file **after** [P10-T8] had already fixed the Codex hook, so there was no
unfixed state left for it to be run against. Its three cases — the Codex idiom of AT-8, AT-9, and
AT-10 — are the same three defects the Claude-side fail-before at row 6 recorded failing against an
unfixed hook, so the fail-before evidence for those three defects exists on the Claude side and the
pass-after exists on both. It reports 3 tests / 0 failed in the [P13-T3] run.

`enforce-parallel-abandon-gate.ps1` is one of the four two-copy hooks and has no `.codex/` copy at
all, so the Codex side does not exist and no pairing is owed for it.

## The single intended assertion reversal, both sides

Rows 4 and 5 each recorded exactly one failing pre-existing assertion at fail-before: the `It` named
`denies a message-body payload that merely contains the staging literal`, at
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
line 246 and at
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
line 250. Both are now green, and both suites report 59 tests with 0 failures, so no other
pre-existing assertion in either file was disturbed. That is the whole of the intended reversal: one
case per side, and nothing else. The reversal is recorded independently in
`evidence/regression-testing/intended-assertion-reversal.2026-09-07T11-52.md`.

## Known-red inventory

`evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md` enumerated every test expected
to fail and the phase that closes it. Every row it names appears in one of the seven fail-before
artifacts above, and every one of those suites now reports zero failures in the [P13-T3] whole-suite
run. The inventory is therefore fully discharged.

## Output Summary

**Seven `[expect-fail]` artifacts from Phase 1 and Phase 10, each paired with a pass-after run.
Zero unpaired fail-before artifacts.** All seven suites report zero failures in the current tree:
11, 19, 23, 59, 59, 7, and 3 tests respectively, 181 cases in total, 0 failed. Both regression
directions close on both runtimes: the preimplementation-gate defect and the `validate-bash.ps1`
matching primitive each carry Claude-side and Codex-side pass-after evidence; the two remaining
subjects are Claude-only hooks for which no Codex side exists. The single intended assertion
reversal is confirmed as exactly one case per side with every other pre-existing assertion in both
files still passing.
