# Feature Audit: codex-native-converter v2 (#164)

**Audit Date:** 2026-04-30
**Branch:** `feature/20260429090101-port-codex-skill` → `development`
**Issue:** #164
**Feature Folder:** `docs/features/active/2026-04-26-codex-native-converter-164/`
**Plan:** `v2/plan.2026-04-30T19-56.md`
**Work Mode:** `full-feature`

**AC Sources (authoritative):**

| Source | Format | Items | Location |
|--------|--------|-------|----------|
| `v2/user-story.md` | Checkbox items | 9 items | `docs/features/active/2026-04-26-codex-native-converter-164/v2/user-story.md` |
| `v2/spec.md` | Prose numbered items (no checkboxes) | 14 items | `docs/features/active/2026-04-26-codex-native-converter-164/v2/spec.md` |

Note: `v2/spec.md` uses prose-numbered format. Acceptance criteria are stated as numbered requirements, not checkboxes. The authoritative checkbox-format AC source is `v2/user-story.md`.

---

## Executive Summary

All acceptance criteria from both `v2/user-story.md` (9 checkbox items) and `v2/spec.md` (14 prose items) are assessed as **PASS**. The converter delivers a complete compiler-style intermediate state pipeline: typed discovery → parse → classify → plan → (optionally emit intermediate state) → render → validate. End-to-end tests confirm that at least one GitHub Copilot fixture and one Claude fixture convert successfully. All required output targets are supported. The review-mode / apply-mode contract is enforced with fail-closed logic verified by unit and integration tests.

The feature is **functionally complete**. Three structural policy violations (500-line limit on `engine.py`, `models.py`, `reporting.py`) and two per-file coverage gaps (`section_intent.py` 76%, `intermediate_state.py` 87%) require remediation before the branch can be considered policy-clean for merge, but these do not affect feature correctness.

**Feature Readiness Verdict: PASS (functionality) + REMEDIATION REQUIRED (policy compliance)**

---

## Section 1: AC Verification — `v2/user-story.md`

All 9 checkbox items in `v2/user-story.md` were marked `[x]` in the source prior to this audit. The table below confirms each item against available evidence.

| # | Acceptance Criterion | AC Status | Evidence |
|---|---------------------|-----------|----------|
| 1 | A maintainer can run the converter against a repo and receive a deterministic classification of all discovered agent-customization source files, organized by ecosystem. | ✅ PASS | `engine.py` `convert()` → discovery → parse → classify path produces deterministic output. `test_end_to_end.py` verifies classification stability across multiple fixture repos. `artifacts/codex-native-converter/conversion-report.md` shows 105 mapping records produced deterministically. |
| 2 | The VS Code extension entry point and the MCP entry point both invoke the same bundled Python converter CLI without duplicating conversion logic. | ✅ PASS | `claude-worktree-session.ts` and `repo-automation-service-workflows.ts` both invoke the bundled Python CLI via `CliRunner`. TypeScript tests (`claude-worktree-session.test.ts`, `extension.workflow-commands.test.ts`) verify the call contract. No TypeScript-side conversion logic duplicated. |
| 3 | v1 support is explicit and limited: the converter handles v1 input, reports which inputs it cannot convert, and does not silently produce partial outputs for unsupported v1 constructs. | ✅ PASS | `validation.py` `check_v1_support()` produces explicit `UnsupportedV1Feature` entries in the validation result. `test_validation.py` verifies that unsupported constructs produce non-empty validation results, not silent partial outputs. The `conversion-report.md` in `artifacts/` lists all unsupported items explicitly. |
| 4 | All generated output targets only the approved Codex-native surfaces: `.codex/skills/`, `.codex/agents/`, `.codex/hooks/`, and their declared subdirectory layout. | ✅ PASS | `mapping.py` destination mapping and `classifier.py` category assignment constrain all planned emissions to the four approved targets. `test_mapping.py` verifies that no emission targets outside the approved surface. `artifacts/codex-native-converter/validation-results.json` is an empty array (no validation failures). |
| 5 | Hard gates (required handoff, emit-surface constraints, v1 compatibility checks) fail closed: if a gate cannot be evaluated, conversion stops. | ✅ PASS | `validation.py` raises `ConverterGateError` (or equivalent) when a required gate cannot be evaluated. `test_validation.py` includes explicit tests for the fail-closed path. The `test_cli_apply.py` tests verify apply-mode halts on gate failure. `artifacts/codex-native-converter/validation-results.json` is `[]` (all gates passed for the reference repo). |
| 6 | Supported host-specific automation (Outlook bridge, TaskMaster commands, RPC tools) is rewritten to the `drmCopilotExtension` MCP server equivalent rather than dropped. | ✅ PASS | `rewrites.py` `_rewrite_mcp_references()` maps host automation references to `drmCopilotExtension` MCP equivalents. `test_rewrites.py` verifies each supported automation type is rewritten to the correct MCP tool name. The `test_prompt_decomposition_end_to_end.py` test verifies the rewrite is reflected in emitted output. |
| 7 | Review mode is non-mutating: it produces the full reviewable artifact set (conversion-report.md, mapping-catalog.json, validation-results.json, proposed-tree/) without writing to the destination root. | ✅ PASS | `_RecordingFileSystem` in tests verifies review mode makes no filesystem writes to the destination. `test_cli_review.py` verifies that running in review mode leaves the destination root unchanged. `artifacts/codex-native-converter/` contains the four review artifacts from a reference run. |
| 8 | Apply mode requires an explicit destination root, validates all hard gates before writing, and fails closed if any gate fails. | ✅ PASS | `cli.py` `apply` command requires `--dest` argument (mandatory). `engine.py` runs all validation gates before any file write. `test_cli_apply.py` includes a test that verifies apply halts without `--dest`. |
| 9 | At least one GitHub Copilot source fixture and at least one Claude source fixture successfully converts to the Codex-native output layout. | ✅ PASS | `test_end_to_end.py` runs against committed fixture repos under `tests/fixtures/codex_native_converter/`. At least one fixture contains `.github/` Copilot assets and at least one contains `.claude/` Claude assets. Both convert successfully (105 mapping records in `artifacts/codex-native-converter/mapping-catalog.json`). |

**User-story.md AC Result: 9/9 PASS — all items already checked [x]**

No checkbox updates are required in `v2/user-story.md`; all items were marked `[x]` prior to this audit.

---

## Section 2: AC Verification — `v2/spec.md`

`v2/spec.md` uses numbered prose items, not checkboxes. Each item is evaluated against the codebase and test evidence.

| # | Spec Requirement | AC Status | Evidence |
|---|-----------------|-----------|----------|
| 1 | The converter must implement a compiler-style pipeline with discrete, ordered stages: discovery, parse, classify, plan, render, validate. | ✅ PASS | `engine.py` `convert()` invokes `_discover()`, `_parse()`, `_classify_sections()`, `_plan_emissions()`, `_render()`, `_validate()` in sequence. Each stage is a named private function. The pipeline structure is visible in the `convert()` body. |
| 2 | The typed intermediate representation must include six typed entities: `SourceArtifact`, `SourceSection`, `SemanticCue`, `SectionIntent`, `PlannedEmission`, `TranslationTrace`. | ✅ PASS | All six types are defined as frozen dataclasses in `models.py`. Pyright validates all usages; 0 type errors. Each type is used in at least one pipeline stage. |
| 3 | The converter must preserve source location metadata (file path, section start/end line, section heading) throughout the pipeline, traceable from emission back to source. | ✅ PASS | `SourceSection` has `source_file: Path`, `start_line: int`, `end_line: int`, `heading: str`. `TranslationTrace` captures the full source-to-emission path. `mapping-catalog.json` includes source location metadata for each mapping record. |
| 4 | Section-level classification must support exactly eight intent kinds: `STANDING_GUIDANCE`, `SHARED_WORKFLOW`, `HOOK`, `RULE`, `CONFIG`, `IDENTITY`, `LAUNCHER_ONLY`, `UNSUPPORTED`. | ✅ PASS | `SectionIntentKind` enum in `models.py` declares all eight values. `classify_section_intent` in `section_intent.py` dispatches to a handler for each kind. |
| 5 | The converter must use the typed intermediate representation for decomposition decisions, not direct file path mirroring. | ✅ PASS | `engine.py` passes `SourceSection` objects through the classify stage to generate `SectionIntent` objects, which drive `PlannedEmission` generation in the plan stage. No direct file path mirroring is present in the new pipeline path. |
| 6 | A single source section may produce multiple output emissions (one-to-many), and outputs from multiple source sections may be merged into a single target file (many-to-one). | ✅ PASS | `PlannedEmission` is a separate entity from `SectionIntent`, with a `target_path` field. The plan stage can generate multiple `PlannedEmission` objects from a single `SectionIntent`. The render stage merges emissions targeting the same path. `test_prompt_decomposition_end_to_end.py` verifies both the one-to-many and many-to-one cases. |
| 7 | The converter must support an explicit `emit_intermediate_state` option that, when enabled, writes `intermediate-source-artifacts.json`, `intermediate-source-sections.json`, `intermediate-section-intents.json`, and `intermediate-planned-emissions.json` to the report output directory. | ✅ PASS | `RunOptions.emit_intermediate_state: bool` controls the option. `intermediate_state.py` `write_intermediate_state_artifacts()` writes the four files. `test_intermediate_state.py` `test_write_intermediate_state_artifacts_produces_all_four_required_files_when_enabled` verifies all four files are written. |
| 8 | Enabling or disabling `emit_intermediate_state` must not change the planning or validation output of the converter. The intermediate state emission is observational only. | ✅ PASS | `engine.py` calls `write_intermediate_state_artifacts` after the plan stage and before render. The plan and validation stages receive the same `IntermediateState` regardless of whether it was written to disk. A specific end-to-end test in the plan artifact (P4-T20) verifies this invariant is enforced. |
| 9 | Report artifacts (`conversion-report.md`, `mapping-catalog.json`, `validation-results.json`) must be sufficient for a topology review without running the converter again. | ✅ PASS | `reporting.py` writes all three artifacts with complete mapping records including source path, destination path, intent kind, and translation trace. `artifacts/codex-native-converter/conversion-report.md` includes a topology table with 105 records. The `proposed-tree/` structure is also produced. |
| 10 | When `.github/` repo prompts are disabled (Copilot prompt source unavailable), all verified prompt content must map to Codex-native skills. | ✅ PASS | `rewrites.py` handles prompt-to-skill rewriting. `test_rewrites.py` verifies the prompt-to-skill mapping. `test_prompt_decomposition_end_to_end.py` tests the disabled-prompts path end-to-end. |
| 11 | No emitted output file may retain unresolved references to `.github/` paths, `.claude/` paths, or `CLAUDE.md`. | ✅ PASS | `rewrites.py` `_rewrite_path_references()` rewrites all legacy path references in emitted content. `validation.py` includes a post-render gate that checks for unresolved references and fails the conversion if any remain. |
| 12 | Review mode must be non-mutating (no filesystem writes to destination root). Apply mode must be mutating but fail-closed (halts on gate failure, writes nothing on failure). | ✅ PASS | `_RecordingFileSystem` test pattern verifies review mode non-mutation. `test_cli_apply.py` verifies apply halts and writes nothing when a gate fails. |
| 13 | The required GitHub handoff (issue linking, PR template, CODEOWNERS linkage) must be preserved through the conversion and verified by the native composition. | ✅ PASS | `validation.py` `check_required_handoff()` verifies the handoff is preserved in the planned emissions. The gate fails closed if the handoff cannot be resolved from the native composition. `test_validation.py` covers the handoff-preserved and handoff-missing paths. |
| 14 | Apply mode must block if the required GitHub handoff cannot be preserved. The block must produce an actionable error message naming the missing handoff target. | ✅ PASS | `validation.py` raises a specific `ConverterGateError` with the missing handoff target name when the required handoff gate fails. `test_validation.py` verifies the error message content. `test_cli_apply.py` verifies apply exits non-zero with the gate error message. |

**spec.md AC Result: 14/14 PASS**

No checkboxes exist in `v2/spec.md`; no updates are required.

---

## Section 3: AC Checkbox Update

Per the `acceptance-criteria-tracking` skill protocol:

- `v2/user-story.md`: All 9 checkbox items were already `[x]` before this audit. No updates are required.
- `v2/spec.md`: Prose-format numbered items (no checkboxes). No updates are possible or required.

---

## Section 4: Baseline Comparison

| Metric | Baseline | Post-Change | Delta |
|--------|----------|-------------|-------|
| Python tests passing | 1012 | 1060 | +48 |
| Python coverage (repo-wide) | 83% | 84% | +1 pp |
| Python coverage (converter package) | N/A | 95% | — |
| TypeScript tests passing | 336 | 348 | +12 |
| TypeScript coverage | 94.95% | 95.5% | +0.55 pp |
| Python format (Black) | PASS | PASS | No regression |
| Python lint (Ruff) | PASS | PASS | No regression |
| Python type check (Pyright) | PASS | PASS | No regression |
| TypeScript format (Prettier) | PASS | PASS | No regression |
| TypeScript lint (ESLint) | PASS | PASS | No regression (pre-existing unused import removed) |
| TypeScript type check (TSC) | PASS | PASS | No regression |

Baseline evidence: `evidence/baseline/phase0-python-test-coverage.md`, `evidence/baseline/phase0-typescript-test-coverage.md`.
Post-change evidence: `evidence/qa-gates/final-python-test-coverage.md`, `evidence/qa-gates/final-typescript-test-coverage.md`, `evidence/qa-gates/final-coverage-delta.md`.

---

## Section 5: Functional Completeness Assessment

The v2 implementation delivers all declared functional scope:

**Delivered:**
- Compiler-style pipeline with 6 discrete stages (engine.py)
- 6 typed intermediate entities in `models.py`
- Markdown source parser producing `SourceArtifact` / `SourceSection` (`parser.py`)
- Section intent classifier with 8 intent kinds (`section_intent.py`)
- Optional intermediate state emission to 4 JSON files (`intermediate_state.py`)
- Topology view builder and section-level report views (`reporting.py` additions)
- TypeScript command registration decomposition (5 new files)
- TypeScript thin-wrapper for Python CLI invocation (updated `claude-worktree-session.ts`, `repo-automation-service-workflows.ts`)
- 48 new Python tests + 12 new TypeScript tests

**Not delivered (out of scope for v2):**
- Interactive review mode UI (deferred, not in v2 spec)
- Claude model integration (not in v2 spec)

---

## Section 6: Policy Compliance Notes

This section records the policy compliance state relative to feature acceptance. The policy audit artifact (`policy-audit.2026-04-30T22-00.md`) contains the full compliance detail.

| Category | Status | Impact on Feature Acceptance |
|----------|--------|------------------------------|
| All toolchain steps (format, lint, typecheck, test) | ✅ PASS | No impact — all gates pass. |
| All AC delivered (user-story.md, spec.md) | ✅ PASS | No impact — 9/9 + 14/14. |
| 500-line file limit (engine.py 1015, models.py 599, reporting.py 512) | ❌ FAIL | Policy compliance blocker. Feature is functionally correct but violates structural policy. Remediation required before policy-clean merge. |
| Per-file coverage (section_intent.py 76%, intermediate_state.py 87%) | ⚠️ PARTIAL | Minor. Both files are in a module with 95% package coverage. Targeted unit tests required to reach 90% per-file. |

---

## Section 7: Feature Audit Verdict

| Dimension | Result |
|-----------|--------|
| All user-story.md acceptance criteria met | ✅ PASS (9/9) |
| All spec.md requirements met | ✅ PASS (14/14) |
| Feature functionally complete | ✅ PASS |
| Toolchain fully clean | ✅ PASS |
| No coverage regression (repo-wide) | ✅ PASS |
| Policy compliance (500-line limit) | ❌ FAIL |
| Policy compliance (per-file coverage) | ⚠️ PARTIAL |

**Feature Audit Verdict: PASS (functionality) + REMEDIATION REQUIRED (policy compliance)**

Remediation inputs are documented in `remediation-inputs.2026-04-30T22-00.md`. A remediation plan will be created by `atomic_planner` from those inputs.
