# Research: legacy-discovery-agent-roles (#365 / epic child #9007)

- Date: 2026-07-17T15-45
- Author: task-researcher
- Feature: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365`
- Epic: `legacy-discovery-and-parity`
- Mode: preparation-mode research (no source/config changes made)

## Scope Recap and Verified Constraints

This feature authors FOUR reusable, domain-neutral agent personas as `.claude/agents/*.md`
definitions. It does not implement skills (skills are feature #9008,
`legacy-discovery-skills`, which `depends_on` `legacy-discovery-agent-roles` per the epic
manifest, `docs/features/epics/legacy-discovery-and-parity/epic.md` lines 40-42).

Verified constraints from repository evidence:

- Domain neutrality is an epic-wide invariant
  (`docs/features/epics/legacy-discovery-and-parity/objective-source.md` lines 28-31, 129-136;
  `epic.md` lines 92-94, 103-106). No TaskMaster / TMW / Outlook / VSTO / email /
  task-management identifiers may appear in frontmatter or body; domain specificity is supplied
  at runtime via the domain profile (#9001) and schemas (#9002).
- Naming-collision constraint against the installed `code-modernization` plugin is mandatory
  (`objective-source.md` lines 163-169). The plugin ships agents `legacy-analyst`,
  `business-rules-extractor`, `architecture-critic`, `scaffolder`, `security-auditor`,
  `test-engineer`, `version-delta-analyst`. Grep confirms these names appear in this repository
  only inside epic/feature documentation, not as installed agent files; the plugin is external
  and non-integrated.
- Mirror obligation: every asset added under `.claude/` must be mirrored into
  `extensions/drm-copilot/resources/claude-customizations/.claude/` (verified path; e.g.
  `.../.claude/agents/task-researcher.md` exists there). The mirror is owned by the downstream
  publishing feature #9012 (`epic.md` line 120; `objective-source.md` lines 106-110). This
  feature authors ONLY the `.claude/` assets and does not mirror.

Dependency folders for #9001 (`legacy-discovery-config-contract`, issue #360) and #9002
(`legacy-discovery-schemas`) are NOT present on this integration tip (Glob for
`docs/features/active/*legacy-discovery-config*`, `scripts/dev_tools/discovery/**`, and
`schemas/**` all returned no files). Design proceeds against the contracts as summarized in the
delegation prompt and `objective-source.md` section 4.

## 1. Current-State Analysis: Agent-Definition Conventions

Evidence base: all 18 files under `.claude/agents/*.md`, read in full or by frontmatter.

### Frontmatter fields (YAML, delimited by `---`)

| Field | Required | Observed values / syntax |
|---|---|---|
| `name` | yes | kebab-case slug, equals the file basename (e.g. `task-researcher`, `feature-review`). |
| `description` | yes | One sentence to one paragraph; states role and write scope. |
| `model` | yes | One of `haiku`, `sonnet`, `opus` (see tier table below). |
| `tools` | yes | YAML list. Entries are either bare tool names (`Read`, `Grep`, `Glob`, `WebFetch`) or scoped-capability strings quoted as `"Write(/path/glob/**)"`, `"Bash(git diff *)"`, `"Edit(docs/**)"`. |
| `skills` | optional | YAML list of existing skill slugs (e.g. `policy-compliance-order`). Omitted by several agents (e.g. `task-researcher` has no `skills:` field). |
| `memory` | yes (observed uniformly) | `project` on all 18 agents. No other value observed. |
| `hooks` | optional | `SubagentStop` (and/or `PreToolUse`) blocks with `matcher` equal to the agent name and a `command` invoking a `pwsh -NoProfile -File .claude/hooks/*.ps1` validator. |

Field ordering is not uniform across files (e.g. `human-exception-runbook.md` orders
`description` before `model`; most order `name`, `model`, `description`). No test asserts field
order, so order is not load-bearing.

### Model tier assignment (evidence: grep `^model:` across `.claude/agents`)

- `opus`: `orchestrator`, `epic-orchestrator`, `epic-planner`, `atomic-planner`,
  `atomic-executor`, `feature-review`, `epic-review`, `staged-review`, `prd-feature`.
  Pattern: orchestration, planning, and review/judgment agents.
- `sonnet`: `task-researcher`, `human-exception-runbook`, `python-typed-engineer`,
  `powershell-typed-engineer`, `csharp-typed-engineer`, `typescript-engineer`, `pr-author`.
  Pattern: research, typed engineering, and artifact-authoring agents.
- `haiku`: `status-updater`, `commit-message`. Pattern: mechanical/low-reasoning tasks.

### Tools allowlist syntax (least-privilege, read + scoped-write)

Closest analogs to the four new personas (read + write markdown/JSON artifacts):

- `task-researcher.md` (lines 5-12): `Read`, `Grep`, `Glob`, `WebFetch`,
  `"Write(/docs/features/**/research/**)"`, `"Write(/docs/research/**)"`, and a skill entry
  listed under `tools` (`evidence-and-timestamp-conventions`). No separate `skills:` field.
- `feature-review.md` (lines 5-11): `Read`, `Grep`, `Glob`, `"Bash(git diff *)"`,
  `"Bash(git log *)"`, `"Write(/docs/features/active/**)"`; `skills:` lists
  `policy-compliance-order`, `acceptance-criteria-tracking`.
- `human-exception-runbook.md` (lines 8-13): `Read`, `Grep`, `Glob`, `WebFetch`,
  `"Write(<FEATURE>/runbooks/**)"`. Demonstrates the `<FEATURE>` placeholder token in a Write
  scope.
- `atomic-planner.md` (lines 5-12): read tools plus both `Edit(...)` and `Write(...)` scopes.

Observed: write scopes are path-globbed and quoted; the `<FEATURE>` placeholder is a supported
convention for feature-relative write scopes.

### Hooks and settings.json registration

- Per-agent `SubagentStop` hooks appear in agent frontmatter (e.g. `task-researcher.md` lines
  14-19 call `validate-task-researcher-output.ps1`).
- `.claude/settings.json` (lines 187-239) ALSO registers `SubagentStop` matchers by agent name.
  The generic matcher at line 189 enumerates the orchestration worker set
  (`atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|
  epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|
  csharp-typed-engineer|typescript-engineer|orchestrator|epic-orchestrator|epic-planner`) and
  requires a completion-artifact path token. `claude-settings.Tests.ps1` (lines 23-36) asserts
  this worker set is present in hook coverage.
- Agents are auto-discovered from `.claude/agents/`; there is no `agents` registry array in
  `settings.json` (grep for `agents` in `settings.json` returned only the SubagentStop line).
  Therefore a pure agent-definition file does not require a `settings.json` entry to exist and
  be discoverable. A `settings.json` entry is only needed to wire a completion-gate hook by
  matcher.

Conclusion for this feature: the four personas are NOT part of the orchestration worker set and
are consumed by future discovery skills (#9008), not invoked directly by the orchestrator here.
The completion-gate hook infrastructure that would validate their output is owned by
`legacy-discovery-hooks` (#9004, `depends_on` #9003 validators) and the discovery skills
(#9008). Wiring a `SubagentStop` hook now would reference validator scripts that do not yet
exist (`scripts/dev_tools/discovery/**` is absent). See the recommendation in section 3.

### Frontmatter parsing precedent (no Python agent validator today)

Grep of `scripts/**.py` for agent-frontmatter handling returned only the
`codex_native_converter` modules (`parser.py`, `classifier.py`, `mapping.py`, etc.) and
push-down mirror scripts. These parse agent frontmatter for ecosystem conversion and mirroring,
not for structural validation. There is NO standalone Python agent-frontmatter validator in the
repository. The `objective-source.md` "Required Operating Mode" and epic Shared Design describe
the repo's parser convention as a "hand-rolled frontmatter regex convention" (`epic.md` line
110; `objective-source.md` lines 66-68, 142). Existing structural verification for `.claude/`
runtime assets is exclusively PowerShell Pester (see section 4).

## 2. Recommended Slugs (verified non-colliding, non-existent)

Proposed slugs, each the distinct kebab-case slugification of the four role names:

| Role | Proposed slug | Collision check |
|---|---|---|
| Legacy Parity Analyst | `legacy-parity-analyst` | Not in `.claude/agents/` (Glob). Distinct from plugin `legacy-analyst` (extra `-parity-` token). |
| Runtime Characterization Analyst | `runtime-characterization-analyst` | Not in `.claude/agents/`. No plugin overlap. |
| Requirements Reconciler | `requirements-reconciler` | Not in `.claude/agents/`. No plugin overlap. |
| Migration Coverage Reviewer | `migration-coverage-reviewer` | Not in `.claude/agents/`. No plugin overlap. |

Verification method: Glob of `.claude/agents/*.md` yields the 18 existing agents (none match
the four proposed slugs); the `code-modernization` plugin names (`legacy-analyst`,
`business-rules-extractor`, `architecture-critic`, `scaffolder`, `security-auditor`,
`test-engineer`, `version-delta-analyst`) are all distinct from the four proposed slugs by exact
string comparison. Rationale: each slug is descriptive, matches the role name in the epic
objective (`objective-source.md` lines 51-59), and is domain-neutral (no TaskMaster/Outlook/etc
tokens). `legacy-parity-analyst` intentionally differs from the plugin's `legacy-analyst` by the
`parity` discriminator to avoid confusion as well as collision.

Note: filenames must equal `<slug>.md` (repo convention: `name` equals file basename), so the
four files are `legacy-parity-analyst.md`, `runtime-characterization-analyst.md`,
`requirements-reconciler.md`, `migration-coverage-reviewer.md`.

## 3. Per-Persona Design (domain-neutral)

All four personas share the following recommended frontmatter baseline, derived from the
`task-researcher` / `human-exception-runbook` analyst analog:

- `model`: `sonnet` (baseline recommendation; see the open decision in section 7 for the
  `opus` alternative for the two judgment-rendering reviewers).
- `tools`: `Read`, `Grep`, `Glob`, plus a scoped `Write(...)` for the discovery-artifact root.
  The Write glob depends on the artifact-root convention fixed by #9001/#9005 and is an open
  decision (section 7). `WebFetch` is NOT recommended (discovery reasons over local
  contracts/evidence, not the web).
- `skills`: omitted. The discovery-workflow skills that these personas would preload are feature
  #9008 and do not exist yet; preloading a non-existent skill would be invalid, and the existing
  orchestration skills (`policy-compliance-order`, `evidence-and-timestamp-conventions`) encode
  drm-copilot-specific policy/paths and would compromise domain neutrality for consumer repos.
  Omitting `skills:` is supported (e.g. `task-researcher` has no `skills:` field).
- `memory`: `project` (uniform across all existing agents).
- `hooks`: omitted for this feature. The completion-gate validators that a `SubagentStop` hook
  would invoke are owned by #9003 (validators) and #9004 (hooks) and are absent today. Adding a
  hook that references a missing script would break invocation. Note this as a deliberate
  deferral; hook wiring is a downstream concern.

Domain-profile fields available (from #9001 contract summary): `profile_version`,
`profile_name`, `legacy_source{root,description,include,exclude}`, `target{root,description}`,
`technology_stack{legacy,target}`, `artifacts{root,conventions}`. Personas read these by
reasoning over the consumer repo's `discovery-profile.yaml` (the programmatic loader
`scripts/dev_tools/discovery/domain_profile.py` — `parse_domain_profile_text`,
`load_domain_profile`, `DomainProfile` — is used by skills/validators, not directly by a
markdown persona). All four consume `profile_name`/`profile_version` (provenance) and
`artifacts.root`/`artifacts.conventions` (where to read/write artifacts).

### 3.1 legacy-parity-analyst (Legacy Parity Analyst)

- Responsibility: reason about source-to-target parity from feature contracts and existing
  parity-matrix evidence; produce/update Parity Matrix records.
- Schemas consumed: Feature Contract (source of expected behavior), Parity Matrix (existing
  parity state), Evidence Reference (linked evidence).
- Schema produced/updated: Parity Matrix records.
- Domain-profile fields: `legacy_source` and `target` (both roots + descriptions; parity is a
  source-vs-target comparison), `technology_stack{legacy,target}`, `artifacts.root`.

### 3.2 runtime-characterization-analyst (Runtime Characterization Analyst)

- Responsibility: reason about observed runtime behavior and characterization scenarios;
  produce Runtime Characterization Scenario records with evidence linkage.
- Schemas consumed: Runtime Characterization Scenario (existing), Evidence Reference; Feature
  Contract for the behavior under characterization.
- Schema produced/updated: Runtime Characterization Scenario (and Evidence Reference links).
- Domain-profile fields: `legacy_source` (the observed system), `technology_stack.legacy`,
  `artifacts.root`.

### 3.3 requirements-reconciler (Requirements Reconciler)

- Responsibility: reconcile undocumented, contradictory, or ambiguous behavior into
  product-decision records.
- Schemas consumed: Unspecified Behavior Record (undocumented/contradictory/ambiguous input),
  Evidence Reference; Feature Contract for context.
- Schema produced/updated: Product Decision Record.
- Domain-profile fields: `legacy_source` (behavior origin), `target` (decision context),
  `artifacts.root`.

### 3.4 migration-coverage-reviewer (Migration Coverage Reviewer)

- Responsibility: review legacy implementation coverage against the coverage ledger.
- Schemas consumed/reviewed: Coverage Ledger (primary), Feature Contract (expected surface),
  Evidence Reference.
- Schema produced/updated: Coverage Ledger review findings / updated review status.
- Domain-profile fields: `legacy_source`, `technology_stack.legacy`,
  `artifacts.root`/`artifacts.conventions`.

### Schema-to-persona mapping confirmation

The proposed mapping in the delegation prompt is consistent with `objective-source.md` section 4
(the seven schemas: Feature Contract, Coverage Ledger, Runtime Characterization Scenario, Parity
Matrix, Unspecified Behavior Record, Product Decision Record, Evidence Reference) and the role
descriptions in `objective-source.md` lines 51-59. Refinement: Evidence Reference is a
cross-cutting linkage schema consumed as a reference input by all four personas (each produced
artifact links to evidence), not owned/produced by any single persona in this set.

## 4. Recommended Structural-Test Strategy

### Selected approach: PowerShell Pester structural test

Location: `tests/scripts/claude-runtime/` (verified precedent directory; existing files
`claude-runtime-structure.Tests.ps1`, `claude-settings.Tests.ps1`,
`claude-architecture-doc.Tests.ps1`, `test-name-uniqueness.Tests.ps1`). Proposed filename:
`legacy-discovery-agent-roles.Tests.ps1`. This satisfies the general-unit-test policy
requirement that tests mirror source under `tests/`; `.claude/` runtime assets' established
mirror location is `tests/scripts/claude-runtime/`.

Recommended assertions (patterned on `claude-runtime-structure.Tests.ps1` and
`claude-settings.Tests.ps1`, resolving `$RepoRoot` by walking up from `$PSScriptRoot`):

1. Existence: each of the four `.claude/agents/<slug>.md` files exists (`Test-Path -PathType
   Leaf`), enumerated over the four expected slugs (avoid case-only `It`/`-ForEach` collisions
   per `test-name-uniqueness.Tests.ps1`).
2. Frontmatter validity: for each file, extract the `---`-delimited frontmatter block via regex
   (hand-rolled frontmatter convention; PowerShell has no native YAML parser and repo precedent
   uses regex/`ConvertFrom-Json`, not YAML) and assert presence of `name:`, `description:`,
   `model:`, `tools:`, and `memory:` lines.
3. Name-equals-slug: assert the `name:` value equals the expected slug and the file basename.
4. Model membership: assert `model:` is one of `haiku|sonnet|opus`.
5. Naming non-collision: assert the four slugs are disjoint from the `code-modernization` plugin
   name set (`legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`,
   `security-auditor`, `test-engineer`, `version-delta-analyst`) and from the other existing
   `.claude/agents/` basenames.
6. Domain-neutral banned-substring scan: for each file's full text (frontmatter + body),
   assert no case-insensitive match against the banned-substring list (section 5).

Follow the `test-name-uniqueness.Tests.ps1` structure: put reusable helpers (frontmatter
extraction, banned-substring scan) in `BeforeAll`, exercise them with in-memory fixtures
(positive: a compliant synthetic persona passes; negative: a persona containing a banned
substring fails), then run the same helper over the four real files. This keeps the detection
logic proven independently of the repository files.

### Rejected alternative: Python (pytest) frontmatter contract test

A pytest validator parsing frontmatter (PyYAML) was considered. Rejected because: (a) no
existing Python agent-frontmatter validator exists to extend; (b) it introduces a second
verification mechanism and a PyYAML dependency where the repository convention is hand-rolled
frontmatter regex (`epic.md` line 110); (c) every existing `.claude/` runtime structural check
is Pester, so Pester is the lower-friction, precedent-consistent choice. Keep the Python
mechanism reserved for the schema/config validators (#9003), which is where the canonical
`validate_<artifact>_text` pattern belongs.

## 5. Domain-Neutrality Verification Approach

Banned-substring list (from `objective-source.md` lines 28-31, 93-94, 131-132; case-insensitive
match over the entire file text, frontmatter and body):

- `taskmaster`
- `tmw`
- `outlook`
- `vsto`
- `email`
- `task-management` and `task management` (both hyphenated and spaced forms)

Scan method: case-insensitive substring match (e.g. PowerShell `-imatch` with escaped literals,
or `-clike`/`.ToLowerInvariant().Contains(...)`). The scan is a Blocking gate: any hit is a test
failure. Note two false-positive risks to document in the test rationale so future edits do not
work around the gate improperly: `email` would also match `emailing`/`e-mail` variants (acceptable
— all indicate domain leakage), and `tmw` is short; the four persona bodies are domain-neutral by
construction so no legitimate token contains these substrings. This scan should also run inside
the epic-wide domain-neutrality context; this feature's test enforces it locally for the four
new files.

## 6. Mirror-Obligation Note

The four new `.claude/agents/*.md` files (and the new Pester test, if the push-down contract
tracks test mirrors) will need mirroring into
`extensions/drm-copilot/resources/claude-customizations/.claude/agents/` (verified target
subtree). That mirroring is owned by feature #9012 (`legacy-discovery-publishing`), per
`epic.md` lines 55-57 and 120 and `objective-source.md` lines 106-110. This feature (#9007) must
NOT create the mirror copies; doing so pre-empts #9012 and could desynchronize the push-down
contract. Record the obligation as a downstream dependency only.

Open verification point for the spec author: confirm whether the push-down contract test treats
a new `.claude/agents/*.md` on the integration branch as immediately requiring a mirror (which
would make #9007 and #9012 co-dependent on the same branch) or whether the mirror is applied at
epic-integration time by #9012. The epic DAG lists #9012 `depends_on` #9007, indicating the
mirror is applied downstream, not within #9007.

## 7. Testing Implications and Open Specification Decisions

Testing implications:

- The deliverables are four non-executable Markdown persona definitions plus one PowerShell
  Pester test. Markdown is exempt from the 500-line file limit (general-code-change policy) and
  produces no line/branch coverage. The new `.Tests.ps1` is test infrastructure (excluded from
  coverage per general-unit-test policy). If no executable production code is added, the
  language coverage gate for this feature is legitimately N/A for the changed files; the Pester
  structural test is the acceptance-verification mechanism. Confirm with feature-review that a
  markdown-plus-test change set yields no coverage FAIL (coverage applies to changed executable
  files; there are none here).
- All five acceptance criteria (user-story lines 43-53) map to the six Pester assertions in
  section 4: existence + frontmatter (AC1), non-collision (AC2), domain-neutral scan (AC3),
  documented schema/profile consumption (AC4 — verified by a body-content assertion that each
  persona names its consumed schemas and the domain profile), structural tests exist (AC5).
- Consider one additional assertion for AC4: each persona body must reference its input/output
  schema names and the domain profile, so the "documents which schemas/profile it consumes"
  criterion is machine-checked rather than prose-only.

Open specification decisions for the spec author (prd-feature) to resolve:

1. Write-tool scope glob. The discovery-artifact root is runtime-configured
   (`artifacts.root` in the domain profile) and lives in the CONSUMER repository, so a static
   `Write(...)` glob cannot capture it precisely. Options: (a) a domain-neutral conventional
   path glob once #9001/#9005 fix the default artifacts-root convention; (b) the `<FEATURE>`-style
   placeholder or a discovery-workspace placeholder token; (c) broad `Write` with the persona
   body documenting the artifacts-root constraint and enforcement deferred to #9004 hooks.
   Recommendation pending the #9001 artifacts-root convention; flag as blocking for final
   frontmatter.
2. Model tier per persona. Baseline recommendation is `sonnet` for all four (analyst/artifact-
   authoring analog: `task-researcher`, `human-exception-runbook`). Defensible alternative:
   `opus` for the two judgment-rendering reviewers (`legacy-parity-analyst`,
   `migration-coverage-reviewer`), matching the `feature-review`/`epic-review` reviewer analog.
   Note that runtime model routing (`resolve_delegation_model`, per
   `.claude/rules/orchestrator-state.md`) may override the static default at delegation time, so
   the static `model:` field is the default for direct invocation only.
3. Whether to add `skills:` referencing future discovery skills. Recommendation: omit now;
   #9008 owns skill authoring and any preload wiring. Confirm the spec does not require a
   `skills:` field on these personas at #9007 time.
4. Whether any `SubagentStop` completion-gate hook is required at #9007 time. Recommendation:
   omit; the validators (#9003) and hooks (#9004) do not exist yet. Confirm the spec defers hook
   wiring downstream.
5. Whether AC4 ("documents which schemas and the domain profile it consumes") should be
   enforced by a body-content Pester assertion (recommended) or left as prose-only.

## Summary of Recommendations

- Author four persona files: `legacy-parity-analyst.md`, `runtime-characterization-analyst.md`,
  `requirements-reconciler.md`, `migration-coverage-reviewer.md` under `.claude/agents/`.
- Frontmatter baseline: `model: sonnet`, `tools: [Read, Grep, Glob, Write(<artifacts-root
  glob>)]`, `memory: project`, no `skills`, no `hooks`; body documents consumed/produced
  schemas and consumed domain-profile fields, all domain-neutral.
- Add one Pester structural test at `tests/scripts/claude-runtime/
  legacy-discovery-agent-roles.Tests.ps1` covering existence, frontmatter validity,
  name-equals-slug, model membership, non-collision, and a case-insensitive banned-substring
  domain-neutrality scan, with in-memory positive/negative fixtures per the
  `test-name-uniqueness.Tests.ps1` precedent.
- Do not mirror to `resources/`; record the #9012 mirror obligation.
- Resolve the five open decisions in section 7 before authoring final frontmatter.
