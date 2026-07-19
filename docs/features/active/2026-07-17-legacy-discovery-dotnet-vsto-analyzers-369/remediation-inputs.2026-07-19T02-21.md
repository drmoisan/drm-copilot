# Remediation Inputs — Cycle 1 (Merge Conflict)

- Timestamp: 2026-07-19T02:21:42Z
- Feature: legacy-discovery-dotnet-vsto-analyzers
- Canonical issue number: 369
- PR: #384 (base epic/legacy-discovery-and-parity-integration)
- Source: S9 CI-green gate — PR non-mergeable (mergeable=CONFLICTING, mergeStateStatus=DIRTY)
- Cycle entry: remediation.cycle_1.inputs

## Finding 1 — BLOCKING: Merge conflict against the epic integration branch

Severity: Blocking

The PR head (`e5b890024824d258987f7d1350cfe93f7317c92f`) is not mergeable into the
epic integration branch `epic/legacy-discovery-and-parity-integration`. The integration
branch advanced after this feature branched (base `3a4985fa`); sibling wave-2 features
#367 (skills) and #368 (reports) merged in the interim. The current integration tip is
`2215ebf992ebfb46ab10674188c48d5a3a15cf3a`.

A trial merge of `origin/epic/legacy-discovery-and-parity-integration` into the feature
branch produces exactly one conflicted file:

- `pyproject.toml` — content conflict in the `[tool.poetry.scripts]` table.

The conflict is additive on both sides:

- This feature (`HEAD`) adds:
  - `"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"`
  - `"dev.discovery.vsto" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"`
- The integration branch (from #368) adds:
  - `"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"`

No other file conflicts. No production or test logic conflicts; `test_domain_neutrality.py`
did not conflict.

### Required remediation

1. Merge `origin/epic/legacy-discovery-and-parity-integration` into the feature branch.
2. Resolve the `pyproject.toml` `[tool.poetry.scripts]` conflict by retaining all three
   entries (both this feature's `dev.discovery.dotnet` / `dev.discovery.vsto` lines and
   the integration branch's `dev.discovery.parity-report` line), preserving the table's
   existing sorted-by-suffix ordering. Change nothing else in `pyproject.toml`
   (no dependency changes, no coverage-configuration changes).
3. Run the full Python toolchain (Black -> Ruff -> Pyright -> Pytest with coverage) to
   confirm the merged tree is clean, all tests pass, and coverage thresholds hold
   (line >= 85%, branch >= 75%) with no regression.
4. Commit the merge resolution.

### Expected outcome

After the merge resolution and a clean toolchain pass, the PR must become mergeable
(`mergeable=MERGEABLE`) so the S9 CI-green gate and the epic-mode merge-on-green step can
proceed.
