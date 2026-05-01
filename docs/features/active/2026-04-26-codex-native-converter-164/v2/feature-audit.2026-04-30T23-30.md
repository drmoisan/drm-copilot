# Feature Audit: codex-native-converter v2 (#164) — Post-Remediation Acceptance Verification

---

**Audit Date:** 2026-04-30
**Feature Folder:** `docs/features/active/2026-04-26-codex-native-converter-164`
**Base Branch:** `development`
**Head Branch:** `feature/20260429090101-port-codex-skill`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `development` (commit `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`)
- **Head branch/commit:** `feature/20260429090101-port-codex-skill` (commit `2a33fe3a2da5ac178236aa318e1f199d90f076eb` plus remediation commits)
- **Merge base:** `d38105a034a98ec56fe80bcfcf7b69ef01988b0b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (refreshed for this re-audit)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/`
  - Remediation closure: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/remediation/remediation-closure.md`
- **Feature folder used:** `docs/features/active/2026-04-26-codex-native-converter-164`
- **Requirements source:** `v2/spec.md` and `v2/user-story.md` (primary); `v1/user-story.md` (secondary, material change confirmed in PR context)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`. Per the acceptance-criteria-tracking skill, `full-feature` means `spec.md` **and** `user-story.md`. The v2 scoping documents are used as the authoritative AC source for v2 delivery validation. The v1 user-story AC (all [x] in PR context) is confirmed as a secondary reference.
- **Scope note:** This audit covers v2 feature delivery plus R1–R5 remediation. v2/spec.md uses numbered AC items (prose format, not checkboxes); they are transcribed faithfully below. v2/user-story.md uses checkbox format.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-26-codex-native-converter-164/v2/spec.md` — primary (v2 delivery scope)
- `docs/features/active/2026-04-26-codex-native-converter-164/v2/user-story.md` — primary (v2 delivery scope)

**Format note:** `v2/spec.md` uses a numbered list for acceptance criteria (not markdown checkboxes). Items are transcribed below without reformatting, per the acceptance-criteria-tracking skill. Status is recorded in the evaluation table only.

### From v2/spec.md (numbered requirements, not checkbox format)

1. The converter must implement a compiler-style pipeline with explicit discovery, parse, classify, plan, render, and validate stages.
2. The converter must parse supported mixed-concern source files into a typed intermediate representation that includes `SourceArtifact`, `SourceSection`, `SemanticCue`, `SectionIntent`, `PlannedEmission`, and `TranslationTrace`.
3. The intermediate representation must preserve enough source location and semantic evidence to explain every emitted target and every blocking validation failure.
4. Section-level classification must support at least these intent kinds: `identity`, `standing_guidance`, `shared_workflow`, `hook_candidate`, `rule_candidate`, `config_candidate`, `launcher_only`, and `unsupported`.
5. The converter must use the intermediate representation, not direct file mirroring, as the basis for decomposition of mixed-concern source files.
6. The converter must allow one source file to emit multiple native outputs and allow multiple sections from one source file to merge into one native output when that merge is deterministic and validated.
7. The converter must support an explicit option to expose the intermediate compiler-like state into the artifact root in deterministic machine-readable files.
8. Disabling intermediate-state exposure must not change planning, validation, or emitted runtime content.
9. The emitted report artifacts must remain sufficient to review source-to-destination topology, section-level mappings, validation findings, and proposed output content.
10. When repository prompt launchers are disabled, verified prompt content that corresponds to existing native concepts must still map to native skills, hooks, or other approved native surfaces rather than remaining as unresolved source-runtime references.
11. No emitted runtime output may retain unresolved `.github`, `.claude`, `CLAUDE.md`, raw host command IDs, or repository-local script references when a verified native rewrite or fallback mapping exists.
12. Review mode must remain non-mutating with respect to the destination root, and apply mode must still fail closed on any blocking validation finding.
13. Required GitHub handoff and delegation behavior must be preserved through verified native composition using subagents, skills, hooks, rules, and required configuration rather than being downgraded to advisory prose.
14. The converter must block apply mode if any required GitHub handoff cannot be preserved through those verified native mechanisms.

### From v2/user-story.md (checkbox format, all checked [x] in PR context)

- [x] A maintainer can run the converter against a supported GitHub Copilot or Claude source tree and receive deterministic classification for every examined artifact as `direct`, `decomposed`, `repo-convention`, or `unsupported`, plus a concrete target role.
- [x] The extension and MCP entry points invoke the same bundled Python converter contract.
- [x] v1 support is explicit and limited to documented GitHub Copilot and Claude source surfaces; unsupported ecosystems or unsupported files within those ecosystems are reported explicitly instead of inferred or silently dropped.
- [x] Generated outputs target only approved Codex-native surfaces such as `AGENTS.md`, `.agents/skills/**`, `.codex/agents/**`, `.codex/config.toml`, `.codex/hooks/**` or native hook configuration, `.codex/rules/**`, and repository-specific `.codex/prompts/**` only when that repository-convention output is intentionally enabled.
- [x] Hard gates and handoff-related behavior remain fail-closed and non-discretionary: if the converter cannot map them to verified Codex-native enforcement or delegation mechanisms, apply mode stops and records a blocking validation failure.
- [x] When a supported host-specific automation mapping exists, the converter rewrites it to the repository's semantic MCP usage model on server `drmCopilotExtension`; when no safe rewrite exists, the converter reports the gap and does not emit a misleading replacement.
- [x] Review mode is non-mutating and always produces a reviewable artifact set that includes `conversion-report.md`, `mapping-catalog.json`, `validation-results.json`, and a `proposed-tree/` snapshot.
- [x] Apply mode requires an explicit destination root, writes the approved Codex-native outputs plus the same report artifacts, and fails closed when required inputs, mappings, or native enforcement equivalents are missing.
- [x] At least one representative GitHub Copilot fixture and one representative Claude fixture can be converted into reviewable v1 outputs, and the result preserves reusable guidance in shared skills rather than flattening duplicated text across agents or prompts.

---

## Acceptance Criteria Evaluation

### From v2/spec.md

| # | Criterion (abbreviated) | Status | Evidence | Verification command(s) | Notes |
|---|-------------------------|--------|----------|--------------------------|-------|
| 1 | Compiler-style pipeline with explicit discovery, parse, classify, plan, render, validate stages | PASS | `engine.py` orchestrates stages in sequence: `discover` (inventory), `parse` (parser.py), `classify` (classifier.py + section_intent.py), `plan` (mapping.py), `render` (rewrites.py), `validate` (validation.py). Stage dispatch is linear and explicit. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/ -q` | Verified in `engine.py` (499 lines) and through end-to-end tests. |
| 2 | Typed IR with SourceArtifact, SourceSection, SemanticCue, SectionIntent, PlannedEmission, TranslationTrace | PASS | All six entity types are defined in `models.py` and `models_intermediate.py` as frozen dataclasses with full type annotations. `parser.py` populates `SourceArtifact` and `SourceSection`. `section_intent.py` produces `SectionIntent`. Engine stages produce `PlannedEmission` and `TranslationTrace`. | `poetry run pyright` (0 errors); inspection of `models.py` and `models_intermediate.py` | PR context: `models.py` +212 lines in v2 delivery. |
| 3 | IR preserves source location and semantic evidence for every emitted target and blocking failure | PASS | `SourceArtifact` carries `source_path` and `source_ecosystem`. `SourceSection` carries `heading`, `body_lines`, and `cues`. `TranslationTrace` links source section to emitted target with `intent_kind`, `target_path`, and `trace_notes`. `PlannedEmission` carries `blocking_reason` when validation fails. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_reporting.py -q` | Verified through reporting end-to-end tests. |
| 4 | Section classification supports identity, standing_guidance, shared_workflow, hook_candidate, rule_candidate, config_candidate, launcher_only, unsupported | PASS | All eight `SectionIntentKind` enum variants exist in `section_intent.py`. `classify_section_intent` produces each variant deterministically. R4 tests verify each variant path. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_section_intent.py -v` | R4 evidence: `evidence/remediation/r4-coverage-checkpoint.md`; `section_intent.py` 100%. |
| 5 | Converter uses IR (not direct file mirroring) for decomposition | PASS | `engine.py` parses to `SourceArtifact`/`SourceSection`, then runs classification before target path resolution. No direct `shutil.copy` or file-mirroring path exists in the converter codebase. Decomposition decisions are driven by `SectionIntent.intent_kind`. | Inspection of `engine.py` pipeline dispatch; `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_prompt_decomposition_end_to_end.py -q` | End-to-end decomposition test confirms IR-driven output. |
| 6 | One source file may emit multiple native outputs; multiple sections may merge into one output | PASS | `PlannedEmission` carries a list of `target_paths` enabling multi-output. The merge path in `engine.py` applies when sections share a canonical target and their merge is deterministic. Tested by `test_prompt_decomposition_end_to_end.py`. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_prompt_decomposition_end_to_end.py -q` | PR context: test file +142 lines. |
| 7 | Explicit option to expose intermediate compiler-like state into artifact root | PASS | `RunOptions.emit_intermediate_state` controls exposure. When enabled, `intermediate_state.py` writes `source_artifacts.json`, `section_intents.json`, `planned_emissions.json`, and `translation_traces.json` into the artifact root. Tested in `test_intermediate_state.py`. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_intermediate_state.py -v` | R5 evidence: `evidence/remediation/r5-coverage-checkpoint.md`; `intermediate_state.py` 100%. |
| 8 | Disabling intermediate-state exposure must not change planning, validation, or emitted runtime content | PASS | The `emit_intermediate_state` flag is evaluated only after the pipeline completes. The pipeline stages do not branch on this flag; it is read only by `write_intermediate_state_artifacts`. Verified by comparing end-to-end fixture output with and without the flag. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/ -q` | Design verified in `engine.py` orchestration; flag isolation confirmed. |
| 9 | Emitted report artifacts sufficient for topology, mappings, validation findings, proposed output review | PASS | `reporting.py` produces `conversion-report.md` (narrative), `mapping-catalog.json` (source-to-target mappings), `validation-results.json` (blocking and non-blocking findings), and `proposed-tree/` snapshot. Topology section in `conversion-report.md` is generated by `_reporting_topology.py`. Tested by `test_reporting_topology_end_to_end.py`. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_reporting_topology_end_to_end.py -q` | PR context: topology test +108 lines. |
| 10 | When prompt launchers disabled, verified prompt content maps to native skills/hooks/surfaces | PASS | `classifier.py` maps LAUNCHER_ONLY sections to `rule_candidate` or `hook_candidate` when the content has a verified native equivalent. When no native equivalent exists, the section is classified as `unsupported` rather than emitting a prompt file. This behavior is gated on `RunOptions.enable_prompt_output`. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/ -q` | Classifier behavior verified in end-to-end tests with `enable_prompt_output=False`. |
| 11 | No emitted output retains unresolved .github, .claude, CLAUDE.md, raw command IDs, or script refs | PASS | `rewrites.py` (`+249/-6` in v2) applies the MCP rewrite catalog and host-reference scrubbing. Validation fails closed when a rewrite cannot be resolved. End-to-end fixture outputs are inspected in `test_end_to_end.py` for retained source-runtime references. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_rewrites.py -q` | PR context: test_rewrites.py +118 lines. |
| 12 | Review mode non-mutating; apply mode fails closed on blocking validation | PASS | Review mode uses `_RecordingFileSystem` which records but does not write. Apply mode gated by `validation.py`; `run_validation_pass` raises `ConverterBlockingError` on blocking findings before any output is written. Tested in `test_cli_apply.py` and end-to-end tests. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py -q` | Verified from both CLI and MCP entry points. |
| 13 | Required GitHub handoff/delegation preserved through verified native composition | PASS | `classifier.py` maps agent handoff patterns to `hook_candidate` (for PreToolUse/SubagentStop), `rule_candidate` (for shell enforcement), and standing guidance (for subagent delegation in `AGENTS.md`). The mapping catalog records each transformation. Verified in `test_end_to_end.py` GitHub Copilot fixture conversion. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py -q` | End-to-end test exercises GitHub Copilot fixture. |
| 14 | Converter must block apply mode if GitHub handoff cannot be preserved through verified mechanisms | PASS | `validation.py` enforces this via the `UNRESOLVED_HANDOFF_NATIVE_EQUIVALENT` blocking failure code. Tested in `test_validation.py` and `test_cli_apply.py`. Apply mode stops at first blocking failure without writing partial output. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_validation.py tests/scripts/dev_tools/codex_native_converter/test_cli_apply.py -q` | Fail-closed behavior confirmed. |

### From v2/user-story.md

| # | Criterion (abbreviated) | Status | Evidence | Verification command(s) | Notes |
|---|-------------------------|--------|----------|--------------------------|-------|
| US-1 | Deterministic classification of every artifact (direct/decomposed/repo-convention/unsupported + target role) | PASS | `classifier.py` produces a `ConversionClass` and `TargetRole` for every artifact. Classification is deterministic (no random input; cue-driven dispatch only). PR context shows all v2 user-story AC as [x]. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/ -q` | All AC [x] in PR context for v2/user-story.md. |
| US-2 | Extension and MCP entry points invoke same Python converter contract | PASS | TypeScript `mcp-handlers/codex-native-converter-handlers.ts` delegates to `ConverterHandler.run_review` / `run_apply` which invoke the Python CLI subprocess. The same `engine.py` pipeline runs for both entry points. | `npm --prefix extensions/drm-copilot run test:unit` | TypeScript handler coverage 100% per `final-typescript-coverage-delta.md`. |
| US-3 | v1 support limited to documented GitHub Copilot and Claude surfaces; unsupported reported explicitly | PASS | `inventory.py` enumerates only the documented source file patterns. Unsupported files within a supported ecosystem produce a `ConversionClass.UNSUPPORTED` record. Unsupported ecosystems stop the run with a blocking validation failure. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py -q` | Verified via end-to-end tests. |
| US-4 | Outputs target only approved Codex-native surfaces; no duplicated shared guidance | PASS | `mapping.py` maps only to approved target paths. `validation.py` rejects duplicate target-path collisions. Shared guidance is placed in skills, not duplicated across agents. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py -q` | Verified via GitHub Copilot and Claude fixture outputs. |
| US-5 | Hard gates fail-closed; apply mode stops when no verified Codex-native enforcement equivalent exists | PASS | See spec AC #14. Enforced by `UNRESOLVED_HANDOFF_NATIVE_EQUIVALENT` and `UNRESOLVED_HARD_GATE` blocking codes in `validation.py`. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_validation.py -q` | |
| US-6 | Supported host-specific automation rewritten to drmCopilotExtension MCP; gap reported when no safe rewrite exists | PASS | `rewrites.py` applies the MCP rewrite catalog. Missing rewrites produce a `UNRESOLVED_MCP_REWRITE` validation finding. PR context shows `rewrites.py` +249 lines in v2 delivery. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_rewrites.py -q` | |
| US-7 | Review mode non-mutating; artifact set includes conversion-report.md, mapping-catalog.json, validation-results.json, proposed-tree/ | PASS | See spec AC #12 and #9. All four artifacts produced in review mode. Apply mode also produces same artifacts plus Codex-native runtime files. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/ -q` | Verified end-to-end. |
| US-8 | Apply mode requires explicit destination root; fails closed on missing inputs/mappings/enforcement equivalents | PASS | `cli.py` enforces presence of `--dest-root` before entering apply mode. `validation.py` performs pre-write blocking check. No partial writes on blocking failure. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_cli_apply.py -q` | |
| US-9 | At least one GitHub Copilot and one Claude fixture converts to reviewable v1 outputs; shared guidance in skills | PASS | `test_end_to_end.py` exercises both fixture types. Fixture outputs are committed under `tests/fixtures/codex_native_converter/`. Shared guidance appears in a single skill output, not duplicated across generated agents. | `poetry run pytest tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py -v` | Fixture outputs visible in committed test fixture directories. |

---

## Acceptance Criteria Summary

| Source | Total AC | PASS | PARTIAL | FAIL | UNVERIFIED |
|--------|----------|------|---------|------|------------|
| v2/spec.md (numbered) | 14 | 14 | 0 | 0 | 0 |
| v2/user-story.md (checkboxes) | 9 | 9 | 0 | 0 | 0 |
| **Total** | **23** | **23** | **0** | **0** | **0** |

---

## Overall Readiness Verdict

**Verdict: PASS**

All 23 acceptance criteria across `v2/spec.md` and `v2/user-story.md` are satisfied. All five remediation items are closed. The final toolchain pass is clean (Black/Ruff/Pyright/Pytest: 1069 passed; all converter modules ≥90% coverage; 85% repo-wide coverage). No open AC items remain.

The feature is ready for PR creation and merge to `development`.
