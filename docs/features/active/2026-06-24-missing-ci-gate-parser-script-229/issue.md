# missing-ci-gate-parser-script (Issue #229)

- Date captured: 2026-06-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/missing-ci-gate-parser-script/ (Issue #229)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #229
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/229
- Last Updated: 2026-06-24
- Work Mode: full-bug

## Summary

The orchestrate skill's Step S9 (CI Green Gate) instructs the orchestrator to parse `gh pr checks` JSON via `scripts/orchestration/Invoke-CiGateParser.ps1`, but that script does not exist in the repository. The S9 contract cannot be executed as written.

## Environment

- OS/version: Windows (Git Bash), repository runtime
- Python version: N/A (PowerShell/orchestration tooling)
- Command/flags used: orchestration S9 CI Green Gate per `.claude/skills/orchestrate/SKILL.md`
- Data source or fixture: `gh pr checks --required --json bucket,name,state,link,workflow`

## Steps to Reproduce

1. Run an orchestration to the S9 CI Green Gate step.
2. Follow the documented S9 procedure, which calls `scripts/orchestration/Invoke-CiGateParser.ps1` to emit the `ci_gate` object.
3. Attempt to invoke the script.

## Expected Behavior

`scripts/orchestration/Invoke-CiGateParser.ps1` exists and parses the `gh pr checks` JSON into the documented `ci_gate` object, deriving `ci_gate.conclusion` as `success` / `failure` / `pending`.

## Actual Behavior

The script is absent (`scripts/orchestration/` does not exist). The orchestrator must derive `ci_gate.conclusion` directly from the `gh pr checks` JSON to complete S9, deviating from the documented contract.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `find . -name "Invoke-CiGateParser.ps1"` returns no results; `ls scripts/orchestration/` reports the directory does not exist.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The orchestrator can derive the CI conclusion directly from the `gh` JSON, so orchestration is not fully blocked, but the documented S9 contract is unexecutable and the parser provides the single source of truth for `ci_gate` derivation.

## Suspected Cause / Notes

The orchestrate skill references a parser script that was specified but never added to the repository, or was removed without updating the skill text. Files to inspect: `.claude/skills/orchestrate/SKILL.md` (Step S9 section), and the absent `scripts/orchestration/` directory.

## Proposed Fix / Validation Ideas

- [ ] Add `scripts/orchestration/Invoke-CiGateParser.ps1` that consumes `gh pr checks --json` output and emits the documented `ci_gate` object with a derived `conclusion`.
- [ ] Unit coverage: success / failure / pending derivation cases; malformed-JSON handling.
- [ ] Integration scenario to retest: run S9 against a live PR and confirm the parser emits the `ci_gate` object consumed by the checkpoint.
- [ ] Alternative: if the parser is intentionally not provided, update the orchestrate skill to document direct JSON derivation as the contract.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch