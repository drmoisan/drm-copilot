# Remediation Inputs — Cycle 1 (#363)

- Timestamp: 2026-07-18T13-10
- Feature: 2026-07-17-legacy-discovery-analyzer-framework-363 (issue #363)
- PR: https://github.com/drmoisan/drm-copilot/pull/378
- Base branch: epic/legacy-discovery-and-parity-integration
- Head branch: feature/legacy-discovery-analyzer-framework-363
- Trigger: Merge-conflict remediation (S9 step 6). GitHub reports PR mergeable state CONFLICTING.

## Synthetic Blocking Finding

- Severity: Blocking
- Category: merge-conflict
- Source: The epic integration branch advanced after this feature branched (siblings #364, #365, #377 merged). A test merge of `origin/epic/legacy-discovery-and-parity-integration` into the feature branch fails with a content conflict.

### Conflicting file

`pyproject.toml`, section `[tool.poetry.scripts]`.

### Conflict detail

Both sides added a new console-script entry at the same location:

- Ours (HEAD): `"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"`
- Theirs (integration): `"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"`

No other file conflicts. The `[tool.coverage.report] exclude_lines` change merges cleanly.

### Required resolution

Merge the integration branch into the feature branch and resolve `pyproject.toml` by KEEPING BOTH console-script entries (union), preserving alphabetical/existing ordering in `[tool.poetry.scripts]`. Do not drop `dev.discovery.inventory` (this feature) or `dev.discovery.generate-acceptance-scenarios` (#364). Confirm `dev.discovery.profile` (#360) remains present. Then re-run the full Python QC loop (Black -> Ruff -> Pyright -> Pytest with coverage) to confirm no regression, commit the merge resolution, and push so the PR becomes mergeable.

### Exit condition

- PR #378 mergeable state is MERGEABLE (no conflicts) against the integration branch head.
- Reaudit (code-review, feature-audit, policy-audit) reports zero blocking findings.
- Full Python QC loop passes with coverage thresholds intact (line >= 85%, branch >= 75%, no regression).
