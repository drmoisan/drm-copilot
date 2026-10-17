# Mirror, Fragment, Generator, and Skill-Bundle Suites Baseline (P0-T19)

Timestamp: 2026-10-01T21-10
Task: P0-T19
Route (reset and listing): sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6)
Sequence: reset, listing, pytest, run in one shell invocation with no Write or Edit in between.

## Step 1 — Batch-budget reset (both kinds, OD-484-2)

Command: foreach ($k in @('python','powershell')) { $f=@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue); "$k removed=$($f.Count) " + (($f | ForEach-Object Name) -join ','); $f | Remove-Item -Force; "$k remaining=$(@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue).Count)" }
EXIT_CODE: 0
Output:

```
python removed=0 
python remaining=0
powershell removed=0 
powershell remaining=0
```

## Step 2 — `.claude/state` listing (read-only)

Command: Get-ChildItem -LiteralPath .claude/state -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object Name
EXIT_CODE: 0
Output: (empty; no files under `.claude/state` in this worktree)

## Step 3 — Contract suites

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 0

## Output Summary:

- Reset lines: `python remaining=0`, `powershell remaining=0` (0 files removed of either kind).
- `.claude/state` listing: empty.
- The reset is required because `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails whenever a batch-budget state file exists under `.claude/state/` (issue #510).
- Final line: `64 passed in 0.86s` (collected 64).
- Passed 64, skipped 0, failed 0.
- Failing node IDs: none.
- Passed count 64 and the empty failing set are the comparison values for P6-T29 and P8-T9.
