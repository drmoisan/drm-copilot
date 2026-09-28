# Feature Audit — Issue #518

Timestamp: 2026-08-26T06-55
Reviewer: feature-review
Branch: `bug/prd-feature-gate-resolves-nested-artifact-as-feature-folder-518` @ `2ae27c01`
Base: `origin/main` @ `b5a7490b`

## Work Mode and Acceptance-Criteria Source

The `- Work Mode:` marker in `issue.md` line 12 reads `full-bug`. Under
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves the acceptance-criteria
source to **`spec.md` only**. `user-story.md` is correctly absent from the feature folder and must
remain absent; its presence would be a lifecycle-integrity failure. Verified: no `user-story.md` exists
in the feature folder and none is added by the branch.

`spec.md` carries **38** checkbox items under the `## Acceptance Criteria` heading, all currently
unchecked. This matches the count stated in the plan's [P5-T2] task.

## Check-Off Status

Per the review directive, **no acceptance criterion was checked off by this review**. [P5-T2] is the
designated check-off task and is the next step. Each criterion below carries a verdict and the evidence
that supports it, so the check-off can cite this audit rather than re-derive the evidence.

## Verification Method

Every verdict below was reached by direct measurement against the working tree at `2ae27c01`, not by
transcription from the evidence artifacts. Specifically:

- Both hook test files were executed: `Invoke-Pester` reports **72 tests, 0 failed, 0 skipped**.
- The full-suite result was read from `artifacts/pester/pester-junit.xml`:
  `tests="3680" errors="0" failures="0" disabled="9"`.
- Coverage was parsed from `artifacts/pester/powershell-coverage.xml` by the reviewer: repo-wide
  **96.17 %**, hook **91.35 %**.
- Formatting was re-checked with `Invoke-Formatter` against the repository PSSA settings; linting with
  `Invoke-ScriptAnalyzer` (0 findings).
- Bundle parity was checked by `git hash-object` and `cmp`.
- Scope containment was checked against `git diff --name-status origin/main..HEAD`.
- Follow-up issues were confirmed with `gh issue list`.
- The pre-fix behaviour of the two corrected test prompts was re-measured against the resolver extracted
  from commit `22c702cf`.

## Acceptance-Criteria Evaluation

### Folder resolution

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Same four-segment folder for all four prompt forms; a passing case for each | **PASS** | `FolderResolution.Tests.ps1:30-54`, four `It` blocks, all passing in the reviewer's run |
| 2 | Same decision for all four prompt forms | **PASS** | `It 'returns the same decision for all four prompt forms'` (lines 119-149); asserts equal `permissionDecision` and equal `permissionDecisionReason` across all four |
| 3 | Reproduction differential passes | **PASS** | `It 'returns the same decision for folder-relative and repo-relative research paths'` (lines 151-177); reviewer independently confirmed both arms diverge under the pre-fix resolver |
| 4 | `Sort-Object -Property Length -Descending` absent from hook and mirror | **PASS** | `git grep` returns 0 matches in both target files; the six residual matches are confined to the three out-of-scope sibling hooks and their mirrors |
| 5 | `.md`-implies-parent branch removed; the case at baseline `:194-196` still passes | **PASS** | branch deleted (hook diff); `It 'strips .md suffix to a folder parent'` retained unmodified and passing |
| 6 | Order-preserving deduplication; case for one folder at three depths | **PASS** | `List[string]` with `Contains` guard at hook lines 261-280; `It 'yields one distinct candidate when one folder is cited at three depths'` (lines 64-79) asserts the resolved value plus zero checkpoint invocations |
| 7 | Token truncating to fewer than four segments rejected; case for `docs/features/active/.` | **PASS** | hook lines 272-275; `It 'rejects a token that truncates to fewer than four segments'` (lines 56-62) |

### Deterministic selection among two feature folders

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 8 | Checkpoint-recorded folder wins; a case where it occurs **later** in the prompt | **PASS** | `It 'prefers the checkpoint folder when it occurs later in the prompt'` (lines 89-95). The expected winner also carries the shorter slug, so a length rule cannot agree by coincidence |
| 9 | Earliest occurrence wins when the checkpoint is null or not a candidate; a case for each | **PASS** | `It 'uses the earliest candidate when the checkpoint folder is absent'` and `It 'uses the earliest candidate when the checkpoint folder is not a candidate'` (lines 97-111) |

### Work mode and prerequisite sets

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 10 | `full-bug` with `spec.md` present and `user-story.md` absent is ALLOWED, including with a nested research citation | **PASS** | `It 'allows full-bug with spec present and user-story absent citing a nested research artifact'` (lines 179-200). This is the reproduction from the issue |
| 11 | `full-feature` with no `spec.md` still DENIES | **PASS** | `It 'denies full-feature when spec.md is missing'` (lines 208-222) |
| 12 | `full-bug` with no `spec.md` still DENIES | **PASS** | `It 'denies full-bug when spec.md is missing'` (lines 224-236) |
| 13 | `full-feature` with `spec.md` present and `user-story.md` absent still DENIES, naming `user-story.md` | **PASS** | `It 'denies full-feature when user-story.md is missing and names it'` (lines 238-252) |
| 14 | `minor-audit` allowed with neither file; legacy `full` still normalizes to `full-feature` | **PASS** | `It 'allows minor-audit when neither prerequisite file is present'` (254-264) and `It 'normalizes the legacy full marker to the full-feature prerequisite set'` (266-281), the latter asserting `work mode: full-feature` in the reason |
| 15 | No decision path returns an empty prerequisite set as a fail-closed default; the fail-open lock still passes | **PASS** | `Get-PrdFeatureRequiredFile` default arm returns `@('spec.md')` (hook line 185); the four cases in the `fail-closed prerequisite resolution` context all pass. `minor-audit` returns an empty set, but that is a *determined* mode, not a fail-closed default |

### Indeterminate work-mode marker

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 16 | Distinct block reason for absent, unreadable, and unrecognized markers; a case for each | **PASS** | three `It` blocks at lines 290-327, each asserting `deny` and the phrase `could not be determined`, which the missing-prerequisite reason does not contain |
| 17 | Reason names the resolved folder and the `issue.md` path, and states marker repair as the remedy | **PASS** | hook lines 402-406; `It 'names the resolved folder and the issue.md path in the indeterminate reason'` (lines 329-344) asserts folder, `issue.md` path, and the `Work Mode:` token |
| 18 | Reason contains no missing-file list and names neither document; a case asserts absence of `user-story.md` | **PASS** | `It 'omits spec.md and user-story.md from the indeterminate reason'` (lines 346-358) asserts `-Not -Match` on `spec\.md`, `user-story\.md`, and `Missing:` |
| 19 | The required-file probe is not executed; a case asserts zero `Get-PrdFeatureFileExistence` invocations | **PASS** | hook returns at line 397 before `Get-PrdFeatureMissingFile` is reached; `It 'does not invoke the file-existence probe in the indeterminate branch'` (lines 360-371) asserts `Should -Invoke ... -Times 0 -Exactly` |
| 20 | The indeterminate branch still DENIES | **PASS** | `permissionDecision = 'deny'` at hook line 401, asserted by all six indeterminate cases and by the three retained cases in `enforce-prd-feature-before-planner.Tests.ps1` |

### Block message

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 21 | Missing-prerequisite reason names the folder before any remedy text; a case asserts the ordering | **PASS** | hook lines 425-427; `It 'names the resolved folder ahead of the prd-feature remedy phrase'` (lines 375-395) uses an ordinal `IndexOf` comparison, which is a genuine ordering assertion rather than a substring presence check |
| 22 | Every deny reason retains the `PRD_FEATURE_BLOCKED:` prefix | **PASS** | all four deny return sites carry the prefix (hook lines 354, 377, 402, 425); `It 'retains the PRD_FEATURE_BLOCKED prefix on every deny reason'` (lines 397-417) drives five payload shapes including malformed and empty input |

### Bundle parity

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 23 | The two hook copies are textually identical after the change | **PASS** | `git hash-object` returns `469fecca912e3be687a123b8a3e33ce8a7f327c6` for both; `cmp` reports no difference; both are 447 lines |
| 24 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes without modification to the test | **PASS, with a recorded condition** | The test file is not in the branch diff, so it is unmodified. It reported 10 passed / 0 failed in the [P4-T4] and post-rebase runs. **Condition:** the reviewer re-ran it and observed 9 passed / 1 failed, because untracked, gitignored `.claude/state/*.json` counters had regenerated. That failure is the pre-existing defect tracked as OPEN issue **#510**, names only a `.claude/state/` path, and is invisible to CI (a runner checkout is fresh and does not invoke the Claude `PreToolUse` hooks). The durable evidence for the parity property is criterion 23. The check-off must cite `#510` by number |

### Scope containment

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 25 | Three sibling hooks, their mirrors, and their three test files unmodified | **PASS** | none of the nine paths appears in `git diff --name-status origin/main..HEAD` |
| 26 | `enforce-feature-folder-order.ps1`, its mirror, and its test unmodified | **PASS** | none of the three paths appears in the branch diff |
| 27 | `.claude/settings.json`, its mirror, `pack-manifests/core.json`, and both `pester.runsettings.psd1` copies unmodified | **PASS** | none appears in the branch diff. The recent change to both `pester.runsettings.psd1` copies is attributable to `a7e5606e fix(526): ...` on `origin/main`, not to this branch; `git diff --name-only origin/main..HEAD` on both paths returns zero |
| 28 | `PreToolUseSchema.Contract.Tests.ps1` passes without modification | **PASS** | not in the branch diff; included in the 3680-test suite with 0 failures |
| 29 | Three follow-up issues for the sibling hooks and one for the `enforce-feature-folder-order.ps1` defects are filed | **PASS** | `gh issue list` confirms **#565** (epic-wave-barrier), **#566** (parallel-cohort-barrier), **#567** (parallel-drift-gate), **#568** (feature-folder-order work-mode and plan-filename defects), all OPEN. Evidence: `evidence/issue-updates/follow-up-issues.2026-08-26T07-05.md`. The mechanism deviated from the plan text (MCP promotion rather than `gh issue create`, which is hook-denied), which does not affect this criterion; see finding NB-2 for a defect in the artifact's own completeness |

### Toolchain, coverage, and file size

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 30 | Format reports no reformatting needed on a clean pass | **PASS** | reviewer re-ran `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` against all three self-hosted files: CLEAN on all three. Artifact: `evidence/qa-gates/qc-poshqc-format.2026-08-26T06-32.md` |
| 31 | Analyze reports zero PSScriptAnalyzer findings | **PASS** | reviewer re-ran `Invoke-ScriptAnalyzer` across all four changed files: `FINDINGS=0`. Artifact: `evidence/qa-gates/qc-poshqc-analyze.2026-08-26T06-32.md` |
| 32 | Zero Pester failures; all three stages pass in a single consecutive run with no re-fix between | **PASS** | `artifacts/pester/pester-junit.xml` root attributes read by the reviewer: `tests="3680" errors="0" failures="0"`. Consecutive-pass attestation: `evidence/qa-gates/qc-consecutive-pass.2026-08-26T06-32.md`, re-established post-rebase by `evidence/qa-gates/post-rebase-toolchain-reverification.2026-08-26T06-55.md` |
| 33 | Line coverage >= 85 % overall and for the hook | **PASS** | reviewer parsed `artifacts/pester/powershell-coverage.xml`: repo-wide **96.17 %** (6696 / 6963); hook **91.35 %** (95 / 104). Both exceed 85 %. No branch threshold applies to PowerShell |
| 34 | No coverage regression on changed lines | **PASS** | hook missed-line count is 9 at baseline and 9 after; per-file coverage rose 90.32 % to 91.35 %; changed-line coverage 100.00 % (24 of 24 analyzable). Artifact: `evidence/qa-gates/coverage-comparison.2026-08-26T06-32.md` |
| 35 | Baseline, regression, and QA-gate evidence written under the three named trees | **PASS** | 19 artifacts present under `evidence/baseline/` (6), `evidence/regression-testing/` (6), `evidence/qa-gates/` (6), plus `evidence/issue-updates/` (1) and `evidence/other/` (2). `validate_evidence_locations.py --root .` exits 0; zero paths under `artifacts/` appear in the diff |
| 36 | Every changed file under 500 lines; companion-file rule applied if needed | **PASS** | 447 / 447 / 430 / 419. The companion file was created, which is the correct branch of the rule: the existing test file was 408 lines at baseline and would have exceeded 500. Decision recorded in `evidence/other/test-placement-decision.2026-08-26T05-34.md` |
| 37 | At most 2 production PowerShell files; no override requested | **PASS** | exactly 2 production `.ps1` files changed (hook and mandatory bundled mirror), plus 2 test files. Within the 2-file direct-mode cap at `.claude/rules/powershell.md:37-40` |

### Documentation

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 38 | Comment-based help no longer describes longest-match or the `.md`-parent strategy, and states truncation, the checkpoint-then-earliest-occurrence rule, and the version-folder limitation | **PASS** | hook lines 14-40 state truncation "to two segments past the `docs/features/active/` prefix -- that is, to exactly four path segments", the two-tier selection rule with its justification, and the version-folder limitation. `git grep -F "The longest match wins"` returns no match in either copy. Function-level help at lines 220-237 states the same contract |

## Regression-Property Verification (independent)

The caller flagged that two Phase 1 test prompts were corrected during Phase 2, which is the classic way
a regression test silently stops being one. This was verified independently rather than accepted.

The pre-fix resolver was extracted from commit `22c702cf` and driven with the corrected prompts:

- `yields one distinct candidate when one folder is cited at three depths` — pre-fix result
  `docs/features/active/2026-08-23-dedupe-1/evidence/baseline`, against an expectation of
  `docs/features/active/2026-08-23-dedupe-1`. **Still fails pre-fix.**
- `returns the same decision for folder-relative and repo-relative research paths` — pre-fix results
  diverge (`.../2026-08-23-differential-1` versus `.../2026-08-23-differential-1/research`), so with the
  exact-path existence mock one arm allows and the other denies. **Still fails pre-fix.**

The corrections were also confirmed necessary: the original prompts, driven against the post-fix
resolver, fail for the trailing-punctuation reason that `spec.md:79` and `spec.md:295` record as a known
limitation deliberately left unchanged. The original prompts were exercising that limitation rather than
the truncation behaviour their names describe.

Both cases therefore remain genuine regression tests. The residual process gap — that the committed
fail-before artifact was captured before the correction and not re-run afterwards — is recorded as
finding NB-7 and is closed by this independent re-measurement.

## Acceptance Criteria Status

```text
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md
- Total AC items: 38
- Checked off (delivered): 0
- Remaining (unchecked): 38
- Reviewer evaluation: 38 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED
- Note: criterion 24 is PASS with a recorded environmental condition (issue #510).
- Check-off is deferred to [P5-T2] per the review directive; this review checked off nothing.
```

## Verdict

All 38 acceptance criteria are satisfied by evidence the reviewer verified independently. There is no
blocking finding. [P5-T2] may proceed to check off all 38, citing this audit, subject to the two
documentation corrections attached to criterion 24 (cite issue #510 by number, and cite the byte-identity
hash comparison as the durable parity evidence).
