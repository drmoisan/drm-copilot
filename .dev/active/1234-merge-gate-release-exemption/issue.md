# merge-gate-release-exemption (Issue #1234)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1234-merge-gate-release-exemption/ (Issue #1234)

- Issue: #1234
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1234
- Last Updated: 2026-11-24
- Work Mode: full-feature

## Problem / Why

Issue #1201 lets an agent commit a release version bump without an orchestration checkpoint on a branch matching the destination-owned `.claude/release-commit-allowance.json`, and issue #1231 (PR #1232) lets the same agent open the release pull request without a checkpoint. Merging that pull request is still blocked. `.claude/hooks/enforce-epic-merge-gate.ps1` admits a `gh pr merge` only through an epic, parallel, green-CI standalone, or `standalone_merge_authorizations` branch, and every one of those reads an orchestrator checkpoint. A checkpoint-free release pull request therefore reaches `EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`, and the release flow stops one step before completion. This was recorded as out of scope (decision D1) in #1231.

## Proposed Behavior

Add a release leg to the merge gate, keyed on the same `.claude/release-commit-allowance.json` (schema version 1, unchanged) and built like the release legs of #1231:

- The leg is evaluated only after the existing branches decline, and only when no orchestrator checkpoint records the pull request number.
- It admits a single structural `gh pr merge <N>` (one explicit number, no chain, wrapper, `-R`/`--repo`, URL selector, `--auto`, or `--admin`) that carries `--match-head-commit <sha>`.
- One bounded `gh pr view <N>` read supplies the head branch, base branch, live head SHA, state, and changed files. The head branch must match a `branch_patterns` entry of one allowance, the live head must equal `--match-head-commit`, and every changed path must equal an `allowed_paths` entry of that same allowance.
- CI on the live head must be green: the newest `CI` workflow run for the head commit, from a `pull_request` event, is `completed` with conclusion `success`.
- Without an allowance file, deny text is byte-identical and no extra `gh` call is made. Each failure appends a distinct `RELEASE_MERGE_*` sub-code after the existing reasons.
- The Codex merge gate is evaluated for parity: if `.codex/hooks/enforce-epic-merge-gate.ps1` blocks the same case, the same leg is added there; otherwise the decision is recorded.

## Acceptance Criteria (early draft)

- [ ] A checkpoint-free `gh pr merge <N> --merge --match-head-commit <sha>` for a pull request whose head branch matches an allowance, whose changed paths all lie in that allowance's `allowed_paths`, whose live head equals the given SHA, and whose CI run on that head succeeded is admitted.
- [ ] A changed path outside the allowance, a branch matching no allowance, an invalid allowance file, a missing `--match-head-commit`, a head mismatch, a CI run that is missing, pending, failed, or from a `push` event, a checkpoint that records the pull request, or a disallowed command shape each keeps the deny with a distinct release sub-code.
- [ ] Without `.claude/release-commit-allowance.json`, every existing deny text is byte-identical and no extra `gh` call is made.
- [ ] The allowance parser and branch matcher of `hook-release-allowance-context.ps1` and the shared predicate file from #1231 are reused, not reimplemented.
- [ ] All changed hook files are mirrored byte-identically into the bundle copies, the pack manifests list any new file, and the orchestrator-state rule and execution-environment brief describe the leg through their generation sources.
- [ ] Pester tests cover each allow and deny case with injected `gh` seams; enforcement hooks invoke no Python.

## Constraints & Risks

- Policy-level control, not a security control: whoever commits the allowance file decides which paths may be merged without a checkpoint. CI green on the exact head is the remaining safeguard.
- A push after the lookup can change the head; requiring `--match-head-commit` closes that race.
- The allowance file is destination-owned and never pushed down; this repository commits none.
- PowerShell only; `enforce-epic-merge-gate.ps1` is at 498 lines, so the leg goes in a sibling file.

## Test Conditions to Consider

- [ ] Unit coverage of the release merge predicate with injected `gh` and file seams
- [ ] Integration through the merge gate's decision order with existing branches declining
- [ ] Byte-identity of mirrors and pack-manifest listing

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/merge-gate-release-exemption/` folder from the template
