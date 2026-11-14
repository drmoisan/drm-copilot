# [P3-T18] Scope

Timestamp: 2026-11-07T02-47
Command: git diff --name-only CYCLE_START -- . ":(exclude).claude/agent-memory" and git diff --name-only MERGE_BASE -- . ":(exclude).claude/agent-memory", each with git status --porcelain --untracked-files=all as the untracked companion
EXIT_CODE: 0
Output Summary: the cycle union holds the script, its bundle copy, the test file and paths under FEATURE/; the branch union adds only TESTS/Invoke-DocsCommand.Tests.ps1 and paths under FEATURE/ beyond the previous r6-scope list.

## Cycle union

Paths outside `FEATURE/`:

- `.claude/lib/docs/Invoke-DocsCommand.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1`
- `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`

Total 34 paths; the other 31 are under `FEATURE/`. `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` is not in the cycle union.

## Branch union

Total 271 paths. Compared with `FEATURE/evidence/qa-gates/r6-scope.2026-11-07T00-41.md`, the folder counts outside `FEATURE/` are equal except `tests/scripts/claude-lib/docs`, which rises from 9 to 10 with `TESTS/Invoke-DocsCommand.Tests.ps1`.

| Folder (outside FEATURE) | Paths |
|---|---|
| `.claude/lib/docs` | 5 |
| `.claude/lib/docs/python` | 1 |
| `.claude/lib/docs/python/docs_python_native` | 17 |
| `extensions/drm-copilot` | 1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs` | 5 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/python` | 1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/python/docs_python_native` | 17 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests` | 2 |
| `extensions/drm-copilot/test/packaging` | 1 |
| `packages/mcp-server` | 1 |
| `pyproject.toml` | 1 |
| `tests/scripts/claude-lib/docs` | 10 |
| `tests/scripts/claude-lib/docs/fixtures` | 1 |
| `tests/scripts/claude-lib/docs/python` | 21 |
| `tests/scripts/claude-runtime` | 3 |
