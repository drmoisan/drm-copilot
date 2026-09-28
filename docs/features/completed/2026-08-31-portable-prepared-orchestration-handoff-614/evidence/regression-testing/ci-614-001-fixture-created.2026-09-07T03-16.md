# Preparation Checkpoint Fixture Created — [P1-T15]

Timestamp: 2026-09-07T11-49
Task: [P1-T15]

Command: `Select-String -LiteralPath tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json -Pattern '"route_id": "preparation"' -SimpleMatch`; `(Get-Content -LiteralPath tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json).Count`
EXIT_CODE: 0

The parent directory `tests/fixtures/codex-hooks/` did not exist and was created as part of creating the fixture.

## File contents (byte dump)

```
0000000   {  \n           "   r   o   u   t   e   _   i   d   "   :
0000020   "   p   r   e   p   a   r   a   t   i   o   n   "  \n   }  \n
0000040
```

The file is exactly an opening brace, the line `  "route_id": "preparation"`, a closing brace, and a trailing newline: 32 bytes, LF line endings, no BOM.

## Results

- `"route_id": "preparation"` match count: 1 (required: exactly 1)
- Line count: 3 (required: 3)

Output Summary: The committed fixture exists at `tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json` with exactly 3 lines and one match for the required literal. This is the preparation-route checkpoint text the hook process receives. It carries the same `route_id` value the six byte-identity cases previously supplied inline as `{"route_id":"preparation"}`, so the route the hook resolves is unchanged and every decision it returns is unchanged; only the whitespace of the JSON text differs, which the hook parses rather than compares.
