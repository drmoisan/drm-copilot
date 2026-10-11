# subagentstop-envelope-artifact-gates (Issue #897)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Adopted existing issue #897 (no new issue created). Child E3 of epic subagentstop-envelope (epic issue #904).

> Source note: this file was populated from `gh issue view 897` and restricted to the E3 scope. Issue #897 is shared with sibling child E1 (`subagentstop-envelope-core-897`), which owns the shared helper and `.claude/settings.json`. Child pull requests reference #897 with `Refs #897` and do not use a closing keyword.

- Issue: #897
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/897
- Last Updated: 2026-10-11
- Work Mode: full-bug

## Summary

SubagentStop validators under `.claude/hooks/` read `$env:CLAUDE_HOOK_INPUT`, take an `output` property off the parsed root, and block with `exit 1`. The documented SubagentStop envelope arrives as JSON on stdin and exposes `last_assistant_message`, not `output`; the documented hook environment does not include `CLAUDE_HOOK_INPUT`; and for SubagentStop only exit code 2 blocks (established by PR #881 for #786). The validators are therefore expected to fail open.

E3 covers four of the affected validators:

- `.claude/hooks/validate-discovery-artifact-gate.ps1`
- `.claude/hooks/validate-pr-author-output.ps1`
- `.claude/hooks/validate-prd-feature-output.ps1` (registered in `.claude/agents/prd-feature.md:20`)
- `.claude/hooks/validate-task-researcher-output.ps1`

## Environment

- OS/version: Windows 11 Pro
- Runtime: PowerShell 7.x (validators are PowerShell; no Python legs are permitted in enforcement hooks)
- Registration surface: agent frontmatter `hooks:` blocks under `.claude/agents/` and bundled mirrors under `extensions/drm-copilot/resources/`

## Steps to Reproduce

1. Pick one of the four E3 validators.
2. Invoke it with the documented SubagentStop envelope on stdin, whose root carries `hook_event_name` set to the SubagentStop event and `last_assistant_message` set to text lacking the required completion artifact.
3. Invoke it again with `CLAUDE_HOOK_INPUT` set to a root object carrying `output`.
4. Compare the two decisions and exit codes.

## Expected Behavior

Step 2 blocks with exit code 2 and writes the block reason to stderr. Steps 2 and 3 describe the same event; after the fix only the documented stdin envelope is read.

## Actual Behavior

Per the issue #897 update dated 2026-10-11 (main at 2ef8d361), each E3 validator reads `.output`, passes `$env:CLAUDE_HOOK_INPUT`, and blocks with `exit 1`:

| File | Reads `.output` at line | Passes `$env:CLAUDE_HOOK_INPUT` at line | `exit 1` at line |
|---|---|---|---|
| `validate-discovery-artifact-gate.ps1` | 224 | 258 | 261 |
| `validate-pr-author-output.ps1` | 109 | 135 | 139 |
| `validate-task-researcher-output.ps1` | 246 | 288 | 291 |
| `validate-prd-feature-output.ps1` | 80 | 95 | 96 |

These line numbers are recorded from the issue and are re-derived against the integration branch during research.

`validate-discovery-artifact-gate.Tests.ps1` and `validate-pr-author-output.Tests.ps1` assert `$LASTEXITCODE | Should -Be 1`, the assertion that #501 inverted for the PreToolUse suites.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. These are completion gates: while inert, an agent (pr-author, prd-feature, task-researcher, or a discovery agent) can report completion without the artifact that proves it.

## Scope Boundary

- In scope: the four validators above, their Pester suites, their bundled mirrors under `extensions/drm-copilot/resources/`, and their agent frontmatter registrations.
- Out of scope: the shared helper and `.claude/settings.json` (E1); `validate-orchestrator-output*.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1` (E2); `validate-feature-review-coverage.ps1` and feature-review thresholds/skills (E4).

## Source

From: GitHub issue #897 (https://github.com/drmoisan/drm-copilot/issues/897), restricted to E3 scope. The potential entry `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` is intentionally left in place.
