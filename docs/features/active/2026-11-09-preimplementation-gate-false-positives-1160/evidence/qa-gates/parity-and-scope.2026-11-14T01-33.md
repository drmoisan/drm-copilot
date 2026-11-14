# Parity and Scope (cycle 3, [P3-T6])

Timestamp: 2026-11-14T01-33
Command: sh SCRATCH/issue-1160-c3r3-scope.sh (sha256sum over the four sibling copies and the six brief copies; the union of `git diff --name-only` from the remediation start ref c4a26619489c1e8a8ab67d00b2187dbee6b07da7 to HEAD, `git diff --name-only` from the start ref to the working tree, and the untracked entries of `git status --porcelain`; `git diff -U0` of the existing commands suite from the start ref; a pattern check of the file set for protected files; `git diff --name-only --diff-filter=A` from the merge base of origin/main and HEAD for `.py` files; a case-sensitive search for `python` in the four sibling copies; logical line counts)
EXIT_CODE: 0
Output Summary: HEAD 0569915a33333a7a13c1839da81b465cd8255042, merge base eb73f1dff52e7175228a03740b53281c81e1c00c. Four sibling copies: one SHA256 c39100dc8993f1042a3ea621d4de6bc832feeae27193e0427fb65e9501c5414c. Six brief copies: one SHA256 4dd9db4baf9abbf7a3f7e15503d7997059c92e068b607fb51ba3535e3957b490. The remediation file set holds only the allowed files; no protected file appears; no `.py` file is added since the merge base; the four sibling copies hold no `python` token; every changed PowerShell file is below 500 logical lines. PASS.

## Remediation file set (outside the feature folder)

- `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` (the four sibling copies)
- `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude`, `codex-and-agents-customizations/.agents`, and `customizations/.github` (the six brief copies)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (the Cases file)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Modelled.Tests.ps1` (the new suite)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` (the existing commands suite; its diff from the start ref changes only the `ExecutingOption.rg` assertion, from `@('--pre')` to `@('--pre', '--hostname-bin')`)

Feature-folder entries: 26, all under `evidence/`, the remediation plan, or `spec.md`. No `.claude/agent-memory/` file is in the set.

## Protected files

No gate file (`enforce-orchestration-preimplementation-gate.ps1`), `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`, `hook-command-` file, bookkeeping sibling, `core.json` pack manifest, `.agents/skills/orchestrate/SKILL.md` or its bundle copy, or AC-9 or AC-17 suite appears in the file set.

## Line counts (logical)

| File | Lines |
|---|---|
| each of the four sibling copies | 489 |
| Cases file | 210 |
| new Modelled suite | 97 |
| existing commands suite | 361 |
