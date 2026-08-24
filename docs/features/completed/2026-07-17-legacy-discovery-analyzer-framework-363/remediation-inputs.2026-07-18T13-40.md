# Remediation Inputs — Cycle 2 (#363)

- Timestamp: 2026-07-18T13-40
- Feature: 2026-07-17-legacy-discovery-analyzer-framework-363 (issue #363)
- PR: https://github.com/drmoisan/drm-copilot/pull/378
- Base branch: epic/legacy-discovery-and-parity-integration
- Head branch: feature/legacy-discovery-analyzer-framework-363
- Trigger: New blocking finding discovered during cycle-1 execution (scope-change rule → new cycle). The cycle-1 merge (pyproject.toml union, commit 1d31dcd0) is complete; this cycle addresses the separately discovered bundle-sync defect.

## Synthetic Blocking Finding

- Severity: Blocking
- Category: bundled-payload-drift (pre-existing integration-branch defect)
- Failing test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- Assertion: every non-memory repo `.claude/**` file must exist byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/**`.

### Root cause

Integration-branch commit `5335075c feat(agents): add four domain-neutral agent personas for legacy-discovery (#365)` added four agent persona files to the repo `.claude/agents/` tree but did not add their counterparts to the bundled `claude-customizations` payload. The defect is present on the integration head (`e5f50108`) independent of this feature; the cycle-1 merge surfaced it in this branch's test suite.

### Drifted files (repo `.claude/agents/` present, bundle missing) — exactly four

- `.claude/agents/legacy-parity-analyst.md`
- `.claude/agents/migration-coverage-reviewer.md`
- `.claude/agents/requirements-reconciler.md`
- `.claude/agents/runtime-characterization-analyst.md`

### Required resolution

Mirror the four files into the bundled payload so the bundle is byte-identical to the repo `.claude/agents/` sources:
- Destination directory: `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`
- Copy each file byte-for-byte from `.claude/agents/<name>.md` to the destination.
- Note: `python -m scripts.dev_tools.push_down_claude_customizations` copies bundle→consumer (the wrong direction) and MUST NOT be used to repair the bundle; the fix is a byte-identical mirror copy INTO the bundle.
- Do not modify the repo `.claude/agents/*.md` source files. Do not touch `.claude/agent-memory/**` or `.claude/settings.local.json` (both exempt from the mirror assertion).
- After the mirror, re-run the full Python QC loop (Black -> Ruff -> Pyright -> Pytest with coverage) to confirm the failing test passes and no regression occurs.

### Scope boundary

If any repo `.claude/**` file OTHER than the four listed above is also found missing/divergent from the bundle, mirror it too (the test asserts the complete non-memory tree), and record each additional file in the execution evidence. If a non-`.claude` blocking issue appears, STOP and report it as a further new finding (do not extend this plan).

### Exit condition

- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes; full Python QC loop green with coverage thresholds intact (line >= 85%, branch >= 75%, no regression).
- PR #378 mergeable state is MERGEABLE against the integration head.
- Reaudit (code-review, feature-audit, policy-audit) reports zero blocking findings.
