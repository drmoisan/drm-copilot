# Code Review: Exempt-operand UNC path-leg fix (#937)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/exempt-operand-unc-path-leg-937`
**Base Branch:** `origin/main` (tip `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`; merge base `c415af626c292f38b910e3a27e70ab3e1903b31a`)
**Head Branch:** `bug/exempt-operand-unc-path-leg-937` (`e8bdc75e61c7785e5163940b90781d893c073120`)
**Review Type:** Re-review after remediation cycle 2 (full branch diff)

**Total blocking findings: 0**

---

## Executive Summary

The production change, identical in all four copies (`git hash-object` `f8e8e9a1a...`; reviewer SHA-256 `ebe9dce17c9779a4...` for all four; LF; 433 lines; no line over 120 characters), now reads:

```powershell
$script:OrchestrationTargetNonLocalPattern = '^(?:\s|[\\/]{2}|[\\/]\?\?[\\/]|\\(?![\\/])|[A-Za-z]:(?![\\/])' +
'|[A-Za-z][A-Za-z0-9+.-]+:|~)|\s$'
```

The first statement of the R1 `foreach ($rawPath ...)` loop in `Get-OrchestrationCommandTarget` returns `New-OrchestrationTargetResult -Rule 'path-not-local' -Value $rawPath` on a match. The cycle 2 production diff against the cycle 1 state (`git diff 2677047c1 HEAD`) is two replaced lines per copy: the comment line ("a file: URI" becomes "a URI scheme") and the pattern continuation (`'|file:|~)|\s$'` becomes `'|[A-Za-z][A-Za-z0-9+.-]+:|~)|\s$'`).

Cycle 2 findings were checked against the code:

- Cycle 1 CR-1 / RI-7 (URI schemes other than `file:`): resolved. The scheme alternative requires a letter followed by at least one of `[A-Za-z0-9+.-]` before the colon, which matches RFC 3986 scheme syntax with a minimum length of two. A single drive letter therefore never reaches it: `C:` and `C:wt` are still matched by `[A-Za-z]:(?![\\/])`, and `C:\` and `C:/` match neither alternative and stay resolvable. `file:` is still covered as a two-or-more-character scheme. U27 `http-uri`, `smb-uri`, `vscode-remote-uri`, `scheme-plus-uri`, U32, and six `(issue #937 RI-7)` gate rows pass on both surfaces (CI run 38898218767).
- Cycle 1 CR-2 / RI-8 (test file at 496 lines): resolved. U27 to U31 were moved unchanged into `enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1` (134 lines), which uses the same `Describe` name and surface `-ForEach`, so JUnit testcase names are unchanged. The source suite has no net change against the merge base (399 lines).

The reviewer traced the final pattern with an equivalent case-insensitive Python `re` probe in the scratchpad (not a PowerShell run). Denied: `http://x/a`, `smb://x`, `vscode-remote://wsl/x`, `git+ssh://x`, `file:///C:/a`, `C:`, `C:wt`, `\\?\C:\`, `~/x`. Not denied: `C:\`, `C:/`, `D:\x`, `/abs/a.ps1`, `rel/a.ps1`, `a.ps1`, `a\b`, `scripts/a:b.ps1`. The probe also shows the consequence recorded as CR-1 below.

**Top 3 risks:**
1. A relative path whose first segment contains a colon after two or more scheme-legal characters (for example `foo:bar.txt`, or an NTFS alternate data stream such as `a.ps1:stream`) is now denied as `path-not-local` instead of resolving to the session root (CR-1, Informational). This is a fail-closed outcome consistent with the spec's design.
2. The branch is 133 commits behind `origin/main`. The trial merge is clean, and the orchestrator merges before the PR (policy-audit PA-2).
3. AC-15 depends on CI on the PR head, which does not exist yet (policy-audit PA-5).

**PR readiness recommendation:** **Ready after the merge of `origin/main`.** No blocking defect.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Informational (Non-blocking; related) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | line 42 (`[A-Za-z][A-Za-z0-9+.-]+:` alternative) | CR-1: the generalized scheme alternative also matches a relative path whose first segment has a colon after two or more scheme-legal characters, for example `foo:bar.txt` or `a.ps1:stream`. Under epic scope such a Write now yields `deny` where it previously evaluated the session root. A first segment that starts with a digit or a dot (`1ab:c`, `.hidden:x`) still takes the relative fallback, which resolves to the session root and is correct. | No action in this item. The outcome fails closed, which matches `spec.md` Proposed Fix, and the Write tool supplies absolute paths by contract. If a later item needs such paths, a test row pinning the behavior would make the choice explicit. | Recorded so the behavior is a known consequence, in the same way cycle 1 recorded the `~` consequence. | Scratchpad regex probe: `foo:bar.txt`, `a.ps1:stream`, `ab:c` classified non-local; `1ab:c`, `.hidden:x`, `scripts/a:b.ps1` not matched |
| Informational (unrelated) | PoshQC MCP runner (installed extension, outside the branch) | runsettings `CodeCoverage.Path` | CR-4 (carried): the local full-suite coverage artifact measures 127 source files against 204 in CI, and the targets file is not instrumented locally. Per-file evidence comes from CI. | Outside this item. | Tooling-environment matter, not a branch defect; dispositioned as unrelated in cycle 1. | Reviewer re-parse of both XMLs (sourcefile counts 127 and 204) |
| Informational (accepted; unrelated) | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (not changed) | lines 116, 335 | CR-5 (cycle 0, carried): report-row attribution variance. The cycle 2 CI report row is 90.44 at both baseline and post-change. | None in this item. | Disposition recorded in `evidence/other/plan-deviation-accepted.2026-10-16T08-26.md`. | `coverage-delta-c2.2026-10-16T12-29.md` |
| Informational (accepted; unrelated) | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (not changed) | `Resolve-WorktreeOperandTarget` | CR-7 (cycle 0, carried): single-feature fallback for `//...`. | None in this item. | Spec Non-Goal. | `spec.md` Non-Goals |

---

## Design and Correctness Notes

- **Placement:** unchanged from cycle 1. The guard is the first statement of the R1 loop, and the raw value is tested before `ConvertTo-OrchestrationTargetPath`. The non-local rule precedes the dot-segment rule (U30), and a non-local path denies even with a valid sibling (U29).
- **Alternative ordering:** the `[A-Za-z]:(?![\\/])` alternative precedes the scheme alternative, but correctness does not depend on order: the scheme alternative cannot match a one-letter prefix, and `C:\`/`C:/` fail both alternatives. A two-letter prefix such as `ab:` is treated as a scheme, which is consistent with RFC 3986 and with how Windows rejects multi-letter drive designators.
- **Case sensitivity:** PowerShell `-match` is case-insensitive, so `HTTP://` and `FILE:` are also denied; the explicit `A-Za-z` ranges are redundant under `-match` but harmless and keep the pattern correct under a case-sensitive operator.
- **Result shape:** reuses `New-OrchestrationTargetResult`. `ReasonCode` stays `target-unresolvable`, and the deny text is unchanged. No caller change is needed.
- **Invariants:** each targets copy is `+9/-0` against the merge base. `ConvertTo-OrchestrationTargetPath`, `OrchestrationTargetAbsolutePattern`, R0, and the R6 `-C` leg are untouched. The invariant filter FINV reads 27 matched with 0 failed and 0 skipped in CI run 38898218767; the source targets suite, C1bCoverage, and Parity suites are absent from the merge-base numstat (`invariants-diff-c2.2026-10-16T11-58.md`).
- **Mirrors:** four copies byte-identical (reviewer SHA-256; evidence `targets-mirror-identity-c2.2026-10-16T11-30.md`).

---

## Test Quality Notes

- The move (RI-8) was proven before any new row was added: CI run 38892084649 shows the passed moved-row name set equal to the c2 baseline (`cmp` exit 0), FOLD at 109 = 165 - 56 with 0 failed, and FDISC 1/1. Commit `caa66b50f` performs the move alone, before the expect-fail commit `96b20936d`.
- Fail-before discriminates: CI run 38892084649 on `96b20936d` concluded `failure` (reviewer `gh run view`) with exactly the 14 expected testcases failing (8 U27 with `but got $true`, 6 gate rows with `'allow'`); the unfiltered failed set equals that set. U32 passed before the fix, as a keep-behavior row should.
- Pass-after: CI run 38898218767 on `725545096` concluded `success` on all 17 jobs; F1 84/84, F2 14/14, 6374 Linux testcases with 0 failed.
- U32 guards the main over-match risk of the new alternative (a colon after a separator). The single-segment colon case is recorded as CR-1 rather than tested; this is acceptable because the spec does not define it as a keep-behavior input.
- New rows use single-quoted literals and no path APIs, so the Linux CI leg stays valid. Gate rows are wrapped across lines; no added content line exceeds 120 characters.

---

## Acceptance Criteria Cross-Reference

AC-1 to AC-14 and AC-16 to AC-20 are supported by the reviewed code and tests (see `feature-audit.2026-10-16T12-36.md`). AC-15 is pending PR CI at S9.
