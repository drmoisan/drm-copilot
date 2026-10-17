# Phase 0 Instructions Read (Issue #929)

Timestamp: 2026-10-16T00-21

Policy Order:
1. `CLAUDE.md` (P0-T1)
2. `.claude/rules/general-code-change.md` (P0-T2)
3. `.claude/rules/general-unit-test.md` (P0-T3)
4. `.claude/rules/powershell.md` (P0-T4)
5. `.claude/rules/quality-tiers.md` and `quality-tiers.yml` `.claude/hooks` entry (P0-T5)
6. `.github/copilot-instructions.md` (P0-T6)
7. `.github/instructions/general-code-change.instructions.md` (P0-T7)
8. `.github/instructions/general-unit-test.instructions.md` (P0-T8)
9. `.github/instructions/powershell-code-change.instructions.md` (P0-T9)
10. `.github/instructions/powershell-unit-test.instructions.md` (P0-T10)
11. `.claude/rules/tonality.md` and `.github/instructions/tonality.instructions.md` (P0-T11)

Files read (P0-T1 to P0-T12), 16 files:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `quality-tiers.yml` (`.claude/hooks` entry)
7. `.github/copilot-instructions.md`
8. `.github/instructions/general-code-change.instructions.md`
9. `.github/instructions/general-unit-test.instructions.md`
10. `.github/instructions/powershell-code-change.instructions.md`
11. `.github/instructions/powershell-unit-test.instructions.md`
12. `.claude/rules/tonality.md`
13. `.github/instructions/tonality.instructions.md`
14. `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`
15. `docs/features/active/subagentstop-artifact-gates-review-notes-929/issue.md`
16. `docs/features/active/subagentstop-artifact-gates-review-notes-929/research/research.2026-10-15T19-52.md`

Notes:
- `CLAUDE.md`: policy reading order (copilot-instructions, general code change, general unit test, language-specific); four-layer architecture (standing instructions, skills, subagents, enforcement); orchestration checkpoint path `artifacts/orchestration/orchestrator-state.json`. No coverage threshold is stated, so the 85% line default governs.
- `general-code-change.md`: 500-line limit for production, test, and reusable script files; seven-stage toolchain loop (format, lint, type-check, architecture, unit tests, contract, integration) restarted on any failure or auto-fix; temporary files in tests prohibited.
- `general-unit-test.md`: 85% line default; PowerShell (Pester) exempt from the branch-coverage threshold only; no production file excluded from coverage; tests live under `tests/` mirroring source.
- `powershell.md`: format, analyze, test through PoshQC MCP tools in that order; 500-line limit.
- `quality-tiers.yml`: `.claude/hooks` is `tier: T3`; no property-test or mutation obligation applies to `.claude/hooks/validate-task-researcher-output.ps1`.
- Tonality: professional, factual, neutral tone applies to all evidence and documentation written by this plan.
- `issue.md` carries `- Work Mode: full-bug`; `spec.md` `## Acceptance Criteria` holds 27 unchecked items AC-01 to AC-27.

Scratch location note: the delegation directive places scratch files under `SCRATCH/issue-929/` at the worktree root; the plan's `SCRATCH/929/` names are mapped to `SCRATCH/issue-929/` (same depth, so the wrapper first line is unchanged). `SCRATCH/` did not exist at execution start and was created by the executor.
