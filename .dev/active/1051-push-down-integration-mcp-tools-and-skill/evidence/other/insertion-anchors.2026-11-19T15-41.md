# Insertion Anchors and Test Classification — Issue #1051 [P0-T2]

Timestamp: 2026-11-19T15-41
Command: Read and Grep over `docs/engineering/process-reductions/` (13 ledger entries, 5 stored patches), the anchor files, `extensions/drm-copilot/test/` and `tests/`; `wc -l` for physical line counts
EXIT_CODE: 0
Output Summary: anchors (a) to (i) OUTSIDE every patch hunk with context and every quoted `Current` region; projected `jest.config.cjs` 683 lines; Result: CLEAR.

## Ledger regions read

- Patches touching anchor files: `0010-early-dependent-starts.patch` hunks in `extensions/drm-copilot/jest.config.cjs` (around the `epic-orchestrator-state-wave-barrier.ts` entry, mid-map), Claude `pack-manifests/core.json` (`.claude/hooks/enforce-epic-*` region) and Codex `pack-manifests/core.json` (`.codex/hooks/enforce-epic-*` region); `0001-parallel-only-test-gates.patch` and `0006-test-suite-baseline-restored.patch` hunks in the six execution-environment brief copies, and `0001` in `.agents/skills/repo-automation-adapter/SKILL.md` (`Required tools:` PoshQC list) and its bundle copy.
- Quoted `Current` regions in `## MCP Surfaces Run the Installed Extension`: the `Concurrent checkpoints (#1097)` bullet (`0002-concurrent-review.md`) and the `Light remediation checkpoints (#1097)` bullet (`0003-light-remediation.md`); `0008-g13-guideline-cutoff.patch` quotes the `LIGHT-ROUTE` Pester row only. The docs-tools bullet is not quoted.

## Anchors

| Anchor | Location | Recorded value | Verdict |
|---|---|---|---|
| (a) | `extensions/drm-copilot/jest.config.cjs` after the final `coverageThreshold` entry | final key `./src/lib/push-down/push-down-ci-layer.ts` | OUTSIDE |
| (b) | Claude `pack-manifests/core.json` between `.claude/skills/pr-context-artifacts/SKILL.md` and `.claude/skills/quota-throttling/SKILL.md` | adjacent entries present | OUTSIDE |
| (c) | Codex `pack-manifests/core.json` between `.agents/skills/policy-compliance-order/SKILL.md` and `.agents/skills/reconcile-parity-matrix/SKILL.md` | adjacent entries present (unused: `shared.json` is PRESENT) | OUTSIDE |
| (d) | each brief copy after the docs-tools bullet | the docs-tools bullet is the last bullet of `## MCP Surfaces Run the Installed Extension` (next heading `## CI Shape and Required Checks`) | OUTSIDE |
| (e) | `## Published MCP Tool Surface` of `.agents/skills/repo-automation-adapter/SKILL.md` after `transition_prepared_orchestration` | last list item | OUTSIDE |
| (f) | `.codex/config.toml` `enabled_tools` after `validate_orchestration_artifacts` | present in `.codex/config.toml` and its bundle copy | OUTSIDE |
| (g) | `REPO_AUTOMATION_TOOLS` after `validate_docs_artifacts` | present | OUTSIDE |
| (h) | COPILOT-CORE between `.github/skills/pr-context-artifacts/SKILL.md` and `.github/skills/reconcile-parity-matrix/SKILL.md` | both names recorded (code-point order: `pr-` before `push`, `push` before `reconcile`) | OUTSIDE |
| (i) | `EXPECTED_REPO_AUTOMATION_TOOL_NAMES` in `extensions/drm-copilot/test/mcp-server-test-service.ts` after `validate_docs_artifacts` | present | OUTSIDE |

## Counts

- Physical lines: `src/mcp-tools.ts` 478; `src/repo-automation-service.ts` 494; `src/repo-automation-service-contract.ts` 327; `src/mcp-tool-definitions.ts` 471; `src/mcp-repo-automation-tool-definitions.ts` 434; `jest.config.cjs` 637 (projected 683 after eleven four-line entries and two comment lines; below 800).
- `REPO_AUTOMATION_TOOLS` length: 49. `EXPECTED_REPO_AUTOMATION_TOOL_NAMES` length: 49.

## Test Classification

Search tokens: `push_down_report`, `pushDownReport`, `pushDownHarness`, `findCiWorkflowNameCollisions`, `assertDestinationManifestOutsideLayers`, `LAYER_ROOT_FOLDERS`, `assertManifestPathIsRootLevel`, `shared.json`, `pack-manifests`, `harness-parity-matrix`.

### ITEM (fixture yields at least one integration item)

| File | Test | Deciding fixture fact |
|---|---|---|
| `test/lib/push-down/push-down-harness.ci-workflows.test.ts` | `withholds the caller when another workflow is named CI, including in a dry run` | `build.yml` declares `name: "CI"`: `workflow-name-collision`, and the withheld caller leaves `missing-required-check` |
| same | `writes the data file exactly in reference, copy, and withheld-caller runs` | withheld fixture `build.yml` named `CI` |
| same | `reports unmanaged-conflict at a CI path even with overwriteUnmanaged true (%s)` | `unmanaged-conflict` action at the data file or the caller |
| same | `keeps an edited managed caller as conflict` | `conflict` action at the caller |
| `test/lib/push-down/push-down-harness.real-bundle.test.ts` | `keeps a local edit and reports conflict` | `conflict` at `AGENTS.md` |
| same | `first run without a manifest adopts and reports unmanaged-conflict` | `unmanaged-conflict` at `.codex/config.toml` |
| `test/lib/push-down/push-down-service-call.test.ts` | `routes conflict, unmanaged-conflict and deleted-locally lines to warnings and log` | all three actions |
| `test/push-down-wrapper-compatibility.test.ts` | `forwards overwrite_unmanaged to the harness (%s)` | declined run reports `unmanaged-conflict` |

None of these tests pins the whole apply write set or deep-equals `push_down_report`; each asserts actions, warnings or specific file texts.

### NO-ITEM (no item and no existing file)

- `push-down-harness.ci-workflows.test.ts`: every other test, including `writes no workflows path other than the caller and selected copies` (its write filter is limited to `.github/workflows/`), `dry run writes no file and no manifest` and `rejects a selection union holding both C# variants` (throws before any write).
- `push-down-harness.test.ts`: all tests (no conflict action, no workflow).
- `push-down-harness.real-bundle.test.ts`: every other test, including `second apply is a no-op (%s)` (no item, so no file is written).
- `push-down-service-call.test.ts`: every other test, including the exclusion-reporting tests (exclusion conflicts are not report actions).
- `push-down-wrapper-compatibility.test.ts`: every other test, including `keeps the pre-change result keys for a workspace_root-only call (%s)` (top-level result keys only).
- `mcp-tool-inputs.push-down-ci-workflows.test.ts`, `repo-automation-service.push-down-claude.test.ts`, `repo-automation-service.push-down-codex.test.ts`, `extension.push-down-claude-customizations.test.ts`: all tests.

### ROOT-LIST

| File | Test | Fact |
|---|---|---|
| `test/lib/push-down/push-down-ecosystem-registry.test.ts` | `accepts the destination manifest path as root-level` | declarations from `LAYER_ROOT_FOLDERS` |
| same | `rejects a layer root or root-file destination that captures the destination manifest path (%s)` | root folder `.push-down` and a root file at the manifest path |

### SET-PIN (all `derived`; no literal count or list of the skill set found)

- `test/lib/push-down/push-down-bundle-manifest-completeness.test.ts` (derived from bundle tree and manifests).
- `test/lib/push-down/push-down-shared-layer.test.ts` (real-tree case derived from `shared.json` and the matrix; its literal `SHARED_LAYER_ECOSYSTEM_EXCEPTIONS` length 3 is unaffected).
- `test/lib/push-down/claude-pack-manifest-completeness.test.ts` (derived).
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_codex_core_manifest_closure.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` (derived).
- `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`, `HarnessParityMatrix.Tests.ps1`, `tests/scripts/harness-generation/HarnessSkillMirror.Tests.ps1` (derived rule checks over the matrix).
- The `tests/scripts/claude-lib/*/*.Manifest.Tests.ps1` suites pin their own library files only and are unaffected.

Result: CLEAR
