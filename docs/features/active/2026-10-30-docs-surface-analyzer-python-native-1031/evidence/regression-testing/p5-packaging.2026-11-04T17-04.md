# [P5-T3] Packaging carve-out for the docs helper

Timestamp: 2026-11-04T17-04
Command: sh SCRATCH/issue-1031-jest.sh issue-1031-p5t3.out test/packaging/discovery-resources.test.ts test/packaging/mcp-server-prepack.test.ts (node run-jest.cjs in extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: Test Suites: 2 passed, 2 total; Tests: 14 passed, 14 total; 0 failed. mcp-server-prepack.test.ts is unchanged (including 'excludes Python files at every depth'); in discovery-resources.test.ts the two named cases are updated:
- 'keeps the explicit Python-source exclusion in both distributables': asserts the .vscodeignore negation !resources/claude-customizations/.claude/lib/docs/python/**/*.py, that shouldCopy admits the two helper .py paths, and rejects other .py paths (including a docs .py outside python/ and a Codex-bundle docs python path), a __pycache__ directory, a .pyc under __pycache__, and .pyc and .pyo files under the helper tree.
- 'excludes no published discovery resource from the VSIX': asserts the negation is the only ! pattern and keeps every other pattern rule.
'copies every discovery resource into the standalone MCP package' is unchanged and passes.

Supporting checks: npx prettier --check (both changed files) exit 0; npx eslint test/packaging/discovery-resources.test.ts exit 0; npx tsc --noEmit -p . exit 0.
Edits: extensions/drm-copilot/.vscodeignore (one negation after **/*.py); packages/mcp-server/prepack.cjs (shouldCopy admits .py only under PYTHON_HELPER_PREFIX claude-customizations/.claude/lib/docs/python/ relative to SOURCE_DIR and rejects every __pycache__ path and every .pyc and .pyo file).
