# Atomic Implementation Plan — propagate-claude-ecosystem-hardening (#187)

- **Issue:** #187
- **Feature folder:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/`
- **Work Mode:** full-feature
- **Plan timestamp:** 2026-06-16T11-00
- **Spec:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/spec.md`
- **User story:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/user-story.md`
- **Research:** `artifacts/research/20260616-tocompare-claude-ecosystem-hardening-audit-research.md`

## Scope and Invariants

This plan propagates seven hardened elements from the SOURCE reference tree
(`artifacts/tocompare/.claude/`) into the canonical `.claude/` runtime, both
bundled mirrors, and one Python validator. Languages in scope: PowerShell
(items 1, 2 + Pester tests), Python (item 5 validator + pytest), and
Markdown-only documentation/skill assets (items 3, 4, 6, 7 and rule docs).

Hard invariants (from spec Constraints & Risks and research Sections 5, 7):

- Every canonical `.claude/` file created or edited MUST be copied
  byte-identically to BOTH `extensions/drm-copilot/resources/claude-customizations/.claude/...`
  and `packages/mcp-server/resources/claude-customizations/.claude/...`.
- `scripts/dev_tools/validate_orchestrator_state.py` is NOT a `.claude` file and
  has NO mirror; do not create a mirror copy of the Python file.
- `schemas/orchestrator-state.schema.json` MUST NOT be copied verbatim.
- `settings.local.json` and `agent-memory/**` MUST NOT be propagated.
- `rules/orchestrator-state.md` is repo-ahead; only additive `human_interaction`
  documentation is permitted, no regression of existing prose.
- All evidence artifacts resolve to
  `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/evidence/<kind>/`.
- Backward-compatibility: absent `human_interaction` key passes both the hook
  and the Python validator; non-matching research artifacts pass the researcher
  hook unaffected.

Dependency ordering (research Section 7): items 1–4 are self-contained; item 5
depends on items 1 and 4 being present; items 6 and 7 are independent. This
plan groups item 1 (Phase 1), item 2 (Phase 2), items 3+4 (Phase 3), item 5
(Phase 4), items 6+7 (Phase 5), full mirror parity verification (Phase 6), and
final QA (Phase 7).

Per-batch budgets respected: PowerShell max 3 production + 3 test per phase;
Python max 3 production + 3 test per phase. Each PowerShell item touches one
production hook (3 copies are byte-identical mirrors of one file) plus its
Pester test; each is its own phase.

---

### Phase 0 — Baseline Capture and Policy Reads

- [x] [P0-T1] Read repository policy files in the required order and record an evidence artifact. Files to read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/skills/policy-compliance-order/SKILL.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Acceptance: artifact `evidence/baseline/phase0-instructions-read.2026-06-16T11-00.md` exists containing `Timestamp:`, `Policy Order:`, and the explicit list of files read.
- [x] [P0-T2] Capture the PowerShell Pester baseline for the two hook test files. Command: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` and `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`. Acceptance: artifact `evidence/baseline/baseline-pester.2026-06-16T11-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording pass/fail counts and the line/branch coverage headline for the two hook scripts.
- [x] [P0-T3] Capture the Python validator baseline. Commands (record each): `poetry run black --check scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `poetry run ruff check scripts/dev_tools/validate_orchestrator_state.py`, `poetry run pyright scripts/dev_tools/validate_orchestrator_state.py`, `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py --cov=scripts/dev_tools/validate_orchestrator_state --cov-branch --cov-report=term-missing`. Acceptance: artifact `evidence/baseline/baseline-python.2026-06-16T11-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording pass/fail counts and numeric line + branch coverage for `validate_orchestrator_state.py`.
- [x] [P0-T4] Capture the bundle-sync contract-test baseline. Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Acceptance: artifact `evidence/baseline/baseline-bundle-sync.2026-06-16T11-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording pass/fail counts.

---

### Phase 1 — Item 1: `Test-HumanInteractionShape` Completion-Gate Hook

- [x] [P1-T1] Add the `Test-HumanInteractionShape` function to `.claude/hooks/validate-orchestrator-output.ps1`, ported byte-for-equivalent from SOURCE `artifacts/tocompare/.claude/hooks/validate-orchestrator-output.ps1` lines 133–214, including the injectable `$FileExistsCheck` scriptblock parameter defaulting to `{ param($Path) Test-Path -LiteralPath $Path -PathType Leaf }`. Acceptance: the function exists in the file with the documented rejection order (absent-key pass; missing `requirements` block; missing/blank `response` block; out-of-enum `response` block; `response == 'halt'` block; `response == 'exception'` with empty or non-existent `runbook_path` block) and the function uses the SOURCE error-message strings.
- [x] [P1-T2] Wire `Test-HumanInteractionShape` into `Invoke-OrchestratorOutputValidation` in `.claude/hooks/validate-orchestrator-output.ps1`, reading the optional top-level `human_interaction` key from the checkpoint and returning the function's blocking message when not `Ok`, placed after the existing `Test-RemediationLoopShape` call (SOURCE lines 292–299). Acceptance: `Invoke-OrchestratorOutputValidation` calls `Test-HumanInteractionShape` and a checkpoint with no `human_interaction` key still returns `Ok = $true`.
- [x] [P1-T3] Add Pester tests for `Test-HumanInteractionShape` to `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` covering: absent-key passes; missing-`requirements` blocks; missing-`response` blocks; invalid-enum `response` blocks; `response == 'halt'` blocks; `response == 'exception'` without runbook blocks (via injected `$FileExistsCheck` returning `$false`); `response == 'exception'` with existing runbook passes (via injected `$FileExistsCheck` returning `$true`). Acceptance: seven new `It` blocks exist, each using Arrange–Act–Assert and the injectable `$FileExistsCheck` seam (no temporary files).
- [x] [P1-T4] Run the PowerShell toolchain for item 1: format → analyze → test. Commands: `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` then `mcp__drm-copilot__run_poshqc_test` scoped to `.claude/hooks/validate-orchestrator-output.ps1` and its test. Acceptance: artifact `evidence/qa-gates/p1-poshqc.2026-06-16T11-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording 0 analyzer findings and all Pester tests passing with line >= 85% / branch >= 75% coverage for the hook script; loop restarts from format if any stage changes files or fails.
- [x] [P1-T5] Mirror `.claude/hooks/validate-orchestrator-output.ps1` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`. Acceptance: the two files are byte-identical (verified by content comparison; bundle-sync contract test in Phase 6 confirms).
- [x] [P1-T6] Mirror `.claude/hooks/validate-orchestrator-output.ps1` byte-identically to `packages/mcp-server/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`. Acceptance: the two files are byte-identical (verified by content comparison).

---

### Phase 2 — Item 2: `Test-AutomationFeasibilitySection` Research-Gate Hook

- [x] [P2-T1] Add the `Test-AutomationFeasibilitySection` function to `.claude/hooks/validate-task-researcher-output.ps1`, ported from SOURCE `artifacts/tocompare/.claude/hooks/validate-task-researcher-output.ps1` lines 86–147, including the injectable `$ReadFileContent` scriptblock parameter defaulting to `{ param($Path) Get-Content -LiteralPath $Path -Raw -ErrorAction Stop }`, the narrow detection pattern `autonomous-execution|human-interaction` against filename and agent output, and the `## Automation Feasibility` heading requirement. Acceptance: the function exists with the documented behavior (non-matching artifacts pass; matching artifact missing section blocks; matching artifact with section passes) and uses the SOURCE error-message strings.
- [x] [P2-T2] Wire `Test-AutomationFeasibilitySection` into `Invoke-TaskResearcherOutputValidation` in `.claude/hooks/validate-task-researcher-output.ps1` as the final check before returning `Ok`, passing the resolved `$researchPath` and `$agentOutput` (SOURCE lines 192–195). Acceptance: `Invoke-TaskResearcherOutputValidation` calls `Test-AutomationFeasibilitySection` and a research artifact whose filename and content do not match the detection pattern is unaffected.
- [x] [P2-T3] Add Pester tests for `Test-AutomationFeasibilitySection` to `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` covering: non-matching artifact passes; matching artifact (by filename or content) missing the `## Automation Feasibility` section blocks; matching artifact with the section passes. Acceptance: three new `It` blocks exist using Arrange–Act–Assert and the injectable `$ReadFileContent` seam (no temporary files).
- [x] [P2-T4] Run the PowerShell toolchain for item 2: format → analyze → test. Commands: `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` then `mcp__drm-copilot__run_poshqc_test` scoped to `.claude/hooks/validate-task-researcher-output.ps1` and its test. Acceptance: artifact `evidence/qa-gates/p2-poshqc.2026-06-16T11-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording 0 analyzer findings and all Pester tests passing with line >= 85% / branch >= 75% coverage for the hook script; loop restarts from format if any stage changes files or fails.
- [x] [P2-T5] Mirror `.claude/hooks/validate-task-researcher-output.ps1` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`. Acceptance: the two files are byte-identical.
- [x] [P2-T6] Mirror `.claude/hooks/validate-task-researcher-output.ps1` byte-identically to `packages/mcp-server/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`. Acceptance: the two files are byte-identical.

---

### Phase 3 — Items 3 and 4: Autonomous-Execution Mandate and Human-Exception Runbook Skill

- [x] [P3-T1] Insert the `## Autonomous-Execution Mandate` section into `.claude/skills/orchestrate/SKILL.md` immediately before the `## Delegation Model` heading, ported from SOURCE `artifacts/tocompare/.claude/skills/orchestrate/SKILL.md` lines 27–55 (detection points, the three permitted responses `scope_change`/`exception`/`halt`, the exception-runbook requirement, and the three named enforcement points: schema, completion gate `Test-HumanInteractionShape`, research gate `Test-AutomationFeasibilitySection`). Acceptance: the section is present in the canonical file, positioned before `## Delegation Model`, and matches the SOURCE section content.
- [x] [P3-T2] Mirror `.claude/skills/orchestrate/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` and `packages/mcp-server/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`. Acceptance: both mirror files are byte-identical to the canonical file.
- [x] [P3-T3] Create `.claude/skills/human-exception-runbook/SKILL.md` ported byte-for-content from SOURCE `artifacts/tocompare/.claude/skills/human-exception-runbook/SKILL.md` (canonical path `<FEATURE>/runbooks/<name>.runbook.md`, the five required sections Cue/Prerequisites/Step-by-step Instructions/Verification/Source and Citation, MCP-first/web-second sourcing rule, and Conformance section). Acceptance: the new file exists with the five required sections and the sourcing rule.
- [x] [P3-T4] Create `.claude/skills/human-exception-runbook/example.runbook.md` ported byte-for-content from SOURCE `artifacts/tocompare/.claude/skills/human-exception-runbook/example.runbook.md` (the Entra admin-consent example with all five sections and dated citations). Acceptance: the new file exists with all five sections and at least one dated source citation.
- [x] [P3-T5] Mirror both new `human-exception-runbook` files byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/human-exception-runbook/SKILL.md` and `.../example.runbook.md`, and to `packages/mcp-server/resources/claude-customizations/.claude/skills/human-exception-runbook/SKILL.md` and `.../example.runbook.md`. Acceptance: all four mirror files exist and are byte-identical to their canonical counterparts.

---

### Phase 4 — Item 5: `human_interaction` Validator Invariants and Rule Documentation

(Depends on Phases 1 and 4 deliverables: the completion-gate hook and the
runbook skill must exist before the rule documentation cites them. Phase 1 is
complete and Phase 3 created the skill; this phase may proceed.)

- [x] [P4-T1] Add `human_interaction` invariant logic to `scripts/dev_tools/validate_orchestrator_state.py` following the existing helper-plus-error-list pattern of `_validate_remediation_loop` / `_validate_remediation_cycle`. Add a private helper `_validate_human_interaction` (and module constants for the response enum `{"scope_change", "exception", "halt"}` and the `human_interaction` key) that, only when a top-level `human_interaction` key is present, enforces: `requirements` is present and is a list; each requirement is an object with a `response` value within the enum; `response == "exception"` requires a non-empty `runbook_path` string. Errors use the existing literal, `Checkpoint`-prefixed message style. Acceptance: the helper returns a `list[str]` of errors, never mutates input, and `validate_orchestrator_state_text` calls it only when the `human_interaction` key is present (mirroring the `REMEDIATION_LOOP_KEY` guard at lines 392–393). The validator does not import or read `schemas/orchestrator-state.schema.json`.
- [x] [P4-T2] Add pytest tests for the new invariants to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` (or a sibling `test_validate_orchestrator_state_human_interaction.py` mirroring the existing remediation-loop test file pattern), covering: a checkpoint with no `human_interaction` key validates unchanged (backward-compatibility); `human_interaction` present with missing `requirements` errors; a requirement with `response` outside the enum errors; `response == "exception"` with empty/missing `runbook_path` errors; a well-formed `human_interaction` with `scope_change` and a runbook-backed `exception` produces no new errors. Acceptance: the new tests exist, follow Arrange–Act–Assert, and assert against the exact error strings; no temporary files are used.
- [x] [P4-T3] Update `.claude/rules/orchestrator-state.md` to document the `human_interaction` invariants alongside the existing three remediation-cycle invariants, and adjust the foreign-schema note per research Section 5 (the SOURCE schema with a repo-local `$id` is not the disqualified foreign schema; the `drmoisan.github.io/mix-calculator/` foreign-schema prohibition is preserved as the stated reason for not importing that foreign artifact). The edit is additive and must not regress existing prose. Acceptance: the rule documents the three `human_interaction` invariants (required `requirements`, per-requirement `response` enum membership, exception-requires-`runbook_path`), cites `scripts/dev_tools/validate_orchestrator_state.py` as the enforcement point, and the existing three invariants and foreign-schema prohibition remain intact.
- [x] [P4-T4] Run the Python toolchain for item 5: Black → Ruff → Pyright → Pytest. Commands: `poetry run black scripts/dev_tools/validate_orchestrator_state.py <new test file>`, `poetry run ruff check scripts/dev_tools/validate_orchestrator_state.py`, `poetry run pyright scripts/dev_tools/validate_orchestrator_state.py`, `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py <new test file> --cov=scripts/dev_tools/validate_orchestrator_state --cov-branch --cov-report=term-missing`. Acceptance: artifact `evidence/qa-gates/p4-python.2026-06-16T11-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording 0 format/lint/type errors, all tests passing, and numeric line >= 85% / branch >= 75% coverage for `validate_orchestrator_state.py`; loop restarts from Black if any stage changes files or fails.
- [x] [P4-T5] Mirror `.claude/rules/orchestrator-state.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` and `packages/mcp-server/resources/claude-customizations/.claude/rules/orchestrator-state.md`. Acceptance: both mirror files are byte-identical to the canonical file. Note: `scripts/dev_tools/validate_orchestrator_state.py` has no mirror and is not copied.

---

### Phase 5 — Items 6 and 7: Coverage/Test-Location Rule Sections and Remediation-Handoff Skill

- [x] [P5-T1] Add the `## Coverage Exclusion Policy` section to `.claude/rules/general-unit-test.md`, ported from SOURCE `artifacts/tocompare/.claude/rules/general-unit-test.md`, placed after the `## Coverage Requirements` section (no production file excluded from coverage; permitted vs. prohibited `exclude` entries; feature-review treats a production-path exclude entry as Blocking). Acceptance: the `## Coverage Exclusion Policy` section is present with the permitted/prohibited entry lists and the Blocking-enforcement sentence.
- [x] [P5-T2] Add the `## Test File Location` section to `.claude/rules/general-unit-test.md`, ported from SOURCE, placed after the `## External Dependencies` section (tests live in a `tests/` tree mirroring production source; colocation in `src/` or equivalent is prohibited). Acceptance: the `## Test File Location` section is present with the mirror-structure requirement and the colocation prohibition.
- [x] [P5-T3] Mirror `.claude/rules/general-unit-test.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` and `packages/mcp-server/resources/claude-customizations/.claude/rules/general-unit-test.md`. Acceptance: both mirror files are byte-identical to the canonical file.
- [x] [P5-T4] Replace `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` with the expanded SOURCE version `artifacts/tocompare/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (Full Handoff Chain diagram, Required Artifacts with entry-vs-exit timestamp contract, Plan Shape, Preflight Sub-Loop, Exit Gate sections). Acceptance: the canonical file matches the SOURCE version byte-for-content, including all named sections.
- [x] [P5-T5] Mirror `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` and `packages/mcp-server/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md`. Acceptance: both mirror files are byte-identical to the canonical file.

---

### Phase 6 — Mirror Parity Verification

- [x] [P6-T1] Run the authoritative bundle-sync contract test. Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Acceptance: artifact `evidence/qa-gates/p6-bundle-sync.2026-06-16T11-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes (every changed/created canonical `.claude/` file is byte-identical in the `extensions/` mirror), and `test_bundled_claude_payload_excludes_settings_local_json` passes.
- [x] [P6-T2] Verify the `packages/mcp-server` mirror parity for every file changed or created in Phases 1–5 (the `packages/mcp-server` mirror has no automated contract test per research Section 2, so confirm manually). Files: `hooks/validate-orchestrator-output.ps1`, `hooks/validate-task-researcher-output.ps1`, `skills/orchestrate/SKILL.md`, `skills/human-exception-runbook/SKILL.md`, `skills/human-exception-runbook/example.runbook.md`, `rules/orchestrator-state.md`, `rules/general-unit-test.md`, `skills/remediation-handoff-atomic-planner/SKILL.md`. Acceptance: artifact `evidence/qa-gates/p6-mcp-mirror-parity.2026-06-16T11-00.md` records, per file, that the `packages/mcp-server/resources/claude-customizations/.claude/...` copy is byte-identical to the canonical `.claude/...` file (`EXIT_CODE: 0` per comparison).
- [x] [P6-T3] Confirm exclusion invariants: `settings.local.json` and `agent-memory/**` were not propagated from SOURCE, and `scripts/dev_tools/validate_orchestrator_state.py` has no mirror copy. Acceptance: artifact `evidence/qa-gates/p6-exclusions.2026-06-16T11-00.md` records that no SOURCE `settings.local.json` or `agent-memory/**` content was added, no `validate_orchestrator_state.py` mirror exists under either bundle, and no verbatim `orchestrator-state.schema.json` was added to `.claude/schemas/`.

---

### Phase 7 — Final QA Loop (All Languages)

- [x] [P7-T1] Run the full PowerShell QA loop for both hooks: format → analyze → test. Commands: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` for `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, and their Pester test files. Acceptance: artifact `evidence/qa-gates/p7-poshqc-final.2026-06-16T11-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording 0 analyzer findings, all Pester tests passing, and numeric line >= 85% / branch >= 75% coverage for both hook scripts; loop restarts from format if any stage changes files or fails.
- [x] [P7-T2] Run the full Python QA loop for the validator: Black → Ruff → Pyright → Pytest with coverage. Commands: `poetry run black scripts/dev_tools/validate_orchestrator_state.py <new test file>`, `poetry run ruff check scripts/dev_tools/validate_orchestrator_state.py`, `poetry run pyright scripts/dev_tools/validate_orchestrator_state.py`, `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py <new test file> --cov=scripts/dev_tools/validate_orchestrator_state --cov-branch --cov-report=term-missing`. Acceptance: artifact `evidence/qa-gates/p7-python-final.2026-06-16T11-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording 0 format/lint/type errors, all tests passing, and numeric line >= 85% / branch >= 75% coverage for `validate_orchestrator_state.py`; loop restarts from Black if any stage changes files or fails.
- [x] [P7-T3] Run the full bundle-sync contract-test suite. Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Acceptance: artifact `evidence/qa-gates/p7-bundle-sync-final.2026-06-16T11-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; all contract tests pass.
- [x] [P7-T4] Record a coverage delta/threshold verification comparing Phase 0 baselines to Phase 7 results. Acceptance: artifact `evidence/qa-gates/p7-coverage-delta.2026-06-16T11-00.md` records, for `validate_orchestrator_state.py` and both PowerShell hook scripts: baseline coverage, post-change coverage, and changed-code coverage, confirming no regression on changed lines and that line >= 85% / branch >= 75% thresholds hold.
- [x] [P7-T5] Verify acceptance criteria mapping. Acceptance: artifact `evidence/qa-gates/p7-acceptance-map.2026-06-16T11-00.md` maps each spec Acceptance Criterion (items 1–7 plus the mirror-parity/toolchain block) to the evidence artifact and code/test location that satisfies it, confirming all criteria are met.
