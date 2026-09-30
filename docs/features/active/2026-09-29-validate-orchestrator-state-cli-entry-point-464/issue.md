# validate-orchestrator-state-cli-entry-point (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Source issue: #464 (pre-existing, OPEN). Epic: #771 (`orchestrator-state-contract-correctness`).

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

## Summary

`scripts/dev_tools/validate_orchestrator_state.py` has no `__main__` guard, no `argparse`, and no `main()`. The command `python -m scripts.dev_tools.validate_orchestrator_state <path> [flags]` therefore does nothing and exits 0, which is a false green for any caller that treats exit 0 as a passed validation gate.

## Environment

- OS/version: any (reproduced without `poetry run`)
- Python version: repository Poetry environment
- Command/flags used: `python -m scripts.dev_tools.validate_orchestrator_state /nonexistent/path.json --require-complete`
- Data source or fixture: none; the path does not exist

## Steps to Reproduce

1. Run `python -m scripts.dev_tools.validate_orchestrator_state /nonexistent/path.json --require-complete`.
2. Run `echo $?`.
3. Run `grep -c "__main__\|argparse\|def main" scripts/dev_tools/validate_orchestrator_state.py`.

## Expected Behavior

The command reads the checkpoint, applies the requested gate flags, prints each validation error, and exits non-zero when errors exist or when the path does not exist.

## Actual Behavior

No output and exit code 0 even though the path does not exist. The grep count is 0.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: exit code 0 with empty output for a nonexistent path; observed during orchestration of #462 (PR #463).

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An orchestrator that runs the documented preflight and reads exit 0 believes a validation gate passed that never executed. The failure is silent and indistinguishable from success.

## Suspected Cause / Notes

The module was written as an import-only library. `.claude/hooks/validate-orchestrator-output.ps1` uses a direct import, so hook-level enforcement works. `scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state <path>` already exposes an equivalent dispatcher route. The module is 492 lines, so the entry point must live in a separate module (500-line cap).

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: exit code and stderr for valid checkpoint, invalid checkpoint, missing path, unreadable path, each of the three flags.
- [ ] Integration scenario to retest: `python -m scripts.dev_tools.validate_orchestrator_state` against a missing path and against a valid checkpoint.
- [ ] Manual verification notes: compare exit codes with the `validate_orchestration_artifacts.py orchestrator-state` dispatcher for the same input.

## Acceptance Criteria

- [x] `python -m scripts.dev_tools.validate_orchestrator_state <path>` runs an argparse-based `main()` reached through a `__main__` guard.
- [x] The CLI accepts the `--require-complete`, `--require-model-routing`, and `--require-pr-creation-ready` flags and passes each to `validate_orchestrator_state_text` unchanged.
- [x] The CLI prints each returned validation error and exits non-zero when the error list is non-empty.
- [x] The CLI exits non-zero and prints a diagnostic when the checkpoint path does not exist.
- [x] The CLI exits 0 and prints nothing to stderr for a valid checkpoint.
- [x] `scripts/dev_tools/validate_orchestrator_state.py` stays under 500 lines and no new production or test file exceeds 500 lines.
- [x] Documentation of the CLI in `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md`, and their bundled mirrors, is consistent with the implemented behavior.
- [x] Existing validator behavior and existing checkpoints are unchanged (byte-identical error lists).

## Next Step

- [x] Promote to GitHub issue (bug-report template): pre-existing issue #464; `potential_to_issue` is not called (see #509).
- [ ] Move to active fix folder / branch
