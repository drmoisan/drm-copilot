# Remediation Inputs: Test-support hygiene and stale skipif (#938)

Review-Verdict: REMEDIATION_REQUIRED

Timestamp: 2026-10-16T01-05
Branch: `bug/test-support-hygiene-793-skipif-938` (HEAD `91044a5b7`)

Artifacts:
- `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/policy-audit.2026-10-16T01-05.md`
- `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/code-review.2026-10-16T01-05.md`
- `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/feature-audit.2026-10-16T01-05.md`

## Blocking findings

### RI-1: TypeScript coverage artifact is absent (policy-audit PA-1, code-review CR-1)

Remediability: autonomous
Remediability-Evidence: The executor can produce the artifact by running the jest coverage command in the extension and writing the result under the feature evidence folder.

Required outcome:
1. In `extensions/drm-copilot`, run `npx jest --config jest.config.cjs --coverage` (reporters `lcov` and `text-summary` write to `coverage/lcov.info`).
2. Record the command, exit code, and repo-wide line and branch percentages in `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/evidence/qa-gates/ts-jest-coverage.<timestamp>.md` with a write-time UTC timestamp.
3. Confirm line coverage is at least 85% and branch coverage at least 75%; if the figures are below threshold, report them (the change is comment-only, so a regression on the changed line is not possible).
4. Do not write coverage output to `artifacts/coverage/` or any non-canonical evidence path.

## Non-blocking findings

- CR-2 / PA-2: private `_build_read_text_stub` duplicate at `tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py:28` (optional consolidation).
- PA-3: `issue.md` line 5 status path does not match the actual folder name (documentation only).
- Nit: `test_validate_orchestration_artifacts_dispatch.py` imports builders from two modules; the other three builders are outside #938 scope.
