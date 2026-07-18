# legacy-discovery-agent-roles — Spec

- **Issue:** #365
- **Parent (optional):** Epic `legacy-discovery-and-parity` (child feature #9007, Wave 1, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T15-45
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Overview

The legacy-discovery-and-parity epic requires four reusable, domain-neutral agent personas
that reason over the discovery schemas and the domain-profile contract to produce the
discovery artifacts. Without these personas, the downstream generic-skills feature (#9008,
which depends on #9007) has no reasoning agents to orchestrate. The personas must be generic:
no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior; all domain
specificity is supplied at runtime through the domain profile (#9001) and the schemas
(#9002).

This feature authors ONLY the four `.claude/agents/*.md` persona definitions plus one
PowerShell Pester structural test. It does not implement discovery-workflow skills (feature
#9008) and does not mirror assets into
`extensions/drm-copilot/resources/claude-customizations/` (feature #9012). Design analysis is
recorded in the research artifact
`docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/research/2026-07-17T15-45-legacy-discovery-agent-roles-research.md`,
which is authoritative for the current-state conventions, verified non-colliding slugs, and
per-persona schema mapping cited below.

## Behavior

Author four reusable, domain-neutral agent personas as `.claude/agents/*.md` definitions,
each following the repository's existing agent-definition conventions (YAML frontmatter:
`name`, `description`, `model`, `tools` allowlist, `memory` scope). Each persona documents the
discovery schemas and the domain-profile fields it consumes and the discovery artifact it
produces. The four personas and their verified non-colliding slugs (research section 2) are:

- Legacy Parity Analyst -> `legacy-parity-analyst.md` — reasons about source-to-target parity
  from feature contracts and parity-matrix evidence.
- Runtime Characterization Analyst -> `runtime-characterization-analyst.md` — reasons about
  observed runtime behavior and characterization scenarios.
- Requirements Reconciler -> `requirements-reconciler.md` — reconciles undocumented,
  contradictory, or ambiguous behavior into product-decision records.
- Migration Coverage Reviewer -> `migration-coverage-reviewer.md` — reviews legacy
  implementation coverage against the coverage ledger.

The filename must equal `<slug>.md` because the repository convention is that the frontmatter
`name` equals the file basename (research section 1). `legacy-parity-analyst` intentionally
differs from the `code-modernization` plugin's `legacy-analyst` by the `parity` discriminator
to avoid both collision and confusion.

## Resolved Specification Decisions

The research artifact (section 7) identified five open specification decisions. The
orchestrator has resolved them as follows; these resolutions are authoritative for
implementation.

### Decision 1 — Write-tool scope glob

Adopt the conventional domain-neutral glob `"Write(discovery/**)"` as the static default,
matching the #9001 default `artifacts.root: "discovery/"`. Each persona body must document
that the true artifact root is the runtime-configured `artifacts.root` from the domain profile,
and that exact-path enforcement is deferred to the #9004 completion-gate hooks. The static glob
is a least-privilege default for direct invocation, not the enforcement mechanism. Personas
also require `Read`, `Grep`, and `Glob`. `WebFetch` is NOT granted: discovery reasons over
local contracts and evidence, not the web.

### Decision 2 — Model tier

Assign `model: sonnet` uniformly to all four personas. Rationale: these are domain-neutral,
reusable analyst/authoring personas analogous to `task-researcher` and
`human-exception-runbook`, both `sonnet`. The static `model` field is a default for direct
invocation; runtime model routing (`resolve_delegation_model`, per
`.claude/rules/orchestrator-state.md`) escalates complexity at delegation time, so a uniform
`sonnet` default does not constrain delegated escalation.

### Decision 3 — `skills` field

Omit the `skills:` field on all four personas. The discovery-workflow skills these personas
would preload are feature #9008 and do not exist yet; preloading a non-existent skill would be
invalid. The existing orchestration skills (`policy-compliance-order`,
`evidence-and-timestamp-conventions`) encode drm-copilot-specific policy and paths that would
compromise domain neutrality for consumer repositories. Omitting `skills:` is supported by
precedent (`task-researcher` has no `skills:` field).

### Decision 4 — `hooks` field

Omit the `hooks:` field on all four personas. The completion-gate validators (#9003) and hooks
(#9004) that a `SubagentStop` hook would invoke do not exist yet
(`scripts/dev_tools/discovery/**` is absent). A hook referencing a missing script would break
invocation. This is a deliberate downstream deferral: hook wiring is owned by #9004 and the
discovery skills (#9008).

### Decision 5 — AC4 enforcement

Machine-check AC4 with a body-content assertion in the Pester structural test. Each persona
body must explicitly name its consumed schema(s), its produced schema(s), and the domain
profile. This is a testable acceptance criterion, not prose-only.

## Inputs / Outputs

- Inputs: none at build time beyond the persona-definition source. At runtime, each persona
  reasons over consumer-repository discovery artifacts (the seven schemas) and the consumer's
  `discovery-profile.yaml` domain profile.
- Outputs: four `.claude/agents/*.md` persona files and one PowerShell Pester structural test.
- Config keys and defaults: none introduced by this feature. Personas reference the
  runtime-configured `artifacts.root` (#9001 default `discovery/`), not a build-time config.
- Versioning or backward-compatibility constraints: agents are auto-discovered from
  `.claude/agents/`; no `settings.json` registry entry is required for discoverability
  (research section 1). No `SubagentStop` matcher is added to `settings.json` for these
  personas at #9007 time (Decision 4).

## Frontmatter Contract (all four personas)

Each persona carries the following frontmatter fields:

- `name`: the persona slug, equal to the file basename.
- `description`: one to three sentences stating the domain-neutral role and the write scope.
- `model`: `sonnet` (Decision 2).
- `tools`: `Read`, `Grep`, `Glob`, `"Write(discovery/**)"` (Decision 1).
- `memory`: `project` (uniform across all existing agents).
- No `skills:` field (Decision 3). No `hooks:` field (Decision 4).

## Per-Persona Design (domain-neutral)

Schema-to-persona mapping is confirmed against `objective-source.md` section 4 (the seven
schemas: Feature Contract, Coverage Ledger, Runtime Characterization Scenario, Parity Matrix,
Unspecified Behavior Record, Product Decision Record, Evidence Reference) and research section
3. Evidence Reference is a cross-cutting linkage schema consumed as a reference input by all
four personas; it is not owned or produced by any single persona in this set.

### legacy-parity-analyst (Legacy Parity Analyst)

- Core responsibilities: reason about source-to-target parity from feature contracts and
  existing parity-matrix evidence; produce and update Parity Matrix records.
- Schemas consumed: Feature Contract, Parity Matrix, Evidence Reference.
- Schema produced/updated: Parity Matrix.
- Domain-profile fields consumed: `legacy_source`, `target`, `technology_stack`,
  `artifacts.root`.

### runtime-characterization-analyst (Runtime Characterization Analyst)

- Core responsibilities: reason about observed runtime behavior and characterization
  scenarios; produce Runtime Characterization Scenario records with evidence linkage.
- Schemas consumed: Runtime Characterization Scenario, Evidence Reference, Feature Contract.
- Schema produced/updated: Runtime Characterization Scenario.
- Domain-profile fields consumed: `legacy_source`, `technology_stack.legacy`,
  `artifacts.root`.

### requirements-reconciler (Requirements Reconciler)

- Core responsibilities: reconcile undocumented, contradictory, or ambiguous behavior into
  product-decision records.
- Schemas consumed: Unspecified Behavior Record, Evidence Reference, Feature Contract.
- Schema produced/updated: Product Decision Record.
- Domain-profile fields consumed: `legacy_source`, `target`, `artifacts.root`.

### migration-coverage-reviewer (Migration Coverage Reviewer)

- Core responsibilities: review legacy implementation coverage against the coverage ledger.
- Schemas consumed: Coverage Ledger, Feature Contract, Evidence Reference.
- Schema produced/updated: Coverage Ledger review findings / updated review status.
- Domain-profile fields consumed: `legacy_source`, `technology_stack.legacy`,
  `artifacts.root` / `artifacts.conventions`.

## API / CLI Surface

No CLI or MCP surface is introduced by this feature. The personas are agent definitions
consumed by future discovery skills (#9008), not invoked directly by the orchestrator here.
They are not part of the orchestration worker set and are therefore not added to the
`settings.json` `SubagentStop` worker matcher (research section 1).

## Data & State

- Data transformations and invariants: none at build time. At runtime, each persona reads
  discovery artifacts and writes to the runtime-configured artifacts root; the persona body
  documents this constraint.
- Caching or persistence details: `memory: project` scope, consistent with all existing
  agents.
- Migration or backfill requirements: none.

## Structural Test

Author one PowerShell Pester structural test at
`tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` (verified precedent
directory alongside `claude-runtime-structure.Tests.ps1`, `claude-settings.Tests.ps1`, and
`test-name-uniqueness.Tests.ps1`). This location satisfies the general-unit-test policy
requirement that tests mirror source under `tests/`; the established mirror location for
`.claude/` runtime assets is `tests/scripts/claude-runtime/`.

Follow the `test-name-uniqueness.Tests.ps1` precedent: place reusable helpers (frontmatter
extraction, banned-substring scan) in `BeforeAll`, exercise them with in-memory positive and
negative fixtures (a compliant synthetic persona passes; a synthetic persona containing a
banned substring or a colliding slug fails), then run the same helpers over the four real
files. This proves the detection logic independently of the repository files. Avoid case-only
`It`/`-ForEach` collisions per the `test-name-uniqueness` precedent.

The test asserts:

1. Existence: each of the four `.claude/agents/<slug>.md` files exists (`Test-Path -PathType
   Leaf`), enumerated over the four expected slugs.
2. Frontmatter validity: for each file, extract the `---`-delimited frontmatter block via the
   hand-rolled frontmatter regex convention and assert presence of `name:`, `description:`,
   `model:`, `tools:`, and `memory:`.
3. Name equals slug: assert the `name:` value equals the expected slug and the file basename.
4. Model membership: assert `model:` is one of `haiku|sonnet|opus`.
5. Naming non-collision: assert the four slugs are disjoint from the `code-modernization`
   plugin name set (`legacy-analyst`, `business-rules-extractor`, `architecture-critic`,
   `scaffolder`, `security-auditor`, `test-engineer`, `version-delta-analyst`) and from the
   other existing `.claude/agents/` basenames.
6. Domain-neutral banned-substring scan: for each file's full text (frontmatter and body),
   assert no case-insensitive match against the banned-substring list: `taskmaster`, `tmw`,
   `outlook`, `vsto`, `email`, `task-management`, and `task management` (both hyphenated and
   spaced forms). Any hit is a Blocking test failure.
7. AC4 body-content assertion: assert each persona body explicitly names its consumed
   schema(s), its produced schema(s), and the domain profile (Decision 5).

## Implementation Strategy

- Implementation scope: add four Markdown persona files under `.claude/agents/` and one Pester
  test under `tests/scripts/claude-runtime/`. No executable production code is added.
- New files to add: `.claude/agents/legacy-parity-analyst.md`,
  `.claude/agents/runtime-characterization-analyst.md`,
  `.claude/agents/requirements-reconciler.md`,
  `.claude/agents/migration-coverage-reviewer.md`, and
  `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`.
- Dependency changes: none. The Pester structural test uses the repository's hand-rolled
  frontmatter regex convention; no PyYAML or new dependency is introduced.
- Logging/telemetry additions: none.
- Rollout plan: no feature flags. Personas are auto-discovered from `.claude/agents/`.

## Testing and Coverage

The deliverables are four non-executable Markdown persona files plus one Pester structural
test. Markdown is exempt from the 500-line file limit (general-code-change policy) and produces
no line or branch coverage. The `.Tests.ps1` file is test infrastructure and is excluded from
coverage per general-unit-test policy. Because this feature adds no new executable production
code, the changed-file coverage gate is legitimately N/A for this feature's changed files; the
Pester structural test is the acceptance-verification mechanism. Feature-review should confirm
that a Markdown-plus-test change set yields no coverage FAIL, since coverage applies to changed
executable files and there are none here.

## Constraints & Risks

- Domain neutrality is an epic-wide invariant. No TaskMaster/TMW/Outlook/VSTO/email/
  task-management identifiers may appear in any persona's frontmatter or body.
- Naming-collision constraint against the `code-modernization` plugin agents is mandatory.
- Any new `.claude/` asset must later be mirrored into
  `extensions/drm-copilot/resources/claude-customizations/` by the downstream publishing
  feature (#9012); this feature authors only the `.claude/` assets and must NOT create the
  mirror copies (research section 6).
- The personas reference the contracts defined by #9001 (domain profile) and #9002 (seven
  schemas), both prepared in parallel within the epic. Those dependency folders are not present
  on the current integration tip; design proceeds against the contracts as summarized in
  `objective-source.md` section 4 and the research artifact.
- Skills implementation is out of scope (feature #9008). Completion-gate validators (#9003) and
  hooks (#9004) are out of scope; hook wiring is deferred (Decision 4).

## Out of Scope

- Discovery-workflow skills (feature #9008).
- Mirroring assets into `extensions/drm-copilot/resources/claude-customizations/` (feature
  #9012).
- Completion-gate validators (#9003) and `SubagentStop`/PreToolUse hooks (#9004).
- Any `skills:` or `hooks:` frontmatter on the four personas.

## Acceptance Criteria

For full-feature work mode, `spec.md` and `user-story.md` are both acceptance-criteria sources.
Checkboxes remain unchecked; delivery occurs in the execution phase, which is out of scope for
this preparation run.

- [x] Four domain-neutral agent `.md` personas exist under `.claude/agents/`
      (`legacy-parity-analyst.md`, `runtime-characterization-analyst.md`,
      `requirements-reconciler.md`, `migration-coverage-reviewer.md`), each with valid YAML
      frontmatter containing `name`, `description`, `model`, `tools`, and `memory`.
- [x] Each persona's `name` equals its slug and file basename; `model` is one of
      `haiku|sonnet|opus` (specifically `sonnet` per Decision 2); `tools` is exactly `Read`,
      `Grep`, `Glob`, `"Write(discovery/**)"`; `memory` is `project`.
- [x] No persona carries a `skills:` field or a `hooks:` field (Decisions 3 and 4).
- [x] The four slugs do not collide with the `code-modernization` plugin agent names
      (`legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`,
      `security-auditor`, `test-engineer`, `version-delta-analyst`) or with existing
      `.claude/agents/` basenames.
- [x] Each persona is domain-neutral: the case-insensitive banned-substring scan
      (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, `task management`)
      finds no match in any persona's frontmatter or body.
- [x] Each persona body explicitly names its consumed discovery schema(s), its produced
      discovery artifact/schema, and the domain profile, per the confirmed mapping in the
      per-persona design (machine-checked by the AC4 body-content assertion).
- [x] A PowerShell Pester structural test exists at
      `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` with in-memory
      positive and negative fixtures, covering existence, frontmatter validity,
      name-equals-slug, model membership, naming non-collision, banned-substring
      domain-neutrality scan, and the AC4 body-content assertion; the test passes.
- [x] No discovery-workflow skills (#9008), completion-gate validators/hooks (#9003/#9004), or
      `resources/` mirror copies (#9012) are added by this feature.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to Pester assertions
- [ ] Persona definitions match acceptance criteria
- [ ] Pester structural test added and passing
- [ ] Edge cases and negative fixtures covered by the structural test
- [ ] Docs updated (this spec and user-story linked from the feature folder)
- [ ] Toolchain pass completed for the changed files (format, lint, test as applicable)

## Seeded Test Conditions (from potential)

- [ ] Structural/frontmatter checks for the four agent definitions (repo precedent).
- [ ] Domain-neutrality scan for banned substrings.
- [ ] Naming-collision guard against the code-modernization plugin agent names.
