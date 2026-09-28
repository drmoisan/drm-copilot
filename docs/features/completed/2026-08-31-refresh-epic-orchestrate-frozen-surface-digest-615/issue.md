# refresh-epic-orchestrate-frozen-surface-digest (Issue #615)

- Date captured: 2026-08-31
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/refresh-epic-orchestrate-frozen-surface-digest/ (Issue #615)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #615
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/615
- Last Updated: 2026-08-31
- Work Mode: full-bug

## Summary

The last merge into `main` changed the checked-in `.claude/skills/epic-orchestrate/SKILL.md` content without refreshing its pinned SHA-256 digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. The frozen-surface contract therefore fails in CI and blocks release validation.

## Environment

- OS/version: GitHub Actions runner
- Python version: 3.11
- Command/flags used: Repository quality-checks workflow, job `quality-checks7 / Code Quality & Tests (3.11)`
- Data source or fixture: Repository bytes at merge head `1432ff895c57113702db70deb2dbb092cefe0296`

## Steps to Reproduce

1. Check out the merge head `1432ff895c57113702db70deb2dbb092cefe0296`.
2. Run the frozen-surface contract in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
3. Compare the computed digest for `.claude/skills/epic-orchestrate/SKILL.md` with `PINNED_FROZEN_SURFACE_HASHES`.

## Expected Behavior

The pinned tuple for `.claude/skills/epic-orchestrate/SKILL.md` matches the SHA-256 digest of the intentionally updated runtime document, and the frozen-surface contract passes.

## Actual Behavior

CI reported a digest mismatch in `quality-checks7 / Code Quality & Tests (3.11)`. The expectation was `d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b`; the observed merge-head digest is `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`. The run completed with 4,244 passed and 5 skipped tests, with this frozen digest assertion failing.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: GitHub Actions run `33379396439`, job `quality-checks7 / Code Quality & Tests (3.11)`, reports the frozen digest assertion as the only test failure.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The merge intentionally changed four lines in `.claude/skills/epic-orchestrate/SKILL.md`, replacing the prior validation wording with the MCP validation call and `require_complete` argument. The corresponding expectation retained the former digest. The second frozen-file pin and the runtime skill mirror are not implicated.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: update only the matching `.claude/skills/epic-orchestrate/SKILL.md` tuple in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; retain the contract assertion and the other frozen-file pin.
- [x] Integration scenario to retest: rerun `test_parallel_orchestrator_surface_contracts.py` and the required Python format, lint, type-check, and pytest gates.
- [x] Manual verification notes: independently compute the SHA-256 from the exact runtime-file bytes and confirm the runtime skill, mirror, fragment expectations, and unrelated tuple remain unchanged.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
