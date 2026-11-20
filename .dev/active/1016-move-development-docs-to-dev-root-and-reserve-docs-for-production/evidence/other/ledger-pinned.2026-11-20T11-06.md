# LEDGER_PINNED derivation ([P1-T2])

Timestamp: 2026-11-20T11-06
Command: pwsh -NoProfile -File SCRATCH/issue-1016-p1t2.ps1 SCRATCH/issue-1016-p0t3b-targets.txt (imports scripts/dev-tools/ProcessReductionChain.psm1 and ProcessReductionLedger.psm1 read-only; Read-ProcessReductionChainInput -RepositoryRoot <worktree>; Get-ProcessReductionPatchHunk over every stored patch; Get-ProcessReductionLanding over every entry; git -C <worktree> ls-files docs/features docs/research docs/engineering docs/discovery); pwsh -NoProfile -File SCRATCH/issue-1016-p1t2b.ps1 (region-level token checks for the hand edits)
EXIT_CODE: 0
Output Summary: Every header and heading path under docs/ starts with a LEDGER_FALLBACK_ROWS prefix (0 uncovered). 72 region lines outside the ledger folder hold a MAPPING_PREFIXES occurrence; 27 name a tracked moved path, every one in a file and entry that LEDGER_REGEN names, except two directory references to docs/features/active/ in the 0008 hunks of .claude/rules/plan-acceptance-gates.md and its bundle copy (REWRITE_EXCLUSIONS member 5, A6 policy Stay, byte-identical through the apply; a directory, not a path git ls-files lists). No relative Markdown link lies in any region. No hand edit falls inside a recorded region outside LEDGER_REGEN. No stop condition fires. Raw output: SCRATCH/issue-1016-ledger-pinned-raw.txt.

## Header and heading paths

Every patch header path and revert-block heading path under docs/ starts with docs/features/templates/ or docs/engineering/: 0 UNCOVERED.

## LEDGER_PINNED (files outside the ledger folder whose recorded regions hold a MAPPING_PREFIXES occurrence)

| File | Entry and region | Matched occurrence | Class |
| --- | --- | --- | --- |
| .claude/skills/atomic-plan-contract/SKILL.md | 0001 hunk 56; 0008 hunk 9 | Final-phase self-review bullet, docs/features/templates/policy_audit/ | tracked; LEDGER_REGEN 0001, 0008 |
| .agents/skills/atomic-plan-contract/SKILL.md | 0001 hunk 1; 0008 hunk 1 | same bullet | tracked; LEDGER_REGEN 0001, 0008 |
| extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md | 0001 hunk 340; 0008 hunk 18 | same bullet | tracked; LEDGER_REGEN 0001, 0008 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md | 0001 hunk 383; 0008 hunk 20 | same bullet | tracked; LEDGER_REGEN 0001, 0008 |
| tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | 0001 hunk 650 (create); 0006 hunk 568 (modify) | AUDIT-TEMPLATE and AUDIT-AGENTS paths; sweep root 'docs/features/templates' | tracked; LEDGER_REGEN 0001, 0006 |
| tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | 0009 hunk 73 (create) | TEMPLATE and AUDIT-AGENTS paths | tracked; LEDGER_REGEN 0009 |
| .claude/rules/plan-acceptance-gates.md and its claude-customizations bundle copy | 0008 hunks 6 and 15 | "the 31 plans in docs/features/active/" (directory reference) | member 5 exclusion; unchanged |
| extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts | 0001 hunks 646, 647 | docs/features/active/example/... | injected; M10 glob |
| tests/scripts/dev_tools/test_validate_policy_audit_artifact.py | 0001 | docs/features/active/example/... | injected; M10 glob |
| extensions/drm-copilot/test/lib/validate/plan-gate-guideline-cutoff.test.ts | 0008 hunk 34 (create) | docs/features/active/f/plan... | injected; M10 glob |
| tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py | 0008 | docs/features/active/f/plan... | injected; M10 glob |
| tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1 | 0010 hunk 53 | docs/features/active/2026-11-08-upstream-901/... | injected; M10 glob |
| tests/scripts/claude-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1 | 0010 hunk 54 | docs/features/active/2026-11-08-upstream-901/... | injected; M10 glob |
| tests/scripts/codex-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1 | 0010 hunk 57 | docs/features/active/2026-11-08-upstream-901/... | injected; M10 glob |
| tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | 0010 hunk 58 (context) | comment naming Edit(docs/features/epics/**) | injected; M10 glob |
| tests/fixtures/epic_wave_barrier/early-start-edge-cases.json | 0010 | docs/features/active/... (23 lines) | injected; member 1 |
| docs/engineering/claude-code-architecture.md | 0005 block (first landing) | docs/ occurrence in the block text | moves with docs/engineering; links-only leaves the text; read through the fallback |

## Region-level intersection with HAND_EDIT_TARGETS

| Hand edit | Token | Region hits | Result |
| --- | --- | --- | --- |
| atomic-plan-contract applicability bullet ([P3-T9]) | docs/engineering/process-reductions/ | 0 | outside every region |
| atomic-plan-contract preflight-fix-record sentence ([P3-T9]) | preflight-fix-record: | 0 | outside every region |
| atomic-plan-contract Final-phase self-review bullet ([P3-T9]) | Final-phase self-review | 8 (0001 and 0008, one per copy) | LEDGER_REGEN rows 0001 and 0008 |
| execution-environment brief source and bundle copy ([P3-T10]) | docs/features, docs/engineering | 0 | outside every region |
| FT_BYTE_PAIRS plan link lines ([P3-T4]) | .github/instructions/ | 1: 0001 hunk 625 of the feature plan bundle copy, which holds the [P0-T1] task line with backticked paths (hunk at line 23); the link lines are lines 12 and 13 | link lines outside every region |
| parallel_orchestrator_surface_expectations.py KICKOFF_IDENTITY_FRAGMENTS ([P3-T6]) | written literally as | 0 (the 0010 hunk 58 holds a different comment) | outside every region |
| parallel-gate-wording.Tests.ps1 ([P3-T9]) | docs/features/templates | 0001 hunk 650, 0006 hunk 568 | LEDGER_REGEN rows 0001 and 0006 |
| less-evidence-contract.Tests.ps1 ([P3-T9]) | docs/features/templates | 0009 hunk 73 | LEDGER_REGEN row 0009 |

Other HAND_EDIT_TARGETS (routing copies, config/blast-radius.json and its test, the epic manifest, the A19 hand edits and test supports of [P3-T7], claude-architecture-doc.Tests.ps1, test_discovery_documentation_contracts.py, ProcessReductionChain.psm1 and its test) are named by no recorded region.

## Decision recorded

The two docs/features/active/ directory references in the plan-acceptance-gates.md copies are not treated as a stop: git ls-files lists files, not this directory, the files are REWRITE_EXCLUSIONS member 5 and stay byte-identical through the apply, and tree-recheck.2026-11-20T08-11.md (M10) recorded them as already covered. Recommended-option decision under OD-1 (autonomous mode).
