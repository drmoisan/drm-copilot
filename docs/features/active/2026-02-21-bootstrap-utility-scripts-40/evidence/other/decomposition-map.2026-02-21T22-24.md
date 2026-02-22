# Decomposition Map (Phase 2)

Timestamp: 2026-02-22T00:04:05-05:00

## Targets and planned module boundaries

1. `atomic_executor/cli.py` (current lines: 2327)
   - Extract argument parsing and validation helpers.
   - Extract preflight validation-only flow orchestration.
   - Extract task execution loop and progress rendering.
   - Keep `cli.py` as a thin command entrypoint/wiring layer.

2. `new_active_feature_folder.py` (current lines: 1190)
   - Extract template selection and destination resolution.
   - Extract metadata/work-mode marker rendering logic.
   - Extract filesystem copy/create operations and post-create open actions.
   - Keep `new_active_feature_folder.py` as orchestration entrypoint.

3. `fix_all.py` (current lines: 944)
   - Extract status-board rendering and terminal capability helpers.
   - Extract branch-runner implementations (json/shell/python/powershell).
   - Extract command-step utility helpers for retries and failure reporting.
   - Keep `fix_all.py` as CLI argument + top-level orchestrator.

4. `atomic_executor/qc_runner.py` (current lines: 897)
   - Extract QC command-plan construction by language/toolchain.
   - Extract result parsing and summarize/report helpers.
   - Extract retry/cancellation behaviors.
   - Keep `qc_runner.py` focused on coordinator API.

5. `potential_to_issue.py` (current lines: 762)
   - Extract issue body construction and template adaptation.
   - Extract GitHub CLI command assembly/execution wrappers.
   - Extract work-mode validation and marker persistence helpers.
   - Keep `potential_to_issue.py` as promotion workflow entrypoint.

6. `pr_context/render.py` (current lines: 615)
   - Extract section-specific renderers (intent/base-head/issues/pr-digests).
   - Extract formatting helpers for tables/lists/stat blocks.
   - Keep `render.py` as deterministic document assembly facade.
