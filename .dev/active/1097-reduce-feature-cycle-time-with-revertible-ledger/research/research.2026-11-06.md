# Research: Reduce Feature Cycle Time With a Revertible Ledger (Issue #1097)

- Date: 2026-11-06
- Requirements source: `docs/features/potential/promoted/2026-11-06-reduce-feature-cycle-time-with-revertible-ledger.md`
- Method: every finding below was read from the item worktree tree. `git` and `gh` were not available; facts that need them are marked `CONFIRM-ORCHESTRATOR` and collected in `## Unconfirmed Facts`.
- Notation: `S6(x)` is the six-copy skill set for skill `x`: `.claude/skills/x/SKILL.md`, `.agents/skills/x/SKILL.md`, `.github/skills/x/SKILL.md`, and the bundled copies under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/...`, `codex-and-agents-customizations/.agents/...`, `customizations/.github/...`). `S4(x)` omits the two `.github` copies. `+B` means the file plus its bundled copy. Only `execution-environment` is byte-identical across surfaces; `atomic-plan-contract` copies differ per surface, so each is edited by hand.

## Findings That Change the Proposal

1. **Nothing checks review at merge today.** No branch of either merge gate reads a review result (question 6). The owner condition "merge remains impossible without a passing review" is currently met only by ordering in skill prose.
2. **The less-evidence reduction depends on concurrent review.** A branch has no CI run until a PR exists, because `ci.yml` has no feature-branch `push` trigger, and #1074 finding F1 records this. Under review-first ordering the reviewer has no CI result to cross-check. Less evidence must land with or after concurrent review, not before it (question 10).
3. **`feature-review` has no `gh`.** Its tools are Read, Grep, Glob, `git diff`, `git log`, a scoped Write, and the validator MCP tool. The cross-check needs a tool grant or an orchestrator-supplied snapshot (question 4).
4. **Installed MCP lags the branch.** G13 and the light-cycle contract reach `validate_orchestration_artifacts` only after an extension release is installed. `atomic-planner` has only the MCP route, and the review templates also come from bundled assets. Any stage that relies on new validator behavior needs a release, or a Python CLI route, first.
5. **The owner's premise on #1019 plans conflicts with the tree.** A plan above 40 tasks without `## Size Justification` already fails G13 today. In `docs/features/active/`, all 16 current plans above 40 tasks carry the section (question 2). `CONFIRM-ORCHESTRATOR`.
6. **A hook, not only skill text, requires the policy-read task.** `Get-PlanStructureValidationReport` in `.claude/hooks/validate-planner-output.ps1` emits `Phase 0 must include a policy-read task.`
7. **The ledger's "merge commit" cannot exist in the commit that adds the entry.** A commit cannot name itself or its later merge (question 1).
8. **Stage timing recorded only in the checkpoint is lost.** `artifacts/` is gitignored and leaves with the worktree (question 9). It should also land earlier than the owner's order, so that reductions are measured.

## 1. Ledger

**Layout.** `docs/engineering/process-reductions/README.md` (index table: id, title, date, issue, status) and one `NNNN-<short-name>.md` per reduction. A patch that will not fit inline goes in `patches/NNNN-<short-name>.patch`.

**Required sections in each entry.** `## Summary` (what, date, issue, reduction commit subject, merge commit), `## Reason and Evidence`, `## Files Changed` (every mirror, bundle, and pinned test), `## Prior Text` or `## Stored Patch`, `## Revert Steps`, `## Revert Signals`. `## Prior Text` holds one `### Revert Block: <repository-relative path>` per canonical file, each with a fenced `Current` and a fenced `Prior` block; a fence longer than any backtick run in the text keeps verbatim Markdown intact. `## Revert Steps` names, in order: apply blocks, re-copy mirrors and bundles, regenerate Codex variants with the generator `--check`, restore pinned hashes, restore contract-test literals, and run the contract tests. Revert must not depend on `git revert`.

**Commit identity.** The owner's list requires a merge commit, and the same commit must add the entry. Decision for the spec: the entry records a stable reduction commit subject token (`reduction: NNNN`, findable with `git log --grep`) and `Merge commit: pending (PR #N)`. The next stage's PR back-fills the value. The structure test accepts `pending` only in that exact shape. Whether each reduction is a separate commit cannot be proven by a CI test on a shallow checkout; the reviewer checks it from the branch log.

**Structure test: Pester, repository-only.**
- Production helpers: `scripts/dev-tools/ProcessReductionLedger.psm1`, with pure functions over text (`Get-ProcessReductionSection`, `Test-ProcessReductionEntry`, `Test-ProcessReductionIndex`, `Get-ProcessReductionRevertBlock`, `Invoke-ProcessReductionRevert`) and one read seam. `scripts` is a root in `config/poshqc-coverage.json` and a scan folder in `config/poshqc-scan.json`, so the module joins the coverage population and CI shards automatically. It is not under `.claude/`, so it adds no bundle, manifest, or closure entry.
- Tests: `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`. In-memory fixtures cover complete, missing section, missing prior text, empty section, and index mismatch. A second case iterates the real entries read-only, so a committed incomplete entry fails `poshqc` shards and therefore `CI Required Gate`.
- PowerShell over Python follows the owner's new-tooling rule.

**"Revert restores behavior" without temporary files.** Apply the revert in memory and run the reverted code in memory:
1. Read the live file text into a string. Reading tracked files is permitted; creating files is not.
2. `Invoke-ProcessReductionRevert` replaces each entry's `Current` block with its `Prior` block and throws when `Current` is absent, so a stale revert block fails loudly.
3. Parse the reverted string with the PowerShell AST, extract the one function, and load it with `[scriptblock]::Create`, the pattern the PowerShell rule file already permits.
4. Assert the behavior.

The sample is the policy-read reduction, because its behavior lives in one PowerShell function: reverted `Get-PlanStructureValidationReport` returns `Phase 0 must include a policy-read task.` for an in-memory plan with no policy task, and the live function does not. Only this sample replays against live text. Replaying every entry would fail CI on any later edit to a ledgered region; the structure test covers the others.

**Standing rule.** Rule text: when `docs/engineering/process-reductions/` exists in the repository, a change that reduces evidence, plan tasks, gates, or review process adds a ledger entry in the same commit; one-off waivers for one item are not entries.
- Carriers: `S6(atomic-plan-contract)` (deferred behind #1094) and `S6(feature-review-workflow)` (not deferred). Stage 1 can land the review half now, and the planning half lands with the first post-#1094 stage.
- `test_push_down_issue_824_follow_ups.py` does not conflict: it checks consuming product names (TaskMaster, No-COM), and the path contains neither. The path has precedent in pushed text: `.claude/skills/orchestrate/SKILL.md` cites `docs/engineering/legacy-discovery-and-parity/enforcement.md`.
- A consumer repository without the folder is unaffected, because the rule is conditional on the folder existing. Whether any pushed-surface test asserts that a cited path exists was not found in the tests read; the contract run in stage 1 settles it.

**#1094 back-fill.** Requires #1094 merged. Prior text comes from its pre-merge state. `CONFIRM-ORCHESTRATOR`.

## 2. G13

**Implementations.** `PLAN_TASK_GUIDELINE`, `PLAN_LINE_GUIDELINE`, `plan_size_message`, and `evaluate_document_gates` in `scripts/dev_tools/plan_gate_document.py`; `PLAN_TASK_GUIDELINE`, `planSizeMessage`, and the evaluator in `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`.

**Every place a plan is validated.**

| Surface | Runs G13? | Which rules | When |
| --- | --- | --- | --- |
| `atomic-planner` self-check (`.claude/agents/atomic-planner.md`) | Yes | Installed MCP only; the planner has no Bash | Before handoff, and on a revision |
| Preflight (`## Preflight Validation` in `.claude/agents/atomic-executor.md`) | Yes | Installed MCP, or the Python CLI in that worktree | Preflight runs only |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | Yes | Installed MCP | Remediation plans |
| `.claude/hooks/validate-planner-output.ps1` | No | Structure, Pre-Mortem, internal review | Planner stop |
| `.claude/hooks/validate-executor-output.ps1` | No | Plan-path, checkboxes, output shape | Executor stop |
| Execution runs | No | No validator call in the execution protocol | Never |
| CI | No | No workflow invokes the plan validator; `.claude/rules/plan-acceptance-gates.md` states there is no sweep | Never |
| Epic and parallel readiness | No | `validate_plan_text` has no caller in those validators; the parallel kickoff checks `plan-hash` only | Never |

**When a lowered threshold would reject an in-flight plan.** The planner stop hook never rejects it, nor does the executor stop hook, the execution run, or CI. A plan already past preflight is not validated again, so it is not rejected unless it is sent back. Rejection occurs only when a plan is re-validated at a planner revision or a preflight, and then only if that surface carries the new constant: installed MCP after a release containing it is installed, or the Python CLI after the item's branch merges the change. `CONFIRM-ORCHESTRATOR`: which #1019 plans have not yet cleared preflight.

**Mechanism: cutoff by plan-file stamp.** Keep the rule Blocking and add a stamp comparison.
- Add a plan path to the gate context. `_plan_channels` holds `args.path`, and `buildPlanGateContext` holds `input.artifactPath`.
- A plan file named `plan.<stamp>.md`, `plan.remediation-cycle-N.<stamp>.md`, or `remediation-plan.<stamp>.md` whose stamp sorts before `PLAN_GUIDELINE_CUTOFF` uses the legacy pair 40 and 400. Every other path, including no path, uses the new pair.
- The stamp comes from the feature-folder tooling, and the Plan-Path Continuity Contract keeps it stable, so new plans cannot opt out by text. New plans are not weakened and in-flight plans need no edit, which matters because `.claude/skills/parallel-orchestrate/SKILL.md` verifies `plan-hash`.
- `## Scope of Invocation` rejects a marker or allowlist because it would be a suppression surface for the plan being written. A date cutoff has no author-controlled surface in a new plan. That section must be amended to state this, and its "no grandfathering" text is a contract edit in the G13 commit.
- The finding message states the guideline that applied. Parity tests run both sides of the cutoff.

**Guideline data (31 plans in `docs/features/active/` written since G13 shipped).** Excludes the unfilled #1097 template, one plan dated before #964, and one remediation-cycle plan.

| Measure | Result |
| --- | --- |
| Tasks: minimum, median, maximum | 15, 41, 171 |
| Plans above 40 tasks | 16, all with `## Size Justification` |
| Plans above 20 tasks | 30 of 31 |
| Physical lines: median, maximum | 148, 1150 |
| Plans above 400, 250, and 200 lines | 1, 3, and 6 |

**Recommendation on the line guideline: lower 400 to 250.** At 400 it binds on 1 of 31 plans, and 400 lines over 20 tasks allows 20 lines per task, so it would not stop tasks from being merged into long ones. 250 leaves room for 20 tasks at the observed rate of up to about 6 lines per task plus a fixed preamble and Pre-Mortem. A lower value would catch plans that are not outliers. Because 30 of 31 plans exceed 20 tasks today, the justification section may become routine at first; use its frequency as a revert signal.

**File inventory.**
- Code: `scripts/dev_tools/plan_gate_document.py`, `plan_gate_discrimination.py`, `validate_orchestration_artifacts.py`; `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`, `plan-gate-discrimination.ts`, `orchestration-artifacts.ts`.
- Docs: `.claude/rules/plan-acceptance-gates.md` +B (frontmatter unchanged; rule table, `### G13` section, finding message, authoring guidance, `## Scope of Invocation`); `S6(atomic-plan-contract)` `Size guideline.` and `## Validator Gate` (deferred); `.claude/agents/atomic-planner.md` +B; `.github/agents/atomic_planning.agent.md` +B.
- Tests needing edits: `test_plan_gate_document_docs.py` (`_RULE_TOKENS` pins `(40)` and `(400)`; `test_rule_file_bundle_copy_is_byte_identical_for_g13`), `test_plan_gate_document_parity.py` and `plan-gate-document-parity.test.ts` (literal message strings). Tests that follow the constants: `test_plan_gate_document.py`, `plan-gate-document.test.ts`. `test_plan_gate_scratch_docs.py` also cites G13 and needs checking.

## 3. Policy-Read Task

**Producers (change these).**
- `S6(atomic-plan-contract)`: `## When to Use This Skill`, `## Short-Path Minimal Plan Contract` block 1, `## Phase 0 Requirements`, and the duplicated paragraph in `## Non-Overridable Evidence Path Clause`. Deferred behind #1094.
- `.claude/agents/atomic-planner.md` +B, `Phase 0: baseline capture (repo-policy reading tasks + ...)`. Six generated `.codex/agents/atomic-planner*.toml` files plus their bundle copies follow through `generate_codex_agent_variants.py`.
- `S6(remediation-handoff-atomic-planner)`, `Phase 0 captures policy reads`.
- `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` and `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`, `### Phase 0: Compliance & Context` task.
- `execute-hard-lock` (`.agents` and `.claude` skill copies, `.github/prompts/execute-hard-lock.prompt.md`, `.github/codex/execute-hard-lock.prompt.md`) and the four Copilot `*-atomic-executor.agent.md` bundle files: the pattern matched here; read and adjust at planning.

**Consumers (change these).**
- `.claude/hooks/validate-planner-output.ps1` +B: remove the policy-read test and its header bullet.
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`: `blocks when Phase 0 baseline and policy-read tasks are missing` and `reports an error when Phase 0 mentions baseline but no policy-read wording` change. Fixtures in `.Reentry.Tests.ps1` and `.Coverage.Tests.ps1` still pass.
- `.github/agents/orchestrator.agent.md` and the `python-`, `powershell-`, and `csharp-` orchestrators +B: S4 gate and checklist require `phase0-instructions-read.md`. Make the artifact required only when the plan names it.
- `.github/prompts/review-feature.prompt.md` +B.

**Unaffected.** The policy-audit row `Read existing change plans` is not a policy-read requirement, although reviewers have cited the artifact there. `is_phase0_read_task` and `phase0_read_tasks` in `scripts/dev_tools/atomic_executor/` return an empty list when no read task exists. `phase0_execution_summary` is baseline state. Historical plans, `tests/fixtures/orchestration-handoff/`, and `translate-*` skills stay as they are; `policy-compliance-order` governs reading, which agents keep doing.

**Baseline requirements that stay.** In the hook: `Plan must include Phase 0 with at least one baseline task.` and `Phase 0 must include a baseline task.` In the contract: the baseline sentence of `## Phase 0 Requirements`, per-step baseline artifacts, and the baseline half of `## Coverage Evidence Contract`. In conventions: `### Baseline Evidence Output Summary (Required)`. In review: `Baseline Coverage Documented` and the fail-closed rules of the policy-audit template. The AC test: search these strings before and after the reduction.

**In-flight plans.** Removing a check only widens acceptance, and no validator forbids the task, so a plan that keeps P0-T1 stays valid and still writes its artifact. The Python and TypeScript plan validators never checked it.

## 4. Less Evidence

| Requirement | Disposition | Reason |
| --- | --- | --- |
| Final-QC format, lint, type, and test artifacts (`## Short-Path Minimal Plan Contract` block 3, `## Final QA Loop`) | Reduce | `quality-checks7`, `poshqc`, and the Jest jobs prove these on the head |
| Repo-wide coverage totals | Reduce | `quality-checks7` (3.13) enforces totals, and `poshqc / PowerShell QC` merges and uploads coverage. #1047 R1 and R2 and #1074 F2 and F3 were findings about this class |
| Scope and diff listings | Reduce | The diff carries them |
| Baseline artifacts and baseline comparison | Keep | Owner condition; the pre-change state is not in CI |
| Per-changed-file coverage and changed-line regression | Keep | CI gates totals for Python and PowerShell, not per changed file; Jest thresholds are per file |
| Fail-before evidence and exception dossiers | Keep | Fail-before is not visible on the final head |
| `preflight-fixes`, `self-review`, issue-update mirrors, AC check-off | Keep | Not in the diff or CI |
| Isolation runs | Out of scope | #1094 owns them |
| `modified-workflow-needs-green-run` | Keep | It is already a CI-based rule |

**Hook and validator code.** None needs a change for this reduction. `validate-feature-review-coverage.ps1` requires a PASS or FAIL coverage row per language and compares figures only "for an available artifact", so a missing local artifact does not block. `validate-executor-output.ps1` checks output text for commands and PASS or FAIL, not evidence files. The final-phase QA check in the planner hook stays.

**Prose that changes.** `S6(atomic-plan-contract)` (deferred); `S6(feature-review-workflow)` step 5 (`If no coverage artifact exists ... flag as FAIL`), which would otherwise recreate findings like #1047 R1; `S6(evidence-and-timestamp-conventions)`; `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (fail-closed text and a new row), `AGENTS.md` in that folder, and their bundled assets. `resolve_policy_audit_template_asset` serves installed assets, so template edits lag until a release.

**Cross-check placement.** A concurrent review can finish before CI, and `feature-review` has no `gh`.
- Recommended split: the reviewer writes a `## CI Cross-check` table of claimed results (check name, claimed outcome, claimed coverage figure, head). At the S9 join the orchestrator compares each row against `ci_gate`, `gh pr checks`, and the merged coverage artifact. A mismatch becomes a synthetic Blocking finding.
- This keeps the reviewer's claims auditable without an `AWAITING_CI` re-review per item. A wait verdict would add a second review delegation.
- Rejected alternative: grant `feature-review` read-only `gh`. It also needs Codex and architecture-doc updates and still cannot read an unfinished run.
- The owner's text says "a reviewer cross-checks", so this split is a decision for the spec.

## 5. Light Remediation

**Invariant 2 today.** `_validate_remediation_cycle` in `scripts/dev_tools/_orchestrator_state_remediation_loop.py`; the matching check in `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`; and the cycle check in `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`. All emit `Checkpoint remediation cycle #N execution_status is X but preflight.final_status is not 'clear'.`

**How the light path differs from proportionate.** The proportionate cycle still has one `atomic-planner` delegation, a plan with Pre-Mortem and self-review, and an executor preflight, and it records a truthful `preflight.final_status: "clear"`. Light removes the planner and the preflight. Of 33 `remediation-inputs` files in `docs/features/active/` with a mode line, 31 are proportionate-only and 2 are design (#1047 and #1011 first cycles), so the planner delegation is paid on nearly every cycle.

**Reuse.** Build light as a third value of the existing mode line, reusing the pre-R4 commit, R4, R5, accounting, and the blocked fallback. A separate path would duplicate those. Leaving proportionate unchanged needs no contract change but keeps the two delegations that are the saving.

**No plan, without a hook change.** `Get-ExecutorOutputBlockDecision` requires an advertised `plan-path` to an existing file with at least one checkbox, all ticked, and `AC Status Summary`. It does not require a remediation-plan name. A `## Light Fix Tasks` section in `remediation-inputs.<timestamp>.md` with canonical `- [ ] [P0-T1] ...` lines satisfies it, and `plan_path` names that file truthfully, so invariant 1 holds. `BLOCKED at preflight (before [P0-T1])` still gives the executor a stop before the first checked task, and the existing fallback rewrites the mode line and continues on the design chain. The checklist remains in one document. The preimplementation gate carries no plan or preflight read (no match in `enforce-orchestration-preimplementation-gate*.ps1`).

**Threshold (all must hold).**
- At most 3 blocking findings, every one `autonomous`.
- No change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors (the existing proportionate test).
- No change to a validator contract, hook decision, or production logic beyond the finding's named location.
- Review-opened cycles only; CI-failure and merge-conflict cycles keep the current path at first.
- Not consecutive: the cycle after a light cycle is full.

**Reviewer's role.** `feature-review` writes `Remediation-Path: light|full` and, per blocking finding, `Finding-Scope: contained|design`. The orchestrator may move a cycle to a heavier path, never lighter. The `Remediation-Mode:` line stays orchestrator-owned.

**Checkpoint shape (additive, key-gated on the cycle).**

```jsonc
{ "plan_path": "<FEATURE>/remediation-inputs.<timestamp>.md", "remediation_path": "light",
  "opened_by_review": 2, "execution_status": "complete", "candidate_applied": true }
```

`review_outcomes[].findings[]` gains an optional `scope`. Absent `remediation_path` keeps every rule byte-identical. New invariant 8, with byte-identical strings:
- `remediation_path` is `light` or `full`.
- A `light` cycle carries no `preflight` object, because a record of a preflight that never ran is untruthful.
- It carries a valid `opened_by_review`.
- The referenced outcome has at most 3 findings, each `autonomous` with `scope` exactly `contained`.
- The prior cycle is not `light`.

**Rejection of a design-level finding.** Any finding with `scope: "design"` or no `scope` fails the cycle at plain validation in all three runtimes, so the `SubagentStop` hook blocks. Invariant 2 then applies unchanged to every non-light cycle, which gives the "preflight absent on the full path" test condition. The check needs `review_outcomes`, so it belongs in the accounting stage, not `_validate_remediation_cycle`, which sees one cycle only (`OrchestratorStateRemediationAccounting.psm1` in PowerShell).

**Corpus and parity.** `tests/fixtures/orchestrator_state_remediation_loop/` and `orchestrator_state_remediation_loop_backcompat/` with `..._expected.json`; `test_orchestrator_state_remediation_loop_parity.py`, `test_validate_orchestrator_state_remediation_backcompat.py`, `test_orchestrator_state_remediation_accounting.py`, `test_orchestrator_state_remediation_docs.py`; `orchestrator-state-remediation-loop-parity.test.ts`, `-backcompat.test.ts`, `-accounting.test.ts`; `tests/scripts/claude-lib/orchestrator-state/`. `test_single_pass_preflight_contracts.py` pins the two mode lines. All three validators land in one commit. Prose: `.claude/rules/orchestrator-state.md` +B, `S4(orchestrate)` `## Remediation Loop (R1–R5)`, `.claude/agents/orchestrator.md` +B, `.claude/agents/feature-review.md` +B, `S6(remediation-handoff-atomic-planner)`, `S6(feature-review-workflow)`, `.claude/lib/orchestrator-state/` bundle copies, and the `atomic-plan-contract` reference to proportionate cycles (deferred).

## 6. Concurrent CI and Review

**What enforces merge today (read from `Invoke-EpicMergeGateDecision` and the Codex gate).**

| Path | Green CI | Passing review |
| --- | --- | --- |
| 1 Epic child | `step9_status == passed` plus PR binding; no live-head check | Not read |
| 2 Epic integration | `epic_merge_pr.ci_gate.conclusion == success` | Not read |
| 3 Parallel | `merge_status == ci_green`, recorded by the parent from `gh pr checks` | Not read |
| 3b Standalone green-CI | `step9_status`, `ci_gate`, PR binding, live head equals `ci_gate.head_sha` | Not read |
| 4 Authorization record | Not read; requires a session-bound record | Not read |
| Docs-only M1 to M9 | Not read; every path under `docs/`, no recording checkpoint | Not read |
| Codex child | `step9_status` in `passed` or `verified`; no green-CI branch | Not read |
| Codex epic, authorization | As paths 2 and 4 | Not read |

**Merge does not check review in any path.** The review requirement is enforced only by sequence: PR Creation Gate condition 1 in `S4(orchestrate)` (prose), plus the `--require-pr-creation-ready` hook preflight, which rejects `step7_status` values `pending`, `blocked`, and `blocked_remediation_loop_limit` but reads no verdict or finding count. `require_complete` reads no review result either. CI is additionally enforced by the GitHub ruleset's required context, whose current state and any review requirement are `CONFIRM-ORCHESTRATOR`. A merge outside the Bash hook surface is not gated by these hooks at all.

**Design: `review_mode: "concurrent"`.** Absent means sequential, with zero behavior change.
- Reuse `remediation_loop.review_outcomes[]`, which already records every review including PASS. Add `head_sha` to each entry. No validator rejects an unknown key, so no second record is needed.
- **Sequence.** S5 passes the one local parallel run, commit, S8 PR, then S7 review and S9 CI proceed together (CI runs on GitHub while the review delegation runs), then a join, then merge.
- **PR creation.** Under the key only, `step7_status: pending` no longer blocks readiness: Python `_orchestrator_state_pr_creation_readiness.py` and PowerShell `OrchestratorState.psm1`. TypeScript has no readiness port (no `require_pr_creation_ready` in the extension source), so none is needed. PR Creation Gate conditions 1 and 2 move to a new merge gate for concurrent runs.
- **Merge guard.** New sibling `.claude/hooks/enforce-epic-merge-gate-review.ps1` and a Codex twin, called right after the child checkpoint read and before branch 1, so it covers 1, 3, 3b, and 4. When `review_mode` is `concurrent` and the checkpoint binds the PR: the last `review_outcomes` entry must have verdict `PASS` and a well-formed `head_sha`, and that head must be current (below). Otherwise deny with `REVIEW_GATE_NOT_PASSED`, `REVIEW_GATE_HEAD_STALE`, or `REVIEW_GATE_HEAD_UNRESOLVED`. A bare command under the key is denied. It reuses `Get-EpicMergeGateLivePrHeadSha`; that one bounded `gh` call happens only under the key.
- **Completion.** `require_complete` under the key requires the same PASS record in all three runtimes (new helper modules; a new TypeScript file needs its own `coverageThreshold` entry).

**Older checkpoints.** No key means no `gh` call, no new denial, and no relaxation, so they are neither stronger nor weaker. A run cannot skip both gates: without the key review precedes the PR, and with it review precedes merge.

**Stale head.** Reviewing, then committing review artifacts, moves the head by design.
- `head_sha` equal to the live head passes.
- Otherwise pass only when it is an ancestor of the live head and `git diff --name-only -z --no-renames <reviewed>..<live>` lists only paths under the checkpoint `feature-folder`. This is condition (b) of `modified-workflow-needs-green-run`, and a git failure denies.
- Any code push after PASS, including a CI fix or a merge of `origin/main`, makes the review stale and requires re-review. The spec decides whether a clean merge of `origin/main` should count; this research recommends that it counts as stale, which is the safer reading of the owner condition.
- A docs-only head reports CI success without running heavy suites, so the join requires a `CI full run` at the reviewed head or its predecessor under the same rule.

**Parallel and epic.** `.claude/skills/parallel-orchestrate/SKILL.md`, step 2 of merge-on-green, must not record `ci_green` while the child's review is unresolved. The child checkpoint is reachable while its worktree is live, and the guard reads it through the item target. If the item target does not resolve, the guard sees no key; the parent's skill step is the backstop, which is a stated limit. Branch 2 keeps current rules. Like the authorization record, this is a policy-level control: a same-session writer can edit the checkpoint.

**Inventory.** `.claude/hooks/enforce-epic-merge-gate.ps1` +B (482 lines, so logic goes in the sibling), `.codex/hooks/enforce-epic-merge-gate.ps1` +B, the new sibling files, pack manifests `core.json` for Claude and Codex, `S4(orchestrate)`, `S4(epic-orchestrate)` if child wording changes (frozen hash), `.claude/skills/parallel-orchestrate/SKILL.md` and its copies, `.claude/rules/orchestrator-state.md` +B, `.claude/agents/orchestrator.md` +B, `docs/engineering/claude-code-architecture.md` if tool text changes. Tests: `tests/scripts/claude-hooks/enforce-epic-merge-gate*` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-*`, `hook-dependency-failure.*`, `hook-dependency-guard-completeness.Tests.ps1`, `test_push_down_pack_manifest_dependency_closure.py`, `test_parallel_orchestrator_surface_contracts.py` (`MERGE_ON_GREEN_FRAGMENTS`). Header comments claiming branches never call `gh` must be corrected.

## 7. Design Check

**Sample.** Five `remediation-inputs` files were read in full (#1093, #1080 first cycle, #1074, #1047 first cycle, #1067) of 43 in `docs/features/active/`; this is a sample, not a measurement.

| Class | Examples | Would a pre-execution check catch it? |
| --- | --- | --- |
| Spec rule with no falsifying test | #1093 F1, #1080 finding 1 | Yes |
| Spec prose disagreeing with an AC | #1093 OA-1 and NB-1 | Yes |
| Unspecified edge behavior | #1080 findings 2 and 3 | Partly |
| Coverage or artifact absent locally | #1047 R1 and R2, #1074 F2 and F3 | No; concurrent CI and less evidence address this |
| CI-dependent results pending | #1074 F1 and F4 | No; concurrent CI addresses this |
| Sibling instances of a fixed defect | #1067 R1-F1 to R1-F5 | Partly |

Few sampled findings were design errors, consistent with the mode-line count of 2 in 33.

**Recommendation: add it to single-pass preflight.** The planner already runs `AC-TRACEABILITY` and cannot objectively check its own plan. A separate step adds a delegation, which runs against the aim. Preflight already reads the whole plan against the tree. Add one named pass: for each spec rule, parameter, and boundary, name the task and the test that would fail if the rule were broken, and treat a gap as a substantive defect (`an acceptance criterion with no implementing task`, widened). It costs no delegation or artifact. Files: `S6(atomic-plan-contract)` `### Single-Pass Preflight` (deferred), `.claude/agents/atomic-executor.md` +B `## Preflight Validation`. No hook change; `test_single_pass_preflight_contracts.py` needs a new pin.

## 8. Early Dependent Starts

**Surfaces.**
- Layer 1: `.claude/hooks/enforce-epic-wave-barrier.ps1` +B and `.codex/hooks/enforce-epic-wave-barrier.ps1` +B.
- Layer 2: `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`, `validate_epic_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`, `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` +B, called by `validate-orchestrator-output.ps1`.
- Prose: `S4(epic-orchestrate)` `## Wave Barrier (Two-Layer Design)`, `S4(epic-run)`, `.claude/agents/epic-orchestrator.md` +B and its generated Codex variants.
- Pins: `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` has both `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. Both digests re-baseline in the same commit, with a new `RE-BASELINED by issue #1097` comment, computed after the final edit.
- Tests: `tests/fixtures/epic_wave_barrier/` (`start-guard-matrix.json`, `layer2-parity-edge-cases.json`), `test_validate_epic_orchestrator_state_wave_barrier.py`, `test_epic_wave_barrier_parity_corpus.py`, `OrchestratorStateEpicWaveBarrier.Tests.ps1`, `.Parity.Tests.ps1`, `enforce-epic-wave-barrier*.Tests.ps1`, `epic-execution-gates.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`.

**Minimum change: one key-gated field on the dependent feature.**

```jsonc
"early_start": { "dependency": "<issue_num or folder>", "upstream_branch": "<branch>",
  "interface_settled_at": "<iso8601>", "interface_evidence": "<path>", "synced_at": null }
```

- Layer 1 allows the start when the sole unmerged dependency equals `early_start.dependency`, `upstream_branch` is non-empty, and the interface fields are present. Other dependencies keep the barrier.
- Layer 2 skips that one edge while the dependent is before merge. A dependent at `pr_open` or later requires dependency `merged` and a string `synced_at`, with new `EPIC_WAVE_BARRIER_VIOLATION` text. Absent the key, both layers are byte-identical, so #1019 is unaffected.
- **Sync step.** After the upstream merges to the integration branch, the child runs `git merge origin/<integration_branch>` in its worktree, runs its local gate, records `synced_at`, and only then opens its PR. Recommend merge, not rebase: `validate-bash.ps1` denies forced pushes, and pushed WIP would need one. The owner wrote "rebase", so this is a decision for the spec.
- If the upstream interface changes after `interface_settled_at`, the child stops and the epic orchestrator re-evaluates; that risk is accepted in the requirements.

## 9. Stage Timing

**Shape.** Top-level, additive:

```jsonc
"stage_timing": [ { "stage": "S5_atomic_execution", "attempt": 1,
                    "started_at": "<iso8601 UTC>", "ended_at": null } ]
```

**Tolerance.** No unknown-key rejection exists in the Python, PowerShell, or TypeScript orchestrator-state validators (searches for such logic found none). `.claude/rules/orchestrator-state.md` documents the precedent (`parallel_mode`, `pr_merge`). No validator change is needed. `required` keys are unaffected. Portable handoff carriage of the key was not traced; add a test.

**Writer.** The orchestrator main session, at the transitions where it already rewrites `last_updated`, reading the clock rather than composing a value. No hook can write it: hooks only allow or deny.

**Durability.** `artifacts/` leaves with the worktree, so the orchestrator also writes `<FEATURE>/evidence/other/stage-timing.<timestamp>.json` in its last pre-merge commit. That commit is inside the feature folder, so it does not stale a review under question 6. The merge stage itself is not captured; state this in the report.

**Report.** `scripts/dev-tools/Get-StageTimingReport.ps1` with pure logic in `scripts/dev-tools/StageTiming.psm1`, tests under `tests/scripts/dev-tools/`, reading the committed evidence files through a seam; output is per-stage median and total per issue. Times are wall-clock, which includes queueing and is not agent time.

**`Get-EpicProgressReport` reuse.** Little. Its logic (`.claude/skills/epic-progress-report/scripts/`) is about task velocity from kickoff tables, `gh`, and `cswap`; only `Format-EpicProgressHour` overlaps, and dot-sourcing a pushed skill's internals into a repository tool adds a dependency for one formatter. Recommend no coupling.

## 10. Delivery

Each reduction is one commit containing its ledger entry. Order below differs from the owner's in two places, marked.

| Stage | Content | Depends on | File overlap |
| --- | --- | --- | --- |
| 1 | Ledger, helpers, tests, review-side standing rule | None | `S6(feature-review-workflow)` with stages 4, 5 |
| 2 (moved earlier) | Stage timing: orchestrate skill text, report | None | `S4(orchestrate)` with 5, 6 |
| 3 | After #1094: #1094 back-fill entry; planning-side standing rule; smaller-plans text; policy-read removal with its hook edit | #1094 | `S6(atomic-plan-contract)` with 4, 5, 6, 7 and #1094 |
| 4 | G13 values, cutoff, guideline docs | Stage 3 | `S6(atomic-plan-contract)` |
| 5 | Light remediation | Release decision | `S4(orchestrate)`, rule file |
| 6 | Concurrent CI and review: commit A inert merge guard, commit B readiness and skills | None | `S4(orchestrate)`, `parallel-orchestrate` |
| 7 (moved later) | Less evidence and CI cross-check | Stage 6 | `S6(feature-review-workflow)`, templates |
| 8 | Design check | #1094 | `S6(atomic-plan-contract)`, `atomic-executor.md` |
| 9 | Early dependent starts | Prefer after #1019 | Epic surfaces, frozen hashes |

**Unsafe orderings.**
- Readiness relaxed before the merge guard removes the only review ordering. Guard first.
- Less evidence before concurrent review: no CI result exists at review time.
- Policy-read contract text without the hook edit: planners are blocked. One commit.
- Any one of three validators alone for light cycles: the stop hook or MCP rejects a truthful cycle.
- G13 without the cutoff in place: older plans fail on re-validation.

**#1094 overlap.** Stages 1, 2, 5, 6, and 9 do not need its two skills, except for `atomic-plan-contract` proportionate-cycle wording in stage 5, which can follow. The brief needs updating in six copies when a stage alters a fact it states; check this at each stage after #1094 merges, because its plan is not in this tree.

**Epic route: reported, not adopted.** This work qualifies by the `orchestrate` scale test ("multiple independently mergeable features"), and the repository's history with #980 points the same way: 9 stages, multi-day. Against it: stage 9 edits the epic machinery, and the stages are largely sequential because of shared files, so waves give little concurrency. The owner decides. A smaller alternative is to keep #1097 as stages 1 to 4 and split the others into child issues.

## Hook and Validator Behavior That Could Land Badly on an In-Flight Item

1. `validate-planner-output.ps1`: a planner re-run during the gap between contract text and hook edit is blocked, repairably.
2. MCP validators stay on old rules until a release: a light cycle is rejected at `validate_orchestration_artifacts`, a required route tool. Adopt the light path only after the release, or route checkpoints through the Python CLI.
3. `validate-orchestrator-output.ps1` uses the PowerShell module from main: a merged PowerShell change applies to every in-flight stop at once. Every new rule must be key-gated.
4. Isolated subagents run main's hook copies, so a branch hook is proven by Pester only, not by a live run.
5. `PINNED_FROZEN_SURFACE_HASHES`: any `epic-orchestrate` or `epic-orchestrator` edit without a re-baseline fails CI, and a merged skill edit changes what a running epic reads on its next load.
6. Parallel `plan-hash`: any edit to an admitted plan stops its child with `premise_falsified`. Nothing may require editing in-flight plans.
7. Merge guard: an in-flight checkpoint lacks the key, so it must take the unchanged path. A test must prove no `gh` call occurs without the key.
8. Codex parity: a missed Codex twin leaves a concurrent Codex run merging without review.
9. `test_parallel_orchestrator_surface_contracts.py` fragments pin merge-on-green wording, including the statement that the orchestrate skill is not modified by that feature.
10. `config/ci-docs-only-paths.json` does not list `docs/engineering/`, so ledger back-fill PRs take a full CI run. This is safe but not free. The merge gate's docs-only exemption still applies only with no recording checkpoint.
11. Batch budget: bundle copies count as production files, so multi-mirror stages belong on the orchestrated large route.
12. `hook-dependency-guard` and dependency-closure tests fail until a new dot-sourced sibling is guarded and manifested.

## Automation Feasibility

Fully automatable for implementation and tests. No third-party UI is involved. Exceptions, all owner actions outside agent scope and none blocking implementation:
- Installing an extension release, which gates MCP adoption of the new validator rules (`human_interaction` response: `scope_change` to the Python CLI route, or a recorded `halt` until installation).
- Any GitHub ruleset change, if the owner wants review represented there. This research proposes none.
- The route decision in question 10.

## Testing Implications

Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix, with no single-process, seeded-shuffle, reversed-order, or comparison runs. Do not edit Epic #1019 feature folders.
- Ledger: in-memory fixtures plus read-only iteration of real entries; replay of one sample.
- G13: parity at the guideline and one above, with and without justification, on both sides of the cutoff and with no path.
- Light cycles: new corpus entries covering valid, design scope, absent scope, four findings, consecutive light, preflight object present, and full path without preflight; byte-identical strings across three runtimes.
- Merge: review passed with CI pending, CI green with review pending, stale head with code change, predecessor head with feature-folder change only, git failure, bare command, no key.
- Older shapes: existing fixtures unchanged and passing.
- Baseline: string-presence check before and after.

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: all 6 copies of the atomic-plan-contract skill describe the new rules.
- Complete Family: atomic-plan-contract
- Exhaustive Search Scope: the entire worktree tree, every SKILL.md file
- Inclusion Rules: a SKILL.md file whose frontmatter names the skill
- Exclusion Rules: feature documents that merely cite the skill
- Primary Search Strategy or Query Expression: ripgrep for the frontmatter text name: atomic-plan-contract over all SKILL.md files
- Primary Member Set: .claude/skills, .agents/skills, .github/skills, bundled claude-customizations, bundled codex-and-agents-customizations, bundled customizations
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: read the _ALL_CONTRACT_COPIES tuple for atomic-plan-contract in test_plan_gate_document_docs.py
- Cross-check Member Set: .claude/skills, bundled claude-customizations, .agents/skills, bundled codex-and-agents-customizations, .github/skills, bundled customizations
- Cross-check Count: 6
- Member-set Comparison: the normalized sets are equal

Supporting population, stated for the G13 decision and not proposed as an acceptance criterion:

- Numeric spec.md acceptance criterion: none; 16 plans above the current guideline all carry a justification.
- Complete Family (population): plan.*.md files in `docs/features/active/` written since G13, excluding the three named under question 2
- Primary (task-line count above 40): 980, 984, 990, 992, 995, 997, 1006, 1009, 1011, 1013, 1026, 1047, 1048, 1066, 1067, 1093 (16)
- Cross-check (files containing `## Size Justification`): the same 16 issue numbers; the predicates differ, and their equality is the finding.

## Pre-Mortem

- Review checklists: the policy-audit fail-closed text conflicts with less evidence if changed in the wrong order. Change template, skill, and installed-asset timing together, and treat the template lag as a stage 7 risk.
- Coverage: new modules fall inside the PowerShell, Python, and Jest populations; a new TypeScript file needs its own `coverageThreshold` entry, and blanket mocks cannot support a per-file floor.
- Mirror parity: each stage lists all copies; run the contract tests named in the `execution-environment` brief, the Codex generator `--check`, and re-baseline frozen hashes in the same commit. Non-identical copies of `atomic-plan-contract` are edited individually.
- File size: `enforce-epic-merge-gate.ps1` is near the 500-line guidance, so new logic goes into siblings; the Python validators add helper modules.
- Test isolation: no temporary files, in-memory replay only; Pester `global:` state from AST-loaded functions must be scoped and removed.
- CI-only behavior: the ledger test uses `Join-Path` and forward-slash paths; no test reads `artifacts/`; merge-guard suites run on the Linux hook job, so case and separators matter; `.gitattributes` normalizes line endings, so `Current` blocks must compare after line-ending normalization.
- Evidence: baseline tasks stay in every stage's plan; the ledger records evidence for each reduction, and no plan asserts a count from PoshQC MCP output.

## Rejected Alternatives

- Ledger replay on a real temporary copy: prohibited by the test policy.
- Python ledger test: the owner directs new tooling to PowerShell.
- G13 marker in plan text, or a Warning band for 21 to 40: an omittable marker, and a weakened rule.
- G13 with no mechanism: rests on `## Scope of Invocation`, but breaks "older plans stay valid" at a replan.
- New `review_gate` object: duplicates `review_outcomes`.
- Separate design-review agent: adds a delegation.
- Light path as `preflight.final_status: "clear"` with no preflight: an untruthful record.

## Unconfirmed Facts

- `CONFIRM-ORCHESTRATOR`: #1019 plans and their state are not in this tree: whether plans above 40 tasks truly lack the section, which have cleared preflight, and what installed MCP version validated them.
- `CONFIRM-ORCHESTRATOR`: current state of ruleset 15241672, including whether `CI Required Gate` is the required context and whether any review rule exists.
- `CONFIRM-ORCHESTRATOR`: #1094 merge state, final scope, and pre-merge text for the back-fill.
- `CONFIRM-ORCHESTRATOR`: installed extension version and release timing; the owner controls tag pushes.
- `CONFIRM-ORCHESTRATOR`: whether `git log --grep` on the branch is acceptable as the proof of one commit per reduction.
- Not traced: portable-handoff carriage of `stage_timing`, the exact bundled path of the policy-audit assets, and the contents of the `execute-hard-lock` and Copilot executor matches.
