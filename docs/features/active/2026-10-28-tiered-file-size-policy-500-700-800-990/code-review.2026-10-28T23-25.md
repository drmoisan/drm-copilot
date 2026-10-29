# Code Review: Tiered File-Size Policy 500/700/800 (#990), remediation cycle 1 re-audit

**Review Date:** 2026-10-28
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990`
**Feature Folder Selection Rule:** supplied by the caller; matches canonical issue #990 and the branch name.
**Base Branch:** `main` (merge base `a7a928d59fd52610c1a627448c8fffac106b23c5`)
**Head Branch:** `feature/tiered-file-size-policy-500-700-800-990` at `abb51cc69b4096ab367cc4fe708ff6cabf6dea03`
**Review Type:** Re-review after remediation cycle 1 (prior review `code-review.2026-10-28T22-32.md`)

---

## Executive Summary

The branch replaces the single 500-line limit with a three-tier file-size policy and adds the first repository-wide mechanical gate at the 800-line hard limit. The gate consists of four parts:

- a pure PowerShell policy module with a text-identical Codex twin;
- Claude and Codex PreToolUse hooks;
- a Pester repository gate with a strict baseline ratchet;
- a baseline generator, together with its committed output.

The policy text is updated across all authoritative and mirrored surfaces. The full diff spans 179 files. The executable delta is 10 PowerShell production files (6 sources and 4 byte-identical bundle copies) and 22 Pester suites.

Cycle 1 resolves CR-1. `New-FileSizeBaseline` now counts the native element array (`@($blobLines).Count`), with a comment explaining why the join-then-count form is not used. A four-row data-driven test was added. The fail-before and pass-after evidence shows the 800-plus-empty-element row failing before the fix and passing after it. The generator output at the merge base is byte-identical to `config/file-size-baseline.json` before and after the fix. This review re-hashed the committed files and confirmed that they match the evidence. It also re-parsed coverage and re-ran a line-count scan of the merge-base tree, which found one file above 800 lines, consistent with the baseline.

**What changed in cycle 1:**
`scripts/ci/New-FileSizeBaseline.ps1` lines 141-144 replace `Get-FileSizeLogicalLineCount -Content ($blobLines -join "`n")` with `@($blobLines).Count`, and its `.DESCRIPTION` now states the element-count rule. `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` lines 109-131 add `counts a blob whose last element is empty like the logical line count` with four rows.

**Top 3 risks:**
1. The excluded directory-name list remains duplicated between the repository gate suite and the module (Minor, carried forward from the prior review). A one-sided edit would let the gate and the covered-path rule disagree.
2. The repository gate scans the working tree with `Get-ChildItem`, so locally untracked covered files are measured. The extension allowlist and excluded directories mitigate this.
3. The hooks and the gate have not yet run in CI on a PR head (the PoshQC shards and the Linux hook-suite job). This is the pending AC7 leg.

**PR readiness recommendation:** **Ready** for the PR flow. There is no open Major or Blocker code finding. AC7 still waits on CI on the PR head; the feature audit tracks it.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/ci/New-FileSizeBaseline.ps1` | lines 141-144 | CR-1 (prior Major) resolved. The generator counts `@($blobLines).Count`. `Invoke-FileSizeBaselineGit` returns `, @($result.Lines)`, so the value is always an array, and an empty blob counts 0 rather than 1. | None. | The native element count equals the on-disk logical count for every mismatch found in the prior review (17 files), and the merge-base output hash is unchanged. | `pa-b1-fail-before.2026-10-28T22-58.md` (14 of 15, expected row failing); `pa-b1-pass-after.2026-10-28T22-59.md` (15 of 15); `generator-hash-after.2026-10-28T22-59.md` (SHA256 `8ed473b7...f4ea`, byte-identical); reviewer `sha256sum` of the committed script equals the format evidence (`52a86046...7fb8`). |
| Minor | `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | lines 30-32 | The excluded directory-name list is still a copy of the list in `Test-FileSizeCoveredPath` (`.claude/lib/file-size-policy/FileSizePolicy.psm1` lines 202-204). Cycle 1 placed this item out of scope. | Expose the list from the module (for example a `Get-FileSizeExcludedDirectoryName` function, mirrored into the Codex twin), or add a test that asserts the two lists are equal. This is related to the item and can be fixed before merge. | Two copies of one policy constant can drift. | Inspected both files at HEAD. |
| Info | `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` | lines 109-131 | The two sub-limit rows (single empty element, expected 1; empty array, expected 0) assert `Get-FileSizeLogicalLineCount` on the constructed on-disk text and the absence of the key from `Files`. They do not observe the generator's own count, because any count at or below 800 produces the same output. The `801 text lines` row duplicates the existing 801 boundary test. | Optional: expose the per-blob count through a small helper, or assert it through a lowered limit seam, if exact sub-limit counts become observable output. | The rows that matter for output (800 plus empty = 801, baselined) are asserted directly against the generator. | Inspected test. |
| Info | `.claude/lib/file-size-policy/FileSizePolicy.psm1` | lines 202-204 | Directory-name exclusions such as `build`, `env`, and `out` apply at any depth. | No change needed now. | The prior reviewer scan found no tracked covered file under an excluded name. | Prior review scan; unchanged in cycle 1. |
| Info | `.claude/hooks/enforce-file-size-limit.ps1` | lines 151-160 | Any tool name other than `Edit` is measured from `content`. A tool with no `content` measures as 0 lines and is allowed. | None required. | The repository gate catches growth through any path. | Inspected hook; unchanged in cycle 1. |
| Info | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | whole file | 501 logical lines, in the 500 guidance tier. No Warning applies (below 700). | Consider a logical split when the suite is next extended. | Guidance tier only. | Reviewer logical-line count at HEAD. |

No covered file added or modified on the branch is at or above 700 logical lines (largest 501, measured at HEAD by the reviewer), so there are no file-size Warning rows.

---

## Implementation Audit

### PowerShell implementation audit (if applicable)

#### What changed well

- The cycle-1 fix is minimal and local. The comment names the exact failure mode: a final empty element makes the joined text end in LF, and that LF is subtracted as a terminator.
- `.DESCRIPTION` now describes the element-count rule as the on-disk equivalent of the module rule, so the generator's help text matches its behavior.
- The policy module remains pure, with function-local constants and the text-identical Codex twin guarded by `file-size-policy.Tests.ps1`.
- `Compare-FileSizeBaselineEntry` encodes the spec's ratchet table one-to-one; `Get-FileSizeRatchetViolation` uses ordinal dictionaries.
- The hooks put the covered-path test first, read the pre-edit file through an injected seam, and fail closed on every anomaly.

#### API and safety notes

- Every function has `CmdletBinding`, `OutputType`, and comment-based help; `New-FileSizeBaseline` and `Write-FileSizeBaselineText` support `ShouldProcess`.
- Git access passes an argument array through `Invoke-GitExe`, with no string-built command lines and no `Invoke-Expression`.
- The generator still imports `FileSizePolicy.psm1` for `Get-FileSizePolicyLimit` and `Test-FileSizeCoveredPath`. After cycle 1 it no longer calls `Get-FileSizeLogicalLineCount`, and the import stays necessary.

#### Error handling and logging

- Fail-closed deny reasons carry the `FILE_SIZE_LIMIT_BLOCKED:` prefix and name the path, the count, the tiers, and the split requirement.
- The generator throws on non-zero git exit codes. Stderr is discarded, which is acceptable for a one-off tool.

---

## Test Quality Audit

The cycle-1 evidence follows the remediation plan in order: baseline suite run, pre-fix generator hash, full coverage baseline, failing test first, fix, passing test, post-fix generator hash, format, analyze, full coverage run, shuffle, and self-review. This review cross-checked the following:

- The coverage XML: report LINE 18232 / 19630 (92.88%), and each new production file at 100%.
- The committed file hashes, against the format evidence.
- The merge-base tree: one code file above 800 lines (`scripts/dev_tools/agentic_sync.py`, 819).

### Reviewed test and QA artifacts

- `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` covers git argv, the coverage filter, the 800/801 boundary, determinism, git failure, and (cycle 1) the empty-last-element, single-empty-element, and empty-array rows.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/regression-testing/pa-b1-fail-before.2026-10-28T22-58.md` and `pa-b1-pass-after.2026-10-28T22-59.md` record fail-before and pass-after.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/baseline/generator-hash-before.2026-10-28T22-45.md` and `generator-hash-after.2026-10-28T22-59.md` record equal hashes and byte-identical output.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/qa-gates/pester-full-coverage.2026-10-28T23-15.md` records 11816 tests with 0 failed, 92.88% coverage, and the generator at 100%.
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/regression-testing/pester-shuffle.2026-10-28T23-20.md` records three seeds, both file orders, and 0 failures.

### Quality assessment prompts

- **Determinism:** in-memory content, injected seams, no clock or randomness.
- **Isolation:** one behavior per row; seeded shuffle runs show no order dependence.
- **Speed:** the generator suite runs in about 1 s.
- **Diagnostics:** the fail-before run identified the row and the expected key directly.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | None added. |
| No unsafe subprocess or command construction | ✅ PASS | Git argv array via `Invoke-GitExe`; no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Envelope anomalies, missing `tool_input`, baseline schema checks. |
| Error handling remains explicit | ✅ PASS | Fail-closed hook decisions; generator and parser throw. |
| Configuration / path handling is safe | ✅ PASS | Paths outside the repository root are not covered; `.claude/worktrees/` is excluded. |
| Counting convention consistent across components | ✅ PASS | CR-1 resolved; the merge-base generator output equals the committed baseline byte for byte. |

---

## Research Log

No external research was required. The cycle-1 behavior was verified from the committed code, the executor evidence, and reviewer scratch scans (coverage XML parse and merge-base line-count scan).

---

## Verdict

Ready. CR-1 is resolved with a fail-before and pass-after test, an unchanged baseline hash, and full toolchain evidence. No Blocker or Major code finding remains. One Minor finding is still open: the duplicated excluded-directory list in the repository gate suite. It is non-blocking and can be fixed before merge. Info rows require no action. AC7's CI leg is tracked in the feature audit.
