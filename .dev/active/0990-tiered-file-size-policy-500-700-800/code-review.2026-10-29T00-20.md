# Code Review: Tiered File-Size Policy 500/700/800 (#990), remediation cycle 2 re-audit

**Review Date:** 2026-10-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990`
**Feature Folder Selection Rule:** supplied by the caller; matches canonical issue #990 and the branch name.
**Base Branch:** `main` (merge base `a7a928d59fd52610c1a627448c8fffac106b23c5`)
**Head Branch:** `feature/tiered-file-size-policy-500-700-800-990` at `b5fe10469d22b54cc6b178e38a0a3dddd30110df`
**Review Type:** Re-review after remediation cycle 2 (prior review `code-review.2026-10-28T23-25.md`)

---

## Executive Summary

The branch replaces the single 500-line limit with a three-tier file-size policy and adds the first repository-wide mechanical gate at the 800-line hard limit. The gate consists of a pure PowerShell policy module with a text-identical Codex twin, Claude and Codex PreToolUse hooks, a Pester repository gate with a strict baseline ratchet, and a baseline generator with its committed output. The full diff spans 201 files; the executable delta is 10 PowerShell production files (6 sources and 4 byte-identical bundle copies) and 22 Pester suites.

Cycle 2 resolves CR-M1 (the excluded directory-name list duplicated between the repository gate suite and the module). The module adds `Get-FileSizeExcludedSegment`, a parameterless pure accessor returning the 20 names, exports it, and has `Test-FileSizeCoveredPath` read it. The gate suite assigns `$script:ExcludedDirectory = @(Get-FileSizeExcludedSegment)` and no longer holds the literal. The Codex twin carries text-identical definitions, and both bundle copies are byte copies. The accessor value is pinned by the independent fixture `$script:FileSizeExcludedSegmentCases` in both the module suite and the twin suite, so a one-sided edit of the accessor fails a test.

This review re-hashed the committed files (equal to the format evidence), confirmed source/bundle SHA256 equality, re-parsed coverage (module 105/105, twin 102/102, repo-wide 92.88%), and re-ran the five affected suites (288 / 288) and the analyzer (0 findings).

**What changed in cycle 2:**
- `.claude/lib/file-size-policy/FileSizePolicy.psm1` lines 52-70 add `Get-FileSizeExcludedSegment`; line 223 reads it; lines 432-434 export it; the module `.DESCRIPTION` names it as the single source.
- `.codex/hooks/file-size-policy.ps1` carries the same two definitions; the bundle copies of both files are refreshed.
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` line 30 reads the accessor; lines 79-94 add `discovers no covered file below an excluded directory name`.
- `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1` lines 75-106 add `Describe 'Get-FileSizeExcludedSegment'` (23 tests); `tests/scripts/codex-hooks/file-size-policy.Tests.ps1` lines 93-99 add 21 twin rows.

**Top 3 risks:**
1. The hooks and the gate have not yet run in CI on a PR head (the PoshQC shards and the Linux hook-suite job). This is the pending AC7 leg.
2. The repository gate scans the working tree with `Get-ChildItem`, so locally untracked covered files are measured. The extension allowlist and excluded directories mitigate this.
3. The excluded names still exist once per runtime (module and Codex twin). This is by design and guarded by the twin parity suite's per-definition text-identity row.

**PR readiness recommendation:** **Ready** for the PR flow. There is no open Blocker, Major, or Minor code finding. AC7 still waits on CI on the PR head; the feature audit tracks it.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/file-size-policy/FileSizePolicy.psm1` | lines 52-70, 223 | CR-M1 (prior Minor, promoted to remediation) resolved. `Get-FileSizeExcludedSegment` is the single source of the names; `Test-FileSizeCoveredPath` and the gate traversal both read it. | None. | The module suite pins membership and count against the independent fixture, and the twin parity suite pins text identity of both changed definitions. | `cr-m1-fail-before.2026-10-28T23-48.md` (44 new tests failing, 192 passing); `cr-m1-pass-after.2026-10-28T23-50.md` (260 / 260); reviewer SHA256 equals `format.2026-10-28T23-52.md`; reviewer run 288 / 288. |
| Info | `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | lines 79-94 | The new row `discovers no covered file below an excluded directory name` can fail only if `Test-FileSizeCoveredPath` stops excluding an accessor name, because the traversal adds only paths that `Test-FileSizeCoveredPath` accepts. That behavior is already asserted per name in `FileSizePolicy.Tests.ps1` (`makes Test-FileSizeCoveredPath exclude every returned name`). The inner loop also adds a path once per matching segment rather than once per path. | Optional: add `break` after `$offender.Add($path)` for a cleaner `-Because` message. No functional change needed. | Low-value but correct regression guard; it was specified by the remediation plan. | Inspected test at HEAD. |
| Info | `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | line 11 | The edited `.DESCRIPTION` line is about 150 characters, while the surrounding help text wraps near 95. | Optional: rewrap when the file is next edited. | Cosmetic; the formatter does not wrap comment text. | Inspected file at HEAD. |
| Info | `.claude/lib/file-size-policy/FileSizePolicy.psm1` | line 223 | `Test-FileSizeCoveredPath` now allocates the 20-element array through a function call on every invocation, including once per file during the repository gate traversal. | None required. | The cost is negligible relative to file I/O in the gate; returning a fresh array avoids shared mutable state. | Inspected module; gate suite runtime in the shuffle evidence is a few seconds. |
| Info | `.claude/lib/file-size-policy/FileSizePolicy.psm1` | lines 66-68 | Directory-name exclusions such as `build`, `env`, and `out` apply at any depth. | No change needed now. | The prior reviewer scan found no tracked covered file under an excluded name; cycle 2 did not change the set. | Prior review scan; names unchanged in cycle 2. |
| Info | `.claude/hooks/enforce-file-size-limit.ps1` | lines 151-160 | Any tool name other than `Edit` is measured from `content`. A tool with no `content` measures as 0 lines and is allowed. | None required. | The repository gate catches growth through any path. | Inspected hook; unchanged since cycle 1. |
| Info | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | whole file | 501 logical lines, in the 500 guidance tier. No Warning applies (below 700). | Consider a logical split when the suite is next extended. | Guidance tier only. | Reviewer logical-line count from the cycle-1 review; file unchanged in cycle 2. |

No covered file added or modified on the branch is at or above 700 logical lines (largest 501; the cycle-2 files are 434, 421, 164, 125, and 118 lines), so there are no file-size Warning rows.

---

## Implementation Audit

### PowerShell implementation audit (if applicable)

#### What changed well

- The fix is minimal: one accessor, two call sites, one export entry. The names, their order, and the `-ccontains` ordinal match are unchanged, so covered-path behavior is identical; the unchanged `Test-FileSizeCoveredPath` rows and the full Pester run confirm this.
- The accessor builds the array inside the function, keeping the module free of module-scope state and keeping each definition self-contained, which the twin text-identity check requires.
- Test-first sequencing is evidenced: 44 tests failed with the command-not-recognized error before the production edit, and all passed afterwards.
- The fixture `$script:FileSizeExcludedSegmentCases` stays independent of the accessor, so the tests detect an accidental edit to the accessor rather than echoing it.

#### API and safety notes

- `Get-FileSizeExcludedSegment` has `CmdletBinding`, `OutputType([string[]])`, an empty `param()`, and comment-based help.
- The export list and the twin function set agree; the twin parity suite's function-name-set row passed in the reviewer run.
- Bundle copies were produced by byte copy, not by edit, so no line-ending drift was introduced (SHA256 equal).

#### Error handling and logging

- No new error path. Existing fail-closed hook behavior and generator throws are unchanged.

---

## Test Quality Audit

The cycle-2 evidence follows the remediation plan in order: policy read, baseline suites (225 / 225), baseline mirror state, baseline full coverage (11816 / 0 failed, 92.88%), failing tests first, module and twin change, pass-after, bundle refresh, gate change, contract suites, format, analyze, mirror parity, full coverage run, shuffle, file sizes, and self-review. This review cross-checked the following:

- The coverage XML: report LINE 18234 / 19632 (92.88%); module 105/105; twin 102/102; the other four new files at 100%.
- The committed file hashes, against the format and mirror-parity evidence.
- A reviewer Pester run over the five affected suites: 288 / 288.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1`: membership per name, exact count, fresh array per call, and exclusion by `Test-FileSizeCoveredPath` for each returned name.
- `tests/scripts/codex-hooks/file-size-policy.Tests.ps1`: membership per name and exact count against the dot-sourced twin.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/regression-testing/cr-m1-fail-before.2026-10-28T23-48.md` and `cr-m1-pass-after.2026-10-28T23-50.md` record fail-before and pass-after.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/qa-gates/pester-full-coverage.2026-10-29T00-08.md` records 11861 tests with 0 failed and 92.88% coverage.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/regression-testing/pester-shuffle.2026-10-29T00-09.md` records three seeds, three distinct orders, and 0 failures.

### Quality assessment prompts

- **Determinism:** in-memory fixture rows; pure accessor; no clock or randomness.
- **Isolation:** one name per row; seeded shuffle runs show no order dependence.
- **Speed:** the five-suite shuffle runs complete in a few seconds each.
- **Diagnostics:** the covered-path row names the failing segment in `-Because`; the gate row lists offending paths.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | None added. |
| No unsafe subprocess or command construction | ✅ PASS | No process or command construction added in cycle 2. |
| Input validation at boundaries | ✅ PASS | Unchanged; the accessor takes no input. |
| Error handling remains explicit | ✅ PASS | Fail-closed hook decisions; generator and parser throw. |
| Configuration / path handling is safe | ✅ PASS | Excluded names and ordinal matching unchanged; `.claude/worktrees/` remains excluded. |
| Single source of policy constants | ✅ PASS | CR-M1 resolved; limits from `Get-FileSizePolicyLimit`, excluded names from `Get-FileSizeExcludedSegment`. |

---

## Research Log

No external research was required. The cycle-2 behavior was verified from the committed code, the executor evidence, and reviewer checks (SHA256, coverage XML parse, Pester and analyzer runs).

---

## Verdict

Ready. CR-M1 is resolved with fail-before and pass-after tests, byte-identical bundle copies, a passing twin parity suite, and full toolchain evidence. No Blocker, Major, or Minor code finding remains. Info rows require no action. AC7's CI leg is tracked in the feature audit.
