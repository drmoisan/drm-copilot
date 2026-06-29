# `2026-06-27-restore-pr-author-receipt-and-orchestrator-governance` — User Story

- Issue: #261
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-27T22-38

## Story Statement

- As the repository maintainer, I want PR-author provenance bound to the PR body by content hash rather than by a short-lived authorization file, so that the PR-creation gate cannot be satisfied by a forgeable sentinel that any actor with `Write(/artifacts/**)` access could write.
- As the repository maintainer, I want the remediation-loop checkpoint shape, the CI-monitoring/post-PR-remediation invariant, and the full Remediation Loop Protocol to live in the always-loaded orchestrator agent contract, so that these governance controls are in effect even in contexts where the on-demand orchestrate skill is not loaded.

## Problem / Why

Two orchestration-governance controls are currently in a weakened state in this repository and must be hardened.

1. PR-author provenance uses a forgeable authorization-sentinel model. The PreToolUse hook `enforce-pr-author-skill.ps1` currently gates `gh pr create` / `gh pr edit --body*` on a short-lived sentinel file `artifacts/pr_author_authorization.json` (`issued_by` / `issued_at` / `ttl_seconds`). The hook's own notes state the sentinel is "not a cryptographic or security control" and is forgeable by any actor with `Write(/artifacts/**)` access. The hardened model instead binds the PR body by content hash: a sibling SHA-256 receipt for `artifacts/pr_body_<N>.md`.

2. Remediation and CI governance risks being de-duplicated out of the always-loaded orchestrator agent definition (`.claude/agents/orchestrator.md`) into on-demand skills that may not be loaded. The agent contract must retain the remediation-loop checkpoint shape, the CI-monitoring/post-PR-remediation section (including the verbatim invariant that the orchestrator must not commit workflow-file changes outside the remediation loop), and the full Remediation Loop Protocol.


## Personas & Scenarios

- Persona: Repository maintainer (the owner of the orchestration-governance controls).
  - Who the user is: the maintainer responsible for the agentic orchestration runtime, its PreToolUse/SubagentStop hooks, and the agent/skill contracts in `.claude/`, `.codex/`, `.agents/`, and `.github/`.
  - What they care about: that the PR-creation gate enforces genuine provenance, and that remediation and CI governance remain in force regardless of which skills happen to be loaded.
  - Their constraints: the PowerShell toolchain (PoshQC format → PSScriptAnalyzer → Pester), the 500-line file cap on runtime scripts, byte-identical bundle-parity contract tests across all mirrors, and the requirement not to weaken any SubagentStop hook.
  - Their goals and frustrations: the current authorization sentinel is self-described as "not a cryptographic or security control" and is forgeable; remediation and CI governance risk being de-duplicated out of the always-loaded agent definition into on-demand skills that may not load.
  - Their context and motivations: hardening two weakened governance controls without introducing new dependencies, telemetry, or workflow changes.

- Scenario: The pr-author handoff creates a PR through the hardened gate.
  - Who is acting: the orchestrator and the delegated `pr-author` agent, with the maintainer relying on the gate's enforcement.
  - What triggered the action: a feature branch has cleared the PR Creation Gate's prior conditions (blocking findings resolved, AC verified, toolchain passed, checkpoint at `S8_create_pr`).
  - Steps taken: the orchestrator calls `mcp__drm-copilot__collect_pr_context` to write `artifacts/pr_context.summary.txt`, then delegates to `Agent(pr-author)`. The agent runs the `pr-author` skill to produce body text, writes `artifacts/pr_body_<N>.md` and the sibling `artifacts/pr_body_<N>.receipt.json` (with `sha256`, `number`, `context_summary_path`, `created_at`), then issues `gh pr create --body-file artifacts/pr_body_<N>.md`.
  - Obstacles or decisions: the PreToolUse hook verifies the receipt in order — canonical path, receipt present, number match, hash match, staleness against the context file's last-write time — and denies with the specific ordered reason if any check fails.
  - Outcome expected: the command is allowed only when the receipt matches the body bytes and is newer than the context artifact; a body file whose bytes do not match its receipt, or a stale receipt, is denied rather than gated by a forgeable file.


## Acceptance Criteria

- [x] `enforce-pr-author-skill.ps1` verifies the SHA-256 receipt and emits the five ordered deny reasons; the sentinel code path is removed; deny uses the PreToolUse `permissionDecision` shape.
- [x] No file references a forgeable PR authorization sentinel as the PR gate.
- [x] `## PR Creation Gate` in the orchestrate skill lists six conditions including the receipt condition; the orchestrator agent references the receipt handoff.
- [x] The orchestrator agent file contains the verbatim "must not commit workflow-file changes outside the remediation loop" invariant and the three governance sections.
- [x] Pester: pr-author hook tests cover all five receipt failure reasons plus the shape blocks; PoshQC format/analyze clean; 500-line cap respected.
- [x] Runtime files and all bundled mirrors (.claude, .codex, .agents, .github) remain in sync; bundle-parity contract tests pass.


## Non-Goals

- Converting the receipt into a cryptographic security boundary. The SHA-256 receipt is a policy-level integrity check binding the body bytes to the receipt; an actor with `Write(/artifacts/**)` access can still replace both the body file and the receipt together. The honest-disclosure language reflects this; closing that gap is out of scope.
- Changing the `validate-pr-author-output.ps1` SubagentStop hook. It has no sentinel dependency and retains its `decision: block` / `exit 1` shape; it must not be converted to the `permissionDecision` form.
- Any GitHub Actions workflow change. The hardening is limited to the PowerShell hook and the Markdown agent/skill/README contracts.
- Adding dependencies, telemetry, or configuration keys.
- Modifying historical feature docs (for example the issue #231 folder) or rewriting the issue #261 feature docs to describe the receipt model as already implemented.
- Introducing a dual-mode or fallback path that retains the sentinel; the sentinel code path is removed.
