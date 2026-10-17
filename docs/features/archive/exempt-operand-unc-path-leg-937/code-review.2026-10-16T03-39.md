# Code Review: Exempt-operand UNC path-leg fix (#937)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/exempt-operand-unc-path-leg-937`
**Base Branch:** `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/exempt-operand-unc-path-leg-937` (`d8ad225b2b05011e45acfe11f3e8df19825ff908`)
**Review Type:** Initial review of the full branch diff

**Total blocking findings: 1** (CR-0, coverage evidence; no code defect. See policy-audit PA-0.)

---

## Executive Summary

The production change adds `$script:OrchestrationTargetNonLocalPattern = '^(?:[\\/]{2}|[\\/]\?\?[\\/]|[A-Za-z]:(?![\\/]))'` and makes the following the first statement of the R1 `foreach ($rawPath ...)` loop in `Get-OrchestrationCommandTarget`:

```powershell
if ($rawPath -match $script:OrchestrationTargetNonLocalPattern) {
    return (New-OrchestrationTargetResult -Rule 'path-not-local' -Value $rawPath)
}
```

The edit is identical in all four copies (`git hash-object` `ef89c7f2e...`; LF; 431 lines; no line over 120 characters). It matches the spec contract. Because the regex runs on the raw value, the trailing-slash trim in `ConvertTo-OrchestrationTargetPath` cannot collapse a bare `\\` or `//` to `/`, and the check precedes the dot-segment check. The anchored alternatives were traced against every spec spelling. `\\`, `//`, `\/`, and `/\` match the first alternative, which also covers `\\?\`, `//?/`, `\\?\UNC\`, `\\.\`, and `//./`. `\??\` and `/??/` match the second. `C:wt\...` and bare `C:` match the third. `C:\` and `C:/` are excluded by the lookahead, and `/abs/path` matches none. PowerShell `-match` is case-insensitive, which is harmless here because the drive class already includes both cases.

Tests cover every spec spelling on both surfaces, the sibling-ordering and dot-segment-ordering rules, marker extraction, and the keep-behavior drive-root rows. The end-to-end gate rows cover both the Claude Write leg and the Codex `apply_patch` leg. Fail-before (42 expected failures, 4 expected passes) and pass-after (46/46) are recorded from CI junit.

Evidence reviewed: `git diff origin/main...HEAD` (all 45 files), the full targets function, the epic-scope caller (`enforce-orchestration-preimplementation-gate-epic-scope.ps1:239-250`), the regenerated `artifacts/pr_context.summary.txt` / `.appendix.txt`, all feature evidence, and the CI coverage XML and Windows junit of runs 38833589314 and 38844097853, which this reviewer downloaded and re-parsed independently.

**Top 3 risks:**
1. A raw path-leg value with leading whitespace before a non-local prefix (for example `' \\server\share\a.ps1'`) does not match the `^`-anchored pattern. It still resolves to the session root through the relative-path fallback. The Claude Write leg passes `FilePath` untrimmed (epic-scope line 250); the Codex marker leg trims (targets line 89) and is not affected. This was established by source reading, not by execution. See CR-1.
2. Other non-absolute spellings outside the spec contract (`file:` URIs, `~`-prefixed paths) still take the relative fallback to the session root. The Write tool supplies absolute paths by contract, so the exposure is low. See CR-2.
3. Under epic scope, a legitimate caller that supplies a drive-relative path is now denied. This is intended and documented in spec Risks; `Detail` carries the raw value, so the denial is diagnosable.

**PR readiness recommendation:** **Not ready**. CR-0 must be remediated first: regenerate the canonical PowerShell coverage artifact from a full-suite run. The code itself has no blocking defect. After CR-0, rebase on `origin/main`; the related non-blocking items CR-1 and CR-3 may be addressed in the same remediation cycle.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker (autonomous) | `artifacts/pester/powershell-coverage.xml` (canonical PowerShell coverage artifact, gitignored) | report LINE counter | CR-0: the canonical artifact reports 66.04% repo-wide line coverage (8110 / 12280) because it came from the executor's scoped local run of two hook test folders. The contract requires FAIL below 85%. The full-suite CI artifact reads 90.41%. | Regenerate the artifact with a full-suite `run_poshqc_test` (no two-folder `scan_folders` restriction), record its LINE counter under `evidence/qa-gates/`, and re-review. | Coverage verification for a changed language must pass on the canonical artifact. | Local `artifacts/pester/pester-junit.xml` (6335 tests); coverage XML LINE counter; policy-audit PA-0 |
| Minor (Non-blocking; related) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | line 228 (`if ($rawPath -match $script:OrchestrationTargetNonLocalPattern)`) | CR-1: the raw-value check is anchored at `^` and the path leg is not trimmed. `' \\server\share\a.ps1'` fails the new pattern, normalizes to `' //server/share/a.ps1'`, fails the absolute pattern, and is mapped to the session root. That is the same misresolution class #937 fixes. The Codex marker leg is unaffected because `Get-OrchestrationPatchMarkerPath` trims (line 89). | Fail closed on surrounding whitespace in the R1 loop. Either prefix the pattern with `\s*`, or add a guard that returns `path-not-local` (or a new token such as `path-whitespace`) when `$rawPath -cne $rawPath.Trim()`. Add one U27-style row with a leading-space UNC spelling on both surfaces, then re-copy the mirrors. | Keeps the fail-closed guarantee independent of payload hygiene. The fix is small, in the same function, and fits the existing test family. | Source reading: targets lines 59-63 (no trim), 86-89 (marker trim), 227-232; epic-scope line 250 passes `@($FilePath)` raw |
| Nit (Non-blocking; related) | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` | U30 | CR-3: U30 asserts only `Resolved` and `Detail.StartsWith('path-not-local')`. It does not assert empty `Targets`, `ReasonCode`, or the exact `Detail` (`'path-not-local: \\server\share\..\x'`), unlike U27, U29, and U31. | Add a `Should -Be 0` assertion on `@($result.Targets).Count`, a `ReasonCode` assertion, and a `Should -BeExactly 'path-not-local: \\server\share\..\x'` assertion on `$result.Detail`, matching U29. | Consistent result-shape assertions across the row family. | File read, U30 block in the added hunk |
| Informational | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | line 232 (relative fallback) | CR-2: `file:///C:/wt/a.ps1`, `file://server/share/a.ps1`, and `~/wt/a.ps1` are not matched (the first alternative requires a leading separator; `file:` is not a single drive letter). They still contribute the session root. They are outside the spec input contract. | No action required for #937. If the operator wants a strict allowlist, a follow-up could deny any raw path-leg value that is neither absolute-local nor a plain relative path (for example a value containing `:` outside position 1, or a leading `~`). | The Write tool contract is absolute paths; `apply_patch` markers are repository-relative. | Regex trace; `spec.md` Inputs/outputs |
| Informational | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | `$script:OrchestrationTargetAbsolutePattern` (line 36) | CR-4: a single-separator root-relative spelling (`\wt\a.ps1`, current-drive-rooted on Windows) normalizes to `/wt/a.ps1` and is treated as an absolute POSIX target. This is pre-existing and does not map to the session root, so the epic-scope check evaluates a non-matching target rather than the coordinator's checkpoint. | No action. Spec Non-Goals keep `OrchestrationTargetAbsolutePattern` unchanged. | Recorded for completeness of the path-spelling review. | Regex trace |
| Informational (Non-blocking) | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (not changed) | lines 116, 335 | CR-5: covered in the baseline coverage XML and uncovered in the final XML, although their direct tests passed in both runs (Windows junit `status="Passed"` for `refuses a resolved Status without a WorktreeRoot` and `join composes an absolute path from a blank remainder`). This moves the report total from 90.42% to 90.41% and leaves plan task P3-T12 unchecked. | Orchestrator records the P3-T12 deviation as accepted (policy-audit PA-1). Track the coverage-attribution variance as a separate follow-up; it is unrelated to the #937 change surface. | Policy thresholds and the changed-line no-regression rule are met; the variance is in an unchanged module. | Reviewer re-parse of both CI XMLs; `evidence/qa-gates/coverage-delta.2026-10-16T03-32.md` |
| Nit (Non-blocking) | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1`, targets suite | added data rows | CR-6: 11 added test lines exceed 120 characters (gate data rows with embedded patch text). The 120-column rule in AC-11 binds the production targets copies only, and the analyzer is clean. | No action required. | Matches the existing row style in both deny tables. | `git diff -U0 origin/main...HEAD -- tests/` with `awk 'length > 121'` (11) |
| Informational | `docs/features/active/exempt-operand-unc-path-leg-937/spec.md` | Rollout & Follow-up | CR-7: the single-feature fallback in `Resolve-WorktreeOperandTarget` still treats `//...` as absolute and falls back to the session worktree. It is a recorded non-goal with an optional follow-up. | Operator decision whether to file the follow-up. | Separate code path with documented fallback semantics. | `spec.md` Non-Goals and Rollout |

---

## Design and Correctness Notes

- **Placement:** the guard is the first statement of the R1 loop, so the first-failing-rule contract holds: R1 runs before the command loop, and a non-local path denies even with a valid sibling (U29).
- **Result shape:** reuses `New-OrchestrationTargetResult`. `ReasonCode` stays `target-unresolvable`, and the existing deny text in `Get-OrchestrationEpicTargetDenyReason` is unchanged. No caller change is needed.
- **Non-epic scope:** the verdict remains `none` (#732 D3 contract), as specified.
- **Invariants:** `git diff --numstat` against the merge base shows each targets copy as 7/0. `ConvertTo-OrchestrationTargetPath`, the absolute pattern, R0, and the R6 `-C` leg are untouched, and U01 to U05, U14, U16, and the C1bCoverage and Parity suites pass unmodified.
- **Mirrors:** the four copies are byte-identical. The extension resource mirrors are outside the PoshQC coverage population (`config/poshqc-coverage.json`, unchanged by this branch); the identical canonical copy is measured.

---

## Test Quality Notes

- Data-driven rows use single-quoted literals and no path APIs, which keeps the Linux CI leg valid for UNC strings.
- Fail-before evidence discriminates. Unit rows failed with `but got $true` and gate rows with `'allow'`, which proves that the rows exercise the defect rather than a harness artifact.
- The gate rows exercise the real epic-scope decision through the existing seams on both surfaces.

---

## Acceptance Criteria Cross-Reference

AC-1 to AC-14 are supported by the reviewed code and tests (see `feature-audit.2026-10-16T03-39.md`). AC-15 is pending PR CI at S9.
