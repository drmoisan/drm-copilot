# `2026-10-30-harness-survey-gold-standard-contracts-parity-matrix` — User Story

- Issue: #1025
- Epic: #1018, child 1
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T21-40
- Spec: `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md`

In this document `<FEATURE>` means `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`. Section references (for example `### Contract Format`) point to `spec.md`.

## Story Statement

- As the epic owner, I want every skill compared by content, every difference classified against the skill's objective and presented for bulk approval with disputed cases separated, so that I decide once and only spend individual attention on cases that change enforcement or conflict on authority.
- As the epic owner, I want every native feature of every ecosystem to carry a disposition in a machine-readable matrix guarded by a test in a required CI check, so that no native capability is lost without a written reason I approved.
- As the epic owner, I want the experiments that need VS Code, the Copilot CLI, the Copilot cloud agent or Codex delivered as runbooks I can follow in a scratch repository, with one stop for all my input, so that the design is based on observed behavior and I am interrupted once.
- As the maintainer of child 3 (generators), I want the matrix dispositions, `generated_from`, `target_paths` and the contract format stated as a fixed interface, so that my generators and `--check` modes read them without interpreting prose.
- As the maintainer of child 4 (push-down consolidation), I want to know where the contracts and their bundle copies live and that no pack-manifest entry was added, so that I can decide their delivery without undoing child 1's work.
- As the maintainer of child 5 (hook parity), I want every hook registration, permission and subagent frontmatter field inventoried with a `parity_group`, so that I can prove parity of function across ecosystems.
- As the maintainer of child 6 (retirements and the thin Copilot layer), I want the Copilot dispositions, the `consumers` values and the experiment results recorded with an approval status, so that I retire `.github/skills` and `.github/agents` only on approved decisions.

## Problem / Why

Epic #1018 restructures the three agent ecosystems in this repository (Claude Code, Codex and GitHub Copilot) onto shared cross-tool conventions. Before any generator, push-down or retirement work can start, the epic needs three settled inputs that do not exist today:

- A content-level comparison of every skill name across `.claude/skills`, `.agents/skills` and `.github/skills`. The existing heading comparison overstates differences because the same topic appears under different headings or in a different artifact of the same ecosystem.
- A tool-neutral gold-standard contract for each shared skill, against which each ecosystem's expression can be judged.
- A machine-readable parity matrix that gives every native feature of every ecosystem a disposition, so later children can prove that no native capability is lost.

Several behaviors that the design depends on are also unverified: Copilot duplicate-skill listing, Codex tolerance of Claude-only frontmatter, whether the Copilot CLI and cloud agent read `.claude/agents`, whether Copilot settings work at workspace scope, and whether Copilot loads rules twice with default settings.

## Personas & Scenarios

- Persona: Epic owner (drmoisan)
  - Owns the confirmed design of epic #1018 and approves dispositions and classifications.
  - Cares that no native capability is lost and that each tool loads each skill and instruction once.
  - Constraint: has limited time for review; can run VS Code, the Copilot CLI, the Copilot cloud agent and Codex, which an agent session cannot.
  - Goal: one approval pass over a bulk set plus a short list of disputed cases.
- Persona: Downstream child maintainer (children 3 to 6, agent or human)
  - Implements generators, push-down consolidation, hook parity or Copilot retirements.
  - Cares about stable, precisely specified inputs: file paths, field names, enums and conditional rules.
  - Constraint: new tooling is TypeScript or PowerShell; reads the matrix JSON directly.
  - Frustration: prose-only specifications that must be reinterpreted in each child.

- Scenario: Owner approval at the single stop
  1. Execution completes the survey, the classification, the bootstrapped matrix, the contracts for the Claude-and-Codex shared names, the E5 result and the five runbooks, then records the stop with `blocked_reason` `human_decision_required`.
  2. The owner opens `<FEATURE>/survey/difference-approval.md`, reviews the bulk set, decides each disputed case, answers or accepts the default for Q1 to Q8, and sets `Approval-Status`.
  3. The owner runs the runbooks in a scratch repository and records each result with the template, or records a deferral.
  4. Execution resumes, applies the decisions to the survey records, contracts and matrix, marks settled entries `approved`, and re-runs the gates.
- Scenario: Child 3 maintainer builds the skill mirror generator
  1. Reads `config/harness-parity-matrix.json` and selects `claude:skill:*` entries with disposition `generated`.
  2. Uses `generated_from` as the source and `target_paths` as the output.
  3. Uses the contract at `.agents/skills/<name>/references/standard.md` to judge the neutral body and the approved positives (class `positive`, recorded port direction) to port.
  4. Keeps `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` green as features change.

## Acceptance Criteria

### Epic owner

- [ ] `<FEATURE>/survey/skill-survey.md` has exactly one row for each skill folder name in the union of `.claude/skills`, `.agents/skills` and `.github/skills`, and a zero-difference comparison against a fresh enumeration of the three trees is recorded in `<FEATURE>/evidence/baseline/`.
- [ ] Every recorded difference has a class from `positive`, `negative`, `neutral`, `mechanism-only` and a port direction, and appears exactly once in `<FEATURE>/survey/difference-approval.md`, either in `## Bulk Approval Set` or under `## Disputed Cases` according to the disputed-case rules in `### Owner Approval Artifact`.
- [ ] `<FEATURE>/survey/difference-approval.md` records my decision: `Approval-Status` `approved` or `approved-with-overrides`, `Approved-By`, `Approved-At`, an `Owner-Decision` for each disputed case, and an answer or accepted default for each of Q1 to Q8.
- [ ] Every `dropped` entry in `config/harness-parity-matrix.json` has a non-empty `reason` and a `decision_ref`, enforced by `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`.
- [ ] The completeness gate fails on an inventoried feature without an entry, a missing disposition, a `dropped` entry without a reason, and an unknown enum value, and passes on the committed matrix, as shown by the named tests in `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` and the `poshqc / PowerShell QC` check on the pull request head.
- [ ] The E5 result is recorded in `<FEATURE>/evidence/other/`, and the E1, E2, E3, E4 and E6 runbooks exist under `<FEATURE>/runbooks/` with the five required sections and a result template.
- [ ] Each of E1, E2, E3, E4 and E6 has a recorded result under `<FEATURE>/evidence/other/` or a recorded deferral in the approval artifact, with dependent matrix entries left `provisional`.
- [ ] Execution stopped once for owner input, recorded with `blocked_reason` `human_decision_required` and one `human_interaction.requirements[]` entry per pending item, preserved in `<FEATURE>/evidence/other/`.
- [ ] No new `.py` file is added, no file added or changed exceeds 800 lines, and no excluded path in `### Excluded paths (must not be edited by this child)` is changed, each recorded in `<FEATURE>/evidence/qa-gates/`.

### Child 3 to 6 maintainers

- [ ] `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` exist at those paths, the schema is Draft 2020-12 with the `$id` in `### Parity Matrix: Location and Format`, and the schema-module agreement test in `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes.
- [ ] Every entry carries `id`, `ecosystem`, `kind`, `name`, `source_path`, `disposition`, `parity_group`, `consumers`, `owner_child` and `decision_status` with values from the enums in the spec, and `shared` and `generated` entries carry non-empty `target_paths` (`generated` also `generated_from`); verified by `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`.
- [ ] Every hook registration, permission and subagent frontmatter field inventoried by `scripts/harness/HarnessInventory.psm1` has a matrix entry with a `parity_group`; verified by `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`.
- [ ] For every `codex:skill:<name>` entry with disposition `shared`, `.agents/skills/<name>/references/standard.md` satisfies `### Contract Format` (H1, exactly three H2 headings in order, gap-free `OB-<n>` and `AC-<n>` identifiers, every citation resolved, no checkboxes); verified by `tests/scripts/harness/HarnessSkillContract.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`.
- [ ] Each contract has a byte-identical bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`, no pack-manifest entry is added, and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` passes.
- [ ] Each per-skill survey record uses the shape in `### Survey Records` with stable `D-<skill-name>-<nn>` Diff IDs that the approval artifact references.
- [ ] Every `copilot:*` entry whose value depends on an experiment carries `decision_status` `approved` after its result is recorded, or `provisional` with a `decision_ref` of the form in `### Decision Reference Format`.
- [ ] Each of `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1` and `scripts/harness/HarnessSkillContract.psm1` has at least 85% line coverage, recorded per file in `<FEATURE>/evidence/qa-gates/`.

## Non-Goals

- Re-opening any confirmed design decision in the epic record.
- Editing any `SKILL.md`, linking a contract from a `SKILL.md`, or porting approved positives (child 3, Q2 and Q4).
- Adding pack-manifest entries for the contracts (child 4, Q1).
- Implementing generators, push-down changes, hook changes or Copilot retirements (children 3 to 6).
- Committing `.vscode/settings.json` or changing `.gitignore` (child 6, Q5).
- Adding any new Python file.
- Editing files in the blast radius of the parallel run `bugs-1001-1002-1003-1006`.
