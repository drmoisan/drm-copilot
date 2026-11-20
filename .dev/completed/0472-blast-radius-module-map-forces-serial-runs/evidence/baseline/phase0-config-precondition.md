# Phase 0 — Pre-Fix Config Precondition (issue #472)

Timestamp: 2026-08-15T10-42

Command: `poetry run python -c "import json; m=json.load(open('config/blast-radius.json'))['modules']; b=json.load(open('extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json'))['modules']; print(sorted(m)); print(sorted(b)); print('root has docs/tests:', 'docs' in m and 'tests' in m, '| bundled has docs/tests:', 'docs' in b and 'tests' in b)"`

EXIT_CODE: 0

Output Summary:

Repo-root `config/blast-radius.json` `modules` keys (14, sorted):

```
['agents-surface', 'benchmarks', 'claude-runtime', 'codex-runtime', 'config', 'copilot-surface', 'docs', 'mcp-server', 'poshqc', 'powershell-dev-tools', 'python-dev-tools', 'schemas', 'tests', 'vscode-extension']
```

Bundled `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` `modules` keys (4, sorted):

```
['claude-runtime', 'config', 'docs', 'tests']
```

Precondition line:

```
root has docs/tests: True | bundled has docs/tests: True
```

Both committed copies currently contain the `docs` and `tests` location-bucket modules. This is the before-state (Defect A precondition) that forces conflict edges between thematically unrelated items whose only overlap is a documentation or test path. The regression gate authored in Phase 1 is expected to fail against this state.
