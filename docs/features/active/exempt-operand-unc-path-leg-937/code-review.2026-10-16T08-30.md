# Code Review: Exempt-operand UNC path-leg fix (#937)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/exempt-operand-unc-path-leg-937`
**Base Branch:** `origin/main` (tip `c415af626c292f38b910e3a27e70ab3e1903b31a`; merge base `ba53ff5694a42e975d5d1db99b2b6ef505143e66`)
**Head Branch:** `bug/exempt-operand-unc-path-leg-937` (`5d34fe4368dcb65244352b0c633514a2424b4b79`)
**Review Type:** Re-review after remediation cycle 1 (full branch diff)

**Total blocking findings: 0**

---

## Executive Summary

The production change, identical in all four copies (`git hash-object` `e92597ce1...`; LF; no BOM; 433 lines; no line over 120 characters), adds this pattern:

```powershell
$script:OrchestrationTargetNonLocalPattern = '^(?:\s|[\\/]{2}|[\\/]\?\?[\\/]|\\(?![\\/])|[A-Za-z]:(?![\\/])' +
'|file:|~)|\s$'
```

The first statement of the R1 `foreach ($rawPath ...)` loop in `Get-OrchestrationCommandTarget` returns `New-OrchestrationTargetResult -Rule 'path-not-local' -Value $rawPath` on a match.

Cycle 1 findings were checked against the code:

- CR-0 / RI-1 (coverage evidence): resolved. The canonical artifact reads 94.57% from a full-suite run, and the full-suite CI artifact (run 38870746395) carries 99.40% per targets copy with changed lines 41, 230, and 231 covered. The reviewer re-parsed the CI artifact independently.
- CR-1 / RI-2 (whitespace): resolved. The `^\s` and `\s$` alternatives deny leading and trailing whitespace before normalization, which closes the untrimmed Claude Write leg. U27 `leading-space-unc`, `leading-space-absolute`, and `trailing-space-absolute` pass on both surfaces.
- CR-2 / RI-4 (`file:` and `~`): resolved for the spellings in scope. PowerShell `-match` is case-insensitive, so `FILE:` is also denied. U27 rows and the `(issue #937 RI-4)` gate rows pass.
- CR-3 / RI-3 (U30 assertions): resolved. U30 now asserts `Targets` count 0, `ReasonCode`, and the exact `Detail`.
- CR-4 / RI-5 (single-backslash root-relative): resolved through `\\(?![\\/])` without editing `OrchestrationTargetAbsolutePattern`. U01 (POSIX `/...` resolves to itself) passes unmodified.
- CR-6 / RI-6 (long added test lines): resolved; 0 added lines exceed 120 characters.

The reviewer traced the pattern against additional spellings with an equivalent case-insensitive regex in a scratchpad probe (not a PowerShell run). `C:\wt\a.ps1` and `/wt/a.ps1` stay absolute, `scripts/a.ps1` stays relative, and a non-breaking-space prefix and a trailing newline are denied. The trace also found one remaining gap, CR-1 below.

**Top 3 risks:**
1. URI schemes other than `file:` (`http://`, `smb://`, `vscode-remote://`) still take the relative fallback to the session root (CR-1). This is the same misresolution class, outside the spec input contract and low in exposure, because the Write tool supplies local absolute paths.
2. A `~`-prefixed relative file name (for example an Office lock file `~$x.docx`) is now denied under epic scope. AC-17 makes this intended, and `Detail` carries the raw value (CR-3, Informational).
3. The targets test suite is at 496 of 500 lines, so the next added row needs compaction or a file split first (CR-2).

**PR readiness recommendation:** **Ready after rebase.** No blocking defect. Rebase on `origin/main` (178 commits ahead, trial merge clean) before opening the PR. CR-1 and CR-2 are related non-blocking items that may be fixed inside this item.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (Non-blocking; related) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | lines 41-42 (`OrchestrationTargetNonLocalPattern`) | CR-1: the `file:` alternative covers only the `file` scheme. `http://server/share/a.ps1`, `smb://server/share/a.ps1`, and `vscode-remote://wsl/x` match no alternative. Each normalizes to a value that fails `OrchestrationTargetAbsolutePattern`, so each contributes the session root. That is the misresolution class #937 fixes. | Replace `file:` with a URI-scheme alternative of two or more characters, for example `[A-Za-z][A-Za-z0-9+.-]+:`. A one-character drive letter stays under the existing `[A-Za-z]:(?![\\/])` and `C:\`/`C:/` stay resolvable. Add expect-fail U27 rows (for example `http-uri`, `smb-uri`) on both surfaces first. Note CR-2 before adding rows. | Generalizes the RI-4 decision with one alternative and closes the remaining scheme spellings. | Scratchpad regex probe (equivalent Python `re` with `IGNORECASE`): `http://...`, `smb://...`, `vscode-remote://...` all classified `REL->session-root` |
| Nit (Non-blocking; related) | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` | whole file | CR-2: 496 lines against the 500-line cap. Compliant now, but any further row (for example for CR-1) breaches the cap unless rows are compacted or the file is split. | If CR-1 is addressed in this item, move U27 to U31 into a sibling file (for example `...targets.PathNotLocal.Tests.ps1`) or compact the U27 data table before adding rows. | Prevents a policy breach on the next edit. | Reviewer line count (496); `origin/main` copy is 399 |
| Informational | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | `~` alternative | CR-3: any raw path-leg value beginning with `~` is denied, including a relative file name such as `~$tmp.docx`. Under epic scope this yields `deny` where it previously evaluated the session root. | No action. AC-17 specifies `~`-prefixed spellings as non-local, and the Write tool supplies absolute paths by contract. | Recorded so the behavior is a known consequence. | Regex probe: `~$tmp.docx` classified `nonlocal`; `scripts/~a.ps1` stays relative |
| Informational (unrelated) | PoshQC MCP runner (installed extension, outside the branch) | runsettings `CodeCoverage.Path` | CR-4: the local full-suite coverage artifact measures 127 source files against 203 in CI, and the targets file is not instrumented locally. Per-file evidence had to come from CI. | Outside this item. Rebuilding and reinstalling the extension, or letting the runner use repository runsettings, would align the canonical artifact with CI. | Tooling-environment matter, not a branch defect. | Reviewer re-parse of both XMLs (sourcefile counts 127 and 203) |
| Informational (accepted) | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (not changed) | lines 116, 335 | CR-5 (cycle 0): report-row attribution variance. Accepted by the orchestrator as unrelated; cycle 1 shows 90.41 at both baseline and post-change. | None in this item. | Disposition recorded in `evidence/other/plan-deviation-accepted.2026-10-16T08-26.md`. | `coverage-delta-c1.2026-10-16T08-25.md` |
| Informational (accepted) | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (not changed) | `Resolve-WorktreeOperandTarget` | CR-7 (cycle 0): single-feature fallback for `//...`. Accepted by the orchestrator as unrelated, with documented fallback semantics. | None in this item. | Spec Non-Goal. | `spec.md` Non-Goals |

---

## Design and Correctness Notes

- **Placement:** the guard is the first statement of the R1 loop, and the raw value is tested before `ConvertTo-OrchestrationTargetPath`. A bare `\\` or `//` therefore cannot collapse to `/`, and the non-local rule precedes the dot-segment rule (U30). R1 runs before the command loop, so a non-local path denies even with a valid sibling (U29).
- **Alternative-by-alternative trace:** `\s` (leading whitespace, including Unicode whitespace under .NET `\s`); `[\\/]{2}` (UNC, extended-length, device, mixed separators, bare doubles); `[\\/]\?\?[\\/]` (NT-object, either separator); `\\(?![\\/])` (single-backslash root-relative; `\??\` is matched by both this and the previous alternative); `[A-Za-z]:(?![\\/])` (drive-relative and bare `C:`; `C:\` and `C:/` excluded); `file:` and `~` (anchored prefixes); `\s$` (trailing whitespace; .NET `$` also matches before a final newline, which is also denied). Each alternative fails closed.
- **Result shape:** reuses `New-OrchestrationTargetResult`. `ReasonCode` stays `target-unresolvable`, and the deny text in `Get-OrchestrationEpicTargetDenyReason` is unchanged. No caller change is needed. The non-epic verdict remains `none` (#732 D3 contract).
- **Invariants:** each targets copy is `+9/-0` against the merge base. `ConvertTo-OrchestrationTargetPath`, `OrchestrationTargetAbsolutePattern`, R0, and the R6 `-C` leg are untouched. U01 to U05, U14, U16, C1bCoverage, and Parity pass unmodified (29/29 invariant testcases in CI run 38870746395).
- **Mirrors:** four copies byte-identical (reviewer SHA-256 prefix `dfca4bd6b1033c9b` for all four; `git hash-object` `e92597ce1...` in evidence).

---

## Test Quality Notes

- Cycle 1 rows extend the existing U27 data table (8 labels) and the two gate deny tables (3 rows each). They use single-quoted literals and no path APIs, so the Linux CI leg stays valid.
- Fail-before discriminates. CI run 38862518700 on `3c6b38fb5` concluded `failure` with exactly the 22 expected testcases failing: 16 U27 MESSAGE lines contain `but got $true` and 6 gate MESSAGE lines contain `'allow'`. The unfiltered failed set equals that set.
- Pass-after: CI run 38870746395 on `ba934fd48` concluded `success` on all 17 jobs; 68/68 issue rows, 6357/6357 Linux testcases.
- U30 now matches the U27 and U29 result-shape assertions (RI-3).

---

## Acceptance Criteria Cross-Reference

AC-1 to AC-14 and AC-16 to AC-19 are supported by the reviewed code and tests (see `feature-audit.2026-10-16T08-30.md`). AC-15 is pending PR CI at S9.
