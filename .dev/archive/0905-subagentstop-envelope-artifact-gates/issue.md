# subagentstop-envelope-artifact-gates (Issue #905)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Adopted existing issue #905 (no new issue created). Child E3 of epic subagentstop-envelope (epic issue #904). Issue #905 is the artifact-gate validators' slice of parent issue #897.

> Source note: this file was populated from `gh issue view 905` and restricted to the E3 scope. The parent issue #897 remains shared with sibling child E1 (`subagentstop-envelope-core-897`), which owns the shared helper and `.claude/settings.json`. The child pull request references both issues with `Refs #905` and `Refs #897` and uses no closing keyword until the epic merges.

- Issue: #905
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/905
- Parent issue: #897 (https://github.com/drmoisan/drm-copilot/issues/897), referenced as `Refs #897`
- Promoted record: `docs/features/potential/promoted/2026-10-11-subagentstop-artifact-gate-validators.md`
- Last Updated: 2026-10-11
- Work Mode: full-bug

## Summary

The artifact-gate validators' slice of #897, split out so epic #904 child E3 has its own issue. Four SubagentStop validators read `$env:CLAUDE_HOOK_INPUT`, take `output` off the parsed root, and block with `exit 1`, which does not block:

- `.claude/hooks/validate-discovery-artifact-gate.ps1`
- `.claude/hooks/validate-pr-author-output.ps1`
- `.claude/hooks/validate-prd-feature-output.ps1`
- `.claude/hooks/validate-task-researcher-output.ps1`

E1 of epic #904 measured the documented envelope live: JSON on stdin with `last_assistant_message`, no `output` key, `CLAUDE_HOOK_INPUT` unset, and only exit 2 blocks.

Two strict rules in these validators would start refusing legitimate work once the validators block: the task-researcher research-filename rule and the prd-feature numeric-derivation rule. Both rules must be corrected, and each validator must produce zero false positives against the existing artifacts on main, before any of the four validators switches to exit-2 blocking.

## Environment

- OS/version: Windows 11 Pro; GitHub Actions CI
- Runtime: PowerShell 7.x (validators are PowerShell; no Python legs are permitted in enforcement hooks)
- Command/flags used: SubagentStop registrations for discovery, pr-author, prd-feature and task-researcher
- Data source or fixture: main at 2ef8d361; E1 live differential evidence in `docs/features/active/subagentstop-envelope-core-897/evidence/other/`

## Steps to Reproduce

1. Supply the documented SubagentStop envelope on stdin to each of the four validators with a final message lacking its required artifact.
2. Observe that each validator reads the environment variable, finds no `output`, and does not block; where a block path is reached it exits 1, which does not block.
3. Run `validate-task-researcher-output.ps1` against existing research files named `research.<timestamp>.md`, and `validate-prd-feature-output.ps1` against existing specs whose acceptance criteria contain thresholds, exit codes or issue numbers.

## Expected Behavior

Each validator reads the envelope through the epic #904 shared helper, blocks with exit 2 when the artifact is missing, and passes the artifacts the repository already produces under its documented conventions.

## Actual Behavior

- The four validators are inert at runtime (wrong transport, wrong field, exit 1).
- `validate-task-researcher-output.ps1:95-98` accepts only `<timestamp>-<short-name>-research.md`; more than 60 existing research files use `research.<timestamp>.md`.
- `validate-prd-feature-output.ps1:68` treats any number in an acceptance-criterion line as a numeric criterion requiring a derivation section.
- `validate-discovery-artifact-gate.Tests.ps1` and `validate-pr-author-output.Tests.ps1` assert `$LASTEXITCODE | Should -Be 1`.

## Logs / Screenshots

- Snippet: `docs/features/active/subagentstop-envelope-artifact-gates-905/research/2026-10-11T12-05-subagentstop-envelope-artifact-gates-research.md`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High, as for #897: these completion gates are inert, so completion claims for research, feature documents, pull requests and discovery artifacts are self-attested. Enabling them without fixing the two strict rules would refuse legitimate work.

## Scope Boundary

- In scope: the four validators above, their Pester suites, their bundled mirrors under `extensions/drm-copilot/resources/`, their agent frontmatter registrations other than `prd-feature.md`, the task-researcher filename rule, the prd-feature numeric-derivation rule, and a false-positive corpus run of each validator against the existing artifacts on main.
- Out of scope: the shared helper and `.claude/settings.json` (E1); `validate-orchestrator-output*.ps1` (including resolution and routing), `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`, and the `.claude/agents/prd-feature.md` registration fix (E2); `validate-feature-review-coverage.ps1` and feature-review thresholds (E4). Policy files (`.claude/rules/**`, `.github/instructions/**`, `.github/copilot-instructions.md`) are not edited.

## Source

From: GitHub issue #905 (https://github.com/drmoisan/drm-copilot/issues/905), restricted to E3 scope; parent issue #897. Promoted record: `docs/features/potential/promoted/2026-10-11-subagentstop-artifact-gate-validators.md`.
