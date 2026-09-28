# Final QA Gate 6 — Single Uninterrupted Clean Pass Confirmation (issue #516)

Timestamp: 2026-08-24T16-36
Command: ordering and outcome review of [P4-T1] through [P4-T5], plus the hash comparisons each of those tasks recorded
EXIT_CODE: 0

## The Confirmed Clean Pass

[P4-T1] through [P4-T5] completed in that order, in a single uninterrupted sequence, with no stage failing and no stage rewriting a file:

| Order | Task | Stage | Command | Exit code | Rewrote a file |
| --- | --- | --- | --- | --- | --- |
| 1 | [P4-T1] | Format | `mcp__drm-copilot__run_poshqc_format` (no `scan_folders`) | **0** | **No** |
| 2 | [P4-T2] | Analyze | `mcp__drm-copilot__run_poshqc_analyze` | **0** | **No** |
| 3 | [P4-T3] | Type check | not applicable to PowerShell; skipped on the authority of `.claude/rules/powershell.md` | 0 | No |
| 4 | [P4-T4] | Test | `mcp__drm-copilot__run_poshqc_test` (no `scan_folders`) | **0** | **No** |
| 5 | [P4-T5] | Parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | **0** | **No** |

Results in that pass: zero files reformatted, zero PSScriptAnalyzer findings, 3476 Pester tests passed with 0 failed and 0 errored, and 10 of 10 pytest cases passed.

## Explicit Statement Required by [P4-T6] Regarding Formatter Rewrites

[P4-T6] requires this artifact to state explicitly whether any rewrite confined to paths named under `PRE-EXISTING FORMATTER DRIFT` in the [P0-T8] artifact occurred and was restored within [P4-T1].

**No such rewrite occurred.** The [P0-T8] artifact names zero paths under that heading, because the baseline format run rewrote nothing. The [P4-T1] artifact likewise names zero paths, because the final format run rewrote nothing. No `git checkout --` restoration was performed at any point in this execution. The subset condition is satisfied trivially: the empty set is a subset of the empty set.

The proof that [P4-T1] rewrote nothing is a SHA256 comparison of all six PowerShell files taken immediately before and immediately after the run, which is stronger than a `git status` check because it also covers the two new test suites, which are untracked and whose content `git status` cannot compare.

## Restart History — two restarts occurred before this pass, both correctly handled

The rule in `.claude/rules/powershell.md` is to restart from step 1 whenever a stage fails or changes files. Two stages did so, and each triggered a restart rather than being recorded as the final pass. Both are disclosed here in full rather than presented as a first-attempt success.

### Attempt 1 — analyze failed

- Format: exit 0, rewrote nothing.
- **Analyze: exit 1** — `PSScriptAnalyzer reported 4 issue(s)`, all `PSUseShouldProcessForStateChangingFunctions`, on the `New-*` builder helpers in the two new suites.
- Remedy: renamed those helpers to the `ConvertTo` verb already used by the existing sibling suite for the same purpose. Files changed, so the pass was abandoned and the toolchain restarted from format.
- Detail recorded in `evidence/qa-gates/final-poshqc-analyze.2026-08-23T23-25.md`.

### Attempt 2 — test failed

- Format: exit 0, rewrote nothing (all six hashes bit-identical).
- Analyze: exit 0, zero findings.
- **Test: exit 1** — one failure, in the repository-wide guard `test-name-uniqueness.Tests.ps1`: both new suites reused the `It` name template `'allows the <Spelling> spelling of <Literal>'` across two different `-ForEach` matrices, producing a colliding folded adapter ID within each file.
- Remedy: renamed the second matrix's `It` template to `'admits the <Spelling> spelling of <Literal>'` in each suite. No case data, case count, or assertion changed. Files changed, so the pass was abandoned and the toolchain restarted from format.
- Detail recorded in `evidence/qa-gates/final-poshqc-test.2026-08-23T23-25.md`.

### Attempt 3 — the clean pass recorded above

Both defects were in the two new test files authored by this item, not in any hook copy. Across both remedies the four hook hashes never changed: `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207` for the Claude pair and `98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD` for the Codex pair, from the moment each was written through to the end of this pass. The production change was correct on its first pass; both restarts were caused by test-file defects.

## Acceptance Condition

> Confirm that P4-T1 through P4-T5 completed in that order within a single uninterrupted pass with no stage failing and no stage rewriting a file.

**Satisfied.** Attempt 3 is that pass. Attempts 1 and 2 are recorded above as required by the task's instruction to record each attempt, and neither is claimed as the final pass. No stage in the recorded pass failed, no stage rewrote a file, and [P4-T1] did not rewrite any of the seven declared paths, so no further restart is required.

Output Summary: The format → analyze → test → parity sequence completed in order in a single uninterrupted pass with every stage exiting 0, no stage failing, and no stage rewriting a file: 0 files reformatted, 0 analyzer findings, 3476 Pester tests passed with 0 failed and 0 errored, and 10 of 10 pytest cases passed. No formatter rewrite of any kind occurred, so no path was restored and both the [P0-T8] and [P4-T1] `PRE-EXISTING FORMATTER DRIFT` sets are empty. Two earlier attempts were abandoned and restarted from format — one on 4 analyzer warnings and one on a test-name uniqueness guard failure, both defects in the new test files and neither touching a hook copy — and each attempt is recorded above.
