# Remediation Inputs — Issue 1093

Timestamp: 2026-11-07T01-41
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/2026-11-06-epic-progress-report-skill-1093/policy-audit.2026-11-07T01-41.md`
- `docs/features/active/2026-11-06-epic-progress-report-skill-1093/code-review.2026-11-07T01-41.md`
- `docs/features/active/2026-11-06-epic-progress-report-skill-1093/feature-audit.2026-11-07T01-41.md`
Head reviewed: `cd19d42c4430a1bba81758db79cb1ea5167ffcb0` (merge base `a936a1d93c37592e6b2c960499767e54779f70f3`)

## Findings requiring remediation

### F1 — `-PairSamples` state write without a new sample is untested

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is one added Pester case in a test file of this branch; it needs no external party, policy decision, owner input or CI result.

- Files: `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` (test to add); production condition `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` line 447 (`if ($selection.Changed -or $ResetBaseline -or $PairSamples)`), expected to stay unchanged.
- Problem: `spec.md` `## Script Additions` states the write rule "the state is written when the sample rule added a sample, or when `-ResetBaseline` or `-PairSamples` was given." The only entry case for `-PairSamples` (`rewrites the stored samples in pairs with -PairSamples`) stores a newest sample 300 seconds old, so the sample rule writes regardless of the switch. A reviewer mutant that removes `-or $PairSamples` from the write condition leaves every test passing. In the documented cadence-change procedure a manual `-PairSamples` run within 90 seconds of a scheduled TL;DR run would then discard the pairing without an error.
- Required change: add an entry-suite case in the same `Describe` as the existing `-PairSamples` case. Store a version-1 state whose newest sample is less than 90 seconds before the fixed now (for example samples at now minus 1230, 930, 630, 330 and 30 seconds), run with `-PairSamples` and `-Mode TLDR`, and assert: exactly one `Write-EpicProgressState` call; the written `samples` are the paired set of the stored samples with no sample at the fixed now appended (for the example, `ts` values now minus 1230, 630 and 30); `startUnixSeconds` and `baselineDone` are carried over unchanged.
- Verification required: (a) the new case passes at the branch head; (b) with `-or $PairSamples` removed from the write condition on a scratch copy, the new case fails; restore and confirm a clean tree; (c) re-run the seven touched suites (163 plus the new case, 0 failed) and the formatter and analyzer on the changed test file; (d) keep the entry suite below 700 lines (563 now).

## Non-remediation items (record only; may be addressed in the same cycle at the planner's discretion)

- NB-1 (Minor, non-blocking): `spec.md` AC-09 cites `git diff --find-renames --name-status main...HEAD` as rename proof, which shows `A`/`M`/`D` by design (DEC-1 keeps the forwarder at the old entry path; DEC-5 trims the hub). The per-commit rename evidence `evidence/other/relocation-renames.2026-11-06T23-58.md` already proves the intent. If addressed, change only the AC-09 parenthetical to cite that evidence; do not change the checkbox state.
- Three Info items in the code review need no action.

## Constraints

- No production behavior change is expected for F1. If the new case fails at the branch head, stop and report it, because that would mean the production write rule is wrong.
- No change to the TL;DR or Full output, the skill text, the bundle mirror, or any Python file.
- If any canonical script changes, re-copy it to the bundle byte-identically and re-run the skill contract suite.
- Per-file line coverage stays at or above 85%; record new evidence under `evidence/qa-gates/` and `evidence/regression-testing/`.
- The five CI-dependent criteria (AC-12, AC-30, AC-31, US-AC-11, US-AC-15) stay unchecked until the S9 CI gate.

## Orchestrator Addendum (related, non-blocking, fixed in this cycle)

- OA-1: spec.md parameter table states the start-time resolution order with the stored start before the reset, which conflicts with AC-14 and the entry-suite reset test (a reset discards the stored start: passed value, then now on -ResetBaseline, then stored value). Correct the parameter table prose to match AC-14 and the implementation. Do not change any acceptance-criterion text.
