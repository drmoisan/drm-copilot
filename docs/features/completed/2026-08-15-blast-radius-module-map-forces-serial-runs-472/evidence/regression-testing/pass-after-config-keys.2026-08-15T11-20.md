# Pass-After — Committed Config Module Keys (issue #472)

Timestamp: 2026-08-15T11-20

Command: `poetry run python -c "import json; m=json.load(open('config/blast-radius.json'))['modules']; b=json.load(open('extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json'))['modules']; print(sorted(m)); print(sorted(b)); print('root has docs/tests:', 'docs' in m and 'tests' in m, '| bundled has docs/tests:', 'docs' in b and 'tests' in b)"`

EXIT_CODE: 0

Output Summary:

Repo-root `config/blast-radius.json` `modules` keys (12, sorted) — AC1:

```
['agents-surface', 'benchmarks', 'claude-runtime', 'codex-runtime', 'config', 'copilot-surface', 'mcp-server', 'poshqc', 'powershell-dev-tools', 'python-dev-tools', 'schemas', 'vscode-extension']
```

This is exactly the twelve expected keys `python-dev-tools`, `powershell-dev-tools`, `poshqc`, `benchmarks`, `claude-runtime`, `codex-runtime`, `copilot-surface`, `agents-surface`, `mcp-server`, `vscode-extension`, `config`, `schemas`.

Bundled `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` `modules` keys (2, sorted) — AC2:

```
['claude-runtime', 'config']
```

Location-bucket check:

```
root has docs/tests: False | bundled has docs/tests: False
```

Neither committed copy contains a `docs` or `tests` module.

## Before / after comparison

| Copy | Baseline module count | Post-change module count | `docs`/`tests` present |
| --- | --- | --- | --- |
| `config/blast-radius.json` | 14 | 12 | before: yes; after: no |
| `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | 4 | 2 | before: yes; after: no |

Baseline reference: `evidence/baseline/phase0-config-precondition.md` (`root has docs/tests: True | bundled has docs/tests: True`).

Both files parse successfully, confirming the trailing-comma removals on the
preceding entries (`schemas` in the repo-root copy, `config` in the bundled
copy) were applied correctly. AC1 and AC2 are satisfied.
