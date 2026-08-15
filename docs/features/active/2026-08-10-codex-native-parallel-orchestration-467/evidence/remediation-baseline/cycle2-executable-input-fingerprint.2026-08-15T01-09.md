# Cycle 2 Executable Input Fingerprint

Timestamp: 2026-08-15T01-35
Command: PowerShell over `git ls-tree -r e693a2a32d1c5a936f8a95494900c840139a9b55`; select the roots and root files below; sort by path ordinal; emit `<path><TAB><Git-blob-object-id>`; join with LF and a final LF; compute SHA-256 over UTF-8 bytes.
EXIT_CODE: 0
Output Summary: The deterministic reviewed-HEAD fingerprint contains 2,576 paths. Its aggregate SHA-256 is 8818C314CF006D2A9201491935289D8F149F264807DA8DB9194E7FA89FD76E36.

## Reviewed boundary

- HEAD: `e693a2a32d1c5a936f8a95494900c840139a9b55`
- Path-set count: 2,576
- Aggregate SHA-256: `8818C314CF006D2A9201491935289D8F149F264807DA8DB9194E7FA89FD76E36`
- Record format: `<path><TAB><Git-blob-object-id>`
- Record order: path ascending, ordinal
- Encoding: UTF-8 without BOM
- Record separator: LF
- Final separator: one LF

## Inclusion roots

- `.agents/` (73)
- `.claude/` (150)
- `.codex/` (164)
- `.devcontainer/` (13)
- `.github/` (124)
- `.vscode/` (8)
- `config/` (3)
- `examples/` (7)
- `extensions/` (976)
- `packages/` (8)
- `schemas/` (7)
- `scripts/` (228)
- `src/` (1)
- `tests/` (783)
- `virtual/` (16)

## Included root files

Fifteen reviewed-HEAD root files were present and included:

- `.mcp.json`
- `AGENTS.md`
- `CLAUDE.md`
- `eslint.config.mjs`
- `jest.config.cjs`
- `package-lock.json`
- `package.json`
- `poetry.lock`
- `poetry.toml`
- `pyproject.toml`
- `run-jest.cjs`
- `run-node-tool.cjs`
- `tsconfig.jest.json`
- `tsconfig.json`
- `tsconfig.tests.json`

The selection also tests for root `quality-tiers.yml` and `docs/ci.research.md`; neither path exists at the reviewed HEAD. The authoritative `.agents/skills/quality-tiers/SKILL.md` is included under `.agents/`.

The selected superset covers all production, test, reusable-script, dependency-manifest, policy, quality-tier, coverage-configuration, and threshold inputs while excluding generated QA outputs and feature evidence under `artifacts/` and `docs/features/`.

Result: PASS
