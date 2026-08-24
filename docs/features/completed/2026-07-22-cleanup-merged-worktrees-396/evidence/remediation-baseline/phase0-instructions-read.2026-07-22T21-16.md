# Phase 0 — Policy Instructions Read (Cycle 3), Issue #396

Timestamp: 2026-07-22T21-42

Policy Order:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/shell.md`
5. `.claude/rules/tonality.md`

Files read (all five, in the order above):
- `CLAUDE.md` — repository tone policy, policy-compliance reading order, four-layer architecture.
- `.claude/rules/general-code-change.md` — design principles, mandatory toolchain loop, 500-line file cap, error handling.
- `.claude/rules/general-unit-test.md` — five unit-test properties, coverage thresholds (line >= 85%), test-file location, determinism.
- `.claude/rules/shell.md` — native bash toolchain (shfmt/shellcheck/bats/kcov), `bash scripts/bash/shell-qc.sh format|check|test`, kcov line-only coverage, 500-line cap, fixture/stub conventions.
- `.claude/rules/tonality.md` — professional tone, no humor/hyperbole/metaphor, evidence-first wording.

Output Summary: All five policy files read in the required order prior to any code or test change. Cycle-3 scope is bash-only (`scripts/bash/cleanup_worktrees_*.sh`, `tests/shell/`, `tests/fixtures/cleanup_worktrees/`); the shell rule and general code/test rules govern this work.
