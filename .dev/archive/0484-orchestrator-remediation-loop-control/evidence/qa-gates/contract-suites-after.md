# Mirror, Fragment, Generator, and Skill-Bundle Suites After Documentation Edits (P6-T29)

Timestamp: 2026-10-01T23-16
Task: P6-T29
Authorization: OD-484-2 (scheduled pre-test reset point P6-T29). The reset is required because `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails whenever a batch-budget state file exists under `.claude/state/` (issue #510).
Route: one scratchpad shell script outside the repository running, in order and with no Write or Edit in between: the reset (pwsh -NoProfile -Command), the listing (pwsh -NoProfile -Command), then pytest.

## Step 1: reset (both kinds)

Command: foreach ($k in @('python','powershell')) { $f=@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue); "$k removed=$($f.Count) " + (($f | ForEach-Object Name) -join ','); $f | Remove-Item -Force; "$k remaining=$(@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue).Count)" }
EXIT_CODE: 0

```
python removed=0 
python remaining=0
powershell removed=0 
powershell remaining=0
```

## Step 2: `.claude/state` listing (read-only)

Command: Get-ChildItem -LiteralPath .claude/state -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object Name
EXIT_CODE: 0

Output: (empty; no file under `.claude/state` in this worktree)

## Step 3: contract suites

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 0

```
collected 64 items
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .............. 
tests\scripts\dev_tools\test_push_down_codex_and_agents_resource_contracts.py ......... 
tests\scripts\dev_tools\test_orchestration_guardrail_contracts.py .......... 
tests\scripts\dev_tools\test_codex_handoff_contract_parity.py ..... 
tests\scripts\dev_tools\test_codex_agent_wrapper_contracts.py ....... 
tests\scripts\dev_tools\test_generate_codex_agent_variants.py .............. 
tests\scripts\dev_tools\test_skill_bundle_contract_repo.py ..... 
============================= 64 passed in 0.80s ==============================
```

## Comparison with P0-T19 (`evidence/baseline/contract-suites-before.md`)

| Count | P0-T19 | P6-T29 |
|---|---|---|
| passed | 64 | 64 |
| skipped | 0 | 0 |
| failed | 0 | 0 |

Output Summary: reset lines `python remaining=0` and `powershell remaining=0` recorded; `.claude/state` empty; 64 passed, 0 failed, 0 skipped, equal to the P0-T19 passed count. The mirror (M-C, M-A), fragment-guard, generator, and skill-bundle suites pass with the fifteen edited documents, their bundle copies, and the twelve regenerated `feature-reviewer*.toml` files. Result: PASS.
