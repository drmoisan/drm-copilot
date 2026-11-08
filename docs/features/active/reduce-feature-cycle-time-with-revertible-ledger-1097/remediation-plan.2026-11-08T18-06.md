# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Stage I, cycle 1, F1 merge with PRs #1134, #1135, #1137)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T18-06
- **Status:** Authored by `atomic-planner`; awaiting executor preflight
- **Version:** 1.0
- **Inputs:** `remediation-inputs.2026-11-08T18-06.md` (finding F1, primary); stage I plan `plan.2026-11-07T00-56.md` (context); `spec.md` decision D7 and the `[I]` criteria

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell, Python, TypeScript code-change and unit-test instructions under `.github/instructions/`

**All work must comply with these policies; do not duplicate their content here.**

## Scope

F1 only. The executor's first task is the merge itself: `git merge origin/main` into `feature/reduce-feature-cycle-time` as a merge commit, with no rebase and no forced push. Each of the seven conflicted files is resolved keeping both sides (main's #1129 and #1130 text and stage I's early-start text), and every mirror is then verified byte-identical to its source. After the merge the plan re-pins `PINNED_FROZEN_SURFACE_HASHES`, checks the two semantic overlaps named in F1, makes ledger entry `0010` correct relative to the merged base, and runs the final gates against the stage I Phase 0 baselines.

### Design Decision: entry 0010 is regenerated against the merged base

Decision: regenerate `patches/0010-early-dependent-starts.patch` and update `0010-early-dependent-starts.md` against the merged tree, in one commit whose subject carries `reduction: 0010`. The later-landing rule is not used.

Reasons:

- `### Later Landing: #N` records wording *for the same reduction* that landed after a higher-numbered entry (README `## Entry Format`). The #1129 and #1130 text is not 0010 wording; it is main's own change. Recording it as a 0010 later landing would make a 0010 revert also delete main's wave CLI grant and child-CI rule, which the owner's revertibility requirement forbids.
- `Invoke-ProcessReductionChain` reverts a patch entry's later landings through block steps and then runs the patch hunks against the result. The digest hunk of the current patch carries the stage I digests as its `Current` (`+`) lines; after the merge the live pins are the merged digests, so that hunk cannot apply and no later-landing block can make it apply without claiming main's text.
- `0010` is the highest-numbered entry and lands on `main` after #1129 and #1130, so its record must be a diff from "merged tree without 0010" to "merged tree". README `## Revert Order` already states that the highest entry is reverted first against the live tree, and the README rule "An edit inside a recorded region ... must update that entry's record" names regeneration under the entry's token as the fix. No README edit is needed, and the chain (no `### Later Landing:` heading in 0010) and README then agree.
- Revertibility months from now: the regenerated patch is a self-contained diff with full blob ids, so `git apply -R` restores the pre-0010 merged state without `git revert`; a hunk that no longer applies is applied by hand as README `## Revert Order` states. Revert steps 2 to 6 name every mirror, the pinned digests of the pre-0010 merged surfaces, the contract-test literal, and the contract tests, including main's tests that read 0010 paths.

Pre-0010 merged state (the regeneration base), derived mechanically so a third party obtains the same tree: for each path the current 0010 patch modifies, three-way merge (`git merge-file`) with ours = the merged `HEAD` text, base = the text at the merge commit's first parent (stage I post-image), theirs = the patch's pre-image blob (from its `index` line); each path the patch creates is absent. Where `git merge-file` reports a conflict, the path's 0010 pre-image blob equals its merge-base blob (the branch changed the path only through 0010), so its pre-0010 text is its `origin/main` blob, which is taken. In `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` the pre-0010 text is main's comment paragraphs without the `RE-BASELINED by issue #1097.` paragraph, and its two digests are the SHA-256 of the pre-0010 `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. The tree is built in a scratch index (`GIT_INDEX_FILE` under `SCRATCH`), with no worktree, ref, or commit.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`. `SCRATCH` resolves to `<session scratchpad>/issue-1097/`; scratch names start with `issue-1097-`, and artifacts record the token, never a host path. Evidence names carry the prefix `stage-i-cycle1-`, stamped with the UTC write time; a consumer selects the greatest `<name>.*.md`.
- Tool routes, launchers, command-text restrictions, the batch budget, hook context, and CI shape come from the `execution-environment` skill. Git-index and digest helpers are `sh` scripts under `SCRATCH`.
- Python: Poetry commands use `VIRTUAL_ENV` pointing at the main checkout's `.venv`, with the same command shape as the `Command:` of the greatest `stage-i-python-test.*.md`. No unqualified `poetry install` from the item worktree. No new Python file.
- Testing: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs. A focused run of one file is debugging only and never evidence.
- Commits: commit and push after each task through `git commit -F` with a file under `SCRATCH`. No tag, no `git stash`, no history rewrite, no forced push. Every commit that edits a ledger entry or patch carries that entry's `reduction:` token in its subject.
- Out of scope: Epic #1019 folders and integration branch; every other item's feature folder that arrives from `main`; `docs/engineering/process-reductions/README.md` (unless [P3-T3] proves a disagreement); entries `0001` to `0009` (unless [P3-T3] shows the chain needs it).
- Failure outside the branch: a failing test whose file and subject are both absent from the diff between the merge base of `origin/main` and `HEAD` (after [P1-T1], files that only `main` changed). The gate artifact names the test, file, and subject; `EXIT_CODE:` stays non-zero; the test is not edited; the executor returns these facts. Any other failure is fixed and the QA loop restarts from [P5-T1].

## Test Dispositions

Found by searching `tests/` for `PINNED_FROZEN_SURFACE_HASHES`, `0010-early-dependent-starts`, `process-reductions`, `early_start`, and the seven conflicted paths.

- `test_frozen_epic_surface_matches_pinned_baseline_digest` (`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`): code unchanged; its pinned data is updated in [P2-T3] because the merged surfaces have new digests.
- `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-END-STATE-RECORDED`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRC-README-REVERT-ORDER-STATED`, `PRC-LEDGER-NO-EXCEPTIONS` (`tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`) and `PRL-REAL-LEDGER-AGREES` (`tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`): unchanged; they must pass on the merged ledger after [P3-T2].
- `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1` and `tests/scripts/dev_tools/test_epic_wave_barrier_early_start.py` (including `test_existing_corpus_holds_no_early_start_key`): unchanged; the merge keeps stage I's text and fixtures.
- main's #1129 and #1130 tests (including `tests/scripts/dev_tools/test_epic_wave_corpus_parity.py` and the child-CI merge-gate suites): unchanged; they must pass on the merged text. A fix from [P2-T1] or [P2-T2] that changes their asserted behavior names them with dispositions in its artifact.
- Push-down contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both `*_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`): unchanged; read from the [P5-T5] gate.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Write `FEATURE/evidence/baseline/stage-i-cycle1-baseline-reference.<timestamp>.md`, recording the stage I Phase 0 baseline read from the greatest `stage-i-powershell-test.*.md`, `stage-i-python-test.*.md`, `stage-i-typescript-test.*.md`, `stage-i-powershell-static.*.md`, `stage-i-python-static.*.md`, `stage-i-typescript-static.*.md`, and `stage-i-ledger-state.*.md` under `FEATURE/evidence/baseline/`. No suite is run.
  - Output Summary: per gate the pass and fail counts, repo-wide coverage, and the per-file coverage of stage I's changed production files named in those artifacts; the static finding counts; the ledger state.
  - Acceptance: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` present; every figure numeric and traced to a named artifact; `Command:` states that no suite was run.
- [x] [P0-T2] Record the pre-merge ledger state in `FEATURE/evidence/baseline/stage-i-cycle1-premerge-ledger.<timestamp>.md`, on the branch head before the merge.
  - Checks (script under `SCRATCH`): `Test-ProcessReductionLedger` over `Read-ProcessReductionLedger`; `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` and with `-StopBefore` for each stored-patch entry; `git apply -R --check` of `patches/0010-early-dependent-starts.patch`; the `index` pre-image blob id of every modify section of that patch resolves with `git cat-file -e`.
  - Acceptance: each result recorded; chain `IsValid` true with 0 errors and the patch check exit 0 (the state the regeneration starts from); any failure is returned before [P1-T1].

### Phase 1 — Merge

- [x] [P1-T1] Merge `origin/main` into the branch with `git merge origin/main` and one merge commit, resolving the seven conflicted files keeping both sides, and write `FEATURE/evidence/other/stage-i-cycle1-merge.<timestamp>.md`.
  - `.claude/skills/epic-run/SKILL.md` and `.agents/skills/epic-run/SKILL.md`: keep #1130's epic-child CI text and stage I's `early_start_on` paragraph of `## Scope`, each in its own section position; bundle copies are re-copied from their sources, not hand-merged.
  - `.claude/agents/epic-orchestrator.md`: keep #1129's wave CLI grant in `tools:` and its citation, and stage I's validator CLI grant and the `Exception (issue #1097)` paragraph of `## Wave Scheduling`; the bundle copy is re-copied.
  - `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: keep main's `RE-BASELINED` paragraphs followed by the `RE-BASELINED by issue #1097.` paragraph (landing order); take main's digest values for now ([P2-T3] re-pins).
  - Acceptance:
    - `git grep -n -e "^<<<<<<< " -e "^>>>>>>> "` over the seven conflicted paths returns no match (tracked merge-conflict fixtures elsewhere in the tree hold such lines by design).
    - For each conflicted source file, every line that the diff from the merge base of the first parent and `origin/main` to `origin/main` adds, and every `+` line of the 0010 patch section for that path except the two stage I digest lines of the pin file (main's digest values are taken until [P2-T3]), is present in the merged file (script under `SCRATCH`, counts recorded).
    - `git log -1` shows two parents; no rebase or forced push; the push succeeds.
- [x] [P1-T2] Verify mirror byte-identity and write `FEATURE/evidence/other/stage-i-cycle1-mirrors.<timestamp>.md`.
  - Pairs: each source in 0010 `## Files Changed` with its bundle copy under `extensions/drm-copilot/resources/`, the two `epic-wave-barrier-early-start.ps1` twins, and each file main added or changed under `.claude/`, `.codex/`, or `.agents/` with its bundle copy (from the merge-base diff to `origin/main`).
  - Acceptance: equal SHA-256 for every pair; a mismatch is re-copied from the source and committed, and the artifact lists it.

### Phase 2 — Semantic Overlap and Pins

- [x] [P2-T1] Check #1129 against stage I and write `FEATURE/evidence/other/stage-i-cycle1-overlap-1129.<timestamp>.md`.
  - Read `tests/scripts/dev_tools/test_epic_wave_corpus_parity.py`, every #1129 test that enumerates a fixture directory, and the manifest reader under `.claude/lib/epic-wave/`.
  - Questions: (a) does any #1129 test enumerate `tests/fixtures/epic_wave_barrier/` or read `early-start-edge-cases.json`, changing its counts or results; (b) does the wave CLI read only `depends_on` and accept a manifest entry carrying `early_start_on`, as `## Early Dependent Starts (early_start)` of the epic-orchestrate skill states ("the field moves no wave").
  - Fix route: a corpus collision is fixed in the #1129 test's selection or by moving the stage I corpus, and a rejected `early_start_on` key by a tolerance in the wave lib with a new test; a fix path is added to 0010 `## Files Changed` in [P3-T2].
  - Acceptance: each question answered with the file, symbol, and test that decide it; the wave CLI run on an in-memory or `SCRATCH` manifest with `early_start_on` exits 0 with the same waves as without it.
- [x] [P2-T2] Check #1130 against the early-start rule and write `FEATURE/evidence/other/stage-i-cycle1-overlap-1130.<timestamp>.md`.
  - Read `Get-EpicMergeGateChildCiDecision` in `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`, #1130's text in the epic-run skills and `.claude/skills/orchestrate/SKILL.md`, and steps 5 to 9 of `## Early Dependent Starts (early_start)`.
  - Question: an early-started dependent reaches `pr_open` only after its sync merge, so its CI must be verified on the post-sync live head (`ci_gate.head_sha` equal to that head). The check confirms that no early-start step allows a merge on pre-sync CI, and that the wave-barrier hooks and the merge gate share no edited function.
  - Fix route: a contradiction is fixed in the early-start section of both epic-orchestrate skills and their bundle copies (decision D7 unchanged).
  - Acceptance: the artifact records `no contradiction` or the fix, with the symbols read.
- [x] [P2-T3] Re-pin `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` to the SHA-256 of the merged `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`, after Phase 2 edits.
  - Comment paragraphs stay as [P1-T1] left them; no paragraph is added.
  - Acceptance: each pinned value equals the lowercase SHA-256 of its file (script under `SCRATCH`, recorded in `FEATURE/evidence/other/stage-i-cycle1-pins.<timestamp>.md`); `test_frozen_epic_surface_matches_pinned_baseline_digest` is read from the [P5-T5] gate.

### Phase 3 — Ledger Entry 0010

- [x] [P3-T1] Build the pre-0010 merged tree of `### Design Decision` in a scratch index and write `FEATURE/evidence/other/stage-i-cycle1-pre0010.<timestamp>.md`.
  - Resolve each `git merge-file` conflict as `### Design Decision` states: record that the path's 0010 pre-image blob equals its merge-base blob and take its `origin/main` blob; a conflicted path whose pre-image differs from its merge-base blob is returned as a finding.
  - Acceptance: the tree id is recorded; for each path, every line `origin/main` added since the merge base of the first parent and `origin/main` is present in the pre-0010 text; the pin values equal the SHA-256 of the pre-0010 surfaces; created paths are absent.
- [x] [P3-T2] Regenerate `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch` as `git diff --binary --no-renames <pre-0010 tree> HEAD` over the paths of 0010 `## Files Changed` other than the ledger folder, and update `docs/engineering/process-reductions/0010-early-dependent-starts.md`, in one commit whose subject carries `reduction: 0010`.
  - `## Stored Patch`: add a paragraph beginning "Regenerated against the merged base" that names PRs #1134 and #1135, states the derivation and why the later-landing rule does not apply; update the Revert Order paragraph for the #1129 and #1130 paths and the `0007` blocks.
  - `## Files Changed`: add any path a Phase 2 fix touched. `## Revert Steps`: step 4 restores the pre-0010 merged digests; step 6 adds main's tests that read a 0010 path (found by searching `tests/`). `## Revert Signals` keeps its four bullets.
  - Acceptance:
    - `git apply -R --check` of the patch exits 0 on the live tree.
    - Excluding the pin-file digest lines (and Phase 2 fix lines, listed), the `+` and `-` line multisets of the new patch equal those of the [P0-T2] patch.
    - `git log -1 --format=%s` contains `reduction: 0010`, and the entry contains `Regenerated against the merged base`.
- [x] [P3-T3] Run the ledger gates (script under `SCRATCH`) and write `FEATURE/evidence/other/stage-i-cycle1-ledger-gates.<timestamp>.md`.
  - Gates:
    - (a) `Test-ProcessReductionLedger` valid.
    - (b) `Invoke-ProcessReductionChain` over all 10 entries and with `-StopBefore` for each stored-patch entry: `IsValid` true, 0 errors.
    - (c) No end-state error, and every created path absent in `FinalText`.
    - (d) `Get-ProcessReductionLanding` returns only `first` for `0010`, matching README `## Revert Order`.
    - (e) `git apply --cached -R` of the patch on a scratch index of `HEAD` yields a tree equal to the [P3-T1] tree on every path of the patch (`git diff --quiet` of the two trees over those paths exits 0; the ledger folder differs by design after [P3-T2]).
    - (f) `git diff <merge commit first parent> HEAD` over entries `0001` to `0009` and their patches is empty.
  - A chain error in `0001` to `0009` caused by main's text is fixed per README `## Revert Order` under that entry's token and listed; no exception list and no skip.
  - Acceptance: `EXIT_CODE:` 0 only when all six gates pass.

### Phase 4 — Generated Variants

- [x] [P4-T1] Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` and write `FEATURE/evidence/other/stage-i-cycle1-codex-check.<timestamp>.md`.
  - Acceptance: exit 0 with no reported drift; on drift, run the generator without `--check`, commit the regenerated files, and re-run until exit 0.

### Phase 5 — Final QA

- [ ] [P5-T1] PowerShell static: PoshQC format in check mode and the direct analyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every `.ps1`/`.psm1` in 0010 `## Files Changed` and any Phase 2 fix; write `FEATURE/evidence/qa-gates/stage-i-cycle1-powershell-static.<timestamp>.md`.
  - Acceptance: `Already formatted:` for every file and no `Formatted:` line (files needing format: 0), `git status --porcelain` over those files empty afterwards, 0 analyzer findings, compared with the stage I static baseline.
- [ ] [P5-T2] Python static: Black in check mode, Ruff, and Pyright over the Python files in 0010 `## Files Changed` and any Phase 2 fix; write `FEATURE/evidence/qa-gates/stage-i-cycle1-python-static.<timestamp>.md`.
  - Acceptance: Black reports `would be left unchanged`, Ruff and Pyright 0 findings, compared with the stage I static baseline.
- [ ] [P5-T3] TypeScript static: Prettier check, ESLint, and `tsc --noEmit` in `extensions/drm-copilot/`; write `FEATURE/evidence/qa-gates/stage-i-cycle1-typescript-static.<timestamp>.md`.
  - Acceptance: 0 format differences, 0 lint errors, 0 type errors, compared with the stage I static baseline.
- [ ] [P5-T4] Run one `Invoke-PoshQCParallelTest` and write `FEATURE/evidence/qa-gates/stage-i-cycle1-powershell-test.<timestamp>.md`.
  - Counts from `artifacts/pester/pester-junit.xml` (shard files when `ExitCode` is non-zero), line coverage from `artifacts/pester/powershell-coverage.xml`.
  - Acceptance: `ExitCode` 0 and 0 failures; the `PRC-LEDGER-` tests, `PRL-REAL-LEDGER-AGREES`, the `EarlyStart` suites, `early-start-skill-contract.Tests.ps1`, and main's child-CI suites passed; `OrchestratorStateEpicWaveBarrier.psm1` and both `enforce-epic-wave-barrier.ps1` gates not below their baseline; both `epic-wave-barrier-early-start.ps1` siblings at least 85%; repo-wide not below 95.6% or each drop attributed per file to files only main changed.
- [ ] [P5-T5] Run one `pytest -n auto` with coverage (command shape of the stage I baseline) and write `FEATURE/evidence/qa-gates/stage-i-cycle1-python-test.<timestamp>.md`.
  - Acceptance: 0 failures; the push-down contract tests, `test_parallel_orchestrator_surface_contracts.py`, `test_epic_wave_barrier_early_start.py`, and `test_epic_wave_corpus_parity.py` passed; `_epic_orchestrator_state_wave_barrier.py` at 100% line and branch; repo-wide line and branch not below 97.11% and 94.36% or each drop attributed to files only main changed.
- [ ] [P5-T6] Run one Jest coverage run in `extensions/drm-copilot/` and write `FEATURE/evidence/qa-gates/stage-i-cycle1-typescript-test.<timestamp>.md`.
  - Acceptance: 0 failures; `epic-orchestrator-state-early-start.test.ts` passed; `epic-orchestrator-state-core.ts` not below its baseline; `epic-orchestrator-state-wave-barrier.ts` at least 85% line and 75% branch under its `coverageThreshold` entry; totals not below the baseline or each drop attributed to files only main changed.
- [ ] [P5-T7] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Rows include: both sides kept with no conflict marker; mirrors byte-identical; pins equal merged digests; 0010 patch reverses cleanly and the chain holds; entries `0001` to `0009` and README unchanged or each change listed with its token; no Epic #1019 or other item's folder edited; no tag, stash, or forced push; no baseline task, evidence, or comparison reduced; changed files at their baseline coverage.
  - Acceptance: no FAIL row; a FAIL is fixed and the loop restarts from [P5-T1].

## Pre-Mortem

- Review checklists: [P5-T7] walks all three templates against the merge-base diff, with explicit rows for both-sides resolution, mirrors, pins, the ledger chain, token-bearing commits, scope, and baselines.
- Coverage: [P5-T4] to [P5-T6] read per-file coverage of stage I's changed production files from the single gate runs against [P0-T1]; the two new stage I files are judged against the thresholds; a repo-wide drop is attributed per file, and only drops in files main alone changed are returned rather than failed.
- Mirror parity: [P1-T2] hash-checks every source and bundle pair after the merge, [P4-T1] runs the Codex generator `--check`, and the push-down contract tests are read from [P5-T5]. No CI job, required context, tool route, or batch-budget rule changes, so no brief-update task is owed; the brief changes only through main's merged text.
- File size: the merge adds text to Markdown skills and the agent file (exempt). `parallel_orchestrator_surface_expectations.py` changes only digest values. A Phase 2 fix to code adds a test in a new file when its target is near a tier.
- Test isolation: one `Invoke-PoshQCParallelTest` run ([P5-T4]), one `pytest -n auto` run ([P5-T5]), and Jest through its normal parallel workers ([P5-T6]), each re-run only after a fix; the ledger and pin checks are scripts, not test runs, and write only under `SCRATCH`.
- CI-only behavior: the regenerated patch is written by `git diff` with LF endings and never hand-reformatted, so the `eol=lf` rule keeps it intact; the chain suites run in the Windows PowerShell shards; a merge with code changes always gets a full CI run, and the stage I review follows CI on the merged head.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/` with a write-time stamp and the four required fields; `SCRATCH` appears only as a token; the stage I baselines are read, not reduced or re-captured.
