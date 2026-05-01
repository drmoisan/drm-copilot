# Feature Audit: codex-native-converter post-remediation rerun (#164)

**Audit Date:** 2026-04-26
**Feature Folder:** `docs/features/active/2026-04-26-codex-native-converter-164`
**Base Branch:** `development`
**Head Branch:** `feature/codex-native-converter-164` (`b9542764a8271b83ecb075b7ca6edeb8575d1dfe`)
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

## Scope and Baseline

- **Base branch:** `development` (commit `0762f58a1451994999c2f49f2dbdc489120d138a`)
- **Head branch/commit:** `feature/codex-native-converter-164` (commit `b9542764a8271b83ecb075b7ca6edeb8575d1dfe`)
- **Merge base:** `0762f58a1451994999c2f49f2dbdc489120d138a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/**`
  - Additional evidence: current-session TypeScript verification commands run during this review
- **Feature folder used:** `docs/features/active/2026-04-26-codex-native-converter-164`
- **Requirements source:** `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md` and `docs/features/active/2026-04-26-codex-native-converter-164/spec.md`
- **Work mode resolution note:** `issue.md` inside the active feature folder records `Work Mode: full-feature`, so the authoritative acceptance-criteria source set for this run is `spec.md` plus `user-story.md`.
- **Scope note:** This rerun validates the full current branch state after the first remediation loop. Acceptance criteria were already delivered before remediation; this rerun confirms they remain satisfied while separately evaluating the residual structural policy blocker.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md` — primary checkbox-backed acceptance-criteria source
- `docs/features/active/2026-04-26-codex-native-converter-164/spec.md` — supporting behavioral source for the same feature scope

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
| 1 | Deterministic classification and target-role output | PASS | `scripts/dev_tools/codex_native_converter/classifier.py`, `tests/scripts/dev_tools/codex_native_converter/test_classifier.py`, refreshed `artifacts/pr_context.summary.txt` | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | No remediation change reopened this behavior. |
| 2 | Extension and MCP entry points share the bundled Python converter contract | PASS | `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/src/repo-automation-service-workflows.ts`, `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts` | `npm --prefix extensions/drm-copilot run typecheck`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | The remediation preserved the wrapper contract while moving helper assembly logic. |
| 3 | v1 support remains explicit and unsupported inputs are reported explicitly | PASS | `spec.md`, `user-story.md`, `tests/scripts/dev_tools/codex_native_converter/test_validation.py`, refreshed `artifacts/pr_context.summary.txt` | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | No evidence of scope broadening or silent fallback was introduced by remediation. |
| 4 | Generated outputs remain constrained to approved Codex-native surfaces | PASS | `scripts/dev_tools/codex_native_converter/mapping.py`, `scripts/dev_tools/codex_native_converter/reporting.py`, fixture tests, refreshed PR context | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | The rerun found no change that weakens output-surface restrictions. |
| 5 | Hard gates and handoff behavior remain fail-closed | PASS | `scripts/dev_tools/codex_native_converter/validation.py`, `tests/scripts/dev_tools/codex_native_converter/test_validation.py`, `spec.md` | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | The remediation targeted only TypeScript wrapper structure and did not alter validation semantics. |
| 6 | Safe host-specific automation rewrites remain semantic and explicit | PASS | `scripts/dev_tools/codex_native_converter/rewrites.py`, `tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py`, `user-story.md` | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | No regression evidence surfaced in the current branch state. |
| 7 | Review mode remains non-mutating and emits the required report set | PASS | `scripts/dev_tools/codex_native_converter/reporting.py`, `tests/scripts/dev_tools/codex_native_converter/test_cli_review.py`, feature evidence under `evidence/other/` | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | Behavior remains delivered. |
| 8 | Apply mode requires an explicit destination root and fails closed on missing requirements | PASS | `tests/scripts/dev_tools/codex_native_converter/test_cli_apply.py`, `spec.md`, `user-story.md` | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | The remediation did not alter apply-mode contract behavior. |
| 9 | Representative GitHub Copilot and Claude fixtures remain supported without duplicated guidance flattening | PASS | `tests/fixtures/codex_native_converter/**`, `tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py`, refreshed PR context | `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` | Existing fixture coverage remains valid. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Feature behavior remains delivered, but the branch still has a residual structural policy blocker in `extensions/drm-copilot/src/repo-automation-command-registration.ts`.
2. None.
3. None.

**Recommended follow-up verification steps:**

1. Split `extensions/drm-copilot/src/repo-automation-command-registration.ts` into smaller focused modules while preserving command IDs and prompt behavior.
2. Rerun the TypeScript QA loop and refresh PR context against `development`, then perform another post-remediation review.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, status is recorded here without rewriting the source file.

### AC Status Summary

- Source: `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md`, `docs/features/active/2026-04-26-codex-native-converter-164/spec.md`
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md` | 9 | 9 | 0 | Checkbox-backed authoritative source. No edit was needed because all applicable items were already checked before this rerun. |
| `docs/features/active/2026-04-26-codex-native-converter-164/spec.md` | 0 checkbox AC items | 0 | 0 | Supporting behavioral source for full-feature review; no checkbox-backed AC list to update. |

No acceptance-criteria source-file edits were made during this rerun because all checkbox-backed criteria were already checked and remain satisfied.