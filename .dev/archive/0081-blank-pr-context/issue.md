# blank-pr-context (Issue #81)

- Date captured: 2026-03-05
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blank-pr-context/ (Issue #81)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #81
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/81
- Last Updated: 2026-03-05
- Work Mode: full

## Summary

When the extension exposes internal tooling to a destination workspace, PR-context collection from `scripts/dev_tools/pr_context` creates the output artifact but leaves it empty (or effectively empty), while `collect_commit_context.py` succeeds under the same workflow.

## Environment

- OS/version: Windows (workspace host)
- Python version: `>=3.10,<4.0` (repo constraint in `pyproject.toml`)
- Command/flags used: Extension-side execution flow that exposes and runs tooling in a destination workspace
- Data source or fixture: Destination workspace Git repository context (branch, base comparison, changed files/diffs)

## Steps to Reproduce

1. Use the `drm-copilot` extension to expose internal tooling to a destination workspace.
2. Run `collect_commit_context.py` (control) and then run PR-context collection from `scripts/dev_tools/pr_context` in the same destination workspace flow.
3. Inspect generated artifacts in the destination workspace.

## Expected Behavior

PR-context artifacts should be populated with expected branch/base comparison and diff context when generated in destination workspaces, just like commit-context artifacts are populated.

## Actual Behavior

The destination artifact path is created correctly, but PR-context content is empty (or effectively empty for downstream use). This indicates collection/rendering references are not resolving correctly under extension-side execution.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
	- Commit context artifact is populated using `collect_commit_context.py` in destination workspace.
	- PR-context artifact from `scripts/dev_tools/pr_context` is created but lacks expected context payload.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Likely path/reference resolution mismatch when PR-context package runs from extension-exposed location in destination workspace. Candidate areas to inspect:
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/render.py`
- `scripts/dev_tools/pr_context/render_pr_helpers.py`

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
	- Add regression tests for destination-workspace execution path to ensure PR-context artifacts are non-empty when git context exists.
- [x] Integration scenario to retest
	- End-to-end extension exposure workflow: compare commit-context vs PR-context artifact generation in destination workspace.
- [x] Manual verification notes
	- Re-run destination-workspace PR-context generation and confirm output includes expected context body.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

## 2026-03-05 Implementation Outcome

- Replaced placeholder-only bundled PR collector output with substantive git-backed summary/appendix rendering in `extensions/scaffold-extension/resources/templates/collect_pr_context.py`.
- Preserved extension invocation CLI flags: `--base`, `--out`, and `--appendix-out`.
- Added deterministic error-path handling so unrecoverable git/data failures return non-zero exit with stderr context.
- Locked regression behavior with extension tests so placeholder-only summary/appendix content is explicitly rejected by test expectations.

Evidence links:
- Red regression evidence: `evidence/regression-testing/ts-regression-red.2026-03-05T10-42.md`
- Green regression evidence: `evidence/regression-testing/ts-regression-green.2026-03-05T10-42.md`
- Final TypeScript QA: `evidence/qa-gates/ts-format.2026-03-05T10-42.md`, `evidence/qa-gates/ts-lint.2026-03-05T10-42.md`, `evidence/qa-gates/ts-typecheck.2026-03-05T10-42.md`, `evidence/qa-gates/ts-test.2026-03-05T10-42.md`
- Final Python QA: `evidence/qa-gates/py-format.2026-03-05T10-42.md`, `evidence/qa-gates/py-lint.2026-03-05T10-42.md`, `evidence/qa-gates/py-typecheck.2026-03-05T10-42.md`, `evidence/qa-gates/py-test-cov.2026-03-05T10-42.md`
- Coverage delta: `evidence/qa-gates/coverage-delta.2026-03-05T10-42.md`

## 2026-03-05 Agentic Error Correction

- Agentic error: the first implementation replaced empty placeholder output by adding rich rendering logic directly inside `extensions/scaffold-extension/resources/templates/collect_pr_context.py`.
- Why this was wrong: it duplicated logic already owned by `scripts/dev_tools/pr_context`, creating drift risk and violating the requirement that extension-side and repo-side artifacts be identical.
- Correction implemented: `drm-copilot: Collect PR Context` now executes the canonical package module `scripts.dev_tools.pr_context.collector` directly from the destination workspace context.
- Compatibility note: the bundled `collect_pr_context.py` template is now only a thin wrapper delegating to the canonical module and contains no PR-context rendering logic.