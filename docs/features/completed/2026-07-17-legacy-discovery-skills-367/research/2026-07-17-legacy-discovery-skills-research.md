# Research: legacy-discovery-skills (Issue #367)

- Date: 2026-07-17
- Feature: `legacy-discovery-skills` (epic child #9008, Wave 2, C3, work_mode full-feature)
- Epic: `legacy-discovery-and-parity`
- Worktree root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad539c45a0675a010` (all paths below are relative to this root)
- Inputs: `docs/features/epics/legacy-discovery-and-parity/objective-source.md`, `docs/features/epics/legacy-discovery-and-parity/epic.md`, `docs/features/active/2026-07-17-legacy-discovery-skills-367/issue.md`, `docs/features/active/2026-07-17-legacy-discovery-skills-367/spec.md` (template stub as of this research)

## Findings Summary

1. The repository's SKILL.md frontmatter contract requires only `name` and `description`. `allowed-tools`, `argument-hint`, `context`, and `agent` are optional and sparsely used: only 3 of 40 skills use `context: fork` + `agent:` (the epic-* fork skills), and 6 use `allowed-tools`. Wrapper skills that delegate to agents (for example `review-feature`) route by name in a body-level `## Worker Routing` section, not via frontmatter.
2. Skill structural verification precedent is two-fold: (a) Python pytest "text-fragment contract tests" under `tests/scripts/dev_tools/` that read SKILL.md text and assert literal fragments and file existence (self-described as "the repository's text-fragment contract-test convention"), and (b) a PowerShell Pester structure suite at `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` that asserts skill existence and forbidden frontmatter patterns. The pytest convention is the more recent and more expressive precedent and is the recommended mechanism.
3. An always-on pytest parity gate requires every file under `.claude/**` to exist byte-identically in `extensions/drm-copilot/resources/claude-customizations/` (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:100-125`). Adding new `.claude/skills/discovery-*/SKILL.md` files without the mechanical bundle copy will fail the repository test suite on this branch, even though broader `resources/` publishing (pack manifests, Codex converter, `.github` mirror) is owned by #9012. This is the single largest planning risk identified.
4. A `discovery-*` prefix produces zero collisions with the 40 existing `.claude/skills/` directories and zero collisions with the `code-modernization` plugin's `/modernize-*` commands and seven agent names. A seven-skill decomposition is recommended (one umbrella sequencing skill, one analyzer-driving skill, four agent-stage skills, one validation-gate skill).
5. Reference isolation is achievable with plain documented strings (agent slugs, Poetry console-script names, schema-relative paths) concentrated in a single canonical "Referenced Contracts" registry inside the umbrella skill, consistent with the `skill-canonical-location-audit` rule that a canonical definition lives in exactly one skill. Structural tests must assert only on the new skills' own text, never on the existence of #9006/#9007 artifacts.
6. Deliverables are Markdown plus one Python contract-test file. The Python toolchain (Black -> Ruff -> Pyright -> Pytest) applies to the test file; no production Python code is added, so coverage denominators are unaffected.

## Q1. SKILL.md Conventions (Evidence-Based Frontmatter Contract)

### Required vs optional keys

The authoritative in-repo specification is `.claude/skills/make-skill-template/SKILL.md`:

- Lines 45-54 define the field table: `name` (required; 1-64 chars, lowercase letters/numbers/hyphens, must match folder name), `description` (required; 1-1024 chars, must state WHAT and WHEN), and optional `license`, `compatibility`, `metadata`, `allowed-tools`.
- Lines 126-134 ("Validation Checklist") add: folder name lowercase-hyphenated, `name` matches folder exactly, `description` wrapped in single quotes, body content under 500 lines.
- Lines 76-88 define recommended body sections: `# Title`, `## When to Use This Skill`, `## Prerequisites`, `## Step-by-Step Workflows`, `## Troubleshooting`, `## References`.

### Keys observed in practice (frontmatter scan of all 40 skills)

| Key | Usage count | Examples (file:line) |
|---|---|---|
| `name` | 40/40 | every SKILL.md line 2 |
| `description` | 40/40 | every SKILL.md line 3; both quoted and unquoted forms occur (`.claude/skills/skill-canonical-location-audit/SKILL.md:3` quoted; `.claude/skills/review-feature/SKILL.md:3` unquoted) |
| `allowed-tools` | 6/40 | `.claude/skills/research-issue/SKILL.md:4-8` (YAML list: Read, Grep, Glob, WebFetch); also `show-my-agent-tree`, `identify-session-id`, `commit-message`, `execute-hard-lock`, `pr-author` (each line 4) |
| `argument-hint` | 4/40 | `.claude/skills/orchestrate/SKILL.md:4`, `.claude/skills/epic-plan/SKILL.md:4`, `.claude/skills/epic-run/SKILL.md:4`, `.claude/skills/epic-orchestrate/SKILL.md:4` |
| `context` | 3/40 | only value observed is `fork`: `.claude/skills/epic-run/SKILL.md:5`, `.claude/skills/epic-plan/SKILL.md:5`, `.claude/skills/epic-orchestrate/SKILL.md:5` |
| `agent` | 3/40 | always paired with `context: fork`; values name an existing `.claude/agents/<name>.md` file: `epic-orchestrator` (`epic-run/SKILL.md:6`, `epic-orchestrate/SKILL.md:6`), `epic-planner` (`epic-plan/SKILL.md:6`) |

No skill uses `model`, `user-invocable`, `version`, or other keys.

### Routing conventions

- `context: fork` + `agent:` is reserved for skills whose entire purpose is to fork a named agent with `$ARGUMENTS` (see `.claude/skills/epic-run/SKILL.md:1-16`).
- The `orchestrate` skill is affirmatively *forbidden* from using `context: fork` / `agent: orchestrator` by a Pester test (`tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1:8-14`).
- Wrapper skills that delegate to a worker agent use frontmatter with `name` + `description` only and route in the body: `.claude/skills/review-feature/SKILL.md:23-25` (`## Worker Routing` / `- Worker: \`feature-review\``). Body sections there are `## Inputs`, `## Output Paths`, `## Worker Routing`.
- Contract/convention skills (for example `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:1-4`, `.claude/skills/atomic-plan-contract/SKILL.md:2-3`) also use `name` + `description` only.

### Implication for this feature

The issue's AC phrase "YAML frontmatter with `allowed-tools`, `context`, and `agent` routing" (`docs/features/active/2026-07-17-legacy-discovery-skills-367/issue.md:51-53`) must be read against this evidence: `context`/`agent` are optional keys used only by fork-routing skills. The spec should restate the AC as "each skill carries valid frontmatter per the repository contract (`name`, `description` required; `allowed-tools` where tool scoping applies; `context`/`agent` only where fork routing is intended)".

## Q2. Skill Structural-Check Precedent

Two verified mechanisms exist:

### (a) Python pytest text-fragment contract tests (primary, most recent precedent)

- `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py:1-13` explicitly names the mechanism: guarantees "expressed as runtime procedure text in the Claude skill/agent Markdown" are verified by "the repository's text-fragment contract-test convention (see `test_orchestration_guardrail_contracts.py`)".
- Mechanics: module-level `REPO_ROOT = Path(__file__).resolve().parents[3]` (line 19), a `read_repo_text(relative_path)` helper (lines 28-38), tuples of literal `required_fragments`, and `assert fragment in skill_text` with a diagnostic message (lines 54-65).
- The same file also asserts byte-identical mirroring into the bundled payload (`test_discovery_fix_is_mirrored_into_bundled_payload`, lines 107-120), demonstrating that a change touching `.claude/` skills is expected to update `extensions/drm-copilot/resources/claude-customizations/` in the same change.
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py:183-242` applies the same pattern to `.claude/skills/feature-promotion-lifecycle/SKILL.md`.

### (b) PowerShell Pester runtime-structure tests

- `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` asserts: existence of specific `SKILL.md` files (`Test-Path ... | Should -BeTrue`, lines 16-29), forbidden frontmatter patterns via `Get-Content -Raw` + `Should -Not -Match` (lines 8-14), and required content fragments in agent files (lines 31-55).

### (c) Always-on `.claude` bundle parity gate (affects any new skill)

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:100-125` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) enumerates every file under the repo's `.claude/**` (excluding `settings.local.json` and `agent-memory/**`) and requires each to exist byte-identically under `extensions/drm-copilot/resources/claude-customizations/`. The bundle currently mirrors all 40 skills (verified by directory listing of `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`).
- The Codex-side inventory test (`tests/scripts/dev_tools/test_codex_full_migration_inventory.py:11-15`) is skipped when the gitignored `.codex`/`.agents` trees are absent, so it does not constrain this feature; it enumerates `.agents/skills`, not `.claude/skills`.
- There is no global tree-parity test between `.claude/skills` and `.github/skills`; only specific-file contract tests reference `.github/skills/...` paths (for example `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py:64,81`).

### What "structural skill checks per repo precedent" means for the plan

A new pytest module under `tests/scripts/dev_tools/` (recommended name: `test_legacy_discovery_skills_contracts.py`) that, for each new skill:

1. asserts the `SKILL.md` file exists at `.claude/skills/<name>/SKILL.md`;
2. asserts frontmatter well-formedness by literal fragments (`name: <name>` present and matching the folder; a non-empty `description:` line);
3. asserts required body fragments (referenced agent slugs, `dev.discovery.*` command names, schema paths — see Q5);
4. asserts the banned domain substrings are absent from each new skill's text (see Q6);
5. asserts non-collision with the `code-modernization` name set (a frozen set literal in the test);
6. asserts byte-identical presence in the bundled payload, following `test_epic_run_kickoff_discovery_contract.py:107-120`.

## Q3. Naming-Collision Analysis

### Collision surfaces

- Existing `.claude/skills/` directories (40, enumerated by glob): `acceptance-criteria-tracking`, `atomic-plan-contract`, `commit-message`, `csharp-change-budget-router`, `csharp-orchestration-state-machine`, `csharp-qa-gate`, `epic-orchestrate`, `epic-plan`, `epic-run`, `evidence-and-timestamp-conventions`, `execute-hard-lock`, `feature-promotion-lifecycle`, `feature-review-workflow`, `fill-feature-docs`, `human-exception-runbook`, `identify-session-id`, `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer`, `make-skill-template`, `orchestrate`, `policy-audit-template-usage`, `policy-compliance-order`, `powershell-change-budget-router`, `powershell-orchestration-state-machine`, `powershell-qa-gate`, `pr-author`, `pr-base-branch-merge-base`, `pr-context-artifacts`, `python-change-budget-router`, `python-qa-gate`, `remediation-handoff-atomic-planner`, `research-issue`, `review-epic`, `review-feature`, `review-staged`, `show-my-agent-tree`, `skill-canonical-location-audit`, `translate-copilot-to-claude`, `update-status`.
- `code-modernization` plugin commands: `modernize-assess`, `modernize-brief`, `modernize-extract-rules`, `modernize-harden`, `modernize-map`, `modernize-preflight`, `modernize-reimagine`, `modernize-status`, `modernize-transform`, `modernize-uplift`.
- `code-modernization` plugin agents: `legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`, `security-auditor`, `test-engineer`, `version-delta-analyst`.

### Verification

- No existing skill directory begins with `discovery` or `modernize` (glob evidence above; grep for `discovery` under `.claude/` matches only incidental prose in `make-skill-template` and `evidence-and-timestamp-conventions`).
- None of the proposed names below equals any plugin command or agent name. The nearest string is plugin agent `legacy-analyst` vs the #9007 persona slug `legacy-parity-analyst`; these are distinct exact names, and this feature deliberately avoids a `legacy-*` skill prefix to keep the distance larger.

### Recommendation

Adopt the prefix `discovery-` for every skill in this feature. It maps directly to the epic's `dev.discovery.*` CLI namespace and to `schemas/discovery/v1/`, is visibly disjoint from `modernize-*`, and satisfies the name constraints in `make-skill-template/SKILL.md:49` (lowercase/hyphens, <= 64 chars).

## Q4. Skill Decomposition (Recommended Set)

Workflow stages derived from `objective-source.md:51-63` (roles and skills scope), `:91-99` (analyzers), and the prepared #9001/#9002/#9003 contracts:

| # | Skill name | Purpose | Analyzer CLI referenced | Agent role referenced (by slug, from #9007) | Schemas produced/consumed (`schemas/discovery/v1/`) | Validators referenced | Frontmatter |
|---|---|---|---|---|---|---|---|
| 1 | `discovery-workflow` | Umbrella sequencing skill: end-to-end stage order (profile -> inventory -> coverage -> runtime -> parity -> reconciliation -> validation gate); canonical "Referenced Contracts" registry (all agent slugs, CLI names, schema paths, artifact conventions) | `dev.discovery.profile` (profile load/echo) | all four (routing table only) | all seven (registry only) | `dev.discovery.validate-all` | `name`, `description` |
| 2 | `discovery-repo-inventory` | Drive the language-neutral repository/project inventory analyzer against `legacy_source.root` and `target.root` from the domain profile; record outputs under the profile's `artifacts.root` | `dev.discovery.profile`, inventory analyzer command from #9006 (assumed `dev.discovery.inventory`; see Q5 and Open Risks) | none (mechanics-only) | consumes `discovery-profile.yaml`; produces analyzer inventory artifacts + `evidence-reference` instances | `dev.discovery.validate-profile`, `dev.discovery.validate-evidence-reference` | `name`, `description`, `allowed-tools` (Bash/Read/Write for CLI driving) |
| 3 | `discovery-coverage-ledger` | Produce feature contracts and the coverage ledger from inventory output; route review to the coverage role | none (consumes inventory output) | `migration-coverage-reviewer` | `feature-contract`, `coverage-ledger` | `dev.discovery.validate-feature-contract`, `dev.discovery.validate-coverage-ledger` | `name`, `description` |
| 4 | `discovery-runtime-characterization` | Produce runtime characterization scenarios and their evidence references; route analysis to the runtime role | none | `runtime-characterization-analyst` | `runtime-characterization-scenario`, `evidence-reference` | `dev.discovery.validate-runtime-scenario`, `dev.discovery.validate-evidence-reference` | `name`, `description` |
| 5 | `discovery-parity-matrix` | Produce/refresh the parity matrix from feature contracts + characterization evidence; route parity reasoning to the parity role | none | `legacy-parity-analyst` | `parity-matrix` (consumes `feature-contract`, `runtime-characterization-scenario`) | `dev.discovery.validate-parity-matrix` | `name`, `description` |
| 6 | `discovery-behavior-reconciliation` | Capture unspecified/contradictory behavior and reconcile into product decisions; route to the reconciler role | none | `requirements-reconciler` | `unspecified-behavior-record`, `product-decision-record` | `dev.discovery.validate-unspecified-behavior`, `dev.discovery.validate-product-decision` | `name`, `description` |
| 7 | `discovery-validate-artifacts` | Canonical validation-gate mechanics: run per-artifact validators after each stage and `dev.discovery.validate-all` as the completion gate; defines pass/fail semantics (`list[str]` of errors, empty = pass) | none | none | all seven (validation targets) | all nine `dev.discovery.validate-*` console scripts | `name`, `description`, `allowed-tools` (Bash/Read for CLI driving) |

Design notes:

- Agent routing follows the `review-feature` wrapper precedent (`## Worker Routing` body section naming the agent slug), not `context: fork`/`agent:` frontmatter. Rationale: (a) the #9007 agents are not merged in this worktree (`.claude/agents/` contains 18 files, none of the four discovery personas), so fork-frontmatter would create a runtime hard dependency; (b) 37 of 40 existing skills route without fork frontmatter; (c) plain-text routing keeps #9012 mirroring mechanical.
- Every skill reads domain specificity (`legacy_source.root`, `target.root`, `technology_stack`, `artifacts.root`, `artifacts.conventions`) exclusively from `discovery-profile.yaml` via `dev.discovery.profile` (#9001). No skill names a concrete repository, path, or technology.
- Stack-specific analyzers (#9014) are NOT named. `discovery-repo-inventory` instructs: "after the language-neutral inventory, run any stack-specific analyzer commands applicable to the profile's `technology_stack`, as documented by the analyzer framework." This preserves domain neutrality (the banned-substring set includes `VSTO`) and matches this feature's dependency set (#9006, #9007 only — `epic.md:40-42`).
- The canonical-location rule (`.claude/skills/skill-canonical-location-audit/SKILL.md:17-36`) requires each canonical definition (registry of upstream names, validation-gate semantics) to live in exactly one skill: the registry lives in `discovery-workflow`; validation-gate mechanics live in `discovery-validate-artifacts`; other skills reference those skills by name (an indirect reference is explicitly not a duplication, per lines 44-47 of that skill).

## Q5. Reference-Isolation Strategy (#9006 / #9007 not merged)

1. **Reference by documented string name only.** Skills mention agent slugs (`legacy-parity-analyst`, `runtime-characterization-analyst`, `requirements-reconciler`, `migration-coverage-reviewer`), Poetry console-script names (`dev.discovery.profile`, `dev.discovery.validate-*`, the #9006 inventory command), and schema-relative paths (`schemas/discovery/v1/<artifact>.schema.json`) as plain text. No skill imports code, embeds file paths to `.claude/agents/*.md`, or asserts the existence of upstream files.
2. **Single registry, single edit point.** The `## Referenced Contracts` section of `discovery-workflow/SKILL.md` is the only place that enumerates the full upstream name set with its source feature (#9001/#9002/#9003/#9006/#9007). Stage skills name only the specific contract(s) they use and point to `discovery-workflow` for the full registry. If an upstream lands with a different final name, exactly one registry line plus the affected stage skill's fragment change.
3. **Structural tests assert only on this feature's files.** The contract test reads `.claude/skills/discovery-*/SKILL.md` text and asserts fragments within it (the pattern of `test_epic_run_kickoff_discovery_contract.py:50-65`). It must NOT assert `Path(".claude/agents/legacy-parity-analyst.md").exists()` or grep `pyproject.toml` for `dev.discovery.*` entries — those files belong to #9007/#9006 and are absent in this worktree. This makes the checks green independent of upstream merge order.
4. **Assumed-name markers.** Where a #9006 name is not fixed by the prepared summaries (only the inventory analyzer command is unfixed; the #9001/#9003 command names are fixed by their prepared specs), the skill text should carry the name once, in the registry, so the fan-in reconciliation on the epic integration branch is a one-line edit. Record the assumption explicitly in spec.md.
5. **Mechanical mirroring for #9012.** Skills are self-contained single `SKILL.md` files (no `scripts/`, `references/`, or `assets/` subfolders needed for these workflow-mechanics skills), so #9012's mirroring is a verbatim file copy plus manifest registration. Avoid anything that would make the mirrored copy diverge (no absolute paths, no worktree-specific text, no generated timestamps in skill bodies).

## Q6. Constraints to Carry into Spec/Plan

### Domain-neutrality banned-substring set

From `objective-source.md:28-30,131-133` and `epic.md:93-94`: `TaskMaster`, `TMW`, `Outlook`, `VSTO`, `email`, `task-management` (recommend case-insensitive matching and also scanning for the unhyphenated `task management`). Scope: the new `.claude/skills/discovery-*/**` files and their bundle mirrors only. Consequence already applied in Q4: skills must not name the .NET/VSTO analyzers literally; stack-specific analyzers are referenced generically via the profile's `technology_stack`.

### File-size cap

`.claude/rules/general-code-change.md` caps production/test/script files at 500 lines with an explicit exception for Markdown documentation; independently, `make-skill-template/SKILL.md:133` requires skill body content under 500 lines. Adopt the stricter reading: every new `SKILL.md` stays under 500 lines. The pytest contract file is test code and is bound by the 500-line cap without exception.

### Evidence locations

All evidence for this feature goes under `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:10-35` (canonical kinds: `baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/`, `other/`, `remediation-baseline/`). `artifacts/` sub-paths other than `artifacts/orchestration/` are forbidden and hook-enforced (`.claude/hooks/enforce-evidence-locations.ps1` exists in this worktree).

### Test file location and toolchain

- Test location policy (`.claude/rules/general-unit-test.md`, "Test File Location"): tests mirror the production tree under `tests/`. For skill contract tests the established location is `tests/scripts/dev_tools/` (pytest precedent: `test_epic_run_kickoff_discovery_contract.py`, `test_orchestration_guardrail_contracts.py`); the Pester alternative lives at `tests/scripts/claude-runtime/`. Recommended: one new pytest module `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`.
- Toolchain: the skills themselves are Markdown (format via the repo Markdown conventions; no lint/type/test stages apply to them directly). The pytest module is Python and runs the Black -> Ruff -> Pyright -> Pytest loop per `.claude/rules/python.md` and the seven-stage loop in `.claude/rules/general-code-change.md`. It adds no production Python code, so line/branch coverage denominators are unchanged.

### Bundle parity obligation (planning decision required)

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:100-125` requires every repo `.claude/**` file byte-identically in `extensions/drm-copilot/resources/claude-customizations/`. The issue states `resources/` mirroring is owned by #9012 (`issue.md:75-77`), but this specific parity test is always-on and will fail this feature's branch if the seven new skills are not byte-copied into `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/SKILL.md` in the same change. Recommended resolution (matching the precedent in `test_epic_run_kickoff_discovery_contract.py:107-120`, which pinned skill + bundle together): include the mechanical byte-copy into the bundled payload within this feature, and leave pack-manifest selection, Codex converter registration, and `.github`/`.agents` mirroring to #9012. This should be recorded in spec.md as an explicit scope clarification.

## Recommended Approach

Author seven domain-neutral `discovery-*` skills (table in Q4), each a single `SKILL.md` under `.claude/skills/<name>/`, using `name` + `description` frontmatter (plus `allowed-tools` on the two CLI-driving skills), body-level `## Worker Routing` for agent-role references, a single `## Referenced Contracts` registry in `discovery-workflow`, byte-copies into the bundled payload, and one pytest text-fragment contract module in `tests/scripts/dev_tools/` covering existence, frontmatter well-formedness, required reference fragments, banned-substring absence, plugin-name non-collision, and bundle parity.

**Rejected alternatives (brief):**

- *Single monolithic `discovery-workflow` skill.* Rejected: would approach or exceed the 500-line body cap, concentrate all upstream references in one file without stage-level reuse, and violate the repo pattern of small purpose-scoped skills.
- *Per-artifact skills (7+ artifact skills plus stages).* Rejected: over-granular; artifact production is naturally paired per agent stage (for example unspecified-behavior + product-decision both belong to reconciliation), and more skills increase the mirroring and registry surface without adding sequencing value.
- *`context: fork` + `agent:` frontmatter routing to the #9007 personas.* Rejected: creates a runtime dependency on unmerged agents, contradicts the dominant wrapper precedent (`review-feature`), and the only fork-routing precedents are the three epic-* skills whose sole function is forking.
- *Pester-based structural tests.* Rejected in favor of pytest: the pytest text-fragment convention is the newest precedent, is explicitly self-described as the applicable verification surface for skill/agent Markdown guarantees, and supports the bundle-parity assertion pattern directly.

## Open Risks / Assumptions

1. **#9006 inventory CLI command name is assumed.** The prepared summaries fix `dev.discovery.profile` (#9001) and the nine `dev.discovery.validate-*` scripts (#9003), but not the inventory analyzer's command name. This research assumes `dev.discovery.inventory`; the registry in `discovery-workflow` isolates the assumption to one line plus the fragment in `discovery-repo-inventory`. Must be reconciled at epic fan-in.
2. **#9007 agent slugs are assumed** as the kebab-case of the persona titles (`legacy-parity-analyst`, `runtime-characterization-analyst`, `requirements-reconciler`, `migration-coverage-reviewer`). None collides with the `code-modernization` agent names, but the final slugs are #9007's decision; same one-registry isolation applies.
3. **Bundle-parity scope tension.** The issue text places `resources/` mirroring out of scope (#9012), while the always-on pytest parity gate requires the `extensions/.../claude-customizations` byte-copy in this feature (Q6). The spec must record the recommended resolution explicitly to avoid a feature-review Blocking finding either way.
4. **Feature-contract authorship stage.** The objective does not state which role authors feature contracts. This research assigns production to the coverage stage (`discovery-coverage-ledger`, reviewed by `migration-coverage-reviewer`) because feature contracts and the coverage ledger are jointly derived from the inventory; the parity stage consumes them. If #9007's persona definitions assign contract authorship differently, only the stage-skill body text changes.
5. **`issue.md:28-29` names #9014 as a driven analyzer source**, but the epic DAG (`epic.md:40-42`) gives this feature dependencies on #9006 and #9007 only, and the delegation scope confirms #9014 is out of scope. Resolved here by generic stack-analyzer wording (Q4/Q6); spec.md should restate this to supersede the issue wording.
6. **`description` quoting is inconsistent in-repo** (quoted and unquoted forms both exist). The template checklist (`make-skill-template/SKILL.md:130`) requires single quotes; adopt single quotes for the new skills and do not attempt to normalize existing skills (out of scope).
