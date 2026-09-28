# Feature Audit — issue #598, blast-radius PowerShell calling convention

Timestamp: 2026-08-30T06-38
Reviewer: feature-review
Branch: `feature/blast-radius-powershell-calling-convention-598`
HEAD: `d26beb1e2aef67a3ed1e6f80ac55f69042ed00a5`
Resolved base: `epic/claude-runtime-portability-integration` at `6df37664`

## Work mode and AC source resolution

Work Mode marker read from `issue.md:12`: `- Work Mode: full-bug`.

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves the acceptance-criteria
source to **`spec.md` only**. `user-story.md` is correctly absent from the feature folder and is not
an AC source for this mode.

Criteria are located under the exact heading `## Acceptance Criteria` at `spec.md:594`, spanning lines
596–677. Nineteen checkbox items appear under that heading in four groups: item 1 (7), item 2 (4),
item 3 (2), cross-cutting (6).

Whole-file checkbox counts, which the spec's own deviation-recording rule depends on:

```
grep -c "^- \[x\]" spec.md  -> 20
grep -c "^- \[ \]" spec.md  ->  3
```

The 3 unchecked boxes are the Impact/Severity selectors (Blocker, Medium, Low) outside the AC
section, not criteria. The 20 checked boxes are the 19 criteria plus the High severity selector.
This matches the recorded state.

Plan completion, verified independently:

```
grep -c "^- \[x\] \[P" plan.2026-08-29T16-05.md  -> 94
grep -c "^- \[ \] \[P" plan.2026-08-29T16-05.md  ->  0
```

## Baseline for comparison

Acceptance criteria were evaluated against the resolved base branch `6df37664`, not against `main`.
The epic integration branch was merged into this branch at `f4d4f958` mid-execution, so a
`main`-anchored comparison would attribute 152 merge-inherited paths to this feature. Exclusion
criteria (15, 16) were evaluated against the full branch-vs-base diff so that no merge-inherited
change could evade them.

## Per-criterion evaluation

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | Convention test file exists, discovers modules from disk with `Get-ChildItem -Filter '*.psm1' -File -Recurse`, restates no module name, anti-vacuity `It` asserts count > 0 | PASS | File present at 137 lines. Discovery at lines 30–33 matches the specified cmdlet and switches; root resolved by `Resolve-Path` (throws on missing path). No module name appears anywhere in the file. `It 'discovers the claude library modules on disk'` executed and passed. |
| 2 | `It 'sets the fail-fast error preference at module scope...'` passes; line after `Set-StrictMode` is `$ErrorActionPreference = 'Stop'` | PASS | Test executed, passed. Independent check across all 56 modules: `TOTAL=56 GUARDED=56`, zero offenders. |
| 3 | `It 'guards every load-time sibling import...'` passes; every column-0 `Import-Module` carries `-ErrorAction Stop` | PASS | Test executed, passed. Independent check: 88 column-0 `Import-Module` lines across repo and mirror, 0 without `-ErrorAction Stop`. |
| 4 | `It 'states the fail-fast convention in the module help block'` passes; token `imports its siblings with -ErrorAction Stop` precedes `Set-StrictMode` in every module | PASS | Test executed, passed. Independent check: 28 of 28 `.claude/lib` modules carry the token. |
| 5 | `It 'leaves the caller error preference unchanged after import'` passes | PASS | Test executed, passed. Mechanism verified: all 28 assignments are unscoped module-root assignments; no `$global:` write exists. See W3 for the single-module sampling limitation. |
| 6 | `It 'keeps every claude library module within the five hundred line limit'` passes | PASS | Test executed, passed. Independent physical-line count: maximum is 500, no module exceeds it. Block counts physical lines via `@(Get-Content).Count`, not `Measure-Object -Line`. |
| 7 | `DiscoveryValidation.VersionFloor.Tests.ps1` passes unchanged, and `DiscoveryValidation.psm1` still contains `Draft 2020-12 support in PowerShell 7.4` | PASS | Test file unmodified vs base (`git diff --name-only 6df37664..HEAD -- <path>` -> 0 paths). Executed: `VF PASSED=13 FAILED=0`. Token present, 2 occurrences. Diff review confirms the condensation re-wrapped prose and removed no content. |
| 8 | `It 'documents the checkpoint date-coercion contract...'` passes; rendered help contains `date-coerced by ConvertFrom-Json` | PASS | Test executed, passed. Token present at `.claude/lib/orchestrator-state/OrchestratorState.psm1:145` and in the mirror. Help read width-pinned at `Out-String -Width 500`. |
| 9 | `It 'returns an ISO-8601 valued checkpoint key as a DateTime...'` passes; fixture supplies `2026-08-29T20:38:00Z`, `State` value is `DateTime`, non-date string key is `String` | PASS | Test executed, passed. Both assertions present and discriminating: `last_updated` asserted `[System.DateTime]`, `objective` asserted `[System.String]`. Fixture value is the specified literal. |
| 10 | `-DateKind` returns zero matches across `.claude/lib/`; `MinimumPowerShellVersion` returns zero across `.claude/lib/orchestrator-state/` | PASS | `grep -rn "DateKind" .claude/lib \| wc -l` -> 0. `grep -rn "MinimumPowerShellVersion" .claude/lib/orchestrator-state/ \| wc -l` -> 0. |
| 11 | `ToString(` returns zero matches across `.claude/lib/orchestrator-state/` | PASS | `grep -rn "ToString(" .claude/lib/orchestrator-state/ \| wc -l` -> 0. |
| 12 | Both `BlastRadius.Conflict.Tests.ps1` `It` blocks pass, and that file appears nowhere in the change set | PASS | Both named `It` blocks present (2 matches). File absent from branch-vs-base diff (0 paths). `evidence/qa-gates/item3-truthiness-verification.2026-08-30T02-14.md` records `Tests Passed: 29, Failed: 0`, `EXIT_CODE: 0`. |
| 13 | Evidence artifact under `evidence/qa-gates/` records item 3 verification with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `EXIT_CODE` is `0` | PASS | `item3-truthiness-verification.2026-08-30T02-14.md` carries `Timestamp: 2026-08-30T02-14`, a `Command:` list, `EXIT_CODE: 0`, and `Output Summary:`. |
| 14 | Bundle-parity pytest passes; every edited `.claude/**` file has the identical edit in its counterpart, covering all 54 production files (27 modules and 27 mirrors) | PASS | Operative clause satisfied and exceeded. Byte comparison: `DISCOVERED=28 MISMATCHED=0`, all pairs byte-identical. Pytest `EXIT_CODE: 0`, `1 passed`. The `54 / 27+27` parenthetical predates the merge; executed figure is 56 across 28 pairs, reconciled in `spec.md` §Execution deviations item 3 and in `spec-acceptance-reconciliation.2026-08-30T02-36.md` row 14. Recorded as W5. |
| 15 | No modification to `parallel-plan/SKILL.md`, `parallel-add/SKILL.md`, or `parallel-planner.md` | PASS | `git diff --name-only 6df37664..HEAD \| grep -E 'parallel-plan/SKILL.md\|parallel-add/SKILL.md\|parallel-planner.md'` -> empty. Evaluated against the full branch-vs-base diff, not the attributable subset. |
| 16 | No modification to any file under `.claude/rules/` or `.github/instructions/`, nor to `pssa.settings.psd1` or `pester.runsettings.psd1` | PASS | `git diff --name-only 6df37664..HEAD \| grep -E '^(\.claude/rules/\|\.github/instructions/\|scripts/powershell/PoshQC/settings/)'` -> empty. |
| 17 | Full toolchain — format, then analyze, then Pester — completes with zero failures in a single pass, recorded with `Timestamp:`, `Command:`, `EXIT_CODE:` | PASS | `final-poshqc-format.2026-08-30T02-17.md` `EXIT_CODE: 0`, 0 formatted / 429 already formatted, porcelain identical before and after. `final-poshqc-analyze.2026-08-30T02-18.md` `EXIT_CODE: 0`, no findings. `final-pester-suite.2026-08-30T02-22.md` `EXIT_CODE: 0`. No stage rewrote a file, so no restart was required. All three carry the required fields. |
| 18 | Every Pester test that failed as a consequence of the new error preference is repaired inside this feature; final run reports zero failed and zero newly-skipped tests | PASS | `Tests Passed: 3881, Failed: 0, Skipped: 9` versus post-merge baseline 3873 passed / 9 skipped. Skipped count unchanged, so no test was newly skipped. The +8 delta is exactly the 8 tests this feature added, so no pre-existing test required repair. |
| 19 | Line coverage for the PowerShell suite is at or above 85% and no changed line lost coverage, with the figure recorded in the toolchain evidence | **PARTIAL** | Both literal clauses hold: independently parsed coverage artifact gives covered 7337, missed 403, **94.79%** >= 85%; missed count is unchanged from the 403 baseline, so no line lost coverage; the figure is recorded in `final-line-coverage.2026-08-30T02-24.md`. However, 1 of the 56 changed production modules — `.claude/lib/requirements/GeneratedDocumentCounters.psm1` — is absent from `CodeCoverage.Path` and produces no coverage row, so the "no changed line lost coverage" clause is **unmeasurable** for that file and the 94.79% figure excludes it. See finding W1. |

## Detail for the PARTIAL verdict (criterion 19)

File: `.claude/lib/requirements/GeneratedDocumentCounters.psm1`
Location of the omission: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, key
`CodeCoverage.Path` (lines 23–245), which is an explicit per-file allow-list.

Violated rule: `.claude/rules/general-unit-test.md` §Coverage Exclusion Policy — "No production file
may be excluded from coverage measurement. Every production source file is in the denominator of the
coverage metric, regardless of whether its lines are reachable in the test environment."

Verification commands and output:

```
grep -c "GeneratedDocumentCounters" scripts/powershell/PoshQC/settings/pester.runsettings.psd1
0

pwsh -NoProfile -Command "<parse artifacts/pester/powershell-coverage.xml; compare sourcefile
  names against .claude/lib/*.psm1>"
GDC present: 0
lib modules on disk: 28
lib modules NOT in coverage report: 1
GeneratedDocumentCounters.psm1
```

Twenty-seven of the 28 shared library modules are in the coverage denominator; one is not.

Attribution, verified against the resolved base:

```
git cat-file -e "6df37664:.claude/lib/requirements/GeneratedDocumentCounters.psm1"    -> EXISTS_ON_BASE
git show "6df37664:.../pester.runsettings.psd1" | grep -c "GeneratedDocumentCounters" -> 0
git diff --name-only 6df37664..HEAD -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1
                                                                                       -> 0 paths
```

The module exists on the base branch, is unregistered on the base branch, and this branch does not
modify the settings file. The omission is pre-existing relative to the PR base and was not introduced
by this feature.

This feature's edit to the file adds 12 lines, of which exactly one is executable
(`$ErrorActionPreference = 'Stop'`); the other 11 are a comment-based-help block. No line lost
coverage, because the file was unmeasured both before and after.

Why PARTIAL rather than FAIL: both clauses of the criterion as literally written are satisfied —
94.79% clears 85%, and nothing lost coverage. Why not PASS: the criterion's assurance does not extend
to one of the 56 changed production files, and the reader of the criterion would reasonably assume it
covered all of them.

Why this is not Blocking for this feature: the defect is inherited from the base, and remedying it
requires editing `pester.runsettings.psd1`, which criterion 16 requires to be unmodified and which
`spec.md` places out of scope. Blocking this PR would not remove the defect from the epic. The
handling — recording it in `spec.md` §Execution deviations item 5, in `[P0-T18]`, `[P10-T5]`, and
`[P10-T11]`, with an accurate statement that no line lost coverage — is honest and complete as a
record.

Gap in the handling: `spec.md` §Rollout & Follow-up lists three items deliberately not filed as
issues, and this coverage gap is not among them. Deviation 5 states the remedy is "left as a
follow-up for the owner of that settings file" but names no issue.

```
SearchScope: docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/**
SearchPatterns: GeneratedDocumentCounters.*(issue|#[0-9]+|follow-up issue|filed)
SearchResult: no issue number associated with the coverage-registration remedy
```

Required follow-up: file an issue against the epic to add
`.claude/lib/requirements/GeneratedDocumentCounters.psm1` to `CodeCoverage.Path`. The epic must not
merge to `main` with a production module outside the coverage denominator.

## Verdict distribution

| Verdict | Count | Criteria |
|---|---|---|
| PASS | 18 | 1–18 |
| PARTIAL | 1 | 19 |
| FAIL | 0 | — |
| UNVERIFIED | 0 | — |

Every criterion was evaluated against direct evidence. No criterion was marked UNVERIFIED, because
independent verification was available for all 19: three test files were executed by this review, the
coverage artifact was parsed directly, and all exclusion and token conditions were re-derived from
the working tree and from `git` rather than read from the evidence artifacts alone.

## Check-off actions

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, a reviewer checks off criteria evaluated
PASS and leaves PARTIAL items unchecked.

- Criteria 1–18 are evaluated PASS and are already checked `[x]` in `spec.md`. No change required.
- Criterion 19 is evaluated PARTIAL and is currently checked `[x]` in `spec.md`. Under the skill it
  should be unchecked pending the follow-up.

**No modification was made to `spec.md`.** The review task explicitly instructs that `spec.md` must
not be modified, and that instruction takes precedence over the skill's check-off step. The
recommended change is recorded here instead: revert `spec.md:676` from `- [x]` to `- [ ]`, or leave it
checked and add the follow-up issue reference to §Rollout & Follow-up. Either resolution is
acceptable; the second is preferable because the criterion's literal clauses do hold.

If criterion 19 is unchecked, the whole-file counts become 19 checked / 4 unchecked, which changes
the counts that `spec.md` §Execution deviations relies on. That consequence is noted so it is not
discovered later as a surprise.

### Acceptance Criteria Status

```
- Source: docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/spec.md
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: none
```

Reviewer qualification on the summary: all 19 are checked in the source file, but criterion 19 is
evaluated PARTIAL by this review and one of the 19 does not carry full reviewer assurance. The
delivered-versus-verified distinction is recorded above rather than by mutating the source file.

## Acceptance verdict

The feature delivers what issue #598 scoped. The fail-fast convention is applied uniformly and
verifiably across all 28 shared library modules and all 28 bundle mirrors, the date-coercion contract
is documented and enforced by a discriminating test, item 3 is verified without modifying the files it
covers, and the full PowerShell toolchain passes in a single pass with coverage above threshold and a
non-negative delta.

One criterion is PARTIAL for a coverage-denominator gap that was verified to originate on the PR base
rather than in this branch. It requires a tracked follow-up before the epic merges to `main`, but it
does not warrant blocking this feature's merge into the epic integration branch.
