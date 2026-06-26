# Phase 0 — Python Reference Inventory (F11)

Timestamp: 2026-06-26T09-01

## Search (1): TypeScript references

Command: `rg -n 'runtimeKind|"python"|hello_python|detectRuntime\("python"\)' extensions/drm-copilot/src extensions/drm-copilot/test`
SearchScope: `extensions/drm-copilot/src`, `extensions/drm-copilot/test`
SearchPatterns: `runtimeKind`, `"python"`, `hello_python`, `detectRuntime("python")`

Relevant `runtimeKind: "python"` assignments and the Python runtime branch (removal targets):
- `src/extension.ts:86` — `runtimeKind: "python"` (helloPython spawn) → P1-T2
- `src/extension.ts:87` — `bundledRelativePath: "resources/templates/hello_python.py"` → P1-T2
- `src/command-runtime.ts:9` — `export type RuntimeKind = "python" | "powershell"` → P2-T1
- `src/command-runtime.ts:183-204` — `if (runtimeKind === "python") { ... }` branch (probes `python`/`py`) → P2-T2
- `src/repo-automation-service-support.ts:10` — `readonly runtimeKind: "python" | "powershell"` → P2-T3
- `src/repo-automation-service-workflows.ts:74,125,140,156` — four dead Python option builders → P3-T1

Test references to remove/rewrite (Phase 1/2):
- `test/extension.test.ts:143,151` — `detectRuntime("python")` cases → P2-T4
- `test/extension.test.ts:166,193,208,260` — bundled hello_python.py / python spawn assertions → P1-T4
- `test/extension.integration.test.ts:234,239,240,256,269` — helloPython python-spawn assertions → P1-T5
- `test/extension-test-harness.ts:381,383` — harness `detectRuntime(runtimeKind)` (type only; stays, narrows with union)

Unrelated `"python"` matches (NOT removal targets — DATA pack name and path-substring test helpers):
- `src/repo-automation-command-registration-admin.ts:129` — push-down pack label "Python" (DATA pack)
- `test/lib/push-down/*.test.ts` — push-down pack-selection tests referencing the "python" DATA pack
- `test/runtime-test-helpers.ts:30`, `test/new-active-feature-folder-fs-harness.ts:176`, `test/extension.collect-*.test.ts`, `test/extension.integration.test.ts:63,193` — path-substring matchers in mock filesystems
- All `runtimeKind: "powershell"` usages (KEPT): `extension.ts:97`, `repo-automation-service.ts:288,305,433,465`, `repo-automation-command-registration-admin.ts:288`, `repo-automation-service-support.ts` PoshQC config

## Search (2): Bundled .py files

Command: `rg --files extensions/drm-copilot/resources -g "*.py"`
SearchScope: `extensions/drm-copilot/resources`
SearchPatterns: `*.py`
SearchResult: 54 files total — 13 under `resources/templates/`, 41 under `resources/scripts/dev_tools/`.

### resources/templates/*.py (13 — removed in P4-T1)
codex_native_converter.py, collect_commit_context.py, collect_pr_context.py, hello_python.py, new_active_feature_folder.py, new_potential_bug_entry.py, potential_to_issue.py, push_down_claude_customizations.py, push_down_codex_and_agents_customizations.py, push_down_copilot_customizations.py, resolve_atomic_plan_prompt.py, resolve_hard_lock_prompt.py, validate_orchestration_artifacts.py

### resources/scripts/dev_tools/**/*.py (41 — removed in P4-T2)
__init__.py, _orchestrator_state_human_interaction.py, _orchestrator_state_routing.py, agentic_sync.py, new_active_feature_folder.py, new_active_feature_folder_docs.py, new_active_feature_folder_flow.py, new_active_feature_folder_io.py, new_active_feature_folder_markdown.py, new_active_feature_folder_models.py, new_potential_bug_entry.py, potential_to_issue.py, potential_to_issue_content.py, prompt_mode_contract.py, push_down_claude_customizations.py, push_down_claude_filesystem.py, push_down_claude_pack_selection.py, push_down_codex_and_agents_customizations.py, push_down_copilot_customizations.py, push_down_copilot_customizations_filesystem.py, push_down_copilot_customizations_rewrites.py, resolve_file_prompt.py, resolve_hard_lock_prompt.py, validate_orchestration_artifacts.py, validate_orchestration_review_artifacts.py, validate_orchestrator_state.py, validate_policy_audit_artifact.py; plus `codex_native_converter/` (__init__.py, __main__.py, cli.py) and `pr_context/` (__init__.py, collector.py, feature_docs.py, git.py, github.py, models.py, render.py, render_feature_excerpts.py, render_pr_helpers.py, summary_helpers.py, verification_evidence.py)

Note: The bundled `dev_tools` tree is broader than the modules the plan's prose enumerated; the entire tree is removed per P4-T2 ("delete the entire bundled Python dev_tools tree ... and every other module enumerated in P0-T2"). This artifact is the authoritative target list.

## Search (3): Python tests referencing bundled Python

Command: `rg -n 'extensions/drm-copilot/resources/scripts/dev_tools|extensions/drm-copilot/resources/templates/.*\.py' tests`
SearchScope: `tests`
SearchPatterns: `extensions/drm-copilot/resources/scripts/dev_tools`, `extensions/drm-copilot/resources/templates/*.py`
SearchResult (literal string matches):
- `tests/scripts/dev_tools/test_push_down_claude_bundled_parity.py:4` → removed P5-T1
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py:648` → surgically edited P5-T3
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_mirror_parity.py:18` → removed P5-T2
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt_mirror_parity.py:17` → removed P5-T1

Additional bundled-Python-dependent Python tests (reference bundled tree via constructed `Path` constants, not literal-substring; confirmed by reading):
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_bundle_parity.py` (BUNDLED_DEV_TOOLS_DIR = `extensions/drm-copilot/resources/scripts/dev_tools`) → removed P5-T1
- `tests/extensions/drm_copilot/resources/templates/**` (10 test files + `__init__.py` at each package level) load/exec bundled `resources/templates/*.py` wrappers → removed P5-T4

### tests/extensions tree (removed entirely in P5-T4)
tests/extensions/drm_copilot/__init__.py
tests/extensions/drm_copilot/resources/__init__.py
tests/extensions/drm_copilot/resources/templates/__init__.py
tests/extensions/drm_copilot/resources/templates/test_new_active_feature_folder.py
tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py
tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py
tests/extensions/drm_copilot/resources/templates/test_potential_to_issue_missing_label_regression.py
tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py
tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt_part2.py
tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py
tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt_output.py
tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt_part2.py
tests/extensions/drm_copilot/resources/templates/test_validate_orchestration_artifacts.py

Remediation note: No TS or Python references outside the files named in the plan were discovered. All discovered references map to a plan removal/edit task above.
