# Tree Re-check, stage B ([P0-T3], resumed run 1)

Timestamp: 2026-11-20T10-35
Command: pwsh -NoProfile -File SCRATCH/issue-1016-p0t3b.ps1 (Test-Path and ordinal Contains per Citation Register entry, child 2 export scan, config/harness-parity-matrix.json classification of HAND_EDIT_TARGETS with physical line counts, SHA-256 of the SKILL_COPIES and BRIEF_COPIES, A1 and A23 checks); sh SCRATCH/issue-1016-p0t3b-gen.sh (Invoke-HarnessGeneration.ps1 -Surface all -Check; generate_codex_agent_variants --check; build_discovery_runtime --check; git fetch origin; merge-base and diff per ref); sh SCRATCH/issue-1016-disc.sh (build_discovery_runtime --check re-run from the worktree root)
EXIT_CODE: 0
Output Summary: RESULT PASS. 73 Citation Register rows PRESENT, 0 MOVED. Six child 2 exports MATCH. Zero HAND_EDIT_TARGETS are generated outputs. SKILL_COPIES and BRIEF_COPIES are four copies each with no .github copy. A1 holds with the single DocsProfile.psm1 comment STAY row. All four A23 premises hold. Harness check prints `harness-generation: no drift`, the Codex variant check exits 0 and the discovery runtime check exits 0. Neither ref has an upstream change since its merge base.

HEAD: the merge of the INTEGRATION tip plus the stage A and planning commits; `origin/epic/shared-agent-harness-layer-integration` and `origin/main` are both ancestors of HEAD after `git fetch origin`.

## (a) Citation Register

Every entry of `## Citation Register` was checked by path existence and, where a symbol, heading or test name is cited, by an ordinal substring check: 73 rows PRESENT, 0 MOVED. The one row whose literal token was not found is a Pester template: `ReviewVerdictEligibility.PullRequest.Tests.ps1` holds `It 'refuses the listing <Name>'` with the case `Name = 'engineering path'`, so the expanded test name "refuses the listing engineering path" is PRESENT.

## (b) Child 2 exports against child 2 spec signatures

| Export | Observed | Result |
| --- | --- | --- |
| `parseFeatureFolderName` | `(name: string): FeatureFolderName` in `feature-folder-name.ts` | MATCH |
| `formatFeatureFolderName` | `(issueNumber: number, feature: string): string` | MATCH |
| `stripDateFirstPrefix` | `(stem: string): string` | MATCH |
| `developmentDocsPath` | `(root: DevelopmentDocsRoot, area: DevelopmentDocsArea): string` in `root.ts` | MATCH |
| `resolveDevelopmentDocsRoot` | `(reader: DevelopmentDocsReader, workspaceRoot: string): DevelopmentDocsRoot` | MATCH |
| `KNOWN_DEVELOPMENT_DOCS_ROOTS` | `["docs/features", ".dev"]` | MATCH |

## (c) Child 2 merged file list and Stay evidence

- Pull request 1200 file list (502 files, paginated `gh api`), kept at `SCRATCH/issue-1016-child2-files.txt` for [P1-T3]; unchanged since `tree-recheck.2026-11-20T08-11.md`, because no commit between the INTEGRATION tip and HEAD touches the child 2 trees.
- Child 2 recorded Stay allowlist: `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/evidence/other/residual-search.2026-11-17T10-10.md` PRESENT.

## (d) GENERATOR_INVENTORY

| Generator | Check form | Result |
| --- | --- | --- |
| `scripts/harness-generation/Invoke-HarnessGeneration.ps1` (surfaces skills, agents, rules, mcp, instructions; 241 generated target paths in the matrix) | `-Surface all -Check` | `harness-generation: no drift`, exit 0 |
| `scripts.dev_tools.generate_codex_agent_variants` | `--check` | exit 0 |
| `scripts.dev_tools.build_discovery_runtime` | `--check` | exit 0 (see note) |

Note: the first discovery check exited 1 with `ValueError: Unexpected package member`. The only package members outside the accepted set were two gitignored pytest atomic-write temporaries, `analyzer/__pycache__/test_references.cpython-313-pytest-9.0.2.pyc.54384` and `analyzer/__pycache__/test_reference_syntax.cpython-313-pytest-9.0.2.pyc.67648` (left by an interrupted pytest rewrite; untracked and ignored). They were removed as a local-environment micro-action, and the re-run from the worktree root exited 0, with the module resolved from the item worktree. No tracked file changed; this is not generator drift.

HAND_EDIT_TARGETS classification against the `generated` matrix entries (direct target or bundle copy of a target): 0 GENERATED, 33 hand. The `.agents/skills/execution-environment/SKILL.md` source and its `codex-and-agents-customizations` bundle copy are hand; the two `.claude` brief copies, which [P3-T10] regenerates, are not hand-edit targets.

## Copy counts

| Surface | Copies | Byte groups |
| --- | --- | --- |
| `atomic-plan-contract` SKILL_COPIES | 4 (no `.github` copy) | two pairs: `.claude` with its bundle (297B4A061604), `.agents` with its bundle (72740F406653) |
| `feature-review-workflow` SKILL_COPIES | 4 (no `.github` copy) | two pairs (2029A1C8F5EF, AA2D2872A581) |
| execution-environment BRIEF_COPIES | 4 (no `.github` copy) | one group, all byte-identical (63E2121FDDC8) |

## (e) A1 coexistence

| Check | Result |
| --- | --- |
| `docs/documentation-estate/` absent | PASS |
| `hook-docs-estate-context.ps1` and `hook-docs-only-diff.ps1` in `.claude/hooks` and `.codex/hooks`: 0 MAPPING_PREFIXES occurrences each | PASS |
| `.claude/lib/docs/`: the only occurrence is the `DocsProfile.psm1` comment "so a starter profile never selects planning trees such as docs/features/." (the A19 STAY row) | PASS |

## A23 premises (A19 rows satisfied by child 2)

| Premise | Result |
| --- | --- |
| `OrchestratorStateFeatureFolderRecord.psm1` imports `DevelopmentDocsRoot.psm1`; bundle copy byte-identical | PASS |
| `_orchestrator_state_feature_folder_record.py` joins `KNOWN_DEVELOPMENT_DOCS_ROOTS` | PASS |
| `orchestrator-state-feature-folder-record.ts` pattern holds the `(?:docs\/features|\.dev)\/active\/` union | PASS |
| `Get-StageTimingReport.ps1` resolves its default through `Resolve-DevelopmentDocsRoot`; the `'../../docs/features'` literal is absent | PASS |

## (f) Upstream changes to the overlap files

| Ref | Derivation | Commits on ref since merge base | Files changed |
| --- | --- | --- | --- |
| `origin/main` | merge base of `origin/main` and `HEAD` | 0 | 0 |
| `INTEGRATION` | merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD` | 0 | 0 |

## (g) Physical line counts of HAND_EDIT_TARGETS

| File | Lines |
| --- | --- |
| `scripts/dev-tools/ProcessReductionChain.psm1` | 596 |
| `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` | 560 |
| `config/orchestration-routing.json` (three copies) | 451 each |
| `config/blast-radius.json` | 90 |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` | 176 |
| FT_BYTE_PAIRS bundle copies: `epic/epic.md`, `bug`, `feature`, `refactor` plan templates | 83, 55, 64, 64 |
| `docs/features/epics/shared-agent-harness-layer/epic.md` | 425 |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | 83 |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | 462 |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 513 |
| `scripts/dev_tools/build_discovery_runtime.py` | 471 |
| `scripts/dev_tools/discovery/init_models.py` | 32 |
| `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` | 255 |
| `tests/scripts/dev_tools/discovery/test_init_models.py` | 114 |
| `tests/discovery_runtime/initialization_test_support.py` | 141 |
| `tests/scripts/dev_tools/discovery/test_domain_neutrality.py` | 79 |
| `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1` | 246 |
| `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | 332 |
| `atomic-plan-contract` copies (`.claude` and bundle; `.agents` and bundle) | 313, 313, 271, 271 |
| `.agents/skills/execution-environment/SKILL.md` and bundle copy | 246, 246 |
| patches `0001`, `0006`, `0008`, `0009` | 9832, 7783, 1809, 1212 |

No code file reaches 700 lines.

## Stop conditions

No `MOVED` row, no `DIFFERS` export, no generated hand-edit target, no generator drift, every copy count is four, every A23 premise holds, and no docs-estate or `.claude/lib/docs/` occurrence lies outside the STAY row. [P0-T3] passes.
