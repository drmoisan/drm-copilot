# Remediation Inputs — Issue 1188 (R4 re-audit)

Timestamp: 2026-11-15T20-57
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Issue: 1188
Base: main
Merge-Base: 1df569f65ccdcca86cc9adeb5a1a33ef56f988cb
Reviewed-Head: 5f8b15daf20b977cfdba2fa14319e36f6536df67
Source review artifacts:
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/policy-audit.2026-11-15T20-57.md`
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/code-review.2026-11-15T20-57.md`
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/feature-audit.2026-11-15T20-57.md`

## Disposition

Two findings require remediation inside this item (owner rule: related findings are fixed in remediation cycles). Both are autonomous and contained: the fix for R2 stays inside the classify sibling's two functions and adds test rows, and the fix for E1 appends one line to one evidence file. Neither changes a spec acceptance criterion, a public interface, a validator contract, or a hook decision outside the named form, and the prior cycle (cycle 2, proportionate) was not light, so the path is light. AC-1 to AC-15 evaluate PASS and stay checked. The reviewer's full Pester gate at the head passed (27305 run, 0 failed, 18 skipped; 96.04% repo-wide lines; both siblings 100%), and the targeted pytest contract suites passed (88).

## Finding R2

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect and its fix lie in one pure PowerShell sibling on this branch and its test tables, and are verifiable by local Pester rows and the parallel gate with no external system or owner decision.
Finding-Scope: contained

- Location: `Get-OrchestrationGateJoinedWordText` and `Get-OrchestrationGateSupplementalPatternIndex` in `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three byte-identical copies (`.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`); rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1`.
- Observed: a joined-word run starts at the first record followed by a substitution opener and absorbs every later record joined only by openers and closers; records contain spaces, so `FOO=$(pwd) npm --prefix $(pwd) run lint` is one run whose first record is `FOO=`. The whole-word check reads only the first record, and the npm record is never a run start, so Form 1 returns no index. `FOO=$(pwd) npm --prefix $(pwd) run lint`, `env FOO=$(pwd) npm --prefix $(pwd) run lint`, `FOO=$(pwd) npx --prefix $(pwd) jest`, and `env FOO=$(pwd) npx --prefix $(pwd) jest` are unclassified on both surfaces, and the Claude gate allows them; without the assignment the commands deny `TARGET_WORKTREE_NOT_DERIVABLE`.
- Fix: in Form 1, for each run member whose `RawText` carries `npm` (or `npx`) as a whole word, match the unchanged npm (or npx, or npx-option) pattern against the joined text from that member to the run end; return the index when any member matches. Keep the four copies byte-identical.
- Verification: new Positive function and classify gate rows for the four commands above, and one V-style operands gate row for `FOO=$(pwd) npm --prefix $(pwd) run lint` (deny `TARGET_WORKTREE_NOT_DERIVABLE`, zero reads, zero listing calls) on both surfaces, red before the fix and green after; existing Negative rows stay unclassified; the classify parity suite and the parallel Pester gate pass.

## Finding E1

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction is one appended line in a tracked evidence file on this branch, needing no external system or owner decision.
Finding-Scope: contained

- Location: `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/evidence/qa-gates/self-review.2026-11-15T20-38.md`.
- Observed: commit `5f8b15daf` added the file at 2026-11-15T20:37:51Z, earlier than its filename stamp and `Timestamp:` value 20-38, and the file has no correction line.
- Fix: append one clock-stamped correction line stating that the stamp was composed and that the file was written no later than 2026-11-15T20:37:51Z; do not rename the file or edit existing lines.
- Verification: `git diff` of the file shows one added line and no removed line.

## Light Fix Tasks

- [x] [P0-T1] Fix R2 in `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three byte-identical copies: evaluate every run member that carries `npm` or `npx` as a whole word, and add the leading-assignment Positive rows to `enforce-orchestration-preimplementation-gate-classify.Cases.ps1` and one V-style row to `enforce-orchestration-preimplementation-gate-operands.Cases.ps1` (fail-before, then pass on both surfaces).
- [x] [P0-T2] Fix E1 in `evidence/qa-gates/self-review.2026-11-15T20-38.md`: append one clock-stamped correction line for the composed stamp, leaving existing lines unchanged.

## Non-remediation notes

- Info: wrapper payloads (`sh -c "pytest tests/x.py"`, `sh -c "npm run lint"`, `pwsh -Command "npm run lint"`) are unclassified by stage 1 on `main` and on this branch; recommend that the coordinator track payload classification for the non-git patterns as its own issue (stage-1 design of #1160).
- Info: mention forms such as `echo npm --prefix $(pwd) run lint` are newly classified by Form 1 and deny; fail-closed and within the spec's Form 1 definition.
- The reviewer's probe scripts are in the gitignored `artifacts/scratch-issue-1188/` folder; the owner-directive decision file is `artifacts/orchestration/owner-directive-decisions/feature-review-1188-r4/OD-1.md`.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
