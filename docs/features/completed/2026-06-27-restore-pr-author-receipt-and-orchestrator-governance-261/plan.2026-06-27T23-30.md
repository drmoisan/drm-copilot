# 2026-06-27-restore-pr-author-receipt-and-orchestrator-governance — Plan (Authoritative)

- **Issue:** #261
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-27T23-30
- **Status:** Approved-pending-preflight
- **Version:** 1.0
- **Work Mode:** full-feature

## Authoritative Plan Notice

This file (`plan.2026-06-27T23-30.md`) is the AUTHORITATIVE implementation plan for issue #261. It supersedes the template placeholder `plan.2026-06-27T22-38.md`, which contained only unfilled `<Phase Name>` / `<Atomic task>` placeholders and is no longer authoritative. Executors and auditors MUST use this file.

## Requirements Sources

- `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/issue.md` (Acceptance Criteria)
- `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/user-story.md` (Acceptance Criteria — AC1–AC6)
- `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/spec.md` (Definition of Done, field contracts, ordered deny reasons)
- `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/research/pr-author-receipt-and-governance-inventory.2026-06-27.md` (file-by-file inventory, line numbers, seams, mirror map — ground truth)

All work must comply with the repository policy files (read in Phase 0). Policy content is not duplicated here.

## Evidence Location Invariant

All evidence artifacts MUST be written under `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation. The feature evidence root is abbreviated `<FEATURE>/evidence/` below.

---

### Phase 0 — Baseline Capture and Policy Reading

- [x] [P0-T1] Read the repository policy files in required order and record the read evidence: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, plus the mirrored rules `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and an explicit list of every file read.
- [x] [P0-T2] Capture the baseline PowerShell formatting state by running `mcp__drm-copilot__run_poshqc_format` (check/report mode) over the in-scope PowerShell files.
  - Acceptance: `<FEATURE>/evidence/baseline/baseline-poshqc-format.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T3] Capture the baseline PowerShell lint state by running `mcp__drm-copilot__run_poshqc_analyze`.
  - Acceptance: `<FEATURE>/evidence/baseline/baseline-poshqc-analyze.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (PSScriptAnalyzer finding count).
- [x] [P0-T4] Capture the baseline Pester state and coverage by running `mcp__drm-copilot__run_poshqc_test` for the claude-hooks test scope (`tests/scripts/claude-hooks/`).
  - Acceptance: `<FEATURE>/evidence/baseline/baseline-pester.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric pass/fail counts and numeric line-coverage and branch-coverage headline values for the hook files in scope.
- [x] [P0-T5] Capture the baseline bundle-parity state by running `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.
  - Acceptance: `<FEATURE>/evidence/baseline/baseline-bundle-parity.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (passed/failed counts).
- [x] [P0-T6] Capture the baseline line counts of every PowerShell file in scope (`.claude/hooks/enforce-pr-author-skill.ps1`, both mirror hooks, `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`).
  - Acceptance: `<FEATURE>/evidence/baseline/baseline-line-counts.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and per-file line counts; confirms each file's starting line count and headroom under the 500-line cap.

---

### Phase 1 — Receipt Hook: Runtime, Mirrors, and Tests (Batch 1)

PowerShell batch: 3 production `.ps1` (runtime + claude mirror + codex mirror) + 1 test `.ps1`. Within the per-batch cap (<= 3 production, <= 3 test).

#### Production hook edit — sentinel removal

- [x] [P1-T1] Remove the sentinel script-level constants `$script:PrAuthorAuthorizationPath` (line ~48) and `$script:PrAuthorAuthorizationTtlSeconds` (line ~49) from `.claude/hooks/enforce-pr-author-skill.ps1`.
  - Acceptance: neither identifier appears in the file; `Get-PrContextArtifactExistence` and `$script:PrContextArtifactPath` are retained.
- [x] [P1-T2] Remove the sentinel read seam `Get-PrAuthorAuthorizationContent` (lines ~65–85) from `.claude/hooks/enforce-pr-author-skill.ps1`.
  - Acceptance: function `Get-PrAuthorAuthorizationContent` is absent from the file.
- [x] [P1-T3] Remove the sentinel validation function `Test-PrAuthorAuthorization` (lines ~101–170) from `.claude/hooks/enforce-pr-author-skill.ps1`.
  - Acceptance: function `Test-PrAuthorAuthorization` is absent from the file.
- [x] [P1-T4] Remove the call to `Test-PrAuthorAuthorization` in `Get-PrAuthorBypassReason` (the `if ($hasBodyFile -and $ContextExists)` sentinel block, lines ~238–245) from `.claude/hooks/enforce-pr-author-skill.ps1`.
  - Acceptance: no remaining call site references `Test-PrAuthorAuthorization`.

#### Production hook edit — receipt seams and verification

- [x] [P1-T5] Add the injectable adapter seam `Get-PrBodyFileBytes` to `.claude/hooks/enforce-pr-author-skill.ps1`: signature `[string] $BodyFilePath` -> `[byte[]]` or `$null`, mapping to `[IO.File]::ReadAllBytes` with a `Test-Path` guard.
  - Acceptance: function `Get-PrBodyFileBytes` is defined with `CmdletBinding()`, `[OutputType([byte[]])]`, and a mandatory `[string] $BodyFilePath` parameter.
- [x] [P1-T6] Add the injectable adapter seam `Get-PrAuthorReceiptContent` to `.claude/hooks/enforce-pr-author-skill.ps1`: signature `[string] $ReceiptFilePath` -> raw JSON `[string]` or `$null` (`Test-Path` + `Get-Content -Raw`).
  - Acceptance: function `Get-PrAuthorReceiptContent` is defined and returns `$null` when the receipt file is absent.
- [x] [P1-T7] Add the injectable adapter seam `Get-PrContextSummaryLastWriteUtc` to `.claude/hooks/enforce-pr-author-skill.ps1`: no input; returns `[DateTime]` (UTC) from `(Get-Item -LiteralPath $script:PrContextArtifactPath).LastWriteTimeUtc`, or `$null` if absent.
  - Acceptance: function `Get-PrContextSummaryLastWriteUtc` is defined with `[OutputType([DateTime])]`.
- [x] [P1-T8] Add the receipt-verification function `Test-PrAuthorReceiptVerification` to `.claude/hooks/enforce-pr-author-skill.ps1` implementing the five ordered deny reasons, each as its own branch that short-circuits: (1) `PR_BODY_PATH_NONCANONICAL` when the `--body-file` argument does not match the case-sensitive regex `--body-file\s+artifacts/pr_body_(\d+)\.md\b`; (2) `PR_AUTHOR_RECEIPT_MISSING` when `Get-PrAuthorReceiptContent` for `artifacts/pr_body_<N>.receipt.json` returns `$null`; (3) `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` when the parsed `receipt.number` (integer) != `<N>`; (4) `PR_AUTHOR_RECEIPT_HASH_MISMATCH` when the inline SHA-256 (lowercase hex, via `[System.Security.Cryptography.SHA256]::Create()`) of `Get-PrBodyFileBytes` bytes != `receipt.sha256`; (5) `PR_AUTHOR_RECEIPT_STALE` when `receipt.created_at` parsed as UTC is not strictly newer than `Get-PrContextSummaryLastWriteUtc`. Return `$null` when all five pass.
  - Acceptance: `Test-PrAuthorReceiptVerification` returns each of the five reason strings on its corresponding failure and `$null` on full pass; SHA-256 is computed inline (no new hash seam); no disk or network access occurs except through the three seams.
- [x] [P1-T9] Replace the removed sentinel block in `Get-PrAuthorBypassReason` (the `--body-file` with context-present path) with a call to `Test-PrAuthorReceiptVerification`, passing the extracted command text / `--body-file` path, in `.claude/hooks/enforce-pr-author-skill.ps1`.
  - Acceptance: the `--body-file-with-context` path returns the result of `Test-PrAuthorReceiptVerification`; Case A (inline `--body` -> `PR_AUTHOR_SKILL_BLOCKED`), Case B (no body flag on create -> `PR_AUTHOR_SKILL_BLOCKED`; edit with no body -> allow), and Case C (`--body-file` with no context -> `PR_CONTEXT_MISSING`) shape blocks are retained unchanged.
- [x] [P1-T10] Update the `.DESCRIPTION` block of `Get-PrAuthorBypassReason` (lines ~177–200) and the file header comment in `.claude/hooks/enforce-pr-author-skill.ps1` to describe receipt verification and remove all sentinel description text.
  - Acceptance: no `.DESCRIPTION` or header text references `pr_author_authorization`, `issued_by`, `issued_at`, or `ttl_seconds`; the description states the receipt is a policy-level integrity check, not a security boundary.
- [x] [P1-T11] Confirm `.claude/hooks/enforce-pr-author-skill.ps1` retains the `permissionDecision='deny'` shape (`Get-PrAuthorSkillBlockDecision`), the allow builder (`Get-PrAuthorSkillAllowDecision`), and remains <= 500 lines.
  - Acceptance: deny/allow builder functions are unchanged; `(Get-Content .claude/hooks/enforce-pr-author-skill.ps1).Count <= 500`.

#### Mirror propagation (same batch)

- [x] [P1-T12] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` with byte-identical content of the post-edit `.claude/hooks/enforce-pr-author-skill.ps1`.
  - Acceptance: a byte comparison of the two files reports identical content (no diff).
- [x] [P1-T13] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` to the post-edit hook content, retaining its prepended `# Converted hook` header lines and keeping the body byte-identical to the runtime hook below the header.
  - Acceptance: the file's body below the `# Converted hook` header matches the runtime hook byte-for-byte; the converted-hook header is preserved.

#### Test edits (same batch)

- [x] [P1-T14] Remove the sentinel test contexts from `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`: `'authorization sentinel - missing (Case D)'`, `'authorization sentinel - invalid issuer (Case E)'`, `'authorization sentinel - expired (Case F)'`, `'authorization sentinel - malformed'`, `'authorization sentinel - valid authorization (allow)'`, `'Get-PrAuthorAuthorizationContent real read seam'`, and `'Test-PrAuthorAuthorization unparseable issued_at'`.
  - Acceptance: none of the listed context names appear in the file; no test references `Get-PrAuthorAuthorizationContent` or `Test-PrAuthorAuthorization`.
- [x] [P1-T15] Add the context `'receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)'` to `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` with an `It` asserting a `--body-file artifacts/pr_body.md` (no number) command yields deny reason `PR_BODY_PATH_NONCANONICAL`, using injectable seams only (no disk/network/temp files), with `Get-PrContextArtifactExistence` mocked to `$true`.
  - Acceptance: the context exists and the `It` passes; no temp file is created.
- [x] [P1-T16] Add the context `'receipt - missing (PR_AUTHOR_RECEIPT_MISSING)'` to the test file with `Mock Get-PrAuthorReceiptContent { $null }` asserting reason `PR_AUTHOR_RECEIPT_MISSING` on a canonical path.
  - Acceptance: the context exists and the `It` passes via seam mocks only.
- [x] [P1-T17] Add the context `'receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)'` to the test file with a canonical `artifacts/pr_body_5.md` path and `Mock Get-PrAuthorReceiptContent` returning a receipt whose `number` is 7, asserting reason `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH`.
  - Acceptance: the context exists and the `It` passes via seam mocks only.
- [x] [P1-T18] Add the context `'receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)'` to the test file with `Mock Get-PrBodyFileBytes { [byte[]]@(0x41) }` and a receipt whose `sha256` does not equal the SHA-256 of `0x41`, asserting reason `PR_AUTHOR_RECEIPT_HASH_MISMATCH` (number matched first).
  - Acceptance: the context exists and the `It` passes via seam mocks only.
- [x] [P1-T19] Add the context `'receipt - stale (PR_AUTHOR_RECEIPT_STALE)'` to the test file with `Mock Get-PrAuthorReceiptContent` returning a correct number and sha256 but `created_at` not strictly newer, and `Mock Get-PrContextSummaryLastWriteUtc` returning a later timestamp, asserting reason `PR_AUTHOR_RECEIPT_STALE`.
  - Acceptance: the context exists and the `It` passes via seam mocks only.
- [x] [P1-T20] Add the context `'receipt - all checks pass (allow)'` to the test file mocking all three receipt seams to matching values (canonical path, present receipt, matching number, matching inline-computed sha256, strictly-newer `created_at`), asserting the decision is `allow`.
  - Acceptance: the context exists and the `It` asserts `permissionDecision == 'allow'` via seam mocks only.
- [x] [P1-T21] Update the allow-path `BeforeEach` of the retained `'authorized commands'` context and the `'Get-PrAuthorBypassReason helper'` and `'Test-PrAuthorBypassRequired helper'` contexts in the test file to mock the receipt seams (`Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, `Get-PrContextSummaryLastWriteUtc`) instead of the removed sentinel seams.
  - Acceptance: these contexts no longer mock `Get-PrAuthorAuthorizationContent` or `Get-CurrentDateTimeUtc` for the receipt path; they pass against the receipt model.
- [x] [P1-T22] Confirm the retained shape-block contexts (inline `--body`, no body flag on create, `gh pr edit` no body allow, `--body-file` without context -> `PR_CONTEXT_MISSING`) remain present and passing in the test file.
  - Acceptance: a Pester run shows these contexts present and green.
- [x] [P1-T23] Confirm `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` remains <= 500 lines; if it would exceed 500, extract receipt-seam test helpers into a sibling helper `.ps1` (each file <= 500 lines) and reference it.
  - Acceptance: every test file touched in this batch is <= 500 lines.

#### Phase 1 toolchain loop and parity gate

- [x] [P1-T24] Run `mcp__drm-copilot__run_poshqc_format` over the in-scope PowerShell files; if it changes any file, re-apply and re-run until clean.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase1-poshqc-format.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` showing a clean format pass.
- [x] [P1-T25] Run `mcp__drm-copilot__run_poshqc_analyze`; restart from format if it changes files; resolve all findings.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase1-poshqc-analyze.md` exists with `EXIT_CODE: 0` and `Output Summary:` showing zero PSScriptAnalyzer findings.
- [x] [P1-T26] Run `mcp__drm-copilot__run_poshqc_test` for `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (and `PreToolUseSchema.Contract.Tests.ps1` and `validate-pr-author-output.Tests.ps1` for regression) in coverage mode.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase1-pester.md` exists with `EXIT_CODE: 0`, all five receipt contexts plus shape-block contexts green, and `Output Summary:` recording numeric line coverage >= 85% and branch coverage >= 75% for the hook.
- [x] [P1-T27] Verify `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` still passes unchanged (it calls `Get-PrAuthorSkillBlockDecision` directly; the research states it is unaffected — verify, expect no change).
  - Acceptance: the contract test is green and was not modified.
- [x] [P1-T28] Run the bundle-parity tests `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` to catch hook/mirror drift.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase1-bundle-parity.md` exists with `EXIT_CODE: 0` and `Output Summary:` confirming byte-identical parity for the three hook files.

---

### Phase 2 — pr-author Agent and Skill Markdown Contracts (Batch 2)

Markdown only (exempt from the 500-line cap and PS batch cap). Each runtime Markdown edit is paired with its byte-identical claude mirror in this phase.

- [x] [P2-T1] Replace the `## Authorization Sentinel Write/Delete Protocol` section in `.claude/agents/pr-author.md` (lines ~39–56) with `## PR Body and Receipt Write Protocol` describing: write `artifacts/pr_body_<N>.md`; compute SHA-256 (lowercase hex) of the body bytes; write sibling `artifacts/pr_body_<N>.receipt.json` with fields `skill`, `pr_body_path`, `number`, `sha256`, `context_summary_path`, `created_at` (ISO-8601 UTC, strictly newer than `pr_context.summary.txt` last-write); issue `gh pr create --body-file artifacts/pr_body_<N>.md`; no write/delete of `artifacts/pr_author_authorization.json`.
  - Acceptance: the new heading is present; no sentinel field names remain in the section.
- [x] [P2-T2] Update the YAML frontmatter `description` field of `.claude/agents/pr-author.md` to remove "Writes a short-lived authorization sentinel" and substitute receipt-protocol language.
  - Acceptance: the frontmatter `description` no longer contains "sentinel" and references the receipt model.
- [x] [P2-T3] Update the `## Enforcement Strength (Honest Disclosure)` section in `.claude/agents/pr-author.md` to remove the sentinel-forgeability disclosure and state the SHA-256 receipt is a policy-level integrity check binding the body bytes to the receipt (not a cryptographic security boundary; any actor with `Write(/artifacts/**)` can replace both files together). Leave `## Final Output Requirement` unchanged.
  - Acceptance: the disclosure describes the receipt integrity check; `## Final Output Requirement` content is unchanged.
- [x] [P2-T4] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md` with byte-identical content of the post-edit `.claude/agents/pr-author.md`.
  - Acceptance: byte comparison reports identical content.
- [x] [P2-T5] Add an `## Output Artifact` section to `.claude/skills/pr-author/SKILL.md` documenting: write the body text to `artifacts/pr_body_<N>.md`; compute SHA-256 (lowercase hex) of the body bytes; write sibling `artifacts/pr_body_<N>.receipt.json` with the shape `{skill: "pr-author", pr_body_path, number, sha256, context_summary_path, created_at}`; pass the body file via `--body-file`. Note that write operations remain in pr-author agent scope (which holds `Write(/artifacts/**)`).
  - Acceptance: the `## Output Artifact` section is present and documents the body + receipt contract and the `--body-file` handoff.
- [x] [P2-T6] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-author/SKILL.md` with byte-identical content of the post-edit `.claude/skills/pr-author/SKILL.md`.
  - Acceptance: byte comparison reports identical content.
- [x] [P2-T7] Replace the `## Authorization Sentinel Protocol (Documentation-Only in This Ecosystem)` section in `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md` (lines ~140–163) with a receipt-protocol description consistent with the `.claude` pr-author agent (body file + SHA-256 receipt + `--body-file` handoff; no sentinel write/delete).
  - Acceptance: the section no longer references the sentinel; it describes the receipt model.
- [x] [P2-T8] Confirm `.github/agents/pr-author.agent.md` (runtime copilot agent) contains no sentinel references (it currently has none) and add a receipt-model `## PR Body and Receipt Protocol` section consistent with the bundled mirror so both copilot agents describe the same receipt model (no byte-parity test enforces this mirror).
  - Acceptance: the runtime copilot agent describes the receipt model and matches the bundled copilot agent's receipt section.

#### Phase 2 parity gate

- [x] [P2-T9] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` to confirm no `.claude` mirror drift after the Markdown edits.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase2-bundle-parity.md` exists with `EXIT_CODE: 0` and `Output Summary:` confirming byte-identical parity for `.claude/agents/pr-author.md` and `.claude/skills/pr-author/SKILL.md`.

---

### Phase 3 — Orchestrate Skill, Orchestrator Agent Governance, and README (Batch 3)

Markdown only. Each runtime Markdown edit is paired with its byte-identical claude mirror in this phase.

#### orchestrate SKILL.md

- [x] [P3-T1] Replace the `## PR Creation Delegation` section in `.claude/skills/orchestrate/SKILL.md` (lines ~68–79) with `## PR Authoring (pr-author Handoff)` describing: orchestrator refreshes context via `mcp__drm-copilot__collect_pr_context` (writes `artifacts/pr_context.summary.txt`); delegates to `Agent(pr-author)`, which runs the `pr-author` skill, writes `artifacts/pr_body_<N>.md` and sibling `artifacts/pr_body_<N>.receipt.json` (shape `{skill, pr_body_path, number, sha256 lowercase hex of body bytes, context_summary_path, created_at ISO-8601 UTC newer than pr_context.summary.txt}`); creates the PR with `gh pr create --body-file`; records `pr_author_receipt` in the checkpoint; the PreToolUse hook verifies the receipt in the five ordered checks. Include the honest disclosure that the receipt is a policy-level integrity check, not a security boundary.
  - Acceptance: the `## PR Authoring (pr-author Handoff)` heading replaces `## PR Creation Delegation`; no sentinel field names or write/delete protocol remain in the section.
- [x] [P3-T2] Change `## PR Creation Gate` in `.claude/skills/orchestrate/SKILL.md` from five to SIX conditions: keep conditions 1–4 (blocking_findings_resolved; AC verification; mandatory toolchain passed; `next_step` is `S8_create_pr`); set condition 5 = "PR body produced via the pr-author handoff: `artifacts/pr_body_<N>.md` exists with a matching `artifacts/pr_body_<N>.receipt.json`, created with `--body-file`"; set condition 6 = CI-green gate (`ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`; DONE is not written while either sub-condition is false).
  - Acceptance: the gate lists six numbered conditions; condition 5 is the receipt condition; condition 6 is the CI-green condition.
- [x] [P3-T3] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` with byte-identical content of the post-edit `.claude/skills/orchestrate/SKILL.md`.
  - Acceptance: byte comparison reports identical content.

#### orchestrator.md agent — Part A reference

- [x] [P3-T4] Rewrite the PR section of `.claude/agents/orchestrator.md` (`## PR Creation Delegation`, ~line 78) to reference the receipt handoff, point to `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` as authoritative, and remove all sentinel language (`pr_author_authorization.json`, `issued_by`, write/delete protocol).
  - Acceptance: the PR section references the receipt handoff and the orchestrate skill; no sentinel terms remain in the section.

#### orchestrator.md agent — Part B governance sections (added verbatim-faithful to the work order)

- [x] [P3-T5] Add the section `### Remediation Loop Checkpoint Shape` to `.claude/agents/orchestrator.md` describing the `remediation_loop` object: `current_cycle` (integer) and `cycles[]`, each cycle `{entry_timestamp, inputs_path, plan_path, preflight{iterations, final_status}, execution_status, audit_paths, blocking_count, exit_condition_met}`; the malformed-cycle rules (non-empty `plan_path`; execution requires `preflight.final_status == 'clear'`; `exit_condition_met == true` requires `blocking_count == 0`); and cycle-aware `next_step` form `remediation.cycle_N.{plan,preflight,execute,reaudit,exit_check}`.
  - Acceptance: the `### Remediation Loop Checkpoint Shape` heading is present with the cycle object fields, malformed-cycle rules, and cycle-aware `next_step` form.
- [x] [P3-T6] Add the section `### CI Monitoring and Post-PR Remediation` to `.claude/agents/orchestrator.md` stating: the orchestrator monitors required CI after PR open; a failed required check transitions into `remediation.cycle_N+1.inputs` and runs the full loop; workflow-file changes go through the loop and trigger `modified-workflow-needs-green-run`; and containing the verbatim invariant string exactly: "The orchestrator must not commit workflow-file changes outside the remediation loop."
  - Acceptance: the `### CI Monitoring and Post-PR Remediation` heading is present and the literal string "The orchestrator must not commit workflow-file changes outside the remediation loop." appears verbatim.
- [x] [P3-T7] Add the section `## Remediation Loop Protocol` to `.claude/agents/orchestrator.md` with these subsections: **Prohibited Delegations** (only `atomic-planner`/`atomic-executor`/`feature-review` during a cycle; no direct typed-engineer invocation; workers invoked by `atomic-executor` only); **Required Artifacts Per Cycle** (exactly five: `remediation-inputs.<entry-ts>.md`, `remediation-plan.<entry-ts>.md`, and `code-review`/`feature-audit`/`policy-audit`.`<exit-ts>.md`); **Preflight Sub-State Semantics** (`final_status` in `{clear, changes_requested, pending}`; `changes_requested` routes back to `atomic-planner`; `execution_status` in `{in_progress, complete, failed}` with `final_status != clear` is malformed; `preflight.iterations` counts passes); **Scope-change Rule** (a new finding during execution triggers a NEW cycle with a follow-up `remediation-inputs.<new-ts>.md`; do not re-prompt the same worker or extend the active plan); **Exit Gate** (`blocking_count` = total FAIL/blocking-PARTIAL across the three reaudit artifacts; only `blocking_count == 0` sets `exit_condition_met = true`); **Citations** (reference the remediation-handoff skill and the strict-handoff memory).
  - Acceptance: the `## Remediation Loop Protocol` heading and all six named subsections are present with the stated content.
- [x] [P3-T8] Confirm `.claude/agents/orchestrator.md` remains internally consistent and that the Part A reference and the three Part B sections coexist without contradiction.
  - Acceptance: the file contains the receipt-handoff PR reference, `### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation`, and `## Remediation Loop Protocol`; the file remains under 500 lines.
- [x] [P3-T9] Overwrite `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` with byte-identical content of the post-edit `.claude/agents/orchestrator.md`.
  - Acceptance: byte comparison reports identical content.

#### README.md

- [x] [P3-T10] Update the README.md reference (~line 40) from "a short-lived authorization sentinel" to a description of the SHA-256 receipt model for the PR-creation gate. No mirror.
  - Acceptance: README.md no longer references the authorization sentinel as the PR gate; it describes the receipt model.

#### Phase 3 parity gate

- [x] [P3-T11] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` to confirm no `.claude` mirror drift after the orchestrate-skill and orchestrator-agent edits.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase3-bundle-parity.md` exists with `EXIT_CODE: 0` and `Output Summary:` confirming byte-identical parity for `.claude/skills/orchestrate/SKILL.md` and `.claude/agents/orchestrator.md`.

---

### Phase 4 — Final QA Loop and Verification Gate

Full language-appropriate QA loop plus the AC verification grep proofs. Each command-bearing task executes its stated command (no SKIPPED).

#### PowerShell full toolchain loop (final)

- [x] [P4-T1] Run `mcp__drm-copilot__run_poshqc_format` over all in-scope PowerShell files; if it changes any file, restart the loop from this step.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-poshqc-format.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` showing a clean format pass with no file changes.
- [x] [P4-T2] Run `mcp__drm-copilot__run_poshqc_analyze`; if it changes files, restart from format.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-poshqc-analyze.md` exists with `EXIT_CODE: 0` and `Output Summary:` showing zero PSScriptAnalyzer findings.
- [x] [P4-T3] Run `mcp__drm-copilot__run_poshqc_test` in coverage mode for the claude-hooks test scope.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pester.md` exists with `EXIT_CODE: 0`, all receipt and shape-block contexts green, and `Output Summary:` recording numeric post-change line coverage >= 85% and branch coverage >= 75% for the hook.
- [x] [P4-T4] Compute the coverage delta against the Phase 0 baseline and record baseline coverage, post-change coverage, and changed-line coverage.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-coverage-delta.md` exists with `Timestamp:`, baseline vs post-change line/branch coverage, changed-line coverage, and confirms no regression on changed lines.

#### Bundle-parity final gate

- [x] [P4-T5] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-bundle-parity.md` exists with `EXIT_CODE: 0` and `Output Summary:` confirming byte-identical parity across all `.claude` and `.codex` mirrors touched.

#### Verification grep proofs

- [x] [P4-T6] Grep-prove the orchestrator agent contains the verbatim workflow-commit invariant and the three governance sections in `.claude/agents/orchestrator.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-grep-orchestrator-governance.md` exists showing matches for the literal "must not commit workflow-file changes outside the remediation loop", `### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation`, and `## Remediation Loop Protocol` (and its six subsections).
- [x] [P4-T7] Grep-prove no runtime file references the forgeable sentinel as the PR gate across `.claude/**`, `.codex/**` (bundle), `.github/agents/**`, `README.md`, and bundled mirrors (excluding historical feature docs).
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-grep-no-sentinel.md` exists showing zero matches for `pr_author_authorization`, `Test-PrAuthorAuthorization`, `issued_by`, `issued_at`, or `ttl_seconds` as the PR gate in the runtime scope; the search scope and patterns are recorded.
- [x] [P4-T8] Grep-prove the orchestrate skill `## PR Creation Gate` lists six conditions including the receipt condition in `.claude/skills/orchestrate/SKILL.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-grep-six-condition-gate.md` exists showing six numbered conditions with condition 5 as the receipt condition and condition 6 as the CI-green condition, and the `## PR Authoring (pr-author Handoff)` heading present.
- [x] [P4-T9] Verify the 500-line cap is respected on every touched PowerShell file (`.claude/hooks/enforce-pr-author-skill.ps1`, both mirror hooks, `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, and any extracted test helper).
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-line-counts.md` exists with per-file line counts, each <= 500.
- [x] [P4-T10] Verify the Pester pr-author hook tests cover all five receipt deny reasons plus the retained shape blocks and the allow path in a single green run.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-receipt-coverage-map.md` exists mapping each of `PR_BODY_PATH_NONCANONICAL`, `PR_AUTHOR_RECEIPT_MISSING`, `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH`, `PR_AUTHOR_RECEIPT_HASH_MISMATCH`, `PR_AUTHOR_RECEIPT_STALE`, the three shape blocks, and the allow path to a passing `It`.

---

## Acceptance Criteria Mapping

| AC (issue.md / user-story.md) | Phase / Task(s) |
|---|---|
| AC1 — hook verifies the SHA-256 receipt and emits the five ordered deny reasons; sentinel code path removed; deny uses `permissionDecision` shape. | P1-T1..T11 (removal + receipt verification + shape-block retention + deny shape), P1-T15..T20 (five reason tests + allow), P4-T7 (no-sentinel grep), P4-T10 (reason coverage map) |
| AC2 — No file references a forgeable PR authorization sentinel as the PR gate. | P1-T10, P2-T1..T3, P2-T7, P3-T1, P3-T4, P3-T10, P4-T7 |
| AC3 — `## PR Creation Gate` lists six conditions including the receipt condition; orchestrator agent references the receipt handoff. | P3-T1, P3-T2 (six-condition gate), P3-T4 (agent reference), P4-T8 (grep proof) |
| AC4 — orchestrator agent contains the verbatim workflow-commit invariant and the three governance sections. | P3-T5, P3-T6, P3-T7, P3-T8, P4-T6 (grep proof) |
| AC5 — Pester covers five receipt reasons plus shape blocks; PoshQC format/analyze clean; 500-line cap respected. | P1-T15..T23, P1-T24..T27, P4-T1..T3, P4-T9, P4-T10 |
| AC6 — Runtime files and all bundled mirrors (.claude, .codex, .agents, .github) remain in sync; bundle-parity contract tests pass. | P1-T12, P1-T13, P1-T28, P2-T4, P2-T6, P2-T8, P2-T9, P3-T3, P3-T9, P3-T11, P4-T5 |

## Phasing and Cap Compliance Notes

- Phase 1 PowerShell batch: 3 production `.ps1` (runtime hook + claude mirror + codex mirror) + 1 test `.ps1` — within the per-batch cap of <= 3 production and <= 3 test files.
- Phases 2 and 3 are Markdown-only and are exempt from the 500-line cap and the PowerShell per-batch cap; each runtime Markdown edit is paired with its byte-identical mirror in the same phase.
- Every touched `.ps1` is held <= 500 lines (P1-T11, P1-T23, P4-T9).
- Every phase that touches `.claude/**` or `.codex/**` runtime files runs the bundle-parity pytest to catch mirror drift (P1-T28, P2-T9, P3-T11, P4-T5).
- Each code/Markdown phase ends with the applicable toolchain/parity gate; the final phase restates the full QA loop and the verification grep gate.

## Out of Scope (per user-story Non-Goals)

- Converting the receipt into a cryptographic security boundary.
- Changing `validate-pr-author-output.ps1` (no sentinel dependency; retains `decision: block` / `exit 1` shape; must not be converted to `permissionDecision`).
- Any GitHub Actions workflow change.
- Adding dependencies, telemetry, or configuration keys.
- Modifying historical feature docs (issue #231 folder) or rewriting the issue #261 feature docs to describe the receipt model as already implemented.
- Any dual-mode or sentinel-fallback path.
