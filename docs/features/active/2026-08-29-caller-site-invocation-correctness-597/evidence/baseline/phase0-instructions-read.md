# Phase 0 — Instructions Read (P0-T1)

Timestamp: 2026-08-30T09-00

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/powershell.md

Files read (in the exact order listed above):
- `CLAUDE.md` — repository standing instructions (tone policy, policy compliance reading order,
  language-specific rules index, four-layer runtime architecture).
- `.claude/rules/general-code-change.md` — cross-language code change policy (design principles,
  mandatory seven-stage toolchain loop, file size limit, error handling, naming, public API
  compatibility, dependencies, I/O boundaries).
- `.claude/rules/general-unit-test.md` — cross-language unit test policy (core test principles,
  coverage requirements, coverage exclusion policy, scenario completeness, test structure, test
  file location, determinism infrastructure).
- `.claude/rules/powershell.md` — PowerShell-specific toolchain and coding standards, read for
  contextual background only.

No language-specific code-change rule beyond PowerShell applies to this feature. No
`.claude/lib/**` `.psm1`/`.ps1` file is created or edited by this feature; all six touched files
(three repo files and their three byte-identical bundle mirrors under
`extensions/drm-copilot/resources/claude-customizations/`) are PowerShell-invocation instruction
text inside markdown (`.claude/skills/parallel-plan/SKILL.md`,
`.claude/skills/parallel-add/SKILL.md`, `.claude/agents/parallel-planner.md`, and their mirrors).
No Python, TypeScript, or C# rule file applies because no source file in those languages is in
scope.

Output Summary: All four policy files read successfully in the required order; no additional
language-specific code-change rule applies beyond PowerShell context, and PowerShell itself has no
production `.psm1`/`.ps1` edits in scope for this feature.
