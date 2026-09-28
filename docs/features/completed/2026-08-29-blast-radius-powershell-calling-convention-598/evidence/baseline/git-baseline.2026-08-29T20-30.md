# Git baseline — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T2]

Command:
1. `git rev-parse --abbrev-ref HEAD`
2. `git rev-parse HEAD`
3. `git status --porcelain`
4. `git rev-parse --verify main`

EXIT_CODE: 0 (highest exit code observed across the four commands; all four exited 0)

BaseRef: main

Output Summary:

- Branch (command 1): `feature/blast-radius-powershell-calling-convention-598`
- Head SHA (command 2): `300768ab7f4dae6a9d8bb4ec40aa335c6e2806b3` (40 characters)
- Porcelain status (command 3), verbatim:

  ```
   M docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md
  ?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/
  ```

  Both entries are this execution's own Phase 0 output: the plan checkbox for `[P0-T1]` and the
  evidence folder created by `[P0-T1]`. No production file is modified at baseline.

- `main` resolution (command 4): `6c425f34d665cd62e8b7a17dcabf662ee461f682`, exit code 0. Because
  that command exits 0, the recorded base ref is `main`.

## Base-ref note

This branch was created from `origin/epic/claude-runtime-portability-integration` at commit
`300768ab`. The integration branch is ahead of `main`, and the intervening commits touch Markdown
documents under `docs/features/` only — no `.psm1`, `.py`, `.Tests.ps1`, `SKILL.md`, agent, rule,
instruction, or settings file. Every later `<BaseRef>...HEAD` diff in the plan is either scoped by
pathspec outside that set or counted by the `.psm1`, `.py`, and `.Tests.ps1` extensions, so those
Markdown paths do not affect any acceptance condition. A whole-tree name-listing diff that shows them
records them as pre-existing epic-branch documents rather than as part of this feature's change set.

Every later `git diff` task in this plan uses the recorded base ref, which is `main`.
