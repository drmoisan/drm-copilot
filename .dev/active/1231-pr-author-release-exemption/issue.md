# pr-author-release-exemption (Issue #1231)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1231-pr-author-release-exemption/ (Issue #1231)

- Issue: #1231
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1231
- Last Updated: 2026-11-23
- Work Mode: full-feature

## Problem / Why

Issue #1201 added the release-commit allowance: a destination repository that commits `.claude/release-commit-allowance.json` lets an agent stage and commit a release version bump on a matching branch without an orchestration checkpoint. Opening the release pull request remains blocked. `.claude/hooks/enforce-pr-author-skill.ps1` requires an orchestrator-state checkpoint that passes `--require-pr-creation-ready` for every `gh pr create --body-file`, and its only checkpoint-free exemptions are the docs-only exemption (#901, every path under `docs/`) and the cleanup consolidation exemption (#1026, branch `documentationandmemories`). A release diff changes package manifests, lockfiles, and configuration files, so neither exemption applies.

Today a release pull request is opened only because `scripts/dev-tools/Invoke-FullRelease.ps1` calls `gh pr create` inside a PowerShell process the hook cannot read. That is an inspection gap, not a designed path, and destination repositories have no equivalent script. An agent-driven release therefore needs a full orchestration checkpoint for a version-bump diff of a few files.

## Proposed Behavior

Add a release exemption to the checkpoint-free path of the pr-author surface, keyed on the existing destination-owned `.claude/release-commit-allowance.json` (schema version 1, unchanged):

- `enforce-pr-author-skill.ps1`: after the checkpoint preflight fails and the docs-only and cleanup exemptions decline, exempt a structural `gh pr create` when no checkpoint exists at the resolved path, the command carries exactly one explicit `--head` and one explicit `--base`, the head branch matches a `branch_patterns` entry of one allowance, the pushed remote head equals the worktree `HEAD`, and every path in the `origin/<base>...HEAD` diff equals an `allowed_paths` entry of that same allowance. The receipt checks (body file, context summary, SHA-256 receipt) still run unchanged.
- Any other gate that blocks a checkpoint-free release pull request (for example the `Agent(pr-author)` model-routing gate and the preimplementation gate for the receipt Write) gains an equivalent allow-side leg, built the same way as the existing cleanup and docs-estate legs.
- Failures append a release sub-code after the existing exemption reasons; deny text without an allowance file is unchanged.

## Acceptance Criteria (early draft)

- [ ] A checkpoint-free `gh pr create --body-file` on a branch matching an allowance, whose diff lies entirely in that allowance's `allowed_paths`, passes the checkpoint preflight of `enforce-pr-author-skill.ps1` and is still subject to the receipt checks.
- [ ] A diff path outside the matched allowance, a branch matching no allowance, an invalid allowance file, an existing checkpoint, a missing or repeated `--head`/`--base`, a remote head that differs from `HEAD`, or `gh pr edit` each keeps the deny, with a distinct release sub-code appended after the existing exemption reasons.
- [ ] Without `.claude/release-commit-allowance.json` every existing deny text is byte-identical.
- [ ] Every other gate on the checkpoint-free release pull-request path admits the same release case through an equivalent leg, with the same fail-closed behaviour.
- [ ] The allowance parser of `hook-release-allowance-context.ps1` is reused, not reimplemented; the schema is unchanged.
- [ ] All changed hook files are mirrored byte-identically into the bundle copies, the pack manifests list any new file, and the execution-environment brief and orchestrator-state rule describe the leg.
- [ ] Pester tests cover each allow and deny case; enforcement hooks invoke no Python.

## Constraints & Risks

- Policy-level control, not a security control: whoever can commit the allowance file decides which paths may reach a pull request without a checkpoint.
- The allowance file is destination-owned and never pushed down; this repository commits none.
- PowerShell only; file-size limits apply to the hook files (split into a sibling file as the docs-only and cleanup legs do).
- Hooks run with the default branch's copy in isolated subagents, so behaviour is proven by Pester.

## Test Conditions to Consider

- [ ] Unit coverage of the release exemption predicate with injected git and file seams
- [ ] Integration through `Get-PrAuthorBypassReason` with a stubbed checkpoint preflight
- [ ] Byte-identity of mirrors and pack-manifest listing

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/pr-author-release-exemption/` folder from the template
