# require-pr-author-agent-for-prs (Issue #231)

- Date captured: 2026-06-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/require-pr-author-agent-for-prs/ (Issue #231)

- Issue: #231
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/231
- Last Updated: 2026-06-24
- Work Mode: full-feature

## Problem / Why

PR bodies must be produced by the `pr-author` skill, but the current enforcement (`enforce-pr-author-skill.ps1`) only checks that `gh pr create`/`gh pr edit` use `--body-file` with the PR-context artifact present. It does not verify that the body was authored by a dedicated `pr-author` agent, and there is no `pr-author` agent in `.claude/agents/`. As a result, the orchestrator (main thread) can hand-write a PR body to a file and open the PR directly, bypassing the `pr-author` skill workflow — which is exactly what happened for PR #228.

## Proposed Behavior

- Add a `pr-author.md` agent under `.claude/agents/` (and bundled/translated copies in the Codex and GitHub Copilot ecosystems) whose sole responsibility is to run the `pr-author` skill: consume the canonical PR-context bundle and produce the PR body, then open/update the PR.
- Strengthen the enforcement so that opening a PR (`gh pr create`) — and editing a PR body (`gh pr edit --body`/`--body-file`) — is permitted only when performed by the `pr-author` agent. Any attempt by the main thread or another agent to open a PR is blocked.
- Provide a verifiable signal the hook can use to attribute the action to the `pr-author` agent (for example an env var identifying the active subagent, or an authorization artifact emitted by the agent), determined during research.

## Acceptance Criteria (early draft)

- [ ] A `pr-author.md` agent exists under `.claude/agents/` and runs the `pr-author` skill, with bundled Codex and GitHub Copilot equivalents.
- [ ] No PR can be opened (`gh pr create`) except by the `pr-author` agent; main-thread or other-agent attempts are blocked by a PreToolUse hook.
- [ ] PR body edits (`gh pr edit` with a body) are likewise restricted to the `pr-author` agent.
- [ ] The enforcement is consistent across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies.
- [ ] Hook behavior is covered by tests (allowed: pr-author agent; blocked: non-agent / inline body / missing context).
- [ ] The orchestrate skill documents mandatory delegation to the `pr-author` agent for PR creation.

## Constraints & Risks

- The hook must reliably attribute a `gh pr create` call to the `pr-author` agent; the available attribution mechanism (env var vs. authorization artifact) must be verified before implementation.
- Must not deadlock orchestration: the orchestrator must be able to delegate to the `pr-author` agent to satisfy the gate.
- Cross-ecosystem consistency: root and bundled copies must stay in sync; Codex copies are translations.

## Test Conditions to Consider

- [ ] PreToolUse hook unit tests for allowed and blocked PR-open attempts.
- [ ] Attribution-signal handling (present vs. absent).
- [ ] Backward compatibility with the existing `--body-file` + context-artifact checks.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create active feature folder from the template