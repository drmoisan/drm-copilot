# targeted-test-cadence (Issue #1228)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1228-targeted-test-cadence/ (Issue #1228)

- Issue: #1228
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1228
- Last Updated: 2026-11-23
- Work Mode: full-feature

## Problem / Why

The orchestration rules run the full unit suite at every `[phase-gate]` task, and some skills also require it for remediation cycles and post-merge sync checks. On large destination repositories this repeats a multi-minute full run many times per orchestration. The owner directed on 2026-11-23: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests. this change should be reflected in every rule that operates otherwise for all orchestrators."

## Proposed Behavior

- The full test suite runs only at the Phase 0 baseline and in the final QC loop.
- Every other test run is targeted: task checks, `[phase-gate]` tasks, remediation cycles, and main-sync or integration-sync checks. A phase gate keeps format, lint, type check, architecture, and contract checks. Its unit stage is the union of the phase's task test selections (mirrored tests of changed files, tests that import, dot-source, or name a changed module, and contract tests for changed Markdown or configuration paths), run in parallel.
- The change applies to every orchestrator and every surface: Claude (`.claude/`), Codex (`.agents/`, `.codex/`), Copilot (`.github/`), AGENTS.md, rule and agent sources under `scripts/harness-generation/sources/`, and all bundle copies under `extensions/drm-copilot/resources/`.
- The change is recorded as a standing gate reduction in `.dev/engineering/process-reductions/`, with the prior text and revert steps.

## Acceptance Criteria (early draft)

- [ ] `## Test Cadence (Mandatory)` in atomic-plan-contract (all surfaces) defines the phase gate's unit stage as the union of the phase's task test selections, and the full suite only at the Phase 0 baseline and the final QA loop.
- [ ] No rule, skill, agent, prompt, or instruction on any surface or bundle still requires a full-suite run outside the Phase 0 baseline and the final QC loop. This is verified by a repository-wide search recorded in evidence.
- [ ] Generated outputs are regenerated from sources, and `Invoke-HarnessGeneration.ps1 -Check` reports no drift.
- [ ] Bundle copies are in parity, AGENTS.md matches its bundle copy byte for byte, and push-down contract tests pass.
- [ ] Any validator, hook, or contract test that pins the old wording is updated in step.
- [ ] A process-reduction ledger entry records the prior text and the revert steps.
- [ ] The final QC loop and the Phase 0 baseline remain full runs with coverage comparison. CI is unchanged.

## Constraints & Risks

- No new Python.
- Test runs are parallel only.
- Epic #1217 is editing `.claude/lib/docs` and the docs skills concurrently. Avoid those files.
- Risk: weaker detection of cross-module regressions between Phase 0 and final QC. The final QC full run and CI remain the backstop.

## Test Conditions to Consider

- [ ] Contract tests that read the Test Cadence wording
- [ ] Harness generation drift check
- [ ] Bundle parity tests

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/targeted-test-cadence/` folder from the template
