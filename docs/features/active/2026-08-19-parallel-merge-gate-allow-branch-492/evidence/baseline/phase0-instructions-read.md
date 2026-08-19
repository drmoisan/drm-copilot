# Phase 0 — Policy Instructions Read Evidence

Timestamp: 2026-08-19T08-58

Policy Order: The following policy files were read in the required order before any code or test change, per `CLAUDE.md` Policy Compliance Reading Order and the `policy-compliance-order` skill. PowerShell is the only language in scope for this minor-audit item.

Files read (in order):

1. Repository tone and communication policy
   - `.github/copilot-instructions.md` (tone policy authority)
   - `CLAUDE.md` (standing instructions; loaded into context)
2. Baseline code-change policy
   - `.github/instructions/general-code-change.instructions.md`
   - `.claude/rules/general-code-change.md` (loaded into context)
3. Baseline unit-test policy
   - `.github/instructions/general-unit-test.instructions.md`
   - `.claude/rules/general-unit-test.md` (loaded into context)
4. PowerShell-specific policy (language in scope)
   - `.github/instructions/powershell-code-change.instructions.md`
   - `.github/instructions/powershell-unit-test.instructions.md`
   - `.claude/rules/powershell.md` (loaded into context)
5. Module rigor tiers
   - `.claude/rules/quality-tiers.md` (loaded into context)
6. Parallel orchestration artifact invariants (checkpoint schema, enums)
   - `.claude/rules/parallel-orchestration.md` (loaded into context)

Notes:
- Coverage policy: line coverage >= 85% (uniform across tiers). Pester does not measure branch coverage; no branch-coverage gate applies to PowerShell.
- Toolchain contract: PoshQC format -> PSScriptAnalyzer analyze -> Pester test via MCP server functions; restart from format on any change or failure.
- File size limit: production PowerShell files must remain under 500 lines.
- Parallel checkpoint schema facts confirmed: `route_id` must equal exactly `'parallel'`; per-item `merge_status` enum includes `ci_green`; per-item `pr_number` field sits directly on each `items[]` entry.
