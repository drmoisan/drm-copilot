# reduce-feature-cycle-time-with-revertible-ledger - Plan (Stage E)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T02-37
- **Status:** Draft
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

Stage E of `spec.md`: the criteria tagged `[E]`, clarifications K1, K3, and K6, and `research/research.2026-11-06.md` sections 1 and 3, re-derived against the tree after #1094 merged through PR #1102.

Delivered as separate commits: the #1094 check and any merge-commit back-fill; the planning-side standing rule (not a reduction); the smaller-plans reduction with its entry; the policy-read reduction with its entry; the replay sample; and the deferred wording with each affected entry updated.

Out of scope: the numeric G13 change and `.claude/rules/plan-acceptance-gates.md` (stage F); the `Size guideline.` bullet; `.github/instructions/` and every other `.claude/rules/` file; the less-evidence reduction (stage G); every Epic #1019 folder and admitted plan; and every TypeScript and Python production file.

## Baseline Hold

A baseline hold is in force. Entry `0001` records that plans capture static baselines and that coverage is read from the gate run with no earlier figure compared; the owner has been asked how to resolve that against the requirement that baselines stay. This plan presumes neither outcome. No task reduces or rewords any baseline, coverage-comparison, or `N/A - no pre-change run` text in any skill, template, hook, or test. Where policy-read wording shares a paragraph or a line with baseline wording, the edit removes only the policy-read wording; `## Baseline Adjacency` names each place. Baseline strings are checked by evidence, not by a new permanent test, because a permanent pin would itself presume the owner's decision.

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1097/`. Launchers and coverage reports live there, and artifacts record the token, never a host path.
- Tool routes, the batch budget, hook context, and CI shape come from the `execution-environment` skill and are not restated here.
- Preconditions, checked before [P0-T1]: the branch has merged `origin/main`, and `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` and `0002-concurrent-review.md` are in the tree. If either fails, stop and report. Stage D is expected to land first with `0003`, but no task assumes it: [P0-T3] and [P3-T2] read the merged tree. Every edit finds its place by heading, symbol, or sentence.
- Route: this stage edits more production files than direct mode allows, so it runs on the `large` route with its checkpoint in the item worktree. Bundled copies are written by a copy script under `SCRATCH`, then compared byte for byte.
- Entry numbers: `NNNN` is the next free four-digit number in `docs/engineering/process-reductions/README.md` when the commit is made, in the order the commits land: smaller plans first, then policy-read removal. The executor derives each number from the tree and records it in the replay artifact. File stems are `NNNN-smaller-plans` and `NNNN-policy-read-removal`.
- Entry form: as `0002-concurrent-review.md`. Fences are longer than any backtick run. Each non-identical copy takes its own block, one per hunk; byte-identical bundles and generated variants take none. `Current` must occur exactly once, so a block for a repeated passage carries an adjacent unique line. Merge commit line: read the open pull request with `gh pr list --head`; with exactly one open use `Merge commit: pending (PR #<number>)`, otherwise `Merge commit: pending (PR #1097)` with the stand-in sentence of entry `0002`, and the orchestrator replaces it after PR creation.
- Ledger replay, run from a script under `SCRATCH` before each reduction commit: `Test-ProcessReductionLedger` over `Read-ProcessReductionLedger` returns `IsValid` true; applying each path's blocks in order with `Invoke-ProcessReductionRevert` to the working text yields that path's text at `HEAD`, after line-ending normalization; and each `Current` of every earlier entry still occurs exactly once in its working file. `EXIT_CODE:` is non-zero when any of these fails.
- Evidence names carry the prefix `stage-e-`; a consumer selects the lexicographically greatest `stage-e-<name>.*.md`. The self-review keeps its contract name.
- Commits: commit and push after each task, except that [P2-T1] to [P2-T3] leave their work uncommitted and [P2-T4] makes the one whole reduction commit. No history is rewritten. A later fix that changes text a `Current` fence holds updates the entry in the same commit, and its subject carries that entry's token.
- Testing rule (owner's standing instruction, overriding contract text that requires otherwise): tests run in parallel only, one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs. A run of one Pester file is a single-process run, so Phases 1 to 3 run no tests: acceptance names the tests, and Phase 4 proves them.
- A task never runs an unqualified `poetry install` from the worktree. If the worktree cannot run a gate, stop and report. No task pushes a git tag. No new Python.
- Reading a Pester gate: `Invoke-PoshQCParallelTest` never calls `exit`. `EXIT_CODE:` records the `ExitCode` property of its returned object. With a non-zero `ExitCode` the merged files are not read; counts come from `artifacts/pester/parallel/shard-<i>/`.
- Failure outside the branch: a failing test whose test file and subject are both absent from the diff from the merge base of `origin/main` and `HEAD`. The artifact names the test, its file, and its subject, and lists that diff as proof. `EXIT_CODE:` stays non-zero, the task stays unchecked, the test is not edited, the gate is not repeated, and the executor returns these facts to the caller.
- Failure on the branch: a failing test whose file or subject is in that diff, or cannot be shown to be outside it. It is fixed, and the loop restarts from [P4-T1].

## Design

**Standing rule.** A new section `## Process-Reduction Ledger`, placed immediately before `## Short-Path Minimal Plan Contract` in each contract source. Its three bullets match the wording of `### Process-reduction ledger` in `.claude/skills/feature-review-workflow/SKILL.md`: the applies-only sentence, the adds-its-ledger-entry sentence, and the one-off-waivers sentence. The two reviewer-only bullets are not copied.

**Smaller plans.** A new bullet `**Task target.**` directly after the `**Size guideline.**` bullet of `## Design-Level Plan Contract (Mandatory)`: a plan targets 15 to 20 canonical tasks; the target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states. It names no validator number, so it stays true when stage F changes that bullet, and the `Size guideline.` bullet is not edited. A plan above the target is valid with no justification until it passes that limit.

**Policy-read removal.** The hook's check, its header bullet, every producer sentence, and every Copilot consumer go in one commit. Only a requirement is removed: `policy-compliance-order` stays, agents still follow policy, and no validator forbids the task, so a plan that keeps it stays valid. The replacement for the first paragraph of `## Phase 0 Requirements` states exactly that, so the next paragraph stays byte-identical, including its word `also`.

**Replay.** `tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1` finds the entry by the stem `*-policy-read-removal.md`, so no number is hard-coded, takes its blocks whose `Path` is `.claude/hooks/validate-planner-output.ps1`, and applies them to the live hook text in memory. A helper parses a text with the PowerShell AST, extracts `Get-PlanStructureValidationReport` and `Test-TaskContainsExplicitPath`, and runs them inside a child scope (`& { . ([scriptblock]::Create($text)); ... }`), so reverted and live definitions never meet and nothing leaks. No file is written. A later edit to the block's region makes the revert throw, which is the intended signal; only this sample replays against live text.

**Deferred wording, by source plan.**

| Stage | Deferred item | Disposition |
| --- | --- | --- |
| A, B | `## Test Isolation Checks` listing serial runs | Already satisfied by #1102; [P3-T2] records this and edits nothing |
| B | Any brief fact | None altered; recorded |
| C | The guard, the join, and the Python CLI route for the review rule | Two brief bullets in [P3-T2]; entry `0002` updated |
| D | The light route in the brief; `### Single-Pass Preflight` wording | Only when `*-light-remediation.md` is in the tree; its entry updated |
| A to D | Standing rule | [P1-T1] |

Each reduction gets its own brief bullet, so each entry reverts alone.

## Baseline Adjacency

Every place where baseline wording sits next to text this stage changes. "Kept" text stays byte-identical.

| # | Place | Removed or changed | Kept |
| --- | --- | --- | --- |
| 1 | Contract `## When to Use This Skill` bullet, six copies, same sentence | `policy reading + ` | `Enforcing Phase 0`, `baseline capture and final QA loops.` |
| 2 | Contract `## Short-Path Minimal Plan Contract` block 1, six copies | Bullet `policy reads in required order,` | Heading `Baseline capture block`; the static baseline capture bullet |
| 3 | Same block, `required artifacts:` list, six copies | Bullet naming the policy-read evidence artifact | The per-step baseline artifact bullet and the `each baseline step artifact` bullet |
| 4 | Contract `## Phase 0 Requirements` first and second paragraphs, six copies | First paragraph replaced | Second paragraph, whole, including `also` |
| 5 | Same section, `incomplete unless both artifacts exist:` list, six copies | `both` becomes `these`; the `phase0-instructions-read.md` bullet | `baseline command-step artifacts` bullet; the checklist-state bullet; the `Output Summary:` paragraph |
| 6 | The repeat of that list in `## Non-Overridable Evidence Path Clause`, in the `.claude` and `.agents` sources and their bundles (absent from the `.github` copies) | As place 5 | As place 5 |
| 7 | `.claude/agents/atomic-planner.md`, `.codex/agents/atomic-planner.toml`, variants and bundles, same sentence | `repo-policy reading tasks + ` | `Phase 0: baseline capture (`, `language-specific static tool baselines; no test suite runs)` |
| 8 | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` and bundle, same sentence | `policy reads and `, and `` `policy-compliance-order` and `` | `Phase 0 captures`, `static baseline results per`, the conventions citation |
| 9 | Hook header bullet, same sentence | `policy-read and ` | `Phase 0 exists and includes`, `baseline tasks,` |
| 10 | `Get-PlanStructureValidationReport` Phase 0 `else` branch | The `if` testing `policy\|instruction\|read` | `Plan must include Phase 0 with at least one baseline task.`, `$phaseZeroText`, the `\bbaseline\b` check and its error |
| 11 | Test title `blocks when Phase 0 baseline and policy-read tasks are missing` | ` and policy-read` | `blocks when Phase 0 baseline`, `tasks are missing` |
| 12 | Test `reports an error when Phase 0 mentions baseline but no policy-read wording` | Expectation inverted | `Capture baseline` fixture task; test `reports an error when Phase 0 mentions policy but no baseline wording` unchanged |
| 13 | Four Copilot orchestrators and bundles, `Do not mark S4 complete` bullet, same sentence | `` `phase0-instructions-read.md` and `` | `the baseline command-step artifacts referenced by the plan`, and the rest |
| 14 | Same files, `Artifact verification gate before mission completion (small path):` bullet, same sentence | `` `phase0-instructions-read.md` and `` | `baseline command-step artifacts required by the approved plan`, in lower case |
| 15 | Four Copilot executors and bundles, preflight list | `and contains the repo-policy reading tasks in the required order` | The two baseline bullets after it |
| 16 | Same files, Section 0 sentence `does not include Phase 0 tasks that cover the above`, near the baseline-schema sentence | ` tasks that cover the above` | `Plan format, Phase 0 requirements, baseline capture schema` sentence |
| 17 | `.github/prompts/execute-hard-lock.prompt.md`, `.github/codex/execute-hard-lock.prompt.md`, bundles, both Phase 0 lists | `Repo-policy reading tasks, AND` and `Repo-policy reading` | `Static baseline capture for each language touched by the plan,`; `Static baseline runs for each language touched` |
| 18 | `.github/prompts/review-feature.prompt.md` and bundle | The `phase0-instructions-read.md` bullet, which holds the words `canonical baseline location`. This is the one place a baseline word leaves a file, because it locates only the policy-read artifact | The next bullet, `every baseline command-step artifact` |
| 19 | Four Copilot planners and bundles, heading `### 2.3 Phase 0 — Context & Inputs` | ` (Mandatory Policy & Research)` | `Phase 0 content, baseline capture schema` sentence; the checklist question on static baseline capture tasks and its parent question, both unedited |
| 20 | `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` and bundle, Phase 0 block | Policy task, its acceptance line, the word `Compliance` in the heading | Instruction bullets naming static baseline tasks; `Coverage evidence:` line |
| 21 | New entry fences that need an adjacent line for uniqueness (places 5, 6, 10) | Nothing | Baseline lines appear unchanged in both `Current` and `Prior` |

Not adjacent, and untouched: `## Coverage Evidence Contract`, the brief's `## Coverage and File-Size Gates`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, the policy-audit template and `AGENTS.md` beside it, and `validate-feature-review-coverage*`.

## Baseline String Register

Research section 3 strings against the current tree.

| Research string | State after #1102 | Stage E use |
| --- | --- | --- |
| Hook `Plan must include Phase 0 with at least one baseline task.` | Present | Checked |
| Hook `Phase 0 must include a baseline task.` | Present | Checked |
| Baseline sentence of `## Phase 0 Requirements` | Reworded; now begins `Phase 0 must also capture static baselines` | Current text checked |
| Per-step baseline artifacts | `one baseline artifact per baseline command step`, `each baseline step artifact MUST include:`, and `baseline command-step artifacts with at least:` present. The bullet on baseline test-step artifacts was removed by #1102 | Current text checked |
| Baseline half of `## Coverage Evidence Contract` | **Removed by #1102**; the section has no baseline wording | Reported only |
| `### Baseline Evidence Output Summary (Required)` | Present in all six conventions copies | Checked |
| `Baseline Coverage Documented` | **Removed by #1102** from the policy-audit template and bundle | Reported only |
| Fail-closed rules of the policy-audit template | **Reworded by #1102**; `Fail-closed rule` and `Fail-closed reminder` no longer name a baseline artifact | Current text checked |

Further strings checked because they are in the hold: `static baseline capture (format, lint, type check, and analyzer findings)`, `No earlier figure is compared.`, `N/A - no pre-change run`, and `Include explicit static baseline tasks`. Nothing is restored or reworded.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Read the policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md` for PowerShell scope, and write `FEATURE/evidence/baseline/stage-e-phase0-instructions-read.<timestamp>.md`.
  - This task stays because the planner stop hook on `main` requires it until [P2-T4] lands.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read.
- [ ] [P0-T2] Capture the static PowerShell baseline and the baseline-string inventory, and write `FEATURE/evidence/baseline/stage-e-powershell-static.<timestamp>.md` and `FEATURE/evidence/baseline/stage-e-baseline-strings.<timestamp>.md`.
  - Static: format check and analyzer findings for `.claude/hooks/validate-planner-output.ps1` and `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`. No test suite runs. No Python or TypeScript file is in scope, so those tools have no baseline here.
  - Inventory: for every `Checked` string of `## Baseline String Register` and every string of the paragraph below it, the count per file over the hook, the six contract copies, the six conventions copies, and the policy-audit template and bundle; and the case-insensitive count of the word `baseline` in every file `## Baseline Adjacency` names.
  - Acceptance: each artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, every string count is above zero in at least one file, and findings are read from a direct analyzer run, not from MCP output.
- [ ] [P0-T3] Confirm that `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` satisfies the `[E]` back-fill criterion, back-fill every landed entry still pending, and write `FEATURE/evidence/other/stage-e-ledger-check.<timestamp>.md`.
  - #1094 check, from a script under `SCRATCH`, with no new entry: the ledger is valid; `patches/0001-parallel-only-test-gates.patch` exists; the entry's `Merge commit:` identifier is an ancestor of `HEAD`; and for each `Revert Block`, `Current` occurs once in that path at the merge commit and `Prior` occurs in that path at the merge commit's first parent, which is the pre-merge state.
  - Back-fill (D1, K8): for each entry whose line is pending, including a stand-in `#1097`, find the merged pull request of `feature/reduce-feature-cycle-time` whose merge commit is the oldest one holding that entry's reduction commit, and write `Merge commit: <identifier>`. An entry whose reduction has not merged stays pending. Commit only those lines.
  - Existing tests: `PRL-REAL-LEDGER-AGREES` reads the real entries and accepts both forms, so it is unchanged.
  - Acceptance: `EXIT_CODE:` is 0 only when every #1094 condition holds; the task adds no file under `docs/engineering/process-reductions/`; and the artifact lists each entry with its line. If a #1094 condition fails, stop and return it to the caller: the criterion is then unmet and needs a new entry that this plan does not hold.

### Phase 1 — Standing Rule and Smaller Plans

- [ ] [P1-T1] Add `## Process-Reduction Ledger` to `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, and `.github/skills/atomic-plan-contract/SKILL.md`, copy each to its bundle under `extensions/drm-copilot/resources/`, and create `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`.
  - The text is the Design's standing rule. The new suite follows `parallel-gate-wording.Tests.ps1`: read in place, collapse whitespace, and write nothing. It takes `-ForEach` rows over the six copies. `PCW-STANDING-RULE-<Copy>` asserts `` `docs/engineering/process-reductions/` exists ``, `adds its ledger entry in the same commit`, and `One-off waivers for a single item are not entries.`
  - Existing tests, unchanged because the edit only adds a section: `test_single_pass_preflight_contracts.py`, `test_plan_gate_document_docs.py`, `test_plan_gate_scratch_docs.py`, `test_claude_planning_integrity_contracts.py`, `parallel-gate-wording.Tests.ps1`, and `test_push_down_issue_824_follow_ups.py`, because the path names no consuming product.
  - Commit: the subject carries no `reduction:` token, because this reduces nothing.
  - Acceptance: each bundle hashes equal to its source, the commit holds no ledger path, and [P4-T2] reports the rows passing.
- [ ] [P1-T2] Add the `**Task target.**` bullet to the same three contract sources and their bundles, extend `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`, write `docs/engineering/process-reductions/NNNN-smaller-plans.md` with its `README.md` row, and make the reduction commit.
  - Text: the Design's smaller-plans bullet. Row `PCW-TASK-TARGET-<Copy>` asserts `15 to 20` and that the bullet sits after `**Size guideline.**`.
  - Entry: `## Reason and Evidence` cites research section 2 and states that the time saved is unknown until stage timing has data. `## Prior Text` holds one block per source with `Current` the bullet and `Prior` empty. `## Revert Steps`, all six labels: `Restore contract-test literals` removes the `PCW-TASK-TARGET` row; the Codex step, not applicable, still runs the generator `--check`; `Restore pinned hashes`, not applicable. `## Revert Signals`: plans merging tasks into long ones, more preflight defects per plan, and a rise in plans above the target that carry no reason.
  - Run the ledger replay and write `FEATURE/evidence/other/stage-e-ledger-replay-smaller-plans.<timestamp>.md` with the derived number. Commit with a subject carrying `reduction: NNNN`, then push.
  - Existing tests, unchanged: the `G13` pins in `test_plan_gate_document_docs.py`, because the `Size guideline.` bullet is not edited.
  - Acceptance: the artifact records `EXIT_CODE: 0`, the commit holds the entry, the row, and all six copies, and `git show --name-only --format= HEAD` lists no file of `## Scope`'s out-of-scope set.

### Phase 2 — Policy-Read Removal

- [ ] [P2-T1] Remove the policy-read check from `.claude/hooks/validate-planner-output.ps1`, copy it to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1`, and update `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`.
  - Hook: places 9 and 10 of `## Baseline Adjacency`. `Get-PlanStructureValidationReport` keeps every other rule.
  - Tests updated: `blocks when Phase 0 baseline and policy-read tasks are missing` is renamed as place 11, and its body is unchanged because the fixture has no Phase 0, which still reports `Plan must include Phase 0 with at least one baseline task.`; `reports an error when Phase 0 mentions baseline but no policy-read wording` becomes `accepts Phase 0 with baseline wording and no policy-read wording`, asserting an empty report, because that plan is now valid. Added: `accepts a plan that keeps the policy-read task`, through `Get-PlanStructureValidationReport`, asserting an empty report.
  - Unchanged because each keeps a baseline task, or asserts another rule: `reports an error when Phase 0 mentions policy but no baseline wording`, `allows termination when the plan satisfies the structural contract`, and the `.Reentry`, `.PreMortem`, and `.Coverage` suites. `test_claude_planning_integrity_contracts.py` pins only review-record tokens. `hook-dependency-failure.*` and `subagentstop-*` suites name the hook only. A search of the tree found `policy-read task` asserted in no other test. `is_phase0_read_task` and `phase0_read_tasks` under `scripts/dev_tools/atomic_executor/` return an empty list when no read task exists, so they are unchanged.
  - Acceptance: the bundle hashes equal to the source, `Phase 0 must include a policy-read task.` is absent from both, and [P4-T2] reports the named tests passing.
- [ ] [P2-T2] Remove the policy-read requirement from `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, `.claude/agents/atomic-planner.md`, and `.codex/agents/atomic-planner.toml`, regenerate, and extend `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`.
  - Contract: places 1 to 6 by hand per source, because the sources differ. Replacement for the first paragraph, as the Design states: Phase 0 carries no routine policy-read task, agents still follow `policy-compliance-order`, and a plan that keeps the task stays valid. Then copy to the bundles. `## Mode-Specific Mandatory Plan Gates` is not edited: `required Phase 0 artifacts` still reads correctly.
  - Agents: place 7. `.codex/agents/atomic-planner.toml` is the hand-edited base; run the generator for the variants and bundles, then its `--check`. Copy the Claude agent to its bundle.
  - Tests: `PCW-POLICY-READ-REMOVED-<Copy>` forbids `policy reading`, `policy reads in required order`, `policy-read evidence artifact`, `tasks to read policy files`, and `phase0-instructions-read.md`, and requires `stays valid`.
  - Existing tests, unchanged: a search of the test tree found no pin on any removed sentence. `parallel-gate-wording.Tests.ps1` `PGW-PLAN-*` and `PGW-SWEEP-SURFACES` hold, because the new text carries no swept token. `test_codex_agent_wrapper_contracts.py` pins no fragment of the changed sentence.
  - Acceptance: every bundle hashes equal to its source, the generator `--check` reports no drift, and [P4-T2] reports the rows passing.
- [ ] [P2-T3] Remove the policy-read wording from the remaining surfaces, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, `.github/agents/atomic_executor.agent.md`, and `.github/prompts/review-feature.prompt.md` among them, with the full file set below, copy each to its bundle, and extend `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`.
  - File set: the handoff skill (place 8); `atomic_executor`, `csharp-atomic-executor`, `powershell-atomic-executor`, and `python-atomic-executor` agents (places 15, 16); `orchestrator`, `csharp-orchestrator`, `powershell-orchestrator`, and `python-orchestrator` agents (places 13, 14); `atomic_planning`, `csharp-atomic-planning`, `powershell-atomic-planning`, and `python-atomic-planning` agents (place 19); both `execute-hard-lock.prompt.md` files (place 17); `review-feature.prompt.md` (place 18); `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` (place 20); and `docs/engineering/claude-code-architecture.md`, whose planner paragraph drops ` policy reads` from `with Phase 0 policy reads,`. That document has no bundle.
  - Place 20: the heading becomes `### Phase 0: Context & Inputs`, and the task becomes the neutral `- [ ] [P0-T1] <Atomic task>` that the other phases use, so no baseline wording is added or removed. The bundle is `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`.
  - Not edited: `policy-compliance-order`, `execute-hard-lock` skills, `translate-*` skills, `.agents/skills/orchestrate/SKILL.md` intake text, `docs/features/templates/bug/` and `refactor/` plans, the policy-audit template, and historical fixtures under `tests/fixtures/`.
  - Tests: `PCW-SURFACE-<Id>` rows, one per source file above, forbid `repo-policy reading`, `phase0-instructions-read`, `captures policy reads`, `Phase 0 tasks that cover`, `Mandatory Policy & Research`, and `Compliance & Context` as each applies.
  - Existing tests, unchanged: `PGW-COPILOT-*` rows, `PGW-AUDIT-*` rows, and `claude-architecture-doc.Tests.ps1`, which pins agent tool names only; `test_execution_environment_brief_contracts.py` `test_brief_is_referenced_by_copilot_base_agents`. A search of the Python, Pester, and Jest test trees found no pin on `Do not mark S4 complete` or on the template's Phase 0 text. The blast-radius fixtures hold historic paths and are data.
  - Acceptance: every bundle hashes equal to its source, and [P4-T2] and [P4-T3] report the tests passing.
- [ ] [P2-T4] Write `docs/engineering/process-reductions/NNNN-policy-read-removal.md` with its `README.md` row, prove the baseline hold, and make the one reduction commit holding every Phase 2 file.
  - Entry: `## Reason and Evidence` cites research section 3 and the owner's condition that only the routine read task and its artifact are dropped. `## Files Changed` lists every Phase 2 file, bundle, generated variant, and test. `## Prior Text` holds a block per hunk per non-identical copy, and must include the two hook blocks that [P3-T1] replays. `## Revert Steps`, all six labels: `Regenerate Codex variants` applies; `Restore contract-test literals` restores the two test bodies of [P2-T1] and removes the `PCW-POLICY-READ-REMOVED` and `PCW-SURFACE` rows; `Restore pinned hashes`, not applicable. `## Revert Signals`: review findings citing a policy the executor did not follow, and a remediation cycle traced to a skipped policy rule.
  - Run the ledger replay and write `FEATURE/evidence/other/stage-e-ledger-replay-policy-read.<timestamp>.md`.
  - Hold check, run from a script under `SCRATCH`, with three conditions. Every string count equals its [P0-T2] count; the count of the word `baseline` falls in no named file except `.github/prompts/review-feature.prompt.md` and its bundle, each by exactly one; and the `N/A - no pre-change run` count is unchanged everywhere. Write `FEATURE/evidence/qa-gates/stage-e-baseline-strings.<timestamp>.md`, whose `Output Summary:` also lists the `Reported only` rows of `## Baseline String Register`.
  - Commit: stage every Phase 2 file with a subject carrying `reduction: NNNN`, then push.
  - Acceptance: both artifacts record `EXIT_CODE: 0`; `git show --name-only --format= HEAD` lists the hook, all six contract copies, and the entry together; and it lists no `.claude/rules/` or `.github/instructions/` path.

### Phase 3 — Replay and Deferred Wording

- [ ] [P3-T1] Create `tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1` and commit it.
  - Behavior: the Design's replay. Rows: `PRR-ENTRY-FOUND` (exactly one stem match and at least one hook block); `PRR-REVERTED-RETURNS-POLICY-READ-ERROR` and `PRR-LIVE-RETURNS-NO-POLICY-READ-ERROR`, each on an in-memory plan whose Phase 0 holds only a `Capture baseline` task, asserting `Phase 0 must include a policy-read task.` present and absent; and `PRR-BASELINE-ERROR-SURVIVES-REVERT`, where a plan with no Phase 0 returns `Plan must include Phase 0 with at least one baseline task.` from both.
  - It uses `Get-ProcessReductionRevertBlock` and `Invoke-ProcessReductionRevert`, reads tracked files only, and leaves no function defined after a row. No existing test changes.
  - Acceptance: the file creates no temporary file, and [P4-T2] reports the four rows passing.
- [ ] [P3-T2] Land the deferred wording from the merged tree in `.claude/skills/execution-environment/SKILL.md` and its five copies and in the three `atomic-plan-contract` sources and bundles, update `docs/engineering/process-reductions/0002-concurrent-review.md` and any light-remediation entry, extend `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`, and write `FEATURE/evidence/other/stage-e-deferred-wording.<timestamp>.md`.
  - First read the tree: stage D counts as landed only when `docs/engineering/process-reductions/*-light-remediation.md` exists. The artifact records every row of the Design table with its disposition, and when stage D has not landed it states that its items stay open.
  - Brief, one text then copied byte for byte. `## Hook Execution Context` gains one bullet: the merge guard `.claude/hooks/enforce-epic-merge-gate-review.ps1`, its twin, inert without `review_mode: "concurrent"`, its three deny codes, and the join, which also needs `CI full run`. `## MCP Surfaces Run the Installed Extension` gains one bullet: installed MCP accepts a concurrent checkpoint that the PowerShell stop hook and the Python CLI reject, so it is checked through the `orchestrator-state` subcommand with `--require-complete`. `## Contract Tests That Pin Mirrored Files` gains `concurrent-review-skill-contract.Tests.ps1` and `planning-contract-wording.Tests.ps1`.
  - When stage D has landed: `## MCP Surfaces Run the Installed Extension` gains a separate bullet stating the light route as the orchestrate skills state it, the contract-test list gains `light-remediation-skill-contract.Tests.ps1`, and the `At most one return` paragraph of each contract source gains one closing sentence: a cycle recorded with `Remediation-Mode: light` has no plan and no preflight, and its executor stop before the first task converts it to the design chain. Only the `.claude` source names proportionate cycles today, and that sentence is not edited. Rows `PCW-LIGHT-WORDING-<Copy>` and `PCW-BRIEF-LIGHT-ROUTE-<Copy>` join the suite.
  - Tests: `PCW-BRIEF-MERGE-GUARD-<Copy>` and `PCW-BRIEF-CHECKPOINT-ROUTE-<Copy>` over the six brief copies assert `enforce-epic-merge-gate-review.ps1`, `REVIEW_GATE_NOT_PASSED`, `CI full run`, and `--require-complete`.
  - Entries (K3): each affected entry's `## Files Changed` gains the six brief copies and any contract copies, `## Prior Text` gains a block per changed source with `Current` its own bullet or sentence and `Prior` empty, and step 2 of `## Revert Steps` names the re-copies. The commit subject carries each updated entry's `reduction:` token.
  - Existing tests, unchanged: every test of `test_execution_environment_brief_contracts.py`, including `test_brief_copies_are_byte_identical`, `test_brief_has_required_headings`, `test_brief_has_no_g11_or_g12_findings`, and `test_brief_copies_carry_no_removed_run_tokens`, provided the new bullets carry no line number, commit identifier, or removed-run token. `## Test Isolation Checks`, `## Coverage and File-Size Gates`, and every baseline sentence are not edited.
  - Run the ledger replay over each updated entry, recording `EXIT_CODE:` in the artifact, and re-run the [P2-T4] hold check.
  - Acceptance: both checks exit 0, the six brief copies hash equal, each contract bundle hashes equal to its source, and [P4-T2] and [P4-T3] report the tests passing.

### Phase 4 — Final QA

- [ ] [P4-T1] Run format and lint over every `.ps1` and `.psm1` file in the branch diff and write `FEATURE/evidence/qa-gates/stage-e-powershell-format-lint.<timestamp>.md`.
  - Format with `Invoke-PoshQCFormat` check-only, with a no-op `-WriteFile`, and analyze with a direct `Invoke-ScriptAnalyzer` run using `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Type checking does not apply.
  - Acceptance: the log holds an `Already formatted: ` line and no `Formatted: ` line for each file, and analyzer findings number zero. `EXIT_CODE:` is non-zero when any condition fails. A failure is repaired and this task restarts.
- [ ] [P4-T2] Run one `Invoke-PoshQCParallelTest` and write `FEATURE/evidence/qa-gates/stage-e-powershell-test.<timestamp>.md`.
  - Output Summary: total and failed counts from `artifacts/pester/pester-junit.xml`; the test counts of `planning-contract-wording`, `ProcessReductionLedger.Replay`, and `validate-planner-output`; the repo-wide percentage; and the `LINE` counter of `.claude/hooks/validate-planner-output.ps1` and its bundle from `artifacts/pester/powershell-coverage.xml`.
  - Acceptance: `ExitCode` is 0, failed tests number zero, each of the three suite counts is above zero, the hook's line coverage from this run is at least 85%, and the repo-wide percentage is at least 85%. No figure comes from MCP output. Each failure is classified under Execution Terms.
- [ ] [P4-T3] Run one `poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing` from the worktree root, with `PYTHONPATH` set to this worktree's `packages/discovery-runtime/src`, and write `FEATURE/evidence/qa-gates/stage-e-python-test.<timestamp>.md`.
  - Output Summary: passed and failed counts, totals, and that `test_execution_environment_brief_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_plan_gate_document_docs.py` are in the passed set, plus the generator `--check` result.
  - Jest skip branch, approved by the caller: one full-suite coverage Jest run through the launcher the brief names runs only when the diff from the merge base of `origin/main` and `HEAD` lists a `.ts` file, and writes `FEATURE/evidence/qa-gates/stage-e-typescript-test.<timestamp>.md`. Otherwise the Python artifact records that no TypeScript file is in the diff, and the diff listing is its proof.
  - Acceptance: the process exit is 0 with failed at zero, totals hold the thresholds, and the Jest condition is recorded. Each failure is classified under Execution Terms.
- [ ] [P4-T4] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - This task starts only when [P4-T2] and [P4-T3] are checked, or the caller has directed it past a failure outside the branch. In that case the `[A]` test-gate row is N/A and names the failing test and the decision.
  - Scope rows: the stage's commits hold no file of `.claude/rules/` or `.github/instructions/`, no Epic #1019 folder, no admitted plan, and no TypeScript or Python production file; the `Size guideline.` bullet is unchanged; no tag was pushed.
  - Hold rows: one row per place of `## Baseline Adjacency`, each citing the hold check; one row stating that no text presumes the owner's decision.
  - Order rows, from the branch log: each reduction is its own commit with its entry and `reduction: NNNN` subject; the standing rule commit carries no token.
  - Acceptance: every `[E]` criterion in `spec.md`, and the `[A]` test-gate criterion, has a row naming its proving test or artifact, and no row is FAIL. A FAIL row is fixed, the QA loop re-runs from [P4-T1], and this artifact is rewritten.

## Pre-Mortem

- Review checklists: the likely finding is a spec rule with no falsifying test. Rule to test: the #1094 back-fill to [P0-T3]; standing rule to `PCW-STANDING-RULE`; target to `PCW-TASK-TARGET`; removal to `PCW-POLICY-READ-REMOVED`, `PCW-SURFACE`, and the [P2-T1] tests; a kept task stays valid to `accepts a plan that keeps the policy-read task`; baseline strings to the hold check; replay to the `PRR-` rows; deferred wording to the `PCW-BRIEF-` rows and the artifact; one commit per reduction to [P4-T4]. [P4-T4] walks all three templates. `modified-workflow-needs-green-run` does not fire: no workflow path changes.
- Coverage: the hook loses lines only, and no new production file exists. [P4-T2] reports its figure from the single gate run against 85%, as the contract states. No Python or TypeScript production file changes. The replay runs the hook's function through a parsed copy, so it adds no coverage to the hook and is not counted on.
- Mirror parity: [P1-T1], [P1-T2], [P2-T2], and [P3-T2] cover the six contract copies, edited by hand per source and copied to bundles; [P2-T1] the hook bundle; [P2-T2] the Claude agent bundle, the Codex base, and the generated variants with `--check`; [P2-T3] each Copilot, skill, and template bundle. Execution-environment brief: [P3-T2] updates all six byte-identical copies, closing the K6 deferrals of stages C and D. The policy-read removal, the standing rule, and the task target alter no fact the brief states.
- File size: `validate-planner-output.ps1` shrinks; `validate-planner-output.Tests.ps1` is near 400 lines and gains about 15; each new suite stays under 500 lines. Markdown is exempt.
- Test isolation: per the owner's standing instruction, the plan runs one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, and Jest through its normal parallel workers only if a TypeScript file changes, each re-run only after a fix. The replay loads functions in a child scope, sets no global state, and creates no file.
- CI-only behavior: `validate-planner-output.Tests.ps1` also runs on `poshqc / PowerShell hook suites (Linux)`, so its additions use forward-slash paths and no drive letters. The two new suites run in the `poshqc / PowerShell QC` shards, because `tests/scripts` is a scan folder; both use `Join-Path` from the repository root, and `Invoke-ProcessReductionRevert` normalizes line endings. No test reads `artifacts/` or `origin/main`. Isolated subagents run `main`'s planner hook, so the removal is proven by Pester only, and this plan keeps [P0-T1]. The PR takes a full CI run, because its paths lie outside `config/ci-docs-only-paths.json`.
- Evidence: artifacts live under `FEATURE/evidence/baseline/`, `qa-gates/`, and `other/`, carry the four fields, use write-time stamps and the `stage-e-` prefix, and record no host path. `EXIT_CODE:` carries each acceptance value. No plan assertion reads PoshQC MCP output.

## Test Plan

- Unit: the [P2-T1] hook tests and the `PRR-` replay rows.
- Contract: `planning-contract-wording.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, the brief contract module, and the bundle and generator checks.
- Changed tests: two tests in `validate-planner-output.Tests.ps1`, as [P2-T1] states. No other existing assertion changes.
- Manual/CLI: the #1094 check, three ledger replays, and the hold check.
- Coverage evidence: `stage-e-powershell-static` under `FEATURE/evidence/baseline/`, and `stage-e-powershell-test` and `stage-e-python-test` under `FEATURE/evidence/qa-gates/`, with per-file figures from the single gate run.

## Open Questions / Notes

These are choices this plan makes where the spec is silent or a premise did not hold. A reviewer should confirm them.

- Phase 0 here follows the contract as it stands: static baselines, no test suite run. This is not a position on the owner's decision; if that decision lands first, the caller directs any change to this plan.
- Premise corrections to research section 3: the `remediation-handoff-atomic-planner` line exists only in the `.claude` copy and its bundle, not in six copies; `.codex/agents/atomic-planner.toml` is a hand-edited base and the other five are generated; the `execute-hard-lock` skills state no policy-read rule, while the two prompts do; only the `.claude` contract source names proportionate cycles.
- Additions to research section 3: the Copilot executors' Section 0 sentence (place 16), which would still invalidate a plan with no read task; the planners' heading (place 19); and the architecture document.
- Research suggested making the artifact required only when a plan names it. The orchestrator text instead drops it: the bullet's own `Phase 0 checklist items` clause still holds a plan that keeps the task to its evidence, and the wording stays a pure removal.
- The target lives in the contract only. The planner agent and Copilot planners defer to the contract, so adding it there would widen the reduction for no behavior.
- Stage D's and stage I's plans cite `0001-concurrent-review.md` and `0002-light-remediation.md`, which predate the renumbering. This plan does not edit them.
- `also` in `Phase 0 must also capture static baselines` is kept, because that sentence is held; the replacement sentence before it keeps it readable.
- The Jest tree was searched for the removed tokens and holds none. Under the caller's condition no local Jest run proves that; the extension test jobs in CI run on the head regardless.
