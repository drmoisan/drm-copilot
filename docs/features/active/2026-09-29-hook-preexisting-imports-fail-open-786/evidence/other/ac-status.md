# AC Status ([P12-T28])

Timestamp: 2026-10-10T06-35

### Acceptance Criteria Status
- Source: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md (Work Mode full-bug; spec.md only)
- Total AC items: 27
- Checked off (delivered): 23
- Remaining (unchecked): 4
- Items remaining:
  - AC-6 (the [P12-T6] gap rule applies; W-EXEMPT contains H1, H4, H5, H6). Gap:
    AC-6 GAP: named-exemption edges H1, H4, H5, H6 deny with the existing token naming the dependency (E rows) but acquire the payload first; the 2026-10-09 amendment did not extend to AC-6
  - AC-24 (line coverage >= 85% per changed PowerShell production file). Gap: the full R-PESTER run reports four Codex files below 85.00 (enforce-epic-child-worktree-binding.ps1 74.70, enforce-epic-planning-only.ps1 82.25, hook-dependency-guard.ps1 57.89, validate-bash.ps1 80.25). It also reports no-regression failures on five Codex files (coverage-comparison.md, final-pester-coverage.md). The covering tests pass, and folder-scoped runs cover the lines. The cause is the profiler tracer's attribution in the full run; see deviations.md, [P10-T3], [P10-T4] and [P11-T3]. This needs an operator decision on the measurement route.
  - AC-26 (no hook or helper invokes Python). Gap: [P9-T7] check (c) requires zero added lines containing "python" or "poetry". Four hooks (.claude and .codex check-python-test-purity.ps1 and enforce-python-batch-budget.ps1) carry 3 such lines each. Each of those lines is the section 2.2 decision-check or tail line, and the match is the hook's R-PREFIX string literal fixed by section 3. None of them invokes Python, and the guard files are unmodified and pass (p9-no-python.md). The acceptance condition as written cannot be met, so this needs a plan or spec decision.
  - AC-27 (PowerShell toolchain passes in a single pass). Gap: QC pass 4 is green for format, analyze, MCP routes, pytest, line counts, mirror parity and scope. [P11-T3] is not green only because of the AC-24 coverage gap (final-qc-loop.md).

Verification: `^- \[x\] AC-\d+:` matches 23 lines in spec.md, and `^- \[ \] AC-\d+:` matches 4 lines (sum 27). The AC-8 gap rule did not apply: W-EXEMPT does not contain H7 or H8, so no AC-8 GAP line is recorded.
