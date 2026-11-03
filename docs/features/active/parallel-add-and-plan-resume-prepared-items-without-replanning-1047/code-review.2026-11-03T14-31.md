# Code Review: parallel-add-and-plan-resume-prepared-items-without-replanning (#1047)

- Timestamp: 2026-11-03T14-31
- Branch: feature/parallel-add-and-plan-resume-prepared-items-1047
- Base: origin/main @ 3ba4795ab2ce22f3d060e4709df8c489e4994971
- Head: fd66abe40e0d900ef1c5653be828d7c5af2de23c
- Review status: PAUSED. The owner paused this review before completion. Findings below are candidates; none has been classified as blocking, and no remediation inputs were written.

## Executive Summary

Review paused by the owner. One verified Minor candidate (unreachable reuse function), one unverified Major candidate (missing admitted plan hash for prepared-then-added items), one unverified field-name check, and two Info items. No blocking finding confirmed.

## Reviewed So Far

- `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`: read in full.
- Skill, rule, agent, settings, `quality-tiers.yml`, `core.json`, and Python test-support diffs: read in full.
- Not yet read: `ParallelAdmission.psm1`, `ParallelAdmissionPrecedence.psm1`, the hook helper diff, all six Pester suites, and the fixtures.

## Findings Table

| Severity | File | Issue | Recommendation |
| --- | --- | --- | --- |
| Minor | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1:632-649` | `Get-ParallelAdmissionRecordedEdge` has no CLI caller (candidate 1 below) | Expose as a subcommand or remove |
| Major (unverified) | `.claude/skills/parallel-add/SKILL.md` step 2 | No admitted plan hash recorded for a prepared-then-added item (candidate 2 below) | Confirm on resume before classifying |

Candidate detail:

| # | Severity | File | Finding | Status |
| --- | --- | --- | --- | --- |
| 1 | Minor (candidate) | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1:632-649` | `Get-ParallelAdmissionRecordedEdge` is not reachable from any subcommand of the CLI dispatch (lines 674-680); it is called only from `Invoke-ParallelAdmission.Tests.ps1` and the integration suite. The re-seed edge-reuse rule is therefore applied by prose in `parallel-plan` `### Seeding procedure` step 7 (`git show` plus a manual hash comparison) rather than by code, while the function's covered lines count toward the file's coverage. Options: expose it as a subcommand that the skill calls, or remove it. | Verified (grep across the worktree); severity to confirm on resume |
| 2 | Major (candidate, unverified) | `.claude/skills/parallel-add/SKILL.md` step 2; `.claude/skills/parallel-orchestrate/SKILL.md` kickoff element 4 | For an item that `/parallel-add` sends through a preparation child (`next_action` not `admit_prepared`), step 2 records `plan_hash` only on the `admit_prepared` branch, and no later step records the plan hash produced by preparation. Kickoff element 4 takes `<hex>` from the checkpoint item's `plan_hash`, else from the kickoff `## Integrity` row, which exists only for items seeded by `/parallel-plan`. A prepared-then-added item may therefore reach execution with no admitted hash to verify. | INCOMPLETE: review paused by the owner, resume here. Confirm whether any other step (for example a re-run of `assess` after preparation, or the receipt) supplies the hash |
| 3 | Unverified | `.claude/skills/parallel-orchestrate/SKILL.md` `**Turn gap.**` | The rule reads `step9_status` and `blocked_reason: awaiting_ci` from the child checkpoint. The field names were not yet checked against `.claude/rules/orchestrator-state.md` and the orchestrator-state validator. | INCOMPLETE: review paused by the owner, resume here |
| 4 | Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1:13, 488` | The help block states that no git write is made, but `assess` runs `git fetch --quiet origin`, which updates remote-tracking refs. The spec requires the fetch; the help text should say "no commit, branch, or working-tree write". | Verified |
| 5 | Info | `.claude/skills/parallel-add/SKILL.md:84, 100` | Step 2 contains two consecutive "Otherwise" clauses (the bullet and the following paragraph) that describe the same delegation; the second reads as a third alternative. | Verified |

No covered file is at or above 700 lines (largest: `Invoke-ParallelAdmission.ps1`, 699 logical lines), so no file-size Warning row applies.

## PowerShell Implementation Audit

Observed in `Invoke-ParallelAdmission.ps1`: strict mode and `$ErrorActionPreference = 'Stop'`; all git calls go through one seam with an argument array (`& git @GitArgs`), with no string-built command and no `Invoke-Expression`; usage validation precedes any read; exit codes 0/1/2 map to fixed stderr prefixes; `guard-run` fails closed on an unreadable checkpoint; JSON output keys are sorted ordinally with LF line endings.

INCOMPLETE: review paused by the owner, resume here. Still to review: both modules (stage inference, staleness verdict, decision table, precedence lift, cohort test, record and reuse), the hook helper change to `Test-ParallelCohortBarrierClear`, and bundle byte-equality (re-hash the 11 primary/bundle pairs).

## Python Implementation Audit

The only Python change adds two fragment tuples and two `SECTION_OBLIGATION_CASES` rows to a test-support module; no executable logic is added.

## Test Quality

INCOMPLETE: review paused by the owner, resume here. Still to review: the six Pester suites for temporary-file use, mock scope, Arrange-Act-Assert structure, scenario completeness against the spec rows, and determinism (clock seam mocked).

## Security and Safety

No secrets observed in the files read. Path handling and the `record` subcommand make no file write. Remaining files: INCOMPLETE: review paused by the owner, resume here.

## Verdict

INCOMPLETE: review paused by the owner, resume here. No blocking finding has been confirmed. Candidate finding 2 must be resolved before a verdict is issued.
