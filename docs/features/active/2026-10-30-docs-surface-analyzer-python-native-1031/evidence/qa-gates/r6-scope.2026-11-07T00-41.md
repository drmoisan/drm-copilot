# [P6-T18] Scope

Timestamp: 2026-11-07T00-41
Command: union of git diff --name-only MERGE_BASE and git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: 233 paths. No DocsPythonTokens path; no path under .claude/hooks/, .claude/skills/, .claude/agents/ or extensions/drm-copilot/src/; the only .py paths are under PYLIB, MIRROR/python and PYTESTS. Every path matches a row of the original plan `## Artifact Classification` or of `## Artifact Classification Additions`: the helper, mirror and test modules, the two LIB modules with the registry, inventory and command files and their MIRROR copies, PYPACK and CORE, pyproject.toml, .vscodeignore, prepack.cjs, discovery-resources.test.ts, the guard files, the docs suites, the native corpus fixture and FEATURE documentation.

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
| `tests/scripts/claude-lib/docs` | 9 |
| `tests/scripts/claude-lib/docs/fixtures` | 1 |
| `tests/scripts/claude-lib/docs/python` | 21 |
| `tests/scripts/claude-runtime` | 3 |
