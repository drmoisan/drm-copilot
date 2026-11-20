# Remediation Inputs — Cycle 1 (2026-10-20T15-44)

- Issue: #984
- Branch: bug/completion-helpers-missing-from-core-pack-manifest-984
- Source audit: `code-review.2026-10-20T15-34.md`, `feature-audit.2026-10-20T15-34.md`, `policy-audit.2026-10-20T15-34.md` (feature folder root). Review status: PASS with no blocking findings.

Remediation-Mode: proportionate

## Rationale for the cycle

The review raised two Minor findings and no blocking findings. The orchestrator is fixing Minor finding 1 in this item rather than leaving it, because it weakens the regression guard that this bug fix adds. Minor finding 2 is accepted without change. The only non-PowerShell `.claude/lib` paths in the bundled `settings.json` are `Bash(...)` permission entries, not hook registrations, and core `core.json` already lists all six of those `.sh` files. No non-PowerShell hook is registered, so changing the pattern now would add behavior that no input exercises.

## Fix list

1. **Strengthen the non-vacuity floor in the closure test.**
   - File: `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, function `test_scanned_source_floor` (around line 216).
   - Current behavior: each surface asserts only `len(scanned) >= 1`. A scan regression that silently drops most sources would still pass.
   - Expected behavior: for each surface, assert that the scanned set contains a named anchor source known to have a `$PSScriptRoot` dependency:
     - Claude: `.claude/hooks/enforce-completion-consistency.ps1`
     - Codex: `.codex/hooks/enforce-completion-consistency.ps1`, or another Codex core hook that dot-sources a sibling, chosen by the planner from the actual manifest
   - Also assert a floor derived from the data rather than the constant 1. For example, the scanned count must equal the number of distinct `.ps1`/`.psm1` entries the surface's effective manifest set lists, or must be at least that number. The planner picks whichever relation the scanner actually satisfies, verified against the current tree.
   - Failure messages must name the surface and the missing anchor or the count mismatch.
   - Fail-before evidence: show that the strengthened assertion fails when the scan is artificially narrowed, using a monkeypatched or in-memory narrowed surface inside the test module. Do not edit production files or use temporary files.
   - Verification:
     - `poetry run black --check` and `poetry run ruff check` on the changed file
     - `poetry run pyright` on the changed file
     - `poetry run pytest tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
     - A second pytest run of the same modules in reversed order

## Do not do

- Do not change any hook, manifest, bundle file, CHANGELOG, or spec acceptance criterion.
- Do not weaken or remove any existing assertion.
- Do not use temporary files in tests.
- Do not extend `_HOOK_PATH` (Minor finding 2 is accepted as-is).
- Do not commit. Do not modify `artifacts/orchestration/orchestrator-state.json`.
- The test file must stay at or under 500 lines.
