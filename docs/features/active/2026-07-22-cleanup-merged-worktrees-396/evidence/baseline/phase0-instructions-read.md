# Phase 0 — Policy Instructions Read (Issue #396)

Timestamp: 2026-07-22T08-12

Policy Order: The following policy files were read in the exact order defined by the plan task [P0-T1] and the `policy-compliance-order` skill.

Files read (in order):

1. `.github/copilot-instructions.md` — repository tone and communication policy.
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (design principles, 500-line file cap, fail-fast error handling, mandatory toolchain loop).
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (independence, isolation, determinism, no temporary files, coverage expectations).
4. `.claude/rules/shell.md` — shell (bash) toolchain and coding standards (shfmt/shellcheck/bats/kcov via `scripts/bash/shell-qc.sh`, `SHELL_QC_<TOOL>_BIN` seam, 500-line cap, no temp files, checked-in fixtures/stubs, kcov line-coverage-only, >= 85% line threshold).
5. `.claude/rules/quality-tiers.md` — module rigor tiers T1–T4 and uniform coverage thresholds (line >= 85%, branch >= 75%; branch coverage not measurable by kcov for bash).

## Output Summary

All five policy files were read prior to any code or test change. Key binding constraints for this feature:

- 500-line cap per production, test, and reusable shell file.
- No temporary files in tests; use checked-in fixtures under `tests/fixtures/` and checked-in stub binaries wired through an env-override seam (`CLEANUP_WT_GIT_BIN` per this feature).
- Bash toolchain order: shfmt (format) -> shellcheck (lint) -> bats (test) -> kcov (coverage), restart on any failure or file rewrite.
- kcov measures line coverage only; uniform >= 85% line threshold applies; no bash branch-coverage gate.
- Fail-fast error handling; quote all expansions; capture legitimately-non-zero commands with `|| rc=$?` under `set -euo pipefail`.
