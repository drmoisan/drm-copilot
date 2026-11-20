# Task Check [P3-T2]

Timestamp: 2026-11-20T14-19
Command: sh SCRATCH/issue-1016-tc-p3t2.sh (Black check, Ruff, Pyright on the changed test; launcher pytest -n auto over the selection); sh SCRATCH/issue-1016-tc-p3t2-ps.sh (launcher pester -TestPath <selection>); sh SCRATCH/issue-1016-taskcheck.sh (Prettier and ESLint on the two bundled routing copies, typecheck, launcher jest-extension --testPathPatterns=<routing readers>)
EXIT_CODE: 0
Output Summary: Python static 0 findings (Black "1 file would be left unchanged.", Ruff "All checks passed!", Pyright 0 errors); pytest selection 751 passed, 0 failed; Pester selection 775 tests, 0 failures, 0 errors (exit 0); Jest selection 138 suites, 2366 tests passed, 0 failed; typecheck exit 0. FIX-FLIP row test_active_root_default_is_the_default_active_area passes; test_canonical_and_bundled_routing_config_are_byte_identical passes.

## Changed files

- `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json`, `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`: `development_docs_root` `docs/features` to `.dev`.
- `tests/scripts/dev_tools/test_plan_progress_report.py`: the run B FIX-FLIP row of REHEARSAL (`apply-rehearsal.2026-11-20T13-04.md`), `Path("docs/features/active")` to `Path(".dev/active")`. It is the only run B FIX row; no other test is edited.

## Byte identity of the three copies (compared directly)

SHA-256 prefix `51e18064247f54e3` for all three copies: IDENTICAL.

## Selection and rule

Contract-test rule for a changed configuration path: every test file under `tests/` and `extensions/drm-copilot/test/` that names `orchestration-routing` or `orchestration_routing` (fixtures excluded), plus the edited test. Python: 32 files (dev_tools routing, blast-radius, push-down, codex routing, feature-docs, potential-to-issue, evidence-location suites). Pester: 21 files (model-routing, drift-gate dev root, blast-radius, codex routing, development-docs root, epic-wave, orchestrator-state routing and parity, parallel admission, docs roles, epic progress report, codex epic child launch, legacy codex hooks, stage-timing report, harness agent generation). Jest: suites matching push-down, orchestrator-state validators, development-docs, new-active-feature-folder, new-potential-bug-entry, potential-to-issue promotion, pr-context feature-docs and verification-evidence, codex discovery routing, development-docs matchers, epic planner readiness integrity, packaging, new-potential-entry-root.

## Recorded observation (non-blocking)

Prettier `--check` reports a style warning for the two bundled routing JSON copies. These files are outside the Prettier scope of the TypeScript static gate (`src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs` in `extensions/drm-copilot`), and the edit changes one string value, which does not change formatting; the warning is pre-existing. ESLint reports the two JSON files as ignored (0 errors).
