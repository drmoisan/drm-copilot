# Python TaskMaster Fixture Focused Regression

Timestamp: 2026-09-03T03-10
Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py -k fixture_hashes_and_source_history_are_pinned --no-cov -q`
EXIT_CODE: 0

Output Summary: Both bidirectional raw-byte provenance cases passed directly against the persistent staged CRLF fixture bytes. Pytest reported `2 passed, 54 deselected`.

```text
..                                                                       [100%]
2 passed, 54 deselected in 0.06s
```

Command: `$p1='tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md';$p2='tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md';git diff --quiet -- $p1 $p2;$d=$LASTEXITCODE;$h=Get-FileHash -Algorithm SHA256 -LiteralPath $p1,$p2;[pscustomobject]@{UnstagedDiffExit=$d;Hashes=@($h.Hash.ToLowerInvariant());Sizes=@((Get-Item -LiteralPath $p1).Length,(Get-Item -LiteralPath $p2).Length)}|ConvertTo-Json -Compress`
EXIT_CODE: 0

Output Summary: Before/after index identity is preserved: no unstaged fixture diff exists, and both files remain 101,998 bytes with raw SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`.

```json
{"UnstagedDiffExit":0,"Hashes":["54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f"],"Sizes":[101998,101998]}
```

No setup hook, helper, pre-test command, or test body rewrote or normalized fixture bytes.
