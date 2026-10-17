# Phase 0 Instructions Read (Remediation Cycle 1)

Timestamp: 2026-10-16T06-45
Plan: docs/features/active/subagentstop-artifact-gates-review-notes-929/remediation-plan.2026-10-16T05-25.md
Tasks: P0-T1 to P0-T12

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/powershell.md
5. .claude/rules/quality-tiers.md
6. .github/copilot-instructions.md
7. .github/instructions/general-code-change.instructions.md
8. .github/instructions/general-unit-test.instructions.md
9. .github/instructions/powershell-code-change.instructions.md
10. .github/instructions/powershell-unit-test.instructions.md
11. .claude/rules/tonality.md
12. .github/instructions/tonality.instructions.md

## Files read (19)

Policy files (P0-T1 to P0-T11):
1. CLAUDE.md (read in full; policy reading order noted; orchestration checkpoint path `artifacts/orchestration/orchestrator-state.json` noted)
2. .claude/rules/general-code-change.md (read in full; 500-line limit, toolchain loop order format, lint, type check, architecture, unit, contract, integration; no temporary files in tests)
3. .claude/rules/general-unit-test.md (read in full; 85% line default; PowerShell branch-coverage exemption; coverage exclusion policy)
4. .claude/rules/powershell.md (read in full; format, analyze, test through PoshQC)
5. .claude/rules/quality-tiers.md (read in full)
6. .github/copilot-instructions.md (read in full)
7. .github/instructions/general-code-change.instructions.md (read in full)
8. .github/instructions/general-unit-test.instructions.md (read in full)
9. .github/instructions/powershell-code-change.instructions.md (read in full)
10. .github/instructions/powershell-unit-test.instructions.md (read in full)
11. .claude/rules/tonality.md (read in full)
12. .github/instructions/tonality.instructions.md (read in full)

Tier configuration (P0-T5):
13. quality-tiers.yml (`.claude/hooks` entry: `tier: T3`; no property-test or mutation obligation applies)

Remediation inputs and review set (P0-T12):
14. docs/features/active/subagentstop-artifact-gates-review-notes-929/remediation-inputs.2026-10-16T05-25.md (`Review-Verdict: REMEDIATION_REQUIRED`; findings F1 to F4)
15. docs/features/active/subagentstop-artifact-gates-review-notes-929/policy-audit.2026-10-16T05-25.md
16. docs/features/active/subagentstop-artifact-gates-review-notes-929/code-review.2026-10-16T05-25.md
17. docs/features/active/subagentstop-artifact-gates-review-notes-929/feature-audit.2026-10-16T05-25.md
18. docs/features/active/subagentstop-artifact-gates-review-notes-929/issue.md (`- Work Mode: full-bug`)
19. docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md (`## Acceptance Criteria`: 27 AC lines, AC-01 to AC-25 checked, AC-26 and AC-27 unchecked)

Output Summary: 19 files read in the order above; 12 policy files, quality-tiers.yml, the remediation inputs, the three review artifacts, issue.md, and spec.md. Evidence text in this cycle uses the professional tone required by the two tonality files.
