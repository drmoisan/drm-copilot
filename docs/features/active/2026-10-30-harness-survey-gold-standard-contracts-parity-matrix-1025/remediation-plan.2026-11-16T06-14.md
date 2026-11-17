# Remediation Plan — Issue 1025, Cycle 2 (Findings R3, R4, R5)

- Issue: 1025
- Branch: feature/harness-survey-gold-standard-contracts-parity-matrix-1025
- Work Mode: full-feature
- Remediation-Mode: proportionate
- Inputs: `remediation-inputs.2026-11-16T06-14.md` (binding: `## Verification Commands`, `## Do Not Do`), `code-review.2026-11-16T06-14.md` (CR-9 to CR-14)
- Prior cycle: `remediation-inputs.2026-11-16T05-19.md`, `evidence/qa-gates/light-remediation-cycle-1.2026-11-16T06-00.md`
- `<FEATURE>` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`. SCRATCH is `<session scratchpad>/issue-1025/`; scratch files are named `issue-1025-*` and evidence records the token `SCRATCH`.
- Tool routes, launchers, the Pester and pytest routes and CI shape: the `execution-environment` skill. Gate composition: plan A `plan.2026-10-30T17-06.md` `## Gate Shape` (phase gate and Python contract set); this plan does not restate them.

## Scope

- Edit set: `.agents/skills/<name>/references/standard.md` and its byte-identical twin `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`, for the contracts named in Phase 1 and any contract the sweep in [P1-T7] fixes; evidence under `<FEATURE>/evidence/<kind>/`.
- Not edited: any `SKILL.md`, survey record, matrix, schema, module, test, spec acceptance criterion, approval artifact, `remediation-inputs.*.md`, or existing evidence file (append-only).
- Decisions (autonomous mode, recorded in the first task-check record that applies them):
  - D-C2-1: the `Resume Protocol` OB-4 items of `csharp-orchestration-state-machine` and `powershell-orchestration-state-machine` carry the copied ordinal form `On invocation: 1) ... 4) ...`, the same R3 ordinal-fragment form as `atomic-plan-contract` OB-4. The inputs' R3–R5 grep (`: 1) `) matches them. They are rewritten in [P1-T1] as one sentence that keeps all four steps. Reason: otherwise Verification Command 3 cannot return nothing.
  - D-C2-2: the inputs' non-remediation note leaves `powershell-qa-gate` unchanged. The coordinator's cycle 2 delegation directs the CR-14 nit to be applied, so [P1-T5] applies it. Reason: the owner's forethought rule says to fix related findings in the item.

## Rewrite Rules (apply to every item this plan edits)

1. Only the text after `- **OB-<n>** <Heading>: ` changes. The prefix, the number, the line order, every `## Objective` and every `- **AC-<n>**` line stay byte-unchanged, and each item stays on one line.
2. The item is one complete sentence with a subject and a finite verb. It states the behavior of the whole source section, meaning the `## <Heading>` section of `.agents/skills/<name>/SKILL.md`. Where that section enumerates a set or an order, the item names every member, in order where the source orders them.
3. Tool-neutral (spec `### Contract Format` rule 6): no runtime tool name (for example `Read`, `Bash`, an agent-spawn tool), no standing-instruction file name (`AGENTS.md`, `CLAUDE.md`), no runtime policy-mirror path, and no MCP tool name. The docs MCP tools are the exception (CR-13). Repository data paths such as `config/...` and `artifacts/...` stay allowed.
4. The new text matches none of the regression greps of `## Text Checks`, and it names no consuming product.
5. After each edit, the base file is copied byte for byte to its bundle twin.

## Defect Class Tests (used by [P1-T6])

- R1: the text ends in `;.`, `,.` or `:.`, or refers to text listed above or below.
- R2: an objective that holds a placeholder. It is checked by grep only, because objectives are outside the OB and AC rows.
- R3: the text is not a complete sentence. That covers a noun phrase or label-and-value naming one of several members, an ordinal fragment, a bare token, and a template placeholder. It also covers a demonstrative or relative reference (`These`, `This`, `that <noun>`, `the list`) to text that the item does not contain.
- R4: the source section enumerates two or more required members (inputs, outputs, fields, steps, sections, entries, skills, paths or modes), and the item names a proper subset as if it were the whole.
- R5: the behavior is stated through a mechanism named in rule 3.
- Accepted: a complete sentence stating one real rule of a multi-rule section (CR-12). Also accepted: a label-and-value naming the single required value of a single-valued section, and a mechanism name in a contract whose subject is that mechanism. Each acceptance on that last ground carries its reason.

## Text Checks

Both trees are `.agents/skills/*/references/standard.md` and the bundle twin tree. The checks are:

- (a) Contract lint: `Get-HarnessSkillContractViolation` from `scripts/harness/HarnessSkillContract.psm1`, through `sh SCRATCH/issue-1025-lint-contracts.sh` (written by the executor when absent), on the base and the twin of the named contracts. Pass: 0 violations.
- (b) Mirror identity: `cmp -s` of each named base contract against its twin. Pass: no differing pair.
- (c) Regression greps: greps 1 to 4 exactly as recorded under `## Greps` of `evidence/qa-gates/light-remediation-cycle-1.2026-11-16T06-00.md`, plus the inputs' R3–R5 grep (Verification Command 3), each over both trees. Pass: each exits 1 with empty output.

## Task Check (after every task that changes a contract)

Evidence: `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`. It lists the changed files, the selection and its rule, and each command with `EXIT_CODE:`. The checks are:

- Text Checks (a) and (b) over the changed contracts, and (c) over both trees.
- Format, lint and type check: N/A, because the changed files are Markdown.
- Pester selection: the launcher `pester` suite with `-TestPath` set to `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`. Pass: exit 0 and 0 failures.
- The plan A Python contract set (five modules) through the launcher. Pass: exit 0. An exit 75 is a queue timeout, re-run and recorded as such.
- A source-check table with one row per rewritten item: contract, OB id, source heading, the members the section enumerates, the members the new text names, the prior text, the new text, and the class closed (Verification Command 4).

A failed check is fixed and the task check is re-run into a new record.

### Phase 0 — Remediation Baseline

- [ ] [P0-T1] Record the pre-change contract text state in `<FEATURE>/evidence/remediation-baseline/cycle-2-contract-text.<timestamp>.md`. Record `Timestamp:`, the `Head:` read from `git rev-parse HEAD`, Text Checks (a) and (b) over all 65 contracts, and (c) over both trees with per-grep match counts. Acceptance: all 65 pairs show 0 lint violations and no `cmp` difference. Cycle 1 greps 1 to 4 return 0 lines. The R3–R5 grep returns exactly 11 lines per tree, which is the fail-before state. Those lines are the 9 named R3/R5 items plus the two D-C2-1 items.
- [ ] [P0-T2] Run one parallel Pester gate through the launcher `pester` suite as the `Phase 0 baseline`. Record it in `<FEATURE>/evidence/remediation-baseline/cycle-2-pester.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (the returned `ExitCode`) and `Output Summary:`. The summary holds tests, failures, errors and skipped from `artifacts/pester/pester-junit.xml`, the `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` counts, and the line coverage of `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1` and `scripts/harness/HarnessSkillContract.psm1` from `artifacts/pester/powershell-coverage.xml`. Acceptance: the artifact holds numeric values for every field.
- [ ] [P0-T3] Run the plan A Python contract set, the Codex generator `--check` and the tier check through their plan A routes. Record them in `<FEATURE>/evidence/remediation-baseline/cycle-2-contract-checks.<timestamp>.md`, with one `Command:`, `EXIT_CODE:` and `Output Summary:` block per command. Acceptance: each block holds its pass count or ok result. An exit 75 is recorded as a queue timeout and re-run.

### Phase 1 — Named Fixes and Source-Comparison Sweep

- [ ] [P1-T1] Fix finding R3 and D-C2-1 under `## Rewrite Rules` in `.agents/skills/<name>/references/standard.md` and its twin `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`. That is 10 items in 8 contracts:
  - `acceptance-criteria-tracking` OB-4: when the completion summary is required and what it holds.
  - `atomic-plan-contract` OB-4: all four blocks of the short-path minimal plan. OB-5: every required planner output of the minimal-audit directive.
  - `evidence-and-timestamp-conventions` OB-5: the full twelve-place discovery order, the default use of that order, and the remediation-reconciliation exception.
  - `policy-audit-template-usage` OB-2: the whole `## Required Steps` section.
  - `review-epic` OB-1: every input, naming the epic folder.
  - `skill-canonical-location-audit` OB-2: every audit workflow step. OB-3: every field of the per-item output.
  - `csharp-orchestration-state-machine` OB-4 and `powershell-orchestration-state-machine` OB-4: the four resume steps as one sentence.
  
  Acceptance: the [Task Check] passes, and the source-check table has 10 rows, each with every member named.
- [ ] [P1-T2] Fix finding R4, part 1, under `## Rewrite Rules` in `.agents/skills/<name>/references/standard.md` and its twin `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`. That is 9 items in 8 contracts:
  - `policy-compliance-order` OB-1: the full precedence order, stated tool-neutrally. It runs from the standing instructions to the cross-language code-change policy, then the cross-language unit-test policy, then the language or domain rules for files in scope (Python and its suppressions rule, PowerShell, TypeScript and its suppressions rule, C#).
  - `evidence-and-timestamp-conventions` OB-3: all five locations.
  - `csharp-orchestration-state-machine` OB-2 and `powershell-orchestration-state-machine` OB-2: every required checkpoint field.
  - `feature-promotion-lifecycle` OB-3: every canonical variable. OB-4: every required handoff output.
  - `feature-review-workflow` OB-1: every required shared skill.
  - `fill-feature-docs` OB-2: both output paths.
  - `pr-context-artifacts` OB-1: the summary and the appendix.
  
  Acceptance: the [Task Check] passes, and the source-check table has 9 rows whose named-member count equals the source member count.
- [ ] [P1-T3] Fix finding R4, part 2, under `## Rewrite Rules` in `.agents/skills/<name>/references/standard.md` and its twin `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`. That is 8 items in 4 contracts:
  - `invoke-csharp-engineer`, `invoke-powershell-engineer` and `invoke-python-engineer` OB-3: all five reporting-block entries. OB-5: every preloaded contract.
  - `execute-hard-lock` OB-2: both required resolver inputs, stated as the plan path and the calling checkout root, with no MCP tool name. OB-5: the delegation to the plan executor and all four preloaded shared skills.
  
  Acceptance: the [Task Check] passes, and the source-check table has 8 rows whose named-member count equals the source member count.
- [ ] [P1-T4] Fix finding R5 under `## Rewrite Rules` in `.agents/skills/<name>/references/standard.md` and its twin `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`. That is 4 items in 3 contracts:
  - `translate-copilot-to-claude` OB-2: reads the full source file, plus every other step of the Phase 1 section. OB-5: reads the existing target file when it exists, plus the rest of the Phase 4 section.
  - `orchestrate` OB-1: reads the repository standing instructions, plus every other prerequisite of the section.
  - `epic-plan` OB-1: reads the repository standing instructions, the applicable language policies, `config/orchestration-routing.json` and any existing epic-planner checkpoint.
  
  Acceptance: the [Task Check] passes, the R3–R5 grep returns 0 lines in both trees, and the source-check table has 4 rows, none of which names a rule 3 mechanism.
- [ ] [P1-T5] Apply the CR-14 nit (D-C2-2) to OB-2 of `.agents/skills/powershell-qa-gate/references/standard.md` and its twin `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/references/standard.md`. The coverage-check step carries a neutral form of the source qualifier, stating that it applies when the task or repository flow enforces it. The rest of the item is unchanged. Acceptance: the [Task Check] passes, and its source-check row shows the qualifier against `## Toolchain Execution Sequence` step 4.
- [ ] [P1-T6] Compare every item of all 65 contracts with its source, using the reviewer's source-comparison method and `## Defect Class Tests`, and write `<FEATURE>/evidence/other/source-comparison.<timestamp>.md`. There is one row per OB item (262) and one per AC item (327). Each row holds: contract, id, source heading, class (or `none`), disposition (`accepted`, `fixed-P1-T<M>`, or `fix-required`), and reason.
  - An AC row is `accepted` when its text is one of the two template forms, its per-behavior form names the heading of its cited OB, and the closing AC cites every OB. The template count is 327.
  - These candidates each need an explicit reasoned disposition: the nine canonical discovery contracts (`adjudicate-unspecified-behavior`, `characterize-runtime-behavior`, `extract-feature-contract`, `generate-acceptance-scenarios`, `initialize-discovery-workspace`, `inventory-legacy-system`, `reconcile-parity-matrix`, `review-discovery-coverage`, `validate-discovery-artifacts`) OB-1, OB-2 and OB-3; `human-exception-runbook` OB-2; the C#, PowerShell and Python `qa-gate` OB-4; the three `invoke-*-engineer` OB-1 and OB-4; `make-skill-template` OB-1; `fill-feature-docs` OB-1; `pr-author` OB-1 and OB-3; `research-issue` OB-1; `execute-hard-lock` OB-1; `csharp-change-budget-router` OB-1 and OB-4; `powershell-change-budget-router` OB-1; `execution-environment` OB-3 and OB-4; `review-staged`, `review-feature` and `update-status` OB-1.
  - A CR-12 item is `fix-required` only with its failing class test stated.
  
  Acceptance: 589 rows, a per-disposition count summary, and no row without a reason. No tracked file changes.
- [ ] [P1-T7] Fix every `fix-required` row of the newest `source-comparison.*.md` under `## Rewrite Rules`, each contract with its twin. Write `<FEATURE>/evidence/other/sweep-fixes.<timestamp>.md` with one row per fixed item: contract, id, class, source heading, prior text, new text, disposition `fixed`. Then add a row count that equals the `fix-required` count. Acceptance: the [Task Check] passes over the contracts changed here. When the count is zero, the record states so, no contract changes, and the task check records an empty selection.
- [ ] [P1-T8] [phase-gate] Run the plan A `## Gate Shape` phase gate (stages 1 to 6), and write `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md`. Acceptance: no test fails that did not fail in `cycle-2-pester`, PSSA reports no finding beyond `pssa-baseline`, and every contract command exits 0. A failure or auto-fix restarts the gate at stage 1.

### Phase 2 — Final QA

- [ ] [P2-T1] Run the PowerShell static stage as the plan A phase gate defines it: a check-only format run and PSSA over `scripts` and `tests/scripts`. Record it in `<FEATURE>/evidence/qa-gates/final-qc-static-powershell-c2.<timestamp>.md`, with each step's command, exit code and finding count. Acceptance: `git status --porcelain` output is identical before and after the format step, and PSSA reports no finding beyond `pssa-baseline`.
- [ ] [P2-T2] Run one parallel Pester gate through the launcher `pester` suite, and record it in `<FEATURE>/evidence/qa-gates/final-pester-c2.<timestamp>.md` with the [P0-T2] fields. Acceptance:
  - `EXIT_CODE: 0` and 0 failures.
  - `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` shows all Its passed with 0 skipped.
  - Each of the three harness modules has line coverage of at least 85% and no lower than in the newest `cycle-2-pester.*.md`.
- [ ] [P2-T3] Run the plan A Python contract set, the Codex generator `--check` and the tier check, and record them in `<FEATURE>/evidence/qa-gates/final-contract-checks-c2.<timestamp>.md`. Acceptance: each command exits 0 (an exit 75 is re-run and recorded as a queue timeout), and the pass count is not below the newest `cycle-2-contract-checks.*.md`.
- [ ] [P2-T4] Run Text Checks (a) and (b) over all 65 contracts and (c) over both trees. Record them in `<FEATURE>/evidence/qa-gates/final-contract-text-c2.<timestamp>.md`, together with the total of source-check rows from the Phase 1 task-check records. Acceptance:
  - 0 lint violations and no differing `cmp` pair among 65.
  - Every grep exits 1 with empty output; the R3–R5 grep was 11 lines per tree in [P0-T1].
  - Source-check rows: 32 named (29 findings, 2 under D-C2-1, 1 under CR-14), plus the `sweep-fixes` count.
- [ ] [P2-T5] Check scope. Run `git diff --name-only` against the `Head:` value of the newest `cycle-2-contract-text.*.md` together with `git status --porcelain`, and record both in `<FEATURE>/evidence/qa-gates/scope-c2.<timestamp>.md`. Acceptance: every listed path is a `references/standard.md` under one of the two trees, a file under `<FEATURE>/evidence/`, or this plan file. Every changed base contract has its twin listed. No `SKILL.md`, survey, matrix, schema, module, test, spec or remediation-inputs path is listed.
- [ ] [P2-T6] Walk the three templates under `docs/features/templates/policy_audit/` (`policy-audit`, `code-review`, `feature-audit`) against the branch diff from the merge base of the base branch and `HEAD`. Write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`, with one PASS, FAIL or N/A row per checklist item and a row for each of R3, R4, R5, CR-14 and the sweep. Acceptance: no FAIL row. A FAIL is fixed, the loop restarts at [P2-T1], and a new self-review is written.

Any failure or file change in [P2-T1] to [P2-T5] is fixed, and the final QA loop restarts at [P2-T1].

## Pre-Mortem

- Review checklists: [P1-T6] repeats the reviewer's source-comparison method over all 589 items, with a named candidate floor. [P2-T6] walks all three review templates before handoff.
- Coverage: no production file changes. [P2-T2] compares the three harness modules' line coverage from the single gate run with the [P0-T2] `Phase 0 baseline` and the 85% line threshold. PowerShell has no branch gate.
- Mirror parity: each task copies the base to its twin, and the task checks and [P2-T4] run `cmp` over the pairs. No fact of the execution-environment brief changes, because the `execution-environment` contract is not the brief and no `SKILL.md` copy is edited, so no brief-update task is needed.
- File size: not applicable. The changed files are Markdown, which is exempt, and each contract is far below 500 lines.
- Test isolation: the gates are one `Invoke-PoshQCParallelTest` run through the launcher per gate ([P0-T2], [P1-T8], [P2-T2]). The Python contract set runs through the launcher, whose `pytest -n auto` workers run it in parallel. No Jest runs, because no TypeScript is in scope. Each gate is re-run only after a fix or an exit 75. There are no serial, single-process, shuffled or reversed runs, and no temporary files in tests.
- CI-only behavior: `poshqc / PowerShell QC` runs the repository gate in CI (spec `Required CI check`, checked off at S9). Contract text has no CI-only failure class, and CRLF is not relevant because `cmp` compares committed bytes.
- Evidence: every artifact is new, under `<FEATURE>/evidence/<kind>/`, and stamped with the UTC write time read from the clock. Consumers select the newest `<name>.*.md`. No evidence file is edited or deleted, and evidence records `SCRATCH` instead of host paths.
