# 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix — Spec

- **Issue:** #1025
- **Parent (optional):** epic #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 1
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T21-40
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Primary research input:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/research/research.2026-10-30T21-08.md`
- **Epic manifest:** `docs/features/epics/shared-agent-harness-layer/epic.md`
- **Confirmed design (not re-opened):** `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`

In this document `<FEATURE>` means `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`. All paths are repository-relative POSIX paths.

## Overview

Epic #1018 restructures the three agent ecosystems in this repository (Claude Code, Codex and GitHub Copilot) onto shared cross-tool conventions. Before any generator, push-down or retirement work can start, the epic needs three settled inputs that do not exist today:

- A content-level comparison of every skill name across `.claude/skills`, `.agents/skills` and `.github/skills`. The existing heading comparison overstates differences because the same topic appears under different headings, and because some content lives in a different artifact of the same ecosystem (for example an agent body instead of a skill).
- A tool-neutral gold-standard contract for each shared skill, against which each ecosystem's expression can be judged.
- A machine-readable parity matrix that gives every native feature of every ecosystem a disposition, so later children can prove that no native capability is lost.

Several behaviors that the design depends on are also unverified. One (Claude Code hooks, subagent and permissions details, E5) is resolved by documentation; the others (E1-E4, E6) need VS Code, the Copilot CLI, the Copilot cloud agent or Codex and are delivered as owner-run runbooks.

Children 3 to 6 of epic #1018 consume the parity-matrix location and schema, the contract format, the survey records and the approval artifact. The section `## Interface Contracts` states them as interface contracts; later children may rely on them without reading this child's implementation.

### Inventory context (informational, not an acceptance threshold)

The research record (section 1.1 and `## Numeric Derivation Evidence`) reports 66 skill folders in `.claude/skills`, 79 in `.agents/skills`, 33 in `.github/skills`, 90 distinct names, and 55 names present in both `.claude/skills` and `.agents/skills`. The 90-name union and the 55-name shared set are confirmed by the caller for planning.

Discrepancy: the promoted epic record states 83 skill directories under `.agents/skills` and 34 skills under `.github/skills`. The tree holds 79 and 33 skill folders. The difference may come from counting the root `README.md` files or from a different snapshot. The epic record's figure of 16 materially different skills is not recorded anywhere in the repository and is not used.

Because the cross-check member sets in the research record are stated by reference ("identical folder names") rather than enumerated independently, this spec does not use any of these counts as an acceptance threshold. Acceptance criteria are stated against the set produced by enumerating the trees at execution time, which is the set the survey and the completeness test both derive.

## Behavior

1. **Phase 0 gate.** Execution confirms that the parallel run `bugs-1001-1002-1003-1006` has merged to `main`, and re-checks this child's edit set (section `## Implementation Strategy`) and the excluded paths (section `## Constraints & Risks`) against the merge base of `origin/main` and `HEAD`. If a named file, symbol or heading has moved, execution stops for re-planning.
2. **Survey.** Every skill folder name in the union of the three trees is recorded in a survey index. An identity pass classifies each name present in more than one tree as `byte-identical`, `wording-only` or `substantive`. A content pass, batched by skill family, records the differences for each `wording-only` or `substantive` name. A section missing from one copy is searched for across that ecosystem's other surfaces (agent bodies, rules, sibling skills) before it is recorded as missing. Single-ecosystem names receive a disposition proposal (`shared` or `native`) instead of a difference table.
3. **Classification and approval.** Every recorded difference is classified against the skill's objective as `positive`, `negative`, `neutral` or `mechanism-only`, with a port direction. An approval artifact lists the bulk set, the disposition proposals and the disputed cases separately. The owner approves in bulk; only disputed cases are decided individually.
4. **Contracts.** Each skill whose matrix entry `codex:skill:<name>` has disposition `shared` receives `.agents/skills/<name>/references/standard.md` in the format in `### Contract Format`, plus a byte-identical bundle copy. No `SKILL.md` links to the contract in this child.
5. **Parity matrix.** `config/harness-parity-matrix.json`, governed by `config/harness-parity-matrix.schema.json`, assigns every inventoried native feature of every ecosystem exactly one entry and one disposition.
6. **Completeness test.** PowerShell modules under `scripts/harness/` and Pester tests under `tests/scripts/harness/` enforce the matrix and contract rules. The repository gate runs in the required `poshqc / PowerShell QC` check.
7. **Experiments.** E5 is recorded as resolved by documentation. E1-E4 and E6 are owner-run runbooks with recorded-result artifacts.
8. **Single owner stop.** Execution stops once for owner input: the bulk approval, the disputed cases, the owner questions in `## Open Owner Questions`, and the runbook results. After the owner responds, execution finalizes dispositions, contracts and the matrix.

## Interface Contracts

These contracts are consumed by children 3 to 6. Changing any of them after this child merges requires a `schema_version` bump (matrix) or an explicit note in the consuming child's spec (contract, survey, approval artifact).

### Parity Matrix: Location and Format

| Item | Value |
| --- | --- |
| Data path | `config/harness-parity-matrix.json` |
| Schema path | `config/harness-parity-matrix.schema.json` |
| Schema dialect | JSON Schema Draft 2020-12 (`"$schema": "https://json-schema.org/draft/2020-12/schema"` in the schema file) |
| Schema `$id` | `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json` |
| Encoding | UTF-8 without BOM, LF line endings, two-space indentation |
| Location rule | Both files are outside `docs/`, so child 7's move of development documents to `.dev` and the feature folder's move to `completed/` do not move them. Neither file is bundled under `extensions/drm-copilot/resources/**` and neither is listed in a pack manifest. |
| Ordering | `features` is sorted by `id` (ordinal, case-sensitive). The completeness test enforces the order so that generator diffs in later children are stable. |

### Parity Matrix: Top-Level Object

`additionalProperties: false`.

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `$schema` | string | yes | const `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json` |
| `schema_version` | string | yes | pattern `^\d+\.\d+\.\d+$`; initial value `1.0.0` |
| `features` | array of feature entry | yes | `minItems: 1` |

### Parity Matrix: Feature Entry

`additionalProperties: false`. Optional fields are omitted rather than set to `null`, except `owner_child`, which is always present and may be `null`.

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `id` | string | yes | `<ecosystem>:<kind>:<name>`; pattern `^(claude\|codex\|copilot\|cross-tool):[a-z-]+:[A-Za-z0-9._@/#:+-]+$`; the `<ecosystem>` and `<kind>` segments equal the entry's `ecosystem` and `kind`; unique across `features` (enforced by the completeness test, because JSON Schema cannot express uniqueness by property) |
| `ecosystem` | enum | yes | `claude`, `codex`, `copilot`, `cross-tool`. The ecosystem that owns the feature's current location. `cross-tool` is used only for `AGENTS.md`. Everything under `.agents/**` is `codex`. |
| `kind` | enum | yes | see `### Parity Matrix: Feature Kinds and Inventory Rules` |
| `name` | string | yes | `minLength: 1`; the bare feature name (skill folder name, agent file stem, `<Event>/<matcher>/<command-stem>` for a hook registration, key or table name for settings, permissions and MCP servers, frontmatter key for field kinds) |
| `source_path` | string | yes | repository-relative POSIX path of the defining file; no leading `/`, no drive letter, no `..` segment |
| `source_pointer` | string | no | location inside the file: a JSON pointer (for example `/permissions/deny`), a TOML table header (for example `[mcp_servers.drm-copilot]`) or a frontmatter key |
| `disposition` | enum | yes | `shared`, `native`, `generated`, `dropped` (see `### Disposition Semantics`) |
| `reason` | string | when `disposition` is `dropped` | `minLength: 1`; optional for other dispositions |
| `target_paths` | array of string | when `disposition` is `shared` or `generated` | `minItems: 1`, `uniqueItems: true`, each item a repository-relative POSIX path; must be absent when `disposition` is `dropped` |
| `generated_from` | string | when `disposition` is `generated` | repository-relative POSIX path of the single source |
| `generator` | string | no | generator identifier; filled by child 3 |
| `parity_group` | string | yes | `minLength: 1`; logical function key shared by equivalent features across ecosystems, of the form `<kind-family>:<function>` (for example `skill:orchestrate`, `hook:validate-bash`, `mcp:drm-copilot`) |
| `consumers` | array of enum | yes | items from `claude-code`, `codex`, `copilot-vscode`, `copilot-cli`, `copilot-cloud`; `uniqueItems: true`; may be empty. Lists the tools that load the feature with default settings. Values that depend on a pending experiment are set provisionally and the entry's `decision_status` is `provisional`. |
| `owner_child` | integer or null | yes | integer `3` to `7` inclusive (the epic child that realizes the disposition), or `null` when no change is needed |
| `decision_status` | enum | yes | `approved`, `provisional` |
| `decision_ref` | string | when `decision_status` is `provisional` or `disposition` is `dropped` | pattern `^#\d+:[^\s]+$`, see `### Decision Reference Format` |
| `notes` | string | no | free text |

Conditional rules, expressed in the schema with `if`/`then` under `allOf`:

- `disposition == "dropped"` requires `reason` and `decision_ref`, and forbids `target_paths`.
- `disposition` in (`shared`, `generated`) requires `target_paths` with at least one item.
- `disposition == "generated"` requires `generated_from`.
- `decision_status == "provisional"` requires `decision_ref`.

### Disposition Semantics

| Value | Meaning |
| --- | --- |
| `shared` | The feature's location is the single source used by more than one ecosystem; `target_paths` lists the native locations it is mirrored to. |
| `native` | The feature stays in its ecosystem's native location and is not mirrored; parity of function, where relevant, is tracked through `parity_group`. |
| `generated` | The feature's file is produced from `generated_from` by a generator; `target_paths` lists the files that generator writes. |
| `dropped` | The feature is retired. `reason` states why; `decision_ref` points to the owner decision. |

### Decision Reference Format

`decision_ref` is `#<issue>:<path-inside-feature-folder>[#<anchor>]`, for example `#1025:survey/difference-approval.md#owner-overrides` or `#1025:evidence/other/e3-copilot-cli-cloud-claude-agents-result.2026-11-04T10-15.md`. The reference is keyed by issue number and is relative to that issue's feature folder, so it stays valid when the feature folder moves to `completed/` and when child 7 moves development documents to `.dev`. The completeness test checks the pattern and non-emptiness only; it does not resolve the reference against the file system. (This format refines the research recommendation, which proposed a plain path; see Q8.)

### Parity Matrix: Feature Kinds and Inventory Rules

`kind` enum and the deterministic inventory rule for each value. The completeness test enumerates features from these rules (subject to the exclusion list) and compares them with the matrix.

| `kind` | Ecosystems | Inventory rule (one entry per) |
| --- | --- | --- |
| `instructions` | `cross-tool`, `claude`, `copilot` | file: `AGENTS.md` (`cross-tool`), `CLAUDE.md` (`claude`), `.github/copilot-instructions.md` (`copilot`) |
| `path-scoped-rule` | `claude`, `copilot` | file matching `.claude/rules/*.md` or `.github/instructions/*.instructions.md` |
| `skill` | `claude`, `codex`, `copilot` | folder that contains `SKILL.md` directly under `.claude/skills/`, `.agents/skills/` or `.github/skills/` |
| `skill-frontmatter-field` | `claude`, `codex`, `copilot` | distinct frontmatter key used by at least one `SKILL.md` in that ecosystem's skills tree (one entry per tree and key) |
| `skill-metadata-file` | `codex` | file matching `.agents/skills/<name>/agents/openai.yaml` |
| `agent` | `claude`, `codex`, `copilot` | file matching `.claude/agents/*.md`, `.codex/agents/*.toml` (base and generated variants), or `.github/agents/*.agent.md` |
| `subagent-frontmatter-field` | `claude`, `codex`, `copilot` | distinct frontmatter key across `.claude/agents/*.md`; distinct frontmatter key across `.github/agents/*.agent.md`; distinct top-level key across `.codex/agents/*.toml` (one entry per tree and key) |
| `handoff` | `copilot` | `.github/agents/*.agent.md` file whose frontmatter declares `handoffs:` |
| `prompt` | `copilot`, `codex` | file matching `.github/prompts/**/*.prompt.md` (including `drafts/`) or `.codex/prompts/*.md` |
| `hook-registration` | `claude`, `codex`, `copilot` | (event, matcher, command) triple in `.claude/settings.json` `hooks`; `[[hooks.<Event>]]` entry in `.codex/config.toml`; registration in `.github/hooks/*.json`; `hooks:` entry in `.claude/agents/*.md` frontmatter |
| `permission` | `claude`, `codex` | sub-key of `.claude/settings.json` `permissions` (`allow`, `deny`, `ask`, `defaultMode`, `additionalDirectories`); `[permissions.<profile>]` table in `.codex/config.toml` |
| `setting` | `claude`, `codex` | other top-level key of `.claude/settings.json`; other top-level table or key of `.codex/config.toml` (for example `[features]`, `[agents]`) |
| `mcp-server` | `claude`, `codex` | server under `mcpServers` in `.mcp.json`; `[mcp_servers.<id>]` table in `.codex/config.toml` |

Parsing rule: the repository has no TOML or YAML parser available to PowerShell without a new dependency, so frontmatter keys and TOML table headers are read with anchored regular expressions. JSON files are read with `ConvertFrom-Json`.

**Exclusion list** (applied by the inventory module and covered by its own unit test):

- Gitignored or local-scope paths: `.claude/settings.local.json`, `.claude/agent-memory/**`, `.claude/state/**`, `.claude/worktrees/**`, `.codex/state/**`, `.vscode/settings.json`, `artifacts/**`.
- Implementation libraries and helper scripts that are not themselves registered features: `.claude/lib/**`, `.codex/scripts/**`, and hook scripts that no registration names. Their function is represented by the registrations that load them (working assumption under Q6).
- Bundle copies under `extensions/drm-copilot/resources/**`.
- README files: `.agents/README.md`, `.agents/skills/README.md`, `.github/skills/README.md`.
- Non-`SKILL.md` supporting files inside a skill folder (`references/**`, `scripts/**`, example files), except `agents/openai.yaml`, which is kind `skill-metadata-file`.

### Default Dispositions (starting values, owner-approved through the approval artifact)

| Feature | `disposition` | `owner_child` | Note |
| --- | --- | --- | --- |
| `codex:skill:<name>` for a name in both `.claude/skills` and `.agents/skills` | `shared` | 3 | `target_paths` includes `.claude/skills/<name>/SKILL.md` |
| `claude:skill:<name>` for the same names | `generated` | 3 | `generated_from` `.agents/skills/<name>/SKILL.md` |
| `copilot:skill:<name>` | `dropped` | 6 | reason: superseded by the shared `.agents/skills/<name>`, which Copilot reads natively |
| Claude-only and Codex-only skills | per approved proposal (`native` or `shared`) | 3 | Q3 |
| `cross-tool:instructions:AGENTS.md` | `shared` | 3 | |
| `claude:instructions:CLAUDE.md` | `native` | 3 | `@AGENTS.md` plus Claude-only text |
| `copilot:instructions:copilot-instructions.md` | `native` | 6 | Copilot-only text |
| `.claude/rules/*`, `.github/instructions/*` | `generated` | 3 | from one rule source |
| `claude:agent:*`, `codex:agent:*` (base) | `generated` | 3 | from one logical definition |
| `codex:agent:*` generated variants (`-c1` to `-c4`, `-c3-elevated`) | `generated` | `null` | existing `scripts/dev_tools/generate_codex_agent_variants.py` |
| `copilot:agent:*` | `provisional` status; `dropped` or `generated` per E3 | 6 | |
| `mcp-server` entries | `generated` | 3 | from one server list |
| `hook-registration`, `permission`, `subagent-frontmatter-field` | `native` | 5 | parity of function via `parity_group` |
| `prompt`, `handoff`, Copilot hook registrations | `native` | 6 | thin Copilot layer |

Until the owner approves, entries carry `decision_status: provisional` with `decision_ref` pointing to the approval artifact or the pending runbook result. The completeness test passes with provisional entries; child 6 may require `approved` later.

### Contract Format

| Item | Value |
| --- | --- |
| Path | `.agents/skills/<name>/references/standard.md`, where `<name>` is the skill folder name |
| Required set | every matrix entry with `kind == "skill"`, `ecosystem == "codex"` and `disposition == "shared"` (derived from the matrix, not hard-coded) |
| Bundle copy | byte-identical copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md` |
| Pack manifest | no entry in this child (deferred to child 4, Q1) |
| Linking | not linked from any `SKILL.md` in this child (Q2) |

Exact structure (no YAML frontmatter):

```markdown
# Gold Standard: <name>

## Objective

<One paragraph: the outcome the skill exists to produce, tool-neutral.>

## Observable Behaviors

- **OB-1** <a behavior an observer can see in outputs, files or tool calls, independent of the tool>
- **OB-2** ...

## Acceptance Checks

- **AC-1** (OB-1) <a verifiable statement that an ecosystem's expression satisfies OB-1>
- **AC-2** (OB-1, OB-2) ...
```

Rules:

1. The first line is exactly `# Gold Standard: <name>`, with `<name>` equal to the folder name. There is exactly one H1.
2. There are exactly three H2 headings, in this order: `## Objective`, `## Observable Behaviors`, `## Acceptance Checks`. No other H2 heading. H3 or deeper headings are not used.
3. Each section has non-whitespace content. `## Objective` is prose. `## Observable Behaviors` and `## Acceptance Checks` each contain at least one list item.
4. Item identifiers: each behavior item begins `- **OB-<n>** `; each check item begins `- **AC-<n>** (<refs>) `, where `<refs>` is a comma-and-space separated list of one or more `OB-<n>` identifiers. Within each section `<n>` starts at 1 and increases by 1 without gaps or repeats. Every cited `OB-<n>` exists in the same file. Every `OB-<n>` is cited by at least one check.
5. No checkbox syntax (`- [ ]` or `- [x]`) anywhere in the file, so acceptance-criteria tooling cannot mistake contract checks for feature acceptance criteria.
6. Tool names appear only to state that mechanism differs; the objective and behaviors are tool-neutral.
7. No consuming-product names; in particular the text `TaskMaster.sln` does not appear (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` scans every file under `.agents`).

### Survey Records

| Artifact | Path | Content |
| --- | --- | --- |
| Survey index | `<FEATURE>/survey/skill-survey.md` | one table row per skill name in the union of the three trees: `Skill`, `Claude`, `Codex`, `Copilot` (each `yes` or `no`), `Identity` (`byte-identical`, `wording-only`, `substantive`, or `single-ecosystem`), `Proposed disposition` (`shared` or `native`), `Batch` (`A` to `F`, or `single`), `Record` (relative link to the per-skill record) |
| Batch records | `<FEATURE>/survey/batch-<letter>-<family>.md`, letters `A` to `F` (families: discovery, foundation-and-policy, integration, language-routing-and-gates, orchestration, authoring-and-review-wrappers), plus `<FEATURE>/survey/single-ecosystem.md` for names present in one tree | per-skill records |
| Identity evidence | `<FEATURE>/evidence/baseline/skill-identity.<timestamp>.md` | for each name in more than one tree: the `git hash-object` value of each copy, the normalized-comparison result and the resulting identity class; the command used and its exit code |

Per-skill record shape (fixed, so a reviewer or a later check can grep it):

```markdown
### <skill-name>

- Presence: claude=`.claude/skills/<name>/SKILL.md` | codex=`.agents/skills/<name>/SKILL.md` | copilot=`.github/skills/<name>/SKILL.md` | absent
- Identity: byte-identical | wording-only | substantive | single-ecosystem
- Proposed disposition: shared | native
- Objective (draft): <one sentence; feeds references/standard.md>

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-<skill-name>-01 | copilot:.github/skills/<name>/SKILL.md#<heading> | ... | yes: `<path>#<heading>` / no | positive / negative / neutral / mechanism-only | <from>-><to> / none | ... |
```

- `byte-identical` records have no difference table. `single-ecosystem` records have no difference table and carry a one-line disposition rationale.
- Diff IDs are `D-<skill-name>-<nn>` with a two-digit, one-based, gap-free sequence per skill. They are stable once the approval artifact references them.
- Port direction is `none` or `<from>-><to>` where `<from>` and `<to>` are distinct values from `claude`, `codex`, `copilot`; multiple targets are written as separate rows.

### Difference Classification

| Class | Meaning | Port action (performed by child 3, Q4) |
| --- | --- | --- |
| `positive` | The variant that has it serves the objective better | Port to the other ecosystems in the recorded direction |
| `negative` | The variant that has it works against the objective, or is stale | Remove from that variant |
| `neutral` | Different wording or structure with equal effect | None; the shared body picks one |
| `mechanism-only` | Equal behavior expressed through a tool-specific mechanism or in a different artifact | None; record the mechanism per tool |

### Owner Approval Artifact

Path: `<FEATURE>/survey/difference-approval.md`. It is a decision record, not evidence, so it is outside `evidence/`.

```markdown
# Difference Classification Approval (Issue #1025)

- Approval-Status: pending
- Approved-By:
- Approved-At:

## Bulk Approval Set
| Diff ID | Skill | Class | Port direction | One-line rationale |

## Disposition Proposals
| Skill or feature id | Proposed disposition | Reason |

## Owner Questions
| Question | Recommended default | Owner answer |

## Owner Overrides
| Diff ID or feature id | Owner decision | Note |

## Disputed Cases
### D-<skill>-<nn>
- Context: ...
- Option A: ...
- Option B: ...
- Recommendation: ...
- Owner-Decision:
```

Field rules:

- `Approval-Status` enum: `pending`, `approved`, `approved-with-overrides`. The owner sets it.
- `Approved-By` is the owner's GitHub handle; `Approved-At` is UTC `yyyy-MM-ddTHH-mm`.
- `## Disposition Proposals` lists every single-ecosystem skill and every matrix entry proposed as `dropped`.
- `## Owner Questions` lists Q1 to Q8 from `## Open Owner Questions` with the recommended default; an empty owner answer at approval time means the default is accepted.
- `## Owner Overrides` is empty when the owner overrides nothing.
- A case is disputed, and goes to `## Disputed Cases` instead of the bulk set, when any of the following holds: the difference changes an enforcement behavior (a gate, a hook, an MCP-only rule, a stop condition); two copies each assert authority for conflicting rules (for example MCP-only versus fallback in `feature-promotion-lifecycle`); the classification depends on information the survey could not verify; or the proposal drops a native feature.
- `Owner-Decision` enum per disputed case: `A`, `B`, or `other: <text>`.

## Inputs / Outputs

- Inputs: the three skill trees; `.claude/agents`, `.codex/agents`, `.github/agents`; `.claude/rules`, `.github/instructions`; `.claude/settings.json`, `.codex/config.toml`, `.mcp.json`, `.github/hooks/*.json`; `.github/prompts`, `.codex/prompts`; `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`; vendor documentation cited in the research record; owner decisions and runbook results.
- Outputs:
  - `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json`
  - `.agents/skills/<name>/references/standard.md` and their bundle copies
  - `scripts/harness/*.psm1`, `tests/scripts/harness/*.Tests.ps1`
  - `<FEATURE>/survey/**`, `<FEATURE>/runbooks/**`, `<FEATURE>/evidence/**`
- Config keys and defaults: none added to existing configuration files.
- Versioning: the matrix carries `schema_version` `1.0.0`. A breaking schema change in a later child bumps the major version and updates the schema `$id` and the data `$schema` together.

## API / CLI Surface

No new CLI entry point is added. The PowerShell modules expose functions consumed by the Pester tests:

- `scripts/harness/HarnessInventory.psm1`: enumerates native features per the inventory rules. File listing and file reading are injected script-block parameters that default to the real file system, so unit tests use in-memory content.
- `scripts/harness/HarnessParityMatrix.psm1`: loads the matrix, performs structural validation of every schema rule, uniqueness, ordering, completeness and orphan checks, and returns a list of violations, each naming the offending `id`. It also exposes a skeleton function that emits draft entries for unmatched inventoried features; execution uses it once to bootstrap the matrix.
- `scripts/harness/HarnessSkillContract.psm1`: checks contract presence and structure for the required set.

Children 3 to 6 that work in TypeScript read the JSON directly and do not depend on these modules.

## Data & State

- Invariants enforced by the completeness test:
  1. Each inventoried feature has exactly one matrix entry, matched by `id`.
  2. Every entry has a `disposition` from the enum; an unknown value of any enum field (`ecosystem`, `kind`, `disposition`, `consumers` item, `decision_status`) fails.
  3. A `dropped` entry has a non-empty `reason` and a `decision_ref`.
  4. `id` values are unique, consistent with `ecosystem` and `kind`, and sorted.
  5. An entry whose feature is no longer inventoried (orphan) must be `dropped`; an orphan with any other disposition fails.
  6. The conditional rules of the schema hold (`target_paths`, `generated_from`, `decision_ref` when `provisional`).
  7. The matrix conforms to the schema: no unknown properties, required fields present, types and patterns respected.
  8. Every skill in the contract required set has a conforming `references/standard.md`.
- Persistence: the matrix and schema are committed files. No runtime state or cache is introduced.
- Migration or backfill: the matrix is bootstrapped once by the skeleton function and then edited by hand; later children update it through their own changes.

## Constraints & Risks

### Language directive (owner, verbatim)

> avoid Python scripts. Existing Python in the repo is tolerated and may be reused, extended in place or called (for example the existing Codex agent-variant generator and the Python ports of the push-down), but NEW scripts, tools, generators, checkers and CLI entry points must be written in TypeScript or PowerShell, to avoid adding environmental dependencies for destination repos.

Requirement: this child adds no new `.py` file. Existing Python tests (for example `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`) are run, not edited. Session-scoped helper scripts used during execution (for example the identity pass) are PowerShell, live in the session scratch location, and are not committed.

### Language choice for the completeness test: PowerShell and Pester

| Aspect | Detail |
| --- | --- |
| Choice | PowerShell modules under `scripts/harness/`, Pester tests under `tests/scripts/harness/` mirroring the production paths |
| CI | Runs in the required `poshqc / PowerShell QC` check, picked up through `config/poshqc-scan.json` (`scanFolders` includes `tests/scripts`); no workflow or configuration edit |
| Coverage | `scripts` is already a coverage root in `config/poshqc-coverage.json`; each new module needs at least 85% line coverage. Pester does not measure branch coverage, so no branch gate applies. |
| Destination dependency | PowerShell 7 is already required by the enforcement hooks; no new runtime is introduced |
| Alternatives rejected | Root TypeScript: not a required check and has no coverage gate without new configuration. Extension TypeScript: shipped product code, and `extensions/drm-copilot/jest.config.cjs` is excluded from this child's edit set. |
| Cost: batch budget | The direct-mode batch budget allows three new production files per worktree session; this child adds exactly three `.psm1` modules. A fourth production file, or a split for size, requires a second session; the plan accounts for this. |
| Risk: `Test-Json -SchemaFile` | Draft 2020-12 support in `Test-Json -SchemaFile` requires PowerShell 7.4 or later. Whether the `windows-latest` runner provides 7.4 is unconfirmed. Fallback (required design, not conditional): the module implements every schema rule as structural validation in code, and that validation is the gate. The repository gate test also reads the schema file as data and asserts that its enums, required fields and conditional rules agree with the module's constants, so the two cannot drift. A supplemental `Test-Json -SchemaFile` assertion may run only when `$PSVersionTable.PSVersion` is 7.4 or later and is marked skipped otherwise; no gate depends on it. |
| Risk: file size | The inventory module covers 13 kinds and may approach the 500-line guidance tier; it is split by kind family if it does, subject to the batch budget. |
| Risk: Windows only | The PowerShell QC shards run on Windows. Paths are built with `Join-Path` and compared in forward-slash relative form; the exclusion list prevents local-only gitignored files from changing the result between a developer machine and CI. |

### Execution precondition

Execution starts only after the parallel run `bugs-1001-1002-1003-1006` has merged to `main`. The Phase 0 gate re-checks this child's edit set and excluded paths against current `origin/main` and stops for re-planning on any moved file, symbol or heading.

### Excluded paths (must not be edited by this child)

- Any `SKILL.md` in any tree (`.claude/skills/**`, `.agents/skills/**`, `.github/skills/**`, and their bundle copies under `extensions/drm-copilot/resources/**`).
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- The policy-audit templates under `docs/features/templates/policy_audit/`.
- `config/poshqc-coverage.json`.
- `config/file-size-baseline.json`.
- The PSSA settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
- The extension Jest configuration `extensions/drm-copilot/jest.config.cjs`.
- `scripts/dev_tools/generate_codex_agent_variants.py` and every `tests/scripts/dev_tools/test_push_down_*` file (run, not edited).
- The copies of the execution-environment brief (no brief fact changes in this child).

### Other risks

- Mirror parity: each new `references/standard.md` without its bundle copy fails `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`. Each contract batch is paired with its bundle-copy task and that test runs after each batch.
- Owner-run experiments cannot run in an agent session; their results arrive only at the owner stop.
- Several Copilot features are preview or experimental, so recorded results carry the observation date and tool versions.
- Test isolation: unit tests use injected script blocks, create no temporary files and remove imported modules in `AfterAll`.

## Experiments

| ID | Question | Status at planning | Delivery | Result artifact | Dependent matrix entries |
| --- | --- | --- | --- | --- | --- |
| E1 | How does Copilot (VS Code and CLI) list a skill present in `.github/skills`, `.claude/skills` and `.agents/skills`? | unresolved | runbook `<FEATURE>/runbooks/e1-copilot-duplicate-skill-listing.runbook.md` | `<FEATURE>/evidence/other/e1-copilot-duplicate-skill-listing-result.<timestamp>.md` | `consumers` of `copilot:skill:*` and shared skills |
| E2 | Does Codex tolerate Claude-only skill frontmatter (`allowed-tools`, `argument-hint`, `context`, `agent`, `disable-model-invocation`, `user-invocable`)? Optional: does VS Code fork on `context: fork`? | unresolved for Codex | runbook `<FEATURE>/runbooks/e2-codex-claude-frontmatter.runbook.md` | `<FEATURE>/evidence/other/e2-codex-claude-frontmatter-result.<timestamp>.md` | `skill-frontmatter-field` entries |
| E3 | Do the Copilot CLI and the Copilot cloud agent read Claude-format `.claude/agents`? | partly resolved (documentation indicates no) | runbook `<FEATURE>/runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md` | `<FEATURE>/evidence/other/e3-copilot-cli-cloud-claude-agents-result.<timestamp>.md` | `copilot:agent:*` (stay `provisional` until recorded) |
| E4 | Do the Copilot location and file-use settings work at workspace scope? | unresolved | runbook `<FEATURE>/runbooks/e4-copilot-workspace-settings.runbook.md` | `<FEATURE>/evidence/other/e4-copilot-workspace-settings-result.<timestamp>.md` | `consumers` of rules, agents and skills; Q5 |
| E5 | Claude Code hooks, subagent frontmatter and permissions details | resolved by documentation | no runbook | `<FEATURE>/evidence/other/e5-claude-hooks-subagent-permissions-documentation.<timestamp>.md` | `hook-registration`, `permission`, `subagent-frontmatter-field` |
| E6 | Does Copilot load both `.github/instructions` and `.claude/rules` (and `CLAUDE.md`) with default settings, and does it deduplicate? | defaults documented; load behavior unresolved | runbook `<FEATURE>/runbooks/e6-copilot-default-double-load.runbook.md` (same scratch repository as E4) | `<FEATURE>/evidence/other/e6-copilot-default-double-load-result.<timestamp>.md` | `consumers` of rules and instructions (Q7) |

E5 result content: the documentation findings listed in research section 6 (E5), each with its source URL and the fetch date 2026-10-30, written by execution without an owner step.

Runbook requirements: each runbook carries the five sections required by `.claude/skills/human-exception-runbook/SKILL.md` (Cue, Prerequisites, Step-by-step Instructions, Verification, Source and Citation with dated sources). Each Verification section gives a result template with `Timestamp:`, `Command:` (the UI action or CLI command), `EXIT_CODE:` (0 when observed as described, 1 otherwise), `Output Summary:` and the tool versions used. Each runbook uses a scratch repository; none instructs the owner to change this repository.

## Owner Stop

Execution stops exactly once for owner input.

- Recorded in `artifacts/orchestration/orchestrator-state.json` with `blocked_reason: "human_decision_required"` and one `human_interaction.requirements[]` entry per pending item: `response: "halt"` for the approval artifact (bulk approval, disputed cases and owner questions), and `response: "exception"` with `runbook_path` for each of the E1, E2, E3, E4 and E6 runbooks, per `.claude/rules/orchestrator-state.md` and `.claude/skills/human-exception-runbook/SKILL.md`.
- Resume condition: `Approval-Status` is `approved` or `approved-with-overrides`, every disputed case has an `Owner-Decision`, and every runbook has a recorded result or an owner statement in `## Owner Overrides` that it is deferred. Deferred runbooks leave the dependent matrix entries `provisional` with `decision_ref` pointing to the runbook.

May proceed before the stop:

- Phase 0 gate; identity pass and identity evidence; survey index and all batch records; classification; the approval artifact in `pending` state.
- E5 result; runbooks E1 to E4 and E6.
- Schema file; the three modules and all unit tests; the repository gate test.
- Bootstrapped matrix with default dispositions, all entries `provisional` where an approval or experiment is pending.
- Contracts and bundle copies for the names present in both `.claude/skills` and `.agents/skills` (default disposition `shared`).
- Full toolchain loop and coverage evidence on the pre-stop state.

Follows the stop:

- Apply owner overrides and disputed-case decisions to the survey records and the matrix.
- Write contracts and bundle copies for any single-ecosystem skill the owner approves as `shared`; remove the contract and bundle copy for any skill the owner moves off `shared`; revise contracts affected by overrides.
- Record runbook results in `consumers` and dispositions; set `decision_status: approved` on every settled entry.
- Re-run the repository gate, the bundle-parity test and the full toolchain loop; record final evidence.

## Implementation Strategy

- Edit set (new files only):
  - `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json`
  - `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1`, `scripts/harness/HarnessSkillContract.psm1`
  - `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`
  - `.agents/skills/<name>/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md` for the contract required set
  - `<FEATURE>/survey/**`, `<FEATURE>/runbooks/**`, `<FEATURE>/evidence/**`
- Dependency changes: none.
- Logging: violations are returned as structured objects and rendered in Pester failure messages that list each offending `id` or contract path.
- Rollout: the repository gate is active from the merge of this child. Later children keep the matrix current as they change features.
- Evidence locations: identity and Phase 0 evidence under `<FEATURE>/evidence/baseline/`; experiment results under `<FEATURE>/evidence/other/`; toolchain, coverage and diff checks under `<FEATURE>/evidence/qa-gates/`; shuffled-order and full-suite runs under `<FEATURE>/evidence/regression-testing/`.

## Open Owner Questions

Each question carries the working assumption that planning and execution use until the owner answers at the owner stop. None is decided on the owner's behalf; each appears in `## Owner Questions` of the approval artifact.

| ID | Question | Recommended default (working assumption) |
| --- | --- | --- |
| Q1 | Should `references/standard.md` files reach destination repositories through pack-manifest entries, or stay repository-local? | Decide in child 4; child 1 adds bundle copies only and no manifest entries. |
| Q2 | Should a shared `SKILL.md` link to its contract, or should the contract stay an unlinked judging standard? | Unlinked in child 1; child 3 decides when it authors the neutral bodies. |
| Q3 | Should the survey propose `shared` or `native` for each single-ecosystem skill, with contracts for every skill the owner approves as `shared`, or are contracts limited to names already in both Claude and Codex? | The former: proposals for every single-ecosystem skill, contracts for every approved `shared` skill. |
| Q4 | Does porting of approved positives happen in child 3 rather than child 1? | Child 3; child 1 records class and port direction and edits no `SKILL.md`. |
| Q5 | `.vscode/settings.json` is gitignored. If E4 shows workspace scope works, should the repository commit it (a `.gitignore` change) or deliver the settings another way (for example the `settings_required.json` pattern or documentation)? | Decision belongs to child 6; child 1 reports the fact and the E4 result. |
| Q6 | Is one matrix entry per hook registration sufficient, or is an entry wanted for every hook script and library file (`.claude/hooks/*`, `.codex/hooks/*`, `.claude/lib/**`, `.codex/scripts/**`)? | Registrations only; library and helper files are excluded as implementation. |
| Q7 | Is E6 (default double loading by Copilot) in scope for child 1? | Yes, run in the same scratch repository as E4. |
| Q8 (raised by this spec) | Is `decision_ref` keyed by issue number and relative to the feature folder (`#1025:survey/difference-approval.md#...`), rather than a repository path that breaks when the folder moves to `completed/` or `.dev`? | Yes, issue-keyed form as specified in `### Decision Reference Format`. |

Items for the orchestrator to confirm (not owner questions): the epic record's 83 and 34 counts against the 79 and 33 observed; which 16 skills the epic record calls materially different; the history of the Copilot copy of `feature-promotion-lifecycle` relative to `docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/`; whether `.claude/settings.local.json` is tracked; the PowerShell version on the `windows-latest` runner; that the parallel run has merged.

## Acceptance Criteria

- [ ] **Phase 0 gate.** `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` records that the parallel run `bugs-1001-1002-1003-1006` has merged to `main` and that the edit set and excluded paths were re-checked against the merge base of `origin/main` and `HEAD` with no moved file, symbol or heading.
- [ ] **Survey completeness.** `<FEATURE>/survey/skill-survey.md` has exactly one row for each skill folder name in the union of `.claude/skills`, `.agents/skills` and `.github/skills`, with no extra and no missing name; a comparison of the index names against a fresh enumeration of the three trees, with zero differences, is recorded in `<FEATURE>/evidence/baseline/`.
- [ ] **Identity evidence.** `<FEATURE>/evidence/baseline/skill-identity.<timestamp>.md` records the `git hash-object` value of each copy and the identity class for every name present in more than one tree.
- [ ] **Per-skill records.** Every index row links to a per-skill record in the shape in `### Survey Records`; every `wording-only` or `substantive` record has a difference table with Diff IDs in the `D-<skill-name>-<nn>` form; every single-ecosystem record has a proposed disposition and rationale.
- [ ] **Classification and approval artifact.** Every Diff ID in the survey has a class from `positive`, `negative`, `neutral`, `mechanism-only` and a port direction, and appears exactly once in `<FEATURE>/survey/difference-approval.md`, either in `## Bulk Approval Set` or under `## Disputed Cases`, with the disputed-case rules applied; the artifact has all headings and fields in `### Owner Approval Artifact`.
- [ ] **Owner decision recorded.** `<FEATURE>/survey/difference-approval.md` has `Approval-Status` `approved` or `approved-with-overrides`, a filled `Approved-By` and `Approved-At`, an `Owner-Decision` for every disputed case, and an owner answer or accepted default for each of Q1 to Q8.
- [ ] **Schema.** `config/harness-parity-matrix.schema.json` exists, declares Draft 2020-12 and the `$id` in `### Parity Matrix: Location and Format`, and defines every field, enum and conditional rule in this spec; verified by the schema-module agreement test in `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`.
- [ ] **Matrix.** `config/harness-parity-matrix.json` exists, conforms to the schema, and gives every feature inventoried by `scripts/harness/HarnessInventory.psm1` exactly one entry and one disposition; verified by `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`.
- [ ] **Contracts.** For every matrix entry with `kind` `skill`, `ecosystem` `codex` and `disposition` `shared`, `.agents/skills/<name>/references/standard.md` exists and satisfies every rule in `### Contract Format`; verified by `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` using `scripts/harness/HarnessSkillContract.psm1`.
- [ ] **Bundle copies.** Each contract has a byte-identical copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`; `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` pass, with results recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] **Completeness unit tests: failure cases.** `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` contains a passing test for each of these inputs producing a violation: an inventoried feature with no entry; an entry without `disposition`; an unknown value in `disposition`, `kind`, `ecosystem`, a `consumers` item and `decision_status`; `dropped` without `reason`; `dropped` with an empty `reason`; `dropped` without `decision_ref`; a duplicate `id`; an `id` inconsistent with `ecosystem` or `kind`; unsorted `features`; an orphan entry that is not `dropped`; `shared` or `generated` without `target_paths`; `generated` without `generated_from`; `provisional` without `decision_ref`; an unknown property.
- [ ] **Completeness unit tests: pass case.** `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` contains a passing test in which a valid in-memory matrix that covers every disposition produces no violation, and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes on the committed matrix.
- [ ] **Contract unit tests.** `tests/scripts/harness/HarnessSkillContract.Tests.ps1` contains a passing test for each of: a missing contract for a required skill; a wrong H1; a missing, extra or reordered H2; an empty section; a gap or repeat in `OB-<n>` or `AC-<n>` numbering; an acceptance check citing a non-existent behavior; a behavior cited by no check; checkbox syntax; and a conforming contract producing no violation.
- [ ] **Inventory unit tests.** `tests/scripts/harness/HarnessInventory.Tests.ps1` contains a passing test for each `kind` inventory rule and a test showing that every entry in the exclusion list is excluded, using injected in-memory file listings only.
- [ ] **Required CI check.** The `poshqc / PowerShell QC` check passes on the pull request head, including the tests under `tests/scripts/harness/` (CI-dependent; checked off at S9).
- [ ] **Coverage.** Each of `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1` and `scripts/harness/HarnessSkillContract.psm1` has at least 85% line coverage, read from `artifacts/pester/powershell-coverage.xml` and recorded per file in `<FEATURE>/evidence/qa-gates/`.
- [ ] **Schema validation fallback.** No gate depends on `Test-Json -SchemaFile`: the module's structural validation is the gate, and any `Test-Json -SchemaFile` assertion is skipped when the PowerShell version is below 7.4; verified by reading `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` and its recorded run.
- [ ] **Test isolation.** Three seeded shuffled file-order runs of `tests/scripts/harness` and one fresh single-process run over `tests/scripts` pass, recorded in `<FEATURE>/evidence/regression-testing/`.
- [ ] **E5 result.** `<FEATURE>/evidence/other/e5-claude-hooks-subagent-permissions-documentation.<timestamp>.md` records the documentation findings for hooks, subagent frontmatter and permissions with source URLs and fetch dates.
- [ ] **Runbooks.** The E1, E2, E3, E4 and E6 runbooks exist at the paths in `## Experiments`, each with the five required sections and the result template.
- [ ] **Runbook results.** Each of E1, E2, E3, E4 and E6 has a recorded result at its path under `<FEATURE>/evidence/other/`, or an owner deferral recorded in `## Owner Overrides` of the approval artifact with the dependent matrix entries left `provisional` and their `decision_ref` pointing to the runbook.
- [ ] **Owner stop recorded.** The orchestrator checkpoint recorded the single owner stop with `blocked_reason` `human_decision_required` and one `human_interaction.requirements[]` entry per pending item, as described in `## Owner Stop`; the stop record is preserved in `<FEATURE>/evidence/other/`.
- [ ] **No new Python.** The list of files added relative to the merge base (`git diff --name-only --diff-filter=A`) contains no file ending in `.py`, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] **File size.** No file added or changed by this child exceeds 800 lines; the repository file-size check passes and the result is recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] **Excluded paths untouched.** The list of files changed relative to the merge base contains none of the paths in `### Excluded paths (must not be edited by this child)`, recorded in `<FEATURE>/evidence/qa-gates/`.

## Definition of Done

- [ ] Every item in `## Acceptance Criteria` is checked off with its evidence.
- [ ] The full toolchain loop (format, lint, type check where applicable, architecture, unit, contract, integration) passes in a single pass, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] `user-story.md` acceptance criteria are checked off consistently with this spec.
