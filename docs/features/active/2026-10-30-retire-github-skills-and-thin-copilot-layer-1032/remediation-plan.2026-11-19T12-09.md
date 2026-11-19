# 2026-10-30-retire-github-skills-and-thin-copilot-layer - Remediation Plan (Cycle R1)

- **Issue:** #1032
- **Parent:** epic #1018, child 6
- **Branch:** `feature/retire-github-skills-and-thin-copilot-layer-1032`
- **Work Mode:** full-feature
- **Remediation-Mode:** proportionate (preflight and execution in one executor delegation)
- **Inputs:** `remediation-inputs.2026-11-19T12-09.md` in this folder (findings F1, F2, F3); `spec.md` (AC12, AC13, AC17, `## Named Sets`); the completed main plan `plan.2026-10-30T18-39.md` (its `## Terms`).
- **Trigger:** integration sync of `origin/epic/shared-agent-harness-layer-integration`, which carries #1029 (PR #1208), into this branch.

## Required References

- Policies: `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`.
- Tool routes, the test-execution launcher, command-text restrictions, CI shape and contract tests: `.claude/skills/execution-environment/SKILL.md` (not restated here).
- Evidence naming and stamping: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

## Terms

- `<FEATURE>`: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032`.
- Reused by name from the main plan `## Terms` and spec `## Named Sets`, unchanged: `RETIRED-SKILL-TREES`, `RETIRED-PATH`, `GUARD-SUITE`, `REGION-MAP`, `LEDGER-STEP`, `PUSH-DOWN-CONTRACT-TESTS`, `LEDGER-CHAIN-TESTS`, `PARALLEL-GATES`, `GATE-RUN`, `REMAINING-BRIEF-COPIES`, `REMAINING-CONTRACT-COPIES`, `STALE-REFERENCE-CLASSES`, `COPILOT-AGENT-FILES`.
- `IMB`: the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD`, derived after a fetch at each use (orchestrator decision AD-7); no commit identifier is recorded.
- `SYNC-MERGE`: the newest merge commit on this branch whose second parent is reachable from `origin/epic/shared-agent-harness-layer-integration`; it is located by `git log --merges` at run time and recorded only by its subject.
- `MERGE-DELTA`: the files added or modified between the first parent of `SYNC-MERGE` and `SYNC-MERGE`.
- `COPILOT-MANIFESTS`: every `*.json` file under `extensions/drm-copilot/resources/customizations/pack-manifests/`; at planning time `core.json`, `csharp.json`, `powershell.json`, `python.json`, `typescript.json`.
- `REMAINING-COPILOT-ROOTS`: `.github/agents`, `.github/prompts`, `.github/hooks`, `.github/instructions`, and the file `.github/copilot-instructions.md`.
- `SCRATCH`: `<session scratchpad>/issue-1032/`; scratch file names start with `issue-1032-r1-`; artifacts record the token `SCRATCH`, never a host path.
- Every artifact this plan writes is `<name>.<timestamp>.md`, stamped from the clock at write time (`date -u`), append-only, and carries `Plan: remediation-plan.2026-11-19T12-09.md`; a consumer takes the lexicographically greatest match carrying that `Plan:` value. Command artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`.
- A Phase 0 task that finds a premise mismatch writes `blocked: premise_falsified` with the item into its artifact, stays unchecked, and stops the run.

## Planning-Time Observations (re-checked by Phase 0)

- `RETIRED-PATH` entries in `COPILOT-MANIFESTS`: `core.json` 48, `csharp.json` 2 (`csharp-change-budget-router`, `csharp-orchestration-state-machine`), `powershell.json` 2 (`powershell-change-budget-router`, `powershell-orchestration-state-machine`), `python.json` 0, `typescript.json` 0. No file under either `RETIRED-SKILL-TREES` tree exists in the merged tree.
- Generator: no generator writes `COPILOT-MANIFESTS`. `scripts/dev_tools/generate_codex_agent_variants.py` (`PACK_ROOT`) writes only the Codex bundle manifest, and `scripts/harness-generation/` names no Copilot manifest; #1029 created the files by a hand-run scratch script (its P2-T1 and P4-T2 task checks). They are therefore hand-edited.
- Merged production roots: `COPILOT_ROOT_FOLDERS` in `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` and `ROOT_FOLDERS` in `scripts/dev_tools/agentic_sync.py` each list the four `.github` sub-roots of `REMAINING-COPILOT-ROOTS` and no retired root; no module under `extensions/drm-copilot/src/lib/push-down/` holds `RETIRED-PATH`.
- Tests that read or seed Copilot manifests, with disposition for the F1 edit:
  - `extensions/drm-copilot/test/lib/push-down/push-down-bundle-manifest-completeness.test.ts`, `lists every Copilot bundle file` and `enumerates a non-empty bundle tree`: unchanged, unaffected. They assert that every bundle file under `COPILOT_ROOT_FOLDERS` is listed, not that every listed path exists, and the edit removes only entries whose files are absent.
  - `GUARD-SUITE` `CLR-PACK-MANIFESTS`: unchanged. It already scans `customizations/pack-manifests`, fails on the merged head (the fail-before state of F1), and passes after the edit.
  - `extensions/drm-copilot/test/lib/push-down/push-down-pipeline.test-helpers.ts`, `push-down-service-call.test.ts`, `push-down-pack-resolver.test.ts`: unchanged, unaffected; they seed in-memory manifests and read no committed manifest.
  - `PUSH-DOWN-CONTRACT-TESTS`: unchanged, unaffected; they read the Claude and Codex bundles only.
- `docs/engineering/process-reductions/` holds no `COPILOT-MANIFESTS` path, so `LEDGER-STEP` is expected not to apply.

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| `COPILOT-MANIFESTS` | Edit (remove entries) | JSON data, bundle-only; no code |
| Tests named `update` by Phase 0, if any | Edit in place | Existing TypeScript, PowerShell or Python tests; tolerated |
| Generator checks, gates, searches | Run only | Existing tools |
| Verification helpers | Not committed | PowerShell or `sh` under `SCRATCH` |

No artifact adds Python; no pushed-down file becomes TypeScript or Python; no hook is edited.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Merged-Head Baseline

- [x] [P0-T1] Manifest and test inventory on the merged head: (a) for each pack manifest under `extensions/drm-copilot/resources/*/pack-manifests/`, run a fixed-string search for `RETIRED-PATH` (built from its parts) and list every matching entry by manifest; (b) confirm every `COPILOT-MANIFESTS` file parses as JSON and record its `paths` count and its count of entries under `REMAINING-COPILOT-ROOTS`; (c) decide `Generated: yes|no` by searching `scripts/` and `extensions/drm-copilot/src/` for a writer of `customizations/pack-manifests`, naming the generator and its check mode when `yes`; (d) search `tests/` and `extensions/drm-copilot/test/` for the manifest file names under `customizations/pack-manifests`, `COPILOT_BUNDLE`, `COPILOT_PACK_NAMES`, `RETIRED-PATH`, and the four pack-scoped skill names, and record each matching test with disposition `unchanged (unaffected)`, `unchanged (fails before, passes after)` or `update` with the reason; (e) check `REGION-MAP` and `docs/engineering/process-reductions/` for any `COPILOT-MANIFESTS` path.
  - Acceptance: `<FEATURE>/evidence/baseline/r1-manifest-inventory.<timestamp>.md` lists every retired-path entry per manifest with counts, `Generated:` with its evidence, per-manifest `paths` and remaining-root counts, every matching test with its disposition, and `LedgerRegion: none|<entries>`; a difference from `## Planning-Time Observations` in the generator decision, or a test that asserts a manifest entry count, records `blocked: premise_falsified` unless the task records that test as `update` with a reason.
- [x] [P0-T2] Merge-delta inventory: locate `SYNC-MERGE` and list `MERGE-DELTA` with each file's status; search `COPILOT_ROOT_FOLDERS`, `agentic_sync.ROOT_FOLDERS`, every module under `extensions/drm-copilot/src/lib/push-down/` and every `MERGE-DELTA` test file for `RETIRED-PATH`; list each `REMAINING-BRIEF-COPIES` and `REMAINING-CONTRACT-COPIES` file that `MERGE-DELTA` contains, with its `git hash-object` value.
  - Acceptance: `<FEATURE>/evidence/baseline/r1-merge-inventory.<timestamp>.md` records the `SYNC-MERGE` subject, the `MERGE-DELTA` file list and count, `EngineRetiredRoot: absent|present`, `SyncRetiredRoot: absent|present`, every `MERGE-DELTA` test that holds `RETIRED-PATH` with disposition `generic-input`, `example` or `update`, and the brief and contract copies the merge touched (or `none`).
- [x] [P0-T3] Run the `Phase 0 baseline` of each gate of `PARALLEL-GATES` on the merged head: one pytest `GATE-RUN` with line and branch coverage and a JSON report under `SCRATCH`, one Jest `GATE-RUN` of `extensions/drm-copilot` with coverage, one Pester `GATE-RUN` over the scan folders of `config/poshqc-scan.json`. A launcher exit 75 is a queue timeout, re-run after the holder finishes.
  - Acceptance: `<FEATURE>/evidence/baseline/r1-pytest-baseline.<timestamp>.md`, `r1-jest-baseline.<timestamp>.md` and `r1-pester-baseline.<timestamp>.md` each record the pass and fail counts, every failing test by name, and repository-wide coverage; the pytest artifact records line and branch coverage of `scripts/dev_tools/agentic_sync.py` from the JSON report and the pass state of `test_agentic_sync.py`, `test_agentic_sync_artifacts.py`, `test_push_down_copilot_customizations.py` and `test_push_down_copilot_customizations_rewrites.py`; the Jest artifact records line and branch coverage of `src/lib/push-down/copilot-customizations-engine.ts` and the pass state of `copilot-customizations-engine.test.ts` and `push-down-bundle-manifest-completeness.test.ts`; the Pester artifact records `ExitCode`, the failing state of `CLR-PACK-MANIFESTS finds no retired path in any pack manifest` (fail-before for F1), and the pass state of `LEDGER-CHAIN-TESTS`.

### Phase 1 — Manifest Fix, Re-Verification and Final QA

The fix and the final QA loop share one phase, so the final QA loop is the only full gate after the edit (orchestrator directive OD-4, cost-benefit: a separate phase gate would repeat all three `PARALLEL-GATES` runs on a data-only change).

- [ ] [P1-T1] F1: in every `COPILOT-MANIFESTS` file that P0-T1 lists with a retired-path entry (at planning time `extensions/drm-copilot/resources/customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/customizations/pack-manifests/csharp.json`, `extensions/drm-copilot/resources/customizations/pack-manifests/powershell.json`), remove each entry naming a path under `RETIRED-SKILL-TREES`, keeping every other entry, its order, the `name` and `label` fields, and valid JSON; when P0-T1 records `Generated: yes`, regenerate with the named generator and run its check mode instead of hand-editing. `LEDGER-STEP` applies only when P0-T1 records a `LedgerRegion` other than `none`. Asserting tests and dispositions: `CLR-PACK-MANIFESTS finds no retired path in any pack manifest` passes after the edit (unchanged); `lists every Copilot bundle file` and `enumerates a non-empty bundle tree` unchanged and passing; every other test as P0-T1 records it. Task check: the `GUARD-SUITE` file through the launcher `pester` suite with `-TestPath`, the Jest selection `push-down-bundle-manifest-completeness.test.ts` and `push-down-pack-resolver.test.ts`, and `PUSH-DOWN-CONTRACT-TESTS`.
  - Acceptance: a fixed-string search of every `extensions/drm-copilot/resources/*/pack-manifests/*.json` file for `RETIRED-PATH` returns zero matches; each edited manifest's `paths` count equals its P0-T1 count minus its removed entries, and its count of entries under `REMAINING-COPILOT-ROOTS` equals the P0-T1 count; the task check passes and is recorded in `<FEATURE>/evidence/other/task-check.P1-T1.<timestamp>.md`.
- [ ] [P1-T2] F1 and F2 test follow-through: update every test under `tests/` or `extensions/drm-copilot/test/` that `<FEATURE>/evidence/baseline/r1-manifest-inventory.<timestamp>.md` (P0-T1) or `<FEATURE>/evidence/baseline/r1-merge-inventory.<timestamp>.md` (P0-T2) records as `update` (a test that asserts a removed manifest entry or count, or a #1029 test that pins `RETIRED-PATH` outside the `generic-input` and `example` classes), building `RETIRED-PATH` at runtime from its parts in any test that must name it; when neither artifact records an `update`, this task makes no edit and records `TestUpdates: none` with the two artifact names (an authorized no-edit branch). The task check runs each updated test with `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/other/task-check.P1-T2.<timestamp>.md` names each updated test with its reason and passing result, or records `TestUpdates: none`; no updated test holds `RETIRED-PATH` as a literal.
- [ ] [P1-T3] Final static loop and generator checks: Prettier check, ESLint and `typecheck` when P1-T2 edited a TypeScript test; PSScriptAnalyzer with the repository settings and the formatter comparison when it edited a PowerShell test; Black check, Ruff and Pyright when it edited a Python test; a JSON parse of each `COPILOT-MANIFESTS` file; the Codex generator check (`scripts/dev_tools/generate_codex_agent_variants.py` with `--check`); child 3's generator check (`scripts/harness-generation/Invoke-HarnessGeneration.ps1` with `-Surface skills -Check`), whose clean run prints `harness-generation: no drift`; and the P1-T1 manifest search. Restart from the format step on any failure or change.
  - Acceptance: `<FEATURE>/evidence/qa-gates/r1-final-static.<timestamp>.md` records each applicable step's command, exit code 0 and zero findings, or `no file of this language changed` per language; `<FEATURE>/evidence/qa-gates/r1-contract-checks.<timestamp>.md` records the five JSON parses as valid, both generator checks with exit code 0 and the printed `harness-generation: no drift`, and zero manifest matches over every bundle's manifests.
- [ ] [P1-T4] F3 re-verification on the post-fix head: repeat the AC13 fixed-string search for `RETIRED-PATH` over tracked files outside `docs/features/` and classify every hit with a class of `STALE-REFERENCE-CLASSES` other than `example`, marking each hit in a `MERGE-DELTA` file; compare the `git hash-object` values of all `REMAINING-BRIEF-COPIES` with each other and of all `REMAINING-CONTRACT-COPIES` with each other, and confirm each brief copy states the four-copy facts S1 to S5 and each contract copy the S6 target `in all four byte-identical copies`.
  - Acceptance: `<FEATURE>/evidence/other/stale-reference-classification.<timestamp>.md` lists every hit with its class, zero unclassified, none in a `COPILOT-AGENT-FILES` file, and the count of `MERGE-DELTA` hits; `<FEATURE>/evidence/qa-gates/r1-brief-copy-facts.<timestamp>.md` records one hash value per copy set (all copies equal) and `holds` for each S1 to S6 check.
- [ ] [P1-T5] Final QA gates: one pytest `GATE-RUN` with line and branch coverage and a JSON report under `SCRATCH`, one Jest `GATE-RUN` of `extensions/drm-copilot` with coverage, and one Pester `GATE-RUN` over the scan folders of `config/poshqc-scan.json`; a failure is fixed and the loop restarts at P1-T3. Integration and golden lanes run in CI only.
  - Acceptance: `<FEATURE>/evidence/regression-testing/r1-pytest-final.<timestamp>.md` records zero failures, the pass count, repository-wide coverage, `agentic_sync.py` line and branch coverage, and every `PUSH-DOWN-CONTRACT-TESTS` module and the four F2 modules in the passing set; `r1-jest-final.<timestamp>.md` records zero failures, the pass count, `copilot-customizations-engine.ts` line and branch coverage, and `copilot-customizations-engine.test.ts` and `push-down-bundle-manifest-completeness.test.ts` passing; `r1-pester-final.<timestamp>.md` records `ExitCode` 0, zero failures, repository-wide line coverage, and passes for `GUARD-SUITE` (including `CLR-PACK-MANIFESTS finds no retired path in any pack manifest`), `LEDGER-CHAIN-TESTS` and `FileSizePolicy.RepoGate.Tests.ps1`.
- [ ] [P1-T6] Coverage note: list the files this cycle changed, from the diff of `SYNC-MERGE` and `HEAD` together with `git status --porcelain`, classify each as production code, test, data or document, and compare the P0-T3 and P1-T5 figures for `scripts/dev_tools/agentic_sync.py` and `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` and repository-wide.
  - Acceptance: `<FEATURE>/evidence/qa-gates/r1-coverage-note.<timestamp>.md` records each changed file with its class and either `no production code file changed` or, per changed production file, final line coverage of at least 85% and branch coverage of at least 75% (line only for PowerShell) with zero uncovered added or modified lines; repository-wide coverage and the per-file coverage of `agentic_sync.py` and `copilot-customizations-engine.ts` show no drop from the `Phase 0 baseline`; no added `*.py` file.
- [ ] [P1-T7] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from `IMB`, with F1 to F3 and AC12, AC13 and AC17 each checked against its evidence.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` carries `Plan: remediation-plan.2026-11-19T12-09.md` and one PASS, FAIL or N/A row per checklist item with no FAIL row; a FAIL is fixed and the loop restarts at P1-T3 before a new file is written.

## Finding Traceability

| Finding or criterion | Implementing task | Check that fails if broken |
| --- | --- | --- |
| F1 retired entries in Copilot manifests; AC12 manifest clause | P0-T1, P1-T1, P1-T2 | `CLR-PACK-MANIFESTS finds no retired path in any pack manifest`; P1-T1 manifest search |
| F1 remaining Copilot surfaces kept | P1-T1 | `lists every Copilot bundle file`; remaining-root count equality |
| F1 generated-manifest branch | P0-T1, P1-T1 | `Generated:` record; generator check in P1-T3 |
| F2 merged engine and sync roots; AC12 engine and push-down clause | P0-T2, P0-T3, P1-T2, P1-T5 | `copilot-customizations-engine.test.ts`; the four F2 pytest modules |
| F3 guard, contract, generator and ledger checks | P1-T3, P1-T5 | `GUARD-SUITE`; `PUSH-DOWN-CONTRACT-TESTS`; both generator checks; `LEDGER-CHAIN-TESTS` |
| F3 stale references in merge-added files; AC13 | P0-T2, P1-T4 | classification record with zero unclassified |
| F3 brief and contract copy facts | P1-T4, P1-T5 | `test_brief_copies_are_byte_identical`; `CLR-BRIEF-COUNT holds every count target in each remaining brief and contract copy` |
| AC17 parallel gates | P0-T3, P1-T5 | gate records |

## Pre-Mortem

- Review checklists: likely findings are a manifest entry for a remaining Copilot surface removed by mistake, an unrecorded test disposition, and an unclassified stale reference from a merge-added file; P1-T1 asserts remaining-root counts, P0-T1 records each test's disposition, P1-T4 classifies every hit, and P1-T7 walks all three templates.
- Coverage: the cycle changes JSON data, plus only the tests Phase 0 names; P0-T3 and P1-T5 read per-file figures from single gate runs and P1-T6 states the result, applying 85% line and 75% branch to any changed production file.
- Mirror parity: `COPILOT-MANIFESTS` exist only in the bundle and have no mirror; no fact of the execution-environment brief changes (no CI job, required context, tool route or batch-budget rule), so no brief-update task is needed, and P1-T4 re-confirms that the brief copies and the contract copies each stay byte-identical after the merge.
- File size: JSON entries are removed and no file grows beyond a test edit Phase 0 names; `FileSizePolicy.RepoGate.Tests.ps1` runs in the Pester gate of P1-T5.
- Test isolation: `PARALLEL-GATES` only, through the test-execution launcher: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` and Jest through its normal workers, at baseline and at final QA, each re-run only after a fix; no serial, single-process, shuffled or reversed run; a found order dependence is fixed on both sides.
- CI-only behavior: `ProcessReductionChain.Ledger.Tests.ps1` and the file-size gate run in the PowerShell shards and in the local Pester gate; `GUARD-SUITE` reads committed files through `Join-Path` with exact-case forward-slash paths; no test diffs against an `origin` ref.
- Evidence: every task names its artifact under `<FEATURE>/evidence/<kind>/`, stamped from the clock at write time, append-only, with `Plan: remediation-plan.2026-11-19T12-09.md`; the `r1-` prefix keeps these artifacts apart from the main plan's; scratch locations are recorded as `SCRATCH`; no receipt id or time is composed.
