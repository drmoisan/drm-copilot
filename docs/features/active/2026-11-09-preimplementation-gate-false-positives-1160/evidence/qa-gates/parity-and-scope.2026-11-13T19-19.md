# Parity and Scope ([P3-T6])

Timestamp: 2026-11-13T19-19
Command: sha256sum over the four commands sibling copies and the six execution-environment SKILL.md copies; git diff --name-only 66ebab395d453502af66b8f64ddcb46c0ea81572 HEAD; git diff --name-only 66ebab395d453502af66b8f64ddcb46c0ea81572; git status --porcelain (untracked entries); git merge-base origin/main HEAD; git diff --name-only --diff-filter=A <merge base> HEAD -- '*.py'; git diff --name-only <merge base> HEAD filtered by the spec `#### Files not to modify` entries; case-sensitive grep for `python` in the four sibling copies; @(Get-Content).Count of each changed PowerShell file
EXIT_CODE: 0
Output Summary: four sibling copies share one SHA256; six brief copies share one SHA256; the remediation file set holds only planned paths; no gate file, `Parity.Cases` file, or AC-9/AC-17 suite changed; no `.py` file added and no protected file changed against the merge base; no `python` token in the sibling copies; every changed PowerShell file is below 500 lines. PASS.

- Remediation start ref: `66ebab395d453502af66b8f64ddcb46c0ea81572`; head: `38ac34e95a5d330c25effc19292ee642c35e7547`; merge base of `origin/main` and `HEAD`: `18520b3fce8b6273ac63a16fef03816f7119dcad`.
- Commands sibling, four copies (`.claude/hooks`, `.codex/hooks`, and the two bundle copies): SHA256 `e32ac31e98c618d9857b9ad3b0ea0cd3223a58a54e519f79fabffd6579cdf9e4`.
- Execution-environment `SKILL.md`, six copies (`.claude`, `.agents`, `.github`, and the three bundle copies): SHA256 `5ea2506c2bdecde02a6414b8b1f86d9715565146fcc38d6d43b0eebc8db0c900`.

## Remediation file set (union of the start-ref-to-HEAD diff, the start-ref-to-worktree diff, and untracked entries)

- `<FEATURE>/spec.md`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`
- `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` `enforce-orchestration-preimplementation-gate-commands.ps1` (4)
- `.claude/skills/`, `.agents/skills/`, `.github/skills/`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`, `extensions/drm-copilot/resources/customizations/.github/skills/` `execution-environment/SKILL.md` (6)
- `<FEATURE>` evidence files and `remediation-plan.2026-11-13T18-24.md`
- No `.claude/agent-memory/` file.

## Exclusions verified

- Neither `enforce-orchestration-preimplementation-gate.ps1` gate file, nor `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`, nor any AC-9 or AC-17 suite is in the remediation file set (0 matches).
- Merge-base diff: 0 added `.py` files; 0 paths matching a spec `#### Files not to modify` entry (helpers, targets, cleanup, epic-scope, modes siblings; `hook-epic-fan-in.ps1`; `hook-cleanup-context.ps1`; the six `hook-command-` matcher files; `HookTargetWorktree.psm1` and `hook-target-worktree.ps1`; `settings.json`; `.codex/config.toml`; `config/preimplementation-gate.json`).
- Case-sensitive search for `python` in each of the four sibling copies: 0 matches each. (The help text names "Python tools" with a capital P for pattern index 1; that is documentation, not an invocation, and is unchanged from head.)

## Line counts (logical lines)

| File | Lines |
|---|---|
| commands sibling (each of four copies) | 263 |
| `enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` | 163 |
| `enforce-orchestration-preimplementation-gate-commands.Tests.ps1` | 361 |
