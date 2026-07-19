# legacy-discovery-skills — Spec

- **Issue:** #367
- **Parent (optional):** Epic `legacy-discovery-and-parity` (child feature #9008, Wave 2, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Research:** `docs/features/active/2026-07-17-legacy-discovery-skills-367/research/2026-07-17-legacy-discovery-skills-research.md`

## Overview

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. The analyzer framework (#9006), the generic agent
roles (#9007), the schemas (#9002), the domain-profile config contract (#9001),
and the validators (#9003) provide the building blocks, but there is no reusable
workflow-mechanics layer that sequences them into an end-to-end discovery and
parity-definition workflow. Without generic skills, every consumer repository
would have to hand-orchestrate the analyzers, agent roles, and artifact
production/validation ad hoc, reintroducing domain coupling and duplicating
sequencing logic.

This feature authors reusable `.claude/skills/<name>/SKILL.md` workflow-mechanics
skills that sequence the discovery and parity-definition workflow: driving the
analyzer CLI commands, routing work to the four generic agent roles by name, and
producing/validating the seven machine-readable discovery artifacts via the
`dev.discovery.validate-*` CLI. All skills are generic, domain-neutral workflow
mechanics driven at runtime by the domain profile (#9001).

## Scope

### In Scope

1. Seven new domain-neutral skills at `.claude/skills/discovery-*/SKILL.md`
   (decomposition in `## Skill Decomposition` below).
2. A byte-identical copy of each new `SKILL.md` into
   `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/SKILL.md`
   (see scope clarification 1 below).
3. One new pytest contract-test module at
   `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`
   (structural verification approach in `## Structural Verification` below).

### Out of Scope (referenced, not authored)

- **#9006 analyzer framework.** The `dev.discovery.*` analyzer CLI (including the
  language-neutral repository/project inventory) is referenced by command name
  only. No analyzer code is authored here.
- **#9007 agent roles.** The four generic agent personas (Legacy Parity Analyst,
  Runtime Characterization Analyst, Requirements Reconciler, Migration Coverage
  Reviewer) are referenced by slug only. No `.claude/agents/*.md` file is
  authored here.
- **#9014 stack-specific analyzers.** Not named literally in any skill (the
  banned-substring invariant forbids the stack name). Skills reference
  stack-specific analyzers generically via the domain profile's
  `technology_stack` key.
- **#9012 cross-ecosystem publishing.** Pack-manifest selection, Codex-native
  converter registration, and `.github`/`.agents` mirroring remain owned by
  #9012.
- Hooks (#9004), schemas (#9002), validators (#9003), initialization/templates
  (#9005), reports (#9010), and MCP/VS Code exposure (#9011).

### Scope Clarifications

1. **Bundle byte-copy is in-feature (supersedes the issue's mirroring note).**
   `issue.md` states that `resources/` mirroring is out of scope and owned by
   #9012. However, the always-on parity gate
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
   (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) requires
   every repo `.claude/**` file to exist byte-identically under
   `extensions/drm-copilot/resources/claude-customizations/`. New skills fail
   the repository test suite unless the mechanical byte-copy is delivered in the
   same change (research Q2(c)/Q6; precedent
   `test_epic_run_kickoff_discovery_contract.py`, which pins skill and bundle
   together). Resolution: the byte-identical bundle copy of this feature's
   skills is a mandatory in-feature step; broader `resources/` publishing (pack
   manifests, converter registration, `.github`/`.agents` mirrors) remains
   #9012.
2. **#9014 is not a dependency of this feature (supersedes the issue's
   "Proposed Behavior" wording).** `issue.md` names the #9014 analyzers as a
   driven CLI source, but the epic DAG (`epic.md`, feature #9008) declares
   dependencies on #9006 and #9007 only. Skills therefore instruct consumers to
   run "any stack-specific analyzer commands applicable to the profile's
   `technology_stack`, as documented by the analyzer framework" without naming
   any stack-specific analyzer (research Q4 design notes, Open Risk 5).
3. **Frontmatter AC restated per the repository SKILL.md contract.** The issue
   AC phrase "YAML frontmatter with `allowed-tools`, `context`, and `agent`
   routing" is restated accurately: per `make-skill-template/SKILL.md`, only
   `name` and `description` are required; `allowed-tools`, `context: fork`, and
   `agent:` are optional keys used only by specific skill classes. Wrapper
   skills route to agents via a body-level `## Worker Routing` section, not via
   frontmatter (research Q1). This feature uses `name` + `description` on all
   skills, adds `allowed-tools` only on the two CLI-driving skills, and does not
   use `context`/`agent` frontmatter (rationale in `## Skill Decomposition`).

## Behavior

The skills sequence the discovery and parity-definition workflow end to end:

1. Load and echo the domain profile (`discovery-profile.yaml`, #9001) via
   `dev.discovery.profile`; all domain specificity (`legacy_source.root`,
   `target.root`, `technology_stack`, `artifacts.root`, `artifacts.conventions`)
   is read from the profile at runtime.
2. Drive the language-neutral repository/project inventory analyzer (#9006)
   against the profile-declared source and target roots.
3. Route stage work to the four generic agent roles (#9007) by slug, using the
   body-level `## Worker Routing` convention.
4. Produce the seven machine-readable discovery artifacts governed by the
   schemas at `schemas/discovery/v1/` (#9002).
5. Validate each artifact with its `dev.discovery.validate-*` console script
   (#9003) after each stage, and run `dev.discovery.validate-all` as the
   completion gate (pass/fail semantics: `list[str]` of errors, empty = pass).

Stage order: profile -> inventory -> coverage -> runtime characterization ->
parity -> behavior reconciliation -> validation gate.

Skills contain no domain-specific behavior. The banned-substring set (research
Q6, case-insensitive) must not appear in any new skill file or its bundle
mirror. No skill names a concrete repository, path, or technology.

## Skill Decomposition

Seven skills, prefix `discovery-`, verified non-colliding with all 40 existing
`.claude/skills/` names and with the `code-modernization` plugin's
`/modernize-*` commands and seven agent names (research Q3).

| # | Skill name | Purpose | Referenced contracts | Frontmatter |
|---|---|---|---|---|
| 1 | `discovery-workflow` | Umbrella sequencing skill: end-to-end stage order; canonical `## Referenced Contracts` registry (all agent slugs, CLI names, schema paths, artifact conventions) | `dev.discovery.profile`; all four agent slugs (routing table only); all seven schema paths (registry only); `dev.discovery.validate-all` | `name`, `description` |
| 2 | `discovery-repo-inventory` | Drive the language-neutral repository/project inventory analyzer against `legacy_source.root` and `target.root` from the domain profile; record outputs under the profile's `artifacts.root`; then run stack-specific analyzers generically per `technology_stack` | `dev.discovery.profile`; #9006 inventory command (assumed `dev.discovery.inventory`); consumes `discovery-profile.yaml`; produces `evidence-reference` instances; `dev.discovery.validate-profile`, `dev.discovery.validate-evidence-reference` | `name`, `description`, `allowed-tools` |
| 3 | `discovery-coverage-ledger` | Produce feature contracts and the coverage ledger from inventory output; route review to the coverage role | agent `migration-coverage-reviewer`; schemas `feature-contract`, `coverage-ledger`; `dev.discovery.validate-feature-contract`, `dev.discovery.validate-coverage-ledger` | `name`, `description` |
| 4 | `discovery-runtime-characterization` | Produce runtime characterization scenarios and evidence references; route analysis to the runtime role | agent `runtime-characterization-analyst`; schemas `runtime-characterization-scenario`, `evidence-reference`; `dev.discovery.validate-runtime-scenario`, `dev.discovery.validate-evidence-reference` | `name`, `description` |
| 5 | `discovery-parity-matrix` | Produce/refresh the parity matrix from feature contracts plus characterization evidence; route parity reasoning to the parity role | agent `legacy-parity-analyst`; schema `parity-matrix` (consumes `feature-contract`, `runtime-characterization-scenario`); `dev.discovery.validate-parity-matrix` | `name`, `description` |
| 6 | `discovery-behavior-reconciliation` | Capture unspecified/contradictory behavior and reconcile into product decisions; route to the reconciler role | agent `requirements-reconciler`; schemas `unspecified-behavior-record`, `product-decision-record`; `dev.discovery.validate-unspecified-behavior`, `dev.discovery.validate-product-decision` | `name`, `description` |
| 7 | `discovery-validate-artifacts` | Canonical validation-gate mechanics: per-artifact validators after each stage and `dev.discovery.validate-all` as the completion gate; defines pass/fail semantics | all nine `dev.discovery.validate-*` console scripts; all seven schemas (validation targets) | `name`, `description`, `allowed-tools` |

Design decisions (from research Q4):

- **Agent routing** follows the `review-feature` wrapper precedent: a body-level
  `## Worker Routing` section naming the agent slug. `context: fork` + `agent:`
  frontmatter is not used because (a) the #9007 agents are not merged in this
  worktree and fork frontmatter would create a runtime hard dependency, (b) 37
  of 40 existing skills route without fork frontmatter, and (c) plain-text
  routing keeps #9012 mirroring mechanical.
- **Canonical-location rule** (`skill-canonical-location-audit`): the upstream
  name registry lives only in `discovery-workflow`; validation-gate mechanics
  live only in `discovery-validate-artifacts`; other skills reference those
  skills by name (indirect reference is not duplication).
- **Frontmatter form**: `name` matches the folder exactly; `description` is
  single-quoted per the `make-skill-template` validation checklist;
  `allowed-tools` appears only on the two CLI-driving skills (#2 and #7).
- Skills are self-contained single `SKILL.md` files (no `scripts/`,
  `references/`, or `assets/` subfolders), with no absolute paths,
  worktree-specific text, or generated timestamps, so the bundle mirror stays a
  verbatim copy.

## Referenced Contracts (upstream, by name only)

Concentrated in the `discovery-workflow` `## Referenced Contracts` registry;
stage skills name only the specific contract(s) they use.

- **#9001 config contract (issue #360):** `discovery-profile.yaml` domain
  profile; CLI `dev.discovery.profile`.
- **#9002 schemas (issue #359):** seven schemas at `schemas/discovery/v1/`
  (`feature-contract`, `coverage-ledger`, `runtime-characterization-scenario`,
  `parity-matrix`, `unspecified-behavior-record`, `product-decision-record`,
  `evidence-reference`).
- **#9003 validators (issue #361):** `dev.discovery.validate-*` console scripts
  (`profile`, `feature-contract`, `coverage-ledger`, `runtime-scenario`,
  `parity-matrix`, `unspecified-behavior`, `product-decision`,
  `evidence-reference`, `all`).
- **#9006 analyzer framework (in preparation):** `dev.discovery.*` analyzer CLI
  including the language-neutral repository/project inventory.
- **#9007 agent roles (in preparation):** four generic agent personas.

**Fan-in reconciliation assumptions (must be flagged in the registry text):**

1. The #9006 inventory CLI command name is assumed to be
   `dev.discovery.inventory`; it is not fixed by the prepared summaries. The
   assumption is isolated to one registry line plus the fragment in
   `discovery-repo-inventory` (research Open Risk 1).
2. The #9007 agent slugs are assumed as the kebab-case of the persona titles:
   `legacy-parity-analyst`, `runtime-characterization-analyst`,
   `requirements-reconciler`, `migration-coverage-reviewer`. Final slugs are
   #9007's decision; the same one-registry isolation applies (research Open
   Risk 2).

Reference-isolation rules (research Q5): plain documented string names only; no
skill imports code, embeds `.claude/agents/*.md` file paths, or asserts the
existence of upstream files; structural tests assert only on this feature's own
files, never on #9006/#9007 artifact existence, so checks are green independent
of upstream merge order.

## Structural Verification

Approach: the repository's Python pytest text-fragment contract-test convention
under `tests/scripts/dev_tools/` (precedent:
`tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`; see also
`test_orchestration_guardrail_contracts.py`) — research Q2.

One new module: `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`.
For each new skill it asserts:

1. `SKILL.md` exists at `.claude/skills/<name>/SKILL.md`;
2. frontmatter well-formedness by literal fragments (`name: <name>` matching the
   folder; a non-empty `description:` line);
3. required body fragments (referenced agent slugs, `dev.discovery.*` command
   names, schema paths, worker-routing sections per the decomposition table);
4. absence of the banned domain substrings (case-insensitive) from each new
   skill's text;
5. non-collision with the `code-modernization` command/agent name set (frozen
   set literal in the test);
6. byte-identical presence in the bundled payload under
   `extensions/drm-copilot/resources/claude-customizations/`, following the
   `test_epic_run_kickoff_discovery_contract.py` mirroring-assertion pattern.

The test module asserts only on this feature's own files. Toolchain: the module
is Python test code, so the Black -> Ruff -> Pyright -> Pytest loop applies per
`.claude/rules/python.md` and the seven-stage loop in
`.claude/rules/general-code-change.md`. No production Python code is added, so
line/branch coverage denominators are unchanged (research finding 6).

## Inputs / Outputs

- **Inputs:** `discovery-profile.yaml` (consumer-repository domain profile,
  #9001), read at skill runtime via `dev.discovery.profile`. No new config keys
  are introduced by this feature.
- **Outputs (repository files delivered by this feature):** seven
  `.claude/skills/discovery-*/SKILL.md` files; seven byte-identical bundle
  copies under
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`; one
  pytest module.
- **Outputs (workflow runtime, produced by skill consumers):** discovery
  artifacts under the profile's `artifacts.root`, conforming to
  `schemas/discovery/v1/` and validated by `dev.discovery.validate-*`.
- **Evidence:** all evidence for this feature is written under
  `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/<kind>/`
  only, per `evidence-and-timestamp-conventions`.
- **Backward compatibility:** additive only; no existing skill, test, or bundle
  file is modified.

## API / CLI Surface

This feature adds no CLI commands, MCP tools, or code APIs. It references the
upstream CLI surface by name (see `## Referenced Contracts`). Validation-gate
semantics documented in `discovery-validate-artifacts`: each
`dev.discovery.validate-*` invocation yields a `list[str]` of errors; an empty
list is a pass; `dev.discovery.validate-all` is the workflow completion gate.

## Data & State

No persistent state, storage, or migration is introduced. The skills are static
Markdown workflow definitions. Workflow data flow (at consumer runtime):
profile -> inventory outputs -> feature contracts + coverage ledger -> runtime
characterization scenarios + evidence references -> parity matrix ->
unspecified-behavior records + product-decision records -> validation gate.
Invariant: every produced artifact validates against its
`schemas/discovery/v1/` schema before the next stage proceeds.

## Constraints & Risks

- **Domain neutrality (hard epic invariant).** Banned substrings
  (case-insensitive) must not appear in any new skill file or bundle mirror:
  `TaskMaster`, `TMW`, `Outlook`, `VSTO`, `email`, `task-management` (also scan
  the unhyphenated `task management`). Consequence: skills must not literally
  name the #9014 stack-specific analyzers; stack-specific analysis is referenced
  generically via the profile's `technology_stack` (research Q6).
- **Upstream fan-in assumptions.** #9006 and #9007 are prepared in parallel and
  may not be merged. Two assumed names (the #9006 inventory command, the #9007
  agent slugs) must be reconciled at epic fan-in; isolation limits each to a
  one-line registry edit plus at most one stage-skill fragment (research Open
  Risks 1-2).
- **Naming collision.** Skill names must not collide with the 40 existing
  `.claude/skills/` names or the `code-modernization` plugin's `/modernize-*`
  commands (modernize-assess, modernize-brief, modernize-extract-rules,
  modernize-harden, modernize-map, modernize-preflight, modernize-reimagine,
  modernize-status, modernize-transform, modernize-uplift) or agents
  (legacy-analyst, business-rules-extractor, architecture-critic, scaffolder,
  security-auditor, test-engineer, version-delta-analyst). The `discovery-`
  prefix is verified disjoint; the nearest string (`legacy-analyst` vs the
  assumed `legacy-parity-analyst` slug) is a distinct exact name, and no
  `legacy-*` skill prefix is used (research Q3).
- **Push-down parity gate.** The always-on bundle parity test fails the branch
  unless the byte-copies land in the same change (Scope Clarification 1). This
  is the largest identified planning risk (research finding 3).
- **File-size cap.** Every new `SKILL.md` stays under 500 lines (stricter
  reading of `make-skill-template` plus `general-code-change`); the pytest
  module is test code bound by the 500-line cap without exception.
- **Evidence locations.** Evidence only under
  `<FEATURE>/evidence/<kind>/`; `artifacts/` sub-paths other than
  `artifacts/orchestration/` are forbidden and hook-enforced.
- **Feature-contract authorship assumption.** Contract production is assigned to
  the coverage stage (reviewed by the coverage role) because feature contracts
  and the coverage ledger are jointly derived from the inventory; if #9007
  assigns authorship differently, only stage-skill body text changes (research
  Open Risk 4).

## Implementation Strategy

- **What changes:** add seven `SKILL.md` files under `.claude/skills/`; add
  seven byte-identical copies under
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`; add
  one pytest module under `tests/scripts/dev_tools/`. No existing file is
  modified.
- **Dependency changes:** none. No new packages; no `pyproject.toml` changes.
- **Logging/telemetry:** none (Markdown deliverables plus a test module).
- **Rollout:** additive files on the feature branch; no feature flags. The
  bundle copies keep the always-on parity gate green; broader publishing follows
  in #9012.
- **Body conventions per skill:** `# Title`, `## When to Use This Skill`,
  prerequisites, step-by-step workflow, `## Worker Routing` (agent-stage skills
  only), `## Referenced Contracts` (umbrella only), references to
  `discovery-workflow` and `discovery-validate-artifacts` by name from stage
  skills.

## Acceptance Criteria

Traceability: AC-1 through AC-6 map one-to-one to the six issue #367 acceptance
criteria; AC-7 and AC-8 derive from the epic Shared Design mirror contract and
this spec's Scope Clarification 1; AC-9 derives from repository policy
(`general-code-change`, `python.md`). Epic-level trace: objective-source
Scope item 2 (Generic Skills), the domain-neutrality architectural boundary, and
the capability-level criterion "the core framework contains no domain-specific
identifiers."

- [x] AC-1: Seven reusable workflow-mechanics skills exist at
      `.claude/skills/discovery-*/SKILL.md` (per the decomposition table) and
      together sequence the discovery and parity-definition workflow: analyzer
      CLI invocation, agent-role routing, and artifact production/validation in
      the stage order profile -> inventory -> coverage -> runtime -> parity ->
      reconciliation -> validation gate. (issue AC 1)
- [x] AC-2: Each skill carries valid frontmatter per the repository SKILL.md
      contract — `name` (matching the folder) and single-quoted `description`
      required; `allowed-tools` only on `discovery-repo-inventory` and
      `discovery-validate-artifacts`; `context`/`agent` frontmatter not used
      (optional keys per the repository SKILL.md contract) — and references
      discovery agents, schemas, validators, and analyzer CLI commands by plain
      string name, with agent routing in body-level `## Worker Routing`
      sections. (issue AC 2, restated per research Q1)
- [x] AC-3: No new skill name collides with any existing `.claude/skills/` name,
      any `code-modernization` `/modernize-*` command name, or any
      `code-modernization` agent name; the contract test asserts non-collision
      against a frozen name set. (issue AC 3)
- [x] AC-4: All new skill files and their bundle mirrors contain none of the
      banned domain substrings (case-insensitive), and no skill names a
      stack-specific analyzer literally; domain specificity is read from the
      domain profile at runtime via `dev.discovery.profile`. (issue AC 4)
- [x] AC-5: Upstream references (#9006 analyzer framework, #9007 agent roles)
      are isolated as plain string names concentrated in the
      `discovery-workflow` `## Referenced Contracts` registry; the two assumed
      names (#9006 inventory command `dev.discovery.inventory`; the four #9007
      agent slugs) are explicitly flagged as fan-in reconciliation assumptions;
      no skill or test asserts the existence of #9006/#9007 artifacts.
      (issue AC 5)
- [x] AC-6: `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`
      exists and passes, covering: SKILL.md existence, frontmatter
      well-formedness, required reference fragments, banned-substring absence,
      plugin-name non-collision, and bundle byte-parity — asserting only on this
      feature's own files. (issue AC 6)
- [x] AC-7: Each new `SKILL.md` exists byte-identically at
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/SKILL.md`,
      and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
      passes on the feature branch. (epic mirror contract; Scope
      Clarification 1)
- [x] AC-8: The scope clarification is recorded in this spec: broader
      `resources/` publishing (pack manifests, converter registration,
      `.github`/`.agents` mirrors) remains #9012, while the byte-identical
      bundle copy of this feature's skills is a mandatory in-feature step.
      (Scope Clarification 1)
- [x] AC-9: Every new `SKILL.md` and the pytest module are under 500 lines, and
      the Python toolchain (Black, Ruff, Pyright, Pytest) passes for the test
      module with no reduction in coverage. (repository policy)

## Definition of Done

- [x] All acceptance criteria above checked off with evidence
- [x] Structural contract tests pass (`test_legacy_discovery_skills_contracts.py`)
- [x] Push-down parity gate passes (`test_push_down_claude_resource_contracts.py`)
- [x] Toolchain pass completed for the Python test module (format -> lint ->
      type-check -> test)
- [x] Evidence recorded under
      `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/<kind>/`
- [x] Feature docs (spec, user story) current

## Seeded Test Conditions (from issue)

- [x] Skill structural checks: each new SKILL.md has valid YAML frontmatter with
      the required fields per repository precedent (`name` matching folder;
      non-empty `description`).
- [x] Skill names do not collide with the `code-modernization` plugin
      command/agent names.
- [x] Domain-neutrality: no banned domain substrings in skill sources or bundle
      mirrors (case-insensitive).
- [x] Referenced agent, schema, validator, and analyzer CLI names match the
      planned upstream contracts as recorded in the `discovery-workflow`
      registry, with the two assumed names flagged for fan-in reconciliation.
- [x] Bundle parity: each new skill byte-identical in the bundled payload.
