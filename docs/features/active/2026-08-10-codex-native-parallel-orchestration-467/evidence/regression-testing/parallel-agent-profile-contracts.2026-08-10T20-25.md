# Parallel Agent Profile Contract Receipt

- Plan task: `[P2-T4]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`

## Profile parity

- `parallel-planner.toml`: root and bundle SHA-256
  `7D9EC7F50723B3D7908742C0E578794E7D953FEF212C6FD4040F2EA7FF287F93`;
  byte-identical; `63` lines each.
- `parallel-orchestrator.toml`: root and bundle SHA-256
  `2E05868C70ADBB81189C63B117794CA3502EEBB851D5123E26C3B02546965773`;
  byte-identical; `74` lines each.

Python `tomllib` parsed all four profiles. The root profiles match their routed
deployment receipts for name, execution context, exact `gpt-5.6-sol` model,
`ultra` reasoning effort, and `orchestrator-workspace` permissions.

## Role-boundary verification

- Focused Pester command: `Invoke-Pester -Path tests/scripts/codex-hooks/parallel-provenance.Tests.ps1 -FullNameFilter '*defines forced persona*'`.
- Result: exit `0`; `2 passed`, `0 failed`, `0 skipped`, `12 not run`.
- The planner profile contains the required `planning-only` boundary and
  prohibits implementation, atomic execution, pull-request work, CI monitoring,
  execution-mode children, and silent model fallback.
- The orchestrator profile contains the required `root-scheduler-only` boundary,
  prohibits use as a child implementer or local item implementation, and
  prohibits silent model fallback.

## Repository invariants

- `.claude` status entries: `0`.
- `git diff --check`: exit `0`.
