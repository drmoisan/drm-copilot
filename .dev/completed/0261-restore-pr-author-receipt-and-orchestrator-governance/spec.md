# 2026-06-27-restore-pr-author-receipt-and-orchestrator-governance — Spec

- **Issue:** #261
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-27T22-38
- **Status:** Draft
- **Version:** 0.1

## Overview

Two orchestration-governance controls are currently in a weakened state in this repository and must be hardened.

1. PR-author provenance uses a forgeable authorization-sentinel model. The PreToolUse hook `enforce-pr-author-skill.ps1` currently gates `gh pr create` / `gh pr edit --body*` on a short-lived sentinel file `artifacts/pr_author_authorization.json` (`issued_by` / `issued_at` / `ttl_seconds`). The hook's own notes state the sentinel is "not a cryptographic or security control" and is forgeable by any actor with `Write(/artifacts/**)` access. The hardened model instead binds the PR body by content hash: a sibling SHA-256 receipt for `artifacts/pr_body_<N>.md`.

2. Remediation and CI governance risks being de-duplicated out of the always-loaded orchestrator agent definition (`.claude/agents/orchestrator.md`) into on-demand skills that may not be loaded. The agent contract must retain the remediation-loop checkpoint shape, the CI-monitoring/post-PR-remediation section (including the verbatim invariant that the orchestrator must not commit workflow-file changes outside the remediation loop), and the full Remediation Loop Protocol.


## Behavior

### Part A — SHA-256 receipt PR-author provenance
- `enforce-pr-author-skill.ps1` (PreToolUse) verifies, for a `gh pr create` / `gh pr edit --body-file` once the PR-context artifact exists, a sibling provenance receipt with ordered, specific deny reasons: PR_BODY_PATH_NONCANONICAL, PR_AUTHOR_RECEIPT_MISSING, PR_AUTHOR_RECEIPT_NUMBER_MISMATCH, PR_AUTHOR_RECEIPT_HASH_MISMATCH, PR_AUTHOR_RECEIPT_STALE. Existing shape blocks (inline --body, no body flag, --body-file with no context) are retained. The authorization-sentinel code path is removed. Filesystem/clock/hash access goes through injectable adapter seams. As a PreToolUse hook it emits deny via `hookSpecificOutput.permissionDecision='deny'`.
- `.claude/skills/orchestrate/SKILL.md`: the authoritative PR-author contract becomes the receipt handoff (`## PR Authoring (pr-author Handoff)`); the `## PR Creation Gate` lists six conditions, condition 5 being the receipt condition and condition 6 the CI-green gate. Any sentinel-as-gate "PR Creation Delegation" section is removed.
- `.claude/agents/orchestrator.md`: the PR section references the receipt handoff and points to the orchestrate skill as authoritative.
- Reconcile the pr-author agent and any `validate-pr-author-output` SubagentStop hook to the receipt model or remove sentinel assumptions.

### Part B — remediation + CI governance retained in the orchestrator agent
- `.claude/agents/orchestrator.md` retains `### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation` (with the verbatim invariant "The orchestrator must not commit workflow-file changes outside the remediation loop."), and `## Remediation Loop Protocol` with its subsections (Prohibited Delegations, Required Artifacts Per Cycle, Preflight Sub-State Semantics, Scope-change Rule, Exit Gate, Citations).


## Inputs / Outputs

Inputs to the `enforce-pr-author-skill.ps1` PreToolUse hook:

- The `gh` command text supplied via the `CLAUDE_TOOL_INPUT` environment variable (the JSON-encoded tool invocation the hook parses to detect `gh pr create` / `gh pr edit --body-file` and to extract the `--body-file` path and its `<N>` capture group).
- On-disk artifacts read through injectable adapter seams:
  - `artifacts/pr_body_<N>.md` — the PR body file referenced by `--body-file`; its bytes are the SHA-256 hash input.
  - `artifacts/pr_body_<N>.receipt.json` — the sibling SHA-256 receipt that binds the body file by content hash.
  - `artifacts/pr_context.summary.txt` — the PR-context artifact produced by `mcp__drm-copilot__collect_pr_context`; its existence enables the receipt path (Cases D/E/F) and its last-write time is the staleness reference for the receipt.

Output of the hook:

- A PreToolUse decision JSON object with `hookSpecificOutput.permissionDecision` set to `allow` (all checks pass) or `deny` (a shape block or one of the five ordered receipt reasons). The hook writes the JSON to stdout and exits 0; the deny shape is the hardened PreToolUse form already in place from issue #259.

Config keys and defaults:

- No new configuration keys. The canonical body-file path pattern `artifacts/pr_body_<N>.md` and the sibling receipt path `artifacts/pr_body_<N>.receipt.json` are fixed conventions, not configurable values.
- The script-level constants for the removed sentinel (`$script:PrAuthorAuthorizationPath`, `$script:PrAuthorAuthorizationTtlSeconds`) are deleted.

Versioning / backward-compatibility constraints:

- The PreToolUse `permissionDecision` deny shape is retained unchanged; the `validate-pr-author-output.ps1` SubagentStop hook retains its `decision: block` / `exit 1` shape and must not be converted to the `permissionDecision` form.
- The receipt model replaces the sentinel model; there is no dual-mode support. The sentinel artifact `artifacts/pr_author_authorization.json` is no longer read or written by any runtime file.

## API / CLI Surface

### Receipt artifact shape

The pr-author handoff writes `artifacts/pr_body_<N>.receipt.json` as a sibling of `artifacts/pr_body_<N>.md`:

```json
{
  "skill": "pr-author",
  "pr_body_path": "artifacts/pr_body_<N>.md",
  "number": <N>,
  "sha256": "<lowercase hex SHA-256 of the body file bytes>",
  "context_summary_path": "artifacts/pr_context.summary.txt",
  "created_at": "<ISO-8601 UTC timestamp, strictly newer than pr_context.summary.txt last-write>"
}
```

Field contracts:

- `skill` — literal `pr-author`.
- `pr_body_path` — the canonical body path `artifacts/pr_body_<N>.md`.
- `number` — the integer `<N>` matching the body-file path capture group.
- `sha256` — lowercase hex of the SHA-256 of the body file bytes.
- `context_summary_path` — `artifacts/pr_context.summary.txt`.
- `created_at` — ISO-8601 UTC; must be strictly newer than the last-write time of `artifacts/pr_context.summary.txt`.

### Ordered deny reasons (receipt path: `--body-file` with context present)

The five checks run in this fixed order on the `--body-file-with-context` path; each failure emits `permissionDecision=deny` with the corresponding reason and short-circuits:

1. `PR_BODY_PATH_NONCANONICAL` — the `--body-file` argument does not match `--body-file\s+artifacts/pr_body_(\d+)\.md\b` (case-sensitive). No artifact read; pattern match only.
2. `PR_AUTHOR_RECEIPT_MISSING` — `artifacts/pr_body_<N>.receipt.json` does not exist.
3. `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` — `receipt.number` is not equal to `<N>` (as integer).
4. `PR_AUTHOR_RECEIPT_HASH_MISMATCH` — the SHA-256 (lowercase hex) of the body file bytes does not equal `receipt.sha256`.
5. `PR_AUTHOR_RECEIPT_STALE` — `receipt.created_at` is not strictly newer than the last-write time of `artifacts/pr_context.summary.txt`.

If all five pass, the receipt verification function returns `$null` and the hook allows.

### Retained shape blocks (unchanged)

The existing non-receipt blocks are retained and emit deny with their established reasons:

- Inline `--body` (without `--body-file`) on `gh pr create` / `gh pr edit` → `PR_AUTHOR_SKILL_BLOCKED`.
- `gh pr create` with no body flag → `PR_AUTHOR_SKILL_BLOCKED`.
- `gh pr edit` with no body flag → allow (`$null`).
- `--body-file` present but `artifacts/pr_context.summary.txt` absent → `PR_CONTEXT_MISSING`.

### Contracts and validation rules

- Reason ordering is significant: a noncanonical path is reported before a missing receipt, and so on, so the most specific applicable failure is surfaced first.
- The canonical-path regex is case-sensitive; a path differing only in case is non-canonical.

## Data & State

### Six-condition PR Creation Gate

`## PR Creation Gate` in `.claude/skills/orchestrate/SKILL.md` is expanded from five to six conditions; the receipt condition is inserted as condition 5 and the CI-green condition is renumbered to condition 6:

1. `blocking_findings_resolved: true`.
2. AC verification artifact confirms all acceptance criteria pass.
3. Mandatory toolchain passed in its most recent run.
4. Checkpoint `next_step` is `S8_create_pr`.
5. PR body produced via the pr-author handoff: `artifacts/pr_body_<N>.md` exists with a matching `artifacts/pr_body_<N>.receipt.json`, and was submitted via `--body-file`.
6. `ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`. DONE is not written while either sub-condition is false.

### Part B — orchestrator-agent governance sections

`.claude/agents/orchestrator.md` is extended so remediation and CI governance are part of the always-loaded agent contract (these sections are currently absent from the 103-line agent file and reside only in the on-demand orchestrate skill):

- `### Remediation Loop Checkpoint Shape` — the checkpoint-shape invariants for the remediation loop.
- `### CI Monitoring and Post-PR Remediation` — including the verbatim invariant: "The orchestrator must not commit workflow-file changes outside the remediation loop."
- `## Remediation Loop Protocol` — with subsections Prohibited Delegations, Required Artifacts Per Cycle, Preflight Sub-State Semantics, Scope-change Rule, Exit Gate, and Citations.

Content duplication between the agent and the orchestrate skill is acceptable for these governance-critical invariants; the skill remains the authoritative detailed reference.

### Bundled-mirror parity invariant

Runtime files under `.claude/**` (excluding `agent-memory/**` and `settings.local.json`) and under `.codex/**` / `.agents/**` must remain byte-identical to their bundled mirrors:

- `.claude/**` → `extensions/drm-copilot/resources/claude-customizations/.claude/**`, enforced by `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- `.codex/**` and `.agents/**` → `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/**` and `.agents/**`, enforced by `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`. The `.codex` hook mirror retains its prepended `# Converted hook` header.

Data transformations and invariants:

- The SHA-256 is a deterministic transform of the body file bytes; it is computed inline from the bytes supplied by the `Get-PrBodyFileBytes` seam, so no filesystem boundary is crossed in tests.
- The staleness check compares two pieces of artifact metadata (`receipt.created_at` and the context file's last-write time); it does not read wall-clock time, so no clock seam is required on the receipt path.

Persistence and migration:

- No persistent store or schema migration is introduced. The receipt and body files are transient session artifacts under `artifacts/`. No backfill is required; the change is to enforcement logic and contract documents only.

## Constraints & Risks

- Cross-cutting change touching PowerShell hooks plus Markdown contracts and multiple ecosystem mirrors enforced by contract tests.
- 500-line file cap; PowerShell toolchain (PoshQC format -> PSScriptAnalyzer -> Pester); professional tonality.
- Must not weaken any SubagentStop hook.


## Implementation Strategy

### PowerShell hook changes (`enforce-pr-author-skill.ps1`)

- Remove the sentinel-only code entirely: the script-level constants `$script:PrAuthorAuthorizationPath` and `$script:PrAuthorAuthorizationTtlSeconds`, the read seam `Get-PrAuthorAuthorizationContent`, the validation function `Test-PrAuthorAuthorization`, and the call to it inside `Get-PrAuthorBypassReason`. Update the `.DESCRIPTION` block to describe receipt verification instead of the sentinel.
- Add three injectable adapter seams so tests mock without disk/network/temp-file access:
  - `Get-PrBodyFileBytes [string] $BodyFilePath` → `[byte[]]` or `$null` (maps to `[IO.File]::ReadAllBytes`).
  - `Get-PrAuthorReceiptContent [string] $ReceiptFilePath` → raw JSON `[string]` or `$null` (maps to `Test-Path` + `Get-Content -Raw`).
  - `Get-PrContextSummaryLastWriteUtc` → `[DateTime]` UTC or `$null` (maps to `(Get-Item -LiteralPath ...).LastWriteTimeUtc`).
- Add the receipt-verification function `Test-PrAuthorReceiptVerification` implementing the five ordered deny reasons, with SHA-256 computed inline via `[System.Security.Cryptography.SHA256]::Create()` over the bytes from `Get-PrBodyFileBytes` (no dedicated hash seam). Replace the sentinel call on the `--body-file-with-context` path with a call to this function.
- Retain `Get-PrContextArtifactExistence` (Case C) and the generic deny/allow builders `Get-PrAuthorSkillBlockDecision` / `Get-PrAuthorSkillAllowDecision` unchanged. `Get-CurrentDateTimeUtc` is no longer called on the receipt path; its removal is optional.

### Markdown contract edits

- `.claude/skills/orchestrate/SKILL.md` — replace `## PR Creation Delegation` (sentinel write/delete protocol) with `## PR Authoring (pr-author Handoff)` describing the receipt handoff sequence; expand `## PR Creation Gate` from five to six conditions (receipt = condition 5, CI-green = condition 6).
- `.claude/agents/orchestrator.md` — rewrite the PR section to reference the receipt handoff and point to the orchestrate skill as authoritative (remove all sentinel language); add the three Part B governance sections (`### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation` with the verbatim workflow-commit invariant, `## Remediation Loop Protocol` with all subsections).
- `.claude/agents/pr-author.md` — replace `## Authorization Sentinel Write/Delete Protocol` with `## PR Body and Receipt Write Protocol`; update the frontmatter `description`; update `## Enforcement Strength (Honest Disclosure)` to state the receipt is a policy-level integrity check (not a cryptographic security boundary). `## Final Output Requirement` is unchanged.
- `.claude/skills/pr-author/SKILL.md` — add an `## Output Artifact` section documenting the body-file write, SHA-256 computation, and receipt shape (write operations remain in agent scope, which already holds `Write(/artifacts/**)`).
- `.github/agents/pr-author.agent.md` — replace `## Authorization Sentinel Protocol (Documentation-Only in This Ecosystem)` with the receipt protocol description.
- `README.md` — replace the line-40 "short-lived authorization sentinel" description with the receipt-model description.

### Mirrors and per-batch phasing

Each runtime edit is propagated to its byte-identical bundled mirror in the same batch. Per the PowerShell per-batch cap (3 production, 3 test files), the work is phased:

- Batch 1 — PowerShell hook: `.claude/hooks/enforce-pr-author-skill.ps1` plus its claude and `.codex` mirrors, and the test file `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`. Run PoshQC format → analyze → Pester before proceeding.
- Batch 2 — pr-author agent and skill (Markdown): `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, `.github/agents/pr-author.agent.md`, and their mirrors.
- Batch 3 — orchestrate skill and orchestrator agent (Markdown): `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, their mirrors, and `README.md`.

### Dependencies, logging, rollout

- Dependency changes: none. No new or removed packages.
- Logging/telemetry: none added. The hook's only output remains the PreToolUse decision JSON.
- Rollout: no feature flag or staged deploy. The change is enforcement-logic and contract-document hardening; the prior sentinel path is removed rather than retained behind a fallback.

## Definition of Done

Each acceptance criterion (from `user-story.md`) maps to its verifying test or grep proof:

- AC1 — `enforce-pr-author-skill.ps1` verifies the SHA-256 receipt and emits the five ordered deny reasons; the sentinel code path is removed; deny uses the PreToolUse `permissionDecision` shape.
  - Verified by `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` contexts for `PR_BODY_PATH_NONCANONICAL`, `PR_AUTHOR_RECEIPT_MISSING`, `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH`, `PR_AUTHOR_RECEIPT_HASH_MISMATCH`, `PR_AUTHOR_RECEIPT_STALE`, plus the allow-path context; and by `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` confirming the deny shape. Grep proof: no occurrence of `Test-PrAuthorAuthorization` or `pr_author_authorization` in `.claude/hooks/enforce-pr-author-skill.ps1`.
- AC2 — No file references a forgeable PR authorization sentinel as the PR gate.
  - Grep proof: no runtime file (`.claude/**`, `.codex/**`, `.github/agents/**`, `README.md`, and bundled mirrors) references `pr_author_authorization`, `issued_by`, `issued_at`, or `ttl_seconds` as the PR gate. Historical feature docs are excluded from the proof.
- AC3 — `## PR Creation Gate` in the orchestrate skill lists six conditions including the receipt condition; the orchestrator agent references the receipt handoff.
  - Grep proof: `.claude/skills/orchestrate/SKILL.md` contains six numbered gate conditions with condition 5 as the receipt condition; `.claude/agents/orchestrator.md` references `## PR Authoring (pr-author Handoff)`.
- AC4 — The orchestrator agent file contains the verbatim "must not commit workflow-file changes outside the remediation loop" invariant and the three governance sections.
  - Grep proof: `.claude/agents/orchestrator.md` contains the literal string "must not commit workflow-file changes outside the remediation loop" and the headings `### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation`, and `## Remediation Loop Protocol` with its subsections.
- AC5 — Pester: pr-author hook tests cover all five receipt failure reasons plus the shape blocks; PoshQC format/analyze clean; 500-line cap respected.
  - Verified by a green Pester run of `enforce-pr-author-skill.Tests.ps1` (five receipt contexts plus retained shape-block contexts), a clean PoshQC format and analyze run, and a line-count check that `.claude/hooks/enforce-pr-author-skill.ps1` remains under 500 lines.
- AC6 — Runtime files and all bundled mirrors (.claude, .codex, .agents, .github) remain in sync; bundle-parity contract tests pass.
  - Verified by `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` and `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (byte-identical), run via `poetry run pytest`.

## Seeded Test Conditions (from potential)
- [ ] Receipt verification: canonical path, missing receipt, number mismatch, hash mismatch, staleness vs pr_context.summary.txt last-write.
- [ ] Retained shape blocks (inline --body, no body flag, --body-file without context).
- [ ] Grep proofs for the workflow-commit invariant and the six-condition PR gate.
- [ ] Bundle-parity contract tests across all mirrors.
