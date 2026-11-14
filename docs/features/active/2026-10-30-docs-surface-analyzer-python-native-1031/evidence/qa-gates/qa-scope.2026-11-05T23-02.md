# [P6-T17] Scope verification

Timestamp: 2026-11-05T23-02
Command: git diff --name-only MERGE_BASE ; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: the union lists 143 paths. The diff gives 143 paths, and porcelain status is empty because every change is committed. Every path matches a row of `## Artifact Classification`. 0 paths lie under `.claude/hooks/`, `.claude/skills/`, `.claude/agents/` or `extensions/drm-copilot/src/`. There are 39 `.py` paths: 12 `PYLIB`, 12 `MIRROR/python` and 15 `PYTESTS`. 0 `.py` paths lie elsewhere.

`MERGE_BASE` = `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`.

## Path-to-row mapping

| Path group | Count | Classification row |
|---|---|---|
| `.claude/lib/docs/python/run_docs_python_native.py`, `.claude/lib/docs/python/docs_python_native/*.py` | 12 | `PYLIB` / `PKG` helper (D3) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/python/**` | 12 | `MIRROR/python/**` (D3) |
| `.claude/lib/docs/DocsAnalyzerPythonNative.psm1`, `DocsPythonNativeProtocol.psm1` and `MIRROR` copies | 4 | new `LIB` modules (R1) |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1`, `DocsInventory.psm1`, `Invoke-DocsCommand.ps1` and `MIRROR` copies | 6 | edited `LIB` files (R1) |
| `pack-manifests/core.json`, `pack-manifests/python.json` (claude-customizations) | 2 | `CORE`, `PYPACK` (D) |
| `pyproject.toml` | 1 | configuration (D, P) |
| `extensions/drm-copilot/.vscodeignore` | 1 | ignore patterns (P, Q12) |
| `packages/mcp-server/prepack.cjs` | 1 | build script (P, Q12) |
| `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` | 1 | Jest test (D, Q12) |
| `tests/scripts/claude-runtime/` guard suite and two helpers | 3 | guard test files (D, Q11) |
| `tests/scripts/claude-lib/docs/*.Tests.ps1` (4 new, 5 edited) | 9 | Pester suites (D) |
| `tests/scripts/claude-lib/docs/python/*.py` (`conftest.py` plus 14 modules) | 15 | Pytest (D3) |
| `tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json` | 1 | test data (D) |
| `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/**` (plan, `spec.md`, `user-story.md`, 72 evidence files) | 75 | `FEATURE/**` documentation (D) |
| Total | 143 | |

Note on `FEATURE/spec.md` and `FEATURE/user-story.md`: their diff against `MERGE_BASE` comes from one planning-time commit, `docs(features): raise the issue 1031 helper Python floor to 3.11`, which records the 2026-11-04 owner decision that raised the helper floor from 3.10 to 3.11. The commit predates execution of the feature tasks, and no execution task changed criterion text. The [P6-T19] check-offs change checkbox state only.

## Commands and raw counts

- `git diff --name-only MERGE_BASE | wc -l` gives `143`.
- `git diff --name-only MERGE_BASE | grep -c -E '^\.claude/(hooks|skills|agents)/|^extensions/drm-copilot/src/'` gives `0`.
- `git diff --name-only MERGE_BASE | grep -c '\.py$'` gives `39`. After excluding the `PYLIB`, `MIRROR/python` and `PYTESTS` prefixes, `wc -l` gives `0`.
- `git status --porcelain --untracked-files=all` prints nothing.
