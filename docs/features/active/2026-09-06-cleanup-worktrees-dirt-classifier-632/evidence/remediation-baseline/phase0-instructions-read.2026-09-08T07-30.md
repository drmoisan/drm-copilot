# Phase 0 — Policy instructions read (cycle 2)

Timestamp: 2026-09-08T07-30
Task: [P0-T1]
Feature: docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/
Branch: bug/cleanup-worktrees-dirt-classifier-632-r2
Worktree: .claude/worktrees/agent-ac72d35e7980bc69d

Policy Order: the four files below were read in the order listed, which is the order
[P0-T1] states: repository tone policy first, then the cross-language code-change
baseline, then the cross-language unit-test baseline, then the language-specific shell
rule that scopes this cycle's files (`scripts/bash/**`, `tests/shell/**`).

## Files read

1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.claude/rules/shell.md`

## Constraints carried into execution

- Tone: professional, factual, neutral; no humor, hyperbole, or decorative metaphor
  (`.github/copilot-instructions.md`).
- Bugfix workflow: failing regression test first, then the minimal targeted fix, then
  local verification (`general-code-change.instructions.md`, Bugfix Workflow). Phase 1
  of the plan is written in exactly that order: P1-T3/P1-T4 add the tests, P1-T5 records
  the failing run, P1-T6 applies the fix, P1-T8 records the passing run.
- File size: no production, test, or reusable shell file may exceed 500 lines
  (`general-code-change.instructions.md` section 4.1; `.claude/rules/shell.md`).
  `scripts/bash/cleanup_worktrees_lib.sh` is at 496 lines and is out of scope for this
  cycle.
- No temporary files in tests (`general-unit-test.instructions.md` section 4, currently
  approved exceptions: none). Every fixture this cycle adds is checked in under
  `tests/fixtures/cleanup_worktrees/scenarios/`.
- Shell toolchain order: shfmt format, shellcheck lint, no type-check stage, bats test
  (`.claude/rules/shell.md`). Restart from step 1 on any failure or file rewrite.
- Coverage: kcov measures line coverage only; the uniform >= 85% line threshold applies
  and there is no bash branch-coverage gate (`.claude/rules/shell.md`).

EXIT_CODE: 0
Output Summary: All four policy files exist and were read in the stated order. No
conflicting instruction was found between them and the approved remediation plan.
