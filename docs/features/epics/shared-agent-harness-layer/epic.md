---
epic: shared-agent-harness-layer
integration_branch: epic/shared-agent-harness-layer-integration
created_at: 2026-10-30T20:30
intent:
  epic_type: enabler
  business_outcome_hypothesis: With default settings, Claude Code, Codex and GitHub Copilot each load every skill and instruction in this repository and in destination repositories exactly once, each shared skill meets one tool-neutral gold standard, and no native capability is lost.
  leading_indicators:
    - The parity matrix assigns a disposition to every native feature of every ecosystem, and its completeness test passes.
    - Every shared skill has a references/standard.md contract and each ecosystem's expression is checked against it.
    - Each generator reports no drift in --check mode on the integration branch.
    - A destination that selects one ecosystem pack receives no files for the other ecosystems.
  nfrs:
    - Enforcement hooks do not invoke Python.
    - No new Python. Code pushed down to destination repos (skills, skill helpers, hooks, libs) is PowerShell or bash; TypeScript is only for MCP tools and extension commands.
    - Mirrors are generated, not symlinked.
    - Migration of a destination is non-destructive, reports a dry run first, and never overwrites a destination's own edits.
    - No production file exceeds 800 lines.
    - Line coverage >= 85% and branch coverage >= 75% (where measured) for changed code.
features:
  - issue_num: 1025
    feature_folder: harness-survey-gold-standard-contracts-parity-matrix
    depends_on: []
  - issue_num: 1035
    feature_folder: 2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035
    depends_on: []
  - issue_num: 1028
    feature_folder: 2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028
    depends_on: [1025, 1035]
  - issue_num: 1029
    feature_folder: 2026-10-30-push-down-consolidation-and-ecosystem-packs-1029
    depends_on: [1028]
  - issue_num: 1030
    feature_folder: 2026-10-30-hook-parity-across-claude-codex-copilot-1030
    depends_on: [1028]
  - issue_num: 1032
    feature_folder: 2026-10-30-retire-github-skills-and-thin-copilot-layer-1032
    depends_on: [1029, 1030]
  - issue_num: 1016
    feature_folder: 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016
    depends_on: [1035, 1032]
---

# Epic: Shared Agent-Harness Layer Across Claude Code, Codex and GitHub Copilot

Epic issue: #1018.

> **Manifest status.** Planning in progress. `issue_num: null` entries are placeholders and
> `feature_folder` values are short-name hints; both are back-filled from each prepared child's
> promotion receipt and active folder at fan-in. Child 7 adopts the existing issue #1016 and is
> not promoted again (owner decision E1, 2026-10-30). Child 1 is keyed to its promoted issue
> #1025.

## Goal

Migrate the three agent ecosystems in this repository to the common cross-tool conventions so
that each tool loads every skill and instruction exactly once with default settings, without
losing the power of any native harness, and with each ecosystem expressing each shared skill at
the same gold standard. The confirmed design, facts, acceptance criteria and risks are recorded in
`docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`
and are not re-opened here.

## Children

| Child | Feature (hint) | Issue | Wave | Band |
| --- | --- | --- | --- | --- |
| 1 Survey, gold-standard contracts, parity matrix, Copilot and Codex experiments | harness-survey-gold-standard-contracts-parity-matrix | #1025 | 0 | C4 |
| 2 #1016 Phase 1: resolver, configured root, folder-name parser, folder creation by issue number | 2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035 | #1035 (references #1016, does not close it) | 0 | C3 |
| 3 Generators and shared-source pipeline (skills, rules, MCP, agents; all with --check) | shared-source-generators-skills-rules-mcp-agents | new | 1 | C3 |
| 4 Push-down consolidation and per-ecosystem pack selection | push-down-consolidation-and-ecosystem-packs | new | 2 | C3 |
| 5 Hook parity | hook-parity-across-claude-codex-copilot | new | 2 | C3 |
| 6 Retirements and the thin Copilot layer | retire-github-skills-and-thin-copilot-layer | new | 3 | C3 |
| 7 #1016 Phases 2 and 3: migration command, move to .dev, feature-folder rename, default flip | dev-docs-root-migration-and-feature-folder-rename | #1016 (adopted) | 4 | C3 |

Waves are 0-indexed (longest-path layering).

### Issue keying for #1016

The manifest is keyed by `issue_num`, and the planning and execution validators require each
`issue_num` to be unique. Owner decision E1 (2026-10-30): child 7 (Phases 2 and 3: migration
command, `.dev` move, feature-folder rename, default flip) adopts #1016, so #1016 closes only when
the move completes. Child 2 (Phase 1) receives a new child issue that references #1016; child 2's
issue, spec, checkpoint and pull request carry no `Closes`/`Fixes`/`Resolves` line for #1016.
#1016 is not promoted a second time. Child 2 carries the full #1016 design (D-1 to D-22) in its
spec with Phases 2 and 3 marked as delivered by child 7; child 7's spec cites it.

Re-key record (2026-10-30). Child 2 was prepared under #1016 before decision E1 arrived. At
fan-in the epic planner: promoted the new child issue #1035 through
`mcp__drm-copilot__potential_to_issue` (potential entry
`2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser.md`); moved the folder
`2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016` to
`2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035` with `git mv`; rewrote the
identity text only (issue.md header and a re-key note, the spec and user-story issue lines, the
plan title, issue line, branch label `feature/dev-docs-root-resolver-phase1-1035`, `<FEATURE>`
path, SCRATCH namespace and re-baseline comment issue number); and added
`evidence/other/preflight-result.2026-10-30T22-51.md`. No plan task or acceptance condition
changed, and the plan re-validated. No document in the folder carries a Closes, Fixes or Resolves
line for #1016. Historical research and preflight-fix records keep the old path as written. The
pushed branch `feature/dev-docs-root-resolver-phase1-1016` holds the pre-re-key preparation and
is superseded by the integration branch.

## Scope

- **Child 1.** Content-level survey of the 90 skill names (the heading comparison overstates
  differences), a tool-neutral gold-standard contract per shared skill
  (`.agents/skills/<name>/references/standard.md`: objective, observable behaviors, acceptance
  checks), classification of every difference as positive, negative, neutral or mechanism-only
  with bulk owner approval and escalation of disputed cases, the parity matrix with a disposition
  (shared, native, generated, dropped with a written reason) for every native feature of every
  ecosystem plus the completeness test, and the unverified-behavior experiments (Copilot duplicate
  listing, Codex tolerance of Claude-only frontmatter, Copilot CLI and cloud agent reading
  `.claude/agents`, workspace-scope Copilot settings, Claude hooks/subagent/permissions details).
  Experiments that need VS Code or Codex are delivered as owner-run runbooks with recorded results.
  Child 1 owns the location and schema of the parity matrix and the contract format; later
  children consume them.
- **Child 2 (#1016 Phase 1).** The `development_docs_root` key (default `docs/features`, behavior
  unchanged), a resolver in Python, PowerShell and TypeScript, the `.dev` fallback, the CI
  docs-only scope, JSON governance globs, dot-folder handling for Node-glob and ripgrep consumers,
  checked write-scope literals, the feature-folder name parser accepting both formats (D-18 to
  D-22), the folder-creation tool naming new folders `<NNNN>-<feature>`, and the mirrored, bundled
  and Codex counterparts.
- **Child 3.** Generators with `--check` for the shared skill mirror (`.agents/skills` to
  `.claude/skills`), path-scoped rules (one source to `.claude/rules` `paths:` and
  `.github/instructions` `applyTo`), MCP servers (one list to `.mcp.json` and the `[mcp_servers]`
  table of `.codex/config.toml`), and agents (one logical definition to `.claude/agents/*.md` and
  `.codex/agents/*.toml`); `AGENTS.md` as the instruction source with `CLAUDE.md` importing it.
- **Child 4.** The three push-downs become one pipeline with the existing MCP tools kept as thin
  wrappers; per-ecosystem pack selection with the shared layer always installed; dry-run report
  first; no overwrite of a destination's own edits, detected against the last pushed-down manifest.
- **Child 5.** Hook parity of function per the parity matrix; Codex gains a hook only where its
  system can express the behavior; no Python in enforcement hooks.
- **Child 6.** Retire `.github/skills` after porting or finding stale its three unique sections
  (`feature-promotion-lifecycle`, `feature-review-workflow`); retire `.github/agents` or reduce it
  to a generated file per child 1's verification result; the thin Copilot layer (prompts,
  handoffs, hooks native in `.github`); Copilot collision controls in `.vscode/settings.json` if
  workspace scope works, otherwise documented.
- **Child 7 (#1016 Phases 2 and 3).** The TypeScript migration command (MCP tool in
  `@danmoisan/drm-copilot-mcp` with a thin `npx` entry point, no Python, idempotent), the move of
  this repository to `.dev`, the rename of existing feature folders to `<NNNN>-<feature>` with the
  owner-decision stop for non-matching folders and issue-number collisions, and the default flip.

## Non-Goals

- Re-opening any confirmed design decision in the epic record or in #1016 (D-1 to D-22).
- Symlinked mirrors (Windows symlinks are unreliable).
- Python in enforcement hooks or in the migration command.
- Any change to the lifecycle semantics of potential, active, completed and archive.
- Renaming potential records, epics, parallel runs or research folders.
- Edits to files or branches of the in-flight parallel run `bugs-1001-1002-1003-1006`.

## Dependency Rationale

Edges are drawn only where a child consumes a contract or edits a file that an upstream child
creates or changes.

- **Child 3 depends on child 1 and child 2.** The generators emit the dispositions and contract
  layout child 1 defines (which surfaces are shared, generated or native), and the agent generator
  emits write scopes that child 2 converts to checked literals for the configured root (D-16).
- **Child 4 depends on child 3.** The consolidated push-down installs the generated shared layer
  and the per-ecosystem outputs that child 3 produces; pack manifests list generated files.
- **Child 5 depends on child 3.** Hook registrations live in agent frontmatter and in
  `.codex/config.toml`, both of which child 3's generators own after it merges.
- **Child 6 depends on child 4 and child 5.** Retiring `.github/skills` and `.github/agents`
  changes pack contents (child 4), and the thin Copilot layer keeps the Copilot hooks whose
  dispositions child 5 settles.
- **Child 7 depends on child 2 and child 6.** The migration consumes child 2's resolver, parser
  and configured key, and the owner requires it to run last because the mass move rewrites paths
  that every other child edits; child 6 is the last of those children, so the edge orders child 7
  after all of them transitively.

Wave computation (longest-path layering, 0-indexed): wave 0 = {child 1, child 2}; wave 1 =
{child 3}; wave 2 = {child 4, child 5}; wave 3 = {child 6}; wave 4 = {child 7}. No cycles; every
reference resolves.

## Shared Design

- **Language (owner directive, refined 2026-10-30; replaces the earlier wording).** Avoid new
  Python; existing Python is tolerated (reuse, call or extend in place only). The language depends
  on where the new code runs: (1) anything pushed down to destination repos, meaning skills, skill
  helpers, hooks and libs, is PowerShell or bash, never TypeScript and never Python; (2)
  TypeScript is only for MCP commands (tools in the MCP server package) and extension commands.
  The skill, rule, MCP-config and agent generators, their `--check` modes, the parity-matrix
  checks and the survey tooling are each classified: if a skill or hook invokes it, it is
  PowerShell or bash; if it is an MCP tool or extension command (for example the #1016 migration
  command, settled as an MCP tool with a thin `npx` entry, and any MCP wrapper over a generator),
  the wrapper is TypeScript. Every child plan records the classification of each planned
  artifact, and any case that cannot follow the rule is raised as an owner question rather than
  decided by the child. Owner exception (E2): a language-native analyzer is allowed when it
  analyzes that same language and ships only with that language's pack; PowerShell remains the
  baseline.
- **Planning ahead of child 1 (owner decision E3).** Children 3 to 6 are planned before child 1's
  contracts, dispositions and approvals exist. Each cites child 1's spec for the contract format
  and parity-matrix schema, and carries a Phase 0 gate that re-checks child 1's outputs at
  execution time; one plan revision is accepted when the survey invalidates a plan.
- `AGENTS.md` is the instruction source; `CLAUDE.md` is `@AGENTS.md` plus Claude-only text;
  `.github/copilot-instructions.md` holds Copilot-only text.
- `.agents/skills` is the source for shared skills; tool-only skills stay in their native folder.
- Every generator has a `--check` mode that reports drift and fails CI on drift.
- The parity matrix is machine-readable and owned by child 1; a test fails when a native feature
  has no disposition.
- `development_docs_root` is the one configured key for the development-docs root; no consumer
  hard-codes `docs/features` after child 2.
- Feature-folder names: `^\d{4}-\d{2}-\d{2}-` is the old date-first format; any other name starting
  with four digits and a dash is the new format; both are accepted until child 7 migrates.

## Owner Decisions H1 to H3 (2026-10-31)

- **H1.** Child 1 (#1025) receives one plan-A revision beyond the one-revision limit: a
  `quality-tiers.yml` entry for `scripts/harness` (QT008), a deterministic parity-matrix `id`
  encoding covering hook matchers with special characters, the `$schema` key and duplicate
  registrations (children 3 to 6 consume it), and confirmation that the matrix schema accepts
  `decision_status: provisional`.
- **H2.** Child 7 (#1016) stage B takes option (b): the moves-then-rewrites case, where the
  second apply call refuses its own decision file after the moves, is a documented halt branch that
  stops with a clear message telling the user to re-run the dry run. Stage A is not reopened. One
  more stage B revision is authorized for P2-T4, P1-T3/P1-T4 and P7-T1.
- **H3.** Child 6 (#1032) owns retiring or redirecting
  `scripts/dev-tools/sync-agents-from-instructions.ps1`; child 3 (#1028) owns redirecting the Codex
  native converter to the new generators. Child 3's OQ-6 default is resolved accordingly, and both
  plans receive the scope revision this requires.

## Execution Preconditions

- Execution starts only after the parallel run `bugs-1001-1002-1003-1006` has merged to `main`.
  That run changes hooks, skills, the execution-environment brief, the policy-audit templates and
  the bundled extension mirrors. Every child plan names the exact files it edits and carries a
  Phase 0 gate that re-checks those files against current `origin/main` at execution time and
  stops for re-planning when a named file, symbol or heading has moved.
- Before each wave the epic orchestrator syncs `origin/main` into the integration branch per the
  epic-orchestrate skill.

## Complexity Assessment

- Child 1: research-heavy, novel, with owner-run experiments and bulk approvals; band C4 by
  judgment.
- Child 2: cross_module_contract_change (one key read by every consumer in three runtimes); C3.
- Child 3: cross_module_contract_change (new generated surfaces consumed by every ecosystem); C3.
- Child 4: cross_module_contract_change (push-down MCP tool contract and pack manifests); C3.
- Child 5: cross_module_contract_change (hook behavior across two ecosystems); C3.
- Child 6: cross_module_contract_change (retires two Copilot surfaces and changes pack contents);
  C3.
- Child 7: cross_module_contract_change plus a repository-wide mechanical move with an owner stop;
  C3.
