# QA Gate: Acceptance Criteria Verification (after loop pass 2) — Issue #1093

Timestamp: 2026-11-07T01-35
Command: review of the named tests and evidence below; read of `config/poshqc-coverage.json`; check-off of verified items in `spec.md` and `user-story.md`
EXIT_CODE: 0
Output Summary: 46 criteria mapped; 41 verified and checked off (28 in spec.md, 13 in user-story.md); 5 pending-CI and left unchecked (AC-12, AC-30, AC-31, US-AC-11, US-AC-15), to be checked off by the orchestrator after `CI Required Gate` passes on the PR head. This version supersedes `ac-verification.2026-11-07T01-00.md` after the P6-T13 self-review fix (two mocked state-write cases in the entry suite, now 35 cases; entry line coverage 90.82%) and the second QA loop pass; every status is unchanged.

Sources: `spec.md` (`## Acceptance Criteria`, AC-01 to AC-31) and `user-story.md` (`## Acceptance Criteria`, US-AC-01 to US-AC-15). Test runs: `evidence/qa-gates/pester-coverage.2026-11-07T01-04.md` (all touched suites 0 failures), `evidence/qa-gates/python-contract-tests.2026-11-07T01-34.md`.

`config/poshqc-coverage.json` read for AC-13: `roots` holds seven entries, `.claude/hooks`, `.claude/lib`, `.claude/skills`, `.codex/hooks`, `.github/hooks`, `.codex/scripts`, `scripts`.

## spec.md

| ID | Status | Proof |
|---|---|---|
| AC-01 | verified | SkillContract: `declares the name epic-progress-report`, `carries a single-quoted non-empty description and an argument-hint`, `grants the canonical script, CronCreate, CronList, CronDelete and PushNotification`, `does not fork context and is not hidden from invocation` |
| AC-02 | verified | SkillContract: `contains every required heading`, `stays under 500 lines` (338 lines) |
| AC-03 | verified | SkillContract: `states the report format fragments` |
| AC-04 | verified | SkillContract: `states the calculation rule values` |
| AC-05 | verified | SkillContract: `carries both scheduling prompts with their cron expressions`, `keeps baseline and pairing arguments out of the scheduling prompts`, `states the push-notification text rule, local cron time and jitter` |
| AC-06 | verified | SkillContract: `documents reset, cadence change, stopping and restart recovery` |
| AC-07 | verified | SkillContract: `documents known behaviors, rates, delivery and quota policy` |
| AC-08 | verified | SkillContract: `names no forbidden token and no scripts/dev-tools invocation`; entry suite: `contains no recovered hardcoded value` (seven paths); `test_push_down_issue_824_follow_ups.py` 62 passed |
| AC-09 | verified | `evidence/other/relocation-renames.2026-11-06T23-58.md` (four `R` entries, production files `R100`); `evidence/qa-gates/scope-diff.2026-11-07T00-59.md` (Logic file absent, 0 references outside `docs/features/`) |
| AC-10 | verified | Forwarder suite (8 passed): `holds no param block and the settled statement sequence`, `exits 1 with the canonical ValidateRange error for -SampleCap 0`, `exits 1 with the canonical ValidateSet error for -Mode Bogus`, `propagates an explicit target exit code`, `exits 0 after a normal target run`, `exits 0 when the target leaves a failed native exit code` |
| AC-11 | verified | SkillContract: `lists every skill-folder file exactly once in core.json`, `mirrors every skill-folder file byte-identically in the bundle`; `evidence/other/bundle-hashes.2026-11-07T00-19.md` |
| AC-12 | pending-CI | Local: the five contract modules pass (106 passed). CI: `CI Required Gate` on the PR head; checked off by the orchestrator |
| AC-13 | verified | Read of `config/poshqc-coverage.json` above |
| AC-14 | verified | State: `resets to now and the current done count`, `keeps a passed start on reset`, `keeps the weekly baseline on reset`; entry: `clears stored samples and writes the resolved baseline with -ResetBaseline` |
| AC-15 | verified | State: `keeps s13, s11, s9, s7, s5, s3 and s1 of 14 samples`, `reduces 13 samples to 7`, `reduces 2 samples to 1`, `leaves 1 and 0 samples unchanged`, `leaves 4 samples after two applications to 14`, `reproduces the recorded 5-minute to 10-minute example`; entry: `rewrites the stored samples in pairs with -PairSamples` |
| AC-16 | verified | Entry: `throws before any I/O when -ResetBaseline and -PairSamples are combined`, `throws before any git call without a passed or stored start`, `uses the stored start when -StartUtc is absent` |
| AC-17 | verified | State: `defaults the state path under .claude/state of the repository root`; entry: `writes only the state file at -StatePath`, `writes nothing when the state write runs with WhatIf`, `confines file writes to Write-EpicProgressState` |
| AC-18 | verified | State: `reads a legacy sample array`, `reads a version-1 document`, `treats blank text as empty state`, `treats unparseable text as empty state`, `treats an unknown version as empty state`, `treats missing fields as absent`, `round-trips integer epoch seconds` |
| AC-19 | verified | Entry: `does not write the state file within 90 seconds of the last sample` (unchanged) |
| AC-20 | verified | Metrics suite (20 passed, including `returns NaN for exactly 2 intervals and a finite value for 3 or more` and the bounded-range and no-upper-bound cases); entry mode cases `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode` |
| AC-21 | verified | Metrics: `prints n/a hrs to no upper bound for zero-rate intervals` |
| AC-22 | verified | Render: `prints no NaN or Infinity before the first task completes` and the `non-finite values print n/a` context |
| AC-23 | verified | `composes the four TL;DR lines`, `composes the Full lines in recovered order`, `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode` (expected strings unchanged from the merge base), and `prints the Full golden for a legacy four-sample state` (lines from `evidence/baseline/full-golden-legacy-state.2026-11-06T23-50.md`) |
| AC-24 | verified | `evidence/qa-gates/it-name-comparison.2026-11-07T01-05.md` |
| AC-25 | verified | Entry: `documents every parameter in comment-based help` (15 parameters), `carries at least one example` |
| AC-26 | verified | Entry: `confines native commands to their wrappers`, `passes only fetch, show and worktree list to git`, `passes only pr list to gh`, `confines file writes to Write-EpicProgressState` |
| AC-27 | verified | `evidence/qa-gates/file-size.2026-11-07T01-05.md` (every file below 700) |
| AC-28 | verified | `evidence/qa-gates/scope-diff.2026-11-07T00-59.md` (0 forbidden paths, no `.py`) |
| AC-29 | verified | `evidence/regression-testing/pester-shuffled-order.2026-11-07T01-04.md` (seeds 7, 41, 1093, 0 failures); `evidence/regression-testing/pester-single-process.2026-11-07T01-27.md` (touched suites 0 failures) |
| AC-30 | pending-CI | Local: `evidence/qa-gates/coverage-delta.2026-11-07T01-04.md` (all six files at or above 85 percent). CI: `CI Required Gate` on the PR head; checked off by the orchestrator |
| AC-31 | pending-CI | Local: format, analyze, Pester, contract, and file-size gates pass. CI: `CI Required Gate` on the PR head; checked off by the orchestrator |

## user-story.md

| ID | Status | Proof |
|---|---|---|
| US-AC-01 | verified | as AC-01, AC-02 |
| US-AC-02 | verified | as AC-03, AC-04 |
| US-AC-03 | verified | as AC-05 |
| US-AC-04 | verified | as AC-16 |
| US-AC-05 | verified | as AC-21, AC-22, AC-23 |
| US-AC-06 | verified | as AC-07 |
| US-AC-07 | verified | as AC-06 (reset section) and AC-14 |
| US-AC-08 | verified | as AC-06 (cadence section) and AC-15 |
| US-AC-09 | verified | as AC-06 (stopping and restart sections) |
| US-AC-10 | verified | as AC-17 and AC-18; the skill's `## State File` section states the location, override, no commit, and legacy read |
| US-AC-11 | pending-CI | Local: AC-07 and AC-11 verified, contract modules pass. CI: `CI Required Gate` on the PR head; checked off by the orchestrator |
| US-AC-12 | verified | as AC-08 and AC-26 |
| US-AC-13 | verified | SkillContract `## Prerequisites` content (PowerShell 7, git, optional gh and cswap, kickoff and checkpoint locations); the skill invokes only the bundled canonical path (AC-09, AC-11) |
| US-AC-14 | verified | as AC-10 |
| US-AC-15 | pending-CI | Local: AC-24, AC-27 verified and the coverage delta passes. CI: `CI Required Gate` on the PR head; checked off by the orchestrator |

## Check-off result

- `spec.md`: 28 checked, 3 unchecked (AC-12, AC-30, AC-31).
- `user-story.md`: 13 checked, 2 unchecked (US-AC-11, US-AC-15).
