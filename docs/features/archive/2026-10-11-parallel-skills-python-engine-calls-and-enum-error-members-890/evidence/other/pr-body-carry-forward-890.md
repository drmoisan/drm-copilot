# PR-Body Carry-Forward Note (Issue #890)

Timestamp: 2026-10-12T20-31
Task: P2-T10

## Operator-Accepted Residual Risks

Copied verbatim from `issue.md` `## Operator-Accepted Residual Risks`. Acceptance status: accepted by the operator for #791, unchanged by #890.

Source: `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md` (around line 282), restated in PR #875 under "Operator-accepted residual risks" and in that folder's `feature-audit.2026-10-10T09-05.md` (around line 74). Acceptance status: accepted by the operator for #791; unchanged by #890. The operator may revisit this acceptance.

- (a) A timed-out hook does not block, and the call continues through the normal permission flow, where the abandon allow entry would then skip the prompt.
- (b) An installed plugin mod that handles `tool.check` can approve a hook-blocked call regardless of the allow entries.

The new allow entry `"Bash(bash .claude/lib/bash/mutate-parallel-run.sh*)"` names a non-destructive script that carries no abandon disposition token, so it alters neither risk.

## Follow-ups (not filed)

- `has_unresolved_drift` and `request_requeue_via_recolor` in `parallel-orchestrate/SKILL.md` remain Python-only seams with no destination-runtime port. No issue is filed by this run.

## Decisions

- AC-3: the inline-code grant `"Bash(poetry run python -c *)"` was removed from `.claude/agents/parallel-orchestrator.md` and its bundled mirror; see `evidence/other/python-c-grant-decision-890.md`.
- AC-2 and AC-6 remain unchecked pending PR CI (P2-T14): the `shell-coverage / Shell Coverage (Bats + kcov)` job must pass on the PR head with the new bats suites included, and its `Bash coverage (lines):` value and per-file line rates must be recorded.
- AC-2's 500-line clause is applied to non-Markdown files under the Markdown documentation exemption; see `evidence/other/file-sizes-890.md`.
