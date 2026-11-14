# Parity and Scope (cycle 4, [P3-T6])

Timestamp: 2026-11-14T03-14
Command: sh SCRATCH/issue-1160-c4-scope.sh SCRATCH/issue-1160-c4-fileset.txt (sha256sum over the four commands-sibling copies and the six execution-environment SKILL.md copies; remediation file set = union of git diff --name-only <start ref> HEAD, git diff --name-only <start ref>, and the untracked entries of git status --porcelain; a pattern search of that set for forbidden files; git diff --name-only --diff-filter=A <merge base> HEAD filtered for .py; case-sensitive grep -c python over the four sibling copies; awk line counts of each changed .ps1 file)
EXIT_CODE: 0
Output Summary: remediation start ref eb8781fd6fca43fe74b1b69392d27c7fd8a9e8f8; HEAD bacd4f54330432c9bb890ceebbbb67a252ea9109; merge base of origin/main and HEAD f9e817b2ace9875b24f3df8ad27b97a4065a435e (equal to origin/main). Four sibling copies: one SHA256 588836fb03c2dda9c6fddf967858d3c497a0a4b12d4d3934f2f600b033e91e83. Six brief copies: one SHA256 797b8bbd795206ffd5ea8f8f2fbfd2d4bf4625a3051fb2e048b99bc3626d3d85. The remediation file set holds only the allowed files (listed below); no gate file, Modelled suite, `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`, `hook-command-` file, pack manifest, bookkeeping sibling, orchestrate skill, or AC-9 or AC-17 suite appears; no `.claude/agent-memory/` file is in the set. The merge-base diff adds no `.py` file. The case-sensitive `python` count is 0 in each sibling copy. Logical lines: each sibling copy 489, the Cases file 235, the commands suite 380, all below 500.

## Remediation file set

Production and mirrors (10):

- `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

Tests (2):

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`

Feature folder (17): `spec.md`, `remediation-plan.2026-11-14T01-40.md`, and 15 evidence files of this cycle under `evidence/other/`, `evidence/qa-gates/`, `evidence/regression-testing/`, and `evidence/remediation-baseline/`.

## Commands suite change

The anchored diff of `enforce-orchestration-preimplementation-gate-commands.Tests.ps1` against the start ref adds the D19 header line and `Context 'subcommand position (decision D19)'` with its four cases, and removes no line.
