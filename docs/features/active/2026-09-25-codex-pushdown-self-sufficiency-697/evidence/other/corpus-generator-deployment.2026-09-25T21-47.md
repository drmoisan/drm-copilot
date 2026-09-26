# Corpus Generator: Deployment (Issue #697, [P6-T3])

Timestamp: 2026-09-25T21-47
Command: poetry run python <SCRATCHPAD>/generate_codex_routing_corpus.py deployment
EXIT_CODE: 0
Output Summary:
- Imported module `__file__` (worktree root replaced, separators normalized): `<WORKSPACE_ROOT>/scripts/dev_tools/resolve_codex_deployment.py` -- starts with `<WORKSPACE_ROOT>/scripts/dev_tools/` (root inserted at `sys.path[0]`).
- Wrote `tests/fixtures/codex_routing/deployment.json` with 9 records (same serialization as topology).
- Exit classes: 5 success (exit 0), 2 argparse errors (exit 2: dep-missing-required, dep-invalid-choice), 2 ValueError (exit 1).
- `dep-ceiling-below-band` expected_stderr_contains: `orchestration_complexity_ceiling must be greater than or equal to complexity_band, found C2 below C3.`
- `dep-unsupported-agent` expected_stderr_contains: `Unsupported Codex logical agent: 'nope'.`
- Byte check on `tests/fixtures/codex_routing/deployment.json` returned nothing (0 bytes > 127 or equal to 13).
