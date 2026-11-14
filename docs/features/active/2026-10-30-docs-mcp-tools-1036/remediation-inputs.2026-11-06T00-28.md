# Review disposition inputs: docs-mcp-tools (#1036)

Review-Verdict: AWAITING_CI
Timestamp: 2026-11-06T00-28
Issue: 1036
Base: epic/documentation-estate-tooling-integration
Merge-Base: 82492b61a7788befcde52353a6fc3925c99a783c
Reviewed-Head: ca0d5c2dc29d29c4d70468957ee8eb911085cb05

## Disposition

There is one non-remediable finding that waits on CI, and there are zero autonomous findings. Do not create a remediation plan target and do not delegate atomic-planner. REMEDIATION_PLAN: NONE. Local formatting, lint, type check, unit, integration, coverage, file-size and evidence-location gates pass.

## Finding PA-1

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The stage 6 test filters out paths with a worktrees component (line 454), so it finds zero brief copies in this agent checkout. The six copies hash identically. Only the ci.yml run on the PR head can record a pass.

- Location: `tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` (unchanged by this branch); brief copies under `.claude/`, `.agents/`, `.github/` and `extensions/drm-copilot/resources/`.
- Affected acceptance criteria: spec SAC-27 and SAC-31; user story US2-6 and US3-6. Affected plan tasks: [P7-T4], [P8-T7], [P8-T13].
- Current evidence: `evidence/qa-gates/contract-tests-final.2026-11-06T00-09.md` (42 passed, 1 failed with `assert 0 == 6`). Reviewer MD5 of all six copies is `fe43258b50ec159b4fafdeef50efb595`.
- Coordinator-owned next action: open the PR into `epic/documentation-estate-tooling-integration` and dispatch `ci.yml` against the branch head, because epic-child PRs do not trigger it automatically. When `ci_gate.conclusion` is `success`, the item's orchestrator run checks off the four criteria and three plan tasks at S9, commits and pushes, and re-runs the CI gate so that `ci_gate.head_sha` equals the final PR head.
- Expected exit condition: CI passes on the final PR head, including the stage 6 contract test.

## Nonblocking notes

- Spec `### Tool input tables` and `### Option emission` still describe `limit` as a positive integer. The implementation follows plan D-1, a `diagnostic-`-prefixed identifier backed by `evidence/baseline/upstream-grammars.2026-11-05T23-35.md`. An optional spec wording update is suggested; no code change is needed.
- `src/mcp-docs-tool-definitions.ts` has one unreachable description fallback branch (13/14 branches). It is above the threshold.

## Context Package

- Policy audit: `docs/features/active/2026-10-30-docs-mcp-tools-1036/policy-audit.2026-11-06T00-28.md`
- Code review: `docs/features/active/2026-10-30-docs-mcp-tools-1036/code-review.2026-11-06T00-28.md`
- Feature audit: `docs/features/active/2026-10-30-docs-mcp-tools-1036/feature-audit.2026-11-06T00-28.md`
- Requirements: `docs/features/active/2026-10-30-docs-mcp-tools-1036/spec.md`, `docs/features/active/2026-10-30-docs-mcp-tools-1036/user-story.md`; `issue.md` supplies the `full-feature` marker.
- Plan: `docs/features/active/2026-10-30-docs-mcp-tools-1036/plan.2026-10-30T18-58.md`
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent; no pull request exists yet.

## Do Not Do

- Do not edit the test's `worktrees` path filter to make it pass locally.
- Do not check off the four pending criteria from local evidence.
- Do not create a remediation plan for this finding.
