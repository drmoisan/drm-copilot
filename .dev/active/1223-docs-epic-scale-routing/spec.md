# 2026-11-23-docs-epic-scale-routing — Spec

- **Issue:** #1223
- **Parent (optional):** epic #1217 (documentation-estate-families), child `docs-epic-scale-routing`
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23T05-58
- **Status:** Draft
- **Version:** 0.2

## Overview

The `documentation-workflow` skill assumes one run, one pull request, and docs-only paths. A first full documentation estate, or an estate large enough that one run cannot author and review it in a single pass, has no documented route. The reference estate in `rgf-forecast` (`docs/features/epics/comprehensive-documentation/epic.md`) needed an epic with dependency waves of documentation families, which the workflow does not describe.

This feature adds guidance text to the skill, a behavior and check to its standard, and a Pester contract test that pins the guidance in every copy. It changes no library, MCP, or hook behavior.

Work mode: full-feature. Decisions D1 to D4 are taken from the research record `research/research.2026-11-23T05-50.md` and are recorded under `## Decisions`.

## Behavior

- `documentation-workflow` states when a documentation run routes through `epic-plan` instead of a single run: a first full estate, or an estate whose planned page count exceeds a stated default page threshold of more than 40 planned pages.
- It states a default family-wave decomposition over the family ids of the epic Shared Design (owned by docs-family-profile-model).
- Each epic child runs the documentation-workflow dispatch order for its families only.
- The docs-complete receipt (family semantics owned by docs-family-gate-and-ia) is written once on the integration branch at its head, before the integration pull request, and no wave child writes or commits a receipt.
- Existing statements that conflict with epic routing are qualified so that they apply to the single-run route.
- A Pester contract test reads the skill text in every copy for the threshold, the wave order, the dispatch and receipt statements, the section placement, and the absence of family-record field names.

## Inputs / Outputs

- Inputs: the skill source `.agents/skills/documentation-workflow/SKILL.md` and `.agents/skills/documentation-workflow/references/standard.md`; the Shared Design of `.dev/epics/documentation-estate-families/epic.md`.
- Outputs: edited skill and standard text; regenerated Claude copies; byte-copied Codex bundle copies; one new Pester suite; one added suite name in each execution-environment brief copy.
- Config keys and defaults: none. The threshold is skill text only (D3); no profile option is added.
- Versioning or backward-compatibility constraints: the two `find` spans in `scripts/harness-generation/sources/skills/documentation-workflow.substitutions.json` (the `## Prerequisites` sentence and the agent-link lines of `## Dispatch Order`) must still match exactly once, so the edit must not alter them.

## API / CLI Surface

No command, flag, or request shape changes.

- Generator write: `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills`
- Generator check: the same command with `-Check`; exit 0 is clean, exit 1 reports drift.
- Contract and validation rules: the new `## Epic-Scale Routing` section is validated by the new Pester suite; `references/standard.md` is validated by `Get-HarnessSkillContractViolation` in `scripts/harness/HarnessSkillContract.psm1`.

### Required content of `## Epic-Scale Routing`

1. Routing: a first full estate, or more than 40 planned pages, routes through `epic-plan` started from the main session. Otherwise the single-run route applies. The epic-worthiness verdict of `epic-plan` can return the work to the single-run route. The value is a default, and deviating from it is a recorded decision.
2. Default decomposition, in this order:
   - Wave 0, foundation: profile and `docs-init`, the `docs-plan-ia` information architecture and family plan, templates, docs CI, and the root inventory. Wave 0 owns no family id.
   - Wave 1: `architecture`, `adr`, `reference`, `product-overview`, `getting-started`.
   - Wave 2: `user-guides`, `administration`, `security` (with repository-root `SECURITY.md` and `CODEOWNERS`).
   - Wave 3: `operations`, `service-management`.
3. Ownership: the family ids are owned by docs-family-profile-model, and the profile's family list is authoritative. The skill does not restate the family record fields.
4. Dispatch: each child runs the `## Dispatch Order` for its families only. `docs-init` and the root inventory step run in the foundation child.
5. Receipt: written once on the integration branch at its head before the integration pull request; no wave child writes or commits a receipt. Docs-complete family semantics are owned by docs-family-gate-and-ia and are cited, not restated.

### Qualifications of existing statements

| Section | Qualification |
| --- | --- |
| `## When to Use This Skill` | Seven skills for a single run; `epic-plan` for the estate route. The no-authority sentence stays. |
| `## Commit, Receipt and Pull Request` | The stage applies to the single-run route; epic children use orchestrator pull request stages. |
| Docs path set rule (same section) | Applies to the checkpoint-free single run; the security-wave child may carry `SECURITY.md` and `CODEOWNERS` as an orchestrated child. |
| `## Refresh After Rebase or Source Change` | In the epic route, the refresh runs on the integration branch before the final receipt. |

## Data & State

No runtime data or state changes. Markdown text, one test file, and generated copies change.

- Data transformations and invariants: the `.claude` skill copy and the Claude bundle copy are renderings of the `.agents` source; the Codex bundle copies are byte copies of the `.agents` files.
- Caching or persistence details: none.
- Migration or backfill requirements: none.

## Acceptance Criteria

- [x] Placement: in the `.agents` source, the generated `.claude` copy, the generated Claude bundle copy, and the byte-copied Codex bundle copy of the `documentation-workflow` skill, a level-two section `## Epic-Scale Routing` exists after `## Rules` and before `## Commit, Receipt and Pull Request`. The contract test fails if the heading is missing, duplicated, or out of that order in any copy.
- [x] Routing condition: the section states that a first full estate, or a planned page count above the default page threshold recorded in decision D2, routes through `epic-plan` started from the main session; that otherwise the single-run route applies; that the epic-worthiness verdict of `epic-plan` can return the work to the single-run route; and that deviating from the default is a recorded decision. The contract test fails when any of these statements or the D2 threshold wording is missing in any copy.
- [x] Wave order: the section states the waves in this order: the foundation wave (profile and `docs-init`, `docs-plan-ia` information architecture and family plan, templates, docs CI, root inventory; owns no family id); then `architecture`, `adr`, `reference`, `product-overview`, `getting-started`; then `user-guides`, `administration`, `security` (with repository-root `SECURITY.md` and `CODEOWNERS`); then `operations`, `service-management`. Each default family id of the Shared Design bullet `Default family ids` (`product-overview`, `getting-started`, `user-guides`, `administration`, `security`, `operations`, `service-management`, `architecture`, `adr`, `reference`) appears in the section without repetition, within its own wave segment. The contract test fails on a missing, duplicated, or misplaced id and on a wave marker out of order.
- [x] Ownership: the section states that the family ids are owned by docs-family-profile-model and that the profile's family list is authoritative. It contains none of the family-record field names `required_families`, `diataxis_mode`, `review_interval_days`, `audience`, `exclusion`, or `legacy_exclusions`. The contract test fails if any such token appears in the section.
- [x] Dispatch: the section states that each child runs the `## Dispatch Order` for its families only, and that `docs-init` and the root inventory step run in the foundation child. The contract test fails when either statement is missing in any copy.
- [x] Receipt: the section states that the docs-complete receipt is written on the integration branch at its head, by the final integration step only, before the integration pull request, that no wave child writes or commits a receipt, and that docs-complete family semantics are owned by docs-family-gate-and-ia. The contract test fails when any statement is missing in any copy.
- [x] Qualifications: in every copy, `## When to Use This Skill` names the docs skills for a single run and `epic-plan` for the estate route; `## Commit, Receipt and Pull Request` states that it applies to the single-run route; the docs path set rule states that it applies to the checkpoint-free single run and that the security-wave child may carry `SECURITY.md` and `CODEOWNERS` as an orchestrated child; `## Refresh After Rebase or Source Change` states that the epic route refreshes on the integration branch before the final receipt. The contract test fails when any of these qualifications is missing.
- [x] Standard: `.agents/skills/documentation-workflow/references/standard.md` gains a new behavior for epic-scale routing and a new check citing it, and the citation list of the existing check that cites the other behaviors is extended to include the new behavior. `Get-HarnessSkillContractViolation` reports no violation for the file, including the `uncited-behavior` rule, and the Codex bundle copy of the file is byte-identical to the source.
- [x] Contract test: `tests/scripts/claude-runtime/documentation-workflow.EpicRouting.Tests.ps1` exists, pins the placement, routing, wave, ownership, dispatch, receipt, and qualification criteria in every copy, runs in the parallel Pester gate, creates no temporary files, reads no clock, defines the threshold in a single script variable, and removes its helper functions in `AfterAll`.
- [x] Generator parity: `Invoke-HarnessGeneration.ps1 -Surface skills -Check` reports no drift; the generated `.claude` and Claude bundle copies come from the generator run and not from hand edits; `scripts/harness-generation/sources/skills/documentation-workflow.substitutions.json` is unchanged.
- [x] Bundle contracts: the push-down Claude resource contract test, the push-down Codex and agents resource contract test, and the pack-manifest completeness tests pass.
- [x] Brief listing: the new suite name appears under `## Contract Tests That Pin Mirrored Files` in the byte-identical execution-environment brief copies (the `.agents` source, the Claude copy, and the bundle copies), and the brief contract tests and `copilot-layer-retirement.Tests.ps1` still pass.
- [x] Scope guard: the change adds no Python, no PowerShell library change, and no MCP change, and edits none of `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `docs-plan-ia`, or the substitutions file.

## Decisions

- D1 (receipt wording): written once on the integration branch at its head, before the integration pull request; no wave child writes or commits a receipt. The committing mechanism is left to the epic's final step.
- D2 (threshold): the default is "more than 40 planned pages", plus "a first full estate". The value is a policy choice and is not derived from an enumerated count.
- D3 (threshold location): skill text only; no profile option. A first estate has no profile, and a profile option would couple this feature to the profile schema child.
- D4 (brief listing): the new suite is listed in the four brief copies, because that heading enumerates suites that pin mirrored files.

## Constraints & Risks

- No new Python. Skill text only, plus a Pester contract test.
- Must cite the family ids and docs-complete family semantics by their Shared Design names and not re-implement them.
- Generated surfaces must be changed through `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; the Codex bundle copies are copied from the edited `.agents` files and confirmed by the push-down contract test.
- Open risk (research section 4): receipt commit mechanics on the integration branch are not covered by the contract test. The integration branch is checked out in the epic integration worktree, which holds an epic checkpoint, and the docs-estate preimplementation legs decline when a checkpoint exists in the resolved root. A receipt commit under `docs/documentation-estate/` may be denied from the epic root. Preflight and the epic's final step own this check; if it is denied, preflight records it as a finding. The skill text states the requirement and not the mechanism.
- Mirror parity: a hand edit of a generated copy is reported as drift; the four brief copies change together.
- Test isolation: the suite reads committed files only, uses `Join-Path` and forward-slash relative paths, and leaks no helper function.

## Dependencies

- docs-family-profile-model (Shared Design name): owns the family ids, the family record, and the profile family list.
- docs-family-gate-and-ia (Shared Design name): owns docs-complete family semantics and the family-planning step of `docs-plan-ia`.
- Existing skills and agents: `epic-plan` (main-session entry), `epic-planner`, `HarnessSkillMirror.psm1`, `HarnessSkillContract.psm1`.

## Non-Goals

- No profile option for the threshold and no library, MCP, or hook change.
- No edit to `epic-orchestrate`, `epic-orchestrator` (hash pinned), `docs-plan-ia`, or the substitutions file.
- No restatement of the family record fields or of docs-complete family semantics.
- No change to the repository epic template under `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/` or to `.dev/engineering/documentation-estate/` files.
- No new Copilot surface file; the Copilot entry for the skill is `dropped` in `config/harness-parity-matrix.json`.
- No mechanism for committing the receipt on the integration branch.

## Implementation Strategy

- Implementation scope: edit `.agents/skills/documentation-workflow/SKILL.md` and `references/standard.md`; run the generator for `-Surface skills`; copy the two edited `.agents` files to the Codex bundle; add the suite name to the four brief copies; add the new Pester suite.
- New classes/functions/commands to add or update: one Pester file following the pattern of `documentation-workflow.CommitStage.Tests.ps1`, using the four skill roots from `Get-DocsAuthoringSkillRoot` or an equivalent literal row list.
- Dependency changes: none.
- Logging/telemetry additions: none.
- Rollout plan: single pull request into the epic integration branch; no feature flag; the fallback is reverting the text.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, .dev/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Contract test over the copies of the skill
- [ ] Harness generation repo gate
- [ ] Push-down bundle contract tests
