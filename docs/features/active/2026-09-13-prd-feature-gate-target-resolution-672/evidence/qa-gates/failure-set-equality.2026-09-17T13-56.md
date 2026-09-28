# Remediation gate 6 — the repository-wide failing node set

Timestamp: 2026-09-17T13-56

Task: `[P4-T5]` of `remediation-plan.2026-09-17T12-29.md`

Source: the `artifacts/pester/pester-junit.xml` produced by the `[P4-T3]` C3 run. No new test run was
performed by this task; it reads the report that run emitted.

Command, **C7**:
`$junit = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml'); $junit.testsuites.tests; $junit.testsuites.failures; $junit.testsuites.errors; @($junit.SelectNodes('//testcase[failure]')) | ForEach-Object { $_.name }`

EXIT_CODE: 0

Output Summary:

## Count and members

`//testcase[failure]` node count: **2**. This is the expected count.

Full `name` attribute of each member:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

`errors` attribute: **0**.

## Set-membership verdict

Every member of the failing node set is one of the two named nodes:

| member | contains the named literal | named node it is |
| --- | --- | --- |
| 1 | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | the first named node, in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` |
| 2 | `allows every registered handler for every tool name its own matcher admits` | the second named node, the Codex PreToolUse integration suite |

**No member lies outside the pair, and `errors` is 0. The gate passes.**

## Why these two are not regressions of this remediation

Both nodes read ambient state rather than modelled state, and both failed identically at the `[P0-T6]`
pre-change baseline, before any file in this remediation's file set was edited:

1. Member 1 is wall-clock and receipt-dependent and reads the real orchestrator checkpoint through an
   unmocked `Get-PrAuthorCheckpointContent` seam.
2. Member 2 reads ambient epic-checkpoint state.

Neither `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, nor the Codex suite, nor
`.claude/hooks/enforce-pr-author-skill.ps1`, nor `.claude/hooks/enforce-epic-wave-barrier.ps1`, nor any
`.codex/` path was edited by this remediation. `[P4-T6]` records the anchored changed-file enumeration that
verifies their absence from the change set.

## The count branches, stated as the plan fixes them

- A count **above 2** necessarily introduces a member outside the pair and therefore fails this gate. Not
  observed.
- A count of **0 or 1** passes this gate and is recorded with the missing member named, because the two nodes
  read ambient state and their disappearance is not an outcome of this remediation. Not observed; no member
  disappeared, so there is no member to name here.
- The observed count is **2**, matching the pair exactly.

This artifact records the count and every member rather than only the verdict, so a later reader can see the
pair is reproducible in this environment rather than inferring it.

Acceptance: every member of the failing node set is one of the two named nodes, and the `errors` attribute is
0. Satisfied.
