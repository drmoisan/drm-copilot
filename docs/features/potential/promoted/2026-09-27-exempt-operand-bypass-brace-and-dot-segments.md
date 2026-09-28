# exempt-operand-bypass-brace-and-dot-segments (Issue #732)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/exempt-operand-bypass-brace-and-dot-segments/ (Issue #732)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #732
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/732
- Last Updated: 2026-09-27
## Summary

The preimplementation gate's exempt-path check (`Test-ExemptOrchestrationOperand` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three byte-identical copies) can be bypassed. Two confirmed operand shapes resolve outside the exempt `docs/features/active/` tree but are treated as exempt.

## Environment

- OS/version: any
- Python version: n/a (PowerShell hooks, Claude and Codex surfaces)
- Command/flags used: a staging or implementation command whose operand uses brace expansion or `.\.` segments
- Data source or fixture: none

## Steps to Reproduce

1. Brace expansion (CR-2, found in the #713 review): an operand `docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts` expands in the shell to a path outside the exempt tree, but the gate evaluates the literal string as exempt.
2. Dot segments (#710 decision D7, `evidence/other/follow-up-d7-operand-gap.md`): `docs/features/active/.\./.\./.\./src/x.ps1` is still exempt.

## Expected Behavior

An operand is exempt only when its fully resolved path, after shell expansion and normalisation, lies inside the exempt tree. Otherwise it fails closed.

## Actual Behavior

Both shapes are treated as exempt, so a production-file change can bypass the preimplementation readiness gate.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #713 `code-review.2026-09-27T06-40.md` CR-2; #710 `evidence/other/follow-up-d7-operand-gap.md`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An enforcement bypass. Both predate the PRs that found them.

## Suspected Cause / Notes

The operand check prefix-matches the raw string. It does not reject shell-expansion metacharacters (`{`, `}`, `*`, `?`, `[`) and does not normalise `.`/`..` segments, including the mixed `.\.` form.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: fail closed on any operand containing brace, glob or bracket metacharacters. Normalise `/` and `\`, collapse `.` and `..`, then require that the normalised path stays under the exempt root. Add Pester deny cases for both shapes and allow cases for ordinary exempt paths. Keep the four copies byte-identical and within the 500-line cap.
- [ ] Integration scenario to retest: the documented exempt workflows (feature docs, checkpoint writes) still pass.
- [ ] Manual verification notes: grep the other gates for the same prefix-match idiom.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
