# Code Review: Tiered File-Size Policy 500/700/800 (#990)

**Review Date:** 2026-10-28
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990`
**Feature Folder Selection Rule:** supplied by the caller; matches canonical issue #990 and the branch name.
**Base Branch:** `main` (merge base `a7a928d59fd52610c1a627448c8fffac106b23c5`)
**Head Branch:** `feature/tiered-file-size-policy-500-700-800-990` at `d60b776c3112301cf56ceeb8c4caca352d392b18`
**Review Type:** Initial review

---

## Executive Summary

The branch replaces the single 500-line limit with a three-tier file-size policy. It adds the first repository-wide mechanical gate at the 800-line hard limit: a pure PowerShell policy module (`.claude/lib/file-size-policy/FileSizePolicy.psm1`) with a dot-sourced Codex twin, Claude and Codex PreToolUse hooks, a Pester repository gate with a strict baseline ratchet, and a baseline generator with its committed output. The policy text is updated across all authoritative and mirrored surfaces. The change spans 162 files; the executable delta is 10 PowerShell production files (6 sources and 4 byte-identical bundle copies) and 22 Pester suites.

The implementation quality is high. The functions are pure and seam-injected, the hooks fail closed, and the six new production files have 100% line coverage. This review verified parity, test isolation, and the analyzer and format results. One defect needs a fix before merge: the baseline generator does not apply the spec's single line-counting convention (CR-1).

**What changed:**
New `FileSizePolicy.psm1` (line counter, tier classifier, covered-path test, ratchet comparer, Edit resolver, hook decision) and its text-identical Codex twin `.codex/hooks/file-size-policy.ps1`. New `enforce-file-size-limit.ps1` hooks for Claude (registered under `Write|Edit`) and Codex (under `^(apply_patch|Edit|Write)$`). New `scripts/ci/FileSizeBaseline.psm1` and `scripts/ci/New-FileSizeBaseline.ps1`. New `config/file-size-baseline.json` with one entry. New `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`. Two existing directory-wide 500-line gates were switched to the shared 800 limit, and the per-file pinned 500 assertions were reworded.

**Top 3 risks:**
1. Generator counting divergence (CR-1): a future regeneration records files ending in an empty line one short, which the gate then rejects.
2. The repository gate scans the working tree with `Get-ChildItem`, so locally untracked covered files are measured; this is mitigated by the extension allowlist and the excluded directories, but a large untracked script in a developer tree can fail the local run.
3. The hooks are proven only by Pester suites until merge (the spec notes branch hooks are not exercised by isolated subagents); the Linux hook-suite CI job has not yet run on a PR head.

**PR readiness recommendation:** **Needs Revision** — one Major correctness defect against an explicit spec contract (CR-1); everything else is ready.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/ci/New-FileSizeBaseline.ps1` | lines 139-140 | CR-1: `Get-FileSizeLogicalLineCount -Content ($blobLines -join "`n")` undercounts by one every blob whose last line is empty, because the final empty native-output element becomes a trailing LF after the join. The spec requires one counting convention for the gate, hook, generator, and review. Blocking; tracked as PA-B1 in the policy audit and the remediation inputs. | Count from the native element array (`@($blobLines).Count`, which equals the `Get-Content` count), or otherwise rebuild the content so each element carries its terminator. Add a generator test row whose fake blob ends with an empty element, for example 800 text lines plus `''` = 801, expected to be baselined at 801. Re-run the generator at the merge base and confirm the SHA256 is unchanged. | The generator is the authoritative source of baseline contents (spec decision 3). A divergent count produces a baseline that the repository gate rejects as `grew` or `new-over-limit`. | Reviewer PowerShell comparison over 2142 covered tracked files at HEAD: 17 mismatches, each generator = disk - 1 (for example `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` 401 vs 402, `scripts/__init__.py` 0 vs 1); native element count equaled disk count in each. |
| Minor | `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` | lines 20-51 | `Get-FakeTreeText` emits only non-empty lines, so no generator row exercises an empty last line, a lone empty line, or an empty blob. | Add these rows together with the CR-1 fix. | This is the test gap that let CR-1 through. | Inspected fixture. |
| Minor | `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | lines 30-32 | The excluded directory-name list is copied from `Test-FileSizeCoveredPath` in the module. A later edit to one copy changes which directories the gate descends into without changing the covered-path rule, or the reverse. | Expose the list from the module (for example a `Get-FileSizeExcludedDirectoryName` function) and use it in both places. Alternatively, add a test asserting that the two lists are equal. | Drift between two copies of one policy constant. | Inspected both files. |
| Info | `.claude/lib/file-size-policy/FileSizePolicy.psm1` | lines 202-204 | Directory-name exclusions such as `build`, `env`, and `out` apply at any depth, so a covered source file under, for example, `src/build/` would be uncovered. | No change needed now. Revisit if such a directory appears. | The reviewer `git ls-files` scan found zero tracked covered files under any excluded name, so nothing is exempted today. | Reviewer scan (no output). |
| Info | `.claude/hooks/enforce-file-size-limit.ps1` | lines 151-160 | Any tool name other than `Edit` is measured from `content`. A tool with no `content` (for example a `MultiEdit`, if the matcher ever admits it) measures as 0 lines and is allowed. | None required. The repository gate catches growth through any path, as the spec states. | Defense in depth already exists in CI. | Inspected hook. |
| Info | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | whole file | 501 logical lines, which is in the 500 guidance tier. No Warning applies (below 700). | Consider a logical split when the suite is next extended. | Guidance tier only. | Reviewer logical-line count. |

No covered file added or modified on the branch is at or above 700 logical lines (largest 501), so there are no file-size Warning rows.

---

## Implementation Audit

### PowerShell implementation audit (if applicable)

#### What changed well

- The policy module is pure (no filesystem, process, clock, or environment access), and its constants are function-local so the Codex twin is text-identical. `file-size-policy.Tests.ps1` guards that parity.
- `Get-FileSizeLogicalLineCount` implements the counting convention correctly for LF, CRLF, a missing trailing terminator, and empty input.
- `Compare-FileSizeBaselineEntry` encodes the spec's ratchet table one-to-one, including `missing-file` for renames and deletions.
- `Get-FileSizeRatchetViolation` uses ordinal dictionaries so paths that differ only by case stay distinct. Its comment documents the case-insensitive variable-name collision with the `-CurrentSize` parameter.
- The hooks put the covered-path test first (no file read for non-covered paths), read the pre-edit file through an injected seam, and fail closed on every anomaly. The Claude hook's `replace_all` parsing avoids the `[bool]'false'` pitfall.
- The Codex hook handles apply_patch Add/Update/Delete and renames, taking the pre-edit size from the source path.

#### API and safety notes

- Every function has `CmdletBinding`, `OutputType`, and comment-based help. `New-FileSizeBaseline` and `Write-FileSizeBaselineText` support `ShouldProcess`.
- Git access passes an argument array through `Invoke-GitExe`, with no string-built command lines and no `Invoke-Expression`.
- The generator writes UTF-8 without BOM and with no newline translation, so the output is byte-stable. The evidence shows equal SHA256 on two runs.

#### Error handling and logging

- Fail-closed deny reasons carry the `FILE_SIZE_LIMIT_BLOCKED:` prefix and name the path, the count, the tiers, and the split requirement.
- The baseline parser throws a specific message for each schema violation.
- The generator throws on non-zero git exit codes and discards stderr. A git failure message therefore lacks git's own diagnostic text. This is acceptable for a one-off tool, so no finding is raised.

---

## Test Quality Audit

The executor evidence is complete. This review cross-checked the coverage XML directly: report LINE 18232 / 19630 (92.88%), and each new production file at 100%. The XML postdates the last edit to every new production file (the XML was written at 18:11 local; the last production edit was at 17:58). Isolation was shown by three seeded shuffles and a fresh single-process run.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/file-size-policy/*.Tests.ps1` — module behavior table-driven from `FileSizePolicy.Cases.ps1`; covers every tier boundary and ratchet row.
- `tests/scripts/claude-hooks/enforce-file-size-limit.Tests.ps1`, `tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1` — hook decisions in-process with in-memory readers; the spec examples (801 deny, 800 allow, 810 to 815 deny, 810 to 805/810 allow) are present.
- `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` — git argv, coverage filter, 800/801 boundary, determinism, and git failure. It has no empty-last-line case (Minor row above).
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` — the live gate; green against the committed baseline.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/regression-testing/pester-shuffle.2026-10-28T22-08.md` — 3 seeds x 754 tests, 0 failures.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/qa-gates/coverage-comparison.2026-10-28T22-12.md` — coverage before and after.

### Quality assessment prompts

- **Determinism:** in-memory content, injected seams, no clock or randomness.
- **Isolation:** one behavior per `It`; seeded shuffle runs show no order dependence.
- **Speed:** new suites run in seconds; the full run takes 704 s with coverage.
- **Diagnostics:** the gate prints each violating path with its rule message; hook tests assert the reason substrings.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | None added. |
| No unsafe subprocess or command construction | ✅ PASS | Git argv array via `Invoke-GitExe`; no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Envelope anomalies, missing `tool_input`, baseline schema checks. |
| Error handling remains explicit | ✅ PASS | Fail-closed hook decisions; generator and parser throw. |
| Configuration / path handling is safe | ✅ PASS | Paths outside the repository root and relative paths that climb above it are not covered; `.claude/worktrees/` is excluded. |
| Counting convention consistent across components | ❌ FAIL | CR-1. |

---

## Research Log

No external research was required. The behavior of PowerShell native output for a trailing empty line was established empirically in this review, by a scratch comparison over the tracked tree.

---

## Verdict

Needs Revision. The design, tests, coverage, and mirrors meet the spec and repository policy. The baseline generator's line count diverges from the spec's single counting convention for files whose last line is empty. The fix is one line plus a test row, and it should land before merge so that the generator and the gate cannot disagree. After CR-1 is fixed and the generator output hash is confirmed unchanged, the change is ready for the normal PR flow, subject to CI on the PR head for AC7.
