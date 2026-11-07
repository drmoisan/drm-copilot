# `qa-loop-scoped-restart-with-confirmation-pass` — User Story

- Issue: #1095
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-06T21-06

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The Final QA Loop contract (`.claude/skills/atomic-plan-contract/SKILL.md`, section "Final QA Loop", and the "Mandatory Toolchain Loop" in `.claude/rules/general-code-change.md`) says: run format, lint, type check where applicable, then tests with coverage; "if any step fails or changes files, restart the loop from step 1 until a clean pass completes." The restart is always a full pass of the whole toolchain, whatever changed.

Measured cost (epic 1019 session, 2026-11-03 18:36 UTC to 2026-11-07 00:36 UTC, from the agents' own transcripts; calls of 30 seconds or longer only):

- Test and quality-check runs: 739 calls, 1,916 minutes (31.9 hours) of agent time. Executors spent 1,149 of their 2,979 active minutes (39 percent) in these runs.
- Passes per item, counted from the `evidence/qa-gates/format.*.md` files: #1067 five, #1034 five, #1080 four, #1026 three, most others one or two. The count is a proxy; evidence naming varies between items and a few items did not use that file name.
- Longest single runs: 6 to 20 minutes each (#1031).

Why #1034 needed five passes, taken from its own evidence files. Each restart was caused by a change to a few files:

1. Pass 1 to 2: one new test failure (`enforcement-hooks-no-python-invocation.Tests.ps1`, five dynamic-invocation sites in `DocsSurfaceDeltaCommands.psm1`).
2. Pass 2 to 3: a merge of the integration branch (siblings #1024 and #1033).
3. Pass 3 to 4: one test renamed in `Invoke-DocsCommand.RevisionContext.Tests.ps1`.
4. Pass 4 to 5: a repository-root seam change in `enforce-docs-complete-gate.ps1` and its bundle copy after a Python manifest-closure contract test failed.

The rule's intent is sound: a fix can break an earlier stage, and a clean pass proves the final state. The cost is that a one-file fix pays for the whole suite again.


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

- [ ] The owner approves a change to the canonical policy before implementation; the amended rule is written once in the canonical source and mirrored from there.
- [ ] The canonical text defines scoped pass, full pass, confirmation pass, the full-pass trigger list and the "when in doubt, full" rule, with no weakening of any gate (format, lint, type, architecture, unit, contract and integration stages, and the coverage thresholds, are unchanged).
- [ ] Every tracked copy that states the restart rule is updated through the existing mirror process and passes its parity tests. A search at the time of writing finds the phrase "restart the loop from step 1" (or close variants) in 63 tracked files: the `.claude` rules, skills and the atomic-executor agent; the `.agents` skills and `AGENTS.md`; the `.codex` executor definitions; the `.github` agents and `atomic-plan-contract` skill; and the corresponding copies under `extensions/drm-copilot/resources/`. The plan must list them and handle the language-specific `*-qa-gate` skills.
- [ ] The plan validators and templates (the atomic-plan-contract `Final QA Loop` and "rerun behavior" requirements, and any validator that checks for the phrase) accept the amended wording and still reject plans that omit a confirmation pass.
- [ ] The QA evidence format records pass type, restart reason, trigger files and duration; a validator or template check covers it.
- [ ] A pilot on at least three subsequent items compares full-suite minutes and first-PR-run CI failures against the figures above; success is a clear reduction in full-pass minutes with no increase in first-run CI failures. The pilot result is recorded before the rule is made permanent.


## Non-Goals

Call out what is explicitly excluded from this feature.
