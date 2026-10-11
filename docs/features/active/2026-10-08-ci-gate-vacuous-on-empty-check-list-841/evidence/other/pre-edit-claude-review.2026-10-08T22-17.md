# Pre-Edit Re-Read of the Claude Feature-Review Policy Rules (#841, P4-T1)

Timestamp: 2026-10-10T09-30
Command: git grep -c -F -e 'whose head SHA matches the current branch head' -- .claude/skills/feature-review-workflow/SKILL.md; git fetch origin main; git log --oneline HEAD..origin/main -- .claude/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary:
- `whose head SHA matches the current branch head` -> `.claude/skills/feature-review-workflow/SKILL.md:1`
- `git fetch origin main` -> exit 0 (`* branch main -> FETCH_HEAD`)
- `git log --oneline HEAD..origin/main -- .claude/skills/feature-review-workflow/SKILL.md` -> no output (no #824 commit on main touches this file beyond HEAD)
- Count is 1; the Appendix F1 anchor matches. No stop.

Route: git commands ran exactly as written.

## Current `## Policy Rules` section (lines 66-75), verbatim

Line 66: `## Policy Rules`; line 68: `### modified-workflow-needs-green-run`; line 77: `## Ordered Procedure`.

Trigger sentence (line 70):

> If the branch diff modifies any path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`, the policy audit emits a Blocking finding unless evidence of a green workflow run against the branch head is present in the remediation inputs.

Rule bullets (lines 72-75):

> - The rule provides a second, independent line of defense for CI-gate-modifying features, separate from and prior to the orchestrator's S9 CI green gate.
> - "Green workflow run against the branch head" means a workflow run whose head SHA matches the current branch head and whose conclusion is success for the affected workflow.
> - A green `workflow_dispatch` run against the branch head also satisfies the rule, not only a PR-context run. This mitigates the chicken-and-egg case where a feature must land its CI gate before the gate can run in PR context (see spec.md Risks & Mitigations).
> - When the rule fires and no qualifying green-run evidence is present, record a Blocking finding classified `awaiting_ci` (the remediation inputs carry `Remediability: awaiting_ci` and a `Remediability-Evidence:` line naming the awaited workflow) and route it to the wait path (`AWAITING_CI` when no other class is present) instead of the remediation handoff.
