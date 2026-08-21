# Final QC — Python Tests and Coverage (Pytest), Iteration 2 — FAILED [P7-T9]

Timestamp: 2026-08-20T20-30

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 1

Coverage-target note: the command uses the bare `--cov` form configured by the repository, not a `--cov=<path>.py` form, which would collect no data.

## Result Header

```
TOTAL                                                               14939   1107   5488    561    91%
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
================= 1 failed, 4060 passed, 5 skipped in 19.01s ==================
```

## Output Summary

**FAIL — 1 failed, 4060 passed, 5 skipped.** This iteration is recorded because the loop ledger requires every iteration's outcome, not only the passing one.

### The Failure

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

```
E  AssertionError: Bundle content differs from repo for: .claude\skills\feature-promotion-lifecycle\SKILL.md
E  assert '---\nname: f...feature`.\n\n' == '---\nname: f...feature`.\n\n'
E    Skipping 4245 identical leading characters in diff, use -v to show
E      t exist
E    - - the promoted record under `docs/features/potential/promoted/` is still present (see 4b)
E      - if any check fails, stop and remediate before planning
E    -
E    - 4b) Verify the promoted record was retained after `new_active_feature_folder`:...
```

The diff lines are exactly the text P5-T4 added.

### Cause

The repository enforces a byte-identical mirror between each repo `.claude/**` file and its bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/**`. `REQUIRED_BUNDLED_FILES` in that test names `.claude/skills/feature-promotion-lifecycle/SKILL.md` explicitly, so this particular file is a contract-listed mirror target.

P5-T4 edited the repo copy and did not mirror the edit, so the two diverged. This is a genuine defect introduced by this change, not a pre-existing failure: the baseline run (`evidence/baseline/baseline-py-pytest-coverage.2026-08-20T18-54.md`) was green at 4059 passed / 0 failed.

### Remediation

The edited skill file was copied to its bundled path:

`.claude/skills/feature-promotion-lifecycle/SKILL.md` → `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md`

`diff` between the two now exits 0, confirming byte identity. Only the mirror copy was changed; the repo copy's content is exactly what P5-T4 authored and is unaltered by the remediation.

Because a source file changed, the toolchain loop restarts from step 1. Iteration 3 begins at `final-py-black.2026-08-20T20-33.md` and its test stage is recorded at `final-py-pytest-coverage.2026-08-20T20-35.md`, which passes with exit code 0.

The exit code was captured directly from the command process with no pipe.
