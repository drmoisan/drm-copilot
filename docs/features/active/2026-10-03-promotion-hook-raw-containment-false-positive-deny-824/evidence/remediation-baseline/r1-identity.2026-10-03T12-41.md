# r1 P0-T6 — baseline byte identity of every existing mirror pair

Timestamp: 2026-10-03T12-41
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t6.ps1 -Worktree WORKTREE (A0 preamble, then P0-T6 lines (a), (b), (c) and the VERDICT line verbatim)
EXIT_CODE: 0
Output Summary:
- 22 lines each ending `EQUAL=True` (MP1 to MP21 existing pairs, plus CLAUDE-RAW / CODEX-RAW).
- PAIRS=22 UNEQUAL=0
- (c) printed `True` twice (both BUNDLE-ONLY `.agents-variants/csharp-legacy` files exist).

Pair results:

- .claude/hooks/hook-command-raw-invocation.ps1 | .codex/hooks/hook-command-raw-invocation.ps1 | EQUAL=True
- .claude/hooks/hook-command-raw-invocation.ps1 | CB .claude/hooks/hook-command-raw-invocation.ps1 | EQUAL=True
- .codex/hooks/hook-command-raw-invocation.ps1 | XB .codex/hooks/hook-command-raw-invocation.ps1 | EQUAL=True
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | CB same | EQUAL=True
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | CB same | EQUAL=True
- .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | XB same | EQUAL=True
- .claude/hooks/validate-feature-review-coverage.ps1 | CB same | EQUAL=True
- .claude/rules/architecture-boundaries.md | CB same | EQUAL=True
- .agents/skills/architecture-boundaries/SKILL.md | XB same | EQUAL=True
- .claude/skills/quota-throttling/SKILL.md | CB same | EQUAL=True
- .github/instructions/csharp-code-change.instructions.md | GB same | EQUAL=True
- .github/instructions/csharp-unit-test.instructions.md | GB same | EQUAL=True
- .github/agents/csharp-typed-engineer.agent.md | GB same | EQUAL=True
- .agents/skills/csharp/SKILL.md | XB same | EQUAL=True
- .agents/skills/csharp-qa-gate/SKILL.md | XB same | EQUAL=True
- .codex/codex-web-setup.sh | XB same | EQUAL=True
- .claude/rules/quality-tiers.md | CB same | EQUAL=True
- .claude/rules/general-unit-test.md | CB same | EQUAL=True
- .agents/skills/quality-tiers/SKILL.md | XB same | EQUAL=True
- .agents/skills/general-unit-test/SKILL.md | XB same | EQUAL=True
- .claude/agents/feature-review.md | CB same | EQUAL=True
- .claude/skills/feature-review-workflow/SKILL.md | CB same | EQUAL=True

(CB, XB, and GB are the plan's bundle-root abbreviations; the step script used the full paths.)
