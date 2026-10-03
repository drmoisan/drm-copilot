# Phase 0 policy read record (remediation cycle 1, issue #824)

Timestamp: 2026-10-03T12-38
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t2.ps1 -Worktree WORKTREE (A0 preamble only; prints the TS value)
EXIT_CODE: 0
Output Summary: TS=2026-10-03T12-38; all files below were read in the listed order from WORKTREE.
Policy Order: CLAUDE.md -> general code change -> general unit test -> quality tiers -> language rules (PowerShell, Python, Python suppressions, TypeScript, shell, C#) -> tonality -> plan acceptance gates -> evidence and timestamp conventions

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/python.md`
7. `.claude/rules/python-suppressions.md`
8. `.claude/rules/typescript.md` (the TypeScript toolchain runs in final QC)
9. `.claude/rules/shell.md` (a `.sh` file changes)
10. `.claude/rules/csharp.md`, `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md` (the two canonical C# policy files are edited under FU-823-3)
11. `.claude/rules/tonality.md`
12. `.claude/rules/plan-acceptance-gates.md`
13. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

`.github/instructions/github-actions.instructions.md` is not read because no workflow file changes in this cycle.
