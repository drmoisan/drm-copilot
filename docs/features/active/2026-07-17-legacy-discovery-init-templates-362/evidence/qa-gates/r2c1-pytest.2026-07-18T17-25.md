# Phase 2 Pytest (Post-Merge) — Remediation Cycle 2 (#362)

- Timestamp: 2026-07-18T17-25
- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- EXIT_CODE: 1
- Output Summary: 1782 passed, 1 failed, 0 skipped. Line coverage 88.53% (10284/11616 statements covered). Branch coverage 79.34% (3426/4318 branches covered). Combined coverage.py `TOTAL` line reported 86%. Both numeric coverage thresholds (line >= 85%, branch >= 75%) are satisfied on the merged tree.

## Failing Test — Root-Cause Diagnosis (Pre-Existing, Out of This Plan's Authorized Scope)

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails with:

```
AssertionError: Repo file missing from bundle: .claude\agents\legacy-parity-analyst.md
```

Verified root cause via tree inspection (not caused by the `pyproject.toml` conflict resolution performed under this plan):

- `git show HEAD:.claude/agents/legacy-parity-analyst.md` (pre-merge feature-branch HEAD) — exit 128 (does not exist). The file is absent from this feature branch prior to the merge.
- `git show origin/epic/legacy-discovery-and-parity-integration:.claude/agents/legacy-parity-analyst.md` — exists (added by commit `5335075c`, sibling feature #365, "feat(agents): add four domain-neutral agent personas for legacy-discovery").
- `git show origin/epic/legacy-discovery-and-parity-integration:extensions/drm-copilot/resources/claude-customizations/.claude/agents/legacy-parity-analyst.md` — does not exist (path not found in that ref).

This confirms the integration branch itself already fails this same test at its own tip, independent of this merge: it added `.claude/agents/legacy-parity-analyst.md` to the repo-scope `.claude/` tree without a corresponding push-down into the bundled `extensions/drm-copilot/resources/claude-customizations/` payload. The failure is inherited by this merge from the integration branch and is unrelated to the `pyproject.toml` `dev.discovery.*` conflict this plan is authorized to resolve.

This plan's sole authorized requirements source is `remediation-inputs.2026-07-18T15-35.md` (single Blocking finding R1 — the `pyproject.toml` conflict). Remediating the bundled-payload push-down gap for `.claude/agents/legacy-parity-analyst.md` requires editing files under `extensions/drm-copilot/resources/claude-customizations/`, which are not named by any task in this plan and fall outside the plan's authorized scope. Per the plan-execution contract, this is escalated as a new finding for a separate remediation cycle rather than resolved ad hoc within this plan.
