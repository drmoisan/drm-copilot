# PR-Author Receipt and Orchestrator Governance — Inventory
**Feature:** 2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261  
**Issue:** #261  
**Date:** 2026-06-27  
**Scope:** Investigation only — no source changes.

---

## 1. enforce-pr-author-skill.ps1 Current State

**File:** `.claude/hooks/enforce-pr-author-skill.ps1`  
**Line count:** 375 lines. Headroom under 500-line cap: 125 lines.  
**Deny shape:** Confirmed `permissionDecision='deny'` form with `hookSpecificOutput.permissionDecision` already in place (lines 327–333). The PreToolUse schema is already the hardened form from issue #259.

### Decision flow

| Block | Function | Lines | Trigger |
|---|---|---|---|
| Entry point | Script body | 361–374 | Reads `$env:CLAUDE_TOOL_INPUT`, calls `Invoke-PrAuthorSkillDecision`, writes JSON, exits 0. |
| Parse & dispatch | `Invoke-PrAuthorSkillDecision` | 250–290 | Parses JSON, calls `Get-PrContextArtifactExistence`, then `Get-PrAuthorBypassReason`. |
| Case A (inline body) | `Get-PrAuthorBypassReason` | 214–217 | `--body` without `--body-file` on create or edit → `PR_AUTHOR_SKILL_BLOCKED`. |
| Case B (no body) | `Get-PrAuthorBypassReason` | 219–224 | `gh pr create` with no body flag → `PR_AUTHOR_SKILL_BLOCKED`. |
| Case B allow (edit, no body) | `Get-PrAuthorBypassReason` | 226–231 | `gh pr edit` with no body flag → `$null` (allow). |
| Case C (missing context) | `Get-PrAuthorBypassReason` | 233–236 | `--body-file` present, context absent → `PR_CONTEXT_MISSING`. |
| Cases D/E/F/malformed | `Get-PrAuthorBypassReason` → `Test-PrAuthorAuthorization` | 238–248, 101–170 | `--body-file` present and context present → calls `Test-PrAuthorAuthorization`. |
| Allow builder | `Get-PrAuthorSkillAllowDecision` | 292–309 | Returns `permissionDecision=allow`. |
| Deny builder | `Get-PrAuthorSkillBlockDecision` | 311–334 | Returns `permissionDecision=deny` with reason. |
| Bypass-required helper | `Test-PrAuthorBypassRequired` | 336–358 | Boolean wrapper over `Get-PrAuthorBypassReason`. |

### Adapter seams already present

| Seam function | Lines | Purpose |
|---|---|---|
| `Get-PrContextArtifactExistence` | 51–63 | `Test-Path` wrapper for `artifacts/pr_context.summary.txt`. |
| `Get-PrAuthorAuthorizationContent` | 65–85 | Reads raw text of `artifacts/pr_author_authorization.json`; returns `$null` if absent. |
| `Get-CurrentDateTimeUtc` | 87–99 | Returns `[DateTime]::UtcNow`. |

### Sentinel-only code that must be removed

The following functions and script-level variables implement the forgeable sentinel and must be removed entirely under the receipt model:

- `$script:PrAuthorAuthorizationPath` — line 48 (path constant for `artifacts/pr_author_authorization.json`)
- `$script:PrAuthorAuthorizationTtlSeconds` — line 49 (TTL constant 120)
- `Get-PrAuthorAuthorizationContent` — lines 65–85 (read seam for the sentinel file)
- `Test-PrAuthorAuthorization` — lines 101–170 (all sentinel validation logic: missing / malformed / invalid issuer / expired)
- The call to `Test-PrAuthorAuthorization` in `Get-PrAuthorBypassReason` — lines 240–245

The `.DESCRIPTION` block in `Get-PrAuthorBypassReason` (lines 177–200) must also be updated to remove the sentinel description and replace it with the receipt verification description.

### Where receipt verification must be inserted

Receipt verification replaces the sentinel block on the `--body-file-with-context` path. In `Get-PrAuthorBypassReason`, the current block:

```powershell
# Cases D/E/F and malformed ...
if ($hasBodyFile -and $ContextExists) {
    $authorizationReason = Test-PrAuthorAuthorization
    if ($authorizationReason) {
        return $authorizationReason
    }
}
```
(lines 238–245) must be replaced with a call to a new function `Test-PrAuthorReceiptVerification`, which implements the five ordered deny reasons (Section 2 below).

---

## 2. Receipt-Model Target Shape

The following five checks run in order on the `--body-file-with-context` path. Each emits a `permissionDecision=deny` via `Get-PrAuthorSkillBlockDecision`. The command-text-extraction regex for `<N>` is required for checks 1–5.

### Canonical path regex

```
--body-file\s+artifacts/pr_body_(\d+)\.md\b
```

The capture group `(\d+)` extracts `<N>`. A `--body-file` argument that does not match this pattern is non-canonical.

### Ordered deny reasons

| Order | Reason code | Condition | Required artifact read |
|---|---|---|---|
| 1 | `PR_BODY_PATH_NONCANONICAL` | `--body-file` path does not match `artifacts/pr_body_<N>.md` (case-sensitive regex above). | None — pattern match only. |
| 2 | `PR_AUTHOR_RECEIPT_MISSING` | `artifacts/pr_body_<N>.receipt.json` does not exist. | Seam: `Test-Path` for the receipt file. |
| 3 | `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` | `receipt.number` parsed from the receipt JSON is not equal to `<N>` (as integer). | Seam: read receipt bytes, parse JSON. |
| 4 | `PR_AUTHOR_RECEIPT_HASH_MISMATCH` | SHA-256 (lowercase hex) of the body file bytes does not equal `receipt.sha256`. | Seam: read body bytes, compute SHA-256. |
| 5 | `PR_AUTHOR_RECEIPT_STALE` | `receipt.created_at` (ISO-8601 UTC) is not strictly newer than the last-write time of `artifacts/pr_context.summary.txt`. | Seam: parse `receipt.created_at`, read last-write time of context file. |

If all five checks pass, the function returns `$null` (allow).

### Required new injectable adapter seams

All five seams below must be functions that tests mock without disk/network/temp-file access. The existing seams `Get-PrContextArtifactExistence` and `Get-CurrentDateTimeUtc` are retained for Cases A–C.

| Seam function (proposed) | Input | Output | Maps to |
|---|---|---|---|
| `Get-PrBodyFileBytes` | `[string] $BodyFilePath` | `[byte[]]` or `$null` | `[IO.File]::ReadAllBytes` |
| `Get-PrAuthorReceiptContent` | `[string] $ReceiptFilePath` | `[string]` or `$null` (raw JSON text, `$null` if absent) | `Test-Path` + `Get-Content -Raw` |
| `Get-PrContextSummaryLastWriteUtc` | (none; uses `$script:PrContextArtifactPath`) | `[DateTime]` (UTC) or `$null` | `(Get-Item -LiteralPath ...).LastWriteTimeUtc` |

SHA-256 computation does not require a new seam: it is a deterministic transform of the body bytes supplied by `Get-PrBodyFileBytes` and can be computed inline in the receipt verification function using `[System.Security.Cryptography.SHA256]::Create()`. Tests supply mock bytes; the hash is computed from those bytes in the production path, so no filesystem boundary is crossed in tests.

`Get-CurrentDateTimeUtc` is NOT needed for the receipt model: the staleness check compares `receipt.created_at` against the context file's last-write time — both are artifact metadata, not wall-clock time. No clock seam is needed for the receipt verification function.

**Repurposing existing seams:** `Get-PrContextArtifactExistence` is retained as-is for Case C. `Get-CurrentDateTimeUtc` is no longer called in the `--body-file-with-context` path and can be removed entirely, but removing it is optional (it has no runtime side-effect if unused). `Get-PrAuthorAuthorizationContent` is removed (sentinel only).

---

## 3. All Sentinel References Across the Repo

Files are classified below by category and whether they are historical docs (do not edit) or runtime files (must change).

### Runtime files — must change

| File | Role | References |
|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` | Runtime hook (source of truth) | `pr_author_authorization`, `issued_by`, `issued_at`, `ttl_seconds` throughout (lines 48, 49, 65–85, 101–170, 240–245) |
| `.claude/skills/orchestrate/SKILL.md` | Orchestrate skill | Lines 68–79: `## PR Creation Delegation` describes sentinel write/delete protocol; line 75 explicitly names `artifacts/pr_author_authorization.json` and `issued_by == pr-author`. |
| `.claude/agents/orchestrator.md` | Orchestrator agent | Line 78: `## PR Creation Delegation` states sentinel issued by the `pr-author` agent is the gate condition. |
| `.claude/agents/pr-author.md` | pr-author agent | Lines 40–56: `## Authorization Sentinel Write/Delete Protocol` — full four-step write/delete sequence. |

### Bundled mirror files — must change to byte-identical matches after runtime edits

| Mirror file | Mirrors | Contract test |
|---|---|---|
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | `.claude/hooks/enforce-pr-author-skill.ps1` | `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | `.claude/skills/orchestrate/SKILL.md` | same |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` | `.claude/agents/orchestrator.md` | same |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md` | `.claude/agents/pr-author.md` | same |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` | `.claude/hooks/enforce-pr-author-skill.ps1` (converted form) | `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` |

The `.codex` mirror is the Codex-native converted form (prepended with `# Converted hook` comment). The contract test enforces byte-identical parity between `.codex/hooks/enforce-pr-author-skill.ps1` in the bundle and the root `.codex/` tree. There is no root `.codex/` directory at the repo root (`extensions/drm-copilot/resources/codex-and-agents-customizations/` is the bundle), so SCOPED_ROOTS for the codex test is `(Path(".codex"), Path(".agents"))` against the bundle root. This means the `.codex` hook must be updated in the bundle only.

**Verification:** The `.codex` root at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (confirmed present at glob result) contains the full sentinel implementation, identical to the claude hook. It must be updated to match the post-change claude hook content (with the `# Converted hook` header retained).

### Copilot ecosystem — `.github/agents/pr-author.agent.md`

`.github/agents/pr-author.agent.md` (repo root, line 140–163) contains `## Authorization Sentinel Protocol (Documentation-Only in This Ecosystem)` with the four-step write/delete sequence and the sentinel field names. This file has a bundled mirror at `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md`. Both must be updated to describe the receipt protocol instead. The copilot ecosystem contract test (`test_push_down_copilot_customizations.py`) tests push-down publisher behavior using in-memory mocks, not byte-parity of `.github/agents/` files, so there is no automated byte-parity gate for `.github/agents/` files — the update is required for correctness but will not be caught by a failing contract test if skipped.

### README.md

`README.md` line 40 references "a short-lived authorization sentinel" as the PR-creation gate description. README.md has no bundled mirror (it is not inside `.claude/`, `.codex/`, or `.agents/` scoped roots). It must be updated to replace "short-lived authorization sentinel" with a description of the receipt model.

### Historical feature docs — do not edit

The following files reference the sentinel model but are historical records and must not be modified:

- `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/` — all files in this folder (research, spec, plan, policy-audit, code-review, feature-audit, evidence)
- `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/issue.md`, `spec.md`, `user-story.md` — these are the current feature docs; they describe the sentinel as the thing being replaced. Do not rewrite them to describe the receipt model as if it already exists.

---

## 4. pr-author Skill and Agent

### `.claude/skills/pr-author/SKILL.md`

Verified content: the skill describes only PR body output format (sections 1–11, style, issue-reference rules). It does **not** instruct writing `artifacts/pr_body_<N>.md`, computing a SHA-256, or writing a receipt file. It does not mention the sentinel.

**Required change:** Add an `## Output Artifact` section that instructs:
- Write the PR body text to `artifacts/pr_body_<N>.md` where `<N>` is a sequence number (1, 2, ... incrementing per session).
- After writing the body file, compute the SHA-256 (lowercase hex) of the body file bytes.
- Write a sibling `artifacts/pr_body_<N>.receipt.json` with the following shape:
  ```json
  {
    "skill": "pr-author",
    "pr_body_path": "artifacts/pr_body_<N>.md",
    "number": <N>,
    "sha256": "<lowercase-hex-sha256-of-body-bytes>",
    "context_summary_path": "artifacts/pr_context.summary.txt",
    "created_at": "<ISO-8601 UTC timestamp, strictly newer than pr_context.summary.txt last-write time>"
  }
  ```
- Pass `artifacts/pr_body_<N>.md` to `gh pr create` or `gh pr edit` via `--body-file`.

The skill currently allows tools `Read` and `Bash(git log *)`. Writing `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json` requires `Write(/artifacts/**)`. The skill's `allowed-tools` frontmatter must be updated accordingly, or the write step deferred to the pr-author agent (which already has `Write(/artifacts/**)` in its tool allowlist). Given the agent's tool allowlist already includes `Write(/artifacts/**)`, the cleanest split is: the skill produces the body text (as it does today), the agent writes `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json`, then issues `gh pr create --body-file`. The skill's SKILL.md should be updated to document the artifact output contract, while the write operations remain in agent scope.

### `.claude/agents/pr-author.md`

Current state: Lines 39–56 (`## Authorization Sentinel Write/Delete Protocol`) describe the four-step sentinel write/delete sequence with exact field names (`issued_by`, `issued_at`, `head_sha`, `ttl_seconds`). Lines 1–3 of the description field in the YAML frontmatter also mentions "Writes a short-lived authorization sentinel."

**Required changes:**
- Replace `## Authorization Sentinel Write/Delete Protocol` (lines 39–56) with `## PR Body and Receipt Write Protocol` describing: (a) write `artifacts/pr_body_<N>.md` with the body text; (b) compute SHA-256 of the body bytes; (c) write `artifacts/pr_body_<N>.receipt.json` with the six fields above; (d) issue `gh pr create --body-file artifacts/pr_body_<N>.md`; (e) no write/delete of `artifacts/pr_author_authorization.json`.
- Update the YAML frontmatter `description` field to remove "Writes a short-lived authorization sentinel" and substitute receipt protocol language.
- The `## Enforcement Strength (Honest Disclosure)` section must be updated: remove the sentinel forgeability disclosure (since the sentinel no longer exists) and replace with an honest disclosure that the SHA-256 receipt is a policy-level integrity check binding the body file bytes to the receipt, not a cryptographic security boundary (any actor with `Write(/artifacts/**)` can replace both the body file and the receipt together).
- The `## Final Output Requirement` section (lines 58–63) is unchanged — still requires PR URL or number in final output.

---

## 5. validate-pr-author-output.ps1 SubagentStop Hook

**File:** `.claude/hooks/validate-pr-author-output.ps1`  
**Line count:** 137 lines.

### Current behavior

The hook reads `CLAUDE_HOOK_INPUT` (agent transcript JSON), extracts `.output`, and checks whether the output text references a PR URL, a `PR #<n>` reference, or a `gh pr create`/`gh pr edit` confirmation with a PR number. It does not inspect `artifacts/pr_author_authorization.json` or any sentinel field. It has no dependency on the sentinel model.

**Conclusion:** This hook does not assume the sentinel. No sentinel-related changes are required. The hook is agnostic to whether the pr-author agent wrote a sentinel or a receipt.

### What must NOT change

This is a SubagentStop hook. Its entrypoint (lines 129–136) uses the `decision:block / exit 1` form (not `permissionDecision`). Per spec constraint, this form must be retained. The hook must not be converted to the `permissionDecision` PreToolUse shape.

### Mirror

The hook has a byte-identical mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1`. Since no changes are required, the mirror requires no update.

---

## 6. orchestrate SKILL.md PR Sections

**File:** `.claude/skills/orchestrate/SKILL.md` (300 lines)

### Current PR-related sections

**`## PR Creation Delegation` (lines 68–79):**

```
PR creation and PR body edits are delegated work, not orchestrator work. The orchestrator
MUST NOT call `gh pr create` or `gh pr edit --body*` directly from the main thread; the
`enforce-pr-author-skill.ps1` PreToolUse hook blocks those commands unless a valid
authorization sentinel issued by the `pr-author` agent is present.

The mandatory sequence is:

1. The orchestrator first produces the PR-context artifact via `mcp__drm-copilot__collect_pr_context`
   (or the equivalent context-collection mechanism), which writes `artifacts/pr_context.summary.txt`.
2. The orchestrator then delegates PR creation and any PR body edits to `Agent(pr-author)`. The
   `pr-author` agent runs the `pr-author` skill, writes the short-lived authorization sentinel
   `artifacts/pr_author_authorization.json` immediately before each `gh` command, issues
   `gh pr create`/`gh pr edit --body-file ...` within the TTL, deletes the sentinel afterward, and
   reports the resulting PR URL or PR number.

`Agent(pr-author)` is the mandatory delegate for PR creation and PR body edits. Direct
`gh pr create`/`gh pr edit --body*` from the main thread is prohibited and is blocked by the hook.

The authorization sentinel is a policy guardrail, not a cryptographic or security control; any
actor with `Write(/artifacts/**)` access can forge it. It prevents accidental bypass and requires
a deliberate, documented act to circumvent.
```

**`## PR Creation Gate` (lines 208–218):** Currently five conditions:

1. `blocking_findings_resolved: true`
2. AC verification artifact confirms all acceptance criteria pass.
3. Mandatory toolchain passed in its most recent run.
4. Checkpoint `next_step` is `S8_create_pr`.
5. `ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`.

The section states: "This gate is non-negotiable. Each condition is independently verified before PR creation proceeds. Conditions 1-4 are unchanged from the prior contract; condition 5 is additive."

There is no `## PR Authoring (pr-author Handoff)` section.

### Required changes

**(a) Remove/rewrite `## PR Creation Delegation`:**

The entire section must be replaced with `## PR Authoring (pr-author Handoff)` describing the receipt-based handoff sequence:
1. Orchestrator calls `mcp__drm-copilot__collect_pr_context`, producing `artifacts/pr_context.summary.txt`.
2. Orchestrator delegates to `Agent(pr-author)`.
3. The pr-author agent runs the `pr-author` skill to produce body text, writes `artifacts/pr_body_<N>.md` and sibling `artifacts/pr_body_<N>.receipt.json` (with `sha256`, `number`, `context_summary_path`, `created_at`).
4. The pr-author agent calls `gh pr create --body-file artifacts/pr_body_<N>.md` (or `gh pr edit`).
5. The PreToolUse hook verifies the receipt (canonical path, receipt present, number match, hash match, staleness check) and allows only when all five pass.

The old sentinel description, sentinel field names, and the write/delete protocol description must be removed.

**(b) Add condition 5 = receipt condition to `## PR Creation Gate`:**

The gate must list SIX conditions. The current five conditions numbered 1–5 must be renumbered so the receipt condition becomes condition 5 and the CI-green condition becomes condition 6:

1. `blocking_findings_resolved: true`
2. AC verification artifact confirms all acceptance criteria pass.
3. Mandatory toolchain passed in its most recent run.
4. Checkpoint `next_step` is `S8_create_pr`.
5. PR body produced via the pr-author handoff: `artifacts/pr_body_<N>.md` exists with a matching `artifacts/pr_body_<N>.receipt.json`, and was submitted via `--body-file`.
6. `ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`. DONE is not written while either sub-condition is false.

**(c) The new `## PR Authoring (pr-author Handoff)` section** replaces `## PR Creation Delegation` and contains: the delegation sequence, the receipt shape, the hook verification order, and the honest disclosure that the receipt is a policy-level integrity check (not a cryptographic security boundary).

---

## 7. orchestrator.md Agent — Part A Reference + Part B Governance

**File:** `.claude/agents/orchestrator.md`  
**Line count:** 103 lines.

### Part A: Current PR section

**`## PR Creation Delegation` (lines 76–79, within the 103-line file):**

Line 78 (verbatim): "PR creation and PR body edits must be delegated to `Agent(pr-author)`. The orchestrator must not call `gh pr create` or `gh pr edit --body*` directly from the main thread; those commands are blocked by the `enforce-pr-author-skill.ps1` PreToolUse hook unless a valid authorization sentinel issued by the `pr-author` agent is present. The orchestrator first produces the PR-context artifact via `mcp__drm-copilot__collect_pr_context`, then delegates to `Agent(pr-author)`, which authors the PR body via the `pr-author` skill, writes and deletes the authorization sentinel around the `gh` command, and reports the resulting PR URL or PR number."

This paragraph must be rewritten to: (a) describe receipt-based authorization instead of sentinel; (b) point to `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` as authoritative; (c) remove all sentinel language (`pr_author_authorization.json`, `issued_by`, write/delete protocol).

### Part B: Governance sections — MISSING

The following sections are **absent** from the current `.claude/agents/orchestrator.md` (103 lines):

| Required section | Status |
|---|---|
| `### Remediation Loop Checkpoint Shape` | MISSING |
| `### CI Monitoring and Post-PR Remediation` (with invariant "The orchestrator must not commit workflow-file changes outside the remediation loop.") | MISSING |
| `## Remediation Loop Protocol` with subsections: Prohibited Delegations, Required Artifacts Per Cycle, Preflight Sub-State Semantics, Scope-change Rule, Exit Gate, Citations | MISSING |

The verbatim invariant string "must not commit workflow-file changes outside the remediation loop" does not appear anywhere in any runtime file. It appears only in the feature docs for issue #261 (`issue.md`, `spec.md`, `user-story.md`). These sections currently reside only in `.claude/skills/orchestrate/SKILL.md` (the on-demand skill), which may not be loaded in all contexts.

The orchestrator agent file must be extended to include all three sections so that remediation and CI governance are part of the always-loaded agent contract. The orchestrate SKILL.md sections can remain in the skill as the authoritative detailed reference; the agent must carry at minimum the checkpoint-shape invariants, the CI-monitoring section with the verbatim invariant, and the full Remediation Loop Protocol. Content duplication between agent and skill is acceptable for governance-critical invariants.

**Line count impact:** The three missing sections from the orchestrate SKILL.md are substantial. The `## Remediation Loop (R1–R5)` section in the skill is approximately 30 lines; `## CI Monitoring` is approximately 8 lines; `## Remediation Loop — CI-Failure Handling` is approximately 15 lines. Adding these to orchestrator.md (currently 103 lines) will bring it to approximately 156–165 lines, well within the 500-line cap.

The `.claude/agents/orchestrator.md` is a Markdown file. The 500-line cap exemption for Markdown documentation files in `.claude/rules/general-code-change.md` does not apply here because agent definition files are runtime artifacts, not documentation. However, the projected size remains comfortably under 500 lines regardless.

---

## 8. Bundle-Parity and Mirrors

### Mirror roots

| Runtime source | Mirror root | Enforcement |
|---|---|---|
| `.claude/**` (excluding `agent-memory/**` and `settings.local.json`) | `extensions/drm-copilot/resources/claude-customizations/.claude/**` | `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` — byte-identical |
| `.codex/**` and `.agents/**` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/**` and `.agents/**` | `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` — byte-identical |
| `.github/agents/**` | `extensions/drm-copilot/resources/customizations/.github/agents/**` | No byte-parity contract test enforces this; the copilot push-down test uses an in-memory filesystem mock and does not compare bundle-vs-repo file bytes for `.github/` content. |

### Byte-identical vs. content-equivalent

The claude and codex/agents contract tests enforce **byte-identical** content. Every character in the runtime source must match the mirror exactly (UTF-8 byte comparison). There is no content-equivalence relaxation.

Exception: the `.codex` mirror of `enforce-pr-author-skill.ps1` has a prepended `# Converted hook\n# Review the generated hook behavior before enabling it.\n\n` header not present in the canonical `.claude` source. This is a pre-existing difference. The test at `test_push_down_codex_and_agents_resource_contracts.py` compares the `.codex` hook in the bundle against the `.codex` hook in the codex-and-agents-customizations root (both in the same bundle root). Since there is no `.codex/` directory at the repo root, the codex contract test compares the bundle to itself (effectively: verifies the file is present). The actual conversion is managed separately. The codex mirror must be updated separately from the claude mirror.

### README.md

`README.md` has no bundled mirror. It is not under `.claude/`, `.codex/`, or `.agents/`, so no contract test covers it. It must be manually updated.

---

## 9. Tests

### `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`

**Current line count:** 474 lines.

**Sentinel-based test contexts that must change or be removed:**

| Context (line range) | Purpose | Action required |
|---|---|---|
| `'authorized commands'` context (lines 120–185): `BeforeEach` mocks `Get-PrAuthorAuthorizationContent` and `Get-CurrentDateTimeUtc` to provide a valid in-TTL sentinel. | The allow path for `--body-file-with-context` currently requires a valid sentinel. | `BeforeEach` must instead mock receipt seams (`Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, `Get-PrContextSummaryLastWriteUtc`) to provide a matching in-date receipt. |
| `'authorization sentinel - missing (Case D)'` (lines 187–208) | Tests `PR_AGENT_AUTHORIZATION_MISSING` reason. | Remove entire context; replace with `'receipt - missing (Case D: PR_AUTHOR_RECEIPT_MISSING)'`. |
| `'authorization sentinel - invalid issuer (Case E)'` (lines 210–225) | Tests `PR_AGENT_AUTHORIZATION_INVALID` reason. | Remove entire context; there is no analogous issuer check in the receipt model. |
| `'authorization sentinel - expired (Case F)'` (lines 227–243) | Tests `PR_AGENT_AUTHORIZATION_EXPIRED` reason. | Remove entire context; replace with `'receipt - stale (Case: PR_AUTHOR_RECEIPT_STALE)'`. |
| `'authorization sentinel - malformed'` (lines 245–268) | Tests `PR_AGENT_AUTHORIZATION_MALFORMED` reason (not valid JSON, missing `issued_at`). | Remove entire context; replace with number-mismatch and hash-mismatch receipt tests. |
| `'authorization sentinel - valid authorization (allow)'` (lines 270–294) | Tests the allow path with a valid sentinel. | Remove; replace with `'receipt - all checks pass (allow)'`. |
| `'Get-PrAuthorBypassReason helper'` context (lines 296–320): `BeforeEach` mocks sentinel seams. | Tests `Get-PrAuthorBypassReason` helper directly. | Update `BeforeEach` to mock receipt seams instead. |
| `'Test-PrAuthorBypassRequired helper'` context (lines 339–363): `BeforeEach` mocks sentinel seams. | Tests the boolean bypass wrapper. | Update `BeforeEach` to mock receipt seams. |
| `'Get-PrAuthorAuthorizationContent real read seam'` context (lines 372–395) | Tests the real sentinel read seam. | Remove; the seam is deleted. |
| `'Test-PrAuthorAuthorization unparseable issued_at'` context (lines 405–414) | Tests malformed sentinel. | Remove; the function is deleted. |
| `'Get-CurrentDateTimeUtc real clock seam'` context (lines 397–403) | Tests the real clock seam. | Retain only if `Get-CurrentDateTimeUtc` is retained in the new hook (optional; it is unused in the receipt path). |

**New test cases required (five receipt failure reasons):**

Each uses injectable seams; no disk/network/temp files. All require `Get-PrContextArtifactExistence` mocked to `$true`.

| New context | It block | Mock setup |
|---|---|---|
| `'receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)'` | `--body-file artifacts/pr_body.md` (no number) → `PR_BODY_PATH_NONCANONICAL` | No receipt seam mock needed (pattern fails before receipt is read). |
| `'receipt - missing (PR_AUTHOR_RECEIPT_MISSING)'` | Canonical path but receipt absent → `PR_AUTHOR_RECEIPT_MISSING` | `Mock Get-PrAuthorReceiptContent { $null }` |
| `'receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)'` | Canonical `artifacts/pr_body_5.md` but `receipt.number == 7` → `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` | `Mock Get-PrAuthorReceiptContent { '{"number":7,"sha256":"abc","created_at":"..."}' }` |
| `'receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)'` | Canonical path, number correct, but SHA-256 of body bytes does not match `receipt.sha256` → `PR_AUTHOR_RECEIPT_HASH_MISMATCH` | `Mock Get-PrBodyFileBytes { [byte[]]@(0x41) }` (body = `A`, SHA-256 of 0x41 ≠ mock receipt sha256) |
| `'receipt - stale (PR_AUTHOR_RECEIPT_STALE)'` | `receipt.created_at` is older than or equal to context file last-write → `PR_AUTHOR_RECEIPT_STALE` | `Mock Get-PrAuthorReceiptContent { '{"number":5,"sha256":"<correct>","created_at":"2026-06-27T10:00:00Z"}' }`; `Mock Get-PrContextSummaryLastWriteUtc { [DateTime]::Parse('2026-06-27T11:00:00Z') }` |
| `'receipt - all checks pass (allow)'` | All five checks pass → `allow` | Mock all seams to return matching values. |

### `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`

**Current line count:** 137 lines.

The `enforce-pr-author-skill.ps1` contract test block (lines 59–62) dot-sources the hook and calls `Get-PrAuthorSkillBlockDecision -Reason 'PR author skill required'`. It does not call any sentinel-specific function. `Get-PrAuthorSkillBlockDecision` is retained unchanged in the receipt model (it is the generic deny builder). This test **is not affected** by the receipt change and requires no modification.

### `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1`

**Current line count:** 128 lines.

This hook has no sentinel dependency (verified in Section 5). The tests do not mock any sentinel seams. No changes are required to this file.

---

## 10. Recommended Execution Phasing

The PowerShell per-batch cap is 3 production files and 3 test files. Markdown files are not subject to the PS batch cap. The 500-line cap does not apply to Markdown documentation files, but does apply to PowerShell scripts and all production runtime files that are not Markdown.

### Batch 1 — PowerShell hook (3 production, 3 test)

| File | Role | Change |
|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` | Production PS (1 of 3) | Remove sentinel functions/constants; insert receipt verification function and three new adapter seams; update comments. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | Production PS mirror (2 of 3) | Byte-identical copy of source after change. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` | Production PS mirror (3 of 3) | Updated content with `# Converted hook` header retained. |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | Test PS (1 of 3) | Remove sentinel contexts; add five receipt failure reason contexts; update allow-path `BeforeEach` mocks. |
| _(no additional test files in this batch)_ | — | — |

Run PoshQC format → analyze → test after Batch 1 passes before proceeding.

### Batch 2 — pr-author agent and skill (2 production MD + 1 production PS mirror)

Markdown files are not subject to the PS batch cap. This batch is primarily Markdown edits plus the PS mirror for `validate-pr-author-output.ps1` (which requires no change — included here only if the Markdown edits require it; otherwise omit).

| File | Role | Change |
|---|---|---|
| `.claude/agents/pr-author.md` | Agent MD | Replace `## Authorization Sentinel Write/Delete Protocol`; update frontmatter description; update enforcement disclosure. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md` | MD mirror | Byte-identical copy. |
| `.claude/skills/pr-author/SKILL.md` | Skill MD | Add `## Output Artifact` section with receipt shape and write instruction. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-author/SKILL.md` | MD mirror | Byte-identical copy. |
| `.github/agents/pr-author.agent.md` | Copilot agent MD | Replace `## Authorization Sentinel Protocol` with receipt protocol description. |
| `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md` | Copilot MD mirror | Byte-identical copy. |

### Batch 3 — orchestrate skill and orchestrator agent (Markdown only)

All Markdown; no PS batch cap applies.

| File | Role | Change |
|---|---|---|
| `.claude/skills/orchestrate/SKILL.md` | Orchestrate skill MD | Replace `## PR Creation Delegation` with `## PR Authoring (pr-author Handoff)`; update `## PR Creation Gate` from five to six conditions (receipt = condition 5, CI = condition 6). |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | MD mirror | Byte-identical copy. |
| `.claude/agents/orchestrator.md` | Orchestrator agent MD | Update PR section to remove sentinel language; add three Part B governance sections (`### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation` with verbatim invariant, `## Remediation Loop Protocol` with all subsections). |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` | MD mirror | Byte-identical copy. |
| `README.md` | README MD | Update line 40 to replace "short-lived authorization sentinel" with receipt-model description. |

### Note on `.github/agents/pr-author.agent.md`

This file does not have a byte-parity contract test enforcement. It can be batched with Batch 2 (Markdown only) without risk to any contract test failure path.

---

## Automation Feasibility

All changes in this feature are fully automatable with no human-interaction requirements.

- All file modifications are code or Markdown changes in the repository filesystem, accessible to the agentic runtime.
- PowerShell toolchain (PoshQC format → PSScriptAnalyzer → Pester) runs via the `mcp__drm-copilot__run_poshqc_*` MCP tools without manual intervention.
- Bundle parity contract tests run via `poetry run pytest`. No external service, portal, or manual step is required.
- No GitHub Actions workflow changes are required by this feature. (The feature hardening is to the hook PowerShell and Markdown agent/skill definitions only.)
- The `.codex` hook mirror update is a file-write operation within the repository.
- No authentication, third-party UI, or human approval gate blocks any step.

**Determination:** `scope_change` and `exception` responses are not required. No `human_interaction.requirements[]` entry is needed. The orchestrator may proceed autonomously through all batches.
