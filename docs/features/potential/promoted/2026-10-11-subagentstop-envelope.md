# subagentstop-envelope (Issue #904)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/subagentstop-envelope/ (Issue #904)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub issue template.

- Issue: #904
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/904
- Last Updated: 2026-10-11
## Problem / Why

The nine SubagentStop validators under `.claude/hooks/` (`validate-*.ps1`) and the inline SubagentStop command at `.claude/settings.json:218` read the payload from the `CLAUDE_HOOK_INPUT` environment variable, take an `output` property off the parsed root, and block with `exit 1`. The documented SubagentStop envelope arrives on stdin and carries `last_assistant_message`, and only exit code 2 blocks. PR #881 (#786) proved that exit-1 block paths in this validator family do not block. While these validators are inert, a subagent can report completion without the artifact that proves it.

Related defects in the same files are also open: the #787 review notes CR-1, CR-3 and CR-7, the double `OrchestratorState.psm1` import in `validate-orchestrator-output.ps1` (#786 review), the feature-review coverage hook follow-ups (#896), and the Codex feature-review coverage hook at 7.30% line coverage with a separate fixed 80% floor (#884, Codex half).

## Proposed Behavior

Deliver the fix as one epic with four child features in two dependency waves. Every child updates the bundled mirrors under `extensions/drm-copilot/resources/`.

- Wave 1: E1 (#897) measures what a real SubagentStop hook receives on stdin versus `CLAUDE_HOOK_INPUT`, records the evidence, adds one shared envelope-read and exit-2 block helper, and fixes the inline command at `.claude/settings.json:218`.
- Wave 2: E2 (#903, with #897) converts `validate-orchestrator-output.ps1` and `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1` and `validate-required-artifact-output.ps1`, and takes the #903 notes for those files; E3 (#897) converts `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1` and `validate-task-researcher-output.ps1`; E4 (#896, with the Codex half of #884) converts `validate-feature-review-coverage.ps1` and aligns the Claude and Codex feature-review coverage floors.

The epic manifest and narrative live at `docs/features/epics/subagentstop-envelope/epic.md`.

## Acceptance Criteria (early draft)

- [ ] Recorded evidence states what a real SubagentStop hook receives on stdin and whether `CLAUDE_HOOK_INPUT` is set.
- [ ] All nine SubagentStop validators and the inline command read the documented envelope through one shared helper and block with exit code 2.
- [ ] No validator reads `CLAUDE_HOOK_INPUT` or blocks with exit code 1.
- [ ] Test suites that asserted exit code 1 for a block assert exit code 2.
- [ ] The Claude and Codex feature-review coverage hooks use the same floor source, and the Codex hook has at least 85% line coverage.
- [ ] Bundled mirrors match their sources, and no production file exceeds 500 lines.
- [ ] All four child features merge into `epic/subagentstop-envelope-integration`, and the integration branch merges into `main`.

## Constraints & Risks

- Enforcement hooks must not gain Python legs.
- Once the validators block, a currently inert gate starts refusing completions. The inline command's matcher covers fifteen agents, including `orchestrator`, `epic-orchestrator` and `epic-planner`, so its pattern must be reviewed before it is made to block.
- `validate-orchestrator-output.ps1` is 466 lines and `validate-feature-review-coverage.ps1` is 477 lines; both need a split to stay under 500.
- Children are existing issues. No new child issues are created.

## Test Conditions to Consider

- A differential run of each validator with the documented envelope on stdin versus the environment-variable shape.
- Exit-code assertions of 2 for every block path and 0 for every pass path.
- Malformed, empty, and absent stdin.
- Mirror parity for every changed hook.
