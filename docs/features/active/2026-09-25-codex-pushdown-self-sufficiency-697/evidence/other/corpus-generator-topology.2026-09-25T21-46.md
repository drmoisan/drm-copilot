# Corpus Generator: Topology (Issue #697, [P6-T2])

Timestamp: 2026-09-25T21-46
Command: poetry run python <SCRATCHPAD>/generate_codex_routing_corpus.py topology
EXIT_CODE: 0
Output Summary:
- Imported module `__file__` (worktree root replaced, separators normalized): `<WORKSPACE_ROOT>/scripts/dev_tools/resolve_codex_topology.py` -- starts with `<WORKSPACE_ROOT>/scripts/dev_tools/`, so the generator used this worktree's module (the root was inserted at `sys.path[0]` after verifying `scripts/dev_tools/resolve_codex_topology.py` exists).
- Wrote `tests/fixtures/codex_routing/topology.json` with 14 records via `json.dumps(records, indent=2, ensure_ascii=True) + "\n"` and `newline="\n"`.
- Exit classes: 9 success (exit 0), 3 argparse errors (exit 2: topo-missing-required, topo-invalid-choice, topo-non-integer-count), 2 ValueError (exit 1).
- `topo-empty-language` expected_stderr_contains: `languages must contain non-empty strings.`
- `topo-root-persona-non-standalone` expected_stderr_contains: `A forced root persona requires standalone context.`
- Byte check `[System.IO.File]::ReadAllBytes('tests/fixtures/codex_routing/topology.json') | Where-Object { $_ -gt 127 -or $_ -eq 13 }` returned nothing (0 bytes).
