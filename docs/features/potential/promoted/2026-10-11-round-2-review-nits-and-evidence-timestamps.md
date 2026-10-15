# round-2-review-nits-and-evidence-timestamps (Issue #903)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/round-2-review-nits-and-evidence-timestamps/ (Issue #903)
- Origin: review artifacts of #793 (PR #868), #797 (PR #861), #845 (PR #870), #846 (PR #873) from parallel run bug-burndown-2026-10-08, and epic #852 children #565 (PR #854), #736 (PR #853), #732 (PR #858), #787 (PR #856), #850 (PR #857), #737 (PR #863), #786 (PR #881)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #903
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/903
- Last Updated: 2026-10-11
## Summary

Collection of the remaining minor, low, nit and info review notes from the round-2 items that were accepted as non-blocking and not fixed, plus a recurring evidence-naming defect: evidence filenames carry the plan-time timestamp rather than the time each file was written. All paths are relative to the repository root; review artifacts are in each item's `docs/features/active/<folder>/`.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: n/a (review notes)
- Data source or fixture: main at 2ef8d361

## Steps to Reproduce

1. Open the latest `code-review.*.md` in each listed feature folder.
2. Read the non-blocking rows listed under Actual Behavior.
3. For the timestamp defect, compare an evidence file's filename timestamp with its internal `Timestamp:` line and `git log --diff-filter=A --format=%cI -- <file>`.

## Expected Behavior

Accepted non-blocking review notes are tracked to resolution or explicitly closed as no action, and evidence filenames reflect when each file was written, as required by the evidence-and-timestamp conventions.

## Actual Behavior

Open review notes (spot-checked on main where marked "verified"):

- #793 `code-review.2026-10-09T01-30.md`: L20 (Low) a loop inside one test in `test_validate_epic_orchestrator_state_merge_status.py` stops at the first failing status; L21 (Low) `expected_repr` used only as the assert message; L22 (Low) the test imports helpers from two sibling test modules; L24 (Info) the spec repro uses key `folder` where the validator reads `feature_folder`.
- #797 `code-review.2026-10-09T07-51.md`: L20 CR-1 (Low) Python `str.lower()` vs .NET `ToLowerInvariant()` differ for some non-ASCII characters (U+0130); L21 CR-2 (Low) `.claude/rules/parallel-orchestration.md` "Known false negatives" item 7 is under the wrong lead-in (and in the mirror); L22 CR-3 (Info) parity pins regex-scrape the Python source; L23 CR-4 (Info) bare `assert` without message in `test_blast_radius_token_shapes.py`.
- #845 `code-review.2026-10-09T21-30.md`: L35 CR-1 (Minor) `test_workflow_npm_token_guard.py` is 497 of 500 lines (verified); L36 CR-2 (Minor) no rows for `[ $NPM_TOKEN = "" ]`, `=~`, `NPM_TOKEN+=x`; L37 CR-3 (Minor) no row for the `NPM_TOKEN==value` narrowing.
- #846 `code-review.2026-10-10T03-00.md`: L22 CR-1 (Minor) no exact QT009 text test (`test_check_quality_tiers.py:193-215`); L23-25 CR-2..CR-4 (Nit) `PublishMcpNpmWorkflow.Tests.ps1` `[^}]*` regex at 111, 127, 227, duplicated `exit 1` asserts at 126-127 and 226-227, only `^\s+if:` lines read at 240-242; L26 CR-5 (Nit) `subagent-tree-command.quick-pick.test.ts` import after a type alias (13-15) and no `// Assert` at 181; L27 CR-6 (Nit) host-specific `WORKSPACE_ROOT` at `subagent-tree-command-test-support.ts:11`; L28 CR-7 (Nit) wrong rationale in closure-disposition rows "#734 CR-1" and "#723 N3".
- #565 `code-review.2026-10-08T20-57.md`: L39 CR-8 (Minor) `Find-OrchestrationModeRecord` falls back to an issue-number match when `Record` is null; L40 CR-9 (Minor) gate main files edited at 386-393 (Claude) and 427-434 (Codex) although the spec excluded them; L41 CR-2 (Minor) `feature-folder-resolution.ps1` does not trim `)` or emphasis characters (false `Ambiguous`); L44 CR-10 (Info) the Codex keyed regex rejects `issue number:`; L45 CR-6 (Info) nine uncovered catch-body lines.
- #736 `code-review.2026-10-08T22-30.md`: L65 O-4 (Low) the Claude entrypoint has no outer guard beyond the reader call; L66 O-5 (Info) invalid-JSON divergence retained (Claude allows, Codex denies).
- #732 `code-review.2026-10-09T05-42.md`: L25-29 CR-2..CR-6 (Low) in `enforce-orchestration-preimplementation-gate-targets.ps1`: `GIT_DIR` substring check over-matches; epic-scope logic duplicated across Claude and Codex; nine lines over 120 characters (max 196 at line 152); `Get-OrchestrationTargetResult` uses the wrong verb; first-`git` token lookup via `IndexOf`. L32 CR-9 (Info) `.agents/skills/epic-plan/SKILL.md` lacks the multi-`-m` trailer form.
- #787 `code-review.2026-10-09T00-12.md`: L34 CR-1 (Minor) `-ccontains` case mismatch at `validate-orchestrator-output-resolution.ps1:150-162`; L36 CR-3 (Minor) unguarded resolver exception at `validate-orchestrator-output.ps1:476-480`; L37 CR-4 (Info) `Rejected` status not in the spec; L40 CR-7 (Info) stale "One subprocess call" comment, now at line 431 (verified).
- #850 `code-review.2026-10-09T01-12.md`: L19 a body PR number above `Int32.MaxValue` throws and exits 1 in `enforce-pr-author-skill.artifact-root.ps1`; L20 the unparseable `pr_gate.pr_number` branch is uncovered; L21 new `PSUseSingularNouns` suppression; L22 duplicated positive-JSON-integer rule; L23 `[long]` vs `[int]` TryParse; L25 stale `.NOTES` text "No external module dependencies" at `enforce-pr-author-skill.ps1:39` (verified).
- #737 `code-review.2026-10-09T06-46.md`: L37-42 F-1..F-6 (Minor): a `Mock` inside an `if` body counts as a direct statement; dot-source fallback uses the first dot-source; discovery depends on literals; Codex context environment injection; the divergent row does not drive the Python-equality assert; script-scope `EpicStateParseCache` memo. L43 N-1 (Nit) `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1:5-6` refers to a nonexistent file (verified); L44 N-2 (Nit) `-Surface 'Codex'` in a Claude suite (`...TargetResolution.Tests.ps1:101`); L47 I-3 (Info) four test files at exactly 500 lines.
- #786 `code-review.2026-10-10T22-23.md`: L39 (Minor) the polluting earlier suite is not identified (`hook-dependency-failure.Codex.Tests.ps1:40-42`); L40 (Minor) stale "AC-6 GAP" line in an evidence file; L41 (Minor) 4.7 MB of probe output committed, and its Verdict timestamp is later than the halt commit; L42 (Minor) double `OrchestratorState.psm1` import at `validate-orchestrator-output.ps1:51,59` (verified); L43 (Minor) CONVERT basis not stated; L44-46 (Nit) overly broad `SilentlyContinue`, always-true conditional in the H4-H6 catch blocks, `finally` resets variables that no longer exist (`FailClosed.Tests.ps1:453,468`). Info: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is exactly 500 lines (verified).

Evidence filename timestamps that do not match when the file was written:

| Item | Mismatched | Example | Filename | Internal `Timestamp:` | Added in commit |
|---|---|---|---|---|---|
| #849 | 51 / 51 | `evidence/qa-gates/diff-scope.2026-10-09T01-33.md` | 2026-10-09T01-33 | 2026-10-10T15-15 | 2026-10-10T11:07-04:00 |
| #841 | 46 / 46 | `evidence/qa-gates/ac-verification.2026-10-08T22-17.md` | 2026-10-08T22-17 | 2026-10-10T09-46 | 2026-10-10T09:45-04:00 |
| #846 | 91 / 91 | `evidence/qa-gates/ac-status.2026-10-09T09-00.md` | 2026-10-09T09-00 | 2026-10-09T22-05 | 2026-10-09T22:06-04:00 |
| #794 | 47 / 47 | `evidence/other/ac-status-summary.2026-10-08T21-25.md` | 2026-10-08T21-25 | 2026-10-09T07-25 | 2026-10-09T03:22-04:00 |
| #736 | 37 / 38 | `evidence/remediation-baseline/base-sha.2026-10-08T23-15.md` | 2026-10-08T23-15 | 2026-10-08T18-56 | 2026-10-08T18:59-04:00 |

The internal timestamps also mix time zones: #841 and #846 match local -04:00 commit times, while #849's internal 15:15 matches UTC.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `artifacts/orchestration/parallel-orchestrator-state.json` lines 97 and 132 (run worktree) list "793/797/845 low review notes" and "846 CR-1" as end-of-run follow-ups.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low. Each note is individually minor. Several files are at or near the 500-line limit, so the next change to them will need a split. Misdated evidence filenames make it harder to order evidence and audit when a result was captured.

## Suspected Cause / Notes

- Plans fix one plan-time STAMP and executors name every evidence file with it regardless of when the file is written.
- Review notes accepted as non-blocking are not carried to a tracking issue automatically.
- The #793, #797 and #845 folders showed no filename mismatches by the internal-`Timestamp:` check; the git-time comparison was not run on them.

## Proposed Fix / Validation Ideas

- [ ] Triage each note above: fix, or close with an explicit no-action rationale.
- [ ] Split or trim files at or near 500 lines (`test_workflow_npm_token_guard.py`, the four 500-line test files from #737, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`).
- [ ] Amend the atomic-plan contract so evidence filenames use the write-time UTC timestamp (or a plan STAMP plus a write-time suffix), and state one time zone for internal `Timestamp:` lines.
- [ ] Unit coverage areas: an evidence-name check comparing the filename timestamp with the commit time within a tolerance.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch