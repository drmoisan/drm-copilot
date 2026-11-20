# Code Review: epic-progress-report skill (#1093)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-epic-progress-report-skill-1093`
**Base Branch:** `main` (merge base `a936a1d93c37592e6b2c960499767e54779f70f3`)
**Head Branch:** `feature/epic-progress-report-skill` @ `51a31118f2217c131808888756e2f7ca4b5b680c`
**Review Type:** Re-audit after remediation cycle 1, covering the full branch diff (85 files, 73 commits)

---

## Executive Summary

The branch turns the #1080 report script into the `/epic-progress-report` skill. The script moves to `.claude/skills/epic-progress-report/scripts/`, the Logic file is split into a hub plus State, Metrics and Render files, the state becomes a versioned document under `.claude/state/`, `-ResetBaseline` and `-PairSamples` are added, `-StartUtc` becomes optional, and `scripts/dev-tools/Get-EpicProgressReport.ps1` becomes a five-statement forwarder. The skill folder is mirrored into the Claude bundle, listed in the core pack, and measured by PoshQC coverage through a new `.claude/skills` root.

Remediation cycle 1 (`237c18dbf..51a31118f`) changed one test file and two non-AC lines of `spec.md`; no production, bundle, manifest or configuration file changed.

Verification performed independently by the reviewer at HEAD:

- F1 closure: the new entry-suite case `pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample` passes. Its newest stored sample is 30 seconds old, so `$selection.Changed` is false and only the `-PairSamples` term of the write condition (entry line 447) causes the write. It asserts exactly one `Write-EpicProgressState` call, the paired `ts` list (now minus 1230, 630, 30, with no sample at now), and the stored start (1767600000), `baselineDone` (1) and `baselineWeeklyPct` (12.5) carried over. `StartUtc` is removed from the arguments, so the stored start is the one written.
- Mutant G (`-or $PairSamples` removed) on a scratch copy: the new case fails (1 new failure relative to the scratch baseline); the restored copy returns to the baseline.
- Formatter 0 differences and PSScriptAnalyzer 0 findings on all 19 changed `.ps1` files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
- Seven touched suites: 164 of 164 passed (Pester 6.2.0).
- Bundle: the six files are byte-identical to the canonical files (`cmp`).
- Coverage artifact: entry 90.82%, the other five files 100%; unchanged from the prior review.
- OA-1: the `-StartUtc` parameter-table prose now reads "the passed value, else (with `-ResetBaseline`) now from the clock seam, else the stored value", which matches AC-14 and the implementation. No acceptance-criterion line changed (`git diff 237c18dbf HEAD -- spec.md` shows two lines, neither a checkbox line).

**Top 3 risks:**
1. The carried-forward #1080 item (unreadable kickoff with `-EpicIssue` supplied gives a 0-of-0 report and records a 0-done sample) now also affects the persistent state file, which outlives the container.
2. The spec's AC-09 verification command cannot show `R` entries at the range level (NB-1, unchanged), so a later auditor following the AC text literally may report a failure that the design makes unavoidable.
3. CI has not run on this head; five acceptance criteria depend on it.

**PR readiness recommendation:** **Go.** No open finding requires remediation; open the PR and confirm the CI Required Gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | `pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample` (lines 407 to 428) | F1 from `code-review.2026-11-07T01-41.md` is closed: the spec write rule for `-PairSamples` without a new sample now has a discriminating test. | None. | The case isolates the `-PairSamples` term of the write condition. | Reviewer Pester 164/164; reviewer mutant G kills the new case; executor `evidence/regression-testing/pairsamples-write-mutation.2026-11-07T02-02.md`. |
| Minor | `docs/features/active/2026-11-06-epic-progress-report-skill-1093/spec.md` | AC-09 parenthetical | NB-1 (non-blocking; Remediability: autonomous; optional and not addressed in cycle 1): AC-09 says `git diff --find-renames --name-status main...HEAD` shows `R` entries for the entry and Logic files. At HEAD it shows `A` for both canonical files, `M` for the forwarder and `D` for the old Logic file, because DEC-1 keeps a file at the old entry path and DEC-5 trims the hub. The rename is recorded at commit level (`475219564`, `R100`; `evidence/other/relocation-renames.2026-11-06T23-58.md`). | Optionally amend the AC-09 parenthetical to cite the per-commit rename evidence. | The intent (history preserved as a rename) is met; only the stated proof command is inconsistent with the settled design. | Prior reviewer `git diff --find-renames --name-status`; no change to the files involved since. |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | `Invoke-EpicProgressReport`, kickoff read (line 382) | Carried forward from #1080 NB-4: with `-EpicIssue` supplied, a failed kickoff `git show` gives a 0-of-0 report and a 0-done sample is written to the persistent state file. | None required for this item; consider a follow-up that throws on an empty kickoff read. | Pre-existing; outside every #1093 acceptance criterion. | Code inspection. |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | `Resolve-EpicProgressBaseline`, line 242 | A hand-edited `startUnixSeconds` outside the `DateTimeOffset` range raises an unhandled `ArgumentOutOfRangeException` instead of a message naming the state file. | None required. | The tool writes only valid values; the run still stops. | Code inspection. |
| Info | `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | child-process cases (lines 100 to 121) | Two cases start the current `pwsh` executable. | None required. | The spec's test inventory requires them to prove the exit code under `-File`; both stop at parameter validation before any git call or file write. | Code inspection. |

File-size measurement of covered files in the branch diff at HEAD (logical lines, `@(Get-Content -LiteralPath).Count`): canonical entry 475, Logic 248, State 286, Metrics 232, Render 196 (bundle copies identical), forwarder 24, fixture 39, entry suite 587, State suite 338, Logic suite 323, skill contract suite 252, Render suite 202, Metrics suite 188, forwarder suite 121. None at or above 700, so no Warning row; none above 800; `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The forwarder has no parameter surface and settles exit status explicitly; each outcome has a test.
- The state is read and the start resolved before the first git call; the combined-switch check runs before any I/O.
- `ConvertFrom-EpicProgressStateText` reads the legacy array and the version-1 object and treats other versions and non-numeric fields as absent.
- `Resolve-EpicProgressBaseline` is pure and returns `UseCurrentDone` rather than reaching for the done count.
- The write condition `$selection.Changed -or $ResetBaseline -or $PairSamples` now has a test for each of its three terms.
- Directory creation is inside the `ShouldProcess` block, so `-WhatIf` writes nothing.

#### API and safety notes

- Parameter surface: the thirteen merged parameters plus `-ResetBaseline` and `-PairSamples`; `-StartUtc` optional; all documented in help (test-pinned).
- No new native command; AST tests scan all five canonical files.
- The default state path is built with `Join-Path` from the repository root; `.claude/state/` is gitignored.

#### Error handling and logging

- Two new terminating errors with actionable text (absent start; combined switches).
- The fetch-failure warning is unchanged.

---

## Test Quality Audit

The suites are deterministic (fixed epoch fixtures, mocked clock and file seams, no temporary files) and order-independent (seeded shuffles after cycle 1, plus the single-process and eight-shard runs at `cd19d42c4`). The new case follows the existing fixture pattern, removes `StartUtc` so the stored start is exercised, and checks each carried field separately. All ten reviewer mutants are now killed.

### Reviewed test and QA artifacts

- `tests/scripts/claude-skills/epic-progress-report/*.Tests.ps1` - six suites, 156 tests.
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` - 8 forwarder tests.
- `evidence/regression-testing/pairsamples-write-head.2026-11-07T02-01.md`, `pairsamples-write-mutation.2026-11-07T02-02.md` - head pass and mutation proof; consistent with the reviewer probe.
- `evidence/qa-gates/pester-coverage.2026-11-07T02-06.md`, `coverage-delta.2026-11-07T02-06.md` - per-file figures agree with the reviewer parse of `artifacts/pester/powershell-coverage.xml`.
- `evidence/qa-gates/powershell-format.2026-11-07T02-03.md`, `powershell-analyze.2026-11-07T02-04.md` - consistent with the reviewer runs.
- `evidence/regression-testing/pester-shuffled-order.2026-11-07T02-07.md` - 0 failures.
- `evidence/qa-gates/mirror-and-size.2026-11-07T02-07.md` - consistent with the reviewer `cmp` and line counts.
- `evidence/qa-gates/self-review.2026-11-07T02-08.md` - cycle self-review.

### Quality assessment prompts

- **Determinism:** fixed now (`2026-01-05T12:00:00Z`) and epoch offsets.
- **Isolation:** pure functions tested directly; entry tested through seams.
- **Speed:** in-process suites complete in seconds.
- **Diagnostics:** `ts` lists joined for comparison give readable failures.
- **Gap:** none open.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No token, host path, drive letter or account name in the skill, scripts or forwarder (skill contract suite). |
| No unsafe subprocess or command construction | ✅ PASS | Native calls only in the three wrappers with array arguments. |
| Input validation at boundaries | ✅ PASS | State text validated by version and field type; parameters validated. |
| Error handling remains explicit | ✅ PASS | Terminating errors before I/O. |
| Configuration / path handling is safe | ✅ PASS | `Join-Path` throughout; state under a gitignored folder. |
| Read-only toward repository and GitHub | ✅ PASS | Only `fetch`, `show`, `worktree list`, `pr list`, `cswap list --json`; asserted by tests. |
| No new Python; no epic-skill or `.agents`/`.github/skills` change | ✅ PASS | `git diff --name-only` of the range. |

---

## Research Log

No external research was required. Conclusions rest on the diff, the spec and user story, local tool runs at HEAD, the mutant G probe on a scratch copy, the prior review's AST comparison (no production change since) and the feature evidence.

---

## Verdict

The design and implementation follow the spec, the moved code is unchanged, every toolchain and coverage gate passes, and F1 is closed. No open finding requires remediation. Non-blocking: NB-1 (Minor, optional spec wording for AC-09) and three Info items.
