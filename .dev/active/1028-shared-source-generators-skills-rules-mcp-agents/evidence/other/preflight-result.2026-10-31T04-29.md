# Preflight Result (Issue #1028)

Timestamp: 2026-10-31T04-29
Plan: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED

PREFLIGHT-FIX: [P0-T9] | literal-formatting / tool route | check mode stated as Invoke-PoshQCFormat with a recording, non-writing -WriteFile script block
PREFLIGHT-FIX: [P1-T3] | validator-blind tracked-file listing | stage scripts/harness-generation/HarnessGeneration.psm1 with git add before check_quality_tiers, which discovers projects from git ls-files
PREFLIGHT-FIX: [P1-T6] | evidence filename | counts recorded in a new phase1-pester.<timestamp>.md instead of appended
PREFLIGHT-FIX: [P1-T9] | literal-formatting pathspec | both MCP bundle paths added to the git diff pathspec
PREFLIGHT-FIX: [P3-T1] | stale anchor | Copilot frontmatter renders optional name: and description:
PREFLIGHT-FIX: [P3-T3], [P3-T5] | stale anchor | claudeUnconditional declarations placed with the tasks that create general-code-change, general-unit-test, tonality ([P3-T3]) and quality-tiers ([P3-T5])
PREFLIGHT-FIX: [P3-T9] | citation completion | rule-skill entry update sets target_paths and owner_child 3 as child 1's schema requires for generated
PREFLIGHT-FIX: [P4-T3], [P4-T5] | stale anchor | protected agent names moved to [P4-T3] because epic-orchestrator and pr-author fall in the first and second thirds
PREFLIGHT-FIX: [P6-T5] | evidence path spelling | full <FEATURE>/evidence/qa-gates/ prefix on all three artifacts
PREFLIGHT-FIX: [P6-T13] | AC tracking wording | evidence cited in the AC status summary; criterion text not modified
PREFLIGHT-DEFECT: spec.md AC "PINNED_FROZEN_SURFACE_HASHES is re-baselined" (plan AC row S-SK-4) | acceptance criterion with no implementing task / spec-plan contradiction | The spec requires a re-baseline with a dated comment (Skill mirror AC 4; Behavior bullets under "Surface: skill mirror" and "Surface: agents"; the Language Classification row "PINNED_FROZEN_SURFACE_HASHES re-baseline ... in-place edit"; Implementation Strategy Phase 2 and Phase 4 "hash re-baseline"), while the plan, PQ-2 and the spec's own PQ-2 row state that the pinned files are protected, render byte-equal and are not re-baselined. No task re-baselines, so [P6-T13] cannot check this AC. Required change: amend those five spec locations to the PQ-2 outcome (the constant is unchanged because both pinned files render byte-equal, and the tests that read tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py pass unchanged), keeping S-SK-4 mapped to [P2-T10] and [P4-T7].
PREFLIGHT-DEFECT: [P0-T2] | missing gate check (assertion change) | spec "### Phase 0 gate (execution-time requirement)" item 2 requires that "contracts exist for the shared set", and [P0-T2] does not check it. Required change: add to [P0-T2]'s check list: for every matrix entry with kind skill, ecosystem codex and disposition shared, .agents/skills/<name>/references/standard.md and its bundle copy under extensions/drm-copilot/resources/codex-and-agents-customizations/ exist; a missing contract ends the record with GATE: STOP.

preflight-fix-record: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/evidence/other/preflight-fixes.2026-10-31T04-29.md
