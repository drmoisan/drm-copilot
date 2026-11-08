---
name: atomic-plan-contract
description: 'Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops.'
---

# Atomic Plan Contract

Shared rules for atomic plan formatting, Phase 0 requirements, baseline capture, and final QA loops.

## When to Use This Skill

Use this skill when:
- Creating or validating atomic plans.
- Executing plans with strict format requirements.
- Enforcing Phase 0 baseline capture and final QA loops.

## Canonical Plan Format

- Phase headings must be: `### Phase N — <Title>`
- Tasks must start with: `- [ ] [P#-T#]` (or `[x]` for completed)
- Task IDs must match their phase and be sequential per phase.
- Plans must pass the `validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>` before they can be reported as approved.

## Design-Level Plan Contract (Mandatory)

A plan is a design-level document: it states what changes and how the change is proven, not a transcript of commands. Every task names the files it creates or edits, the symbols, headings, or tests it touches, the behavior the change produces, the tests that prove that behavior, and an acceptance condition stated as an observable outcome.

Rules:

- **Anchors are symbols, headings, or test names.** A plan never cites a line number, a `path:line` locator, a `#L` anchor, or a commit SHA, because each goes stale when `main` moves (validator rules G11 and G12). Scope comparisons name the merge-base derivation of `origin/main` and `HEAD`, not a commit.
- **Literals only where they are the asserted value.** A plan quotes a literal when an acceptance condition asserts that exact value. It does not quote file contents, command output, or prose for context.
- **Tool routes are not restated.** Tool routes, launchers, wrapper scripts, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill. A plan references that skill instead of restating its content.
- **Changed existing behavior names its asserting tests.** A task that changes the observable behavior of an existing function, script, fixture, or test stub (its signature, argv, output, exit status, or the files it writes) names every existing test that asserts that behavior and states each test's disposition: unchanged because it is unaffected, or updated, with the reason for the update. The tests are found by searching the test tree for the symbol, the file name, and the asserted output. A test that asserts the current behavior and is outside the task's file set fails once the change lands, and the plan's own acceptance condition then cannot be met. The planner's adversarial self-review includes this search for every task that changes existing behavior.
- **Size guideline.** A plan stays within 20 canonical tasks and 250 physical lines. A plan file stamped before `PLAN_GUIDELINE_CUTOFF` (the instant of the G13 commit, compared in the zone of each stamp shape) keeps the legacy pair of 40 canonical tasks and 400 physical lines, and a plan validated without a path uses the new pair. A plan that needs more carries a `## Size Justification` section with at least one line stating why the size is necessary (validator rule G13). Files produced by one generator run count as one generator task. The installed MCP validator applies 40 and 400 until a release carrying the lowered guideline is installed, so the planner's MCP self-check does not report a plan between the two pairs: the planner holds a new plan to 20 tasks and 250 lines itself, and preflight applies the new pair through the Python CLI route of `## Validator Gate`.
- **Task target.** A plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states.
- **Pre-Mortem.** Every plan carries a `## Pre-Mortem` section with one bullet beginning with each of the seven labels `Review checklists`, `Coverage`, `Mirror parity`, `File size`, `Test isolation`, `CI-only behavior`, and `Evidence`. Each bullet states how the plan prevents that failure class, or states "not applicable" followed by the reason. The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix. The `Mirror parity` bullet also covers the execution-environment brief: a plan that alters a fact the brief states (for example, it adds or renames a CI job, changes a required status context, a tool route, or a batch-budget rule) includes a task that updates the brief in the same change, in all six byte-identical copies, and the bullet names that task. Without that task the brief states a superseded fact once the change lands, which breaks the brief's own maintenance rule. The planner SubagentStop hook blocks a plan without a complete section.
- **Final-phase self-review.** The final phase of every plan contains a self-review task that walks the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base and writes `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. A FAIL row is fixed and the QA loop is re-run before the self-review is rewritten; the plan does not complete with a FAIL row.

This section takes precedence over the literal-quoting rules of `## Wrap-Tolerant Assertion Authoring (Mandatory)`: those rules govern the asserted value of an acceptance condition, not context.

## Process-Reduction Ledger

- This rule applies only when `docs/engineering/process-reductions/` exists, so a repository without that folder is unaffected.
- A change that reduces evidence, plan tasks, gates, or review process adds its ledger entry in the same commit, in the format of that folder's `README.md`.
- One-off waivers for a single item are not entries.

## Short-Path Minimal Plan Contract

When orchestration selects short path, a minimal plan is still mandatory and must include these blocks:

1) Baseline capture block
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
- required artifacts:
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.

2) Delegated implementation block
- explicit handoff task to the small-path implementation engineer,
- acceptance criteria for implementation completion.

3) Final QC block
- full language-appropriate QA loop (format → lint → type-check when applicable → test),
- rerun behavior when any step changes files or fails.
- one final-QC static artifact per language records the format, lint, and type-check steps of that language, and each test gate keeps its own final-QC artifact (no aggregate-only final-QC artifact across languages or gates)
- the static artifact and each test-gate artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; the static artifact records each step's command, exit code, and finding count
- final-QC test commands for languages with mandatory coverage policy MUST run in coverage mode and record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
- final-QC command tasks that are present in the approved plan MUST execute their stated commands; `SKIPPED` is invalid unless the task text itself explicitly authorizes a skip condition.

4) Reduced audit block
- explicit post-implementation small-audit handoff,
- reduced artifact checks required by short-path policy.

## Minimal-Audit Directive Contract (Small Path)

For short-path planning handoffs, orchestrators MUST include:
- `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`

Required planner outputs for this directive:
- plan MUST use `${feature-folder}/issue.md` as sole requirements source,
- plan MUST require `${feature-folder}/issue.md` to contain an explicit `## Acceptance Criteria` section and MUST treat only that section as the minor-audit AC source,
- plan MUST NOT require `spec.md`/`user-story.md`/`research.md`,
- plan MUST include exactly 3 phases:
	- Phase 0 baseline capture,
	- Phase 1 placeholder for constrained small-path implementation,
	- Phase 2 final QC loop,
- final-QC command tasks in the generated plan MUST be unconditional when present; no IN_SCOPE/OUT_OF_SCOPE branches and no SKIPPED completion path unless the task text explicitly authorizes a skip branch,
- planner MUST return `plan-path` and final preflight signal.

## Phase-0-Only Execution Contract (Small Path)

After preflight all-clear on the minimal-audit plan:
- orchestrator MUST delegate to executor to run Phase 0 only,
- orchestrator MUST checkpoint Phase 0 evidence before branching.

Branching after Phase 0:
- `manual bootstrap` → save state and stop for manual resume ONLY when the initial user request explicitly opted into manual orchestration from the beginning,
- otherwise continue with constrained small-path development, then executor validation, then reduced audit/remediation loop.

## No-Manual-Step Contract (Mandatory)

Unless the user's initial request explicitly opts into manual orchestration from the beginning, approved plans and remediation plans MUST remain fully automated.

This prohibition includes:

- manual bootstrap pauses,
- human-operator validation tasks,
- user-performed repro or QA steps,
- requests for screenshots, notes, or runtime evidence that the agent cannot collect itself.

When a fully automated equivalent is unavailable, the plan MUST fail closed by recording blocked or remediation-required automated state. It MUST NOT introduce a new manual step later in the workflow.

## Phase 0 Requirements

Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.

Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

`Output Summary:` is mandatory for each command-step artifact and must concisely summarize the essential result signal (for example: pass/fail status, key counts, coverage headline, or primary diagnostic).

## Evidence Filename Timestamps in Plans

Plans name evidence artifacts `<name>.<timestamp>.md` and never fix a plan-time stamp in an evidence filename. An acceptance condition identifies a consumed evidence artifact by the derivation in `evidence-and-timestamp-conventions` (`### Evidence Filename Timestamp`): the lexicographically greatest file matching `<name>.*.md`, not a pre-stamped literal path. This section governs artifact paths only: asserted search tokens remain concrete.

## Coverage Evidence Contract (Mandatory when policy requires coverage)

For any language in scope where repository policy requires coverage validation:

- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
	- post-change coverage,
	- new/changed-code coverage.
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
- If required coverage values are unavailable, the plan outcome MUST be remediation-required and MUST NOT be reported as PASS.

## Final QA Loop (Required for Code/Test Changes)

Run the full toolchain loop for each applicable language in order:
1) Formatting
2) Linting
3) Type checking (if applicable)
4) Testing

For languages with mandatory coverage policy, step 4 must use coverage-enabled test commands and persist numeric coverage evidence.

If any step fails or changes files, restart the loop from step 1 until a clean pass completes.

The format, lint, and type-check results of each language are recorded in one final-QC static artifact per language, with each step's command, exit code, and finding count; reviewers read that artifact and do not re-run format, lint, or type checks.

## No-SKIPPED Rule for Planned Command Tasks

For command-bearing tasks in approved plans (especially Phase 2 final-QC tasks):
- if the task exists in the plan, the command must be executed and recorded,
- `EXIT_CODE: SKIPPED` MUST NOT be used as a passing outcome,
- exceptions are allowed only when the task text itself explicitly contains a skip branch and that branch is intentionally approved in requirements.

## Expect-Fail Test Tasks

Any regression test task expected to fail must be tagged with `[expect-fail]` and include an auditable evidence artifact per `evidence-and-timestamp-conventions`.

## Preflight Validation (Planner ↔ Executor)

When validating or handing off plans for execution:
- Put the directive line `DIRECTIVE: PREFLIGHT VALIDATION ONLY` in the delegation prompt. The preflight directive belongs in the delegation prompt, never in a plan file.
- Require one of the exact signals:
	- `PREFLIGHT: ALL CLEAR`
	- `PREFLIGHT: REVISIONS REQUIRED`
- If revisions are required, provide a precise plan delta with one `PREFLIGHT-DEFECT:` line per substantive defect. A plan returns to the planner at most once.
- If the required planner ↔ executor handoff cannot be started or completed, stop and report blocked state; do not self-approve the plan.

### Single-Pass Preflight

- **Review the entire plan in one pass.** The preflight executor checks every phase, task, and prose region and does not stop at the first defect.
- **Classify every defect as trivial or substantive.** Trivial defects are a stale or misspelled anchor, symbol, heading, or path whose intent is unambiguous; a citation correction, including removal of a G11 line-number or G12 commit-SHA citation; a typo; a literal-formatting defect that does not change what is asserted; and an evidence filename spelling. Substantive defects are a missing or extra task; a wrong file set or design; an acceptance criterion with no implementing task; an acceptance condition whose correction changes what is asserted; a task-ordering error; and a scope-boundary violation.
- **Fix trivial defects in place, in task text only.** The preflight executor edits task text and plan preamble in the same plan file and never adds, removes, or reorders tasks. Each fix is recorded in `<FEATURE>/evidence/other/preflight-fixes.<timestamp>.md`.
- **Return substantive defects only, all of them.** `PREFLIGHT: REVISIONS REQUIRED` is returned only when at least one substantive defect remains, and it lists every one. `PREFLIGHT: ALL CLEAR` may follow in-place fixes.
- **Run the design check.** Within the same single pass, with no new delegation and no new artifact, the preflight executor reads the feature's spec.md (or the Acceptance Criteria of issue.md when the folder has no spec.md) and, for each rule, parameter, and boundary it states, names the task that implements it and the test that would fail if the rule were broken. A rule, parameter, or boundary with no implementing task, or with no test that would fail if it were broken, is a substantive defect and is returned as a `PREFLIGHT-DEFECT:` line; it extends the substantive class that already holds an acceptance criterion with no implementing task. The pass records nothing beyond those lines.

Output format. After the `PREFLIGHT:` signal, the return carries one line per defect:

- `PREFLIGHT-FIX: <task id or heading> | <defect class> | <change made>`
- `PREFLIGHT-DEFECT: <task id or heading> | <defect class> | <required change>`
- `preflight-fix-record: <path>` when at least one fix was made.

`PREFLIGHT: ALL CLEAR` carries no `PREFLIGHT-DEFECT:` line, and `PREFLIGHT: REVISIONS REQUIRED` carries at least one.

At most one return. On `PREFLIGHT: REVISIONS REQUIRED`, the orchestrator delegates one planner revision carrying the full `PREFLIGHT-DEFECT:` list and runs one more preflight. If that preflight still reports a substantive defect, the orchestrator halts with `blocked_reason: "validator_failed"` during planning, or records `final_status: "blocked_preflight_iteration_limit"` in a remediation cycle.

Light cycles. A remediation cycle recorded with `Remediation-Mode: light` has no remediation plan and no preflight; its executor runs the inputs file directly. When that executor stops with `BLOCKED at preflight (before [P0-T1])` before the first task, the cycle converts to the design chain, and the remediation plan it then receives follows this section.

## Validator Gate (Mandatory)

Before a plan can be treated as approved:

- run the `validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>`,
- reject the plan if that validator exits non-zero,
- do not treat human-readable summaries as a substitute for validator success.

The validator applies the acceptance-gate rules of `.claude/rules/plan-acceptance-gates.md`. G1 through G9 judge the commands a plan states as acceptance conditions; G10 reports a SCRATCH definition not namespaced by issue number; and the document-level rules G11, G12, and G13 report a line-number citation, a commit-SHA citation, and a plan above the size guideline without a non-empty `## Size Justification` section. The complete shipped set is therefore G1 through G13. The installed MCP validator applies G11 through G13, and the lowered G13 guideline with its cutoff, only after the extension release that carries them is installed; until then, validate a plan with the repository's Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py` and its `plan` subcommand, as the `execution-environment` skill states.

## Plan-Path Continuity Contract (Mandatory)

When a caller provides an explicit target plan file path (for example `${plan-path}` or `${file}`):

- Planner MUST update that exact file in place.
- Planner MUST reuse the same file for the single permitted preflight revision.
- Planner MUST NOT create additional timestamped sibling files (for example `plan.<timestamp>.md`) during the same planning cycle.

If the provided path does not exist, it may be created once, then reused for the single permitted revision in that cycle.

## Mode source precedence (Mandatory)

When a plan is generated or validated from a feature folder, resolve selected mode in this order:

1) Persisted marker in `issue.md` metadata block:
	- `- Work Mode: minor-audit`
	- `- Work Mode: full-feature`
	- `- Work Mode: full-bug`
2) Legacy compatibility marker `- Work Mode: full` resolves to `full-feature`
3) Explicit workflow override only when repo policy allows and only when reconciled against `issue.md`
4) Fail closed to `full-feature` when marker is missing or malformed

## Mode-Specific Mandatory Plan Gates

- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
- `minor-audit` plans MUST require `${feature-folder}/issue.md` to contain an explicit `## Acceptance Criteria` section; do not infer acceptance criteria from other `issue.md` sections.
- `minor-audit` plans MUST NOT treat missing `spec.md` or `user-story.md` as automatic blockers.
- `minor-audit` execution/validation/audit MUST fail closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, when the explicit `## Acceptance Criteria` section is missing from `issue.md`, when required Phase 0 artifacts are missing, or when checklist state contradicts evidence on disk.
- `full-feature` plans MUST enforce full-document expectations (`spec.md` + `user-story.md`) and full QA loop obligations.
- `full-bug` plans MUST enforce spec-driven expectations (`spec.md` required, `user-story.md` optional/absent by default) and full QA loop obligations.
