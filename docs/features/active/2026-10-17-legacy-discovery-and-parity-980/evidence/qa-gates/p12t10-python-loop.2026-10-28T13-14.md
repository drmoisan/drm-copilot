# P12-T10 — Publisher synchronizer split: Python loop

Timestamp: 2026-10-28T13-14
Command: poetry run python -I SCRATCH/issue-980-p12t10-split.py (line-range split of scripts/dev_tools/agentic_sync.py and tests/scripts/dev_tools/test_agentic_sync.py); sh SCRATCH/issue-980-p12t10-static.sh (poetry run black, poetry run ruff check, poetry run pyright, wc -l over the seven resulting files); sh SCRATCH/issue-980-p12t10-tests.sh (poetry run pytest -q -p no:randomly --cov=scripts.dev_tools.agentic_sync --cov=scripts.dev_tools.agentic_sync_filesystem --cov=scripts.dev_tools.agentic_sync_artifacts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/p12t10-coverage.json over test_agentic_sync.py, test_agentic_sync_artifacts.py, test_agentic_sync_branches.py, test_push_down_copilot_customizations.py, test_push_down_copilot_customizations_helpers.py, test_push_down_copilot_customizations_rewrites.py, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_quality_tiers_contract_classification.py)
EXIT_CODE: 0
Output Summary: Two corrections before the clean pass: the filesystem module's annotation-only `Path` import moved into a type-checking block (Ruff TC003), and the two repository helpers that moved to the shared test-support module became public (`make_repo_paths`, `add_files`) because Pyright reports cross-module use of underscore names; their call sites in the sync tests were renamed and no assertion changed. Final pass in order: black "7 files left unchanged"; Ruff "All checks passed!"; Pyright "0 errors, 0 warnings, 0 informations"; Pytest 91 passed in 1.55s (three agentic_sync suites, three push-down customization suites, both resource-contract and both pack-manifest suites, tier classification). Coverage (JSON report): agentic_sync.py lines 93.1% (94/101) branches 88.2% (30/34), the missed lines being the `dev_tools` import fallback and the two real-adapter calls in `main`; agentic_sync_artifacts.py lines 100.0% (58/58) branches 100.0% (2/2); agentic_sync_filesystem.py lines 87.9% (29/33) branches 100.0% (6/6). Physical lines: agentic_sync.py 454 (was 820), agentic_sync_filesystem.py 239, agentic_sync_artifacts.py 213, agentic_sync_test_support.py 271, test_agentic_sync.py 150 (was 598), test_agentic_sync_artifacts.py 204, test_agentic_sync_branches.py 228.

## Files

- `scripts/dev_tools/agentic_sync.py` (454): keeps `AgenticSyncer`, `parse_args`, `main`, `ROOT_FOLDERS`, `LOGGER` and the compatibility re-exports (`__all__` lists every public name); imports the two new modules with the same `scripts.dev_tools`/`dev_tools` fallback the publisher uses; `main` resolves `Path`, `RealSyncFileSystem` and `AgenticSyncer` from this module's namespace, so the monkeypatched entry-point tests pass unchanged.
- new `scripts/dev_tools/agentic_sync_filesystem.py` (239): `SyncFileSystem` and `RealSyncFileSystem`, moved verbatim.
- new `scripts/dev_tools/agentic_sync_artifacts.py` (213): `DecisionType`, `ForceDirection`, `SyncActionPayload`, `SyncSummaryPayload`, `SyncAction`, `SyncSummary`, `build_artifact_path`, `render_sync_summary`, `write_sync_artifact`, moved verbatim.
- new `tests/scripts/dev_tools/agentic_sync_test_support.py` (271): `MemoryFile`, `InMemorySyncFileSystem` (now subclassing `agentic_sync_filesystem.SyncFileSystem`), `make_repo_paths`, `add_files`.
- `tests/scripts/dev_tools/test_agentic_sync.py` (150): the five synchronization tests, unchanged apart from the helper import.
- new `tests/scripts/dev_tools/test_agentic_sync_artifacts.py` (204): the artifact, argument, `main` and root-folder contract tests, moved verbatim and still asserting through the `agentic_sync` namespace.
- `tests/scripts/dev_tools/test_agentic_sync_branches.py` (228): imports `InMemorySyncFileSystem` and `MemoryFile` from the support module; its monkeypatch targets `agentic_sync.Path`, `agentic_sync.RealSyncFileSystem` and `agentic_sync.AgenticSyncer` are unchanged and pass.
- `scripts/dev_tools/push_down_copilot_customizations.py`: unchanged; its `ROOT_FOLDERS` import keeps resolving.

## Acceptance

- Every named file is under 500 physical lines (counts above).
- The three production modules measure at least 85% lines and 75% branches (figures above).
- The publication contract suites are unchanged and green: 91 passed across the eleven suites, including both resource-contract and both pack-manifest suites and the tier classification suite.
