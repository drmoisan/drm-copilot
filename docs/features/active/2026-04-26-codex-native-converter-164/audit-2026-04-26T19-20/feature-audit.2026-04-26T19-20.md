# Feature Audit: codex-native-converter (#164)

**Audit Date:** 2026-04-26
**Feature Folder:** `docs/features/active/2026-04-26-codex-native-converter-164`
**Base Branch:** `development`
**Head Branch:** `feature/codex-native-converter-164` working tree
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `development` (commit `0762f58a1451994999c2f49f2dbdc489120d138a`)
- **Head branch/commit:** `feature/codex-native-converter-164` working tree (resolved `HEAD` commit `0762f58a1451994999c2f49f2dbdc489120d138a` with additional staged and unstaged feature files)
- **Merge base:** `0762f58a1451994999c2f49f2dbdc489120d138a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.appendix.txt`
  - Secondary baseline diff: `artifacts/pr_context.summary.txt`
  - Feature evidence: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/**`
  - Additional evidence: direct inspection of `scripts/dev_tools/codex_native_converter/*.py`, `extensions/drm-copilot/src/mcp-handlers/codex-native-converter-handlers.ts`, `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/repo-automation-service.ts`, and `extensions/drm-copilot/resources/templates/codex_native_converter.py`
- **Feature folder used:** `docs/features/active/2026-04-26-codex-native-converter-164`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` currently records `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative acceptance-criteria sources for this run.
- **Scope note:** The refreshed PR-context summary shows an empty commit range because base and head resolved to the same commit SHA. This audit therefore evaluates the current working-tree implementation plus feature evidence rather than a commit-only diff.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md` — primary checkbox source
- `docs/features/active/2026-04-26-codex-native-converter-164/spec.md` — primary supporting requirements source and Definition of Done evidence

### Acceptance criteria

#### From `user-story.md`

1. A maintainer can run the converter against a supported GitHub Copilot or Claude source tree and receive deterministic classification for every examined artifact as `direct`, `decomposed`, `repo-convention`, or `unsupported`, plus a concrete target role.
2. The extension and MCP entry points invoke the same bundled Python converter contract.
3. v1 support is explicit and limited to documented GitHub Copilot and Claude source surfaces; unsupported ecosystems or unsupported files within those ecosystems are reported explicitly instead of inferred or silently dropped.
4. Generated outputs target only approved Codex-native surfaces such as `AGENTS.md`, `.agents/skills/**`, `.codex/agents/**`, `.codex/config.toml`, `.codex/hooks/**` or native hook configuration, `.codex/rules/**`, and repository-specific `.codex/prompts/**` only when that repository-convention output is intentionally enabled.
5. Hard gates and handoff-related behavior remain fail-closed and non-discretionary: if the converter cannot map them to verified Codex-native enforcement or delegation mechanisms, apply mode stops and records a blocking validation failure.
6. When a supported host-specific automation mapping exists, the converter rewrites it to the repository's semantic MCP usage model on server `drmCopilotExtension`; when no safe rewrite exists, the converter reports the gap and does not emit a misleading replacement.
7. Review mode is non-mutating and always produces a reviewable artifact set that includes `conversion-report.md`, `mapping-catalog.json`, `validation-results.json`, and a `proposed-tree/` snapshot.
8. Apply mode requires an explicit destination root, writes the approved Codex-native outputs plus the same report artifacts, and fails closed when required inputs, mappings, or native enforcement equivalents are missing.
9. At least one representative GitHub Copilot fixture and one representative Claude fixture can be converted into reviewable v1 outputs, and the result preserves reusable guidance in shared skills rather than flattening duplicated text across agents or prompts.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Deterministic classification and target-role assignment for supported GitHub Copilot or Claude source trees | PASS | `classifier.py`, `models.py`, `test_classifier.py`, `test_end_to_end.py` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | The classifier explicitly maps supported surfaces into conversion classes and target roles, and tests cover both ecosystems. |
| 2 | Extension and MCP entry points invoke the same bundled Python converter contract | PASS | `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/resources/templates/codex_native_converter.py`, `codex-native-converter-handlers.test.ts`, `repo-automation-service.codex-native-converter.test.ts` | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | The TypeScript entry points delegate to the bundled Python wrapper rather than duplicating converter logic. |
| 3 | v1 support is explicit and limited to documented source surfaces, with unsupported items reported explicitly | PASS | `inventory.py`, `classifier.py`, `validation.py`, `spec.md`, `user-story.md` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | Supported roots are explicitly enumerated by ecosystem, and unsupported mappings are represented in validation and report output. |
| 4 | Generated outputs target only approved Codex-native surfaces, with `.codex/prompts/**` gated by opt-in | PASS | `mapping.py`, `validation.py`, `test_mapping.py`, `spec.md` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | Mapping logic resolves only the approved target roles and demotes launcher output to unsupported unless repo prompts are enabled. |
| 5 | Hard gates and handoff-related behavior remain fail-closed and non-discretionary | PASS | `validation.py`, `classifier.py`, `engine.py`, `test_validation.py`, `test_cli_entrypoints.py` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | Apply mode exits non-zero on blocking findings and records structured validation failures. |
| 6 | Supported host-specific automation references rewrite to semantic MCP usage on `drmCopilotExtension`, otherwise report the gap | PASS | `rewrites.py`, `validation.py`, `spec.md`, `test_validation.py` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | Rewrites and unresolved-runtime-reference detection are explicit and fail closed when no safe mapping exists. |
| 7 | Review mode is non-mutating and always produces `conversion-report.md`, `mapping-catalog.json`, `validation-results.json`, and `proposed-tree/` | PASS | `reporting.py`, `engine.py`, `test_cli_review.py`, `test_end_to_end.py` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | Report writing uses a deterministic artifact-set contract and review mode does not write destination output. |
| 8 | Apply mode requires an explicit destination root, writes approved outputs plus the same report artifacts, and fails closed on missing requirements | PASS | `cli.py`, `engine.py`, `validation.py`, `test_cli_apply.py`, `test_cli_entrypoints.py` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | The CLI enforces destination-root presence for apply mode and exits non-zero on blocking findings. |
| 9 | Representative GitHub Copilot and Claude fixtures convert into reviewable v1 outputs while preserving shared guidance | PASS | `tests/fixtures/codex_native_converter/**`, `test_end_to_end.py`, `test_classifier.py`, `test_mapping.py` | `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` | Both ecosystems have checked-in fixtures and review-mode tests validate the generated artifact set and shared-skill preservation strategy. |

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Complete the structural remediation identified in the policy audit for the oversized touched TypeScript files.
2. Rerun the feature review after that remediation so acceptance and policy status are both current.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md`, `docs/features/active/2026-04-26-codex-native-converter-164/spec.md`
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md` | 9 | 9 | 0 | Checkbox-backed and already checked at review time. |
| `docs/features/active/2026-04-26-codex-native-converter-164/spec.md` | 7 Definition-of-Done items | 6 | 1 | The remaining unchecked item is `Telemetry/logging added or updated (if applicable)`, which is not part of the user-story acceptance-criteria checklist used for final PASS here. |

No source-file checkbox changes were made during this review because the authoritative `user-story.md` acceptance-criteria items were already checked at review time.