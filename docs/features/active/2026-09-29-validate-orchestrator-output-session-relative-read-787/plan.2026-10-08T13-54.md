# 2026-09-29-validate-orchestrator-output-session-relative-read (Plan)

- **Issue:** #787 (primary); bundles and closes #840
- **Parent (optional):** epic #852 (enforcement-hook-precision), child C6, wave 1 (0-indexed)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T15-40
- **Status:** Ready for preflight (revision 1.0)
- **Version:** 1.0
- **Work Mode:** full-bug (`spec.md` is the only acceptance-criteria source; `user-story.md` is absent by design)
- **Branch:** `bug/validate-orchestrator-output-session-relative-read-787`
- **Research:** `research/research.2026-10-08T14-00.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Recap

1. **#787.** `.claude/hooks/validate-orchestrator-output.ps1` resolves the run checkpoint for all three artifact types through the exported functions of `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (plus `Get-WorktreeItemLiveRoot`), in a new dot-sourced sibling `.claude/hooks/validate-orchestrator-output-resolution.ps1`. Every downstream read, including the `runbook_path` existence check, uses the resolved absolute root. An unresolved, ambiguous, mismatched, or import-failed target blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and reads nothing.
2. **#840.** A PowerShell port of `validate_wave_barrier_ordering`, `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, is invoked by the hook for `epic-orchestrator-state` only, after the routing dispatch passes. Parity with the Python authority is pinned by a new fixture `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json` exercised by a Pester lane and a pytest lane. The three #840 documents and their bundled mirrors are corrected.
3. Registration (`core.json`, `OrchestratorState.Manifest.Tests.ps1`), bundled mirrors, and the frozen-surface digest pin are updated so every parity and contract test stays green.

**Execution context.** This plan is executed later, on this branch, by the epic-orchestrator through a delegated orchestrator, after upstream C2 (#565, wave 0) merges into `epic/enforcement-hook-precision-integration`. Phase 0 merges that branch into this one before any edit (P0-T10, P0-T11) and re-locates every edit site by its text on the merged tree.

**Out of scope (spec Non-goals and caller instruction):** the SubagentStop transport and exit-code defect recorded in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`; any edit to `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (owned by C3 #850); any change to Layer 1 logic in `.claude/hooks/enforce-epic-wave-barrier.ps1` beyond its header comment; the TypeScript parity lane (it is run, not extended); guarding the existing unguarded `OrchestratorState.psm1` import (C4 #786); porting any part of `validate_epic_orchestrator_state_text` beyond Layer 2; `.codex/**` and `.agents/**`; PR authoring and CI monitoring (done by the orchestrator).

### Current-tree facts this plan relies on (re-derived 2026-10-08 against this worktree before the integration merge)

- `.claude/hooks/validate-orchestrator-output.ps1` is 421 lines: unguarded `OrchestratorState.psm1` import at line 41; `Get-CheckpointFileContent` lines 43-66; `Test-HumanInteractionShape` lines 68-150 with the `FileExistsCheck` default at line 101 and its use at line 143; `Test-OrchestratorCheckpointStructure` lines 152-196 (reads through `Get-OrchestratorStateCheckpoint` at line 190); `Invoke-RoutingContractValidation` lines 198-304 (completion leg at line 261, structural leg at line 270); `Invoke-OrchestratorOutputValidation` lines 306-408 (payload checks 326-342, read at 344, human-interaction call at 381, routing arguments at 390, tokens `MODEL_ROUTING_BLOCKED:` at 402 and `ROUTING_CONTRACT_BLOCKED:` at 404); dot-source guard 410-413; entry point 415-421.
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` is 490 lines. The Context titled `-CheckpointPath / -ArtifactType parameterization (Invoke-OrchestratorOutputValidation)` spans lines 361-415 and holds the two rows that assert the relative literal (lines 385 and 412). The interpreter AST row is at lines 468-488.
- Three suites call `Invoke-OrchestratorOutputValidation`: `validate-orchestrator-output.Tests.ps1` (18 occurrences), `validate-orchestrator-output.model-routing.Tests.ps1` (5), `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` (2, lines 246 and 273). `validate-orchestrator-output.human-interaction.Tests.ps1` dot-sources the hook but calls only `Test-HumanInteractionShape`.
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` is 497 lines; exports at lines 490-497. `WorktreeItemResolution.psm1` exports `Get-WorktreeItemLiveRoot` (line 405 of its export list; function at line 179). `Get-WorktreeRunCheckpointPath` composes through `Join-WorktreeResolutionPath` (`WorktreeTargetResolution.psm1:311-339`).
- `.claude/hooks/enforce-epic-wave-barrier.ps1` (pre-C2): the Layer 2 sentence is at lines 26-29 inside the comment help; its guarded `WorktreeRunResolution.psm1` import is at lines 43-50. C2 rewrites this file, so P0-T13 re-locates the sentence by its text.
- `.claude/skills/epic-orchestrate/SKILL.md` Layer 2 bullet: lines 244-254. `.claude/agents/epic-orchestrator.md` SubagentStop sentence: lines 124-127 (paragraph 118-127).
- Python authority: `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py:78-163` (start guard 37-75); `scripts/dev_tools/_epic_orchestrator_state_resolution.py` prefixes 37-42, index 74-109, reference resolution 141-149; `scripts/dev_tools/validate_epic_orchestrator_state.py:341-428`. `_validate_merge_status_enum` (lines 218-243) tests membership in the set `VALID_MERGE_STATUS` (line 54), so an array or object `merge_status` raises `TypeError` in the Python authority; such cases are pinned in the PowerShell unit suite only, never in the shared corpus.
- `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` uses the schema `schema_version`, `envelope`, `cases[]` (`name`, `acceptance_criteria`, `notes`, `features`, `expected_barrier_errors`). Its consumers assert 14 cases by name of file: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py:40` and `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts:38-40`. Neither iterates the directory.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-163` pins the SHA-256 of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:471-479` asserts them. Editing either document fails that test until the pin is re-baselined (Plan decision D11).
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/validate-orchestrator-output.ps1` at line 62 and `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` at line 147. `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` holds `ExpectedPaths` at lines 28-42 and enumerates every on-disk module (lines 80-90).
- `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1:36-41` requires every `.claude/lib/**/*.psm1` to carry `Set-StrictMode -Version Latest` followed immediately by `$ErrorActionPreference = 'Stop'`, the help-block sentence containing "imports its siblings with -ErrorAction Stop", `-ErrorAction Stop` on every column-0 `Import-Module`, and at most 500 lines.
- SubagentStop registrations that the cross-check must accept: `.claude/settings.json` lines 265, 274, 283; `.claude/agents/orchestrator.md:42`; `.claude/agents/epic-orchestrator.md:29`; `.claude/agents/parallel-orchestrator.md:42`.
- No `.codex` copy exists for the hook, the sibling, or the module. Codex-side analogues that exist and make no Layer 2 claim: `.codex/hooks/enforce-epic-wave-barrier.ps1`, `.codex/agents/epic-orchestrator.toml`, `.agents/skills/epic-orchestrate/SKILL.md` (spec: explicitly excluded).
- `.gitattributes` line 1 is `* text=auto eol=lf`, so working-tree bytes of the edited documents equal their committed bytes.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` carries no per-file list (line 3 lists folders only), so no runsettings edit is needed. `quality-tiers.yml` already classifies `.claude/hooks` (line 28) and `.claude/lib/orchestrator-state` (line 61) as T3.

### Plan decisions (resolutions of spec latitude, recorded for review)

- **D1 — AC identifiers.** `spec.md` `## Acceptance Criteria` holds 26 unchecked criteria at lines 184-209 and no other checkbox in the file. This plan names them AC-01 through AC-26 in spec order (Appendix I).
- **D2 — Block token vocabulary.** All target failures lead with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: <ArtifactType>: <Status> (<ReasonCode>): <Detail>`. `NoTarget` and `Ambiguous` carry the resolver reason codes. A failed `-CheckpointPath` cross-check uses status `Rejected` with `CHECKPOINT_PATH_MISMATCH`. A failed sibling or resolver import uses status `NoTarget` with `RESOLVER_IMPORT_FAILED` and names the file. An unsupported artifact type is `NoTarget` with `TARGET_WORKTREE_NOT_DERIVABLE` and a detail naming the type.
- **D3 — Reason-code literals in the sibling.** The sibling may not call `WorktreeResolution.psm1` accessors (AC-01), so it holds the two literals `TARGET_WORKTREE_AMBIGUOUS` (discovery ambiguity) and `TARGET_WORKTREE_NOT_DERIVABLE` (unsupported type). Rows R5 and S2-7 assert each equals the accessor value, so drift fails a test.
- **D4 — Cross-check order.** The lexical check (empty, rooted, `..` segment) runs before any resolver call, so a malformed value reads nothing. The canonical-equality check runs after resolution against `Get-WorktreeRunCheckpointPath` for the type's kind.
- **D5 — Import guards.** The hook guards, in order, the sibling dot-source, `WorktreeItemResolution.psm1`, and `WorktreeRunResolution.psm1` (first failure recorded in `$script:OrchestratorOutputResolverImportFailure`), and separately `OrchestratorStateEpicWaveBarrier.psm1` (`$script:OrchestratorOutputWaveBarrierImportFailure`). A Layer 2 import failure blocks the epic leg only, with `EPIC_WAVE_BARRIER_UNEVALUABLE:` naming the module. The existing line-41 import is unchanged (C4).
- **D6 — Non-integer numeric tokens fail closed.** When the port consults a number token that is not an integer literal (an `issue_num` of an indexed feature, or a `depends_on` entry of a started feature), it throws `EPIC_WAVE_BARRIER_UNEVALUABLE:`. Declared divergence D1 of the parity suite pins this.
- **D7 — Duplicate keys.** The port reads properties through its own last-definition-wins enumeration of `JsonElement.EnumerateObject()`, independent of `TryGetProperty` behavior.
- **D8 — Relative-literal rows.** The Context at `validate-orchestrator-output.Tests.ps1:361-415` is removed; its two rows are rewritten as S1 rows R1 (epic arguments) and R12 (default arguments), which assert the absolute path that reaches the read seam and the dispatch leg.
- **D9 — Three new hook suites.** Rows are split across S1 (topology through the hook), S2 (sibling functions and cross-check), and S3 (Layer 2 through the hook) to keep each under 500 lines.
- **D10 — Default resolution mock.** Each existing suite that reaches `Invoke-OrchestratorOutputValidation` gains `BeforeAll { <DM-LINE> }` as the first child of its outermost `Describe` (Appendix C0).
- **D11 — Frozen-surface digest re-baseline (scope addition).** The spec file table omits `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, but the #840 document edits change both pinned digests and would fail `test_parallel_orchestrator_surface_contracts.py`, which AC-26 requires to pass. P5-T7 re-baselines both values and adds a provenance comment in the file's established form. No other Python file changes.
- **D12 — Corpus expectations follow the authority.** The corpus in Appendix D carries expectations derived from the algorithm. If the pytest lane (P1-T3) reports a case whose authority output differs, the case's `expected_barrier_errors` is replaced by the authority output, the case name, planned value, and authority value are recorded in `FEATURE/evidence/other/corpus-derivation.TS.md`, and the PowerShell port is held to the corrected value. No case is added or removed by this rule.
- **D13 — Transport caveat wording.** Each corrected passage carries a one-sentence note that the hook's runtime effect is likely to depend on the defect recorded in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` (AC-22).
- **D14 — Layer 2 call site.** The hook's `Invoke-OrchestratorOutputValidation` calls the sibling helper `Get-OrchestratorOutputWaveBarrierDecision` for `epic-orchestrator-state` after the routing dispatch passes; the helper calls the port and composes the block text.
- **D15 — Codex copies.** None is updated; P5-T11 records the check per file.
- **D16 — Branch sync.** Integration-branch updates are taken with `git merge --no-ff --no-commit` followed by a trailer-bearing commit. No rebase and no force-push.

## Execution Conventions

### Terms used in every task

- FEATURE means `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787`.
- BRANCH means `bug/validate-orchestrator-output-session-relative-read-787`. INTEGRATION means `origin/epic/enforcement-hook-precision-integration`.
- PLAN means `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/plan.2026-10-08T13-54.md` (this file).
- CB means `extensions/drm-copilot/resources/claude-customizations`.
- HOOK means `.claude/hooks/validate-orchestrator-output.ps1`; SIB means `.claude/hooks/validate-orchestrator-output-resolution.ps1` (new); PORT means `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (new); WAVE means `.claude/hooks/enforce-epic-wave-barrier.ps1`; WRR means `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`.
- SKILL means `.claude/skills/epic-orchestrate/SKILL.md`; AGENT means `.claude/agents/epic-orchestrator.md`; PIN means `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; CORE means `CB/pack-manifests/core.json`; MANIFEST means `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1`; CORPUS means `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json` (new).
- T-MAIN, T-DISPATCH, T-ROUTING, T-HUMAN mean `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`, `.artifact-type-dispatch.Tests.ps1`, `.model-routing.Tests.ps1`, and `.human-interaction.Tests.ps1` in that folder.
- New test files: S1 `tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1` (14 rows), S2 `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1` (12 rows), S3 `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1` (12 rows), S4 `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1` (20 test cases), S5 `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1` (7 test cases with two fixture files present), PYLANE `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` (30 test nodes with 28 corpus cases).
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form. SCRATCH means the executor's session scratchpad directory, outside the repository and never committed; artifacts record it as the literal token SCRATCH, never as a host path.
- PRE_MERGE_SHA, INTEGRATION_SHA, and MERGED_SHA are recorded by P0-T9 and P0-T11. INTEGRATION_SHA is the commit of INTEGRATION that P0-T11 merged and is the base for every diff in Phases 1-5; P6-T1 records FINAL_INTEGRATION_SHA.
- Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; one whose expected exit code is not 0 also carries `ExpectedExitCode:`. PowerShell coverage artifacts record numeric `LinePercent=` values; Python coverage artifacts record numeric `LinePercent=` and `BranchPercent=` values.
- KL-510 is the known local failure of issue #510 in node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. A run satisfies KL-510 in exactly two cases. Case (a): the node passes; the artifact carries `KL-510: PASSED`. Case (b): the node fails, its assertion message is the literal "Repo file missing from bundle:" followed by a path whose first two components are `.claude` and `state`, and no output line contains "Bundle content differs from repo for:"; the artifact carries `KL-510: STATE-ONLY`, quotes the message, and carries `ExpectedExitCode: 1`. Any other outcome stops the task.

### Evidence location

Every evidence artifact lives under `FEATURE/evidence/<kind>/` with kind one of `baseline`, `regression-testing`, `qa-gates`, or `other`. Coverage XML, coverage JSON, and report files written by scratch scripts go to SCRATCH. The caller supplied no non-canonical evidence path, so no override record is needed.

### Shell route

- The worktree isolation hook refuses Bash command text containing the words bash, pwsh, or wsl, heredocs, compound commands, and cd-chains. Every git, poetry, npm, cp, and sh command in this plan is one plain command with literal arguments, and no commit message contains any of those three words.
- Every PowerShell script runs as CMD-PS-SCRIPT: `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>`. Glob arguments are expanded by the shell before the script runs; comma-joined lists are split by the scripts.
- Bundle mirrors are produced by `cp` from the primary file, never through Write or Edit, so they are byte-identical.

### Live-file and stop rules

- **LF-1.** HOOK and SIB are written as whole files: SIB first (P3-T1), then HOOK from a staged copy (P3-T2, P3-T3). HOOK is never changed by a partial Edit.
- **LF-2.** WAVE is a live PreToolUse hook; it is changed by one comment-only Edit (P5-T3) followed by A15 and A14 checks.
- **LF-3.** If any hook denies a Write, Edit, Bash command, or MCP call issued by this plan, stop and report the verbatim denial text. Do not bypass the hook through another tool and do not disable a hook. A batch-budget denial is reported, not worked around; P0-T8 confirms the large route, which the PowerShell batch-budget hook exempts.
- **LF-4.** No task writes, moves, or deletes anything under `artifacts/orchestration/`, any file under `.codex/` or `.agents/`, or WRR.

### Toolchain loop rule

Each implementation phase runs, after its writes: MCP format over the phase's folders, a read-only A6 check, a `git status --porcelain` check, MCP analyze, an A7 count, and the phase's A2 runs. If any step fails or changes a tracked file, fix the cause and restart that phase's loop from its format task. Phase 6 is the final QA loop for both languages (PowerShell: format, analyze, test with coverage, no type-check stage per `.claude/rules/powershell.md`; Python: black, ruff, pyright, pytest with coverage). No production Python file changes; the Python changes are PYLANE and the PIN values.

### Commit rule

Each phase ends with a commit-and-push task. CMD-GIT-ADD and CMD-GIT-COMMIT name the same explicit paths (files, the FEATURE evidence directory, FEATURE/spec.md, PLAN); `git add -A` and `git add .` are not used. A commit task's own check-off is written after its status check and is carried by the next commit. Never force-push.

### Command catalogue

Angle-bracket fields are filled from the task text. Commands run from the worktree root.

```text
CMD-GIT-BRANCH        git rev-parse --abbrev-ref HEAD
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-FETCH-INT     git fetch origin epic/enforcement-hook-precision-integration
CMD-GIT-INT-SHA       git rev-parse origin/epic/enforcement-hook-precision-integration
CMD-GIT-C2-CHECK      git log --oneline --grep=565 origin/epic/enforcement-hook-precision-integration -- .claude/hooks/enforce-epic-wave-barrier.ps1
CMD-GIT-MERGE-INT     git merge --no-ff --no-commit origin/epic/enforcement-hook-precision-integration
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-COUNT         git grep -c -F -e '<literal>' -- <paths>
CMD-GIT-ADD           git add -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message given in the task>" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: <session URL from the executing session's attribution instruction>" -- <exact paths listed in the task>
CMD-GIT-PUSH          git push origin bug/validate-orchestrator-output-session-relative-read-787
CMD-CP                cp <primary> <mirror>

CMD-PY-TEST           poetry run pytest -v <test files listed in the task>
CMD-PY-PARITY         poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
CMD-PY-FULL           poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/<json name given in the task>

CMD-TS-TEST           npm --prefix extensions/drm-copilot test -- <test path listed in the task>

CMD-PS-SCRIPT         sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format   (workspace_root = worktree root, scan_folders = folders listed in the task)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze  (same arguments)
MCP-PS-TEST           mcp__drm-copilot__run_poshqc_test     (workspace_root = worktree root)
```

CMD-GIT-COUNT literals are always wrapped in single quotes; the literal named in a task is the text between the quotes. `git grep` searches tracked files only, so CMD-GIT-COUNT is used only on files tracked before the task runs; a new file is searched with A17.

### Observed success outputs that acceptance conditions rely on

- The PoshQC MCP tools return a fixed summary string composed before the child process runs, with no exit code and no test output. Their only observable signal is whether the call returns or raises; artifacts record `EXIT_CODE: 0` when the call returned and non-zero when it raised. Every count, percentage, and finding is read from scratch scripts, never from an MCP result.
- A2 prints `TotalCount=`, `PassedCount=`, `FailedCount=`, and one `FAILED:` line per failed test; A3 adds one `COVERAGE file=... LinePercent=` line plus `HIT`/`MISSED` lines per coverage file; A6 prints `FORMAT-SUMMARY ChangedCount=`; A7 prints `PSSA-SUMMARY DiagnosticCount=`; A15 prints `STAGE-CHECK ParseErrors= FormatChanged= DiagnosticCount=`. These formats were observed in recorded runs: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/remediation-baseline/coverage-wrr.2026-09-30T02-05.md` (A3 line `COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 AnalyzedLines=146 CoveredLines=146 LinePercent=100`) and `.../evidence/remediation-baseline/powershell-format-analyze.2026-09-30T02-05.md`. A2 and A3 exit 0 whether or not tests fail; failures are read from their output.
- On a clean run, `poetry run black <path>` prints a summary containing "left unchanged" and no line beginning "reformatted"; `poetry run ruff check <path>` prints "All checks passed!"; `poetry run pyright <path>` prints "0 errors, 0 warnings, 0 informations". Observed together in `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/frozen-surface-pins.2026-09-30T01-34.md` line 11.
- `pytest -v` prints one PASSED or FAILED line per node and a final summary line such as "30 passed". With `--cov-report=json:<path>`, coverage.py writes a `totals` object carrying `covered_lines`, `num_statements`, `covered_branches`, and `num_branches`, which A20 reads; the terminal table prints only one combined `Cover` column, so no task reads separate line and branch values from the terminal.
- `git grep -c` prints one `path:count` line per file with a match and exits 1 with no output when nothing matches. `git diff --stat <ref> -- <path>` prints nothing when the path is unchanged.
- Jest, through `run-jest.cjs`, prints a line beginning "Tests:" that names a passed count and, only when a test failed, a failed count.
- The other scratch scripts (A8-A10, A12, A14, A16-A23) print only the `KEY=` lines their text in Appendix H writes; their first run is their smoke test (P0-T7 and the task that first uses each).

### Search literal register

The searches in this plan use these fixed strings, quoted here so each is an explicit instruction and not an inferred phrase: "Layer 2", "retrospective backstop:", "SubagentStop", "OrchestratorStateEpicWaveBarrier.psm1", "tests/fixtures/epic_wave_barrier/", "subagentstop-validators-read-undocumented-envelope", "ROUTING_CONTRACT_BLOCKED", "MODEL_ROUTING_BLOCKED", "Mock Resolve-OrchestratorOutputCheckpointPath", "TestDrive", "New-TemporaryFile", "GetTempFileName", "GetTempPath", "Set-Content", "Out-File", "New-Item", "Remove-Item", "Start-Process", "Start-Sleep", "565", "RE-BASELINED by issue #787".

---

### Phase 0 — Policy Reads, Scratch Scripts, Branch Sync, and Baselines

- [ ] [P0-T1] Read `CLAUDE.md` and `.github/copilot-instructions.md` in full, in that order. Acceptance: both read; recorded in P0-T6.
- [ ] [P0-T2] Read, in order, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, and `.github/instructions/python-suppressions.instructions.md`. Acceptance: all seven read; recorded in P0-T6.
- [ ] [P0-T3] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`, and `.claude/rules/self-explanatory-code-commenting.md`. Acceptance: all six read; recorded in P0-T6.
- [ ] [P0-T4] Read, in order, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, and `.claude/rules/orchestrator-state.md`. Acceptance: all four read; recorded in P0-T6.
- [ ] [P0-T5] Read FEATURE/issue.md, FEATURE/spec.md, FEATURE/research/research.2026-10-08T14-00.md in full, and the C6 Scope bullet, `## Dependency Rationale`, and `## Shared Design` of `docs/features/epics/enforcement-hook-precision/epic.md`. Acceptance: all four read; recorded in P0-T6.
- [ ] [P0-T6] Write the policy-read record FEATURE/evidence/baseline/phase0-instructions-read.TS.md. Acceptance: the artifact contains `Timestamp:`, `Policy Order:` (CLAUDE.md, general code change, general unit test, PowerShell, Python), and the explicit list of the 23 files read in P0-T1 through P0-T5 in reading order.
- [ ] [P0-T7] Create the 23 scratch files A1 through A23 of Appendix H verbatim under SCRATCH (staged copies later go under `SCRATCH/stage/`), then smoke-test with CMD-PS-SCRIPT, script line-counts (A4), argument `CLAUDE.md`. Write FEATURE/evidence/other/scratch-smoke.TS.md. Acceptance: exit 0 and one output line beginning `CLAUDE.md LineCount=`; the artifact lists the 23 file names.
- [ ] [P0-T8] Verify checkpoint readiness read-only. Command: CMD-PS-SCRIPT with script checkpoint-probe (A8) and argument `artifacts/orchestration/orchestrator-state.json`. Write FEATURE/evidence/baseline/checkpoint-readiness.TS.md. Acceptance: output contains `ROUTE_ID=large`, `LIFECYCLE_READY=True`, and `ISSUE_NUM=787`. Otherwise stop and report; this plan does not write the checkpoint.
- [ ] [P0-T9] Record branch state in FEATURE/evidence/baseline/branch-state.TS.md. Commands: CMD-GIT-BRANCH, CMD-GIT-HEAD (recorded as PRE_MERGE_SHA), CMD-GIT-STATUS. Acceptance: the branch is BRANCH; PRE_MERGE_SHA is 40 hexadecimal characters; CMD-GIT-STATUS prints no line other than a line for PLAN (modified or untracked) and lines for the untracked planner memory directory `.claude/agent-memory/` when present. Any other line stops the plan.
- [ ] [P0-T10] Fetch the integration branch and confirm upstream C2 is merged. Commands: CMD-GIT-FETCH-INT, CMD-GIT-INT-SHA, CMD-GIT-C2-CHECK. Write FEATURE/evidence/baseline/integration-sync.TS.md. Acceptance: fetch exits 0; the integration SHA is recorded; CMD-GIT-C2-CHECK prints at least one line (a commit that touches WAVE and whose message carries `565`). Zero lines stops the plan with `C2-NOT-MERGED`, because AC-21 is defined only after C2 merges.
- [ ] [P0-T11] Merge the integration branch into BRANCH. Command: CMD-GIT-MERGE-INT. Branches (exactly one applies): (a) output contains "Already up to date." — no commit; MERGED_SHA = PRE_MERGE_SHA; (b) merge stopped with no conflict — CMD-GIT-COMMIT with message `chore(787): merge epic/enforcement-hook-precision-integration after C2 (#565)` and no pathspec, then CMD-GIT-HEAD recorded as MERGED_SHA; (c) any conflict — run `git merge --abort`, stop, and report the conflicted paths. Record INTEGRATION_SHA (the SHA printed by CMD-GIT-INT-SHA in P0-T10) and MERGED_SHA in the P0-T10 artifact. Acceptance: branch (a) or (b) completed; `git status --porcelain` afterwards prints no tracked-file line.
- [ ] [P0-T12] Check that the merge did not move the files this plan's specifications describe. Command: `git diff --stat PRE_MERGE_SHA MERGED_SHA -- .claude/hooks/validate-orchestrator-output.ps1 tests/scripts/claude-hooks scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py scripts/dev_tools/_epic_orchestrator_state_resolution.py scripts/dev_tools/validate_epic_orchestrator_state.py tests/fixtures/epic_wave_barrier .claude/lib/orchestrator-state .claude/lib/worktree-resolution .claude/skills/epic-orchestrate/SKILL.md .claude/agents/epic-orchestrator.md .claude/hooks/enforce-epic-wave-barrier.ps1`, plus `git status --porcelain` to confirm a clean tree. Write FEATURE/evidence/baseline/merge-drift.TS.md listing every path the diff names. Acceptance: no listed path is HOOK, T-MAIN, T-DISPATCH, T-ROUTING, T-HUMAN, one of the three Python authority files, or a file under `.claude/lib/orchestrator-state`; any such path stops the plan for re-derivation. Every other path (for example under `.claude/lib/worktree-resolution`, `tests/scripts/claude-hooks/enforce-*`, WAVE, SKILL, and AGENT) is allowed and recorded.
- [ ] [P0-T13] Re-read WAVE on the merged tree and re-locate the Layer 2 sentence by its text. Command: CMD-PS-SCRIPT with script locate-text (A9), `-Path .claude/hooks/enforce-epic-wave-barrier.ps1 -Literal 'Layer 2'`. Write FEATURE/evidence/other/wave-barrier-layer2-location.TS.md quoting every `MATCH` line and `HELP_END_LINE=`. Acceptance: `MATCH-SUMMARY count=` is at least 1 and every matched line number is less than `HELP_END_LINE`; the artifact names the paragraph (first and last line numbers between blank comment lines) that holds the first match, which P5-T3 replaces. If the count is 0, rerun A9 with `-Literal 'SubagentStop'`; a match inside the help block is used instead and recorded; no match in either run stops the plan.
- [ ] [P0-T14] Re-locate the SKILL bullet and the AGENT sentence by text on the merged tree. Commands: A9 with `-Path .claude/skills/epic-orchestrate/SKILL.md -Literal 'retrospective backstop:'` (ASCII-only argument), and A9 with `-Path .claude/agents/epic-orchestrator.md -Literal 'SubagentStop'`. Write FEATURE/evidence/other/doc-edit-locations.TS.md. Acceptance: SKILL count is exactly 1; AGENT has at least one match in the `## Wave Scheduling` paragraph (the paragraph that also contains `validate_epic_orchestrator_state_text`), whose line range is recorded.
- [ ] [P0-T15] Re-read the resolver exports consumed by C6 (C3 #850 may have changed WRR). Command: CMD-PS-SCRIPT with script module-exports (A10); then CMD-PS-SCRIPT with file-hashes (A5) over WRR and `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`. Write FEATURE/evidence/baseline/resolver-exports.TS.md. Acceptance: `MISSING_CONSUMED=0`; both `Hash=` values recorded (WRR value recorded as WRR_HASH).
- [ ] [P0-T16] Observe JSON-engine behavior the Layer 2 rows depend on. Command: CMD-PS-SCRIPT with script json-engine-probe (A16). Write FEATURE/evidence/baseline/json-engine-probe.TS.md. Acceptance: output contains `CFJ_NAN_ACCEPTED=True`, `CFJ_DEPTH70_ACCEPTED=True`, `STJ_NAN_REJECTED=True`, and `STJ_DEPTH70_REJECTED=True`; any `False` stops the plan, because rows H9 and H10 would then be unsatisfiable.
- [ ] [P0-T17] Record pre-change line counts. Command: CMD-PS-SCRIPT with script line-counts (A4) over the files of Appendix F group LC-BASE. Write FEATURE/evidence/baseline/line-counts.TS.md. Acceptance: exit 0 and one `LineCount=` line per LC-BASE file (10 lines); HOOK and T-MAIN values recorded as BASE_HOOK_LINES and BASE_MAIN_LINES.
- [ ] [P0-T18] Record mirror-pair hashes for the existing pairs of Appendix F group MP-EXIST. Command: CMD-PS-SCRIPT with script pair-hashes (A13) over those pairs. Write FEATURE/evidence/baseline/mirror-hashes.TS.md. Acceptance: `PAIR-SUMMARY pairs=4 unequal=0`. An unequal pair stops the plan, because a later `cp` would discard a bundle-specific difference.
- [ ] [P0-T19] PowerShell format baseline over every file the MCP format calls of this plan scan. Command: CMD-PS-SCRIPT with script ps-format-check (A6) over `.claude/hooks/*.ps1 .claude/lib/orchestrator-state/*.psm1 tests/scripts/claude-hooks/*.ps1 tests/scripts/claude-lib/orchestrator-state/*.ps1`. Write FEATURE/evidence/baseline/powershell-format.TS.md. Acceptance: exit 0 and `FORMAT-SUMMARY ChangedCount=0`. A non-zero count stops the plan, because folder-scoped MCP format calls would otherwise rewrite files outside this item.
- [ ] [P0-T20] PowerShell analyzer baseline for the existing production files this plan changes (HOOK, WAVE). Command: CMD-PS-SCRIPT with script pssa-count (A7) over those two files. Write FEATURE/evidence/baseline/powershell-analyze.TS.md. Acceptance: exit 0 and the `PSSA-SUMMARY DiagnosticCount=` value recorded as BASE_PSSA.
- [ ] [P0-T21] Pester baseline for SET-HOOK-BASE (Appendix G). Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path` set to the SET-HOOK-BASE list. Write FEATURE/evidence/baseline/pester-set-hook.TS.md. Acceptance: the artifact records `TotalCount=` (as BASE_HOOK_TOTAL), `PassedCount=`, `FailedCount=`, and every `FAILED:` line verbatim (the baseline failure set, possibly empty).
- [ ] [P0-T22] Pester baseline for SET-LIB, artifact FEATURE/evidence/baseline/pester-set-lib.TS.md. Acceptance: as P0-T21; TotalCount recorded as BASE_LIB_TOTAL.
- [ ] [P0-T23] Pester baseline for SET-WRR, artifact FEATURE/evidence/baseline/pester-set-wrr.TS.md. Acceptance: as P0-T21; TotalCount recorded as BASE_WRR_TOTAL.
- [ ] [P0-T24] Pester baseline for SET-GUARD, artifact FEATURE/evidence/baseline/pester-set-guard.TS.md. Acceptance: as P0-T21; TotalCount recorded as BASE_GUARD_TOTAL.
- [ ] [P0-T25] PowerShell coverage baseline for HOOK. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath` the SET-HOOK-BASE list, `-CoveragePath .claude/hooks/validate-orchestrator-output.ps1`, `-CoverageOutputPath SCRATCH/cov-hook-base.xml`, `-ReportPath SCRATCH/cov-hook-base.txt`. Write FEATURE/evidence/baseline/coverage-powershell.TS.md. Acceptance: one `COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1` line with a numeric `LinePercent=` recorded as BASE_HOOK_PCT. SIB and PORT do not exist yet; the artifact records their baseline as `NEW-FILE`.
- [ ] [P0-T26] Python format baseline (read-only). Command: `poetry run black --check .` Write FEATURE/evidence/baseline/python-black.TS.md. Acceptance: exit 0 and output containing "would be left unchanged". A non-zero exit stops the plan, because the final `poetry run black .` would rewrite files outside this item.
- [ ] [P0-T27] Python lint baseline. Command: `poetry run ruff check .` Write FEATURE/evidence/baseline/python-ruff.TS.md. Acceptance: exit and summary recorded (expected "All checks passed!").
- [ ] [P0-T28] Python type-check baseline. Command: `poetry run pyright` Write FEATURE/evidence/baseline/python-pyright.TS.md. Acceptance: exit and the errors/warnings/informations summary line recorded.
- [ ] [P0-T29] Python test and coverage baseline. Command: CMD-PY-FULL with json name `py-coverage-base.json`, then CMD-PS-SCRIPT with script py-coverage-totals (A20) and `-Path SCRATCH/py-coverage-base.json`. Write FEATURE/evidence/baseline/python-pytest-coverage.TS.md. Acceptance: the pytest summary line, every failed node id (the baseline failure set), the KL-510 disposition, and the A20 line with numeric `LinePercent=` and `BranchPercent=` (recorded as BASE_PY_LINE and BASE_PY_BRANCH) are recorded.
- [ ] [P0-T30] Python targeted baseline. Command: CMD-PY-TEST over the PY-TARGET-BASE list (Appendix G), then CMD-PY-PARITY. Write FEATURE/evidence/baseline/python-targeted.TS.md. Acceptance: both summaries recorded; PY-TARGET-BASE passes with 0 failed; CMD-PY-PARITY satisfies KL-510 and has no other failed node.
- [ ] [P0-T31] Ensure the extension test dependencies exist. Check `extensions/drm-copilot/node_modules/jest` with Glob. Branches: present — record `NODE_MODULES: PRESENT`; absent — run `npm --prefix extensions/drm-copilot ci` and record its exit code. Write FEATURE/evidence/baseline/node-modules.TS.md. Acceptance: `NODE_MODULES: PRESENT`, or the install exited 0 and a second Glob finds `extensions/drm-copilot/node_modules/jest`.
- [ ] [P0-T32] TypeScript lane baseline for the existing start-guard fixture. Command: CMD-TS-TEST with `test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts`. Write FEATURE/evidence/baseline/ts-wave-barrier.TS.md. Acceptance: exit 0 and the "Tests:" line names a passed count and no failed count.
- [ ] [P0-T33] Commit and push Phase 0 evidence. CMD-GIT-ADD and CMD-GIT-COMMIT with paths FEATURE/evidence and PLAN, message `docs(787): record phase 0 policy reads, integration sync, and baselines`; then CMD-GIT-PUSH. Acceptance: commit and push exit 0; `git status --porcelain` prints no line for FEATURE/evidence or PLAN.

### Phase 1 — Parity Corpus and Python Lane

- [ ] [P1-T1] Write CORPUS with the exact content of Appendix D (LF line endings). Command: CMD-PS-SCRIPT with script json-parse (A12), `-Path tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json`. Write FEATURE/evidence/regression-testing/corpus-written.TS.md. Acceptance: output `JSON-OK file=tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json cases=28`.
- [ ] [P1-T2] Write PYLANE per Appendix C6. Acceptance: the file exists and defines exactly the three test functions named in C6.
- [ ] [P1-T3] Run PYLANE against the Python authority. Command: CMD-PY-TEST with `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py`. Write FEATURE/evidence/regression-testing/pylane.TS.md. Acceptance: summary "30 passed" and no FAILED line. A failed case is handled only by D12 (expectation replaced by the authority output, FEATURE/evidence/other/corpus-derivation.TS.md written), then this task is re-run until "30 passed".
- [ ] [P1-T4] Confirm the existing start-guard lanes are unchanged and pass. Commands: `git diff --stat INTEGRATION_SHA -- tests/fixtures/epic_wave_barrier/start-guard-matrix.json tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts` (with `git status --porcelain` to show none of the three is modified), then CMD-PY-TEST with `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`. Write FEATURE/evidence/regression-testing/start-guard-unchanged.TS.md. Acceptance: the diff prints nothing; the porcelain output names none of the three paths; pytest reports 0 failed and the node `test_start_guard_matrix_has_fourteen_unique_cases` PASSED.
- [ ] [P1-T5] Run the TypeScript start-guard lane. Command: CMD-TS-TEST with `test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts`. Write FEATURE/evidence/regression-testing/ts-wave-barrier.TS.md. Acceptance: exit 0 and the "Tests:" line names a passed count equal to the P0-T32 passed count and no failed count.
- [ ] [P1-T6] Python toolchain on PYLANE. Commands: `poetry run black tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py`, `poetry run ruff check tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py`, `poetry run pyright tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py`. Write FEATURE/evidence/regression-testing/pylane-toolchain.TS.md. Acceptance: black output contains "left unchanged" and no line beginning "reformatted" (a reformat restarts this task after re-running P1-T3); ruff prints "All checks passed!"; pyright prints "0 errors".
- [ ] [P1-T7] Line counts for PYLANE and CORPUS (A4). Write FEATURE/evidence/qa-gates/line-counts-phase1.TS.md. Acceptance: both `LineCount=` values are at most 500.
- [ ] [P1-T8] Check off AC-14 in FEATURE/spec.md (change only `- [ ]` to `- [x]` on the AC-14 line, Appendix I). Evidence: P1-T1, P1-T3, P1-T4. Acceptance: CMD-PS-SCRIPT with script ac-checkbox-count (A21), `-Path FEATURE/spec.md`, prints `AC-CHECKBOXES total=26 checked=1 unchecked=25`.
- [ ] [P1-T9] Check off AC-16 in FEATURE/spec.md. Evidence: P1-T3, P1-T4, P1-T5. Acceptance: A21 prints `checked=2 unchecked=24`.
- [ ] [P1-T10] Commit and push Phase 1. CMD-GIT-ADD and CMD-GIT-COMMIT with paths CORPUS, PYLANE, FEATURE/spec.md, FEATURE/evidence, PLAN, message `test(840): add Layer 2 parity corpus and Python authority lane`; then CMD-GIT-PUSH. Acceptance: exit 0 for both; `git status --porcelain` prints no line for those paths.

### Phase 2 — Layer 2 Port Module

- [ ] [P2-T1] Write PORT per Appendix B2. Command: CMD-PS-SCRIPT with script stage-check (A15), `-Path .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`. Write FEATURE/evidence/regression-testing/port-stage-check.TS.md. Acceptance: output `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`; otherwise correct PORT and repeat.
- [ ] [P2-T2] Write S4 per Appendix C4. Acceptance: A15 on S4 prints `ParseErrors=0`.
- [ ] [P2-T3] Write S5 per Appendix C5, with the declared-divergence list in its comment help. Acceptance: A15 on S5 prints `ParseErrors=0`.
- [ ] [P2-T4] Scan S4 and S5 for prohibited test constructs. Command: CMD-PS-SCRIPT with script token-scan (A17), `-Token 'TestDrive,New-TemporaryFile,GetTempFileName,GetTempPath,Set-Content,Out-File,New-Item,Remove-Item,Start-Process,Start-Sleep'` and `-File` the two paths. Write FEATURE/evidence/regression-testing/port-suite-purity.TS.md. Acceptance: `TOKEN-SUMMARY count=0 files=2`.
- [ ] [P2-T5] Run S4 and S5. Command: A2 with `-Path` S4,S5. Write FEATURE/evidence/regression-testing/port-suites.TS.md. Acceptance: `TotalCount=27`, `PassedCount=27`, `FailedCount=0`.
- [ ] [P2-T6] PORT coverage. Command: A3 with `-TestPath` S4,S5, `-CoveragePath .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, `-CoverageOutputPath SCRATCH/cov-port.xml`. Write FEATURE/evidence/regression-testing/port-coverage.TS.md. Acceptance: `LinePercent=` for PORT is at least 85; otherwise add S4 rows for the `MISSED` lines (S4 stays at most 500 lines; Appendix C4 count is updated in the artifact) and repeat P2-T5 and this task.
- [ ] [P2-T7] Format PORT, S4, S5. MCP-PS-FORMAT with scan_folders `.claude/lib/orchestrator-state` and `tests/scripts/claude-lib/orchestrator-state`; then A6 over the three files; then `git status --porcelain`. Write FEATURE/evidence/qa-gates/phase2-format.TS.md. Acceptance: MCP call returned; `FORMAT-SUMMARY ChangedCount=0`; the porcelain output names no tracked file outside PORT, S4, S5 (all three untracked or added). A rewrite restarts from P2-T5.
- [ ] [P2-T8] Analyze PORT, S4, S5. MCP-PS-ANALYZE with the P2-T7 folders; then A7 over the three files. Write FEATURE/evidence/qa-gates/phase2-analyze.TS.md. Acceptance: MCP call returned; `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P2-T9] Run the library convention and test-name guards. Command: A2 with `-Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1,tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`. Write FEATURE/evidence/regression-testing/phase2-guards.TS.md. Acceptance: `FailedCount=0`.
- [ ] [P2-T10] Line counts for PORT, S4, S5 (A4). Write FEATURE/evidence/qa-gates/line-counts-phase2.TS.md. Acceptance: each value at most 500.
- [ ] [P2-T11] Check off AC-09 in FEATURE/spec.md. Evidence: P2-T1, P2-T5. Acceptance: A21 prints `checked=3 unchecked=23`.
- [ ] [P2-T12] Check off AC-15. Evidence: P2-T5 (rows P1 and P2 of C5). Acceptance: A21 prints `checked=4 unchecked=22`.
- [ ] [P2-T13] Check off AC-17. Evidence: P2-T3 (header list), P2-T5 (rows D1-D5 of C5 and U6 of C4). Acceptance: A21 prints `checked=5 unchecked=21`.
- [ ] [P2-T14] Commit and push Phase 2. Paths PORT, S4, S5, FEATURE/spec.md, FEATURE/evidence, PLAN; message `feat(840): port the Layer 2 wave-barrier ordering check to PowerShell`; then CMD-GIT-PUSH. Acceptance: exit 0 for both; `git status --porcelain` prints no line for those paths.

### Phase 3 — Resolution Sibling, Hook Wiring, and Hook Suites

- [ ] [P3-T1] Write SIB per Appendix B1 (LF-1: before HOOK). Command: A15 on SIB. Write FEATURE/evidence/regression-testing/sib-stage-check.TS.md. Acceptance: `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`.
- [ ] [P3-T2] Stage the complete new HOOK per Appendix B3 at `SCRATCH/stage/validate-orchestrator-output.ps1` (start from the merged-tree HOOK text). Command: A15 on the staged copy. Acceptance: `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`.
- [ ] [P3-T3] Write HOOK from the staged copy in one Write call; then A5 over the staged copy and HOOK; then A4 over HOOK and SIB. Write FEATURE/evidence/regression-testing/hook-written.TS.md. Acceptance: the two `Hash=` values are equal; HOOK `LineCount=` and SIB `LineCount=` are each at most 500.
- [ ] [P3-T4] Edit T-MAIN: delete the whole Context whose title is `-CheckpointPath / -ArtifactType parameterization (Invoke-OrchestratorOutputValidation)` (lines 361-415 at planning time; located by title), and add `BeforeAll { <DM-LINE> }` (Appendix C0) as the first child of the outermost `Describe 'validate-orchestrator-output.ps1'`. Acceptance: A4 prints a T-MAIN `LineCount=` of at most 500 and at most BASE_MAIN_LINES minus 50; A17 with `-Token 'Mock Resolve-OrchestratorOutputCheckpointPath'` over T-MAIN prints `count=1`.
- [ ] [P3-T5] Edit T-DISPATCH: add `BeforeAll { <DM-LINE> }` as the first child of its outermost `Describe`. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-OrchestratorOutputCheckpointPath` over T-DISPATCH prints a count of 1; A4 at most 500.
- [ ] [P3-T6] Edit T-ROUTING: add `BeforeAll { <DM-LINE> }` as the first child of its outermost `Describe`. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-OrchestratorOutputCheckpointPath` over T-ROUTING prints a count of 1; A4 at most 500.
- [ ] [P3-T7] Write S1 per Appendix C1 (14 rows R1-R14). Acceptance: A15 on S1 prints `ParseErrors=0`.
- [ ] [P3-T8] Write S2 per Appendix C2 (12 rows S2-1 to S2-12). Acceptance: A15 on S2 prints `ParseErrors=0`.
- [ ] [P3-T9] Write S3 per Appendix C3 (12 rows H1-H12). Acceptance: A15 on S3 prints `ParseErrors=0`.
- [ ] [P3-T10] Scan S1, S2, S3 for prohibited constructs (A17, same token list as P2-T4). Write FEATURE/evidence/regression-testing/hook-suite-purity.TS.md. Acceptance: `TOKEN-SUMMARY count=0 files=3`.
- [ ] [P3-T11] Run SET-HOOK. Command: A2 with the SET-HOOK list. Write FEATURE/evidence/regression-testing/set-hook.TS.md. Acceptance: `TotalCount=` equals BASE_HOOK_TOTAL plus 36 (two rows removed by P3-T4, 38 added); `FailedCount=0`; the T-MAIN interpreter row (`invokes no python, python3, py, or poetry command anywhere in the default invoker`) is not among `FAILED:` lines.
- [ ] [P3-T12] Run SET-LIB, SET-WRR, and SET-GUARD (three A2 runs). Write FEATURE/evidence/regression-testing/phase3-neighbours.TS.md. Acceptance: SET-LIB `TotalCount=` equals BASE_LIB_TOTAL plus 27; SET-WRR equals BASE_WRR_TOTAL; SET-GUARD equals BASE_GUARD_TOTAL; each run's `FAILED:` set is a subset of its P0 baseline failure set.
- [ ] [P3-T13] HOOK and SIB coverage. Command: A3 with `-TestPath` the SET-HOOK list, `-CoveragePath .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1`, `-CoverageOutputPath SCRATCH/cov-hook-p3.xml`, `-ReportPath SCRATCH/cov-hook-p3.txt`. Write FEATURE/evidence/regression-testing/hook-coverage.TS.md. Acceptance: both `LinePercent=` values are at least 85; otherwise add rows to S1, S2, or S3 for the `MISSED` lines (each file stays at most 500 lines; the added rows are named in the artifact and the P3-T11 expected total rises by the same number) and repeat P3-T11 and this task.
- [ ] [P3-T14] Resolver-call and interpreter scan. Command: CMD-PS-SCRIPT with script resolver-call-scan (A18), `-File .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1,.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`. Write FEATURE/evidence/qa-gates/resolver-call-scan.TS.md. Acceptance: `RESOLVER-CALL-SUMMARY disallowed=0 interpreter=0`, and the `RESOLVER-CALL` lines name only the seven allowed functions.
- [ ] [P3-T15] Deny-token assertion stability. Command: CMD-PS-SCRIPT with script removed-lines-scan (A19), `-BaseRef INTEGRATION_SHA -Token 'ROUTING_CONTRACT_BLOCKED,MODEL_ROUTING_BLOCKED' -File` HOOK, T-MAIN, T-DISPATCH, T-ROUTING. Write FEATURE/evidence/qa-gates/deny-token-stability.TS.md. Acceptance: `REMOVED-TOKEN-SUMMARY count=0 files=4`.
- [ ] [P3-T16] Format the Phase 3 files. MCP-PS-FORMAT with scan_folders `.claude/hooks` and `tests/scripts/claude-hooks`; then A6 over HOOK, SIB, T-MAIN, T-DISPATCH, T-ROUTING, S1, S2, S3; then `git status --porcelain`. Write FEATURE/evidence/qa-gates/phase3-format.TS.md. Acceptance: MCP call returned; `FORMAT-SUMMARY ChangedCount=0`; the porcelain output names no tracked file other than those eight. A rewrite restarts from P3-T11.
- [ ] [P3-T17] Analyze the Phase 3 files. MCP-PS-ANALYZE with the P3-T16 folders; then A7 over the eight files. Write FEATURE/evidence/qa-gates/phase3-analyze.TS.md. Acceptance: MCP call returned; `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P3-T18] Line counts for the eight Phase 3 files (A4). Write FEATURE/evidence/qa-gates/line-counts-phase3.TS.md. Acceptance: every value at most 500.
- [ ] [P3-T19] Check off AC-02. Evidence: P3-T11 rows R1, R9, R12, R13. Acceptance: A21 prints `checked=6 unchecked=20`.
- [ ] [P3-T20] Check off AC-03. Evidence: P3-T11 rows R5, R6, R7, R8, R10. Acceptance: A21 prints `checked=7 unchecked=19`.
- [ ] [P3-T21] Check off AC-04. Evidence: P3-T11 rows R14, S2-1 to S2-6. Acceptance: A21 prints `checked=8 unchecked=18`.
- [ ] [P3-T22] Check off AC-05. Evidence: P3-T11 row S2-12. Acceptance: A21 prints `checked=9 unchecked=17`.
- [ ] [P3-T23] Check off AC-06. Evidence: P3-T11 (existing suites pass), P3-T15. Acceptance: A21 prints `checked=10 unchecked=16`.
- [ ] [P3-T24] Check off AC-07. Evidence: P3-T10, P3-T11 rows R1-R12. Acceptance: A21 prints `checked=11 unchecked=15`.
- [ ] [P3-T25] Check off AC-08. Evidence: P3-T4 to P3-T6, P3-T11 rows R1 and R12. Acceptance: A21 prints `checked=12 unchecked=14`.
- [ ] [P3-T26] Check off AC-10. Evidence: P3-T11 rows H1, H5, H6, H7. Acceptance: A21 prints `checked=13 unchecked=13`.
- [ ] [P3-T27] Check off AC-11. Evidence: P3-T11 (T-MAIN interpreter row), P3-T12 (`enforcement-hooks-no-python-invocation.Tests.ps1` in SET-GUARD), P3-T14. Acceptance: A21 prints `checked=14 unchecked=12`.
- [ ] [P3-T28] Check off AC-12. Evidence: P2-T5 (corpus parity), P3-T11 rows H1 and H2. Acceptance: A21 prints `checked=15 unchecked=11`.
- [ ] [P3-T29] Check off AC-13. Evidence: P3-T11 rows H8, H9, H10. Acceptance: A21 prints `checked=16 unchecked=10`.
- [ ] [P3-T30] Check off AC-18. Evidence: P3-T11 row H3. Acceptance: A21 prints `checked=17 unchecked=9`.
- [ ] [P3-T31] Commit and push Phase 3. Paths HOOK, SIB, T-MAIN, T-DISPATCH, T-ROUTING, S1, S2, S3, FEATURE/spec.md, FEATURE/evidence, PLAN; message `fix(787): resolve the run checkpoint through WorktreeRunResolution and run Layer 2 at SubagentStop`; then CMD-GIT-PUSH. Acceptance: exit 0 for both; `git status --porcelain` prints no line for those paths.

### Phase 4 — Registration and Bundle Mirrors

- [ ] [P4-T1] Edit CORE: insert `".claude/hooks/validate-orchestrator-output-resolution.ps1",` immediately before the `.claude/hooks/validate-orchestrator-output.ps1` entry, and `".claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1",` immediately after the `OrchestratorStateUnconditional.psm1` entry. Command: A12 on CORE. Acceptance: `JSON-OK`; CMD-GIT-COUNT with literal `validate-orchestrator-output-resolution.ps1` over CORE prints a count of 1 and with literal `OrchestratorStateEpicWaveBarrier.psm1` prints a count of 1.
- [ ] [P4-T2] Edit MANIFEST: append `'.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1'` as the last element of `$script:ExpectedPaths` (adding the separating comma to the previous element). Acceptance: CMD-GIT-COUNT with literal `OrchestratorStateEpicWaveBarrier.psm1` over MANIFEST prints a count of 1.
- [ ] [P4-T3] CMD-CP HOOK to `CB/.claude/hooks/validate-orchestrator-output.ps1`. Acceptance: exit 0.
- [ ] [P4-T4] CMD-CP SIB to `CB/.claude/hooks/validate-orchestrator-output-resolution.ps1`. Acceptance: exit 0.
- [ ] [P4-T5] CMD-CP PORT to `CB/.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`. Acceptance: exit 0.
- [ ] [P4-T6] Mirror check for the code pairs (Appendix F group MP-CODE). Command: A13. Write FEATURE/evidence/qa-gates/mirror-code.TS.md. Acceptance: `PAIR-SUMMARY pairs=3 unequal=0`.
- [ ] [P4-T7] Run MANIFEST and the no-Python guard. Command: A2 with `-Path` MANIFEST,`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`. Write FEATURE/evidence/regression-testing/manifest-and-no-python.TS.md. Acceptance: `FailedCount=0`.
- [ ] [P4-T8] Python bundle-parity suites. Command: CMD-PY-PARITY. Write FEATURE/evidence/regression-testing/py-parity-phase4.TS.md. Acceptance: no failed node other than a KL-510 case (b); KL-510 disposition recorded.
- [ ] [P4-T9] TypeScript pack-manifest completeness. Command: CMD-TS-TEST with `test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Write FEATURE/evidence/regression-testing/ts-pack-manifest.TS.md. Acceptance: exit 0 and the "Tests:" line names no failed count.
- [ ] [P4-T10] Commit and push Phase 4. Paths CORE, MANIFEST, the three CB mirrors, FEATURE/evidence, PLAN; message `chore(787): register and mirror the resolution sibling and Layer 2 port`; then CMD-GIT-PUSH. Acceptance: exit 0 for both; `git status --porcelain` prints no line for those paths.

### Phase 5 — Documentation Corrections (#840)

- [ ] [P5-T1] Edit SKILL: replace the whole `**Layer 2 — retrospective backstop:**` bullet located by P0-T14 with the text of Appendix E1, wrapped at 100 columns with backticked tokens unbroken; then CMD-CP SKILL to `CB/.claude/skills/epic-orchestrate/SKILL.md`. Acceptance: CMD-GIT-COUNT over SKILL prints a count of at least 1 for each literal `OrchestratorStateEpicWaveBarrier.psm1`, `tests/fixtures/epic_wave_barrier/`, and `subagentstop-validators-read-undocumented-envelope` (each was absent from SKILL before the edit; the P5-T6 artifact records both counts).
- [ ] [P5-T2] Edit AGENT: replace the sentence of the `## Wave Scheduling` paragraph that begins "Do not launch wave N+1" (located by P0-T14) through the end of that paragraph with the text of Appendix E2; then CMD-CP AGENT to `CB/.claude/agents/epic-orchestrator.md`. Acceptance: CMD-GIT-COUNT over AGENT prints a count of at least 1 for each literal `OrchestratorStateEpicWaveBarrier.psm1`, `tests/fixtures/epic_wave_barrier/`, and `subagentstop-validators-read-undocumented-envelope`.
- [ ] [P5-T3] Edit WAVE with one Edit call that replaces only the comment-help paragraph recorded by P0-T13 with the text of Appendix E3, using the indentation of the surrounding help lines (LF-2); then A15 on WAVE; then CMD-CP WAVE to `CB/.claude/hooks/enforce-epic-wave-barrier.ps1`. Acceptance: `STAGE-CHECK ParseErrors=0 FormatChanged=False`; CMD-GIT-COUNT over WAVE prints a count of 1 for `OrchestratorStateEpicWaveBarrier.psm1` and 1 for `subagentstop-validators-read-undocumented-envelope`.
- [ ] [P5-T4] Prove WAVE changed only in comments. Command: CMD-PS-SCRIPT with script noncomment-compare (A14), `-Path .claude/hooks/enforce-epic-wave-barrier.ps1 -BaseRef INTEGRATION_SHA`. Write FEATURE/evidence/qa-gates/wave-comment-only.TS.md. Acceptance: `NONCOMMENT-EQUAL=True`.
- [ ] [P5-T5] Mirror check for the document pairs (Appendix F group MP-DOC). Command: A13. Write FEATURE/evidence/qa-gates/mirror-doc.TS.md. Acceptance: `PAIR-SUMMARY pairs=3 unequal=0`.
- [ ] [P5-T6] Record the corrected passages. Write FEATURE/evidence/other/doc-corrections.TS.md quoting the final SKILL bullet, the final AGENT sentences, and the final WAVE paragraph with their line ranges. Acceptance: the artifact holds the three quotations; each contains `OrchestratorStateEpicWaveBarrier.psm1` and the potential-entry file name.
- [ ] [P5-T7] Re-baseline PIN. Command: CMD-PS-SCRIPT with script lowercase-digest (A22) over SKILL and AGENT. Edit PIN: replace the two digest strings in `PINNED_FROZEN_SURFACE_HASHES` with the printed values and append to the comment block above it the paragraph of Appendix E4. Write FEATURE/evidence/other/pin-rebaseline.TS.md with both old and new digests. Acceptance: CMD-GIT-COUNT with literal `RE-BASELINED by issue #787` over PIN prints a count of 1; each new digest is 64 lowercase hexadecimal characters and appears in PIN.
- [ ] [P5-T8] Python toolchain on PIN. Commands: `poetry run black tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. Write FEATURE/evidence/qa-gates/pin-toolchain.TS.md. Acceptance: black output contains "left unchanged" and no line beginning "reformatted"; ruff "All checks passed!"; pyright "0 errors".
- [ ] [P5-T9] Document contract tests. Command: CMD-PY-TEST over PY-TARGET (Appendix G). Write FEATURE/evidence/regression-testing/doc-contracts.TS.md. Acceptance: 0 failed; node `test_frozen_epic_surface_matches_pinned_baseline_digest` PASSED for both parameters.
- [ ] [P5-T10] Run SET-GUARD and SET-HOOK. Two A2 runs. Write FEATURE/evidence/regression-testing/phase5-suites.TS.md. Acceptance: SET-GUARD `TotalCount=` equals BASE_GUARD_TOTAL with a `FAILED:` set that is a subset of its baseline set; SET-HOOK `FailedCount=0`.
- [ ] [P5-T11] Codex-copy check per changed or new `.claude` file. Command: CMD-PS-SCRIPT with script codex-copy-check (A23) over HOOK, SIB, PORT, WAVE, SKILL, AGENT; then A17 with `-Token 'Layer 2,validate_epic_orchestrator_state_text'` over every candidate printed with `exists=True`. Write FEATURE/evidence/other/codex-copy-check.TS.md with one row per file: candidate paths, existence, the A17 count, and the disposition `NO CODEX COPY` or `CODEX ANALOGUE EXCLUDED BY SPEC (no change)`. Acceptance: six rows; every `exists=True` candidate is one of `.codex/hooks/enforce-epic-wave-barrier.ps1`, `.codex/agents/epic-orchestrator.toml`, `.agents/skills/epic-orchestrate/SKILL.md`; `git status --porcelain` names no path under `.codex/` or `.agents/`.
- [ ] [P5-T12] Re-run the bundle-parity suites with all mirrors in place. Command: CMD-PY-PARITY. Write FEATURE/evidence/regression-testing/py-parity-phase5.TS.md. Acceptance: no failed node other than a KL-510 case (b).
- [ ] [P5-T13] Check off AC-19. Evidence: P5-T1, P5-T5, P5-T6. Acceptance: A21 prints `checked=18 unchecked=8`.
- [ ] [P5-T14] Check off AC-20. Evidence: P5-T2, P5-T5, P5-T6. Acceptance: A21 prints `checked=19 unchecked=7`.
- [ ] [P5-T15] Check off AC-21. Evidence: P0-T13, P5-T3, P5-T4, P5-T5. Acceptance: A21 prints `checked=20 unchecked=6`.
- [ ] [P5-T16] Check off AC-22. Evidence: P5-T1 to P5-T3, P5-T6. Acceptance: A21 prints `checked=21 unchecked=5`.
- [ ] [P5-T17] Check off AC-23. Evidence: P4-T1, P4-T2, P4-T6, P4-T7, P5-T5, P5-T11, P5-T12. Acceptance: A21 prints `checked=22 unchecked=4`.
- [ ] [P5-T18] Commit and push Phase 5. Paths SKILL, AGENT, WAVE, their three CB mirrors, PIN, FEATURE/spec.md, FEATURE/evidence, PLAN; message `docs(840): describe the PowerShell Layer 2 check at epic-orchestrator SubagentStop`; then CMD-GIT-PUSH. Acceptance: exit 0 for both; `git status --porcelain` prints no line for those paths.

### Phase 6 — Final QA Loop, Coverage Comparison, and AC Closure

- [ ] [P6-T1] Re-sync with the integration branch (C3 may have merged). Commands: CMD-GIT-FETCH-INT, CMD-GIT-INT-SHA (recorded as FINAL_INTEGRATION_SHA), CMD-GIT-MERGE-INT with the P0-T11 branches (a), (b) with message `chore(787): merge epic/enforcement-hook-precision-integration before final QA`, or (c) stop. Write FEATURE/evidence/qa-gates/final-sync.TS.md. Acceptance: branch (a) or (b) completed; `git status --porcelain` prints no tracked-file line; when branch (b) applied, the artifact lists `git diff --stat MERGED_SHA HEAD -- .claude/lib/worktree-resolution` output so the re-run of P6-T6 covers any resolver change.
- [ ] [P6-T2] WRR is unchanged by this branch. Command: `git diff --stat origin/epic/enforcement-hook-precision-integration -- .claude/lib/worktree-resolution/WorktreeRunResolution.psm1` Write FEATURE/evidence/qa-gates/wrr-unchanged.TS.md. Acceptance: exit 0 and empty output.
- [ ] [P6-T3] Final PowerShell format. MCP-PS-FORMAT with scan_folders `.claude/hooks`, `.claude/lib/orchestrator-state`, `tests/scripts/claude-hooks`, `tests/scripts/claude-lib/orchestrator-state`; then A6 over Appendix F group PS-ALL; then `git status --porcelain`. Write FEATURE/evidence/qa-gates/final-ps-format.TS.md. Acceptance: MCP call returned; `FORMAT-SUMMARY ChangedCount=0`; the porcelain output is empty. A rewrite or failure restarts the loop from this task (P6-T17).
- [ ] [P6-T4] Final PowerShell analyze. MCP-PS-ANALYZE with the P6-T3 folders; then A7 over PS-ALL. Write FEATURE/evidence/qa-gates/final-ps-analyze.TS.md. Acceptance: MCP call returned; `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P6-T5] Final PoshQC test route-compliance call. MCP-PS-TEST. Write FEATURE/evidence/qa-gates/final-ps-mcp-test.TS.md. Acceptance: the call returned (`EXIT_CODE: 0` as call disposition); no count is read from it.
- [ ] [P6-T6] Final Pester counts. Four A2 runs: SET-HOOK, SET-LIB, SET-WRR, SET-GUARD. Write FEATURE/evidence/qa-gates/final-pester.TS.md. Acceptance: SET-HOOK `TotalCount=` equals BASE_HOOK_TOTAL plus 36 plus any rows added under P3-T13, with `FailedCount=0`; SET-LIB equals BASE_LIB_TOTAL plus 27 plus any rows added under P2-T6, with `FailedCount=0`; SET-WRR and SET-GUARD `FAILED:` sets are subsets of their P0 baseline sets.
- [ ] [P6-T7] Final PowerShell coverage. Command: A3 with `-TestPath` the SET-HOOK list plus S4,S5, `-CoveragePath` HOOK,SIB,PORT, `-CoverageOutputPath SCRATCH/cov-final.xml`, `-ReportPath SCRATCH/cov-final.txt`. Write FEATURE/evidence/qa-gates/final-ps-coverage.TS.md. Acceptance: three `COVERAGE` lines, each `LinePercent=` at least 85.
- [ ] [P6-T8] Changed-line coverage for HOOK. Command: CMD-PS-SCRIPT with script changed-line-coverage (A11), `-CoverageReportPath SCRATCH/cov-final.txt -BaseRef INTEGRATION_SHA -File .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1,.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`. Write FEATURE/evidence/qa-gates/final-changed-line-coverage.TS.md. Acceptance: three `CHANGED-COVERAGE` lines, each `ChangedPercent=` at least 85 (`NA` fails).
- [ ] [P6-T9] Coverage comparison. Write FEATURE/evidence/qa-gates/coverage-comparison.TS.md with `Timestamp:`, `Command: comparison of P0-T25, P0-T29, P6-T7, P6-T8, P6-T14`, `EXIT_CODE: 0`, and `Output Summary:` stating BASE_HOOK_PCT, final HOOK/SIB/PORT `LinePercent=`, the three `ChangedPercent=` values, BASE_PY_LINE/BASE_PY_BRANCH, and the final Python values. Acceptance: final HOOK, SIB, and PORT LinePercent are each at least 85 and each ChangedPercent is at least 85; final Python LinePercent is at least BASE_PY_LINE minus 0.1 and BranchPercent at least BASE_PY_BRANCH minus 0.1 (no regression; this plan changes no production Python); the final Python values are compared with 85 (line) and 75 (branch) and recorded as met or not met, and a value below its threshold is acceptable only when the baseline value was already below it, recorded as pre-existing with both numbers. Any other shortfall makes the outcome remediation-required.
- [ ] [P6-T10] Final line counts. Command: A4 over Appendix F group LC-ALL. Write FEATURE/evidence/qa-gates/final-line-counts.TS.md. Acceptance: 17 `LineCount=` lines, each at most 500.
- [ ] [P6-T11] Final Python format. Command: `poetry run black .` then `git status --porcelain`. Write FEATURE/evidence/qa-gates/final-py-black.TS.md. Acceptance: exit 0; output contains "left unchanged" and no line beginning "reformatted"; the porcelain output is empty.
- [ ] [P6-T12] Final Python lint. Command: `poetry run ruff check .` Write FEATURE/evidence/qa-gates/final-py-ruff.TS.md. Acceptance: exit 0 and "All checks passed!".
- [ ] [P6-T13] Final Python type check. Command: `poetry run pyright` Write FEATURE/evidence/qa-gates/final-py-pyright.TS.md. Acceptance: exit 0 and a summary line beginning "0 errors".
- [ ] [P6-T14] Final Python tests with coverage. Command: CMD-PY-FULL with json name `py-coverage-final.json`, then A20 with `-Path SCRATCH/py-coverage-final.json`. Write FEATURE/evidence/qa-gates/final-py-pytest.TS.md. Acceptance: the failed-node set is empty or consists only of a KL-510 case (b); PYLANE nodes all PASSED; the A20 line records numeric `LinePercent=` and `BranchPercent=`.
- [ ] [P6-T15] Final targeted and parity Python runs. Commands: CMD-PY-TEST over PY-TARGET; CMD-PY-PARITY. Write FEATURE/evidence/qa-gates/final-py-targeted.TS.md. Acceptance: PY-TARGET 0 failed; CMD-PY-PARITY no failed node other than a KL-510 case (b).
- [ ] [P6-T16] Final TypeScript lanes. Commands: CMD-TS-TEST with `test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts`; CMD-TS-TEST with `test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Write FEATURE/evidence/qa-gates/final-ts.TS.md. Acceptance: both exit 0 with "Tests:" lines naming no failed count.
- [ ] [P6-T17] Record the single clean pass. Write FEATURE/evidence/qa-gates/final-loop.TS.md listing, for the last pass, each of P6-T3 through P6-T16 with its artifact path and result, and the pass number. Acceptance: in the recorded pass every task met its acceptance and no task changed a tracked file; if any did not, fix the cause and restart from P6-T3.
- [ ] [P6-T18] Check off AC-01. Evidence: P3-T11 rows R1-R12, P3-T14, P6-T2. Acceptance: A21 prints `checked=23 unchecked=3`.
- [ ] [P6-T19] Check off AC-24. Evidence: P6-T10. Acceptance: A21 prints `checked=24 unchecked=2`.
- [ ] [P6-T20] Check off AC-25. Evidence: P6-T7, P6-T8. Acceptance: A21 prints `checked=25 unchecked=1`.
- [ ] [P6-T21] Check off AC-26. Evidence: P6-T17. Acceptance: A21 prints `AC-CHECKBOXES total=26 checked=26 unchecked=0`.
- [ ] [P6-T22] Write the AC status summary FEATURE/evidence/qa-gates/ac-status.TS.md in the `### Acceptance Criteria Status` form of the acceptance-criteria-tracking skill (source FEATURE/spec.md, total 26, checked 26, remaining 0) with the check-off task for each AC. Acceptance: the artifact carries the five fields and 26 rows.
- [ ] [P6-T23] Final commit and push. Paths FEATURE/spec.md, FEATURE/evidence, PLAN; message `docs(787): record final QA, coverage comparison, and acceptance criteria`; then CMD-GIT-PUSH; then `git log --oneline INTEGRATION_SHA..HEAD` and `git status --porcelain` recorded in FEATURE/evidence/qa-gates/final-commit.TS.md. Acceptance: commit and push exit 0; the porcelain output is empty; the log lists the phase commits of Phases 0-6.

## Acceptance Criteria Traceability

| AC | Spec line | Implementation | Tests / checks | Evidence task(s) |
|---|---|---|---|---|
| AC-01 | 184 | SIB `Resolve-OrchestratorOutputCheckpointPath` | S1 R1-R12; A18 scan; WRR diff vs INTEGRATION | P3-T11, P3-T14, P6-T2, P6-T18 |
| AC-02 | 185 | HOOK absolute paths; SIB runbook helpers | S1 R1, R9, R12, R13 | P3-T11, P3-T19 |
| AC-03 | 186 | HOOK unresolved block | S1 R5-R8, R10 | P3-T11, P3-T20 |
| AC-04 | 187 | SIB leaf checks | S1 R14; S2-1 to S2-6 | P3-T11, P3-T21 |
| AC-05 | 188 | HOOK import guards | S2-12 | P3-T11, P3-T22 |
| AC-06 | 189 | HOOK tokens unchanged | existing suites; A19 | P3-T11, P3-T15, P3-T23 |
| AC-07 | 190 | S1 topology suite | S1 R1-R12; A17 purity | P3-T10, P3-T11, P3-T24 |
| AC-08 | 191 | DM-LINE in three suites; D8 move | T-MAIN, T-DISPATCH, T-ROUTING; S1 R1, R12 | P3-T4 to P3-T6, P3-T25 |
| AC-09 | 192 | PORT | S4, S5 | P2-T1, P2-T5, P2-T11 |
| AC-10 | 193 | HOOK epic-only call after dispatch | S3 H1, H5, H6, H7 | P3-T11, P3-T26 |
| AC-11 | 194 | no Python in HOOK, SIB, PORT | T-MAIN AST row; no-Python guard; A18 | P3-T11, P3-T12, P3-T14, P3-T27 |
| AC-12 | 195 | PORT rendering; HOOK unwrapped lines | S5 P1, P2; S3 H1, H2 | P2-T5, P3-T11, P3-T28 |
| AC-13 | 196 | PORT and SIB UNEVALUABLE paths | S3 H8, H9, H10 | P3-T11, P3-T29 |
| AC-14 | 197 | CORPUS | A12; PYLANE; start-guard diff | P1-T1, P1-T3, P1-T4, P1-T8 |
| AC-15 | 198 | S5 corpus lane | S5 P1, P2 | P2-T5, P2-T12 |
| AC-16 | 199 | PYLANE | PYLANE; existing Python and TS lanes | P1-T3 to P1-T5, P1-T9 |
| AC-17 | 200 | S5 header; S4 U6 | S5 D1-D5; S4 U6 | P2-T3, P2-T5, P2-T13 |
| AC-18 | 201 | SIB halt instruction | S3 H3 | P3-T11, P3-T30 |
| AC-19 | 202 | SKILL bullet + mirror | CMD-GIT-COUNT; A13 | P5-T1, P5-T5, P5-T13 |
| AC-20 | 203 | AGENT sentence + mirror | CMD-GIT-COUNT; A13 | P5-T2, P5-T5, P5-T14 |
| AC-21 | 204 | WAVE header + mirror | A9; A14; A13 | P0-T13, P5-T3, P5-T4, P5-T15 |
| AC-22 | 205 | caveat sentence in three passages | CMD-GIT-COUNT | P5-T1 to P5-T3, P5-T16 |
| AC-23 | 206 | mirrors, CORE, MANIFEST, Codex check | A13; MANIFEST; CMD-PY-PARITY | P4-T1 to P4-T8, P5-T5, P5-T11, P5-T12, P5-T17 |
| AC-24 | 207 | file placement | A4 | P6-T10, P6-T19 |
| AC-25 | 208 | coverage rows | A3; A11 | P6-T7, P6-T8, P6-T20 |
| AC-26 | 209 | full loops | P6-T3 to P6-T16 | P6-T17, P6-T21 |

## Appendix B — Implementation Specifications

### B1 — `.claude/hooks/validate-orchestrator-output-resolution.ps1` (new, dot-sourced by HOOK)

- Comment-based help: SYNOPSIS "Checkpoint resolution and Layer 2 decision helpers for validate-orchestrator-output.ps1 (issues #787, #840)." DESCRIPTION states: dot-sourced by the hook; resolves the run checkpoint through the exported functions of `WorktreeRunResolution.psm1` and `Get-WorktreeItemLiveRoot` only; never uses the payload `cwd`; reads no file except through `Get-WorktreeRunCheckpointText` and the `Test-OrchestratorOutputRunbookFile` seam; starts no process and invokes no Python. No `param()` block.
- Script-scope constants: `$script:OrchestratorOutputRunKind = @{ 'orchestrator-state' = 'item'; 'epic-orchestrator-state' = 'epic'; 'parallel-orchestrator-state' = 'parallel' }`; `$script:OrchestratorOutputAmbiguousReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`; `$script:OrchestratorOutputNoTargetReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'`; `$script:OrchestratorOutputMismatchReasonCode = 'CHECKPOINT_PATH_MISMATCH'`; `$script:OrchestratorOutputHaltInstruction = 'orchestrator hook: the lines above record a wave-barrier ordering violation in the epic checkpoint that this agent cannot clear. Report them to the operator and halt.'`; `$script:OrchestratorOutputUnevaluableToken = 'EPIC_WAVE_BARRIER_UNEVALUABLE:'`.
- `ConvertTo-OrchestratorOutputResolution -Resolved <bool> [-CheckpointPath] [-WorktreeRoot] -Status [-ReasonCode] -Detail` returns `[pscustomobject]` with exactly `Resolved`, `CheckpointPath`, `WorktreeRoot`, `Status`, `ReasonCode`, `Detail` (absent values `$null`).
- `Test-OrchestratorOutputCheckpointLeafShape -CheckpointPath` (pure) returns `@{ Ok; Leaf; Detail }`. Normalization: trim; `\` to `/`; collapse `/{2,}` to `/`; strip leading `./` repeatedly. Not Ok when the result is blank ("the -CheckpointPath value is empty"), matches `^([A-Za-z]:|/)` ("the -CheckpointPath value '<value>' is rooted; it must be a repository-relative path"), or has a `..` segment ("the -CheckpointPath value '<value>' escapes the worktree root").
- `Test-OrchestratorOutputCheckpointLeaf -CheckpointPath -Kind (epic|parallel|item) -WorktreeRoot` returns `@{ Ok; CanonicalPath; Detail }`: runs the shape check; `$canonical = Get-WorktreeRunCheckpointPath -Kind $Kind -WorktreeRoot $WorktreeRoot`; `$composed = (($WorktreeRoot.Trim() -replace '\\', '/').TrimEnd('/')) + '/' + $shape.Leaf`; Ok only when `$composed -ceq $canonical`; otherwise Detail "the -CheckpointPath value '<value>' composes '<composed>' beneath the resolved root, which is not the canonical <kind> checkpoint '<canonical>'".
- `Find-OrchestratorOutputRunSignalValue -Kind (epic|parallel) -SessionRoot` returns `string[]` (`return , $values.ToArray()`): field `integration_branch` or `parallel_slug`, route `epic` or `parallel`. Assign `$liveRoots = Get-WorktreeItemLiveRoot -SessionRoot $SessionRoot` before wrapping; for each non-blank root read `Get-WorktreeRunCheckpointText -Path (Get-WorktreeRunCheckpointPath -Kind $Kind -WorktreeRoot $root)`; skip blank text; parse with `ConvertFrom-Json -InputObject $text -NoEnumerate -ErrorAction Stop` inside `try`/`catch { continue }`; skip a result that is not `[System.Management.Automation.PSCustomObject]`; skip unless the property names contain `route_id` (`-ccontains`) and `[string]$parsed.route_id -ceq` the route; skip unless the field is present, is a `[string]`, and is non-blank; add the value when not already in the ordinal `List[string]`.
- `Resolve-OrchestratorOutputCheckpointPath -ArtifactType -CheckpointPath -AgentOutput -SessionRoot` (all `[AllowEmptyString()]` except `SessionRoot`, which is mandatory):
  1. Kind lookup; no kind → unresolved `NoTarget`, NoTarget code, Detail "unsupported artifact type '<type>'; supported types: orchestrator-state, epic-orchestrator-state, parallel-orchestrator-state".
  2. Shape check; not Ok → unresolved `Rejected`, mismatch code, shape Detail. No resolver call has run.
  3. `item`: `$target = Resolve-WorktreeOperandTarget -Path '' -SessionRoot $SessionRoot`.
  4. `epic`: `$signal = Find-WorktreeRunIdentitySignal -Text $AgentOutput`; `$branch = $signal.IntegrationBranch`; when blank: `$values = @(Find-OrchestratorOutputRunSignalValue -Kind epic -SessionRoot $SessionRoot)`; more than one → unresolved `Ambiguous`, ambiguity code, Detail "the epic checkpoints of live worktrees record <n> distinct integration_branch values (<values joined with ', '>), and the agent output names no integration_branch: value"; exactly one → `$branch = $values[0]`; none → `$branch = ''`. Then `$target = Resolve-WorktreeEpicTarget -IntegrationBranch $branch -EpicSlug $signal.EpicSlug -SessionRoot $SessionRoot`.
  5. `parallel`: as step 4 with `ParallelSlug`, `parallel_slug`, and `Resolve-WorktreeParallelTarget -ParallelSlug $slug -SessionRoot $SessionRoot`.
  6. `$target.Status` of `NoTarget` or `Ambiguous` → unresolved with the target's `Status`, `ReasonCode`, `Detail`.
  7. Leaf check with `$target.WorktreeRoot`; not Ok → unresolved `Rejected`, mismatch code, leaf Detail.
  8. Resolved: `CheckpointPath` = canonical path, `WorktreeRoot` = `$target.WorktreeRoot`, `Status` = `$target.Status`, `ReasonCode` = `$null`, `Detail` = `$target.Detail`.
- `Resolve-OrchestratorOutputRunbookPath -WorktreeRoot -RunbookPath` (pure): `$path = ([string]$RunbookPath).Trim() -replace '\\', '/'`; a value matching `^([A-Za-z]:/|/)` is returned unchanged; otherwise strip leading `./` repeatedly and return `(($WorktreeRoot.Trim() -replace '\\', '/').TrimEnd('/')) + '/' + $path.TrimStart('/')`.
- `Test-OrchestratorOutputRunbookFile -Path` returns `Test-Path -LiteralPath $Path -PathType Leaf` (the read seam tests mock).
- `Get-OrchestratorOutputWaveBarrierDecision -CheckpointText` returns `@{ Ok; Message }`: when `$script:OrchestratorOutputWaveBarrierImportFailure` is set → Message "EPIC_WAVE_BARRIER_UNEVALUABLE: <module> failed to import; the wave-barrier ordering check did not run."; call `@(Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $CheckpointText)` in `try`; in `catch`, a message beginning with the unevaluable token is returned unchanged, any other message as "EPIC_WAVE_BARRIER_UNEVALUABLE: the wave-barrier ordering check failed: <message>"; no errors → Ok; otherwise Message = the error lines followed by the halt instruction, joined with "`n".

### B2 — `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (new)

- Header help names issue #840, states that it ports `validate_wave_barrier_ordering` (`scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`) as reached through `validate_epic_orchestrator_state_text`, parses with `System.Text.Json` (not `ConvertFrom-Json`), reads no file, starts no process, and contains the sentence "CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop." Then `Set-StrictMode -Version Latest` immediately followed by `$ErrorActionPreference = 'Stop'`. No `Import-Module`. Exports only `Get-OrchestratorStateEpicWaveBarrierError`.
- Constants: lifecycle prefixes in order `docs/features/active/`, `docs/features/completed/`, `active/`, `completed/`; merged statuses `merged`, `worktree_removed`; `not_started`; integer-token pattern `^-?(0|[1-9][0-9]*)$`; the two violation formats of spec lines 138-139.
- Private helpers: `Get-EpicWaveBarrierProperty -Element -Name` (enumerate `EnumerateObject()`, keep the last property whose `Name -ceq $Name`; return `[pscustomobject]@{ Found; Value }`); `ConvertTo-EpicWaveBarrierFolderHint -Value` (strip the first matching prefix with ordinal `StartsWith`); `Get-EpicWaveBarrierNumberKey -Element -Role -Folder` (integer token → `'n:' + [System.Numerics.BigInteger]::Parse($raw, [System.Globalization.CultureInfo]::InvariantCulture).ToString([System.Globalization.CultureInfo]::InvariantCulture)`; other number → throw "EPIC_WAVE_BARRIER_UNEVALUABLE: feature '<folder>' has a non-integer numeric <role> token '<raw>', which this port does not compare"); `Format-EpicWaveBarrierReference -Element` (String → `GetString()`; True → `True`; False → `False`; Number → BigInteger string); `Test-EpicWaveBarrierFeatureStarted -Feature` (a String `worktree_created_at` → started; else `merge_status` not found → started; found String equal ordinal to `not_started` → not started; any other → started).
- `Get-OrchestratorStateEpicWaveBarrierError -CheckpointText` (`[AllowEmptyString()]`), returning `, [string[]]`:
  1. `JsonDocument::Parse($CheckpointText, [System.Text.Json.JsonDocumentOptions]::new())` in `try`; any exception → throw "EPIC_WAVE_BARRIER_UNEVALUABLE: the checkpoint is not parseable by System.Text.Json with default options (a non-standard literal such as NaN or Infinity, or nesting deeper than 64 levels): <message>". Dispose in `finally`.
  2. Root not Object → empty. `features` not found or not Array → empty. Entries = elements whose ValueKind is Object, in order.
  3. `byFolder` = `Dictionary[string, JsonElement]` (Ordinal) over entries with a String `feature_folder`, later entry wins.
  4. `byHint`, `byIssue` = `Dictionary[string, string]` (Ordinal) over entries with a non-empty String `feature_folder`: `byHint[hint(folder)] = folder`; an `issue_num` that is found and not Null: Array or Object → throw "EPIC_WAVE_BARRIER_UNEVALUABLE: feature '<folder>' has an issue_num that is an array or object, which the Python authority cannot index"; True/False → key `n:1`/`n:0`; Number → number key (role `issue_num`); String → not indexed. Later entry wins.
  5. For each entry: skip unless `feature_folder` is String and `depends_on` is Array; skip unless started; `$created` = the String `worktree_created_at` or `$null`.
  6. For each dependency in order: String → `byHint[hint(text)]`; True/False → `byIssue['n:1'/'n:0']`; Number → `byIssue[number key]` (role `depends_on` reference); Null, Array, Object → unresolved. Unresolved, or a resolved folder missing from `byFolder`, is skipped.
  7. Status violation unless the dependency's `merge_status` is found, String, and ordinal-equal to `merged` or `worktree_removed`. Timing violation when the dependency's `merge_confirmed_at` is String, `$created` is not null, and `[string]::CompareOrdinal($confirmed, $created) -gt 0`. Status precedes timing; at most one error per edge; `{dependency}` is `Format-EpicWaveBarrierReference` of the raw element.
- Ordinal dictionaries use `[System.Collections.Generic.Dictionary[...]]::new([System.StringComparer]::Ordinal)` (not `[hashtable]::new`, which `PSUseLiteralInitializerForHashtable` flags). Estimated size: 200-300 lines.

### B3 — HOOK changes

1. Comment help: DESCRIPTION adds that the checkpoint is resolved through `WorktreeRunResolution.psm1` by the dot-sourced sibling, that an unresolved, ambiguous, or mismatched target blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` before any read, and that for `epic-orchestrator-state` the Layer 2 ordering check runs after the routing dispatch. NOTES adds the import-guard behavior.
2. After the line-41 import, the guard block of D5: `$script:OrchestratorOutputResolverImportFailure = $null`; `$script:OrchestratorOutputWaveBarrierImportFailure = $null`; `try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-resolution.ps1') } catch { ... = 'validate-orchestrator-output-resolution.ps1' }`; `foreach` over `'WorktreeItemResolution.psm1', 'WorktreeRunResolution.psm1'` (stop after the first recorded failure) with `Import-Module (Join-Path $PSScriptRoot "../lib/worktree-resolution/$module") -Force -ErrorAction Stop`; then `try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1') -Force -ErrorAction Stop } catch { ... = 'OrchestratorStateEpicWaveBarrier.psm1' }`.
3. `Invoke-OrchestratorOutputValidation` gains `[string] $SessionRoot = (Get-Location).Path`. After the agent-output check and before any read: the import-failure block (D2 form, reason `RESOLVER_IMPORT_FAILED`, message ending "no checkpoint was read."); then `$resolution = Resolve-OrchestratorOutputCheckpointPath -ArtifactType $ArtifactType -CheckpointPath $CheckpointPath -AgentOutput ([string]$agentOutput) -SessionRoot $SessionRoot`; unresolved → `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: {0}: {1} ({2}): {3}` with ArtifactType, Status, ReasonCode, Detail.
4. Every later use of `$CheckpointPath` (read, the four messages, routing arguments) uses `$resolution.CheckpointPath`.
5. `Test-HumanInteractionShape -HumanInteraction $humanInteraction -FileExistsCheck { param($Path) Test-OrchestratorOutputRunbookFile -Path (Resolve-OrchestratorOutputRunbookPath -WorktreeRoot $resolution.WorktreeRoot -RunbookPath $Path) }` (no `GetNewClosure`; the block runs in a child scope of the caller).
6. After the routing dispatch passes: `if ($ArtifactType -eq 'epic-orchestrator-state') { $barrier = Get-OrchestratorOutputWaveBarrierDecision -CheckpointText $file.Content; if (-not $barrier.Ok) { return @{ Ok = $false; Message = $barrier.Message } } }`.
7. `Invoke-RoutingContractValidation`, its default invoker, `Test-HumanInteractionShape`, `Get-CheckpointFileContent`, the dot-source guard, and the entry point are unchanged. Expected size about 460 lines.

## Appendix C — Test Specifications

All rows follow Arrange-Act-Assert and carry their row ID as the start of the `It` name. No row creates a file, uses a temporary path, uses `TestDrive:`, starts a process, or reads a clock. Synthetic roots use `/synthetic-worktrees/<name>`. A file whose stub or helper declares an unused parameter carries the file-level `SuppressMessageAttribute('PSReviewUnusedParameter', ...)` used at `validate-orchestrator-output.Tests.ps1:7`; a helper that registers mocks with a `Set-` verb carries the `PSUseShouldProcessForStateChangingFunctions` suppression used at `enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1:48`.

### C0 — Default mock (DM-LINE, one line)

```powershell
Mock Resolve-OrchestratorOutputCheckpointPath { [pscustomobject]@{ Resolved = $true; CheckpointPath = '/synthetic-worktrees/default-session/artifacts/orchestration/orchestrator-state.json'; WorktreeRoot = '/synthetic-worktrees/default-session'; Status = 'SessionRoot'; ReasonCode = $null; Detail = 'default resolved target (issue #787)' } }
```

### C1 — S1 `validate-orchestrator-output.WorktreeResolution.Tests.ps1` (14 rows)

BeforeAll: dot-source HOOK; import `WorktreeTargetResolution.psm1` and `WorktreeResolution.psm1`; import `OrchestratorStateCompletion.psm1 -Force` then `OrchestratorState.psm1 -Force` last (the order at `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1:53-70`); dot-source `WorktreeResolutionFixture.Helpers.ps1`; `$script:Session = (Get-Location).Path.Replace([string][char]92, '/')`; helper `Set-OutputRunTopology -Live -BranchRoot -Epic -Parallel` registering `Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText` mocks both with `-ModuleName WorktreeRunResolution` and without it (the sibling calls them from script scope), serving texts at `<root>/artifacts/orchestration/epic-orchestrator-state.json` and `.../parallel-orchestrator-state.json`; helper `Set-OutputCheckpointRead -Map` mocking `Get-CheckpointFileContent` by `$Path`. Checkpoint texts carry `objective`, `completed_steps`, `next_step`, `last_updated`, the kind's `route_id`, and `integration_branch` or `parallel_slug`. BeforeEach mocks `Get-OrchestratorStateCheckpoint` (returns `@{ Ok = $true; State = [pscustomobject]@{}; Error = '' }`), `Test-OrchestratorStateCompletionReadiness` (returns `@{ ExitCode = 0; Output = '' }`), and `Get-OrchestratorStateEpicWaveBarrierError` (returns an empty array). Rows call `Invoke-OrchestratorOutputValidation -RawPayload ... -SessionRoot $script:Session` with the default routing invoker.

- R1 (replaces the T-MAIN epic-arguments row): epic arguments; output names `integration_branch: epic/c6-integration`; live roots session and `w-epic`, only `w-epic` records the branch. Assert Ok; `Get-CheckpointFileContent` once with `/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json`; `Get-OrchestratorStateCheckpoint` once with that `CheckpointPath`; the port once with `CheckpointText` equal to the `w-epic` text.
- R2: session root and `w-epic` both record the branch; `-BranchRoot` is `w-epic`. Assert the read is at `w-epic` and 0 reads at the session path.
- R3: `w-a` records `epic/a`, `w-b` records `epic/b`; output names `epic/b`. Assert the read is at `w-b`.
- R4: no signal; only `w-epic` holds an epic checkpoint. Assert the read is at `w-epic`.
- R5: no signal; `w-a` and `w-b` record distinct branches; the row passes a `-RoutingInvoker` stub that sets `$script:RoutingReached = $true`. Assert not Ok; message starts `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: Ambiguous (` followed by `Get-WorktreeResolutionAmbiguityReasonCode`; `Get-CheckpointFileContent` 0 times; `$script:RoutingReached` stays `$false`; port 0 times.
- R6: no signal; no live epic checkpoint. Same assertions as R5 with `NoTarget (` and `Get-WorktreeResolutionNoTargetReasonCode`.
- R7: the session root holds an epic checkpoint recording `epic/old`; output names `epic/new`. Same assertions as R5 with `NoTarget` (the stale session copy is never read).
- R8: parallel arguments; no signal; no live parallel checkpoint. Same assertions as R5 with `NoTarget`.
- R9: parallel; no signal; only `w-par` records `parallel_slug: demo`. Assert Ok; read and `Get-OrchestratorStateCheckpoint` at `/synthetic-worktrees/w-par/artifacts/orchestration/parallel-orchestrator-state.json`; port 0 times.
- R10: parallel; no signal; `w-p1` and `w-p2` record distinct slugs. Same assertions as R5 with `Ambiguous`.
- R11: parallel; the same two worktrees; output names `parallel_slug: beta`. Assert the read is at the worktree recording `beta`.
- R12 (replaces the T-MAIN default-arguments row): no `-CheckpointPath`/`-ArtifactType`; `Resolve-WorktreeOperandTarget` mocked (script scope) to `New-WorktreeResolutionFixtureTarget -Status SessionRoot -WorktreeRoot '/synthetic-worktrees/w-item'`. Assert Ok; read once and `Test-OrchestratorStateCompletionReadiness` once with `/synthetic-worktrees/w-item/artifacts/orchestration/orchestrator-state.json`; port 0 times.
- R13: as R1 with `human_interaction.requirements[0]` = `{ "response": "exception", "runbook_path": "docs/runbooks/epic-halt.md" }`; `Test-OrchestratorOutputRunbookFile` mocked to `$true`. Assert Ok and the seam invoked once with `/synthetic-worktrees/w-epic/docs/runbooks/epic-halt.md`.
- R14: epic type with `-CheckpointPath artifacts/orchestration/orchestrator-state.json` and the R1 topology. Assert message starts `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: Rejected (CHECKPOINT_PATH_MISMATCH):`; 0 reads.

### C2 — S2 `validate-orchestrator-output-resolution.Tests.ps1` (12 rows)

BeforeAll as C1 (same imports and helpers).

- S2-1: `Test-OrchestratorOutputCheckpointLeaf -CheckpointPath 'artifacts/orchestration/epic-orchestrator-state.json' -Kind epic -WorktreeRoot '/synthetic-worktrees/w-reg'` is Ok with `CanonicalPath` `/synthetic-worktrees/w-reg/artifacts/orchestration/epic-orchestrator-state.json`.
- S2-2: the spelling `.\artifacts\orchestration\epic-orchestrator-state.json` is Ok with the same canonical path.
- S2-3: the item leaf for kind `epic` is not Ok and its Detail contains the canonical epic path.
- S2-4: HOOK with epic type and `-CheckpointPath '/abs/artifacts/orchestration/epic-orchestrator-state.json'` blocks with `Rejected (CHECKPOINT_PATH_MISMATCH)`; `Get-WorktreeItemLiveRoot` (both scopes) and `Get-CheckpointFileContent` invoked 0 times.
- S2-5: as S2-4 with `artifacts/../artifacts/orchestration/epic-orchestrator-state.json`; same assertions.
- S2-6: read `.claude/settings.json` and `.claude/agents/orchestrator.md`, `epic-orchestrator.md`, `parallel-orchestrator.md` as text (read-only); collect every match of `validate-orchestrator-output\.ps1(?<args>[^"\r\n]*)`; for each derive `-CheckpointPath` (default `artifacts/orchestration/orchestrator-state.json`) and `-ArtifactType` (default `orchestrator-state`). Assert 6 matches and every pair is Ok under `Test-OrchestratorOutputCheckpointLeaf` with the type's kind and root `/synthetic-worktrees/w-reg`.
- S2-7: `Resolve-OrchestratorOutputCheckpointPath -ArtifactType 'not-a-type' ...` returns `Resolved = $false`, `Status = 'NoTarget'`, `ReasonCode` equal to `Get-WorktreeResolutionNoTargetReasonCode`, and a Detail containing `unsupported artifact type 'not-a-type'`.
- S2-8: `Resolve-OrchestratorOutputRunbookPath -WorktreeRoot '/synthetic-worktrees/w-epic' -RunbookPath './docs/runbooks/x.md'` returns `/synthetic-worktrees/w-epic/docs/runbooks/x.md`.
- S2-9: a rooted runbook path `/srv/runbooks/x.md` is returned unchanged.
- S2-10: `Find-OrchestratorOutputRunSignalValue -Kind epic` over five mocked roots (route `Epic`; unparseable text; a JSON array; a blank branch; branches `epic/a` and `epic/A` with route `epic`) returns exactly `epic/a`, `epic/A` in that order.
- S2-11: `Test-OrchestratorOutputRunbookFile` returns `$false` for `Join-Path $PSScriptRoot 'no-such-runbook-for-787.md'` and `$true` for `$PSCommandPath`.
- S2-12 (last row): mock `Import-Module` as a no-op and to throw for `$Name -like '*WorktreeRunResolution.psm1'`; re-dot-source HOOK; then register the `Get-CheckpointFileContent` mock. Assert the message contains `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`, `RESOLVER_IMPORT_FAILED`, and `WorktreeRunResolution.psm1`, and 0 reads. Reset `$script:OrchestratorOutputResolverImportFailure = $null` in `finally`.

### C3 — S3 `validate-orchestrator-output.WaveBarrier.Tests.ps1` (12 rows)

The top-level BeforeAll dot-sources HOOK and defines a routing stub returning ExitCode 0. A BeforeAll inside the outermost `Describe` mocks `Resolve-OrchestratorOutputCheckpointPath` to a resolved target at `/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json`. Rows mock `Get-CheckpointFileContent` with the text named; folder names and strings as Appendix D.

- H1: one unmerged dependency; real port. Message split on "`n" has 2 lines: line 1 is exactly `EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged`; line 2 equals the halt instruction.
- H2: two violated edges (Appendix D case 28 features). 3 lines in that order, each violation line beginning with the token.
- H3: the last line of the H1 message matches `operator` and `halt` and does not match `(?i)\b(edit|rewrite|modify|change|update|delete|remove|reset)\b|timestamp|merge_status|history`.
- H4: clean epic checkpoint (merged dependency confirmed before start); real port. Ok.
- H5: parallel type; port mocked to throw. Ok; port 0 times.
- H6: orchestrator-state type; port mocked to throw. Ok; port 0 times.
- H7: epic type; routing stub returns ExitCode 1 with Output `x`. Message starts `ROUTING_CONTRACT_BLOCKED:`; port 0 times.
- H8: `issue_num` `[901]`; real port. Message starts `EPIC_WAVE_BARRIER_UNEVALUABLE:` and contains no `EPIC_WAVE_BARRIER_VIOLATION`.
- H9: a feature carrying `"merge_confirmed_at": NaN`; real port. Message starts `EPIC_WAVE_BARRIER_UNEVALUABLE:`.
- H10: a feature carrying a value nested in 70 arrays; real port. Message starts `EPIC_WAVE_BARRIER_UNEVALUABLE:`.
- H11: port mocked to throw `simulated port failure (issue #840)`. Message starts `EPIC_WAVE_BARRIER_UNEVALUABLE:` and contains `simulated port failure`.
- H12 (last row): mock `Import-Module` as a no-op and to throw for `$Name -like '*OrchestratorStateEpicWaveBarrier.psm1'`; re-dot-source HOOK; register the resolution and read mocks. Epic message starts `EPIC_WAVE_BARRIER_UNEVALUABLE:` and contains `OrchestratorStateEpicWaveBarrier.psm1`. Reset `$script:OrchestratorOutputWaveBarrierImportFailure = $null` in `finally`.

### C4 — S4 `OrchestratorStateEpicWaveBarrier.Tests.ps1` (20 test cases)

BeforeAll imports PORT `-Force`. A helper composes checkpoint text from feature JSON strings. Expected strings use the Appendix D folder names.

- U1: root `[]` → empty. U2: `{}` (no `features`) → empty.
- U3 (`-ForEach`, 7 cases, name `U3 start guard <Name>`), dependency `2026-10-08-alpha-901` with `pr_open`, dependent `2026-10-08-bravo-902` depending on it: `not_started` without `worktree_created_at` → no error; `not_started` with `null` → no error; `not_started` with `""` → status error; `merge_status` absent → status error; `null` → status error; `5` → status error; `Not_Started` → status error.
- U4: dependency `merge_status` `["merged"]` → status error. U5: `{"value": "merged"}` → status error.
- U6 (`-ForEach`, 2 cases, name `U6 duplicate key <Name>`): dependency object text `"merge_status": "pr_open", "merge_status": "merged"` → no error; reversed order → status error.
- U7: dependency hint `active/completed/2026-10-08-alpha-901` with the dependency unmerged → no error.
- U8: `false` reference with a feature whose `issue_num` is `0` and unmerged → error rendering `False`.
- U9: text `{ broken` throws a message starting `EPIC_WAVE_BARRIER_UNEVALUABLE:`. U10: empty text throws the same token.
- U11: `issue_num` `901.5` throws the token and the message contains `901.5`. U12: `issue_num` `{"n": 1}` throws the token and contains `array or object`.
- U13: a dependency token `901.0` on a dependent with `merge_status` `not_started` and no `worktree_created_at` → no error and no throw.

### C5 — S5 `OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1` (7 test cases)

Comment help lists the declared divergence classes: D1 non-integer numeric reference tokens; D2 astral-plane string ordering; D3 unhashable `issue_num`; D4 non-standard JSON literals; D5 nesting depth beyond the System.Text.Json default. BeforeDiscovery enumerates `tests/fixtures/epic_wave_barrier/*.json` sorted by name (read-only).

- P-file rows (`-ForEach` the files, name `P <FileName> runs every case`): parse with `JsonDocument`; for each case build `JsonNode.Parse(envelope raw text)`, set `features` to `JsonNode.Parse(case features raw text)`, pass `ToJsonString()` to the port, compare to `expected_barrier_errors`. Assert the `cases` array is non-empty, the executed count equals its length, and the mismatch list is empty. With `layer2-parity-edge-cases.json` and `start-guard-matrix.json` present this is 2 cases.
- D1: `depends_on` `[901.0]` on a started dependent with an unmerged `issue_num` 901 → throws the unevaluable token (the Python authority reports a status error rendering `901.0`).
- D2: dependency merged with `merge_confirmed_at` `"Ａ"`; dependent `worktree_created_at` `"😀"` → returns exactly the timing violation (the Python authority returns none).
- D3: `issue_num` `[901]` → throws the token (the Python authority raises `TypeError`).
- D4: a `NaN` literal → throws the token. D5: 70 nested arrays → throws the token.

### C6 — PYLANE `test_epic_wave_barrier_parity_corpus.py` (2 tests plus 28 parametrized nodes)

Module docstring states purpose, the PowerShell sibling lane, and that no temporary file or process is used. Constants `REPO_ROOT = Path(__file__).resolve().parents[3]`, `CORPUS_PATH` = CORPUS, `BARRIER_PREFIX = "EPIC_WAVE_BARRIER_VIOLATION: "`; `_load_corpus() -> dict[str, Any]` (raises `TypeError` for a non-object root); `_barrier_errors_for(features: object) -> list[str]` (document `{**ENVELOPE, "features": features}` through `validate_epic_orchestrator_state_text(json.dumps(document))`, filtered by the prefix). Tests: `test_corpus_is_non_empty_with_unique_case_names`; `test_corpus_executes_every_case` (loops all cases, counts executions, asserts the count equals `len(CASES)` and the mismatch list is empty); `test_corpus_case` parametrized over `CASES` with `ids` the case names. Fully typed; no `print`.

## Appendix D — Corpus `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json` (verbatim)

```json
{
  "schema_version": 1,
  "envelope": {
    "objective": "pin the epic wave-barrier Layer 2 parity edge cases",
    "route_id": "epic",
    "epic_feature_folder": "2026-10-08-layer2-parity-epic-852",
    "integration_branch": "epic/layer2-parity-852-integration",
    "max_parallel_features": 4,
    "completed_steps": [],
    "next_step": "wave_1_launch",
    "last_updated": "2026-10-08T00-00",
    "waves": []
  },
  "cases": [
    {
      "name": "issue-num-reference-confirmed-before-start",
      "acceptance_criteria": ["AC-14"],
      "notes": "An integer issue_num reference resolves through the union index; a confirmation earlier than the start is not a violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T09-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [901], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "issue-num-reference-confirmed-after-start",
      "acceptance_criteria": ["AC-14"],
      "notes": "A confirmation later than the start is a timing violation that renders the raw integer reference.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T11-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [901], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 worktree_created_at precedes dependency 901 merge_confirmed_at"
      ]
    },
    {
      "name": "active-prefixed-hint-unmerged",
      "acceptance_criteria": ["AC-14"],
      "notes": "A docs/features/active/ hint resolves after prefix normalization and renders the raw hint text.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["docs/features/active/2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency docs/features/active/2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "completed-prefixed-hint-unmerged",
      "acceptance_criteria": ["AC-14"],
      "notes": "A completed/ hint resolves after prefix normalization and renders the raw hint text.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["completed/2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency completed/2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "unresolved-and-non-string-references-skipped",
      "acceptance_criteria": ["AC-14"],
      "notes": "Unresolved strings and integers, a string against an integer issue_num, null, list, and object references are skipped.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-missing-999", 999, "901", null, [901], {"issue_num": 901}], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "bool-reference-without-issue-num-one",
      "acceptance_criteria": ["AC-14"],
      "notes": "A true reference resolves only to an issue_num equal to 1; with none it is skipped.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [true], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "bool-reference-matches-issue-num-one",
      "acceptance_criteria": ["AC-14"],
      "notes": "A true reference matches issue_num 1 and renders as True.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-001", "issue_num": 1, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [true], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency True is not merged"
      ]
    },
    {
      "name": "integer-reference-matches-bool-issue-num",
      "acceptance_criteria": ["AC-14"],
      "notes": "An integer reference 1 matches an issue_num of true and renders as 1.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-001", "issue_num": true, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [1], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 1 is not merged"
      ]
    },
    {
      "name": "integer-reference-against-string-issue-num",
      "acceptance_criteria": ["AC-14"],
      "notes": "An integer reference never matches a string issue_num.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": "901", "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [901], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "skipped-malformed-entries",
      "acceptance_criteria": ["AC-14"],
      "notes": "Non-object entries, a string depends_on, a non-string dependent folder, and an absent depends_on produce no error.",
      "features": [
        "not-an-object",
        42,
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": "2026-10-08-alpha-901", "merge_status": "worktree_created"},
        {"feature_folder": 7, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created"},
        {"feature_folder": "2026-10-08-charlie-903", "issue_num": 903, "merge_status": "worktree_created"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "features-is-an-object",
      "acceptance_criteria": ["AC-14"],
      "notes": "A features value that is an object rather than a list yields no features.",
      "features": {"feature_folder": "2026-10-08-alpha-901", "depends_on": [], "merge_status": "pr_open"},
      "expected_barrier_errors": []
    },
    {
      "name": "dependency-merge-status-integer",
      "acceptance_criteria": ["AC-14"],
      "notes": "A non-string dependency merge_status is a status violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": 5},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "dependency-merge-status-case-variant",
      "acceptance_criteria": ["AC-14"],
      "notes": "The merged-status comparison is case-sensitive.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "Merged"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "dependency-merge-status-key-case-variant",
      "acceptance_criteria": ["AC-14"],
      "notes": "A Merge_Status key is not merge_status, so the status is absent and the edge is a status violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "Merge_Status": "merged"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "equal-timestamps-no-violation",
      "acceptance_criteria": ["AC-14"],
      "notes": "Equal confirmation and start strings are not a timing violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T10-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "lowercase-t-confirmation-orders-after-uppercase",
      "acceptance_criteria": ["AC-14"],
      "notes": "Ordinal comparison places a lowercase t after an uppercase T.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08t09-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 worktree_created_at precedes dependency 2026-10-08-alpha-901 merge_confirmed_at"
      ]
    },
    {
      "name": "offset-timestamps-compare-as-strings",
      "acceptance_criteria": ["AC-14"],
      "notes": "Timestamps compare as strings, so a chronologically later offset time that sorts earlier is not a violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T09:00:00-05:00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10:00:00Z"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "utc-timestamps-confirmation-later",
      "acceptance_criteria": ["AC-14"],
      "notes": "ISO-8601 Z timestamps stay strings; a later confirmation is a timing violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T11:00:00Z"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10:00:00Z"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 worktree_created_at precedes dependency 2026-10-08-alpha-901 merge_confirmed_at"
      ]
    },
    {
      "name": "non-string-confirmations-skip-timing",
      "acceptance_criteria": ["AC-14"],
      "notes": "A numeric or null merge_confirmed_at never produces a timing violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": 20261008},
        {"feature_folder": "2026-10-08-charlie-903", "issue_num": 903, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": null},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901", "2026-10-08-charlie-903"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "empty-string-start-guard-timing",
      "acceptance_criteria": ["AC-14"],
      "notes": "An empty worktree_created_at marks a not_started feature as started, and any confirmation string sorts after it.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T09-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "not_started", "worktree_created_at": ""}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 worktree_created_at precedes dependency 2026-10-08-alpha-901 merge_confirmed_at"
      ]
    },
    {
      "name": "self-dependency-of-started-feature",
      "acceptance_criteria": ["AC-14"],
      "notes": "A started feature that depends on itself reports a status violation naming itself.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-alpha-901 is treated as started while dependency 2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "duplicate-folder-later-record-merged",
      "acceptance_criteria": ["AC-14"],
      "notes": "A later record with the same feature_folder replaces the earlier one.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T09-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "empty-dependent-folder",
      "acceptance_criteria": ["AC-14"],
      "notes": "An empty dependent feature_folder is iterated and renders as an empty name.",
      "features": [
        {"feature_folder": "", "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created"},
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION:  is treated as started while dependency 2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "empty-string-dependency-never-resolves",
      "acceptance_criteria": ["AC-14"],
      "notes": "An empty dependency string never resolves, even when a feature has an empty folder.",
      "features": [
        {"feature_folder": "", "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [""], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": []
    },
    {
      "name": "negative-zero-integer-reference",
      "acceptance_criteria": ["AC-14"],
      "notes": "A -0 reference matches issue_num 0 and renders as 0.",
      "features": [
        {"feature_folder": "2026-10-08-zulu-900", "issue_num": 0, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [-0], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 0 is not merged"
      ]
    },
    {
      "name": "integer-reference-beyond-int64",
      "acceptance_criteria": ["AC-14"],
      "notes": "An integer beyond the 64-bit range matches and renders exactly.",
      "features": [
        {"feature_folder": "2026-10-08-big-904", "issue_num": 123456789012345678901234567890, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [123456789012345678901234567890], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 123456789012345678901234567890 is not merged"
      ]
    },
    {
      "name": "status-violation-takes-precedence-over-timing",
      "acceptance_criteria": ["AC-14"],
      "notes": "An unmerged dependency with a later confirmation reports only the status violation.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open", "merge_confirmed_at": "2026-10-08T11-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged"
      ]
    },
    {
      "name": "multiple-edges-reported-in-depends-on-order",
      "acceptance_criteria": ["AC-14"],
      "notes": "Violations are reported in depends_on order, one per edge.",
      "features": [
        {"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"},
        {"feature_folder": "2026-10-08-charlie-903", "issue_num": 903, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T11-00"},
        {"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-charlie-903", "2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}
      ],
      "expected_barrier_errors": [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 worktree_created_at precedes dependency 2026-10-08-charlie-903 merge_confirmed_at",
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged"
      ]
    }
  ]
}
```

Case-to-category map (AC-14): issue_num references 1, 2, 7, 8, 9, 25, 26; folder-hint prefixes 3, 4; unresolved and non-string references 5, 6; skipped malformed entries 10, 11; case-variant status values and keys 13, 14 (plus 12); timestamp ordering traps 15-19; empty-string start guard 20; self-dependency 21; duplicate folders 22; empty dependent folder 23, 24; precedence and ordering 27, 28. No case uses an array or object `merge_status`, `feature_folder`, or `issue_num`, because the Python authority raises on those (`validate_epic_orchestrator_state.py:218-243` and the waves index).

## Appendix E — Document Texts

### E1 — SKILL Layer 2 bullet (replaces the whole bullet)

- **Layer 2 — retrospective backstop:** the wave-barrier ordering invariant of `validate_epic_orchestrator_state_text`, enforced at `epic-orchestrator` `SubagentStop` time by a PowerShell port, `Get-OrchestratorStateEpicWaveBarrierError` in `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, which the parameterized `validate-orchestrator-output.ps1` hook invokes for `epic-orchestrator-state` after resolving the epic checkpoint through `WorktreeRunResolution.psm1`. The hook starts no Python process. Parity with `validate_epic_orchestrator_state_text` is pinned by the shared fixtures under `tests/fixtures/epic_wave_barrier/`, and the Python validator remains the authority used through the `mcp__drm-copilot__validate_orchestration_artifacts` call. It checks only a dependent feature that is treated as started: one with a string `worktree_created_at`, or with a `merge_status` other than `not_started` (a missing or non-string `merge_status` counts as started). It appends exactly one error per violated dependency edge. When the dependency's `merge_status` is not `merged` or `worktree_removed`, the error is `EPIC_WAVE_BARRIER_VIOLATION: <f> is treated as started while dependency <d> is not merged`. Otherwise, when the dependency's `merge_confirmed_at` is later than the dependent's `worktree_created_at`, the error is `EPIC_WAVE_BARRIER_VIOLATION: <f> worktree_created_at precedes dependency <d> merge_confirmed_at`. A violation blocks with an instruction to report it to the operator and halt. The hook's runtime effect is likely to depend on the `SubagentStop` transport and exit-code defect recorded in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.

### E2 — AGENT sentence (replaces "Do not launch wave N+1 ..." through the end of the paragraph)

Do not launch wave N+1 until every wave-N feature's dependency edges are durably confirmed `merged` or `worktree_removed`. This durable confirmation is enforced both by the `enforce-epic-wave-barrier.ps1` per-call deterrent and by the retrospective wave-barrier ordering check, which runs at your own `SubagentStop` time as `Get-OrchestratorStateEpicWaveBarrierError` in `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, a PowerShell port of the check inside `validate_epic_orchestrator_state_text` invoked by `.claude/hooks/validate-orchestrator-output.ps1`; parity is pinned by `tests/fixtures/epic_wave_barrier/`, and the Python validator remains the authority used through the `mcp__drm-copilot__validate_orchestration_artifacts` call. If the check reports a violation, report it to the operator and halt. Its runtime effect is likely to depend on the `SubagentStop` transport and exit-code defect recorded in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.

### E3 — WAVE comment-help paragraph (replaces the paragraph located by P0-T13)

```text
This is the per-call deterrent (Layer 1) of the two-layer wave-barrier design. The
retrospective backstop (Layer 2) is the wave-barrier ordering invariant of
validate_epic_orchestrator_state_text, run at epic-orchestrator SubagentStop time by
validate-orchestrator-output.ps1 through its PowerShell port
OrchestratorStateEpicWaveBarrier.psm1, with parity pinned by tests/fixtures/epic_wave_barrier/.
That hook's runtime effect is likely to depend on the SubagentStop transport defect recorded in
docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md.
The two layers share no code.
```

If C2 rewrote the located paragraph to describe Layer 1 in additional sentences, those Layer 1 sentences are kept verbatim ahead of the replacement text, and only the sentences that describe Layer 2 are replaced; the artifact of P5-T6 quotes the result.

### E4 — PIN provenance paragraph (appended to the comment block above `PINNED_FROZEN_SURFACE_HASHES`)

```text
#
# RE-BASELINED by issue #787 (bundling #840). That change corrected the Layer 2
# text in the epic skill's `## Wave Barrier (Two-Layer Design)` bullet and the
# agent's `## Wave Scheduling` paragraph to describe the PowerShell port invoked
# at epic-orchestrator SubagentStop. Both digests moved, and the pin stays live
# for both entries.
```

## Appendix F — File Groups and Mirror Pairs

- LC-BASE (10): HOOK, T-MAIN, T-DISPATCH, T-ROUTING, T-HUMAN, WAVE, WRR, MANIFEST, PIN, CORE.
- MP-EXIST (4 pairs): HOOK / `CB/.claude/hooks/validate-orchestrator-output.ps1`; WAVE / `CB/.claude/hooks/enforce-epic-wave-barrier.ps1`; SKILL / `CB/.claude/skills/epic-orchestrate/SKILL.md`; AGENT / `CB/.claude/agents/epic-orchestrator.md`.
- MP-CODE (3 pairs): HOOK, SIB, PORT with their CB paths.
- MP-DOC (3 pairs): WAVE, SKILL, AGENT with their CB paths.
- PS-ALL (13): HOOK, SIB, PORT, WAVE, T-MAIN, T-DISPATCH, T-ROUTING, S1, S2, S3, S4, S5, MANIFEST.
- LC-ALL (17): PS-ALL plus CORPUS, PYLANE, PIN, CORE.

## Appendix G — Suite Sets

- SET-HOOK-BASE: T-MAIN, T-DISPATCH, T-ROUTING, T-HUMAN (comma-joined repository-relative paths).
- SET-HOOK: SET-HOOK-BASE plus S1, S2, S3.
- SET-LIB: the directory `tests/scripts/claude-lib/orchestrator-state` (includes MANIFEST, and S4 and S5 once written).
- SET-WRR: the directory `tests/scripts/claude-lib/worktree-resolution`.
- SET-GUARD: `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1`.
- PY-TARGET-BASE: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py`, `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`, `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`, `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`.
- PY-TARGET: PY-TARGET-BASE plus PYLANE.

## Appendix H — Scratch Scripts

Written verbatim under SCRATCH by P0-T7 and never committed. A1-A7, A11, A13, and A15 are carried unchanged from `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md` Appendix H, whose outputs are recorded in that feature's evidence.

A1 run-ps.sh:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-counts.ps1:

```powershell
param([Parameter(Mandatory)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Path
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
```

A3 pester-coverage.ps1:

```powershell
param(
    [Parameter(Mandatory)][string[]] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath,
    [string] $ReportPath = ''
)
$TestPath = @($TestPath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
$result = Invoke-Pester -Configuration $configuration
$report = [System.Collections.Generic.List[string]]::new()
$report.Add("TotalCount=$($result.TotalCount)")
$report.Add("PassedCount=$($result.PassedCount)")
$report.Add("FailedCount=$($result.FailedCount)")
foreach ($failedTest in $result.Failed) { $report.Add("FAILED: $($failedTest.ExpandedPath)") }
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique | Where-Object { $hitLines -notcontains $_ })
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    $report.Add("COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent")
    $report.Add("HIT file=$file Lines=$($hitLines -join ',')")
    $report.Add("MISSED file=$file Lines=$($missLines -join ',')")
}
$report | Write-Output
if ($ReportPath) { $report | Set-Content -LiteralPath $ReportPath -Encoding UTF8 }
```

A4 line-counts.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$((Get-Content -LiteralPath $file).Count)" }
```

A5 file-hashes.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
```

A6 ps-format-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
```

A7 pssa-count.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
```

A8 checkpoint-probe.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $CheckpointPath)
$ErrorActionPreference = 'Stop'
$checkpoint = Get-Content -Raw -LiteralPath $CheckpointPath | ConvertFrom-Json
Write-Output "ROUTE_ID=$($checkpoint.route_id)"
Write-Output "LIFECYCLE_READY=$($checkpoint.lifecycle_ready)"
Write-Output "ISSUE_NUM=$($checkpoint.'issue-num')"
Write-Output "FEATURE_FOLDER=$($checkpoint.'feature-folder')"
```

A9 locate-text.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)][string] $Literal)
$ErrorActionPreference = 'Stop'
$lines = @(Get-Content -LiteralPath $Path)
$helpEnd = 0
for ($index = 0; $index -lt $lines.Count; $index++) { if ($lines[$index].Trim() -eq '#>') { $helpEnd = $index + 1; break } }
Write-Output "HELP_END_LINE=$helpEnd"
$count = 0
for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index].Contains($Literal)) { $count++; Write-Output "MATCH line=$($index + 1) text=$($lines[$index].Trim())" }
}
Write-Output "MATCH-SUMMARY count=$count"
```

A10 module-exports.ps1 (read-only):

```powershell
$ErrorActionPreference = 'Stop'
$root = Join-Path (Get-Location).Path '.claude/lib/worktree-resolution'
$run = Import-Module (Join-Path $root 'WorktreeRunResolution.psm1') -Force -PassThru
$item = Import-Module (Join-Path $root 'WorktreeItemResolution.psm1') -Force -PassThru
Write-Output "WRR_EXPORTS=$((@($run.ExportedFunctions.Keys) | Sort-Object) -join ',')"
Write-Output "WIR_EXPORTS=$((@($item.ExportedFunctions.Keys) | Sort-Object) -join ',')"
$required = @('Find-WorktreeRunIdentitySignal', 'Get-WorktreeRunCheckpointText', 'Get-WorktreeRunCheckpointPath', 'Resolve-WorktreeEpicTarget', 'Resolve-WorktreeParallelTarget', 'Resolve-WorktreeOperandTarget')
$missing = @($required | Where-Object { -not $run.ExportedFunctions.ContainsKey($_) })
if (-not $item.ExportedFunctions.ContainsKey('Get-WorktreeItemLiveRoot')) { $missing += 'Get-WorktreeItemLiveRoot' }
Write-Output "MISSING_CONSUMED=$($missing.Count) $($missing -join ',')"
```

A11 changed-line-coverage.ps1 (reads an A3 report file; lines absent at the base ref count as changed):

```powershell
param(
    [Parameter(Mandatory)][string] $CoverageReportPath,
    [Parameter(Mandatory)][string] $BaseRef,
    [Parameter(Mandatory)][string[]] $File
)
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$report = Get-Content -LiteralPath $CoverageReportPath
foreach ($target in $File) {
    $hitLine = $report | Where-Object { $_ -like "HIT file=$target Lines=*" } | Select-Object -First 1
    $missLine = $report | Where-Object { $_ -like "MISSED file=$target Lines=*" } | Select-Object -First 1
    if (-not $hitLine -or -not $missLine) { Write-Output "CHANGED-COVERAGE file=$target MISSING"; continue }
    $hit = @(($hitLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $miss = @(($missLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $changed = [System.Collections.Generic.HashSet[int]]::new()
    $null = git cat-file -e "${BaseRef}:$target" 2>$null
    if ($LASTEXITCODE -eq 0) {
        foreach ($diffLine in @(git diff -U0 $BaseRef -- $target)) {
            if ($diffLine -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@') {
                $start = [int]$Matches[1]
                $count = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
                for ($offset = 0; $offset -lt $count; $offset++) { [void]$changed.Add($start + $offset) }
            }
        }
    } else {
        $lineCount = (Get-Content -LiteralPath $target).Count
        for ($lineNumber = 1; $lineNumber -le $lineCount; $lineNumber++) { [void]$changed.Add($lineNumber) }
    }
    $changedHit = @($hit | Where-Object { $changed.Contains($_) }).Count
    $changedMiss = @($miss | Where-Object { $changed.Contains($_) }).Count
    $analyzed = $changedHit + $changedMiss
    $percent = if ($analyzed -eq 0) { 'NA' } else { [math]::Round(100 * $changedHit / $analyzed, 2) }
    Write-Output "CHANGED-COVERAGE file=$target ChangedLines=$($changed.Count) ChangedAnalyzed=$analyzed ChangedCovered=$changedHit ChangedPercent=$percent"
}
```

A12 json-parse.ps1 (System.Text.Json, read-only):

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path).Path)
$document = [System.Text.Json.JsonDocument]::Parse($text, [System.Text.Json.JsonDocumentOptions]::new())
$cases = 'NA'
$property = [System.Text.Json.JsonElement]::new()
if ($document.RootElement.ValueKind -eq [System.Text.Json.JsonValueKind]::Object -and $document.RootElement.TryGetProperty('cases', [ref] $property)) { $cases = $property.GetArrayLength() }
$document.Dispose()
Write-Output "JSON-OK file=$Path cases=$cases"
```

A13 pair-hashes.ps1 (arguments: primary, mirror, primary, mirror, ...):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
if ($Path.Count % 2 -ne 0) { throw 'pair-hashes requires an even number of paths.' }
$unequal = 0
for ($index = 0; $index -lt $Path.Count; $index += 2) {
    $primary = $Path[$index]
    $mirror = $Path[$index + 1]
    $primaryHash = (Get-FileHash -LiteralPath $primary -Algorithm SHA256).Hash
    $mirrorHash = if (Test-Path -LiteralPath $mirror) { (Get-FileHash -LiteralPath $mirror -Algorithm SHA256).Hash } else { 'MISSING' }
    $equal = $primaryHash -eq $mirrorHash
    if (-not $equal) { $unequal++ }
    Write-Output "PAIR equal=$equal primary=$primary mirror=$mirror"
}
Write-Output "PAIR-SUMMARY pairs=$($Path.Count / 2) unequal=$unequal"
```

A14 noncomment-compare.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)][string] $BaseRef)
$ErrorActionPreference = 'Stop'
function Get-NonCommentTokenText([string] $Source) {
    $tokens = $null
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
    $skip = @([System.Management.Automation.Language.TokenKind]::Comment, [System.Management.Automation.Language.TokenKind]::NewLine)
    return @($tokens | Where-Object { $skip -notcontains $_.Kind } | ForEach-Object { $_.Text })
}
$current = Get-NonCommentTokenText -Source (Get-Content -Raw -LiteralPath $Path)
$base = Get-NonCommentTokenText -Source ((@(git show "${BaseRef}:$Path")) -join "`n")
$differences = @(for ($index = 0; $index -lt [math]::Min($current.Count, $base.Count); $index++) { if ($current[$index] -cne $base[$index]) { $index } })
Write-Output "NONCOMMENT-TOKENS current=$($current.Count) base=$($base.Count)"
Write-Output "NONCOMMENT-EQUAL=$(($current.Count -eq $base.Count) -and ($differences.Count -eq 0))"
```

A15 stage-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$tokens = $null
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $Path).Path, [ref] $tokens, [ref] $errors)
$original = Get-Content -Raw -LiteralPath $Path
$formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
$records = @(Invoke-ScriptAnalyzer -Path $Path -Settings $settings)
foreach ($record in $records) { Write-Output "PSSA $($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "STAGE-CHECK ParseErrors=$(@($errors).Count) FormatChanged=$($formatted -cne $original) DiagnosticCount=$($records.Count)"
```

A16 json-engine-probe.ps1 (read-only, in memory):

```powershell
$ErrorActionPreference = 'Stop'
$nanText = '{"a":NaN}'
$deepText = '{"a":' + ('[' * 70) + (']' * 70) + '}'
function Test-ConvertFromJson([string] $Text) { try { $null = ConvertFrom-Json -InputObject $Text -ErrorAction Stop; return $true } catch { return $false } }
function Test-SystemTextJson([string] $Text) { try { $document = [System.Text.Json.JsonDocument]::Parse($Text, [System.Text.Json.JsonDocumentOptions]::new()); $document.Dispose(); return $true } catch { return $false } }
Write-Output "CFJ_NAN_ACCEPTED=$(Test-ConvertFromJson $nanText)"
Write-Output "CFJ_DEPTH70_ACCEPTED=$(Test-ConvertFromJson $deepText)"
Write-Output "STJ_NAN_REJECTED=$(-not (Test-SystemTextJson $nanText))"
Write-Output "STJ_DEPTH70_REJECTED=$(-not (Test-SystemTextJson $deepText))"
Write-Output "PWSH_VERSION=$($PSVersionTable.PSVersion)"
```

A17 token-scan.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string[]] $Token, [Parameter(Mandatory)][string[]] $File)
$Token = @($Token | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$count = 0
foreach ($target in $File) {
    $lines = @(Get-Content -LiteralPath $target)
    for ($index = 0; $index -lt $lines.Count; $index++) {
        foreach ($item in $Token) { if ($lines[$index].Contains($item)) { $count++; Write-Output "TOKEN file=$target line=$($index + 1) token=$item" } }
    }
}
Write-Output "TOKEN-SUMMARY count=$count files=$($File.Count)"
```

A18 resolver-call-scan.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string[]] $File)
$ErrorActionPreference = 'Stop'
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$allowed = @('Find-WorktreeRunIdentitySignal', 'Get-WorktreeRunCheckpointText', 'Get-WorktreeRunCheckpointPath', 'Resolve-WorktreeEpicTarget', 'Resolve-WorktreeParallelTarget', 'Resolve-WorktreeOperandTarget', 'Get-WorktreeItemLiveRoot')
$resolverFunctions = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($module in @(Get-ChildItem -LiteralPath '.claude/lib/worktree-resolution' -Filter '*.psm1' -File)) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($module.FullName, [ref] $tokens, [ref] $errors)
    foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) { [void] $resolverFunctions.Add($definition.Name) }
}
$banned = @('python', 'python3', 'py', 'poetry')
$disallowed = 0
$interpreter = 0
foreach ($target in $File) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $target).Path, [ref] $tokens, [ref] $errors)
    foreach ($command in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)) {
        $name = $command.GetCommandName()
        if (-not $name) { continue }
        if ($resolverFunctions.Contains($name)) {
            $isAllowed = $allowed -contains $name
            if (-not $isAllowed) { $disallowed++ }
            Write-Output "RESOLVER-CALL file=$target name=$name allowed=$isAllowed"
        }
        if ($banned -contains $name.ToLowerInvariant()) { $interpreter++; Write-Output "INTERPRETER-CALL file=$target name=$name" }
    }
}
Write-Output "RESOLVER-CALL-SUMMARY disallowed=$disallowed interpreter=$interpreter"
```

A19 removed-lines-scan.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $BaseRef, [Parameter(Mandatory)][string[]] $Token, [Parameter(Mandatory)][string[]] $File)
$Token = @($Token | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$count = 0
foreach ($target in $File) {
    foreach ($line in @(git diff -U0 $BaseRef -- $target)) {
        if ($line.StartsWith('-') -and -not $line.StartsWith('---')) {
            foreach ($item in $Token) { if ($line.Contains($item)) { $count++; Write-Output "REMOVED-TOKEN file=$target token=$item text=$($line.Trim())" } }
        }
    }
}
Write-Output "REMOVED-TOKEN-SUMMARY count=$count files=$($File.Count)"
```

A20 py-coverage-totals.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$totals = (Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json).totals
$line = if ($totals.num_statements -gt 0) { [math]::Round(100 * $totals.covered_lines / $totals.num_statements, 2) } else { 'NA' }
$branch = if ($totals.num_branches -gt 0) { [math]::Round(100 * $totals.covered_branches / $totals.num_branches, 2) } else { 'NA' }
Write-Output "PY-COVERAGE LinePercent=$line BranchPercent=$branch CombinedPercent=$([math]::Round([double]$totals.percent_covered, 2))"
```

A21 ac-checkbox-count.ps1 (read-only; total from the shipped counter, checked and unchecked by prefix inside the same section):

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path (Get-Location).Path '.claude/lib/requirements/GeneratedDocumentCounters.psm1') -Force
$document = Get-Content -Raw -LiteralPath $Path
$total = Get-NamedSectionCheckboxCount -Document $document -Heading 'Acceptance Criteria'
$inside = $false
$checked = 0
$unchecked = 0
foreach ($line in ($document -split "`r?`n")) {
    if ($line -match '^#{1,2}\s+') { $inside = ($line.Trim() -eq '## Acceptance Criteria'); continue }
    if (-not $inside) { continue }
    if ($line.StartsWith('- [x] ')) { $checked++ } elseif ($line.StartsWith('- [ ] ')) { $unchecked++ }
}
Write-Output "AC-CHECKBOXES total=$total checked=$checked unchecked=$unchecked"
```

A22 lowercase-digest.ps1 (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "DIGEST file=$file sha256=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant())" }
```

A23 codex-copy-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) {
    $codex = $file -replace '^\.claude/', '.codex/'
    $agents = $file -replace '^\.claude/', '.agents/'
    $candidates = @($codex, $agents)
    if ($file -like '.claude/agents/*.md') { $candidates += ($codex -replace '\.md$', '.toml') }
    foreach ($candidate in $candidates) { Write-Output "CODEX-CANDIDATE file=$file candidate=$candidate exists=$(Test-Path -LiteralPath $candidate -PathType Leaf)" }
}
```

## Appendix I — Acceptance-Criteria Inventory (spec line per ID)

AC-01 184, AC-02 185, AC-03 186, AC-04 187, AC-05 188, AC-06 189, AC-07 190, AC-08 191, AC-09 192, AC-10 193, AC-11 194, AC-12 195, AC-13 196, AC-14 197, AC-15 198, AC-16 199, AC-17 200, AC-18 201, AC-19 202, AC-20 203, AC-21 204, AC-22 205, AC-23 206, AC-24 207, AC-25 208, AC-26 209.
