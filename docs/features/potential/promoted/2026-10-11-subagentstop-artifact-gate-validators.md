# subagentstop-artifact-gate-validators (Issue #905)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/subagentstop-artifact-gate-validators/ (Issue #905)
- Related: #897 (parent defect; this entry is its artifact-gate validators' slice), epic #904 (subagentstop-envelope, child E3)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub issue template.

- Issue: #905
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/905
- Last Updated: 2026-10-11
## Summary

The artifact-gate validators' slice of #897, split out so epic #904 child E3 has its own issue. Four SubagentStop validators read `$env:CLAUDE_HOOK_INPUT`, take `output` off the parsed root, and block with `exit 1`, which does not block: `.claude/hooks/validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1` and `validate-task-researcher-output.ps1`. E1 of epic #904 measured the documented envelope live: JSON on stdin with `last_assistant_message`, no `output` key, `CLAUDE_HOOK_INPUT` unset, and only exit 2 blocks.

Two strict rules in these validators would start refusing legitimate work once the validators block: the task-researcher research-filename rule and the prd-feature numeric-derivation rule.

## Environment

- OS/version: Windows 11 Pro; GitHub Actions CI
- Python version: n/a - validators are PowerShell 7
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

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/subagentstop-envelope-artifact-gates-897/research/2026-10-11T12-05-subagentstop-envelope-artifact-gates-research.md`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High, as for #897: these completion gates are inert, so completion claims for research, feature documents, pull requests and discovery artifacts are self-attested. Enabling them without fixing the two strict rules would refuse legitimate work.

## Suspected Cause / Notes

- Same root cause as #897; the shared helper is delivered by epic #904 child E1.
- The two strict rules were never exercised at runtime because the validators never blocked.

## Proposed Fix / Validation Ideas

- [ ] Convert the four validators to the E1 helper; block with exit 2; invert the two `Should -Be 1` suites.
- [ ] Before enabling exit-2 blocking, run each validator against the existing artifacts on main and remove false positives: research filenames must accept the forms in use or the documented convention; the numeric-derivation rule must apply only to computed or derived numbers.
- [ ] Record each rule change with its rationale.
