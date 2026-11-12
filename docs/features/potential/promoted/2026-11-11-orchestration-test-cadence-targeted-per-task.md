# orchestration-test-cadence-targeted-per-task (Issue #1167)

- Date captured: 2026-11-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestration-test-cadence-targeted-per-task/ (Issue #1167)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1167
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1167
- Last Updated: 2026-11-12
## Summary

The harness text reads as a full toolchain run (including the whole unit suite) after every atomic-plan task. The owner rule is: "The rule for an orchestration is a full test after every phase and only targeted tests after every task". The executor should run targeted checks per task and the full toolchain loop only at each phase gate and in the final QA loop.

## Environment

- OS/version: Windows 11 host and Linux CI; any destination repository that receives the push-down
- Python version: 3.13
- Command/flags used: `/orchestrate` and `/execute-hard-lock` atomic execution
- Data source or fixture: downstream repository iar-migration, issue #145, 2026-11-11 (about 10,400 unit tests)

## Steps to Reproduce

1. Run an orchestration whose atomic plan has many tasks in a repository with a large unit suite.
2. Observe the atomic executor follow the per-task toolchain loop wording (for example R3 in `.claude/skills/orchestrate/SKILL.md`, "Mandatory Toolchain Loop" in `.claude/rules/general-code-change.md`).
3. Observe the full unit suite run after every task.

## Expected Behavior

After each task: format, lint, and type check scoped to the changed files, plus only the tests that cover the changed modules (mirrored test paths under `tests/` and tests that import the changed modules), with the selection recorded in the task evidence. At each phase gate: the full toolchain loop, restarting from step 1 on a failure or auto-fix. Final QA loop unchanged. The cadence is defined once (likely in the `atomic-plan-contract` skill) and referenced from every other surface.

## Actual Behavior

Executors run the full unit suite after each task. Downstream observation: about 10 tasks per hour across a 68-task plan, with most task time spent in the full suite, and a second orchestration on the same machine queued behind each run under the single-suite rule.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: R3: "Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping."

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Surfaces to inspect: `.claude/skills/orchestrate/SKILL.md` (R3 and executor delegation guidance), `.claude/rules/general-code-change.md`, `.claude/skills/atomic-plan-contract/SKILL.md` (Final QA Loop, Pre-Mortem "Test isolation" bullet, per-task test gate wording), the atomic-executor agent, the execute-hard-lock and atomic-plan prompt templates, the execution-environment brief (six copies), the language rules and QA-gate skills, and the Copilot (`.github/`), Codex (`.codex/`, `.agents/`), and push-down (`extensions/drm-copilot/resources/`) mirrors. Any plan validator that requires a full-suite command in every task.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: a Pester test pinning the canonical cadence wording, and a sweep test that fails when any harness surface prescribes a full-suite run per task; parity tests for every mirror.
- [ ] Integration scenario to retest: plan validator accepts targeted per-task test commands and requires a full-toolchain gate task at the end of every phase.
- [ ] Manual verification notes: coverage rules, Phase 0 baseline comparison, the no-SKIPPED rule, the final QA loop, and the single-suite pseudo-queue rule are unchanged. Destinations receive the change after the extension rebuild and push-down.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
