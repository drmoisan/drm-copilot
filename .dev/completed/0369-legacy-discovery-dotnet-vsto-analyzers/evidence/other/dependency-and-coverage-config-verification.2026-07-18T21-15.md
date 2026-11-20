# Dependency and Coverage-Configuration Verification

- Timestamp: 2026-07-18T21-15
- Task: [P5-T3]
- Rule: No new runtime dependency; no coverage exclusion added for new modules.

## pyproject.toml diff (only relevant excerpt)

```
@@ [tool.poetry.scripts] @@
 "dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
+"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"
+"dev.discovery.vsto" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"
 "dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
```

The entire `pyproject.toml` diff for this feature is exactly these two added
lines under `[tool.poetry.scripts]`. No other section of `pyproject.toml` was
modified.

## Explicit statements

- `[tool.poetry.dependencies]` (runtime): unchanged. Standard library only is used
  by the new analyzer modules (`pathlib`, `re`, `fnmatch`, `json`, `hashlib`,
  `argparse`, `dataclasses`, `typing`, `datetime`).
- Dev dependency group: unchanged. `jsonschema` remains a dev-only test
  dependency; `hypothesis` was NOT added (parametrized boundary matrices are the
  approved substitute for property-based tests, consistent with #360/#363).
- `[tool.coverage.*]` configuration: unchanged. No coverage exclusion was added
  for any new analyzer module; all new production modules remain in the coverage
  denominator.

## Verdict

No new runtime dependency and no new coverage exclusion. PASS.
