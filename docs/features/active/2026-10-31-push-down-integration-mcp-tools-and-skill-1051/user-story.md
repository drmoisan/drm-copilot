# `2026-10-31-push-down-integration-mcp-tools-and-skill` — User Story

- Issue: #1051
- Parent: epic #1018 (`shared-agent-harness-layer`), child 10
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-14
- Spec: `spec.md` (rules S1 to S56, constraints C1 to C6)

## Story Statement

- As a repository owner pushing the harness into an existing repository, I want the push-down to record every decision it cannot make mechanically in `.push-down-integration-needed.json`, so that no integration choice is guessed by a deterministic command or by a hidden model call.
- As an agent session integrating a push-down, I want `detect_push_down_integration` to report the destination's ecosystems, workflows and structured conflicts without modifying anything, so that I resolve conflicts from facts rather than from my own reading of the tree.
- As an agent session integrating a push-down, I want `validate_push_down_integration` to return a deterministic pass or a list of failures, together with a fixed list of what it does not check, so that I know when to stop and what remains unverified.
- As a coordinator, I want the integration loop documented in the `push-down-integration` skill and carried out through ordinary edits under the destination's hooks and review, so that every integration decision has a transcript and passes the same gates as any other change.

## Problem / Why

A push-down into a destination that already has workflows, a different version matrix, existing hooks or a different layout requires integration decisions. The push-down is a deterministic TypeScript extension command; it should not make those decisions, and it should not call a language model itself. A model call inside the extension bypasses the repository's hooks, the model-routing and preimplementation gates and the review step; it needs credentials and quota that the coordinator cannot see; it fails wherever no model is signed in; and it leaves no transcript or receipt.

The integration judgment belongs in an agent session, where the model is already governed and visible. The session needs structured facts to work from and a deterministic check that the result is correct.

## Personas & Scenarios

- Persona: Repository owner (destination maintainer)
  - Maintains a repository that already has its own CI workflow, version pins and possibly edited hooks.
  - Cares that the push-down never overwrites destination work and never makes an undocumented choice.
  - Constraint: integration changes must pass the destination's own hooks and review.
  - Goal: adopt the harness CI and customizations with a reviewable record of each decision.
  - Frustration: a push-down that silently produces two workflows named `CI` or a required check that no job produces.

- Persona: Integrating agent session
  - Runs under the destination's hooks, model routing and review step.
  - Cares about structured inputs and an unambiguous stop condition.
  - Constraint: the MCP tools report facts and verdicts only; every judgment is the session's.
  - Goal: resolve each recorded item and reach `verdict: pass`.

- Scenario: Integrating CI into a destination that already has `ci.yml`
  1. The owner runs a CI-enabled push-down in apply mode. The destination's `.github/workflows/ci.yml` declares `name: CI`, so the push-down withholds its caller, delivers the data file, and writes `.push-down-integration-needed.json` listing `workflow-name-collision`, `existing-ci-workflow` and `missing-required-check` items. It makes no model call.
  2. An agent session loads the `push-down-integration` skill, reads the file, and calls `detect_push_down_integration`, which returns the same item ids with `source: detect`, the workflow list with job names, and the ecosystems present. Nothing in the destination changes.
  3. The session chooses `keep-both-workflows`: it renames the existing workflow through an ordinary edit, which the destination's hooks and review accept, and re-runs the push-down, which now writes the caller.
  4. The session calls `validate_push_down_integration`. V1 to V5 pass, so `verdict` is `pass`. The session stops, quotes the `not_checked` list in its hand-off, and reports that `existing-ci-workflow` remains in the file with the decision `keep-both-workflows`.
  5. Outcome: one workflow named `CI` produces `CI Required Gate`, coverage artifact paths match the toolchain rules, manifest hashes are consistent, and every decision is in the session transcript.

- Scenario: A destination-edited hook
  1. A re-run of the push-down finds a managed hook whose hash differs from its manifest entry and from the payload. It keeps the file and records `destination-edited-file` with `detail.is_hook: true`.
  2. The session decides the edit is intentional, lists the path in `.push-down-exclusions` (`declare-destination-owned`), and calls validate. V5 reports the path under `destination_owned` and does not fail.

## Acceptance Criteria

- [x] AC1 (draft 1): An apply-mode push-down writes `.push-down-integration-needed.json` listing each unresolved decision it observes, with the schema, kind vocabulary, id, ordering, rendering and forbidden-content rules of spec S1 to S9, the sources of S10, the post-run view of S11, the write rule of S12, no manifest entry (S13) and the result field of S14; a dry run returns the same items without writing; and the writer module passes the no-model-call text test of S49.
- [x] AC2 (draft 2): `detect_push_down_integration` returns `integration.ecosystems`, `integration.workflows` and `integration.conflicts` per spec S21 to S31, using the workflow reader of S15 to S20, and a write-recording fake records no write (S32, S33).
- [x] AC3 (draft 3): `validate_push_down_integration` fails on unparsable or unsupported YAML (V1, S36), a malformed data file (V2, S37), missing required check names (V3, S38), mismatched coverage artifact paths (V4, S39) and inconsistent manifest hashes (V5, S40), each shown by a failing fixture; passes on a correct integration shown by a passing fixture per rule and by the end-to-end case of S44; and returns the verdict shape and `not_checked` list of S35 and S41 with read-only, deterministic behavior (S43).
- [x] AC4 (draft 4): The `push-down-integration` skill documents the read, resolve, validate loop and stop condition, names `detect_push_down_integration` and `validate_push_down_integration`, covers every item kind and resolution option, and states the same not-checked list as the tool (spec S51 to S54).
- [x] AC5 (draft 5): `detect_push_down_integration` and `validate_push_down_integration` follow the existing MCP tool conventions (explicit required `workspace_root`, `additionalProperties: false`, read-only annotations, structured `integration` result, `ok` semantics) and have unit tests with injected in-memory file-system seams (spec S23, S34, S42, S45 to S48).
- [ ] AC6 (draft 6): No new Python file is added; the tools and writer are TypeScript and no helper script is added (spec C1, C2, Language Classification).
- [x] AC7 (owner behavior 5): No new module calls a model or uses MCP sampling, shown by the text test of spec S49 and the capability and in-memory client test of S50.
- [ ] AC8: Both tools are reachable from Codex through `enabled_tools` and the `repo-automation-adapter` skill without a `.claude/settings.json` edit (spec S55), and the execution-environment brief bullet is present after the docs-tools bullet in every `_BRIEF_COPIES` copy with byte identity preserved (S56).

## Non-Goals

- The tools do not resolve any item and do not call a model or use MCP sampling.
- The tools do not check CI execution, ruleset or branch protection, coverage values, hook behavior, symlinks, or anything else in the `not_checked` list (spec S41).
- No YAML library dependency, no actionlint invocation, no VS Code command, and no `.claude/settings.json` change.
- No change to the manifest schema (#1049) or to the CI data file schema (#1050).
- The seeded scratch-destination integration scenario is CI-dependent or orchestrator-owned; locally it is represented by the in-memory end-to-end case (spec S44).
