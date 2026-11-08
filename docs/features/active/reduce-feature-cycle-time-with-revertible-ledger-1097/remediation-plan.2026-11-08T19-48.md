# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Stage I, cycle 3, F1 merge with PR #1142)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T19-48
- **Status:** Authored by `atomic-planner`; awaiting executor preflight
- **Version:** 1.0
- **Inputs:** `remediation-inputs.2026-11-08T19-48.md` (finding F1, primary); cycle 1 plan `remediation-plan.2026-11-08T18-06.md` and its preflight record `evidence/other/preflight-fixes.2026-11-08T18-22.md` (method); `## Stored Patch` of `docs/engineering/process-reductions/0010-early-dependent-starts.md` (cycle 1 and cycle 2 regenerations); `spec.md` decision D7 and the `[I]` criteria

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell, Python, TypeScript code-change and unit-test instructions under `.github/instructions/`

**All work must comply with these policies; do not duplicate their content here.**

## Scope

F1 only. The first task after the reference baselines is the merge: `git merge origin/main` into `feature/reduce-feature-cycle-time` as one merge commit, with no rebase and no forced push. The three conflicted files (`.claude/skills/epic-run/SKILL.md`, its Claude bundle copy, and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`) are resolved keeping both sides, and every mirror is then verified byte-identical. The plan then checks #1142 against the early-start rule (the only new semantic check; the #1129 and #1130 checks were completed in cycle 1), re-pins `PINNED_FROZEN_SURFACE_HASHES`, regenerates ledger entry `0010` against the merged base, and runs the final gates against the stage I Phase 0 baselines.

### Design Decision: the cycle 1 method is reused unchanged

The method of `### Design Decision` in the cycle 1 plan applies, including the preflight fixes recorded for it: a conflict-marker search scoped to the conflicted paths; a conflicted path whose 0010 pre-image equals its merge-base blob takes its `origin/main` blob in the pre-0010 tree; tree comparison over the patch paths with `git diff --quiet`; and PoshQC format evidence read as `Already formatted:` lines. The later-landing rule of README `## Entry Format` is not used, because #1142's text is `main`'s own change and recording it as a 0010 later landing would make a 0010 revert delete #1142's `## Nesting Depth` sections and Agent-tool preflight.

Pre-0010 merged state, derived mechanically: cycle 2 regenerated the patch from the `origin/main` commit the branch last merged, so every modify-section pre-image blob of the current patch is expected to equal the blob of its path at the merge base of `HEAD` and `origin/main` before this merge ([P0-T2] confirms it). For each such path the branch changed the text only through 0010, so its pre-0010 merged text is its `origin/main` blob; each created path is absent. A path whose pre-image differs from its merge-base blob uses the cycle 1 three-way `git merge-file` rule, and a conflict on such a path is returned as a finding. The pre-0010 digests of revert step 4 are then the SHA-256 of `origin/main`'s `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`, which are also `origin/main`'s pinned values.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`. `SCRATCH` resolves to `<session scratchpad>/issue-1097/`; scratch names start with `issue-1097-`, and artifacts record the token, never a host path. Evidence names carry the prefix `stage-i-cycle3-`, stamped with the UTC write time; a consumer selects the greatest `<name>.*.md`.
- Tool routes, launchers, command-text restrictions, the batch budget, hook context, and CI shape come from the `execution-environment` skill. Git-index, digest, and ledger helpers are `sh` scripts under `SCRATCH`.
- Python: Poetry commands use the command shape of the `Command:` of the greatest `stage-i-python-test.*.md`. No unqualified `poetry install` from the item worktree. No new Python file.
- Testing: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs. A focused run of one file is debugging only and never evidence.
- Commits: commit and push after each task through `git commit -F` with a file under `SCRATCH`. No tag, no `git stash`, no history rewrite, no forced push. Every commit that edits a ledger entry or patch carries that entry's `reduction:` token in its subject.
- Out of scope: Epic #1019 folders and integration branch; every other item's feature folder that arrives from `main`; `docs/engineering/process-reductions/README.md` and entries `0001` to `0009` (unless [P3-T3] shows the chain needs an edit, made under that entry's token and listed).
- Failure outside the branch: a failing test whose file and subject are both absent from the diff between the merge base of `origin/main` and `HEAD` (after [P1-T1], files only `main` changed). The gate artifact names the test, file, and subject; `EXIT_CODE:` stays non-zero; the test is not edited; the executor returns these facts. Any other failure is fixed and the QA loop restarts from [P5-T1].

## Test Dispositions

Found by searching `tests/` for `PINNED_FROZEN_SURFACE_HASHES`, `0010-early-dependent-starts`, `Nesting Depth`, `NESTING_DEPTH_INSUFFICIENT`, `AGENT_TOOL_UNAVAILABLE`, and the three conflicted paths.

- `test_frozen_epic_surface_matches_pinned_baseline_digest` (`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`): code unchanged; its pinned data is updated in [P2-T2] because the merged surfaces have new digests.
- `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-END-STATE-RECORDED`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRC-README-REVERT-ORDER-STATED`, `PRC-LEDGER-NO-EXCEPTIONS` (`tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`) and `PRL-REAL-LEDGER-AGREES` (`tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`): unchanged; they must pass on the merged ledger after [P3-T2].
- `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1` (including `ESS-RUN-POINTS-TO-SECTION` and `ESS-CLAUDE-NAMES-PYTHON-CLI-ROUTE`) and `tests/scripts/dev_tools/test_epic_wave_barrier_early_start.py`: unchanged, because the merge keeps stage I's text; a [P2-T1] fix adds one `ESS-` case and names it in its artifact.
- #1142's tests `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` and `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1` (including `coordinator skills document Nesting Depth and fallback` and `bundle copy matches live file`): unchanged; they must pass on the merged text, which keeps every `## Nesting Depth` section.
- `test_orchestrate_skill_first_thirteen_headings_match_required_layout`: unchanged; it reads `parallel-orchestrate/SKILL.md`, which is not a 0010 path.
- Push-down contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both `*_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`): unchanged; read from the [P5-T4] gate.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Write `FEATURE/evidence/baseline/stage-i-cycle3-baseline-reference.<timestamp>.md`, recording the stage I Phase 0 baseline read from the greatest `stage-i-powershell-test.*.md`, `stage-i-python-test.*.md`, `stage-i-typescript-test.*.md`, `stage-i-powershell-static.*.md`, `stage-i-python-static.*.md`, `stage-i-typescript-static.*.md`, and `stage-i-ledger-state.*.md` under `FEATURE/evidence/baseline/`. No suite is run.
  - Acceptance: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` present; every figure numeric and traced to a named artifact; `Command:` states that no suite was run.
- [x] [P0-T2] Record the pre-merge ledger state on the branch head in `FEATURE/evidence/baseline/stage-i-cycle3-premerge-ledger.<timestamp>.md`, and copy `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch` to `SCRATCH` as the cycle 2 patch.
  - Checks: `Test-ProcessReductionLedger` over `Read-ProcessReductionLedger`; `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` and with `-StopBefore` for each stored-patch entry; `git apply -R --check` of the 0010 patch; for every modify section, its `index` pre-image blob compared with the blob of that path at the merge base of `HEAD` and `origin/main`.
  - Acceptance: chain `IsValid` true with 0 errors and the patch check exit 0; the artifact lists each patch path as `equal` or `differs` (a `differs` path uses the `git merge-file` rule in [P3-T1]); any chain or apply failure is returned before [P1-T1].

### Phase 1 — Merge

- [x] [P1-T1] Merge `origin/main` with `git merge origin/main` and one merge commit, resolving the three conflicted files keeping both sides, and write `FEATURE/evidence/other/stage-i-cycle3-merge.<timestamp>.md`.
  - `.claude/skills/epic-run/SKILL.md`: keep #1142's `## Nesting Depth` section and stage I's `early_start_on` paragraph of `## Scope`, each in its own position; the Claude bundle copy under `extensions/drm-copilot/resources/claude-customizations/` is re-copied from the source, not hand-merged.
  - `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: keep main's `RE-BASELINED` paragraphs, ending with the `RE-BASELINED by issue #1138.` paragraph, followed by the `RE-BASELINED by issue #1097.` paragraph (landing order); take main's digest values for now ([P2-T2] re-pins).
  - Acceptance:
    - `git grep -n -e "^<<<<<<< " -e "^>>>>>>> "` over the three conflicted paths returns no match.
    - For each conflicted source file, every line that the diff from the pre-merge merge base to `origin/main` adds, and every `+` line of the cycle 2 patch section for that path except the two stage I digest lines of the pin file, is present in the merged file (script under `SCRATCH`, counts recorded).
    - `git log -1` shows two parents; the push succeeds without force.
- [x] [P1-T2] Verify mirror byte-identity and write `FEATURE/evidence/other/stage-i-cycle3-mirrors.<timestamp>.md`.
  - Pairs: each source in 0010 `## Files Changed` with its bundle copy, the two `epic-wave-barrier-early-start.ps1` twins, and each file #1142 added or changed under `.claude/`, `.codex/`, or `.agents/` with its bundle copy (from the diff of the pre-merge merge base to `origin/main`).
  - Acceptance: equal SHA-256 for every pair; a mismatch is re-copied from the source, committed, and listed.

### Phase 2 — #1142 Overlap and Pins

- [x] [P2-T1] Check #1142 against the early-start rule and write `FEATURE/evidence/other/stage-i-cycle3-overlap-1142.<timestamp>.md`.
  - Read `Test-EpicInvocationNestingDepthApplies` and `Get-EpicInvocationNestingDepthDenyReason` in `.claude/hooks/epic-invocation-nesting-depth.ps1`, the delegation path of `.claude/hooks/enforce-epic-invocation-origin.ps1`, `## Nesting Depth` of both Claude epic skills, the Agent-tool preflight and the `Exception (issue #1097)` paragraph of `.claude/agents/epic-orchestrator.md`, and `## Early Dependent Starts (early_start)`.
  - Questions: (a) an early-started dependent is an ordinary `Agent(orchestrator)` child of `epic-orchestrator`, so the nesting-depth decision depends only on target and caller and is the same with or without the early-start kickoff lines; (b) under the main-session fallback of `## Nesting Depth`, each early-start parent step (evidence wait, checkpoint write and validation, the ancestry check and the `early_start.synced_at` write) has an owner, or the text is silent on it; (c) no hook function edited by #1142 is shared with the wave-barrier hooks or `epic-wave-barrier-early-start.ps1`.
  - Fix route for (b) silent: one sentence in `## Early Dependent Starts (early_start)` of `.claude/skills/epic-orchestrate/SKILL.md` stating that under the main-session fallback the feature keeps the wave barrier, the bundle copy re-copied, and one new `ESS-` case in `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1` pinning it; the fix paths are added to 0010 `## Files Changed` in [P3-T2]. Decision D7 is unchanged.
  - Acceptance: each question answered with the file and symbol that decide it; the artifact records `no contradiction` or the fix with its commit.
- [x] [P2-T2] Re-pin `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` to the SHA-256 of the merged `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`, after any [P2-T1] edit; comment paragraphs stay as [P1-T1] left them.
  - Acceptance: each pinned value equals the lowercase SHA-256 of its file (script under `SCRATCH`, recorded in `FEATURE/evidence/other/stage-i-cycle3-pins.<timestamp>.md`); `test_frozen_epic_surface_matches_pinned_baseline_digest` is read from the [P5-T4] gate.

### Phase 3 — Ledger Entry 0010

- [x] [P3-T1] Build the pre-0010 merged tree of `### Design Decision` in a scratch index (`GIT_INDEX_FILE` under `SCRATCH`, no worktree, ref, or commit) and write `FEATURE/evidence/other/stage-i-cycle3-pre0010.<timestamp>.md`.
  - Acceptance: the tree id is recorded; each modify path marked `equal` in [P0-T2] holds its `origin/main` blob; each created path is absent; the two pin values in the pre-0010 pin file equal the SHA-256 of the pre-0010 `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` and equal `origin/main`'s pinned values.
- [ ] [P3-T2] Regenerate `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch` as `git diff --binary --full-index --no-renames <pre-0010 tree> HEAD` over the paths of 0010 `## Files Changed` other than the ledger folder, and update `docs/engineering/process-reductions/0010-early-dependent-starts.md`, in one commit whose subject carries `reduction: 0010`.
  - `## Stored Patch`: add a paragraph beginning "Regenerated in remediation cycle 3" that names PR #1142 (#1138), the three conflicted files, the derivation, and why the later-landing rule does not apply; extend the Revert Order paragraph so the revert keeps #1142's `## Nesting Depth` sections, the Agent-tool preflight, and the `RE-BASELINED by issue #1138.` paragraph.
  - `## Files Changed`: add any [P2-T1] fix path. `## Revert Steps`: step 4 carries the pre-0010 digests of [P3-T1]; step 6 adds `NestingDepthContract.Tests.ps1`, which reads 0010 paths. `## Revert Signals` keeps its four bullets.
  - Acceptance:
    - `git apply -R --check` of the patch exits 0 on the live tree.
    - Excluding the pin-file digest lines and [P2-T1] fix lines (listed), the `+` and `-` line multisets of the new patch equal those of the cycle 2 patch copied in [P0-T2].
    - `git log -1 --format=%s` contains `reduction: 0010`; the entry contains `Regenerated in remediation cycle 3`; revert step 4 contains both [P3-T1] digest values.
- [ ] [P3-T3] Run the ledger gates (script under `SCRATCH`) and write `FEATURE/evidence/other/stage-i-cycle3-ledger-gates.<timestamp>.md`.
  - Gates:
    - (a) `Test-ProcessReductionLedger` valid.
    - (b) `Invoke-ProcessReductionChain` over all 10 entries and with `-StopBefore` for each stored-patch entry: `IsValid` true, 0 errors.
    - (c) No end-state error, and every created path absent in `FinalText`.
    - (d) `Get-ProcessReductionLanding` returns only `first` for `0010`.
    - (e) `git apply --cached -R` of the patch on a scratch index of `HEAD` yields a tree for which `git diff --quiet` against `origin/main` over every patch path exits 0.
    - (f) `git diff --quiet` from the merge commit's first parent to `HEAD` over entries `0001` to `0009`, their patches, and `README.md` exits 0, or each edit is listed with its token.
  - A chain error in `0001` to `0009` caused by main's text is fixed per README `## Revert Order` under that entry's token and listed; no exception list and no skip.
  - Acceptance: `EXIT_CODE:` 0 only when all six gates pass.

### Phase 4 — Generated Variants

- [ ] [P4-T1] Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` and write `FEATURE/evidence/other/stage-i-cycle3-codex-check.<timestamp>.md`.
  - Acceptance: exit 0 with no reported drift; on drift, run the generator without `--check`, commit the regenerated files, and re-run until exit 0.

### Phase 5 — Final QA

- [ ] [P5-T1] PowerShell static: PoshQC format in check mode and the direct analyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every `.ps1`/`.psm1` in 0010 `## Files Changed` and any [P2-T1] fix; write `FEATURE/evidence/qa-gates/stage-i-cycle3-powershell-static.<timestamp>.md`.
  - Acceptance: `Already formatted:` for every file and no `Formatted:` line, `git status --porcelain` over those files empty afterwards, 0 analyzer findings, compared with the stage I static baseline.
- [ ] [P5-T2] Python static: Black in check mode, Ruff, and Pyright over the Python files in 0010 `## Files Changed`; write `FEATURE/evidence/qa-gates/stage-i-cycle3-python-static.<timestamp>.md`.
  - Acceptance: Black reports `would be left unchanged`, Ruff and Pyright 0 findings, compared with the stage I static baseline.
- [ ] [P5-T3] Run one `Invoke-PoshQCParallelTest` and write `FEATURE/evidence/qa-gates/stage-i-cycle3-powershell-test.<timestamp>.md`.
  - Counts from `artifacts/pester/pester-junit.xml` (shard files when `ExitCode` is non-zero), line coverage from `artifacts/pester/powershell-coverage.xml`.
  - Acceptance: `ExitCode` 0 and 0 failures; the `PRC-LEDGER-` tests, `PRL-REAL-LEDGER-AGREES`, the `EarlyStart` suites, `early-start-skill-contract.Tests.ps1`, `epic-invocation-nesting-depth.Tests.ps1`, and `NestingDepthContract.Tests.ps1` passed; `OrchestratorStateEpicWaveBarrier.psm1` and both `enforce-epic-wave-barrier.ps1` gates not below their baseline; both `epic-wave-barrier-early-start.ps1` siblings at 100% lines; repo-wide not below 95.6% or each drop attributed per file to files only main changed.
- [ ] [P5-T4] Run one `pytest -n auto` with coverage (command shape of the stage I baseline) and write `FEATURE/evidence/qa-gates/stage-i-cycle3-python-test.<timestamp>.md`.
  - Acceptance: 0 failures; the push-down contract tests, `test_parallel_orchestrator_surface_contracts.py`, `test_epic_wave_barrier_early_start.py`, and `test_epic_skill_script_citations_shipped.py` passed; `_epic_orchestrator_state_wave_barrier.py` at 100% line and branch; repo-wide line and branch not below 97.11% and 94.36% or each drop attributed to files only main changed.
- [ ] [P5-T5] Decide the TypeScript gates and write the artifact for the outcome.
  - Condition: a TypeScript file in the resolution is a `.ts` file or `extensions/drm-copilot/jest.config.cjs` whose `HEAD` blob equals neither its first-parent blob nor its `origin/main` blob (combined by the merge or edited by a cycle 3 commit), found by a script under `SCRATCH`.
  - Skip branch (authorized by the cycle 3 inputs): when the condition finds no file, write `FEATURE/evidence/qa-gates/stage-i-cycle3-typescript-na.<timestamp>.md` with the search and `SearchResult: none`.
  - Otherwise: Prettier check, ESLint, and `tsc --noEmit` in `extensions/drm-copilot/` into `stage-i-cycle3-typescript-static.<timestamp>.md`, and one Jest coverage run into `stage-i-cycle3-typescript-test.<timestamp>.md`, both under `FEATURE/evidence/qa-gates/`.
  - Acceptance: the not-applicable artifact lists the files compared; or 0 format, lint, and type findings, 0 Jest failures, `epic-orchestrator-state-early-start.test.ts` passed, `epic-orchestrator-state-core.ts` not below its baseline, and `epic-orchestrator-state-wave-barrier.ts` at least 85% line and 75% branch.
- [ ] [P5-T6] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Rows include: both sides kept with no conflict marker; mirrors byte-identical; pins equal merged digests; #1142 and the early-start rule consistent; 0010 patch reverses to `origin/main` and the chain holds; entries `0001` to `0009` and README unchanged or each change listed with its token; no Epic #1019 or other item's folder edited; no tag, stash, or forced push; no baseline task, evidence, or comparison reduced; changed files at their baseline coverage.
  - Acceptance: no FAIL row; a FAIL is fixed and the loop restarts from [P5-T1].

## Pre-Mortem

- Review checklists: [P5-T6] walks all three templates against the merge-base diff, with explicit rows for both-sides resolution, mirrors, pins, the #1142 check, the ledger chain, token-bearing commits, scope, and baselines.
- Coverage: [P5-T3] to [P5-T5] read per-file coverage of stage I's changed production files from the single gate runs against [P0-T1]; both early-start siblings must stay at 100% lines; a repo-wide drop is attributed per file, and only drops in files main alone changed are returned rather than failed.
- Mirror parity: [P1-T2] hash-checks every source and bundle pair after the merge, [P2-T1] re-copies the bundle copy of any skill fix, [P4-T1] runs the Codex generator `--check`, and the push-down contract tests are read from [P5-T4]. No CI job, required context, tool route, or batch-budget rule changes, so no brief-update task is owed; the brief changes only through main's merged #1142 text.
- File size: the merge adds text to Markdown skills (exempt); `parallel_orchestrator_surface_expectations.py` changes only digest values and keeps main's paragraphs; a [P2-T1] test case goes into the existing contract file only if it stays below the 500-line tier, otherwise into a new sibling test file.
- Test isolation: one `Invoke-PoshQCParallelTest` run ([P5-T3]), one `pytest -n auto` run ([P5-T4]), and Jest through its normal parallel workers ([P5-T5], only when its condition holds), each re-run only after a fix; ledger, pin, and tree checks are scripts that write only under `SCRATCH`.
- CI-only behavior: the regenerated patch is written by `git diff` with LF endings and never hand-reformatted, so the `eol=lf` rule keeps it intact; the chain and nesting-depth suites run in the Windows shards and `epic-invocation-nesting-depth.Tests.ps1` also in the Linux hook-suite job, which the merge does not change; a merge with code changes gets a full CI run, and the re-audit follows CI on the merged head.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/` with a write-time stamp and the four required fields; `SCRATCH` appears only as a token; the stage I baselines are read, not reduced or re-captured.
