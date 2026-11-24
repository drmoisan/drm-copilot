# `2026-11-23-merge-gate-release-exemption` — User Story

- Issue: #1234
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-24
- Spec: `.dev/active/1234-merge-gate-release-exemption/spec.md`

## Story Statement

- As a release operator in a destination repository that has committed `.claude/release-commit-allowance.json`, I want an agent to merge the release pull request for a matching branch without an orchestration checkpoint once CI on its exact head is green, so that a version-bump release completes without a full orchestration run.
- As a release operator, I want a checkpoint-free release merge to be refused with a specific reason whenever the pull request carries an unlisted path, a moved head, or a CI result that is not a green `pull_request` run, so that the allowance cannot merge unrelated or unverified changes.
- As a release operator on Codex, I want the same merge to be admitted under the same rules, so that the release flow does not depend on which agent runtime runs it.
- As a maintainer of a repository with no allowance file, I want every merge-gate decision and deny text to stay unchanged, so that this feature has no effect where it is not adopted.

## Problem / Why

Issue #1201 lets an agent commit a release version bump without an orchestration checkpoint on a branch matching the destination-owned `.claude/release-commit-allowance.json`, and issue #1231 (PR #1232) lets the same agent open the release pull request without a checkpoint. Merging that pull request is still blocked. `.claude/hooks/enforce-epic-merge-gate.ps1` admits a `gh pr merge` only through branches that read an orchestrator checkpoint or that admit only documentation paths. A checkpoint-free release pull request therefore reaches `EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`, and the release flow stops one step before completion. The Codex merge gate denies the same case. #1231 recorded the merge as out of scope.

## Personas & Scenarios

- Persona: Release operator
  - Runs releases in a destination repository that receives the drm-copilot push-down and publishes versioned packages.
  - Cares that a release is routine, auditable, and merged only after CI passes on the exact commit being merged.
  - Constraint: releases run through agents under the Claude or Codex hooks; there is no orchestration checkpoint for a version bump.
  - Goal: commit, open, and merge a release pull request without creating an orchestration checkpoint.
  - Frustration: the #1201 commit and the #1231 pull request succeed, then `gh pr merge` is denied for lack of a checkpoint.
- Persona: Harness maintainer
  - Maintains the Claude and Codex hooks and their bundle copies.
  - Cares that the new leg reuses existing parsers and seams, is byte-identical across trees and bundles, and leaves deny texts unchanged where not adopted.
  - Constraint: hooks in isolated subagents run the default branch's copy, so behavior must be proven by Pester.
- Scenario: Merging a release pull request on an allowed branch
  - Actor: an agent session in the destination repository after the release pull request for `release/patch-20261201` was opened under #1231.
  - Trigger: CI on the pull request head has finished successfully.
  - Steps: the agent reads the head SHA and runs `gh pr merge <N> --merge --match-head-commit <sha>`.
  - Decisions: the gate finds no checkpoint, the existing branches decline, and the release leg reads the allowance file, reads the pull request once, confirms the head branch matches one allowance, every changed path is listed by that allowance, the live head equals `<sha>`, and the newest `CI` run on that head is a successful `pull_request` run.
  - Outcome: the merge is admitted without an orchestration checkpoint.
- Scenario: A release pull request that is not eligible
  - Actor: the same agent, on a release pull request that also changed a source file, or whose CI is still running, or whose head moved after the SHA was read.
  - Steps: the agent runs the same merge command.
  - Outcome: the gate denies, and the deny text ends with ` (release merge not applied: <CODE>: <detail>)` naming `RELEASE_MERGE_PATH_NOT_ALLOWED`, `RELEASE_MERGE_CI_NOT_GREEN`, or `RELEASE_MERGE_HEAD_MISMATCH`. The agent removes the file, waits for CI, or re-reads the head.
- Scenario: A command shape the leg does not model
  - Actor: the same agent, running `gh pr merge <N> --merge --admin`, `gh pr merge <N> --auto`, or a merge without `--match-head-commit`.
  - Outcome: the gate denies with `RELEASE_MERGE_COMMAND_NOT_MODELLED` or `RELEASE_MERGE_MATCH_HEAD_MISSING`.

## Acceptance Criteria

- [ ] US-AC-01: On the Claude gate, as the release operator, I can merge a checkpoint-free release pull request with `gh pr merge <N> --merge --match-head-commit <sha>` when its head branch matches an allowance, every changed path is listed by that allowance, the live head equals `<sha>`, and the newest `CI` run on that head is a successful `pull_request` run (spec AC-01).
- [ ] US-AC-02: On the Codex gate, as the release operator, I can merge the same pull request under the same conditions (spec AC-02, AC-29).
- [ ] US-AC-03: When the allowance file is invalid, a checkpoint records the pull request, the command shape is not modelled, or `--match-head-commit` is missing or malformed, the merge is denied with `RELEASE_MERGE_CONFIG_INVALID`, `RELEASE_MERGE_CHECKPOINT_PRESENT`, `RELEASE_MERGE_COMMAND_NOT_MODELLED`, or `RELEASE_MERGE_MATCH_HEAD_MISSING` respectively, before any `gh` call (spec AC-04 to AC-07, AC-19).
- [ ] US-AC-04: When the pull request cannot be read, is not open, comes from a fork, has a head that differs from `<sha>`, lists too many files, contains a rename or copy, has a branch matching no allowance, has no changed path, or has a path outside the allowance, the merge is denied with `RELEASE_MERGE_PR_UNRESOLVED`, `RELEASE_MERGE_PR_NOT_OPEN`, `RELEASE_MERGE_CROSS_REPOSITORY`, `RELEASE_MERGE_HEAD_MISMATCH`, `RELEASE_MERGE_FILES_TRUNCATED`, `RELEASE_MERGE_CHANGE_NOT_MODELLED`, `RELEASE_MERGE_BRANCH_NOT_MATCHED`, `RELEASE_MERGE_EMPTY_DIFF`, or `RELEASE_MERGE_PATH_NOT_ALLOWED` respectively (spec AC-08 to AC-14).
- [ ] US-AC-05: When CI cannot be read, has no `CI` run on the head, has a newest run from a `push` or `workflow_dispatch` event, or is pending or failed, the merge is denied with `RELEASE_MERGE_CI_UNREADABLE`, `RELEASE_MERGE_CI_MISSING`, `RELEASE_MERGE_CI_EVENT_NOT_ALLOWED`, or `RELEASE_MERGE_CI_NOT_GREEN` respectively (spec AC-15 to AC-17).
- [ ] US-AC-06: Each denial names only the first failing check, as the last term of the existing deny text on both gates (spec AC-18, AC-23).
- [ ] US-AC-07: An unexpected error in the release leg leaves the original deny in place (spec AC-20).
- [ ] US-AC-08: In a repository without `.claude/release-commit-allowance.json`, every merge-gate deny text on both gates is byte-identical to its text before this feature, and no additional `gh` or `git` call is made (spec AC-21, AC-22).
- [ ] US-AC-09: Merges handled by the existing epic, parallel, green-CI, standalone-authorization, and docs-only branches, and the review guard, behave as before (spec AC-24, AC-25).
- [ ] US-AC-10: The leg reuses the #1201 allowance parser and branch matcher, the #1231 predicate file, the docs-only shape and `gh` helpers, and the child-CI run helpers, and the allowance schema is unchanged (spec AC-26 to AC-28).
- [ ] US-AC-11: The hook changes are byte-identical across the Claude and Codex trees and their bundle copies, new files are listed in both `core.json` manifests, and the rule, brief, and pr-author skill describe the leg through their generator sources (spec AC-29 to AC-31, AC-34).
- [ ] US-AC-12: The documentation states that the merge leg is a policy-level control, not a security control: whoever can commit the allowance file decides which paths may be merged without a checkpoint (spec AC-35).
- [ ] US-AC-13: Pester suites cover every allow and deny case with injected seams, the new leg file reaches at least 85% line coverage, and no enforcement hook invokes Python (spec AC-37 to AC-39).

## Non-Goals

- Any change to the allowance schema, its keys, or its location.
- Any change to the existing allow branches (epic child, epic, parallel, green-CI, `standalone_merge_authorizations`, docs-only) or to the review guard.
- Restricting the merge method, validating the base branch beyond spelling, or a configurable CI workflow name.
- Admitting a bare `gh pr merge` without an explicit number.
- Fetching remote refs or running a local diff inside the leg.
- A new hook registration or a change to `config/harness-parity-matrix.json`.
- Changing `scripts/dev-tools/Invoke-FullRelease.ps1`.
