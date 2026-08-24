# Phase 0 Policy Read Evidence — Issue #516

Timestamp: 2026-08-24T09-52

Policy Order: `CLAUDE.md` → `.claude/rules/general-code-change.md` → `.claude/rules/general-unit-test.md` → `.claude/rules/powershell.md` → `.claude/rules/quality-tiers.md` → `.claude/rules/plan-acceptance-gates.md` → feature requirement sources (`spec.md`, `research/research.2026-08-24T09-50.md`, `issue.md`).

Files read (nine, in order):

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/plan-acceptance-gates.md`
7. `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/spec.md`
8. `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/research/research.2026-08-24T09-50.md`
9. `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/issue.md`

Notes carried into execution:

- PowerShell toolchain order is format → analyze → test via the PoshQC MCP tools; restart from format whenever a stage fails or changes a file.
- Per-batch cap is 3 production and 3 test PowerShell files; four production hook copies force the two-batch split described in the plan.
- Line coverage threshold is >= 85% uniformly; Pester measures no branch coverage, so no branch gate applies.
- Every `.ps1` file must remain under 500 lines.
- Tests must not create temporary files and must not depend on the current working directory.
