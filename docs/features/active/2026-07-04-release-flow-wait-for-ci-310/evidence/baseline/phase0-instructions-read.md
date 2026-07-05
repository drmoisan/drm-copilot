# Phase 0 Instructions Read (Issue #310)

Timestamp: 2026-07-04T22-10

Policy Order: The mandatory policy files were read in the order specified by plan task [P0-T1].

Note on path correction: the plan text names `.claude/rules/CLAUDE.md`. No such file exists in this
repository (`.claude/rules/` contains no `CLAUDE.md`, and there is no root `CLAUDE.md`). `CLAUDE.md`
in this repository's convention refers to the standing instructions auto-loaded into every session
(per `.claude/skills/policy-compliance-order`: "CLAUDE.md (standing instructions, always loaded)").
This matches the precedent recorded in
`docs/features/active/2026-07-04-enforce-model-selection-routing-305/evidence/baseline/phase0-instructions-read.md`.
Those standing instructions were already present in session context prior to this task.

Files read (in order):
1. `CLAUDE.md` (standing instructions; auto-loaded into session context prior to task start)
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`

Output Summary: All five mandatory policy files/contexts were read in the prescribed order prior to
any implementation. Key constraints captured: 500-line file limit; line coverage >= 85%, branch
coverage >= 75% with no regression on changed lines; PowerShell toolchain order format -> analyze ->
test (Pester v5.x) via PoshQC MCP tools, restart from step 1 on any failure or file change; wrapper
seam pattern (`Invoke-<Tool>Exe -<Tool>Args`) is the required mocking seam, never mock the external
executable directly; no sleeps/retries/timing hacks to stabilize flaky *tests* (does not prohibit the
in-scope production bounded-retry feature itself, which is the object of this plan).
