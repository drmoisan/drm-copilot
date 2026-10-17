# exempt-operand-bypass-brace-and-dot-segments (Issue #732)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/exempt-operand-bypass-brace-and-dot-segments/ (Issue #732)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #732
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/732
- Last Updated: 2026-09-27
- Work Mode: full-bug

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

## Bundled Issues

This feature is child C1b of epic #852 (`enforcement-hook-precision`). It delivers the primary issue #732 and the three bundled issues below in one pull request. No new GitHub issue is created for this child.

### #738 — Epic-scope resolution reads only the first `git -C` of the first segment

Acceptance conditions:

- Epic-scope target resolution, on both the Claude and Codex surfaces, resolves the effective target of every command segment (each `git -C <path>`, a repeated `-C`, a path operand into another worktree), consuming the segment and invocation API owned by `.claude/hooks/hook-command-invocation.ps1` (C1a, #824) rather than re-implementing segment parsing.
- Every resolved target must satisfy the readiness conditions; an unresolvable or ambiguous target fails closed.
- Codex `workdir` (amended 2026-10-08 after research): the Codex PreToolUse payload carries the raw command string only, with no shell and no `workdir` field, so `workdir` is unobservable to the hook. The session root is the target for a segment without an explicit `-C`; this residual is recorded in the spec as a follow-up candidate (upstream payload support, or a Codex strict mode requiring an absolute `-C`).
- Gate-level Pester tests cover a two-segment command whose second segment targets a different worktree, a repeated `-C`, a relative `-C` path, and an unresolvable `-C` path, on both surfaces.

### #745 — Trailer-form documentation and missing trailer tests

Acceptance conditions:

- `.agents/skills/epic-plan/SKILL.md` and its Codex bundle mirror document the Integration Commit Form and the trailer commit forms accepted by the preimplementation gate (single-quoted `$`, backtick, and `--trailer`).
- A test covers `--trailer` taking a following `--` as its value (CR-4).
- Denied-test rows exercise U+201A, U+201B, and U+201E.
- The helpers line reported at line 131 (140 characters) is brought within the repository line-length limit.
- Item 5 (heredoc-fed commit messages, decision D5) is optional; the spec records an explicit adopt-or-defer decision with its rationale.

### #735 — Which shell Codex uses on Windows (research precondition)

Acceptance conditions:

- A research artifact under `research/` determines which shell Codex uses to execute commands on Windows and records the evidence for the finding, or states that the shell cannot be determined from available evidence.
- No Codex-surface command-parsing change is planned or made before that finding is recorded.
- The Codex-surface parsing plan follows the recorded finding. If the shell is undetermined, the plan adopts the fail-closed option: an operand or command shape whose meaning differs between POSIX shells and PowerShell is denied rather than exempted.
