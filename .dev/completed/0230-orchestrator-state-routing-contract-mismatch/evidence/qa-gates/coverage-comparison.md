# Coverage Comparison — Baseline vs Post-Change

Timestamp: 2026-06-24T17-55

## Baseline (Phase 0, P0-T6)

- Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
- TOTAL line coverage: 83%
- TOTAL branch coverage: (2994 - 420) / 2994 = 85.97% (~86%)
- Tests: 1168 passed, 19 skipped
- Routing module scripts/dev_tools/_orchestrator_state_routing.py: 89%

## Post-Change (Phase 5, P5-T4)

- Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
- TOTAL line coverage: 83%
- TOTAL branch coverage: (2994 - 420) / 2994 = 85.97% (~86%)
- Tests: 1169 passed, 19 skipped (added parity test)
- Routing module scripts/dev_tools/_orchestrator_state_routing.py: 89%

## Delta and Changed-Line Non-Regression

- Line coverage delta: 0 percentage points (83% -> 83%).
- Branch coverage delta: 0 percentage points (85.97% -> 85.97%).
- Routing module coverage delta: 0 percentage points (89% -> 89%).

The only changed source files are:
- config/orchestration-routing.json (JSON data; not coverage-measured)
- extensions/drm-copilot/resources/config/orchestration-routing.json (JSON mirror; not coverage-measured)
- .claude/skills/orchestrate/SKILL.md (Markdown; not coverage-measured)
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md (Markdown mirror; not coverage-measured)
- tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py (test; assertion-literal/fixture-value update only)
- tests/scripts/dev_tools/test_orchestration_routing_config_parity.py (new test)

No production Python line was added, removed, or modified. Therefore there are
no changed production lines whose coverage could regress. The
_orchestrator_state_routing.py production module is unchanged and its coverage
is identical to baseline at 89%.

## Outcome

No coverage regression versus baseline. All measured coverage values are
present (numeric, not placeholders). The pre-existing TOTAL line coverage of
83% is unchanged by this work; this change does not introduce or worsen the
gap. Outcome: PASS for the no-regression requirement applicable to this change.
