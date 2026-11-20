# Preflight Fixes — Remediation Cycle 1 (Issue 1162)

Timestamp: 2026-11-14T07-52
Plan: docs/features/active/2026-11-09-cross-epic-dependencies-1162/remediation-plan.2026-11-14T07-20.md
Validator: `scripts.dev_tools.validate_orchestration_artifacts plan` (branch Python CLI) exit 0 before and after the fixes; 20 tasks, 97 physical lines.

## Fix 1 — P1-T4 | stale tool-route fact | toml bundle copy

- Defect: P1-T4 stated that `scripts/dev_tools/generate_codex_agent_variants.py` without `--check` writes the bundle copy of `.codex/agents/epic-orchestrator.toml`. `epic-orchestrator` is not in `GENERATED_AGENT_FAMILIES` (`scripts/dev_tools/resolve_codex_deployment.py`), so `_synchronize` writes neither the base toml nor its bundle copy. `codex-epic-runtime-contracts.Tests.ps1` compares the SHA-256 of the root and bundle toml, so it would fail if the copy were left to the generator.
- Change: P1-T4 now copies the three Markdown files and the toml byte-identically to their bundle copies, then runs the generator with `--check` only. The P1-T4 acceptance now also requires toml blob-id parity with its bundle copy. The asserted outcome (bundle parity; generator `--check` exit 0) is unchanged.

## Fix 2 — P1-T4 | asserting-test list completeness | existing tests named

- Defect: `test_push_down_codex_and_agents_customizations.py` and the fragment pins of `merge_queue_documentation_expectations.py` read `.codex/agents/epic-orchestrator.toml` and its bundle copy, but the P1-T4 list of existing tests left unchanged did not name them.
- Change: both tests are now named in that list. Their disposition is unchanged, because the change only appends a paragraph. A note on `codex-epic-runtime-contracts.Tests.ps1` records that its hash comparison holds because of the toml copy.

## Fix 3 — Pre-Mortem Mirror parity | consistency with Fix 1

- Change: the bullet now says that P1-T4 copies the toml to its bundle copy and runs the generator `--check`, rather than relying on the generator to write the toml copy.
