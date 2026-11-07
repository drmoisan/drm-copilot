# Code Review: epic-progress-report skill (#1093)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-epic-progress-report-skill-1093`
**Base Branch:** `main` (merge base `a936a1d93c37592e6b2c960499767e54779f70f3`)
**Head Branch:** `feature/epic-progress-report-skill` @ `cd19d42c4430a1bba81758db79cb1ea5167ffcb0`
**Review Type:** Initial review of the full branch diff (67 files, 56 commits)

---

## Executive Summary

The branch turns the #1080 report script into the `/epic-progress-report` skill. The script moves to `.claude/skills/epic-progress-report/scripts/`, the Logic file is split into a hub plus State, Metrics and Render files, the state becomes a versioned document under `.claude/state/`, `-ResetBaseline` and `-PairSamples` are added, `-StartUtc` becomes optional, and `scripts/dev-tools/Get-EpicProgressReport.ps1` becomes a five-statement forwarder. The skill folder is mirrored into the Claude bundle, listed in the core pack, and measured by PoshQC coverage through a new `.claude/skills` root.

Verification performed independently by the reviewer:

- AST comparison of every function at the merge base and at HEAD: of the 32 merged functions, 29 are byte-identical after the move and the three that changed are the intended ones (`Resolve-EpicProgressSetting`, `Write-EpicProgressState`, `Invoke-EpicProgressReport`); four State functions are new. No merged function was dropped. This supports AC-23 (output unchanged) beyond the golden tests.
- Formatter 0 differences and PSScriptAnalyzer 0 findings on all 19 changed `.ps1` files with the repository settings file.
- Seven touched suites: 163 of 163 passed (Pester 6.2.0).
- Bundle: the six files are byte-identical to the canonical files (`cmp`).
- Coverage artifact at HEAD content: entry 90.82%, the other five files 100%.
- Ten targeted mutants on a scratch copy of the State and entry code: nine killed, one survived (F1).

**Top 3 risks:**
1. F1: the `-PairSamples` write path when no new sample is added is not pinned by a test; a regression there would silently discard a cadence change.
2. The carried-forward #1080 item (unreadable kickoff with `-EpicIssue` supplied gives a 0-of-0 report and records a 0-done sample) now also affects the persistent state file, which outlives the container.
3. The spec's AC-09 verification command cannot show `R` entries at the range level, so a later auditor following the AC text literally would report a failure that the design makes unavoidable.

**PR readiness recommendation:** **No-Go until F1 is remediated.** F1 needs one added test; no production change is expected.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | `rewrites the stored samples in pairs with -PairSamples` (line 393); production condition at `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` line 447 | F1 (blocking; Remediability: autonomous): the spec write rule ("the state is written when the sample rule added a sample, or when `-ResetBaseline` or `-PairSamples` was given") has no test for `-PairSamples` when the sample rule adds nothing. The only entry case stores a newest sample 300 seconds old, so `$selection.Changed` is already true. | Add an entry-suite case whose newest stored sample is under 90 seconds old (for example now minus 30) with `-PairSamples`; assert exactly one `Write-EpicProgressState` call whose `samples` are the paired set and that no new sample was appended. | The skill's cadence-change procedure runs `-PairSamples` once by hand, and the TL;DR job runs every 10 minutes, so a manual run within 90 seconds of a scheduled run is a realistic case. Without the write the report prints paired figures once and the next run reverts to the unpaired samples with no error. A scenario-completeness gap on a stated rule. | Reviewer mutant G (`-or $PairSamples` removed from the write condition): 0 new failures across the State and entry suites; the other nine mutants each failed 1 to 6 tests. |
| Minor | `docs/features/active/2026-11-06-epic-progress-report-skill-1093/spec.md` | AC-09 parenthetical | NB-1 (non-blocking; Remediability: autonomous): AC-09 says `git diff --find-renames --name-status main...HEAD` shows `R` entries for the entry and Logic files. At HEAD it shows `A` for both canonical files, `M` for the forwarder and `D` for the old Logic file, because DEC-1 keeps a file at the old entry path and DEC-5 trims the hub to 248 of 688 lines. The rename is recorded at commit level (`475219564`, `R100` for both files; `evidence/other/relocation-renames.2026-11-06T23-58.md`) and `git log --follow` on the hub reaches the #1080 commits. | Optionally amend the AC-09 parenthetical to cite the per-commit rename evidence instead of the range diff. | The intent (history preserved as a rename) is met; only the stated proof command is inconsistent with the settled design. | Reviewer `git diff --find-renames --name-status main...HEAD`; `git log --follow --oneline` on the hub. |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | `Invoke-EpicProgressReport`, kickoff read (line 382) | Carried forward from #1080 NB-4: with `-EpicIssue` supplied, a failed kickoff `git show` gives a 0-of-0 report and a 0-done sample is written. The state file now persists under `.claude/state/`, so the bad sample survives a restart until the next reset. | None required for this item; consider a follow-up that throws on an empty kickoff read. | Pre-existing; outside every #1093 acceptance criterion; the operator sees "0 of 0 tasks". | Code inspection; `code-review.2026-11-06T13-43.md` of #1080. |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | `Resolve-EpicProgressBaseline`, line 242 | A hand-edited `startUnixSeconds` outside the `DateTimeOffset` range raises an unhandled `ArgumentOutOfRangeException` from `FromUnixTimeSeconds` instead of a message naming the state file. | None required. | The tool writes only valid values; the run still stops. | Code inspection. |
| Info | `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | child-process cases (lines 100 to 121) | Two cases start the current `pwsh` executable, which the general unit-test policy discourages. | None required. | The spec's test inventory requires them to prove the exit code under `-File`; both stop at parameter validation before any git call or file write. | Code inspection. |

File-size measurement of covered files in the branch diff (logical lines, `@(Get-Content -LiteralPath).Count`): canonical entry 475, Logic 248, State 286, Metrics 232, Render 196 (bundle copies identical), forwarder 24, fixture 39, entry suite 563, State suite 338, Logic suite 323, skill contract suite 252, Render suite 202, Metrics suite 188, forwarder suite 121. None at or above 700, so no Warning row; none above 800; `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The forwarder has no parameter surface and settles exit status explicitly (`$ErrorActionPreference = 'Stop'`, reset of `$global:LASTEXITCODE`, `if ($?) { exit 0 }`, explicit propagation); each outcome has a test.
- The state is read and the start resolved before the first git call; the combined-switch check runs before any I/O; both are asserted with `Should -Invoke ... -Times 0`.
- `ConvertFrom-EpicProgressStateText` reads the legacy array and the version-1 object, treats other versions and non-numeric fields as absent, and always returns an array of samples.
- `Resolve-EpicProgressBaseline` is pure: it returns `UseCurrentDone` instead of reaching for the done count, which is only known after the git calls.
- `Merge-EpicProgressSamplePair` is a short index loop and the help states its non-idempotence.
- Directory creation is inside the `ShouldProcess` block, so `-WhatIf` writes nothing.

#### API and safety notes

- Parameter surface: the thirteen merged parameters plus `-ResetBaseline` and `-PairSamples`; `-StartUtc` optional; all documented in help (test-pinned).
- No new native command; AST tests now scan all five canonical files.
- The default state path is built with `Join-Path` from the repository root; `.claude/state/` is gitignored.

#### Error handling and logging

- Two new terminating errors with actionable text (absent start; combined switches).
- The fetch-failure warning is unchanged.

---

## Test Quality Audit

The suites are deterministic (fixed epoch fixtures, mocked clock and file seams, no temporary files) and order-independent (three seeded shuffles, single-process and eight-shard runs). New tests reproduce the recorded pairing example to four decimals and pin the Full golden captured from the merged tool before any edit. One stated rule lacks a discriminating test (F1).

### Reviewed test and QA artifacts

- `tests/scripts/claude-skills/epic-progress-report/*.Tests.ps1` - six suites, 155 tests.
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` - 8 forwarder tests.
- `evidence/qa-gates/pester-coverage.2026-11-07T01-04.md`, `coverage-delta.2026-11-07T01-04.md` - per-file figures agree with the reviewer parse of `artifacts/pester/powershell-coverage.xml`.
- `evidence/regression-testing/pester-shuffled-order.2026-11-07T01-04.md`, `pester-single-process.2026-11-07T01-27.md`, `pester-parallel-shards.2026-11-07T01-33.md` - 0 failures.
- `evidence/qa-gates/it-name-comparison.2026-11-07T01-05.md` - 105 of 106 names preserved; the one replacement is the one the spec names.
- `evidence/baseline/full-golden-legacy-state.2026-11-06T23-50.md` - source of the legacy-state Full golden.
- `evidence/qa-gates/python-contract-tests.2026-11-07T01-34.md` - 106 passed.

### Quality assessment prompts

- **Determinism:** fixed now (`2026-01-05T12:00:00Z`) and epoch offsets.
- **Isolation:** pure functions tested directly; entry tested through seams.
- **Speed:** in-process suites complete in seconds.
- **Diagnostics:** `ts` lists joined for comparison give readable failures.
- **Gap:** F1.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No token, host path, drive letter or account name in the skill, scripts or forwarder (skill contract suite and reviewer grep). |
| No unsafe subprocess or command construction | ✅ PASS | Native calls only in the three wrappers with array arguments. |
| Input validation at boundaries | ✅ PASS | State text validated by version and field type; parameters validated. |
| Error handling remains explicit | ✅ PASS | Terminating errors before I/O. |
| Configuration / path handling is safe | ✅ PASS | `Join-Path` throughout; state under a gitignored folder. |
| Read-only toward repository and GitHub | ✅ PASS | Only `fetch`, `show`, `worktree list`, `pr list`, `cswap list --json`; asserted by tests. |
| No new Python; no epic-skill or `.agents`/`.github/skills` change | ✅ PASS | `git diff --name-only` of the range. |

---

## Research Log

No external research was required. Conclusions rest on the diff, the spec and user story, local tool runs at HEAD, the AST comparison, the mutation probe on a scratch copy and the feature evidence.

---

## Verdict

The design and implementation follow the spec, the moved code is unchanged, and every toolchain and coverage gate passes. One blocking finding remains: F1 (Major, autonomous), a missing test for the `-PairSamples` write when no sample is added. Non-blocking: NB-1 (Minor, spec wording for AC-09) and three Info items.
