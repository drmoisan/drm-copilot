# Bug: feature-review coverage hook review follow-ups and SubagentStop envelope (E4)

- Issue: #896 (https://github.com/drmoisan/drm-copilot/issues/896)
- Related: #884 (Codex half only), #897 (feature-review coverage validator only)
- Epic: subagentstop-envelope (epic issue #904), child E4, wave 1, complexity band C3
- Integration branch: epic/subagentstop-envelope-integration
- Feature branch: bug/subagentstop-envelope-feature-review-coverage-896
- Upstream dependency: E1 (#897, folder hint subagentstop-envelope-core-897, branch bug/subagentstop-envelope-core-897)
- Issue adoption: existing issue #896 adopted; no new issue created. Populated from `gh issue view 896`, `gh issue view 884`, and `gh issue view 897` on 2026-10-11.
- Work Mode: full-bug

## Summary

PR #879 made `.claude/hooks/validate-feature-review-coverage.ps1` read coverage floors from the consuming repository's `CLAUDE.md`. Open findings remain (#896): an unreadable `CLAUDE.md` makes the hook fail closed although the spec says it falls back to defaults (CR-4); the hook is 477 lines, 23 under the 500-line limit (CR-8); figure-before-comparator statements silently fall back to defaults (CR-9); a mock is repeated in eight test cases (CR-6). The Codex copy `.codex/hooks/validate-feature-review-coverage.ps1` still enforces a separate fixed 80% floor, and 80/90 figures remain in the feature-review-workflow skills and `.codex/agents/feature-review.toml`.

From #884 (Codex half): `.codex/hooks/validate-feature-review-coverage.ps1` (304 lines) is at 7.30% line coverage (10 of 137 lines, Pester, CI run 38022356096), below the uniform 85% floor.

From #897 (this validator only): `.claude/hooks/validate-feature-review-coverage.ps1` reads `$env:CLAUDE_HOOK_INPUT`, parses `.output` (line 367), passes the environment variable at line 471, and blocks with `exit 1` at line 474. The documented SubagentStop envelope arrives on stdin and carries `last_assistant_message`; only exit 2 blocks (PR #881 / #786).

## Environment

- PowerShell 7; feature-review SubagentStop completion gate (Claude) and Codex feature-review hook.
- Baseline: origin/epic/subagentstop-envelope-integration at ac525c4ef (main at 2ef8d361 plus the epic manifest).

## Steps to Reproduce

1. Make the repository-root `CLAUDE.md` unreadable (or simulate a read failure in a test) and run the Claude hook.
2. Write a coverage statement as "line coverage: 70% minimum" in `CLAUDE.md` and run the Claude hook.
3. Read `.codex/hooks/validate-feature-review-coverage.ps1` and `.codex/agents/feature-review.toml` for fixed floors.
4. Invoke the Claude hook with the documented SubagentStop envelope on stdin whose `last_assistant_message` lacks the required review artifact; observe that it does not block with exit 2.
5. Read the Pester per-file coverage for `.codex/hooks/validate-feature-review-coverage.ps1`.

## Expected Behavior

- Behavior on an unreadable `CLAUDE.md` matches the spec, with the spec and behavior aligned on one choice.
- Statements the parser does not recognize are reported rather than silently replaced by defaults, or the accepted form is documented.
- The Claude and Codex hooks and the feature-review skill and agent texts use the same floor source.
- The Claude hook reads the stdin envelope through the E1 helper and blocks with exit 2 on every block path.
- Every changed PowerShell file, including the Codex hook, has at least 85% line coverage; no production file exceeds 500 lines.

## Actual Behavior

- CR-4 (Minor): `.claude/hooks/validate-feature-review-coverage.ps1:50-71`, used at line 441, throws on an unreadable `CLAUDE.md` (fail closed).
- CR-8 (Info): the hook is 477 lines.
- CR-9 (Info): `.claude/hooks/feature-review-coverage-thresholds.ps1:57`: figure-before-comparator statements fall back to defaults.
- CR-6 (Nit): `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, F824-1..F824-8 (lines 41-230), repeat the `Get-ArtifactFileContent` mock switch.
- PR #879 Follow-ups item 5: the Codex hook and its mirror keep a separate 80 percent floor; 80/90 figures remain in the feature-review-workflow skills and `.codex/agents/feature-review.toml` and their mirrors.
- #884: Codex hook at 7.30% line coverage.
- #897: Claude hook uses `CLAUDE_HOOK_INPUT`, `.output`, and `exit 1`.

## Sources

- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/code-review.2026-10-10T00-44.md` lines 33-41.
- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/code-review.2026-10-10T14-25.md` lines 46-54.
- `docs/features/epics/subagentstop-envelope/epic.md` (Shared Design, Decomposition).

## Out of Scope

- The bash half of #884 (`.claude/lib/bash/compute-concurrency-batches.sh`).
- The other eight SubagentStop validators (owned by E2 and E3).
- `.claude/settings.json` and the shared helper `.claude/hooks/subagentstop-envelope.ps1` (owned by E1).

## Issue Closure

The PR for this child may close #896. It uses `Refs #884` and `Refs #897` and does not close either.

## Impact / Severity

Medium. The Claude and Codex feature-review gates enforce different floors, so the same review can pass on one surface and fail on the other. The Claude gate does not block at runtime while it reads the wrong transport and exits 1. The Codex gate is almost entirely untested.
