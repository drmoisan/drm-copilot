# Research: docs-epic-scale-routing (Issue #1223, epic #1217 wave 2, C2)

- Timestamp note: the researcher had no shell and wrote the file as `research.2026-11-23T06-30.md` with an estimated stamp. The orchestrator renamed it to `research.2026-11-23T05-50.md` using the host clock reading `2026-11-23T05:50:32Z`, taken immediately after the researcher returned. Evidence artifacts written later take their stamps from the clock.
- Scope: guidance text in `documentation-workflow` plus a Pester contract test. Upstream contracts (family record, family ids, docs-complete family semantics, docs-plan-ia family step) are cited by Shared Design name and are not re-implemented.

## 1. Current text of `documentation-workflow` (Claude copy)

Source: `.claude/skills/documentation-workflow/SKILL.md`. Frontmatter has `name` and a one-line `description`. Level-two sections in order:

1. `## When to Use This Skill`: run from the root session, whole workflow or resume at a named step; "an alias: it adds no tool call, receipt or write authority of its own and dispatches to the seven skills below".
2. `## Prerequisites`: root steps run the docs helper library at `.claude/lib/docs/` under PowerShell 7.4 or later.
3. `## Dispatch Order`: eight numbered rows: docs-init (root); root `inventory -Write` step (root); docs-inventory-surface (docs-architect); docs-plan-ia (docs-architect); docs-author-page (docs-author); docs-reconcile-behavior (docs-reconciler); docs-review-coverage (docs-coverage-reviewer); docs-validate (docs-coverage-reviewer or root).
4. `## Rules`: three bullets (pass prepared inputs; read report tokens, `BLOCKED` or `FAIL` stops the workflow; profile artifact writes go through a root step or `update_docs_ledger`).
5. `## Commit, Receipt and Pull Request`: root session stage after the dispatch order, "not a dispatch row and writes no orchestration checkpoint". Steps: commit (`git add --`, `git commit -F <file>`, no pathspec); receipt (`Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -WriteReceipt`, then stage and commit); push; delegate `Agent(pr-author)` with the four prompt lines. A `Rules:` list follows: tracking issue before the PR; a root that holds another item's checkpoint makes every docs leg decline (fail closed); only docs path set changes may be on the branch ("paths under `docs/` that lie under the profile's documentation roots or artifact directories, and the docs-init workflow file"; any other path denied at commit, PR creation, and merge).
6. `## Refresh After Rebase or Source Change`: seven ordered steps (re-inventory, regenerate reference pages, update `surface_refs`, re-review, rebuild ledger, re-validate, write a new receipt).

The Codex copy (`.agents/skills/documentation-workflow/SKILL.md`) has identical sections; only `## Prerequisites` and the agent links in `## Dispatch Order` differ (`.codex/agents/*.toml` instead of `.claude/agents/*.md`).

### Statements that conflict with or need qualification under epic routing

| Statement (section) | Issue under epic routing | Proposed qualification |
| --- | --- | --- |
| "dispatches to the seven skills below" (`## When to Use This Skill`) | The skill would also dispatch to `epic-plan` | Say it dispatches to the seven skills for a single run, and to `epic-plan` for the estate route in `## Epic-Scale Routing`. The "adds no tool call, receipt or write authority" sentence stays true: `epic-plan` is main-session only and the skill grants no authority. |
| "The root session runs this stage itself ... writes no orchestration checkpoint" (`## Commit, Receipt and Pull Request`) | Epic children are orchestrator runs that hold a checkpoint and open their own PRs through the standard orchestrator stages | State that the stage describes the single-run route; epic children use the orchestrator PR stages, and the receipt step moves to the integration branch. |
| "A session root that holds another item's checkpoint makes every docs leg decline" | An epic root always holds a checkpoint, so the docs-estate legs decline there by design | Cross-reference it: this is why epic children do not use the checkpoint-free stage. |
| "Only docs path set changes may be on the branch" | The Shared Design `security` family includes repository-root `SECURITY.md` and `CODEOWNERS`, which are outside the docs path set. The CI docs-only allowlist in `execution-environment` also excludes them, so such a PR gets a full CI run. | Qualify: the rule applies to the checkpoint-free single-run route; the security-wave child may carry `SECURITY.md` and `CODEOWNERS` because it runs as an orchestrated child with a checkpoint, and its PR gets full CI. |
| `## Refresh After Rebase or Source Change` | The receipt is written once on the integration branch, so the refresh sequence ends with a new integration receipt | One sentence: in the epic route the refresh runs on the integration branch before the final receipt. |

## 2. Copies and generator

Copies of the skill:

| Copy | Path | Role |
| --- | --- | --- |
| Codex source | `.agents/skills/documentation-workflow/SKILL.md` and `references/standard.md` | Generator source. Parity matrix entry `codex:skill:documentation-workflow` has disposition `shared`. |
| Claude | `.claude/skills/documentation-workflow/SKILL.md` | Generated. Entry `claude:skill:documentation-workflow` has disposition `generated`, `generated_from` `.agents/skills/documentation-workflow/SKILL.md`, generator `harness-generation/skills`. |
| Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/documentation-workflow/SKILL.md` | Generated with the Claude copy (`HarnessSkillMirror.psm1` renders the Claude copy "and to its bundle copy"). Listed in `pack-manifests/core.json`. |
| Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/documentation-workflow/SKILL.md` and `references/standard.md` | Byte copy of the `.agents` source. Listed in `pack-manifests/shared.json` (both files) and `core.json`. Its maintenance mechanism was not found in `scripts/harness-generation`; `test_push_down_codex_and_agents_resource_contracts.py` pins equality. The plan should copy the edited `.agents` files and confirm with that test. |
| Copilot | `.github/skills/documentation-workflow/SKILL.md` | Does not exist. Entry `copilot:skill:documentation-workflow` has disposition `dropped` with reason "Superseded by the shared .agents/skills/documentation-workflow, which Copilot reads natively". The Copilot surface has no equivalent file to edit. |

Claude differences are produced by `scripts/harness-generation/sources/skills/documentation-workflow.substitutions.json`: two ordered exact-text substitutions, each `find` must occur exactly once. They cover the `## Prerequisites` sentence and the six agent-link lines (rows 3 to 8 of `## Dispatch Order`). New text outside those two spans needs no substitution entry. Any new sentence that names a Claude-only path or tool would need a new substitution; the proposed text names none (it cites `epic-plan`, skill and family names only).

`references/standard.md` is never mirrored to `.claude` (`Get-HarnessSkillMirrorExcludedFile` lists `agents/openai.yaml` and `references/standard.md`). Its shape is validated by `scripts/harness/HarnessSkillContract.psm1` (`Get-HarnessSkillContractViolation`): fixed H2 set, `- **OB-<n>** ` behaviors numbered from 1 without gaps, `- **AC-<n>** (OB-..) ` checks, and rule `uncited-behavior` (every OB must be cited by a check). Adding a behavior OB-6 therefore requires a new AC citing OB-6 and extending the AC-6 citation list.

Generator invocation (`scripts/harness-generation/Invoke-HarnessGeneration.ps1`, parameters `-Surface skills|rules|mcp|agents|instructions|all`, `-Check`, `-Root`):

- Write: `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills`
- Check: same with `-Check`. It prints one line per drifted, missing, or extra file; exit 0 clean, 1 on a finding, 2 on rejected arguments.
- An executor has no PowerShell tool and the isolation guard refuses `pwsh` text, so the run goes through a `sh <SCRATCH>/<file>.sh` launcher holding the literal path (execution-environment, "Tool Routes by Agent" and "Command-Text Restrictions"). The generated Claude and Claude-bundle files must come from this run, not hand edits.

## 3. Existing tests and pins

Tests that read the skill:

- `tests/scripts/claude-runtime/documentation-workflow.CommitStage.Tests.ps1` (issue #1169). `BeforeDiscovery` defines `$script:WorkflowCopyRows` (the four copies, as `@{ Path = ... }`) and `$script:BriefCopyRows` (four copies of the execution-environment brief). `BeforeAll` defines `Get-CommitStageSection` (reads the file with `Get-Content -Raw`, normalizes CRLF, extracts a level-two section with `(?ms)^<heading>[ \t]*\n(?<body>.*?)(?=^## |\z)`, collapses whitespace to one space) and `Get-CommitStageHeadingIndex`. Assertions use ordinal `Contains` and `IndexOf`, step order is `$positions | Should -Be @($positions | Sort-Object)`, `-ForEach` over rows, `-Because` messages. `AfterAll` removes the helper functions. It also asserts that each brief copy has a `- Docs-estate legs (#1169)` bullet in `## Hook Execution Context` and lists four contract-suite names (including itself) in `## Contract Tests That Pin Mirrored Files`.
- `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` plus helper `DocsAuthoringRoles.Helpers.ps1`: `Get-DocsAuthoringSkillRoot` returns the four skill roots keyed `Claude`, `ClaudeBundle`, `Codex`, `CodexBundle`; `Read-DocsAuthoringText`; `Get-DocsWorkflowSectionText`. Checks the `inventory -Write` row precedes the docs-inventory-surface link in `## Dispatch Order`. This is the preferred reader for a new test (one place defines the four roots).
- `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` ("lists the seven skills in dispatch order", `.claude` copy only): first-`IndexOf` order of `[docs-init](../docs-init/SKILL.md)` through `[docs-validate](../docs-validate/SKILL.md)`. New text must not place one of these exact links before its dispatch row. Inserting the new section after `## Dispatch Order` is safe even if it links.
- `tests/scripts/claude-runtime/docs-authoring-roles.Registration.Tests.ps1` (registration of the skill name in the named set), `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` (name list), `copilot-layer-retirement.Tests.ps1` (brief phrases such as "in the four `documentation-workflow` copies", must stay "four", not "six"). None reads the new section.
- Parity: `HarnessGeneration.RepoGate.Tests.ps1` (every generated skill equals the rendering of its source), `HarnessSkillMirror.Tests.ps1`, `HarnessSkillContract.Tests.ps1`, `HarnessInventory.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and the two pack-manifest completeness tests. They compare text and do not pin section counts. `config/orchestration-routing.json` `docs_operations.documentation-workflow` pins only `logical_agent: root` and `mcp_tools: []`; no change.
- `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. It is not affected, provided the change does not edit those two files (the plan must not touch them).
- `config/poshqc-shard-weights.json` lists the existing CommitStage test with weight 297; a new test file is assigned to a shard automatically (execution-environment, CI shape) and needs no entry, although adding one is optional.

No existing test breaks when a new level-two section is added. Verified by reading each test above: none counts sections or hashes the skill file.

## 4. Epic routing and the docs-complete receipt

- `epic-plan` (`.claude/skills/epic-plan/SKILL.md`, `context: fork`, `agent: epic-planner`) is the main-session entry. `.claude/agents/epic-planner.md` states it is "invoked from the main session only", and `enforce-epic-invocation-origin.ps1` denies `Agent(epic-planner)` from a subagent. The skill takes an objective or an epic manifest path. A documentation epic must supply: manifest at `.dev/epics/<slug>/epic.md` (frontmatter `epic`, `integration_branch: epic/<slug>-integration`, `created_at`, `intent`, `features[]` with `feature_folder` and `depends_on`), integration branch created from `origin/main`, children prepared in preparation mode and branched from the integration branch, execution later by `/epic-run <slug>` or `epic-orchestrate`, wave layering by longest path (`Invoke-EpicWave.ps1`), epic-level issue promoted with `promotion_type: epic`, and the epic-worthiness gate (at least two independently mergeable children and a change budget beyond one feature).
- A repository template already exists: `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/` (`epic.md`, `README.md`). It decomposes by tooling (profile-and-init, IA, templates, metadata, docs-ci, then page types by Diataxis mode, then an exit gate), not by family. It is also referenced from `.dev/engineering/documentation-estate/consumer-onboarding.md` ("Using the Epic Template"), which still names `docs/features/epics/<slug>/` although the template README says `.dev/epics/<slug>/`. Neither is in this feature's scope. The skill text should point at `epic-plan` and state the family-wave default, and may name the template as an alternative tooling-first decomposition without editing it.
- Docs-complete gate: `.claude/hooks/enforce-docs-complete-gate.ps1` is opt-in through `completion_gates.integration_pr_gate.enabled` in `docs/documentation-estate/docs-profile.json`. It gates only a `gh pr merge` whose head is an epic integration branch merging into `main` (decision step 5). It reads the receipt path from the profile and the receipt file from the local working tree at `Get-DocsCompleteGateReceiptRoot`: the one live worktree that has the PR head branch checked out, else the repository root. The head revision is always `headRefOid`. The receipt revision rule (`.claude/lib/docs/DocsReceiptRevision.psm1`, `Get-DocsReceiptRevisionDecision`) accepts a receipt revision equal to the head or an ancestor of it with no changed path under `surface_selection.source_roots`. The guidance "the docs-complete receipt is written on the integration branch" is therefore consistent with the gate: the gate only inspects the integration branch head state and never a child branch. A child-branch receipt would pass only by ancestry after merge, which the skill should not rely on.
- Open mechanics (record, not resolved by reading): the integration branch is checked out in the epic's integration worktree, which holds `artifacts/orchestration/epic-orchestrator-state.json`. The docs-estate preimplementation legs decline when a checkpoint exists in the resolved root (execution-environment "Docs-estate legs (#1169)"), and the post-fan-in allowance admits only `epic-status.md`, `artifacts/pr_body_<N>.*`, and merged-feature follow-up paths. A receipt commit under `docs/documentation-estate/` on the integration branch might therefore be denied if issued from the epic root. Decision D1 below words the skill requirement (receipt present and committed at the integration head before the integration PR, none on a wave child) and does not prescribe the committing mechanism beyond naming the final exit step; the plan's preflight must check the mechanism against the gate behavior and, if denied, record it as a finding. This is the one point that cannot be confirmed without running the hooks, and it is not testable by the contract test.

## 5. Reference estate and threshold

Read-only source: `rgf-forecast/docs/features/epics/comprehensive-documentation/epic.md`.

- Eight children, four waves by longest-path layering (the epic text states the formula):
  - Wave 0: `docs-foundation-and-ia` (C3), docs-as-code system: IA, page templates, ownership and metadata convention, docs CI.
  - Wave 1: `architecture-and-adr-docs` (C3), `reference-api-cli-config-docs` (C3), `product-overview-and-onboarding-docs` (C2).
  - Wave 2: `user-task-guides` (C2), `admin-operator-deployment-docs` (C3), `security-compliance-docs` (C2).
  - Wave 3: `operations-runbooks-and-service-mgmt` (C3).
- The epic states no page counts. The estate under `docs/production-documentation/` holds 74 pages excluding `_templates/`.

### Numeric Derivation Evidence

Claim: the reference estate holds 74 pages excluding `_templates/` (81 Markdown files, 7 of them templates). The recommended threshold below is a policy choice, not an enumerated count, and carries no derivation record; the 74 figure is context only and is not proposed as an acceptance-criterion assertion.

- Complete Family: Markdown files under `rgf-forecast/docs/production-documentation/`.
- Exhaustive Search Scope: the whole `docs/production-documentation/` tree, every subfolder, `.md` only.
- Inclusion Rules: every `.md` file outside `_templates/`; READMEs and ADRs count as pages.
- Exclusion Rules: `_templates/*.md`; non-Markdown files.
- Primary Search Strategy or Query Expression: Glob `docs/production-documentation/**/*.md`, tallied by folder: admin 8, architecture 14 (README, 9 ADRs, components, data-flow, overview, trust-boundaries), getting-started 4, operations 13 (README, alerts-catalog, 2 playbooks, 9 runbooks), product 2, reference 12 (README, api 3, cli 4, config 4), security 6, service-management 4, user-guides 11.
- Primary Member Set: the 74 paths of those nine folders.
- Primary Count: 74.
- Cross-check Search Strategy or Query Expression: Grep `^---` with `output_mode: count` over `**/*.md` (front-matter delimiter), which reported 2 matches in each of 81 files.
- Cross-check Member Set: 81 files, of which the 7 under `_templates/` (adr, architecture, guide, product-overview, reference, runbook, security) are removed.
- Cross-check Count: 81 - 7 = 74.
- Member-set Comparison: the 74 paths of the folder tally equal the 81 front-matter files minus the 7 template files; no file lacks front matter and no extra file appears.

### Recommended default threshold

Recommend: an estate of more than 40 planned pages routes through `epic-plan`; also any first full estate. Rationale:

- The reference estate averaged about 9 pages per child (74 pages over 8 children), and the largest family (architecture with ADRs) held 14. A single run that authors, reconciles, reviews, and validates every page sits well past that per-run size once an estate reaches four or more families.
- 40 pages is roughly half the reference estate. The reference needed four waves; a 40-page estate yields about four to five children of roughly 8 to 10 pages, which satisfies the epic-worthiness gate (two or more independently mergeable children) with margin.
- It is a default stated in skill text; a repository may route a smaller estate through `epic-plan` and a larger one through a single run only by an explicit, recorded decision (the skill should say "default"). Ratified as D2.

### Family to wave mapping (default ids from the epic Shared Design)

| Wave | Content | Family ids |
| --- | --- | --- |
| 0 foundation | docs profile and `docs-init` (family seeding), the `docs-plan-ia` information architecture and family plan, page templates, `_docs-quality.yml`, root `inventory -Write` snapshot | No family id owns pages. Foundation produces the profile, plan, and CI artifacts that every later wave consumes (reference: `docs-foundation-and-ia`). |
| 1 architecture, reference, product | | `architecture`, `adr`, `reference`, `product-overview`, `getting-started` |
| 2 guides, administration, security | | `user-guides`, `administration`, `security` (including `SECURITY.md` and `CODEOWNERS`) |
| 3 operations and service management | | `operations`, `service-management` |

Placement notes: `adr` goes with `architecture` (reference `architecture-and-adr-docs`). `product-overview` and `getting-started` go with wave 1 as the "product" group (reference `product-overview-and-onboarding-docs`, which `user-task-guides` depends on). `reference` is wave 1 because guides, administration, and security cite it. Wave 3 follows because operations cite administration and security (reference `operations-runbooks-and-service-mgmt` depends on architecture, admin, and security). The mapping covers all ten Shared Design ids exactly once: product-overview, getting-started, user-guides, administration, security, operations, service-management, architecture, adr, reference.

The skill must say these are default groupings of the Shared Design ids owned by docs-family-profile-model; a profile's `required_families[]` is the authority, and a profile that omits or renames an id keeps the wave order for the ids it has. It must not restate the record shape.

## 6. Docs profile threshold option

`.claude/lib/docs/DocsProfile.psm1` builds the profile (including `completion_gates`) and validates it; a grep of `.claude/lib/docs/` for page-count and threshold terms found only the page-check result field `page_count` in `DocsPageCheck.psm1` and `DocsReferenceReport.psm1`, and no profile option. The upstream child docs-family-profile-model already changes the profile schema (record owner), so adding a threshold key would couple this C2 feature to a C3 schema change and require library, MCP parameter, init seeding, and parity changes. The routing decision is made by an agent before a profile exists (a first estate has no profile), so a profile option cannot govern the first-estate case. Recommendation (D3): the threshold is skill text only. A profile option is deferred and is not filed as an issue (no evidence it is needed).

## 7. Sibling files and stale facts

- `.claude/skills/documentation-workflow/` contains only `SKILL.md`; `.agents/skills/documentation-workflow/` adds `references/standard.md` and the bundle mirrors it. No other sibling file exists.
- `docs-plan-ia/SKILL.md` has no epic or wave text; the family-planning step is owned by docs-family-gate-and-ia, so this feature must not edit it.
- `.dev/engineering/documentation-estate/workflow.md` (Sequence step 7, Integration-PR Gate) and `README.md` name the skill. Step 7 describes the single-run stage and stays true. Adding a short "Epic-scale estates" pointer to `workflow.md` is optional and not required by the issue.
- Execution-environment brief: the existing text names `documentation-workflow.CommitStage.Tests.ps1` and the docs-estate legs; nothing states a fact this change alters. If the new contract suite is listed under `## Contract Tests That Pin Mirrored Files`, all four brief copies change together, and `test_execution_environment_brief_contracts.py` plus `copilot-layer-retirement.Tests.ps1` phrases must still pass. Decision D4: list it, because that heading exists to enumerate suites that pin mirrored files and the maintenance rule requires brief and fact to move together. The CommitStage test asserts only that its own four named suites are present, so adding a fifth name does not break it.

## Candidate approaches

1. Guidance section in the skill plus a standalone Pester contract test over four copies (recommended). Matches the #1169 precedent, needs no library change, and fits C2.
2. Profile option `epic_route_page_threshold` plus gate warning. Rejected: couples to the upstream schema child, cannot apply before a profile exists, adds PowerShell library and MCP work beyond C2.
3. Fold the new assertions into `documentation-workflow.CommitStage.Tests.ps1`. Rejected: that suite is named and described for the commit stage (brief lists it by that purpose); a separate file keeps the failure attributable and the file small.

## Behavior semantics for the skill text

- Routing condition: a first full estate (no committed profile or no pages under the documentation roots) or a planned page count above 40 routes through `epic-plan`; otherwise the single-run route applies. `epic-plan` is started from the main session; its epic-worthiness gate can still return a single-feature verdict, which sends the work back to the single-run route.
- Default decomposition: four waves in the order of section 5. Each child runs the `## Dispatch Order` for its families only (docs-init and the root inventory step run once in the foundation child; later children start at inventory refresh, plan, author, reconcile, review, validate for their families).
- Receipt: written once at the integration branch head after the last wave merges, not by a wave child; the integration pull request is the one that the docs-complete gate evaluates. Family completeness of the whole estate is owned by docs-family-gate-and-ia: a required family with no page and no recorded exclusion fails docs-complete, and `SECURITY.md` and `CODEOWNERS` are required when security is required. The skill cites those semantics and does not restate field names.
- Failure conditions: a child that reports `BLOCKED` or `FAIL` stops its wave under existing rule; a missing family at the integration head fails the gate, not a child.

## Automation Feasibility

Fully automatable with no human interaction. Skill text edits, one generator run, a byte copy to the Codex bundle, one new Pester file, and brief edits are all executor-capable. The only non-test-covered point is the receipt-commit mechanics on the integration branch (section 4); it is a preflight observation, not a human step, and does not block the text change.

## Recommendations

Decisions (autonomous mode; recommended options taken):

- D1: wording of the receipt rule is "written once on the integration branch at its head, before the integration pull request; no wave child writes or commits a receipt". Mechanism left to the epic's final step.
- D2: default page threshold is 40 planned pages ("more than 40"), plus "a first full estate".
- D3: threshold is skill text only; no profile option.
- D4: the new contract suite is listed in the four brief copies.

Proposed file inventory:

Production (6 files, within the Claude change budget only because test files and generated files are counted per kind; the batch-budget cap is three distinct non-test PowerShell or Python files and none of these are `.ps1` or `.py`, so no large-path routing is needed):

1. `.agents/skills/documentation-workflow/SKILL.md`: add `## Epic-Scale Routing` after `## Rules` (and before `## Commit, Receipt and Pull Request`), plus the qualifications of section 1. Include literal tokens for the test: `epic-plan`, `more than 40 planned pages`, `first full estate`, the four wave lines in order with their family ids, `Dispatch Order`, `integration branch`, `receipt`.
2. `.agents/skills/documentation-workflow/references/standard.md`: add `OB-6` Epic-Scale Routing and `AC-7`, and extend AC-6's citation list to OB-6.
3. `.claude/skills/documentation-workflow/SKILL.md`: generated.
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/documentation-workflow/SKILL.md`: generated.
5. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/documentation-workflow/SKILL.md` and `references/standard.md`: byte copies of items 1 and 2.
6. The four copies of `.claude/skills/execution-environment/SKILL.md` (`.agents`, both bundles): one added suite name in `## Contract Tests That Pin Mirrored Files` (byte-identical edit).

Not edited: `documentation-workflow.substitutions.json` (the two existing `find` spans stay unmodified; the edit must not alter the `## Prerequisites` sentence or rows 3 to 8 of `## Dispatch Order`), parity matrix, pack manifests, orchestration-routing, `epic-orchestrate` and `epic-orchestrator` (hash pinned), `docs-plan-ia`.

Test (1 new file): `tests/scripts/claude-runtime/documentation-workflow.EpicRouting.Tests.ps1`. Follow the CommitStage pattern with the four-copy rows from `Get-DocsAuthoringSkillRoot` (or the same literal row list), a section extractor for `## Epic-Scale Routing`, whitespace-normalized ordinal `Contains`, and `-ForEach` over copies. Rows: section exists and sits between `## Rules` and `## Commit, Receipt and Pull Request`; states `epic-plan`, `first full estate`, and `more than 40 planned pages`; the four wave labels appear in order (index order of `foundation`, `architecture`, `administration`, `operations` wave markers, with the ten family ids each present exactly in its wave segment); states each child runs the dispatch order for its families; states the receipt is written on the integration branch and not on a child; the section does not name a profile option key (guards D3). The test reads committed files only, creates no temp files, uses no clock, and must not hardcode the number 40 in more than one place (a `$script:DefaultPageThreshold` variable). Line coverage is not applicable to Markdown; the test file stays far below 500 lines.

Generated: Claude copy and Claude bundle via `-Surface skills`, verified with `-Check`.

Verification route after editing: Pester task check for the new and the four neighboring suites through the launcher `pester` suite with `-TestPath`; `-Surface skills -Check`; `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_execution_environment_brief_contracts.py`; phase gate runs the parallel Pester gate and the pytest gate once each.

## Pre-Mortem

- Review checklists: a reviewer may flag text that restates upstream contracts (field names of `required_families[]`) or an unqualified "Only docs path set changes" rule left standing next to `SECURITY.md`. Mitigation: the plan carries the section 1 qualification table as a task checklist and a grep-style test row that the new section contains no `review_interval_days`, `diataxis_mode`, or `required_families` token.
- Coverage: the change is Markdown and one Pester file; no PowerShell or TypeScript production file is added, so no per-file coverage floor applies. Risk: a reviewer demands coverage for the test file. Mitigation: record that Pester test files are outside the production coverage population and that the PoshQC population is derived from `config/poshqc-coverage.json`.
- Mirror parity: the main failure mode is a hand edit to `.claude/skills/documentation-workflow/SKILL.md` or its bundle, which `HarnessGeneration.RepoGate.Tests.ps1` reports as drift, or a Codex bundle copy that differs by one byte from `.agents`. Also the four brief copies must change together if D4 stands. Mitigation: edit only `.agents` files, run `-Surface skills`, copy the two Codex bundle files, then run `-Check` and the push-down contract tests; a brief task updates all four copies and the plan's `Mirror parity` bullet names it.
- File size: all files are far below 500 lines (the skill is 93 lines; the execution-environment brief is a long Markdown file but Markdown is exempt). The new test must stay below 500 lines.
- Test isolation: the new suite reads committed files only and defines helper functions in `BeforeAll`, which it must remove in `AfterAll` (as CommitStage does); a leaked function would be caught by `Invoke-PoshQCLeakScan` and by shard composition. It must not dot-source helpers that define names already defined by another suite without removing them (the `DocsAuthoringRoles.Helpers.ps1` suites remove their names in `AfterAll`).
- CI-only behavior: Linux shards run case-sensitive paths; use `Join-Path` and forward-slash relative paths, with no drive letters and no CRLF fixtures (`eol=lf`). The generator `-Check` runs in the repo gate on every platform; a stray CRLF in a hand-copied bundle file would diverge only in CI. Docs-only CI behavior does not apply because the change touches `.agents`, `.claude`, `extensions`, and `tests` paths, so a full run happens.
- Evidence: an executor on this route has no PowerShell tool; generator and Pester runs go through `sh` launcher scripts, and counts come from `artifacts/pester/pester-junit.xml`, not from MCP results (which carry no output). Evidence files are written under `.dev/active/1223-docs-epic-scale-routing/evidence/<kind>/` with clock-read stamps and are append-only.

## Sources verified

`.dev/epics/documentation-estate-families/epic.md` (`## Shared Design`, `## Decomposition and Waves`); `.dev/active/1223-docs-epic-scale-routing/issue.md`; the four skill copies; `config/harness-parity-matrix.json` entries for the three ecosystems; `scripts/harness-generation/Invoke-HarnessGeneration.ps1`, `HarnessSkillMirror.psm1`, `sources/skills/documentation-workflow.substitutions.json`; `scripts/harness/HarnessSkillContract.psm1`; the tests named in section 3; `.claude/skills/epic-plan/SKILL.md`; `.claude/agents/epic-planner.md`; `.claude/hooks/enforce-docs-complete-gate.ps1`; `.claude/skills/epic-orchestrate/SKILL.md` (integration worktree and checkpoint); `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/`; `.dev/engineering/documentation-estate/workflow.md` and `consumer-onboarding.md`; the read-only rgf-forecast epic and estate tree.
