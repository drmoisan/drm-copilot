# Feature Audit: harden feature promotion lifecycle MCP-only (#168)

**Audit Date:** 2026-04-29
**Feature Folder:** `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168`
**Base Branch:** `development`
**Head Branch:** `feature/harden-feature-promotion-lifecycle-mcp-only-168` working tree
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `development` (commit `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`)
- **Head branch/commit:** `feature/harden-feature-promotion-lifecycle-mcp-only-168` working tree (branch tip also at `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`)
- **Merge base:** `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.appendix.txt`
  - Secondary baseline diff: `artifacts/pr_context.summary.txt`
  - Feature evidence: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/`
  - Additional evidence:
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/code-review.2026-04-29T13-55.md`
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-black.2026-04-29T10-47.md`
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-ruff.2026-04-29T10-49.md`
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pyright.2026-04-29T10-51.md`
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pytest.2026-04-29T10-52.md`
- **Feature folder used:** `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` explicitly declares `- Work Mode: full-feature`, so the authoritative acceptance sources for this run are `spec.md` and `user-story.md`.
- **Scope note:** The refreshed PR context against `development` shows no committed branch delta, so this audit evaluates the current working tree plus the feature folder’s baseline and QA evidence.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md` — primary checkbox-backed source
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md` — secondary prose-backed corroboration source

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

`spec.md` corroborates the same eight requirements through its Behavior, API / CLI Surface, and Data & State sections. It also contains a checked `## Definition of Done` section that remains satisfied for this run. The separate `## Seeded Test Conditions (from potential)` checklist is treated as supplemental test-planning guidance rather than as the authoritative acceptance-criteria source for this full-feature review, so those items were left unchanged.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | MCP-only lifecycle skill with preflight and raw receipt capture | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The skill contains the required MCP preflight and receipt-key wording, and the contract tests passed after the validator split. |
| 2 | No fallback commands when MCP tools are unavailable | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The skill explicitly says agent sessions stop and restore MCP connectivity instead of using script fallbacks. |
| 3 | Banned fallback/script strings removed from the skill | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/skill-banned-string-grep.2026-04-29T08-56.md` | `pwsh -NoProfile -Command "Select-String -Path '.claude/skills/feature-promotion-lifecycle/SKILL.md' -Pattern 'Fallback','fallback','dev_tools','dev-tools','poetry run python -m scripts' -SimpleMatch"` | The review-time grep produced no matches. |
| 4 | Exactly one non-authoritative VS Code command-palette note remains | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The contract test asserts exactly one `VS Code command-palette` note and the required non-authoritative wording. |
| 5 | Bash hook registration and enforcement for the four promotion tokens | PASS | `.claude/settings.json`; `.claude/hooks/enforce-promotion-mcp-only.ps1`; `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1`; `tests/scripts/claude-runtime/claude-settings.Tests.ps1` | `mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]` | The settings file registers the hook, and the Pester suite proves one allow case and four deny-token cases. |
| 6 | Receipt namespace documented as raw MCP payloads | PASS | `.claude/skills/feature-promotion-lifecycle/SKILL.md`; `.claude/agents/orchestrator.md` | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | Both runtime documents name the exact keys and describe them as raw receipt payloads without lossy normalization. |
| 7 | Validator and tests accept the additive receipt namespace while preserving legacy compatibility | PASS | `scripts/dev_tools/validate_orchestration_artifacts.py`; `scripts/dev_tools/validate_orchestrator_state.py`; `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`; `artifacts/orchestration/orchestrator-state.json` | `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json` and `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | The live checkpoint validated successfully after the split, and the Python tests cover both the legacy list and additive namespace forms. |
| 8 | Scope remains limited to Claude-side skill/settings/hook/documentation/validation surfaces | PASS | `artifacts/pr_context.appendix.txt`; working-tree diff inspection | `mcp_drmcopilotext_collect_pr_context base=development` | The reviewed diff does not modify the underlying `scripts/dev_tools` promotion modules or the MCP server implementation. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Commit the reviewed working-tree changes so a later PR-context refresh can represent the true branch diff.
2. If the repository continues to enforce the new-module coverage target as a release gate, add focused tests for the uncovered review-artifact and orchestrator-state edge paths identified in `code-review.2026-04-29T13-55.md`.

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
| `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md` | 8 | 8 | 0 | Checkbox-backed and already checked before this review. |
| `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md` | 7 | 7 | 0 | The authoritative `## Definition of Done` items were already checked before this review; the supplemental `## Seeded Test Conditions (from potential)` checklist was left unchanged. |

No source-file checkbox change was made during this review because the authoritative acceptance criteria in both `user-story.md` and `spec.md` were already marked complete, and the supplemental `## Seeded Test Conditions (from potential)` checklist in `spec.md` was outside the acceptance-criteria source used for this review.
