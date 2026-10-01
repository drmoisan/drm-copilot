# Integration Stage, Python (P8-T9)

Timestamp: 2026-10-01T22-44
Task: P8-T9
Loop iteration: 2
Sequence: P0-T19 reset (both kinds), `.claude/state` listing, pytest, then the generator check, in one shell invocation with no Write or Edit in between.

## Step 1 — Batch-budget reset (both kinds, OD-484-2)

Route: sh-wrapped pwsh -NoProfile -Command (scratchpad script outside the repository)
Command: foreach ($k in @('python','powershell')) { $f=@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue); "$k removed=$($f.Count) " + (($f | ForEach-Object Name) -join ','); $f | Remove-Item -Force; "$k remaining=$(@(Get-ChildItem -LiteralPath .claude/state -Filter "$k-batch-budget.*.json" -File -ErrorAction SilentlyContinue).Count)" }
Output:

```
python removed=0 
python remaining=0
powershell removed=0 
powershell remaining=0
```

`.claude/state` listing (`Get-ChildItem -LiteralPath .claude/state -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object Name`): empty.

## Step 2 — P0-T19 suites

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 0
Final line: `64 passed in 0.70s`

## Step 3 — Codex variant generator check

Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
stdout bytes: 0; stderr bytes: 0

## Output Summary:

- Reset lines: `python remaining=0`, `powershell remaining=0` (issue #510 reason for the reset).
- Suites: 64 passed, 0 failed, 0 skipped; equal to the P0-T19 passed count (64) and failing set (empty).
- Generator check: exit 0, empty stderr.
- Overall EXIT_CODE: 0.
