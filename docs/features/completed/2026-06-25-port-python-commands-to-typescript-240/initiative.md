# port-python-commands-to-typescript - Initiative Overview

- Issue: #240
- Owner: drmoisan
- Last Updated: 2026-06-25T22-19

## Goal & Outcomes

Port every Python command script invoked by the VS Code extension and the standalone
MCP server to TypeScript, with behavior parity and equally robust automated tests, so
that neither the extension nor the published MCP npm package requires a Python
interpreter at runtime.

Measurable outcomes:

- The 12 runtime-invoked MCP commands execute via in-process TypeScript, not by spawning
  Python.
- The `"python"` runtime branch in `command-runtime.ts` and the bundled Python resources
  are removed.
- TypeScript test coverage meets repository policy (line >= 85%, branch >= 75%).

Authoritative scope and inventory: `research/python-to-typescript-inventory.md`.

## Decomposition (Child Features/Workstreams)

Ordered, independently shippable features (each one branch + PR + green CI + merge):

- F1 `ts-shared-subprocess-and-utility-layer` (Issue #240) — shared subprocess runner,
  prompt-mode contract, json-config, markdown-label-formatter. Prereq for all.
- F2 `ts-validate-orchestration-artifacts` (Issue #240) — validate_* cluster. Prereq: F1.
- F4 `ts-collect-commit-context` (Issue #240) — self-contained git context. Prereq: F1.
- F5 `ts-resolve-prompts` (Issue #240) — hard-lock and file prompt resolvers. Prereq: F1.
- F6 `ts-new-potential-bug-entry` (Issue #240) — bug entry creator. Prereq: F1.
- F3 `ts-push-down-customizations` (Issue #240) — copilot/codex/claude push-down. Prereq: F1.
- F7 `ts-potential-to-issue` (Issue #240) — potential→issue promotion (gh). Prereq: F1.
- F8 `ts-new-active-feature-folder` (Issue #240) — active folder creation (gh). Prereq: F1.
- F9 `ts-pr-context` (Issue #240) — full PR context cluster (git + gh). Prereq: F1.
- F10 `ts-codex-native-converter` (Issue #240) — converter pipeline. Prereq: F1.
- F11 `ts-command-runtime-cleanup` (Issue #240) — remove Python bridge + bundled resources.
  Prereq: F2–F10 complete.

Dependencies: F1 → {F2, F3, F4, F5, F6, F7, F8, F9, F10} → F11.

## Cross-Cutting Constraints & Assumptions

- TypeScript ports live under `extensions/drm-copilot/src/lib/**`; tests mirror under
  `extensions/drm-copilot/test/lib/**`.
- 500-line file size limit applies; files over the limit in Python are split in TS
  (noted per feature in the research doc).
- Subprocess (`git`/`gh`) access goes through an injectable `SubprocessRunner`; filesystem
  access goes through an injectable `FileSystem` interface to keep unit tests hermetic
  (no temp files, no real subprocess).
- The `RepoAutomationService` interface is unchanged; only `DefaultRepoAutomationService`
  method bodies switch from `executeScript()` to in-process TS calls.
- Behavior parity must be preserved: CLI output, exit codes, file artifacts, JSON shapes.

## Milestones & Status

- M1 F1 shared utilities — In progress
- M2 F2–F10 cluster ports — Not started
- M3 F11 Python bridge removal — Not started
- M4 No Python runtime dependency for extension/MCP commands — Not started

## Initiative-Level Validation

- End-to-end: each ported MCP command produces output identical to its Python predecessor.
- Integration: extension and MCP server tests pass without a Python interpreter.
- Determinism/Regression: ported pure functions covered by unit (and where applicable
  property-based) tests; no coverage regression.
- Error handling/Resilience: error messages, exit codes, and failure modes match the
  Python originals.

## Notes / Follow-Ups

- Out of scope (dev-internal Python tooling, not bundled/invoked by extension or MCP):
  `fix_all*`, `shell_qc`, `copy_research_to_issue`, `clean_devcontainer`,
  `plan_progress_report`, `atomic_executor/**`, `resolve_execute_plan_prompt.py` (tkinter),
  `tk_dialog_helpers.py`. Rationale recorded in `research/python-to-typescript-inventory.md`
  Section 3.2.
- `agentic_sync.ROOT_FOLDERS` constant is inlined into the push-down TS port; the rest of
  `agentic_sync.py` is not ported.
