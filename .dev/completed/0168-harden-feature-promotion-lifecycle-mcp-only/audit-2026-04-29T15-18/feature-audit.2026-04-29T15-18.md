# Feature Audit: harden feature promotion lifecycle MCP-only (#168)

**Audit Date:** 2026-04-29
**Feature Folder:** `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168`
**Base Branch:** `development`
**Head Branch:** `feature/harden-feature-promotion-lifecycle-mcp-only-168` working tree
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `development` (commit `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`)
- **Head branch/commit:** `feature/harden-feature-promotion-lifecycle-mcp-only-168` working tree (branch tip also resolves to `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`)
- **Merge base:** `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/`
  - Additional evidence: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T15-18/policy-audit.2026-04-29T15-18.md`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T15-18/code-review.2026-04-29T15-18.md`
- **Feature folder used:** `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` explicitly declares `- Work Mode: full-feature`, so the authoritative acceptance-criteria sources for this review are `spec.md` and `user-story.md`.
- **Scope note:** The PR context was refreshed against `development` during this rerun. The branch currently reviews as a working tree because the resolved base, head, and merge-base SHAs are identical.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md` ΓÇö primary checkbox-backed source
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md` ΓÇö corroborating full-feature scope source

### From `user-story.md`

1. `.claude/skills/feature-promotion-lifecycle/SKILL.md` is rewritten so agent-session promotion guidance is MCP-only, includes an explicit preflight verification that the required promotion MCP tools are available before execution begins, and requires raw receipt capture for the potential-entry, issue-promotion, and active-feature-folder steps.
2. When the required promotion MCP tools are unavailable, the documented lifecycle stops before any promotion step runs and does not direct agent sessions to `scripts/dev_tools/`, `scripts/dev-tools/`, or `poetry run python -m scripts...` fallback commands.
3. The skill no longer contains fallback-script sections or any remaining direct script guidance, and grep-based verification against `.claude/skills/feature-promotion-lifecycle/` shows no matches for `Fallback`, `fallback`, `dev_tools`, `dev-tools`, or `poetry run python -m scripts`.
4. The only documented non-MCP alternative remaining in `.claude/skills/feature-promotion-lifecycle/SKILL.md` is a single VS Code command-palette note that is explicitly marked non-authoritative for agent sessions.
5. `.claude/settings.json` registers the required PreToolUse Bash hook, and a dedicated hook script under `.claude/hooks/` allows benign Bash commands but blocks invocations containing `new-potential-entry.ps1`, `new_potential_bug_entry`, `potential_to_issue`, or `new_active_feature_folder` by returning the required error message before execution.
6. The checkpoint contract is documented to support `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder`, and those fields are defined as the raw MCP receipts captured from the corresponding promotion operations without lossy normalization.
7. `scripts/dev_tools/validate_orchestration_artifacts.py` and its tests accept the current nested `delegation_receipts.promotion.*` checkpoint shape additively while preserving compatibility with the existing list-based `delegation_receipts` validation path.
8. The change remains limited to Claude-side skill, settings, hook, and checkpoint-schema documentation/validation surfaces; no underlying `scripts/dev_tools/` promotion modules are modified, and no MCP server implementation changes are introduced.

### From `spec.md`

`spec.md` corroborates the same delivered behavior through its Behavior, API / CLI Surface, Data & State, and Definition of Done sections. Its checked Definition of Done items remain aligned with the acceptance result in this rerun.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | MCP-only lifecycle skill with preflight and raw receipt capture | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The skill wording remains MCP-only and the contract tests still cover the required fragments. |
| 2 | No fallback commands when MCP tools are unavailable | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The skill explicitly instructs agent sessions to stop and restore MCP access instead of using script fallback. |
| 3 | Banned fallback/script strings removed from the skill | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/skill-banned-string-grep.2026-04-29T08-56.md` | `pwsh -NoProfile -Command "Select-String -Path '.claude/skills/feature-promotion-lifecycle/SKILL.md' -Pattern 'Fallback','fallback','dev_tools','dev-tools','poetry run python -m scripts' -SimpleMatch"` | The banned-string verification remains satisfied in this rerun. |
| 4 | Exactly one non-authoritative VS Code command-palette note remains | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The contract test still enforces exactly one `VS Code command-palette` note with the required non-authoritative wording. |
| 5 | Bash hook registration and enforcement for the four promotion tokens | PASS | `.claude/settings.json`; `.claude/hooks/enforce-promotion-mcp-only.ps1`; PowerShell test suites | `mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]` | The settings registration and the allow or deny behavior remain supported by the stored PowerShell QA evidence. |
| 6 | Receipt namespace documented as raw MCP payloads | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `.claude/agents/orchestrator.md` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The exact `delegation_receipts.promotion.*` keys and raw-payload wording remain present. |
| 7 | Validator and tests accept the additive receipt namespace while preserving legacy compatibility | PASS | `scripts/dev_tools/validate_orchestration_artifacts.py`; `scripts/dev_tools/validate_orchestrator_state.py`; `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`; `artifacts/orchestration/orchestrator-state.json` | `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json` | The current workspace validator passed against the live checkpoint during this rerun, and the existing tests still cover both legacy and additive shapes. |
| 8 | Scope remains limited to Claude-side skill/settings/hook/documentation/validation surfaces | PASS | Refreshed PR context plus working-tree inspection | `mcp_drmcopilotext_collect_pr_context base=development` | The reviewed scope does not modify the underlying promotion modules or the MCP server implementation. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None for acceptance behavior.

**Recommended follow-up verification steps:**

1. Use the companion `policy-audit.2026-04-29T15-18.md` and `code-review.2026-04-29T15-18.md` as the authoritative merge-gate artifacts for policy readiness.
2. After remediation of the oversized validator module and coverage gaps, refresh PR context again and rerun the review package.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`; `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md` | 8 | 8 | 0 | Checkbox-backed and already checked before this rerun. |
| `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md` | 7 | 7 | 0 | Definition of Done corroborates the acceptance result; no additional checkbox edit was required during this rerun. |

No source-file checkbox change was made during this rerun because the authoritative acceptance items were already checked and remained supported by the refreshed evidence.
