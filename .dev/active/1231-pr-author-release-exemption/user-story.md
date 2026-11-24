# `2026-11-23-pr-author-release-exemption` — User Story

- Issue: #1231
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23T23-30
- Spec: `.dev/active/1231-pr-author-release-exemption/spec.md`

## Story Statement

- As a destination-repository owner who has committed `.claude/release-commit-allowance.json`, I want an agent to open the release pull request for a matching branch without an orchestration checkpoint, so that a version-bump release does not require a full orchestration run.
- As a repository maintainer, I want every checkpoint-free release pull request to be limited to the paths my allowance lists and to fail closed with a specific reason otherwise, so that the exemption cannot carry unrelated changes.
- As a maintainer of a repository with no allowance file, I want every existing hook decision and deny text to stay unchanged, so that this feature has no effect where it is not adopted.

## Problem / Why

Issue #1201 added the release-commit allowance: a destination repository that commits `.claude/release-commit-allowance.json` lets an agent stage and commit a release version bump on a matching branch without an orchestration checkpoint. Opening the release pull request remains blocked. `.claude/hooks/enforce-pr-author-skill.ps1` requires an orchestrator-state checkpoint that passes `--require-pr-creation-ready` for every `gh pr create --body-file`, and its only checkpoint-free exemptions are the docs-only exemption (#901, every path under `docs/`) and the cleanup consolidation exemption (#1026, branch `documentationandmemories`). A release diff changes package manifests, lockfiles, and configuration files, so neither exemption applies.

Today a release pull request is opened only because `scripts/dev-tools/Invoke-FullRelease.ps1` calls `gh pr create` inside a PowerShell process the hook cannot read. That is an inspection gap, not a designed path, and destination repositories have no equivalent script. An agent-driven release therefore needs a full orchestration checkpoint for a version-bump diff of a few files.

## Personas & Scenarios

- Persona: Destination-repository owner
  - Owns a repository that receives the drm-copilot push-down and publishes versioned packages.
  - Cares that releases are routine and auditable, and that hook enforcement stays in place for ordinary work.
  - Constraint: has no `Invoke-FullRelease.ps1` equivalent; releases run through agents under the Claude hooks.
  - Goal: commit, push, and open a release pull request for a version bump without creating an orchestration checkpoint.
  - Frustration: the #1201 commit succeeds, then `Agent(pr-author)`, the receipt Write, and `gh pr create` are each denied for lack of a checkpoint.
- Persona: Harness maintainer
  - Maintains the Claude hooks and their bundle copies.
  - Cares that new exemptions reuse existing parsers and seams, stay mirrored, and leave deny texts unchanged where not adopted.
  - Constraint: hooks in isolated subagents run the default branch's copy, so behavior must be proven by Pester.
- Scenario: Opening a release pull request on an allowed branch
  - Actor: an agent session in the destination repository, after committing a version bump on `release/patch-20261201` under #1201.
  - Trigger: the release commit is pushed and the pull request must be opened.
  - Steps: the agent runs `collect_pr_context`, pushes the branch, delegates to `Agent(pr-author)` with one `branch:` and one `base:` line, pr-author writes the body and the receipt, and runs `gh pr create --head release/patch-20261201 --base main --body-file artifacts/pr_body_<N>.md`.
  - Decisions: each gate finds no checkpoint, reads the allowance file, matches the branch, and confirms that every diff path is listed by that allowance; the pr-author gate also confirms the pushed remote head equals `HEAD` and runs the receipt checks.
  - Outcome: the pull request is opened without an orchestration checkpoint.
- Scenario: A release branch carrying an unlisted file
  - Actor: the same agent, on a release branch that also changed a source file.
  - Steps: the delegation is denied with `RELEASE_DELEGATION_PATH_NOT_ALLOWED`; a direct `gh pr create` is denied with `RELEASE_EXEMPTION_PATH_NOT_ALLOWED` appended after the existing exemption reasons.
  - Outcome: the agent sees the specific reason and either removes the file or uses a checkpoint.
- Scenario: Merging the release pull request
  - Outcome: the merge remains governed by the existing merge gate and is outside this feature (see Non-Goals).

## Acceptance Criteria

- [x] US-AC-01: On a branch matching an allowance, with a diff entirely within that allowance's `allowed_paths` and no checkpoint, the agent can delegate to pr-author, write the PR body receipt, and run `gh pr create`, and the receipt checks still apply (spec AC-01, AC-05, AC-07).
- [x] US-AC-02: When any release precondition fails, the gate still denies, and the deny reason names the specific release sub-code after the existing exemption reasons (spec AC-02, AC-03, AC-06, AC-08).
- [x] US-AC-03: In a repository without `.claude/release-commit-allowance.json`, every deny text of the changed gates is byte-identical to its text before this feature (spec AC-10).
- [x] US-AC-04: An unexpected error in a release leg leaves the original deny in place (spec AC-11).
- [x] US-AC-05: The release legs reuse the #1201 allowance parser, branch matcher, and file seams, and the allowance schema is unchanged (spec AC-12).
- [x] US-AC-06: The hook changes are mirrored byte-identically into the Claude bundle, new files are listed in `core.json`, and the rule, brief, skill, and agent documentation describe the legs through their generator sources (spec AC-15, AC-17, AC-18).
- [x] US-AC-07: Pester suites cover every allow and deny case, new hook files reach at least 85% line coverage, and no enforcement hook invokes Python (spec AC-13, AC-20, AC-21).
- [x] US-AC-08: The documentation states that the exemption is a policy-level control, not a security control: whoever can commit the allowance file decides which paths may reach a pull request without a checkpoint (spec AC-18).

## Non-Goals

- Merging a release pull request without a checkpoint (scope decision D1). A checkpoint-free merge leg in `.claude/hooks/enforce-epic-merge-gate.ps1` is out of scope; this feature covers pull-request creation only.
- Editing a release pull request with `gh pr edit` without a checkpoint.
- Changes to the Codex surface, the allowance schema, the #1201 context and release-sibling files, or `Invoke-FullRelease.ps1`.
- Fetching remote refs inside a hook.
