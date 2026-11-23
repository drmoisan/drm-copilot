# Research: Targeted Test Cadence (Issue #1228)

- Issue: #1228
- Branch: `feature/targeted-test-cadence-1228`
- Worktree read: the item worktree only, at its committed state.
- Research stamp: `2026-11-23T12-00` (no clock reading was available to this agent; the fallback stamp from the delegation was used).
- Owner directive (2026-11-23, verbatim): "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests. this change should be reflected in every rule that operates otherwise for all orchestrators."
- Owner directives block: none was supplied in the delegation, so no `OWNER-DIRECTIVE-DECISION:` line is recorded.

## 1. Current State Analysis

### 1.1 The single definition of the cadence

`## Test Cadence (Mandatory)` in `.claude/skills/atomic-plan-contract/SKILL.md` and in `.agents/skills/atomic-plan-contract/SKILL.md` (two hand-authored files whose text differs elsewhere) defines:

- **Task check (after each task).** Format, lint, and type check scoped to the changed files, then "the task's test selection": the mirrored test files of each changed production file, plus every test file that imports, dot-sources, or names a changed module or file, plus the contract tests that read a changed Markdown or configuration path. Pester selection runs through the launcher `pester` suite with `-TestPath`. Not a gate; no coverage.
- **Phase gate (after each phase).** Current wording: "That task runs stages 1 to 6 of the toolchain loop across the repository: format, lint, type check, architecture-boundary tests, the full unit suite, and contract checks. The unit stage is one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers." This is the primary text the owner directive reverses.
- **Expect-fail phase.** "Its `[phase-gate]` task still runs the full loop".
- **Final QA loop (unchanged)** and **CI-only suites** bullets.

Every other surface restates one sentence that points back to this section: "Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop." Its occurrence count is derived in `## Numeric Derivation Evidence` (156 occurrences in 112 files outside `.dev/`).

### 1.2 Other places a full run happens today outside Phase 0 and final QC

| Place | Current behavior | Source |
|---|---|---|
| `[phase-gate]` task | Full unit suite through each parallel gate | `## Test Cadence (Mandatory)` |
| Remediation cycle plan | Its own `Phase 0 baseline` test-suite run and its own full final QA loop | `## Plan Shape` of `remediation-handoff-atomic-planner` |
| Regenerate path of a merge conflict (main sync, integration sync) | "runs the standard parallel unit gates when unit_gate is not_run" | item 5 of `## Merge-Conflict Remediation` in `.claude/skills/orchestrate/SKILL.md` |
| Epic early-start sync (integration sync) | "8. Child: re-run the local gate" (undefined term, read as the full gate) | `## Early Dependent Starts (early_start)` of both `epic-orchestrate` skills |
| QA-gate skills | Applied "at a phase gate or the final QA loop"; run the full toolchain with coverage | `## When to Use This Skill` of the python, powershell, csharp `*-qa-gate` skills |
| Typed engineers in the small path | Item 5 "Final QA gate — apply `<lang>-qa-gate` to run the full toolchain", then the minimal plan's Final QC block runs the full loop again | `## Workflow` of the three typed-engineer agent sources; `## Short-Path Minimal Plan Contract` |
| Feature review coverage step | Runs full launcher coverage runs when the executor's reports are absent; the review coverage hook marks a report stale when it predates the newest commit touching that language, so in an item worktree the pre-review commit and the pre-R4 commit force a full re-run at every review | step 5 of `feature-review-workflow`; `.claude/hooks/validate-feature-review-coverage-freshness.ps1` (`Get-FeatureReviewCoverageFreshnessDecision`) |

Epic main sync and the epic post-merge flow run no local tests (they dispatch CI); the parallel merge-on-green re-runs S9 (CI) only. CI is unchanged by this item.

### 1.3 Enforcement surfaces checked and found not to pin the cadence

- No hook under `.claude/hooks/`, `.claude/lib/`, or `.codex/hooks/` contains `phase-gate`, `phase gate`, or the restated sentence (Grep over those trees: no match).
- The Python plan validator (`scripts/dev_tools/validate_orchestration_artifacts.py` and its rules) and the TypeScript twin under `extensions/drm-copilot/src/` contain no `phase-gate` or `phase_gate` token (Grep: no match outside harness sources and the contract test).
- The planner and executor SubagentStop hooks do not inspect `[phase-gate]` content; the `task checkbox` hits in `validate-planner-output.Tests.ps1` and `validate-executor-output*.Tests.ps1` are unrelated.
- The Python atomic executor CLI (`scripts/dev_tools/atomic_executor/qc_runner.py`, `QCRunner.run_scoped` and `run_full`; `cli.py` "Phase {cur.phase} complete -> running full toolchain") runs a full toolchain per phase. It is a repository-local developer tool, not bundled for push-down. See decision D6.

## 2. Candidate Approaches

### Approach A (recommended): redefine the cadence once, then update every restatement and every independent full-run instruction

Rewrite the `Phase gate` and `Expect-fail phase` bullets of `## Test Cadence (Mandatory)` so the unit stage is the union of the phase's task test selections, add bullets for remediation cycles and sync checks, and replace the restated sentence everywhere with one new sentence. Update the independent instructions listed in 1.2 (except the frozen epic surfaces, see D5). Regenerate generated targets and Codex variants, hand-copy bundles of hand-authored files, update the pinned test literals, and record ledger entry `0014`.

- Advantages: one canonical definition stays authoritative; every surface stays a pointer; matches the #1167 pattern (`0011`), so the same contract test and ledger machinery apply; no production code changes; the epic hash pin is untouched.
- Limitations: large file count (mostly derived); wording must avoid the swept tokens (D7).

### Rejected alternatives

- **Change only `## Test Cadence (Mandatory)` and leave restatements.** Every restatement says "the full toolchain loop at each phase gate", so agents reading a rule or agent file would keep running full suites; it fails AC2 ("No rule ... still requires a full-suite run").
- **Enforce the cadence in a hook (deny a full launcher run outside Phase 0/final QC).** The hook cannot know the plan phase without new checkpoint state; adds PowerShell production code on four copies (batch budget) and a new enforcement surface; disproportionate to a wording change.
- **Edit the Python atomic executor CLI to run selections at phase end.** Python edits in a tool that is not pushed down; out of the owner's scope ("rule ... for all orchestrators"). See D6.

## 3. Behavior Semantics (target)

- **Full suite runs exactly twice per orchestration:** the `Phase 0 baseline` (one run of each parallel gate with coverage) and the final QA loop (one run of each gate with coverage, compared with the baseline). CI is unchanged.
- **Task check:** unchanged.
- **Phase gate:** stages 1 to 6. Format, lint, type check, architecture-boundary tests, and contract checks stay repository-wide. Stage 5 (unit) runs the union of the test selections of the phase's tasks, in parallel through the launcher: the launcher `pester` suite with `-TestPath <union>` (one `Invoke-PoshQCParallelTest` run), the launcher `pytest` suite with the union files (one `pytest -n auto` run), and the launcher Jest suite with the union test paths (Jest through its normal parallel workers). No coverage is measured. A language whose union is empty records "no selected tests" for its unit stage. Restart-from-step-1 and one-clean-pass are unchanged. Evidence path unchanged: `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`, which also records the union and the rule that produced it.
- **Expect-fail phase:** the gate's unit stage passes when its only failures are the plan's named `[expect-fail]` tests (they are in the selection by construction), each confirmed failing, and every other selected test passes.
- **Remediation cycle (D2):** task checks per task; the cycle ends with one remediation gate in the phase-gate form (repo-wide static, architecture, contract; unit stage over the union of the cycle's task selections), run in coverage mode for each changed language so per-file coverage of the files the cycle changed is recorded. No `Phase 0 baseline` re-run: the remediation plan's Phase 0 captures static baselines only and cites the orchestration's `Phase 0 baseline` artifact. Light cycles are unchanged (task checks only).
- **Sync checks (D5, D9):** after a merge of `origin/main`, an integration branch, or an upstream branch into a feature or integration branch (main sync, integration sync, early-start sync, regenerate path), the local gate is the phase-gate form whose unit stage is the test selection of the paths the merge changed on either side since the merge base.
- **Review coverage (D3):** the reviewer reads the final-QC artifacts; when a coverage report is absent or stale for a changed language, it re-runs coverage only over the branch's test selection (initial review: union of all task selections of the plan; R4: the cycle's selection), not the full suite. The repo-wide total comes from the final-QC artifact and the CI result recorded in `## CI Cross-check`.
- **Failure conditions:** any full-suite instruction outside Phase 0 and final QC on any surface is a defect found by the extended sweep (section 5).

### Decisions (one recommended option each)

| ID | Decision | Recommended | Reason |
|---|---|---|---|
| D1 | Phase-gate unit stage | Union of the phase's task selections, parallel launcher runs, no coverage | Directly states the owner rule; reuses the existing selection rule and launcher `-TestPath` route |
| D2 | Remediation cycle tests | Remediation gate in phase-gate form, coverage mode for changed files; no per-cycle `Phase 0 baseline` run; alternative "full QA loop per cycle" rejected because the objective lists remediation cycles as targeted | Coverage of changed files is still measured; repo-wide backstop is the final-QC artifact and CI |
| D3 | Review coverage re-run | Re-run over the branch's selection when the freshness hook would block; no hook code change | A selection run refreshes the report files the freshness hook reads (`artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `coverage/lcov.info`), so the hook is satisfied without a full run; keeps zero PowerShell production edits |
| D4 | Typed engineers inside an orchestration | One sentence in `## Workflow` item 5 of the three typed-engineer agent sources: when the delegation comes from an orchestration whose plan carries a `Phase 0 baseline` and a final QC block, the engineer runs the task check and leaves the full gate to the plan's final QA loop; standalone direct mode keeps its own Phase 0 and final QA gate | Removes the duplicate full run in the small path; standalone use already brackets its own run with a beginning and a QC run |
| D5 | Epic "re-run the local gate" | Do not edit the epic surfaces; define "local gate" for sync checks in `## Test Cadence (Mandatory)` (and the brief) | `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` are frozen by `PINNED_FROZEN_SURFACE_HASHES`; a definition elsewhere makes the existing term targeted without a re-baseline |
| D6 | Python atomic executor CLI | Out of scope; record in the ledger entry as unchanged | Not pushed down; the brief's `## Test Runtime` bullet that describes it ("its phase-gate QC loop", pinned) stays accurate |
| D7 | Vocabulary | Use "test selection" / "selected tests"; never "targeted tests", "targeted Pester", "targeted Pytest", "targeted xUnit", "targeted MSTest" | Those tokens are banned by both contract sweeps (section 5) |
| D8 | Ledger record form | New entry `0014-targeted-test-cadence.md` with `## Stored Patch` (precedent `0009`) | The restated sentence occurs twice in several files, so a `Current` fence must be made unique by context; a stored patch avoids that class of chain failure |
| D9 | Regenerate-path fallback gate | Replace "the standard parallel unit gates" with the phase-gate unit stage over the selection of the paths the merge changed | Satisfies "regeneration-path unit gates" in the objective; `config/orchestration-regeneration.json` `unit_gate` argv stays repository-owned |
| D10 | Copilot standalone agents (staged-review, commentary-remediation, remediate-comments prompt, Copilot typed and DI/pytest engineers' Phase D) | No change | Not orchestrator steps; each brackets its own standalone run; several rows are pinned by `parallel-gate-wording.Tests.ps1` to `poetry run pytest -n auto` |

## 4. Inventory (Question 1, 2, 6)

Classification key: **SRC-H** = source for `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; **GEN-H** = generated by that script (it also writes the bundle copy of every generated target, `Get-HarnessBundlePath` in `HarnessGeneration.psm1`); **GEN-V** = generated by `scripts/dev_tools/generate_codex_agent_variants.py` (variants `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` and their bundle copies); **HAND** = hand-authored, no generator; **BUNDLE-HAND** = byte-identical bundle copy made by hand (checked by the push-down contract tests and `TCW-BUNDLE-*` rows); **VARIANT-HAND** = bundle-only variant with its own text. Classifications come from `config/harness-parity-matrix.json` (`disposition`, `generated_from`, `generator`).

### 4.1 Must change

| # | Path (canonical) | Section | Current wording (short quote) | Class | Derived copies |
|---|---|---|---|---|---|
| 1 | `.claude/skills/atomic-plan-contract/SKILL.md` | `## Test Cadence (Mandatory)` (Phase gate, Expect-fail bullets; add remediation and sync bullets); restated sentence in `## Short-Path Minimal Plan Contract` and `## Final QA Loop (Required for Code/Test Changes)` | "the full unit suite"; "still runs the full loop" | HAND (claude native) | bundle `claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` (BUNDLE-HAND) |
| 2 | `.agents/skills/atomic-plan-contract/SKILL.md` | same three places | same | HAND (codex shared; text differs from #1) | bundle `codex-and-agents-customizations/.agents/...` |
| 3 | `scripts/harness-generation/sources/rules/general-code-change.md` | `## Mandatory Toolchain Loop` ("at phase gates and in the final QA loop, stage 7 runs in CI" kept; restated sentence); `## Bugfix Workflow` step 3; `## 8. After Making Changes` / `### 1. Run the full toolchain (no shortcuts)` | restated sentence (3 occurrences) | SRC-H | `.claude/rules/general-code-change.md`, `.agents/skills/general-code-change/SKILL.md`, `.github/instructions/general-code-change.instructions.md` + three bundles (GEN-H) |
| 4 | `sources/rules/python.md`, `powershell.md`, `typescript.md`, `csharp.md`, `shell.md` | `## Toolchain` paragraph | restated sentence (python 2, csharp 2, others 1) | SRC-H | `.claude/rules/<lang>.md`, `.agents/skills/<lang>/SKILL.md` (no `.agents` shell skill) + bundles (GEN-H) |
| 5 | `sources/agents/atomic-executor.md` | `## Execution Protocol` step 4; `## Toolchain Commands` | "a `[phase-gate]` task runs the full toolchain loop instead" + restated | SRC-H | `.claude/agents/atomic-executor.md`, `.codex/agents/atomic-executor.toml` + bundles (GEN-H); five variants + bundles (GEN-V) |
| 6 | `sources/agents/atomic-planner.md` | `## Plan Structure` "Phase gates:" bullet (Claude); `## Requirements` item 6 (Codex) | restated sentence | SRC-H | `.claude/agents/atomic-planner.md`, `.codex/agents/atomic-planner.toml` + bundles; variants (GEN-V) |
| 7 | `.agents/skills/remediation-handoff-atomic-planner/SKILL.md` | `## Plan Shape` | "Phase 0 captures ... the `Phase 0 baseline` test-suite run"; "Final phase runs the full toolchain QA loop" | SRC-H (claude copy generated, matrix `generated_from`) | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` + bundles (GEN-H) |
| 8 | `.agents/skills/execution-environment/SKILL.md` | `## Test Isolation Checks` (add phase-gate selection and sync-check bullets); `## Contract Tests That Pin Mirrored Files` (`test-cadence-wording.Tests.ps1` description if the suite is extended) | "The test gates are parallel" list has no phase-gate selection | SRC-H | `.claude/skills/execution-environment/SKILL.md` + two bundles (GEN-H); brief maintenance rule requires all four copies |
| 9 | `.agents/skills/test-execution-policy/SKILL.md` | `### Scoped Pester runs` | "A task check, a fail-before proof, and a consumer-suite check run their Pester selection" (add phase gate and remediation gate) | SRC-H | `.claude` copy + bundles (GEN-H) |
| 10 | `.claude/skills/orchestrate/SKILL.md` | `## Delegation Model` (`atomic-executor` bullet); `## Remediation Loop (R1–R5)` R3; `## Merge-Conflict Remediation` item 5 | restated (2); "runs the standard parallel unit gates when unit_gate is not_run"; "the standard parallel gates pass" | HAND | BUNDLE-HAND |
| 11 | `.agents/skills/orchestrate/SKILL.md` | `## Delegation Model`; `## Remediation Loop` R3 (no regenerate path in Codex) | restated (2) | HAND | BUNDLE-HAND |
| 12 | `.claude/skills/{python,powershell,csharp}-qa-gate/SKILL.md` and `.agents/skills/{python,powershell,csharp}-qa-gate/SKILL.md` | `## When to Use This Skill` | "An executor has reached a phase gate or the final QA loop" + restated | HAND (shared pairs) | BUNDLE-HAND each |
| 13 | `claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`, `.../.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, `codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`, `.../.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | `## Toolchain`; `## When to Use This Skill` | restated / "a phase gate or the final QA loop" | VARIANT-HAND | none |
| 14 | `.agents/skills/atomic-executor/SKILL.md` | `## Execution Rules` item 3 | "a `[phase-gate]` task runs the full toolchain loop instead" + restated | HAND | BUNDLE-HAND |
| 15 | `.agents/skills/atomic-planner/SKILL.md` | `## Plan Requirements` paragraph | restated sentence | HAND | BUNDLE-HAND |
| 16 | `.github/agents/atomic_executor.agent.md` | `## 0. Highest Priority: Repository Policy Compliance (Non-Negotiable)` ("Toolchain loop:" bullet); `### 3.4 Verification (mandatory before check-off)` | "as the full loop at each phase gate"; "runs the full toolchain loop instead" | HAND (copilot native) | BUNDLE-HAND (`resources/customizations/.github/...`) |
| 17 | `.github/agents/{python,powershell,csharp}-atomic-executor.agent.md` | same two places + `### 7.1 <Lang> policy and toolchain gates` ("Phase-gate and final-QA toolchain for <Lang> ..." and its test step) | same, 3 occurrences each | HAND | BUNDLE-HAND |
| 18 | `.github/agents/atomic_planning.agent.md`, `python-atomic-planning.agent.md`, `powershell-atomic-planning.agent.md`, `csharp-atomic-planning.agent.md` | the "every phase between Phase 0 and the final QA phase MUST end with a `[phase-gate]` task" bullet | restated sentence | HAND | BUNDLE-HAND |
| 19 | `.github/prompts/execute-hard-lock.prompt.md`, `.github/codex/execute-hard-lock.prompt.md`, `.github/codex/resume-hard-lock.prompt.md` | numbered step "Run the task check; a `[phase-gate]` task runs the full toolchain loop instead." | same + restated | HAND | BUNDLE-HAND |
| 20 | `AGENTS.md` | `## Mandatory Toolchain Loop` | restated sentence | HAND | BUNDLE-HAND (`codex-and-agents-customizations/AGENTS.md`; `BUNDLE-DRIFT` check in `HarnessInstructions.psm1`) |
| 21 | `.dev/templates/{bug,feature,refactor}/plan.yyyy-MM-ddTHH-mm.md` | the `[phase-gate]` task lines | "Run the full toolchain loop (stages 1 to 6)" | HAND | BUNDLE-HAND (`resources/feature-templates/<kind>/...`) |
| 22 | `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md` | step `5. **Run required checks**`, coverage sub-bullets | full launcher coverage runs; "If coverage artifacts already exist from the executor run, inspect them instead of re-running." | HAND (shared pair) | BUNDLE-HAND (D3) |
| 23 | `sources/agents/{python,powershell,csharp}-typed-engineer.md` | `## Workflow` item 5 (both the Claude and Codex halves) | "Final QA gate — apply `<lang>-qa-gate` to run the full toolchain" | SRC-H | `.claude/agents/*`, `.codex/agents/*` + bundles (GEN-H); variants (GEN-V) (D4) |

Item 6 of the question (evidence formats): the phase-gate evidence path `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md` is stated only in `## Test Cadence (Mandatory)` and the three plan templates (items 1, 2, 21), and it implies a full run only through the surrounding bullet. Remediation-cycle QA requirements live only in `## Plan Shape` of `remediation-handoff-atomic-planner` (item 7). No policy-audit, code-review, or feature-audit template under `.dev/templates/policy_audit/` demands a full phase-gate run: `policy-audit` row `**Full toolchain loop**` under `### 2.5 After Making Changes - Toolchain Execution` and the coverage rows read "from the single gate run" (final QC); `AGENTS.md` of that folder reads coverage from the single gate run. A reviewer could cite the rule restatements to demand a full phase gate; items 3 and 4 remove that basis.

### 4.2 Hits that do not change (recorded so the sweep evidence can cite them)

| Path | Section | Wording | Reason |
|---|---|---|---|
| `.claude/skills/atomic-plan-contract/SKILL.md` (and `.agents`) | `## Final QA Loop`, `## Design-Level Plan Contract` Pre-Mortem bullet, mode lines "full QA loop obligations" | "Run the full toolchain loop for each applicable language" | Final QC |
| `.claude/agents/atomic-planner.md` | `## Plan Structure` "Final phase: full QA loop" | Final QC |
| `.github/agents/*atomic-executor*.agent.md` | final-QA check bullets | "a final QA phase exists that runs the full toolchain loop" | Final QC |
| `.github/prompts/execute-hard-lock.prompt.md` and Codex twins | precondition list | "A final QA phase exists with full toolchain loops" | Final QC |
| `.claude/skills/orchestrate/SKILL.md`, `.agents` | `## Concurrent Review and CI (review_mode)` item 3 | "The local parallel test run passes" | It is the final QC run before the pull request |
| `.claude/skills/execution-environment/SKILL.md` (four copies) | `## Test Runtime` | "full-suite pytest commands of the atomic executor tool (its preflight QC, its phase-gate QC loop ...)"; "A full suite above about 15 minutes" | Describes the Python CLI (D6) and runtime diagnosis; `its phase-gate QC loop` is pinned |
| brief, `orchestrate`, `orchestrator-state` rule | CI sections | "CI full run" | CI is unchanged |
| `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md` | `## Early Dependent Starts (early_start)` step 8 | "re-run the local gate" | D5: defined as targeted elsewhere; Claude copy is hash-pinned |
| `.github/agents/staged-review.agent.md`, `commentary-remediation.agent.md`, `.github/prompts/remediate-comments.prompt.md`, `pytest-unit-test-coding.agent.md`, `Powershell DI Unit Test Engineer.agent.md`, `python-execution-only-typed.agent.md`, `python-typed-engineer.agent.md`, `powershell-typed-engineer.agent.md`, `csharp-typed-engineer.agent.md` | Phase D / validation loop | "Run the full toolchain" | D10: standalone, not orchestrator steps |
| `.github/agents/{orchestrator,python-orchestrator,powershell-orchestrator,csharp-orchestrator}.agent.md` | executor handoff prompt | "Complete final QA loop" | Final QC |
| `.codex/agents/{python,powershell,csharp}-atomic-executor.toml` | instructions | "run the required ... QA loop" | Final QC |
| `sources/rules/typescript.md` (Copilot TS instructions) | notes | "requires the full toolchain loop: formatting → linting → type checking → testing" | Stage completeness, not suite breadth |
| `.dev/templates/bug/spec.md` | definition of done | "Full toolchain pass completed" | Final QC |
| `scripts/powershell/PoshQC/README.md` | usage | "Run the full suite against a selected scope" | Developer documentation |
| `scripts/dev_tools/atomic_executor/*.py` | `qc_runner.py`, `cli.py` | "Run full toolchain on entire codebase (phase gate)" | D6 |

### 4.3 Minimal hand-edit set and regeneration commands

Hand-edit (47 files): items 1, 2, 10, 11, 14, 15, 20 (7 files); the six qa-gate skills (item 12); the four csharp-legacy variants (item 13); the eight `.github/agents` files (items 16 to 18 minus overlap: `atomic_executor`, three language executors, four planners); three prompts (item 19); three plan templates (item 21); two `feature-review-workflow` copies (item 22); and the generator sources: `general-code-change.md`, the five language rule sources, `atomic-executor.md`, `atomic-planner.md`, three typed-engineer sources (items 3 to 6, 23: 11 files), plus `.agents/skills/remediation-handoff-atomic-planner`, `execution-environment`, `test-execution-policy` (items 7 to 9: 3 files).

Then, in order:

1. `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1` (all surfaces; writes generated targets and their bundle copies), then the same with `-Check`, and `-Surface instructions -Check` (checks `AGENTS.md` bundle drift and `EMBEDDED-RULE`). In an agent worktree this runs from a `sh <SCRATCH>/<file>.sh` launcher because command text containing `pwsh` is refused (execution-environment brief).
2. `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (writes variants and bundle copies), then with `--check`.
3. Hand-copy each HAND file to its bundle path (`Get-HarnessBundlePath` mapping; `.dev/templates/<kind>/` maps to `resources/feature-templates/<kind>/`). Bundle copies of hand-authored files are not produced by any generator or sync script in this repository (`scripts/dev_tools/skill_bundle_contract_cli.py` only checks).

## 5. Pinned Tests, Validators, Hooks, and Hashes (Question 3)

| Test or pin | Location | Pinned token(s) / behavior | Action |
|---|---|---|---|
| `TCW-<Id> carries its cadence wording`, `CANONICAL-*` rows | `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` (`$canonicalRequired`) | `'stages 1 to 6'`, `'restart from step 1'`, `'one clean pass'`, `'one `Invoke-PoshQCParallelTest` run'`, `'one `pytest -n auto` run'`, `'Jest through its normal parallel workers'`, `'phase-gate.P<N>.<timestamp>.md'`, `'-TestPath'`, `'Phase 0 baseline'`; `NextHeading '## Final QA Loop (Required for Code/Test Changes)'` | Keep all; the new wording can hold them. Add required tokens for the union rule and the "full suite only at the Phase 0 baseline and the final QA loop" statement |
| `TCW-CANONICAL-DISCRIMINATES` | same file | D15 tokens `'expected failures'`, `'confirmed failing'`, `'every other test passes'`, `'no-change phase'`, `'changes no tracked file'`, `'the next gate covers it'`; `$Token.Count | Should -Be 6` | Keep wording; count unchanged |
| `POLICY` rows | same file | `'phase-gate and final-QA requirement'`, `'run in CI'`, `'from step 1'`, `'every stage it runs'`, forbidden `'all seven stages'` | Keep; clarify stage 5 at a phase gate |
| `EXECUTOR` rows | same file | `## Execution Protocol` requires anchor and `'[phase-gate]'`; Copilot `### 7.1 ...` requires `'Phase-gate and final-QA toolchain'` | Keep |
| `PLANNER` rows | same file | `'[phase-gate]'`, `'between Phase 0 and the final QA phase'`, `'expected failures'`, `'no-change phase'` | Keep |
| `QAGATE` rows | same file | `## When to Use This Skill` requires `'a phase gate or the final QA loop'`; forbidden `'planned batch'` | Update the literal to the new qa-gate wording (QA gate applies to the final QA loop and the remediation gate) |
| `BRIEF` rows | same file | `'task-check evidence'`, `'never as a gate result or coverage evidence'`, `'-TestPath'`, `'its phase-gate QC loop'` (forbidden `'its full QC loop'`), `'test-cadence-wording.Tests.ps1'`, `'run-test-suite.sh pester'` | Keep |
| `TCW-TEMPLATE-<Id>` | same file | gate count per template (bug 2, feature 1, refactor 1), gate line holds `'phase-gate.P'` and the anchor, expect-fail gate holds `'expected failures'`, bug `**Phase 1` line holds `'no-change phase'` | Keep layout; reword only |
| `TCW-SWEEP-SURFACES` / `TCW-SWEEP-HELPER` | same file | 7 per-task sweep tokens, `$tokens.Count | Should -Be 7` | Add the removed phrases as a second token list with its own count assertion (for example "and the full toolchain loop at each phase gate", "the full unit suite", "runs the full toolchain loop instead", "still runs the full loop", "as the full loop at each phase gate", "the standard parallel unit gates"), or extend the list and change 7 to the new count |
| `runClassForbidden` (file-wide on rules, skills, prompts) | same file | `'targeted Pester'`, `'targeted Pytest'`, `'targeted xUnit'`, `'targeted MSTest'`, `'targeted tests'`, `'repeat until clean'` (per-task list) | D7: wording must avoid them |
| `PGW-SWEEP-SURFACES` / `PGW-SWEEP-HELPER` | `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | 12 tokens incl. `'targeted tests'`, `'targeted Pester'`, `'targeted Pytest'`; `$tokens.Count | Should -Be 12`; excludes `.claude/rules/`, `.github/instructions/`, `.agents` language skills | No change; D7 |
| `PGW-<Id>` rows | same file | QA-gate rows require `'single gate run'`, `'debugging only'`, `'Phase 0 baseline'`, D13 tokens; `REVIEW-*` rows require `'debugging only'`, `'N/A - no pre-change run'`, `'Phase 0 baseline'`, `'run-test-suite.sh'`, forbidden `'smallest relevant subset'`, `'run_poshqc_test'`, `'npm run test:unit:coverage'`; Copilot commentary/remediate rows require `'poetry run pytest -n auto'` | Keep tokens while editing items 12 and 22 |
| `PGW-SCOPED-<Id>` | same file | `'-TestPath'`, `'fail-before proof'` in four `test-execution-policy` copies | Keep while editing item 9 |
| `RSC-REGENERATE` | `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` | `'runs the standard parallel unit gates when unit_gate is not_run'`; `"When the entry point reports unit_gate not_run and the standard parallel gates pass, the orchestrator sets the event's unit_gate to pass before appending it."` (scope `## Merge-Conflict Remediation`, `.claude` copy and bundle) | Update both literals in step with item 10 (D9) |
| `test_frozen_epic_surface_matches_pinned_baseline_digest` | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` over `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | SHA-256 of `.claude/agents/epic-orchestrator.md` (`47c4c592...549f`) and `.claude/skills/epic-orchestrate/SKILL.md` (`e334237b...7e80`) | Untouched under D5. A legitimate change recomputes the digest from the new bytes and adds a `RE-BASELINED by issue #N` comment block above the tuple (precedents #1156, #1162, #1035) |
| `review-verdict-skill-contract.Tests.ps1` | `tests/scripts/claude-runtime/` | `'PINNED_FROZEN_SURFACE_HASHES'` in the orchestrate skill | Not affected |
| `less-evidence-contract.Tests.ps1` | `tests/scripts/claude-runtime/` | `'regression on changed lines'`, `'Phase 0 baseline'`, `'Enforce Python coverage thresholds'`, `'## CI Cross-check'` in feature-review surfaces | Keep while editing item 22 |
| Harness drift | `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` | every generated target equals its source rendering | Run generator before commit |
| Bundle parity | `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `TCW-BUNDLE-*` rows | equal text | Re-copy bundles |
| Ledger chain | `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1` | every entry reverts newest-first; index row per entry | New entry `0014` + index row |
| Plan validator, TS twin, planner/executor SubagentStop hooks | as in 1.3 | none pin `[phase-gate]` content | No change |

## 6. Off-Limits Check (Question 4)

Grep over `.claude/lib/docs/**`, `.claude/skills/docs-*/**`, `.claude/skills/documentation-workflow/**`, their `.agents` twins, and every bundle copy of those paths for `full unit suite`, `full toolchain`, `phase-gate`, `phase gate`, `full suite`, `full test suite`, `full loop`, `Test Cadence`, `parallel gates`, and `local gate`:

- SearchScope: the paths above in the item worktree.
- SearchResult: none. No inventory hit lies in the epic #1217 files.
- Adjacent risk: epic #1217 may also edit the docs-estate bullets of the execution-environment brief (`## Hook Execution Context`, `## Contract Tests That Pin Mirrored Files`), which item 8 also edits; the orchestrator should merge `origin/main` before the final QC loop.

## 7. Process-Reduction Ledger (Question 5)

- Folder: `.dev/engineering/process-reductions/`; the rule applies because the folder exists (`## Process-Reduction Ledger` of `atomic-plan-contract`).
- File: `NNNN-<short-name>.md`; next free number is `0014` (last entry `0013-npm-audit-advisory-exception.md`); recommended name `0014-targeted-test-cadence.md`. The orchestrator confirms no `0014` has landed on `origin/main` before commit.
- Required level-two sections, each non-blank: `## Summary` (with lines `reduction: 0014`, `Date: yyyy-MM-dd`, `Issue: #1228`, `Merge commit: pending (PR #N)`; the commit subject carries `reduction: 0014`); `## Reason and Evidence`; `## Files Changed` (every path including mirrors, bundles, generated variants, contract tests); `## Prior Text` and/or `## Stored Patch`; `## Revert Steps` with the six labels in order (`Apply the blocks`, `Re-copy mirrors and bundles`, `Regenerate Codex variants`, `Restore pinned hashes`, `Restore contract-test literals`, `Run the contract tests`), "not applicable" where a label does not apply; `## Revert Signals`.
- README index row: `| [0014](0014-targeted-test-cadence.md) | Targeted test cadence | <date> | #1228 | Active |`.
- Interaction with `0011` and `0012`: most edited regions are `Current` regions of `0011` (and some of `0012`). A newer entry that records its own edit is allowed (README `## Revert Order`; `0009` precedent): reverting `0014` first restores those regions byte-for-byte, so the older entries need no change.
- Recommended form (D8): `## Stored Patch` naming `patches/0014-targeted-test-cadence.patch`, generated as `git diff --cached --binary --no-renames HEAD` over the `## Files Changed` paths other than the ledger folder, as `0009` states. `.dev/templates/` paths are valid; `ProcessReductionChain.psm1` maps the legacy `docs/features/templates/` spelling to `.dev/templates/`.
- `## Reason and Evidence` should cite the owner directive verbatim and record D6 (Python CLI unchanged) and D10 (standalone Copilot agents unchanged).

## 8. Requirements Mapping

| Issue AC | Design |
|---|---|
| AC1 `## Test Cadence (Mandatory)` defines the union rule and full suite only at Phase 0 and final QA | Items 1, 2 (D1, D2, D5, D9 bullets) |
| AC2 No surface requires a full run elsewhere, verified by a recorded search | Items 3 to 23; evidence file under `<FEATURE>/evidence/other/` with `SearchScope`, `SearchPatterns`, `SearchResult`; the extended TCW sweep enforces it |
| AC3 Generated outputs regenerated; `-Check` reports no drift | Section 4.3 steps 1 and 2 |
| AC4 Bundle parity, AGENTS.md byte-identical, push-down tests pass | Section 4.3 step 3; `TCW-BUNDLE-AGENTS-MD`; push-down contract tests |
| AC5 Pinned validators, hooks, tests updated | Section 5 (TCW, RSC; none in hooks or validators) |
| AC6 Ledger entry with prior text and revert steps | Section 7 |
| AC7 Final QC and Phase 0 remain full runs with coverage; CI unchanged | `Final QA loop (unchanged)` bullet kept; no workflow edit |

## 9. Testing Implications

- Extend `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` (542 lines): new canonical required tokens; QA-gate literal; a second sweep token list for the removed full-at-phase-gate phrases with its own count assertion and a helper row; brief row for the new `## Test Isolation Checks` bullet. Expected size stays under 700 lines.
- Update `RSC-REGENERATE` literals in `regeneration-path-skill-contract.Tests.ps1` (350 lines).
- No new test file and no Python test edit under D5.
- Each test edit is a contract-wording change; run through the launcher `pester` suite with `-TestPath` for task checks, and the phase-gate union for the phase gate (the new rule applies to this item's own plan).

## 10. Risks (Question 7)

- File size: every edited non-test file is Markdown or TOML; Markdown is exempt from the file-size tiers. Test files: `test-cadence-wording.Tests.ps1` 542, `parallel-gate-wording.Tests.ps1` 332, `regeneration-path-skill-contract.Tests.ps1` 350, `parallel_orchestrator_surface_expectations.py` 513 (untouched under D5). None approaches 800.
- Batch budget: no PowerShell or Python production file is edited under the recommended design (hooks unchanged under D3; Python CLI unchanged under D6), so the batch-budget hooks are not engaged. Bundle copies count only for `.ps1`/`.py` files, and none is edited.
- Uniqueness trap: the restated sentence occurs twice in several files (both `atomic-plan-contract` copies, both `orchestrate` copies, the executor agents, `general-code-change` instruction) and three times in the Copilot language executors; a replace-all edit is correct there, but any `Current` fence would need context (D8 avoids fences).
- `HarnessInstructions.psm1` `EMBEDDED-RULE`: `AGENTS.md` `## Mandatory Toolchain Loop` must not become whitespace-equal to the same section of `.claude/rules/general-code-change.md`.
- Behavioral risk: cross-module regressions surface later (final QC, CI). Mitigation: repo-wide static, architecture, and contract stages stay at every phase gate; the final QC full run and CI stay.

## Automation Feasibility

The work needs no human interaction. Every step is a file edit, a generator run, a hand copy, a test run through the launcher, a ledger entry, and a commit. Facts this agent could not verify without `git`/`gh` (that no `0014` ledger entry has landed on `origin/main`, and the merge base for the scope diff) are confirmed by the orchestrator with read-only commands. No ruleset, workflow, or settings change is involved.

## Pre-Mortem

- Review checklists: a reviewer walking the policy-audit template could flag phase-gate evidence as "not a full toolchain loop"; mitigation: the plan's self-review cites the rewritten `## Test Cadence (Mandatory)` and the `general-code-change` stage-5 clarification, and the template rows are already final-QC rows (no template edit needed).
- Coverage: a remediation cycle or review could report a coverage gap because no full run follows the fix; mitigation: D2 and D3 state that changed-file coverage comes from the cycle's selection run in coverage mode and repo-wide totals from the final-QC artifact and CI; the final QA loop of this item itself stays a full run compared with its `Phase 0 baseline`.
- Mirror parity: a hand-authored file edited without its bundle copy, or the brief edited in fewer than four copies, fails the push-down contract tests or the brief maintenance rule; mitigation: the plan carries one generator task, one variant-generator task, and one bundle re-copy task naming every HAND file of section 4.1, and the brief edit goes through the `.agents` source and the generator.
- File size: not applicable for production files, because every edited non-test file is Markdown or TOML; the two edited test files stay below 700 lines (section 10).
- Test isolation: the new phase-gate wording could be read as permitting a serial or single-file run; mitigation: the unit stage names one parallel launcher run per language (`pester -TestPath`, launcher `pytest` with `-n auto`, launcher Jest) and no worker-reduction token; the sweep tokens that ban "targeted ..." wording (D7) stay in force.
- CI-only behavior: CI is unchanged, so a full-suite regression introduced between Phase 0 and final QC is first seen in the final QC loop or CI; mitigation: the final QC loop remains full, and the item's own CI run (`CI Required Gate`) gates the merge.
- Evidence: the AC2 repository-wide search could be recorded without scope or patterns and fail audit; mitigation: the sweep evidence file records `SearchScope`, `SearchPatterns`, and `SearchResult` per the negative-evidence rule, and the ledger entry lists every changed path including derived copies.

## Numeric Derivation Evidence

This section supports the occurrence count reported in section 1.1. It is not proposed as a numeric acceptance criterion; the recommended AC2 check is a zero-hit sweep.

- Complete Family: occurrences of the restated cadence sentence "Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop." in the item worktree.
- Exhaustive Search Scope: the whole worktree, excluding `node_modules/`, `.venv/`, `.git/`, `.claude/worktrees/`, and `.dev/` (feature, research, and ledger records).
- Inclusion Rules: every file of any extension containing the sentence; each occurrence counted.
- Exclusion Rules: `.dev/**` (the ledger entry `0011-task-check-cadence.md` holds 58 quoted occurrences in its revert blocks and is a record, not a surface).
- Primary Search Strategy or Query Expression: Grep, count mode, literal suffix `and the full toolchain loop at each phase gate and in the final QA loop`, with the `.dev` record subfolders excluded; the 58 occurrences in `.dev/engineering/process-reductions/0011-task-check-cadence.md` were then removed (214 - 58).
- Primary Member Set: harness sources 8 files / 14 (`sources/agents/atomic-executor.md` 2, `atomic-planner.md` 2, `sources/rules/csharp.md` 2, `general-code-change.md` 3, `powershell.md` 1, `python.md` 2, `shell.md` 1, `typescript.md` 1); `.claude` 13 files / 16 (`agents/atomic-executor.md` 2, `agents/atomic-planner.md` 1, six `rules/*.md` 1 each, `skills/atomic-plan-contract` 2, `csharp-qa-gate` 1, `orchestrate` 2, `powershell-qa-gate` 1, `python-qa-gate` 1); `.agents/skills` 12 files / 14 (`atomic-executor` 1, `atomic-plan-contract` 2, `atomic-planner` 1, `csharp-qa-gate` 1, `csharp` 1, `general-code-change` 1, `orchestrate` 2, `powershell-qa-gate` 1, `powershell` 1, `python-qa-gate` 1, `python` 1, `typescript` 1); `.codex/agents` 12 files / 18 (six `atomic-executor*.toml` 2 each, six `atomic-planner*.toml` 1 each); `.github` 12 files / 20 (`atomic_executor` 2, `atomic_planning` 1, three language executors 3 each, three language planners 1 each, `codex/execute-hard-lock` 1, `codex/resume-hard-lock` 1, `instructions/general-code-change` 2, `prompts/execute-hard-lock` 1); `AGENTS.md` 1 file / 1; `resources/claude-customizations` 15 files / 18 (two csharp-legacy variants 1 each, `agents/atomic-executor` 2, `agents/atomic-planner` 1, six rules 1 each, `atomic-plan-contract` 2, `csharp-qa-gate` 1, `orchestrate` 2, `powershell-qa-gate` 1, `python-qa-gate` 1); `resources/codex-and-agents-customizations` 27 files / 35 (two csharp-legacy variants 1 each, twelve `.agents/skills` copies 14, twelve `.codex/agents` copies 18, `AGENTS.md` 1); `resources/customizations/.github` 12 files / 20.
- Primary Count: 156 occurrences in 112 files.
- Cross-check Search Strategy or Query Expression: Grep, count mode, regular expression on the sentence prefix ``Test cadence follows `## Test Cadence \(Mandatory\)` `` with all of `.dev/**` excluded by glob.
- Cross-check Member Set: the same 112 paths with the same per-file counts as the primary member set (compared path by path).
- Cross-check Count: 156 occurrences in 112 files.
- Member-set Comparison: the normalized path lists and per-file counts are identical; every prefix occurrence is followed by the suffix, so no file holds a partial or variant restatement.
