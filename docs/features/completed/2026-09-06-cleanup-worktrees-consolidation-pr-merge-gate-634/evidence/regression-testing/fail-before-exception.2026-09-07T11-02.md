Timestamp: 2026-09-07T11-02

WhyFailingRunImpossible: The defect this feature fixes is an omission in prose: step 5 of
`.claude/skills/cleanup-merged-worktrees/SKILL.md`'s End-to-End Workflow did not name who
performs the consolidation merge or why. There is no assertion anywhere in the repository
that fails on this omission today — no test targets the prose content of a skill document's
Markdown body. Fabricating a failing test for a prose-only defect is prohibited by
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, which requires a fail-before
exception dossier plus an alternative proof when a failing run is structurally impossible,
rather than a contrived or synthetic failing test.

Alternative proof: the Phase 0 baseline artifact
`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/baseline/token-absence-before.2026-09-07T10-56.md`
recorded that all nine asserted tokens (`human-performed`, `EPIC_MERGE_GATE_BLOCKED`,
`settings.json`, `permissions.allow`, `strict_required_status_checks_policy`, `unbounded`,
`epic_mode`, `step9_status`, `enforce-epic-merge-gate.ps1`) were absent from
`.claude/skills/cleanup-merged-worktrees/SKILL.md` before the change (`rg` exit 1, zero match
lines). The Phase 2 artifacts for AC-1 through AC-7 record the same tokens present after the
change, each with `rg` exit 0 and at least one match line inside the required section:

- AC-1: `evidence/qa-gates/ac-01-human-performed.2026-09-07T11-02.md`
- AC-2: `evidence/qa-gates/ac-02-deny-reason.2026-09-07T11-02.md`
- AC-3: `evidence/qa-gates/ac-03-permission-blocker.2026-09-07T11-02.md`
- AC-4: `evidence/qa-gates/ac-04-strict-checks-policy.2026-09-07T11-02.md`
- AC-5: `evidence/qa-gates/ac-05-unbounded-wait.2026-09-07T11-02.md`
- AC-6: `evidence/qa-gates/ac-06-checkpoint-evasion-forbidden.2026-09-07T11-02.md`
- AC-7: `evidence/qa-gates/ac-07-cross-reference.2026-09-07T11-02.md`

Those seven criteria therefore genuinely fail before the change (token absent, `rg` exit 1)
and pass after it (token present, `rg` exit 0), which is the fail-before/pass-after property
this dossier substitutes a paired before/after search assertion for, in place of a
conventional failing-then-passing test run.
