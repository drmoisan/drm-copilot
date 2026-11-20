# Production Root Search [P4-T4]

Timestamp: 2026-11-20T16-13
Command: sh SCRATCH/issue-1016-p4t4.sh: git grep -n -E 'docs.{1,8}(features|research|engineering|discovery)' -- .claude/hooks .claude/lib .codex/hooks .codex/scripts scripts extensions/drm-copilot/src; git grep -n -E "[\"']docs[\"']" over the same roots; node SCRATCH/issue-1016-p1t3prod.cjs (the [P1-T3] classifier) against the post-apply report dev-docs-migration-dry-run.2026-11-20T16-11.json and DECISIONS folder-rename-decisions.2026-11-20T12-24.json; manual review of each match the classifier did not place
EXIT_CODE: 0
Output Summary: 251 + 14 lines, 263 distinct matches: 248 STAY_ENTRIES (a REWRITE_EXCLUSIONS glob, which includes members 4 and 12, the A19 STAY rows and child 2's resolver and matcher files), 3 HAND_EDIT_SET (build_discovery_runtime.py: RESOURCE_ROOTS and the A5 key-to-source mapping), 12 child 2 matcher unions (harness agent sources whose Write( literals and hook patterns carry both roots), 0 tool-rewritten (no prefix-form literal remains in a non-excluded production file), 0 unclassified.

## Allowlist

- `STAY_ENTRIES`: the 343 `rewrite_exclusions` globs of DECISIONS (members 1 to 13, including child 2's merged production files, the cleanup-leg files, the stage A tool, the A6 policy sources under `scripts/harness-generation/sources/rules/**`, the ledger modules and the A19 STAY rows such as `DocsProfile.psm1`, `DocsFinding.psm1`, `FileSizePolicy.psm1`, the feature-folder record and `potential_record` validators, `Get-StageTimingReport.ps1`, `pr_context/models.py`, `render.py,cover` and `plan_progress_report.py`).
- `HAND_EDIT_SET`: `scripts/dev_tools/build_discovery_runtime.py`, `scripts/dev_tools/discovery/init_models.py` (the latter no longer matches).
- Child 2 resolver constants and matcher unions: `KNOWN_DEVELOPMENT_DOCS_ROOTS` and its PowerShell and TypeScript twins (inside STAY_ENTRIES globs), and the harness agent-source rows below.

## Matches placed by manual review (child 2 matcher unions)

| File | Line | Both-root form |
| --- | --- | --- |
| `scripts/harness-generation/sources/agents/epic-planner.json` | 19 | `Write(docs/features/epics/**)` with `Write(.dev/epics/**)` |
| `scripts/harness-generation/sources/agents/epic-review.json` | 19 | `Write(/docs/features/**)` with `Write(/.dev/**)` |
| `scripts/harness-generation/sources/agents/epic-review.json` | 31 | hook pattern `(?:docs/features|.dev)/epics/.+/epic-audit` |
| `scripts/harness-generation/sources/agents/epic-review.md` | 55 | `Write(/docs/features/**)`, next line `Write(/.dev/**)` |
| `scripts/harness-generation/sources/agents/feature-review.json` | 19 | `Write(/docs/features/active/**)` with `Write(/.dev/active/**)` |
| `scripts/harness-generation/sources/agents/feature-review.md` | 199 | `Write(/docs/features/active/**)`, next line `Write(/.dev/active/**)` |
| `scripts/harness-generation/sources/agents/prd-feature.json` | 19 | `Write(/docs/features/active/**)` with `Write(/.dev/active/**)` |
| `scripts/harness-generation/sources/agents/prd-feature.json` | 31 | hook pattern `(?:docs/features|.dev)/active/.+/spec` |
| `scripts/harness-generation/sources/agents/prd-feature.md` | 62 | `Write(/docs/features/active/**)`, next line `Write(/.dev/active/**)` |
| `scripts/harness-generation/sources/agents/status-updater.json` | 19 | `Write(/docs/features/**)` with `Write(/.dev/**)` |
| `scripts/harness-generation/sources/agents/status-updater.md` | 56 | `Write(/docs/features/**)`, next line `Write(/.dev/**)` |
| `scripts/harness-generation/sources/agents/task-researcher.json` | 19 | `Write(/docs/features/**/research/**)` with `Write(/.dev/**/research/**)` |

These are the 12 rows [P1-T3] classified as child 2's set through the harness agent generator family (their generated `.claude/agents` outputs are in child 2's merged list); the fallback release keeps both root forms (AC on `Write(`/`Edit(` literals).

## Output (all matches with class)

| File | Line | Class | Text |
| --- | --- | --- | --- |
| .claude/hooks/enforce-epic-merge-gate-review.ps1 | 39 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | 9. feature-folder is not a clean path below docs/features/: REVIEW_GATE_HEAD_UNRESOLVED. |
| .claude/hooks/enforce-epic-merge-gate-review.ps1 | 296 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | return [ordered]@{ State = 'Unresolved'; Detail = 'the checkpoint feature-folder value is not a clean path below docs/features/.' } |
| .claude/hooks/enforce-feature-folder-order.ps1 | 10 | STAY_ENTRIES (**/hooks/enforce-feature-folder-order.ps1) | docs/features/(active/archive)/<folder>/: a literal plan.md or a timestamped |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 18 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md. |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 59 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md. |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 65 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # `docs/features/active/X` under `-C <root>/tests/fixtures/resolve_execute_plan_prompt` |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 66 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # stages `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/X`. Measured |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 267 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | rule in docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md). |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 367 | STAY_ENTRIES (**/hooks/enforce-orchestration-preimplementation-gate-modes.ps1) | epic_manifest_path under docs/features/epics/; non-empty |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 19 | STAY_ENTRIES (**/hooks/enforce-parallel-cohort-barrier.ps1) | (feature-folder-resolution.ps1, issue #565): every docs/features/active/<token> |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 138 | STAY_ENTRIES (**/hooks/enforce-parallel-cohort-barrier.ps1) | docs/features/active/<folder> path and one that records a bare basename both match |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 171 | STAY_ENTRIES (**/hooks/enforce-parallel-cohort-barrier.ps1) | docs/features/active/<token> path, in either separator style, is truncated to its |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | 12 | STAY_ENTRIES (**/hooks/enforce-parallel-drift-gate.ps1) | (feature-folder-resolution.ps1, issue #565), which truncates every docs/features/active/ |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 290 | STAY_ENTRIES (**/hooks/enforce-prd-feature-before-planner-helpers.ps1) | Scans a prompt string for docs/features/active/<...> path tokens, |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 296 | STAY_ENTRIES (**/hooks/enforce-prd-feature-before-planner-helpers.ps1) | Truncation to four segments -- docs, features, active, and the |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 297 | STAY_ENTRIES (**/hooks/enforce-prd-feature-before-planner-helpers.ps1) | feature-folder name -- is two segments past the docs/features/active/ |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 27 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | docs/features/active/<token>, accepting both forward-slash and |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 29 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | docs/features/active/ prefix -- that is, to exactly four path segments: |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 30 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | docs, features, active, and the feature-folder name. Truncation is |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 63 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | under docs/features/active/ today, and issue.md sits at the feature root in |
| .claude/hooks/feature-folder-resolution.ps1 | 9 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | a known development-docs root (docs/features/active/ or .dev/active/, issue #1035), and |
| .claude/hooks/feature-folder-resolution.ps1 | 41 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | after the first 'active' segment (the fourth segment under docs/features), with |
| .claude/hooks/feature-folder-resolution.ps1 | 49 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so both docs/features and .dev tokens are read. |
| .claude/hooks/feature-folder-resolution.ps1 | 60 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .claude/hooks/feature-folder-resolution.ps1 | 96 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so docs/features/<lifecycle>/ and .dev/<lifecycle>/ prefixes |
| .claude/hooks/feature-folder-resolution.ps1 | 108 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .claude/hooks/hook-epic-fan-in.ps1 | 10 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | docs/features/epics/<slug>/epic-status.md and pr-author writes the integration pull |
| .claude/hooks/hook-epic-fan-in.ps1 | 123 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | Derives docs/features/epics/<epic_feature_folder>/epic-status.md; a declared .dev/epics form of the |
| .claude/hooks/hook-epic-fan-in.ps1 | 137 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $derived = "docs/features/epics/$slug/epic-status.md" |
| .claude/hooks/hook-epic-fan-in.ps1 | 389 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | after one optional docs/features/active/ or docs/features/completed/ prefix, a |
| .claude/hooks/hook-epic-fan-in.ps1 | 391 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | 0: docs/features/active/<basename>/ and docs/features/completed/<basename>/. The status |
| .claude/hooks/hook-epic-fan-in.ps1 | 415 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/active/$basename/") |
| .claude/hooks/hook-epic-fan-in.ps1 | 416 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/completed/$basename/") |
| .claude/hooks/hook-epic-fan-in.ps1 | 431 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | path is also judged in its docs/features/<area>/... form (issue #1035). |
| .claude/hooks/validate-executor-output.ps1 | 146 | STAY_ENTRIES (**/hooks/validate-executor-output.ps1) | the docs/features/ rule reads the repository-relative value and Test-PreflightFixRecord |
| .claude/hooks/validate-executor-output.ps1 | 188 | STAY_ENTRIES (**/hooks/validate-executor-output.ps1) | return @{ Ok = $false; Repairable = $true; Message = 'atomic-executor hook: a `PREFLIGHT-FIX:` line requires a `preflight-fix-record: <path> |
| .claude/hooks/validate-required-artifact-output.ps1 | 15 | STAY_ENTRIES (**/hooks/validate-required-artifact-output.ps1) | spec-path/^docs/features/active/.+/spec\.md$/spec artifact |
| .claude/hooks/validate-task-researcher-output.ps1 | 9 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | (docs/features/<feature>/research/ for feature-associated research, or |
| .claude/hooks/validate-task-researcher-output.ps1 | 10 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | docs/research/ for one-off research), matches the documented filename |
| .claude/hooks/validate-task-researcher-output.ps1 | 12 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | docs/features/ must also carry a complete `## Pre-Mortem` section |
| .claude/hooks/validate-task-researcher-output.ps1 | 14 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | research under docs/research/ is exempt. |
| .claude/hooks/validate-task-researcher-output.ps1 | 89 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | Feature research lives under docs/features/ or .dev/ (issue #1035); the one-off research |
| .claude/hooks/validate-task-researcher-output.ps1 | 90 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | areas docs/research/ and .dev/research/ are excluded, so .dev/research/ is exempt from |
| .claude/hooks/validate-task-researcher-output.ps1 | 91 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | the Pre-Mortem as docs/research/ is. |
| .claude/hooks/validate-task-researcher-output.ps1 | 123 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | #   - one-off research: the research area (docs/research/ or .dev/research/). |
| .claude/hooks/validate-task-researcher-output.ps1 | 306 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | return @{ Ok = $false; Message = 'task-researcher hook: agent output does not advertise a research-path. Researcher must report `research-pa |
| .claude/hooks/validate-task-researcher-output.ps1 | 323 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | return @{ Ok = $false; Message = "task-researcher hook: research-path '$researchPath' is not under a tracked research root. All research art |
| .claude/hooks/validate-task-researcher-output.ps1 | 327 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | return @{ Ok = $false; Message = "task-researcher hook: research-path '$researchPath' does not match the required filename convention `<time |
| .claude/hooks/validate-task-researcher-output.ps1 | 345 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | # Issue #964: feature research carries a Pre-Mortem; one-off research under docs/research/ |
| .claude/lib/blast-radius/BlastRadius.psm1 | 157 | STAY_ENTRIES (**/.claude/lib/blast-radius/BlastRadius.psm1) | placed. Defaults to the first known root (docs/features); a value outside |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 25 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | $script:DefaultDevelopmentDocsRoot = 'docs/features' |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 26 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | $script:KnownDevelopmentDocsRoots = @('docs/features', '.dev') |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 29 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'backlog'             = @{ 'docs/features' = 'docs/features/backlog.md'; '.dev' = '.dev/backlog.md' } |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 30 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'research'            = @{ 'docs/features' = 'docs/research'; '.dev' = '.dev/research' } |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 31 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'discovery-templates' = @{ 'docs/features' = 'docs/discovery/templates'; '.dev' = '.dev/discovery/templates' } |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 32 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'engineering'         = @{ 'docs/features' = 'docs/engineering'; '.dev' = '.dev/engineering' } |
| .claude/lib/docs/DocsProfile.psm1 | 187 | STAY_ENTRIES (**/.claude/lib/docs/DocsProfile.psm1) | 'guide', so a starter profile never selects planning trees such as docs/features/. |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 37 | STAY_ENTRIES (**/.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1) | # the error text keeps naming docs/features/active (D-P11). |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 42 | STAY_ENTRIES (**/.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1) | $script:ERROR_PATH_FORMAT = 'Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without  |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 55 | STAY_ENTRIES (**/.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1) | under docs/features/active/ whose every segment starts with a letter or |
| .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 317 | STAY_ENTRIES (**/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1) | $errors.Add("Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving $tool.") |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 241 | STAY_ENTRIES (**/lib/parallel-admission/Invoke-ParallelAdmission.ps1) | return "-RunFolder must be docs/features/parallel/<slug>; got '$($Option['RunFolder'])'." |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 246 | STAY_ENTRIES (**/lib/review-verdict/ReviewVerdictEligibility.psm1) | return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_FEATURE_FOLDER_INVALID' -Detail "feature-folder '$folder' is n |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 481 | STAY_ENTRIES (**/lib/review-verdict/ReviewVerdictEligibility.psm1) | Every name-status entry lies under docs/features/potential/ (not template.md) or is an |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 482 | STAY_ENTRIES (**/lib/review-verdict/ReviewVerdictEligibility.psm1) | added file under exactly one folder docs/features/active/<name>-<branch number>/ that does |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 132 | STAY_ENTRIES (**/lib/worktree-resolution/EpicScopeReadiness.psm1) | epic_manifest_path (empty, or not under docs/features/epics/ after backslash |
| .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 52 | STAY_ENTRIES (**/lib/worktree-resolution/WorktreeTargetResolution.psm1) | # active area of either known development-docs root (docs/features/active or |
| .codex/hooks/enforce-epic-merge-gate-review.ps1 | 39 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | 9. feature-folder is not a clean path below docs/features/: REVIEW_GATE_HEAD_UNRESOLVED. |
| .codex/hooks/enforce-epic-merge-gate-review.ps1 | 296 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | return [ordered]@{ State = 'Unresolved'; Detail = 'the checkpoint feature-folder value is not a clean path below docs/features/.' } |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 353 | STAY_ENTRIES (**/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1) | epic_manifest_path (empty, or not under docs/features/epics/ after backslash |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 18 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 59 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 65 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # `docs/features/active/X` under `-C <root>/tests/fixtures/resolve_execute_plan_prompt` |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 66 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # stages `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/X`. Measured |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 267 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | rule in docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md). |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 364 | STAY_ENTRIES (**/hooks/enforce-orchestration-preimplementation-gate-modes.ps1) | epic_manifest_path under docs/features/epics/; non-empty |
| .codex/hooks/feature-folder-resolution.ps1 | 9 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | a known development-docs root (docs/features/active/ or .dev/active/, issue #1035), and |
| .codex/hooks/feature-folder-resolution.ps1 | 41 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | after the first 'active' segment (the fourth segment under docs/features), with |
| .codex/hooks/feature-folder-resolution.ps1 | 49 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so both docs/features and .dev tokens are read. |
| .codex/hooks/feature-folder-resolution.ps1 | 60 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .codex/hooks/feature-folder-resolution.ps1 | 96 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so docs/features/<lifecycle>/ and .dev/<lifecycle>/ prefixes |
| .codex/hooks/feature-folder-resolution.ps1 | 108 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .codex/hooks/feature-review-coverage-target.ps1 | 97 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | Accepts docs/features/active/<folder>/[<version>/]policy-audit.<timestamp>.md and |
| .codex/hooks/feature-review-coverage-target.ps1 | 98 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | docs/features/active/<folder>/audit/<timestamp>/policy-audit.md, relative or absolute, with / |
| .codex/hooks/feature-review-coverage-target.ps1 | 103 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | double-quote span that holds docs/features/active/ (spaces kept); (3) each whitespace-delimited |
| .codex/hooks/feature-review-coverage-target.ps1 | 105 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | holds docs/features/active/ exactly once, so a source that spans two audit paths is skipped and |
| .codex/hooks/feature-review-coverage-target.ps1 | 190 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | return [pscustomobject]@{ RelativePath = $null; ReasonCode = 'AUDIT_NOT_NAMED'; Reason = 'the reviewer''s final message names no policy audi |
| .codex/hooks/hook-epic-fan-in.ps1 | 10 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | docs/features/epics/<slug>/epic-status.md and pr-author writes the integration pull |
| .codex/hooks/hook-epic-fan-in.ps1 | 123 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | Derives docs/features/epics/<epic_feature_folder>/epic-status.md; a declared .dev/epics form of the |
| .codex/hooks/hook-epic-fan-in.ps1 | 137 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $derived = "docs/features/epics/$slug/epic-status.md" |
| .codex/hooks/hook-epic-fan-in.ps1 | 389 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | after one optional docs/features/active/ or docs/features/completed/ prefix, a |
| .codex/hooks/hook-epic-fan-in.ps1 | 391 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | 0: docs/features/active/<basename>/ and docs/features/completed/<basename>/. The status |
| .codex/hooks/hook-epic-fan-in.ps1 | 415 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/active/$basename/") |
| .codex/hooks/hook-epic-fan-in.ps1 | 416 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/completed/$basename/") |
| .codex/hooks/hook-epic-fan-in.ps1 | 431 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | path is also judged in its docs/features/<area>/... form (issue #1035). |
| .codex/scripts/epic-child-launch-contract.ps1 | 416 | STAY_ENTRIES (**/.codex/scripts/epic-child-launch-contract.ps1) | $errors.Add("launch '$($entry.launch_id)' requires a final docs/features/active feature_folder without placeholders.") |
| extensions/drm-copilot/src/extension-command-helpers.ts | 90 | STAY_ENTRIES (extensions/drm-copilot/src/extension-command-helpers.ts) | return "This command requires an active or selected plan markdown file under docs/features/active/**/plan*.md."; |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 5 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | * longest prefix first. `docs/discovery/` holds only `templates/`, so its row |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 34 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | export const DISCOVERY_TEMPLATES_SOURCE = "docs/discovery/templates/"; |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | from: "docs/features/", |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 46 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/potential/", ".dev/potential/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 47 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/active/", ".dev/active/", true), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 48 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/completed/", ".dev/completed/", true), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 49 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/archive/", ".dev/archive/", true), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 50 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/epics/", ".dev/epics/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 51 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/parallel/", ".dev/parallel/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 52 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/templates/", ".dev/templates/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 53 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/research/", ".dev/research/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 55 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | from: "docs/features/backlog.md", |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 61 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/research/", ".dev/research/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 62 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/engineering/", ".dev/engineering/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 123 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | * @returns `mapped` with the target; `unmapped` under `docs/features/` with no |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 149 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | if (path.startsWith("docs/features/")) { |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 37 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/features", |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 38 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/research", |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 39 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/engineering", |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 40 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/discovery", |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts | 251 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | for (const root of [`docs/features/${area}/`, `.dev/${area}/`]) { |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts | 396 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | if (tracked.some((path) => path.startsWith("docs/discovery/"))) { |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts | 422 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | refusals.push(`unmapped entry under docs/features/: ${entry}`); |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-report.ts | 33 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | ["unmapped_entries", "Unmapped entries under docs/features/"], |
| extensions/drm-copilot/src/lib/development-docs-migration/reference-rewrite.ts | 64 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | * generic `docs/features/` row, longest prefix first. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 11 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-1 file absent or unreadable -> `docs/features`. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 12 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-2 key absent -> `docs/features` (no `.dev` probe). |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 15 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-5 value `docs/features` -> `docs/features`. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 17 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-7 value `.dev`, `.dev` absent, `docs/features` exists -> `docs/features`. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 33 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | export type DevelopmentDocsRoot = "docs/features" / ".dev"; |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 37 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features"; |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | ["docs/features", ".dev"]; |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 98 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | /** Areas whose `docs/features` form sits outside `docs/features`. */ |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 103 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features": "docs/features/backlog.md", |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 106 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | research: { "docs/features": "docs/research", ".dev": ".dev/research" }, |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 108 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features": "docs/discovery/templates", |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 112 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features": "docs/engineering", |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 9 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     fallback release both the `docs/features` form and the `.dev` form are |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 161 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | * `docs/features` and `.dev` for `.dev` (the parent of the engineering area). |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 205 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | * @returns For example `["Write(/docs/features/active/**)", "Write(/.dev/active/**)"]`. |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 249 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | * @returns For example `^(?:docs/features/\.dev)/active/.+/spec\.md$`. |
| extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts | 103 | STAY_ENTRIES (extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts) | * @param root Resolved development-docs root; defaults to `docs/features`. |
| extensions/drm-copilot/src/lib/potential-to-issue/content.ts | 29 | STAY_ENTRIES (extensions/drm-copilot/src/lib/potential-to-issue/content.ts) | export const DEFAULT_ACTIVE_AREA = "docs/features/active"; |
| extensions/drm-copilot/src/lib/potential-to-issue/content.ts | 476 | STAY_ENTRIES (extensions/drm-copilot/src/lib/potential-to-issue/content.ts) | *   `docs/features/active`. |
| extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts | 7 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts) | /(?:docs\/features/\.dev)\/epics\/[a-z0-9][a-z0-9-]*\/epic\.md/; |
| extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts | 124 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts) | `${prefix}.feature_folder must be under docs/features/active or completed.`, |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 35 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | * A repository-relative folder under `docs/features/active/`. Applied without |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 39 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | // root; the error text keeps naming docs/features/active (D-P11). |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | /^(?:docs\/features/\.dev)\/active\/[A-Za-z0-9][A-Za-z0-9._-]*(\/[A-Za-z0-9][A-Za-z0-9._-]*)*$/; |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 52 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | "Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing s |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts | 276 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts) | `Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving ${tool}.`, |
| extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts | 10 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts) | * Ownership is recorded in `docs/features/epics/parallel-orchestration/epic.md`, |
| extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts | 26 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts) | /(?:docs\/features/\.dev)\/parallel\/[a-z0-9][a-z0-9-]*\/parallel\.md/; |
| scripts/dev-tools/Get-StageTimingReport.ps1 | 15 | STAY_ENTRIES (scripts/dev-tools/Get-StageTimingReport.ps1) | (docs/features unless configured otherwise, issue #1035); a failed resolution throws its Reason. |
| scripts/dev-tools/ProcessReductionChain.psm1 | 184 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | return 'docs/features/templates/' + $Matches['rest'] |
| scripts/dev-tools/ProcessReductionChain.psm1 | 482 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | [string]$LedgerPath = 'docs/engineering/process-reductions', |
| scripts/dev-tools/ProcessReductionChain.psm1 | 548 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | and starts with a fallback prefix (docs/features/templates/ or docs/engineering/) is |
| scripts/dev-tools/ProcessReductionChain.psm1 | 565 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | @{ From = 'docs/features/templates/'; To = '.dev/templates/' }, |
| scripts/dev-tools/ProcessReductionChain.psm1 | 566 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | @{ From = 'docs/engineering/'; To = '.dev/engineering/' } |
| scripts/dev-tools/ProcessReductionChain.psm1 | 595 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | [string]$LedgerPath = 'docs/engineering/process-reductions' |
| scripts/dev-tools/ProcessReductionLedger.psm1 | 6 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionLedger.psm1) | The ledger under docs/engineering/process-reductions/ records every reduction of |
| scripts/dev-tools/link-feature-docs.ps1 | 7 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/link-feature-docs.ps1 | 8 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [string] $DevelopmentDocsRoot = 'docs/features' |
| scripts/dev-tools/link-feature-docs.ps1 | 44 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/link-feature-docs.ps1 | 45 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [string] $DevelopmentDocsRoot = 'docs/features' |
| scripts/dev-tools/link-feature-docs.ps1 | 89 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/link-feature-docs.ps1 | 90 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [string] $DevelopmentDocsRootParam = 'docs/features' |
| scripts/dev-tools/new-potential-entry.ps1 | 6 | STAY_ENTRIES (**/new-potential-entry.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/new-potential-entry.ps1 | 7 | STAY_ENTRIES (**/new-potential-entry.ps1) | [string] $DevelopmentDocsRoot = 'docs/features' |
| scripts/dev_tools/_orchestrator_state_feature_folder_record.py | 57 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_feature_folder_record.py) | # A repository-relative folder under docs/features/active/: every segment |
| scripts/dev_tools/_orchestrator_state_feature_folder_record.py | 62 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_feature_folder_record.py) | # naming docs/features/active (D-P11). |
| scripts/dev_tools/_orchestrator_state_feature_folder_record.py | 76 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_feature_folder_record.py) | "docs/features/active/ without dot segments or a trailing slash." |
| scripts/dev_tools/_orchestrator_state_issue_adoption.py | 289 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_issue_adoption.py) | f"file under docs/features/potential/ when waiving {tool}." |
| scripts/dev_tools/build_discovery_runtime.py | 49 | HAND_EDIT_SET | RESOURCE_ROOTS = ("schemas/discovery", "docs/discovery/templates") |
| scripts/dev_tools/build_discovery_runtime.py | 53 | HAND_EDIT_SET | ("docs/discovery/templates", ".dev/discovery/templates"), |
| scripts/dev_tools/build_discovery_runtime.py | 68 | HAND_EDIT_SET | ``docs/discovery/templates/v2/x.md``. |
| scripts/dev_tools/copy_research_to_issue.py | 7 | STAY_ENTRIES (scripts/dev_tools/copy_research_to_issue.py) | `docs/features/active/<issue>/...`). |
| scripts/dev_tools/copy_research_to_issue.py | 49 | STAY_ENTRIES (scripts/dev_tools/copy_research_to_issue.py) | development-docs root rather than a fixed ``docs/features`` path. |
| scripts/dev_tools/copy_research_to_issue.py | 58 | STAY_ENTRIES (scripts/dev_tools/copy_research_to_issue.py) | ``docs/features/active`` or ``.dev/active``. |
| scripts/dev_tools/epic_planner_readiness.py | 166 | STAY_ENTRIES (scripts/dev_tools/epic_planner_readiness.py) | The epics area, for example ``docs/features/epics`` or ``.dev/epics``. |
| scripts/dev_tools/epic_planner_readiness.py | 206 | STAY_ENTRIES (scripts/dev_tools/epic_planner_readiness.py) | f"{prefix}.feature_folder must be under docs/features/active or completed." |
| scripts/dev_tools/json_config.py | 46 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "docs/features/**", |
| scripts/dev_tools/json_config.py | 85 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features" |
| scripts/dev_tools/json_config.py | 86 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | KNOWN_DEVELOPMENT_DOCS_ROOTS: tuple[str, ...] = ("docs/features", ".dev") |
| scripts/dev_tools/json_config.py | 101 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "backlog": {"docs/features": "docs/features/backlog.md", ".dev": ".dev/backlog.md"}, |
| scripts/dev_tools/json_config.py | 102 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "research": {"docs/features": "docs/research", ".dev": ".dev/research"}, |
| scripts/dev_tools/json_config.py | 104 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "docs/features": "docs/discovery/templates", |
| scripts/dev_tools/json_config.py | 107 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "engineering": {"docs/features": "docs/engineering", ".dev": ".dev/engineering"}, |
| scripts/dev_tools/json_config.py | 167 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | ``"docs/features"`` or ``".dev"``. |
| scripts/dev_tools/json_config.py | 205 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | # existing .dev, falls back to an existing docs/features for one release, |
| scripts/dev_tools/json_config.py | 224 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | The area path, for example ``.dev/active`` or ``docs/research``. |
| scripts/dev_tools/new_active_feature_folder_flow.py | 59 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_flow.py) | The resolved root, ``docs/features`` or ``.dev``. |
| scripts/dev_tools/new_active_feature_folder_flow.py | 393 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_flow.py) | description="Create docs/features/active/<name>/ from the selected template." |
| scripts/dev_tools/new_active_feature_folder_flow.py | 406 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_flow.py) | "Must be under docs/features/potential/promoted and end with .md" |
| scripts/dev_tools/new_active_feature_folder_io.py | 52 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_io.py) | root: Resolved development-docs root; defaults to ``docs/features``. |
| scripts/dev_tools/parallel_kickoff_contract.py | 11 | STAY_ENTRIES (scripts/dev_tools/parallel_kickoff_contract.py) | ``docs/features/epics/parallel-orchestration/epic.md`` section "Planner |
| scripts/dev_tools/plan_progress_report.py | 1 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | """Generate a markdown report of incomplete plan checkboxes under docs/features/active. |
| scripts/dev_tools/plan_progress_report.py | 72 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (typically docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 140 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 198 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 249 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | A markdown link string, e.g. `[plan](../docs/features/active/.../plan.md)`. |
| scripts/dev_tools/plan_progress_report.py | 320 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 346 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | "Scan docs/features/active for plan.md / plan.*.md and report " |
| scripts/dev_tools/potential_to_issue.py | 173 | STAY_ENTRIES (scripts/dev_tools/potential_to_issue.py) | The resolved root, ``docs/features`` or ``.dev``. |
| scripts/dev_tools/potential_to_issue_content.py | 18 | STAY_ENTRIES (scripts/dev_tools/potential_to_issue_content.py) | DEFAULT_ACTIVE_AREA = "docs/features/active" |
| scripts/dev_tools/potential_to_issue_content.py | 243 | STAY_ENTRIES (scripts/dev_tools/potential_to_issue_content.py) | ``docs/features/active``. |
| scripts/dev_tools/pr_context/render.py,cover | 210 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | >     """Extract feature names from docs/features/active/** paths.""" |
| scripts/dev_tools/pr_context/render.py,cover | 309 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | !     base_dir = root / "docs" / "features" / "active" |
| scripts/dev_tools/pr_context/render.py,cover | 310 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | !     promoted_dir = root / "docs" / "features" / "potential" / "promoted" |
| scripts/dev_tools/pr_context/render_feature_excerpts.py | 105 | STAY_ENTRIES (scripts/dev_tools/pr_context/render_feature_excerpts.py) | path under ``docs/features/active/`` or ``.dev/active/`` yields its |
| scripts/dev_tools/pr_context/render_feature_excerpts.py | 131 | STAY_ENTRIES (scripts/dev_tools/pr_context/render_feature_excerpts.py) | The set of feature folder names under ``docs/features/active/`` or |
| scripts/dev_tools/validate_evidence_locations.py | 61 | STAY_ENTRIES (scripts/dev_tools/validate_evidence_locations.py) | research = development_docs_relative_path(docs_root, "research") |
| scripts/harness-generation/sources/agents/epic-orchestrator.json | 19 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.json) | "value": "\n  - \"Agent(orchestrator)\"\n  - \"Agent(pr-author)\"\n  - Read\n  - Grep\n  - Glob\n  - \"Write(docs/features/epics/**)\"\n  -  |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 36 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | (`docs/features/epics/<epic-slug>/epic.md`). |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 58 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `docs/features/epics/<epic-slug>/epic-kickoff.md` from that ref — for example |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 59 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `git show origin/epic/<epic-slug>-integration:docs/features/epics/<epic-slug>/epic-kickoff.md`, or |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 61 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `git cat-file -e epic/<epic-slug>-integration:docs/features/epics/<epic-slug>/epic-kickoff.md` — |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 159 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | Maintain `docs/features/epics/<epic-slug>/epic-status.md` as a human-readable projection of the |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 176 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | 3. `docs/features/epics/<epic-slug>/epic-status.md` reflects the completed state. |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 221 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | For `epic-run`, require `docs/features/epics/<slug>/epic-kickoff.md`. Validate its invocation |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 277 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `docs/features/epics/<slug>/epic-status.md` from that checkpoint at kickoff, every feature status |
| scripts/harness-generation/sources/agents/epic-planner.json | 19 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  - \"Agent(orchestrator)\"\n  - Read\n  - Grep\n  - Glob\n  - \"Write(docs/features/epics/**)\"\n  - \"Write(.dev/epics/**)\"\n |
| scripts/harness-generation/sources/agents/epic-review.json | 19 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Write(/docs/features/**)\"\n  - \"Write(/.dev/**)\"" |
| scripts/harness-generation/sources/agents/epic-review.json | 31 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  SubagentStop:\n    - matcher: \"epic-review\"\n      hooks:\n        - type: command\n          command: pwsh -NoProfile -File |
| scripts/harness-generation/sources/agents/epic-review.md | 55 | CHILD_2_MATCHER_UNION (manual review above) | - "Write(/docs/features/**)" |
| scripts/harness-generation/sources/agents/feature-review.json | 19 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Bash(git diff *)\"\n  - \"Bash(git log *)\"\n  - \"Write(/docs/features/active/**)\"\n  - \" |
| scripts/harness-generation/sources/agents/feature-review.md | 199 | CHILD_2_MATCHER_UNION (manual review above) | - "Write(/docs/features/active/**)" |
| scripts/harness-generation/sources/agents/prd-feature.json | 19 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Write(/docs/features/active/**)\"\n  - \"Write(/.dev/active/**)\"" |
| scripts/harness-generation/sources/agents/prd-feature.json | 31 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  SubagentStop:\n    - matcher: \"prd-feature\"\n      hooks:\n        - type: command\n          command: pwsh -NoProfile -File |
| scripts/harness-generation/sources/agents/prd-feature.md | 62 | CHILD_2_MATCHER_UNION (manual review above) | - "Write(/docs/features/active/**)" |
| scripts/harness-generation/sources/agents/status-updater.json | 19 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Write(/artifacts/**)\"\n  - \"Write(/docs/features/**)\"\n  - \"Write(/.dev/**)\"" |
| scripts/harness-generation/sources/agents/status-updater.md | 56 | CHILD_2_MATCHER_UNION (manual review above) | - "Write(/docs/features/**)" |
| scripts/harness-generation/sources/agents/task-researcher.json | 19 | CHILD_2_MATCHER_UNION (manual review above) | "value": "\n  - Read\n  - Grep\n  - Glob\n  - WebFetch\n  - \"Write(/docs/features/**/research/**)\"\n  - \"Write(/.dev/**/research/**)\"\n  |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 319 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | / `potential_record` / When waiving a promotion-entry tool: required when `origin` is `epic_decomposition`, optional when `origin` is `trans |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 320 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | / `feature_folder_record` / Required when `waived_tools` includes `new_active_feature_folder`, and validated whenever it is an object: `{ pa |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 335 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | - 11a. `path` must be a string that fully matches `^docs/features/active/[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$`, so dot  |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 343 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | A lifecycle record moved to `docs/features/potential/promoted/` satisfies the `potential_record` path rule, because the rule checks only the |
| scripts/harness-generation/sources/rules/parallel-orchestration.json | 8 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | "value": "\n  - \"artifacts/orchestration/parallel-*\"\n  - \"docs/features/parallel/**\"\n  - \"scripts/dev_tools/*parallel*\"\n  - \"exten |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 5 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | This rule governs the three artifacts of the `parallel` orchestration surface: the parallel-run manifest at `docs/features/parallel/<slug>/p |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 267 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | **Durable scheduling record.** `docs/features/parallel/<slug>/parallel-scheduling.json`, committed on `parallel/<slug>-plan`, carries `schem |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 321 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | token whose final component names a directory rather than a file, a `docs/features/` glob whose |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 701 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | that starts with `docs/features/`, ends with `/**`, and carries no other wildcard (the feature-folder |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 848 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | - The TypeScript parity port at `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts`, `parallel-state-structures.ts`, `paralle |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.json | 8 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | "value": "\n  - \"scripts/dev_tools/plan_gate_*\"\n  - \"scripts/dev_tools/validate_orchestration_artifacts.py\"\n  - \"extensions/drm-copil |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 65 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The measurement is recorded in `docs/features/completed/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gat |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 87 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The four severities below were fixed by one corpus measurement recorded in `docs/features/completed/2026-08-23-plan-acceptance-gates-miss-un |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 91 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The measurement scanned 194 plan files under `docs/features`, covering the `active`, `completed`, and `archive` trees. Unlike the G5 measure |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 110 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, and every one of the 22 false positives named by plan path, task identifier, and offending span: `docs/features/completed/2026-08-23 |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 120 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, and every one of the 7 false positives named by plan path, task identifier, and offending span: `docs/features/completed/2026-08-23- |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 128 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, the zero false-positive record, and the three sub-classes with their plan paths and offending spans: `docs/features/completed/2026-0 |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 136 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, and every one of the 4 false positives named by plan path, task identifier, offending span, and the reason its acceptance condition  |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 155 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The measurement is recorded in `docs/features/archive/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/evidence/qa-gates/g10-corpus- |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 189 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | G13 reports a plan above 20 canonical task lines or 250 physical lines that carries no `## Size Justification` section with content. The fir |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 205 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The corpus measurement informed the false-positive class list and did not decide the channel. It is recorded in `docs/features/archive/2026- |
| .claude/lib/docs/DocsFinding.psm1 | 252 | STAY_ENTRIES (**/.claude/lib/docs/DocsFinding.psm1) | 'docs'. |
| .claude/lib/docs/DocsFinding.psm1 | 270 | STAY_ENTRIES (**/.claude/lib/docs/DocsFinding.psm1) | $name = if ([string]::IsNullOrEmpty($CommandResult.Command)) { 'docs' } else { [string] $CommandResult.Command } |
| .claude/lib/file-size-policy/FileSizePolicy.psm1 | 67 | STAY_ENTRIES (**/.claude/lib/file-size-policy/FileSizePolicy.psm1) | return [string[]]@('.git', 'node_modules', 'artifacts', 'coverage', 'dist', 'out', 'virtual', 'docs', |
| .codex/hooks/file-size-policy.ps1 | 58 | STAY_ENTRIES (**/.codex/hooks/file-size-policy.ps1) | return [string[]]@('.git', 'node_modules', 'artifacts', 'coverage', 'dist', 'out', 'virtual', 'docs', |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-apply.ts | 96 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | deps.fileSystem.ensureDir(joinRoot(deps.workspaceRoot, "docs")); |
| extensions/drm-copilot/src/lib/pr-context/models.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/pr-context/models.ts) | "docs", |
| extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts | 94 | STAY_ENTRIES (extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts) | "docs", |
| extensions/drm-copilot/src/repo-automation-service.ts | 148 | STAY_ENTRIES (extensions/drm-copilot/src/repo-automation-service.ts) | private readonly docsOptions: RepoAutomationServiceOptions["docs"]; |
| scripts/dev_tools/pr_context/models.py | 18 | STAY_ENTRIES (scripts/dev_tools/pr_context/models.py) | "docs", |
| scripts/dev_tools/pr_context/render.py,cover | 216 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | !             and parts[0] == "docs" |
| scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py | 118 | STAY_ENTRIES (scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py) | "docs", |
| scripts/harness-generation/sources/rules/mermaid.json | 43 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | "docs" |
