# Acceptance-Criteria Check-Off Mapping — [P5-T2], Issue #518

Timestamp: 2026-08-26T07-11
Agent: atomic-executor
Branch: `bug/prd-feature-gate-resolves-nested-artifact-as-feature-folder-518`
AC source: `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`,
`## Acceptance Criteria` section (lines 327-393).

## Work Mode and Source Resolution

The `- Work Mode:` marker in `issue.md` reads `full-bug`. Under
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves the acceptance-criteria source
to `spec.md` only. `user-story.md` is correctly absent from the feature folder and was not created.

## Verification Posture

The feature review (`feature-audit.2026-08-26T06-55.md`) evaluated all 38 criteria as PASS. This check-off
did not accept that tally wholesale. Each criterion below was re-inspected against the artifact or the
`It` name it cites, using the checks listed under "Independent checks performed" at the end of this
document. Every criterion held. No criterion was left unchecked.

Two test-file `It` names cited by the review were renamed at close-out under finding NB-5 and appear below
under their new names; their assertions are unchanged. No criterion depends on either name.

Short forms used below:

- `FR` = `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`
- `PT` = `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
- `HOOK` = `.claude/hooks/enforce-prd-feature-before-planner.ps1`
- `MIRROR` = `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
- Evidence paths are relative to the feature folder.

Both test files ran green in the close-out suite: `FR` 25 tests / 0 failures / 0 skipped, `PT` 47 tests /
0 failures / 0 skipped. See `evidence/qa-gates/close-out-verification.2026-08-26T07-11.md`.

## Mapping

### Folder resolution

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 1 | Same four-segment folder for all four prompt forms; a passing case for each | `FR`: `It 'resolves the same folder when the prompt cites the feature folder alone'`, `It 'resolves the same folder when the prompt cites a research artifact path'`, `It 'resolves the same folder when the prompt cites an evidence artifact path'`, `It 'resolves the folder from a nested artifact path with no folder citation'` |
| 2 | Same decision for all four prompt forms | `FR`: `It 'returns the same decision for all four prompt forms'` |
| 3 | Reproduction differential passes | `FR`: `It 'returns the same decision for folder-relative and repo-relative research paths'`; pre-fix divergence independently re-measured against the resolver extracted from commit `22c702cf`, recorded in `feature-audit.2026-08-26T06-55.md` ("Regression-Property Verification") |
| 4 | `Sort-Object -Property Length -Descending` absent from `HOOK` and `MIRROR` | `git grep -n -F "Sort-Object -Property Length -Descending" -- HOOK MIRROR` exits 1 (re-run at close-out); `evidence/regression-testing/verify-selection-rule-removed.2026-08-26T06-26.md` |
| 5 | `.md`-implies-parent branch removed; the pre-existing case still passes | Branch absent from `HOOK` lines 251-308 (truncation only); `PT`: `It 'strips .md suffix to a folder parent'` retained unmodified and passing, and `It 'treats a path ending in .md as a file and uses its parent directory'` likewise |
| 6 | Order-preserving deduplication, not a `[hashtable]`; case for one folder at three depths | `HOOK` lines 258-281 use `System.Collections.Generic.List[string]` with a `Contains` guard; `FR`: `It 'yields one distinct candidate when one folder is cited at three depths'` |
| 7 | Token truncating to fewer than four segments rejected | `HOOK` lines 272-275 (`.` components discarded, `$segments.Count -lt 4` continues); `FR`: `It 'rejects a token that truncates to fewer than four segments'` |

### Deterministic selection among two feature folders

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 8 | Checkpoint-recorded folder wins; a case where it occurs later in the prompt | `HOOK` lines 293-302; `FR`: `It 'prefers the checkpoint folder when it occurs later in the prompt'` |
| 9 | Earliest occurrence wins when the checkpoint is null or not a candidate; a case for each | `HOOK` lines 304-307; `FR`: `It 'uses the earliest candidate when the checkpoint folder is absent'` and `It 'uses the earliest candidate when the checkpoint folder is not a candidate'` |

### Work mode and prerequisite sets

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 10 | `full-bug` with `spec.md` present and `user-story.md` absent is ALLOWED, including with a nested research citation | `FR`: `It 'allows full-bug with spec present and user-story absent citing a nested research artifact'` (the reproduction from the issue) |
| 11 | `full-feature` with no `spec.md` still DENIES | `FR`: `It 'denies full-feature when spec.md is missing'` |
| 12 | `full-bug` with no `spec.md` still DENIES | `FR`: `It 'denies full-bug when spec.md is missing'` |
| 13 | `full-feature` with `spec.md` present and `user-story.md` absent still DENIES, naming `user-story.md` | `FR`: `It 'denies full-feature when user-story.md is missing and names it'` |
| 14 | `minor-audit` allowed with neither file; legacy `full` still normalizes to `full-feature` | `FR`: `It 'allows minor-audit when neither prerequisite file is present'` and `It 'normalizes the legacy full marker to the full-feature prerequisite set'` |
| 15 | No decision path returns an empty prerequisite set as a fail-closed default; the fail-open lock still passes | `HOOK` `Get-PrdFeatureRequiredFile` default arm returns `@('spec.md')`; `PT` `Context 'fail-closed prerequisite resolution (AC: unable to determine work mode)'` (the lock at baseline lines 350-357) retains all four `It` cases, all passing. `minor-audit` returns an empty set, but that is a *determined* mode, not a fail-closed default. The two default-arm cases are `PT`: `It 'returns spec.md alone for a $null mode so no reachable path can demand user-story.md'` and `It 'returns spec.md alone for an unrecognized mode string so no reachable path can demand user-story.md'` (renamed at close-out under NB-5; assertions unchanged) |

### Indeterminate work-mode marker

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 16 | Distinct block reason for absent, unreadable, and unrecognized markers; a case for each | `FR`: `It 'denies with the indeterminate-marker reason when the marker line is absent'`, `It 'denies with the indeterminate-marker reason when issue.md is unreadable'`, `It 'denies with the indeterminate-marker reason when the marker value is unrecognized'` |
| 17 | Reason names the resolved folder and the `issue.md` path, and states marker repair as the remedy | `HOOK` lines 403-407; `FR`: `It 'names the resolved folder and the issue.md path in the indeterminate reason'` |
| 18 | Reason contains no missing-file list and names neither document | `FR`: `It 'omits spec.md and user-story.md from the indeterminate reason'` |
| 19 | The required-file probe is not executed in the indeterminate branch | `HOOK` returns at line 398 before `Get-PrdFeatureMissingFile` is reached; `FR`: `It 'does not invoke the file-existence probe in the indeterminate branch'` (`Should -Invoke ... -Times 0 -Exactly`) |
| 20 | The indeterminate branch still DENIES | `HOOK` line 402 sets `permissionDecision = 'deny'`; asserted by all six indeterminate cases in `FR` and by the four cases in `PT`'s fail-closed context |

### Block message

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 21 | Missing-prerequisite reason names the folder before any remedy text | `HOOK` lines 422-428 (folder leads the reason); `FR`: `It 'names the resolved folder ahead of the prd-feature remedy phrase'`, an ordinal `IndexOf` ordering assertion |
| 22 | Every deny reason retains the `PRD_FEATURE_BLOCKED:` prefix | All four deny return sites carry the prefix (`HOOK` lines 354, 377, 403, 426); `FR`: `It 'retains the PRD_FEATURE_BLOCKED prefix on every deny reason'` |

### Bundle parity

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 23 | The two hook copies are textually identical after the change | `git hash-object` returns `60d303759e07cf7156b9bfb8bb5cd38f65266428` for both copies after the NB-3 close-out edit; `cmp` reports no difference; both are 448 lines. Artifact: `evidence/qa-gates/close-out-verification.2026-08-26T07-11.md` step 4. The pre-close-out value recorded by the review was `469fecca912e3be687a123b8a3e33ce8a7f327c6`; the value changed because NB-3 edited both copies, and the property under test is hash **equality between the two copies**, which holds |
| 24 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes without modification to the test | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` does not appear in `git diff --name-status origin/main..HEAD`, so the test is unmodified. It reported 10 passed / 0 failed in the [P4-T4] run (`evidence/qa-gates/qc-bundle-parity.2026-08-26T06-32.md`) and in the post-rebase re-verification. **Recorded condition:** the suite's exit code is conditional on untracked, gitignored `.claude/state/*.json` batch-budget counters that the repository's own PreToolUse hooks regenerate on any agent file edit. When those counters are present the suite reports 9 passed / 1 failed on an assertion naming only a `.claude/state/` path. That is the pre-existing defect tracked as OPEN issue **#510** ("Bug: claude-resource-parity-enumerates-gitignored-state"); it is not introduced by this branch and is invisible to CI, whose checkout is fresh and does not invoke the Claude PreToolUse hooks. Counters were regenerated again by the close-out edits, so the suite was deliberately not re-run as a gate at close-out. The durable evidence for the same parity property is criterion 23 |

### Scope containment

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 25 | Three sibling hooks, their mirrors, and their three test files unmodified | None of the nine paths appears in `git diff --name-status origin/main..HEAD`, re-run at close-out; `evidence/regression-testing/verify-write-set.2026-08-26T06-26.md` |
| 26 | `enforce-feature-folder-order.ps1`, its mirror, and its test unmodified | None of the three paths appears in the branch diff |
| 27 | `.claude/settings.json`, its mirror, `pack-manifests/core.json`, and both `pester.runsettings.psd1` copies unmodified | None appears in the branch diff. The recent change to both `pester.runsettings.psd1` copies is attributable to `a7e5606e` on `origin/main`, not to this branch |
| 28 | `PreToolUseSchema.Contract.Tests.ps1` passes without modification | Not in the branch diff; included in the 3680-test close-out suite with 0 failures |
| 29 | Three follow-up issues for the sibling hooks and one for the `enforce-feature-folder-order.ps1` defects are filed | Confirmed independently at close-out by `gh issue list --state open`: **#565** epic-wave-barrier, **#566** parallel-cohort-barrier, **#567** parallel-drift-gate, **#568** feature-folder-order work-mode and plan-filename defects, all OPEN. Artifact: `evidence/issue-updates/follow-up-issues.2026-08-26T07-05.md`. The filing mechanism was the MCP promotion route rather than the command named in the plan text, which is hook-denied; that deviation does not affect this criterion |

### Toolchain, coverage, and file size

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 30 | Format reports no reformatting needed on a clean pass | `evidence/qa-gates/qc-poshqc-format.2026-08-26T06-32.md`; re-run at close-out with `ok: true` and no file reformatted, `evidence/qa-gates/close-out-verification.2026-08-26T07-11.md` step 1 |
| 31 | Analyze reports zero PSScriptAnalyzer findings | `evidence/qa-gates/qc-poshqc-analyze.2026-08-26T06-32.md`; re-run at close-out with `ok: true` and zero findings, `close-out-verification.2026-08-26T07-11.md` step 2 |
| 32 | Zero Pester failures; all three stages pass in a single consecutive run with no re-fix between | `evidence/qa-gates/qc-consecutive-pass.2026-08-26T06-32.md`, re-established post-rebase by `evidence/qa-gates/post-rebase-toolchain-reverification.2026-08-26T06-55.md`, and re-established again at close-out: format, analyze, and test ran consecutively with no file edit between them, 3671 passed / 0 failed / 9 skipped (`close-out-verification.2026-08-26T07-11.md`) |
| 33 | Line coverage >= 85 % overall and for the hook | Parsed from `artifacts/pester/powershell-coverage.xml` at close-out: overall **96.17 %** (6696 / 6963), hook **91.35 %** (95 / 104). No branch threshold applies to PowerShell per `.claude/rules/quality-tiers.md` |
| 34 | No coverage regression on changed lines | `evidence/qa-gates/coverage-comparison.2026-08-26T06-32.md`: hook missed-line count 9 at baseline and 9 after; per-file 90.32 % to 91.35 %; changed-line coverage 100.00 % (24 of 24 analyzable) |
| 35 | Baseline, regression, and QA-gate evidence written under the three named trees | `evidence/baseline/` (6 artifacts), `evidence/regression-testing/` (6), `evidence/qa-gates/` (8 including the two written at close-out), plus `evidence/issue-updates/` (1) and `evidence/other/` (2). Zero paths under `artifacts/` appear in the branch diff |
| 36 | Every changed file under 500 lines; companion-file rule applied if needed | Close-out `wc -l`: `HOOK` 448, `MIRROR` 448, `PT` 431, `FR` 419. The companion file was created, which is the correct branch of the rule; decision recorded in `evidence/other/test-placement-decision.2026-08-26T05-34.md`. Also `evidence/qa-gates/post-change-line-counts.2026-08-26T06-19.md` |
| 37 | At most 2 production PowerShell files; no override requested | The branch diff modifies exactly two production `.ps1` files (`HOOK` and the mandatory bundled `MIRROR`), plus two test files. Within the 2-file direct-mode cap at `.claude/rules/powershell.md:37-40`. No override was requested |

### Documentation

| # | Criterion (abridged) | Evidence |
| --- | --- | --- |
| 38 | Comment-based help no longer describes longest-match or the `.md`-parent strategy, and states truncation, the checkpoint-then-earliest-occurrence rule, and the version-folder limitation | `HOOK` lines 14-40: truncation "to two segments past the `docs/features/active/` prefix -- that is, to exactly four path segments", the two-tier selection rule with its justification, and the version-folder limitation. `git grep -F "The longest match wins"` returns no match in either hook copy (only in feature documentation). Function-level help states the same contract |

## Independent checks performed at close-out

1. `git diff --name-status origin/main..HEAD` — full branch write set, used for criteria 24 through 29, 35, and 37.
2. `git grep -n -F "Sort-Object -Property Length -Descending"` scoped to the two hook copies — exit 1 (criterion 4).
3. `git grep -n -F "The longest match wins"` repository-wide — matches only feature documentation, neither hook copy (criterion 38).
4. Direct read of `HOOK` lines 12-40 and 240-308 and 414-437 — resolution, selection, deduplication, truncation rejection, and message ordering (criteria 5 through 9, 21, 38).
5. Enumeration of every `It` name in both test files — all names cited by criteria 1 through 22 exist (criteria 1 through 22).
6. Per-suite JUnit read of both test files — `FR` 25/0/0 and `PT` 47/0/0.
7. `git hash-object` on both hook copies plus `cmp` — equal hashes, no byte difference (criterion 23).
8. `wc -l` on all four changed PowerShell files — 448 / 448 / 431 / 419 (criterion 36).
9. `gh issue list --state open` filtered to 565-568 — all four present and OPEN (criterion 29).
10. Direct parse of `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` (criteria 32, 33).
11. Read of `evidence/qa-gates/coverage-comparison.2026-08-26T06-32.md` (criterion 34).
12. Diff inspection of the check-off edit itself: 38 insertions and 38 deletions, and each criterion's text appears identically on both sides of the diff, confirming that only the `- [ ]` to `- [x]` marker changed.

## Acceptance Criteria Status

```text
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md
- Total AC items: 38
- Checked off (delivered): 38
- Remaining (unchecked): 0
- Items remaining: none
- Note: criterion 24 is checked off with the recorded environmental condition above (issue #510). The
  durable evidence for the same parity property is criterion 23.
```

The three remaining `- [ ]` checkboxes elsewhere in `spec.md` are the severity-selection list in the
document header (Blocker / Medium / Low). They are not acceptance criteria and were not modified.
