# Phase 0 Policy-Read Evidence — Issue #272

Timestamp: 2026-07-02T18-45
Policy Order:
1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/powershell-code-change.instructions.md`
5. `.github/instructions/powershell-unit-test.instructions.md`
6. `.claude/rules/general-code-change.md`
7. `.claude/rules/general-unit-test.md`
8. `.claude/rules/powershell.md`
9. `.claude/rules/orchestrator-state.md`

Files read (P0-T1 through P0-T9), in order:
- `.github/copilot-instructions.md` — repository tone and communication policy (strictly professional, factual, neutral tone).
- `.github/instructions/general-code-change.instructions.md` — baseline code change rules (design principles, bugfix workflow, 500-line file cap, mandatory format→lint→type-check→test toolchain loop).
- `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (independence, isolation, determinism, coverage thresholds, AAA structure, no temp files).
- `.github/instructions/powershell-code-change.instructions.md` — PowerShell-specific code change rules (PoshQC MCP toolchain, ShouldProcess, 500-line cap, approved verbs).
- `.github/instructions/powershell-unit-test.instructions.md` — PowerShell-specific unit test rules (Pester v5.x, `*.Tests.ps1` naming, `Describe`/`Context`/`It`, mirrored test-file location).
- `.claude/rules/general-code-change.md` — 500-line file cap, seven-stage toolchain loop, I/O boundary rules (confirmed as already loaded into session context).
- `.claude/rules/general-unit-test.md` — coverage thresholds (>=85% line, >=75% branch), test-file-location rule (confirmed as already loaded into session context).
- `.claude/rules/powershell.md` — PoshQC toolchain (format→analyze→test), `$Invoker`/wrapper design-seam rules, change-budget caps (confirmed as already loaded into session context).
- `.claude/rules/orchestrator-state.md` — remediation-cycle and `human_interaction` invariants; confirmed the new `pr_author_preflight` field is an additive, unrelated top-level checkpoint key and is out of scope for the `remediation_loop`/`human_interaction` invariants defined in this rule (confirmed as already loaded into session context).

Output Summary: All nine policy files read in full before implementation began. No conflicting instructions were found. The PowerShell toolchain contract (PoshQC format -> analyze -> test via MCP functions) and the 500-line file-size cap apply to this feature's in-scope files (`enforce-pr-author-skill.ps1`, `enforce-pr-author-skill.Tests.ps1`, and their mirrors).
