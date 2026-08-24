# Phase 1 — Scoped Diff Check (Issue #369, Remediation Cycle 1)

Timestamp: 2026-07-18T22-27

Command: git diff pyproject.toml

EXIT_CODE: 0

Output Summary:
- The combined merge diff (`diff --cc`) contains exactly one hunk, located within the `[tool.poetry.scripts]` table:
  ```
  @@@ -59,8 -61,7 +61,9 @@@ shell-qc-test = "scripts.dev_tools.shel
    "dev.discovery.generate-acceptance-scenarios" = ...
    "dev.discovery.init" = ...
    "dev.discovery.inventory" = ...
   +"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"
  + "dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"
   +"dev.discovery.vsto" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"
    "dev.discovery.profile" = ...
    "dev.discovery.validate-all" = ...
    "dev.discovery.validate-coverage-ledger" = ...
  ```
- The only added lines relative to both parents are the resolution of the `dev.discovery.*` run: `dotnet` and `vsto` (from HEAD, left `+` column) and `parity-report` (from integration, right `+` column). Conflict markers are removed.
- The integration-only additive entries `dev.discovery.completion-report` and `dev.discovery.coverage-report` were auto-merged cleanly (they match the integration parent) and therefore do not appear in the combined `diff --cc` output; they are not a manual edit.
- No dependency table (`[tool.poetry.dependencies]`, `[tool.poetry.group.*]`), no coverage-configuration table (`[tool.coverage.*]`), and no other `[tool.poetry.scripts]` line was changed. The diff is confined to the `[tool.poetry.scripts]` `dev.discovery.*` run and conflict-marker removal.
