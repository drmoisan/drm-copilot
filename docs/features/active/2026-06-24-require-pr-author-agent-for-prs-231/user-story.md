# `require-pr-author-agent-for-prs` — User Story

- Issue: #231
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-24T15-17

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

PR bodies must be produced by the `pr-author` skill, but the current enforcement (`enforce-pr-author-skill.ps1`) only checks that `gh pr create`/`gh pr edit` use `--body-file` with the PR-context artifact present. It does not verify that the body was authored by a dedicated `pr-author` agent, and there is no `pr-author` agent in `.claude/agents/`. As a result, the orchestrator (main thread) can hand-write a PR body to a file and open the PR directly, bypassing the `pr-author` skill workflow — which is exactly what happened for PR #228.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] A `pr-author.md` agent exists under `.claude/agents/` and runs the `pr-author` skill, with bundled Codex and GitHub Copilot equivalents.
- [ ] No PR can be opened (`gh pr create`) except by the `pr-author` agent; main-thread or other-agent attempts are blocked by a PreToolUse hook.
- [ ] PR body edits (`gh pr edit` with a body) are likewise restricted to the `pr-author` agent.
- [ ] The enforcement is consistent across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies.
- [ ] Hook behavior is covered by tests (allowed: pr-author agent; blocked: non-agent / inline body / missing context).
- [ ] The orchestrate skill documents mandatory delegation to the `pr-author` agent for PR creation.


## Non-Goals

Call out what is explicitly excluded from this feature.
