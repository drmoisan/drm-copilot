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
    feature_folder: 1025-harness-survey-gold-standard-contracts-parity-matrix
    depends_on: []
  - issue_num: 1035
    feature_folder: 1035-dev-docs-root-resolver-and-feature-folder-name-parser
    depends_on: []
  - issue_num: 1028
    feature_folder: 1028-shared-source-generators-skills-rules-mcp-agents
    depends_on: [1025, 1035]
  - issue_num: 1029
    feature_folder: 1029-push-down-consolidation-and-ecosystem-packs
    depends_on: [1028]
  - issue_num: 1030
    feature_folder: 1030-hook-parity-across-claude-codex-copilot
    depends_on: [1028]
  - issue_num: 1032
    feature_folder: 1032-retire-github-skills-and-thin-copilot-layer
    depends_on: [1030]
  - issue_num: 1049
    feature_folder: 1049-pushed-down-vendored-code-coverage-carve-out
    depends_on: [1029]
  - issue_num: 1050
    feature_folder: 1050-push-down-ci-workflows-per-ecosystem-pack
    depends_on: [1028, 1029]
  - issue_num: 1051
    feature_folder: 1051-push-down-integration-mcp-tools-and-skill
    depends_on: [1050]
  - issue_num: 1016
    feature_folder: 1016-move-development-docs-to-dev-root-and-reserve-docs-for-production
    depends_on: [1035, 1032, 1049, 1051]
---

# Epic: Shared Agent-Harness Layer Across Claude Code, Codex and GitHub Copilot

Epic issue: #1018.

> **Manifest status.** Planning complete (2026-11-15); every child is prepared and PREFLIGHT: ALL CLEAR. Historical note follows. `issue_num: null` entries are placeholders and
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
| 1 Survey, gold-standard contracts, parity matrix, Copilot and Codex experiments | 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025 | #1025 | 0 | C4 |
| 2 #1016 Phase 1: resolver, configured root, folder-name parser, folder creation by issue number | 2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035 | #1035 (references #1016, does not close it) | 0 | C3 |
| 3 Generators and shared-source pipeline (skills, rules, MCP, agents; all with --check) | 2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028 | #1028 | 1 | C3 |
| 4 Push-down consolidation and per-ecosystem pack selection | 2026-10-30-push-down-consolidation-and-ecosystem-packs-1029 | #1029 | 2 | C3 |
| 5 Hook parity | 2026-10-30-hook-parity-across-claude-codex-copilot-1030 | #1030 | 2 | C3 |
| 6 Retirements and the thin Copilot layer | 2026-10-30-retire-github-skills-and-thin-copilot-layer-1032 | #1032 | 3 | C3 |
| 8 Vendored-code coverage carve-out for pushed-down files | 2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049 | #1049 | 3 | C3 |
| 9 Push down CI workflows per ecosystem pack | 2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050 | #1050 | 4 | C3 |
| 10 Push-down integration MCP tools and skill | 2026-10-31-push-down-integration-mcp-tools-and-skill-1051 | #1051 | 5 | C3 |
| 7 #1016 Phases 2 and 3: migration command, move to .dev, feature-folder rename, default flip | 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016 | #1016 (adopted) | 6 | C3 |

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
- **Child 8 (#1049).** A vendored-code exception in the pushed-down coverage rules: exact paths
  only, hash-verified; the push-down writes a content-hash manifest; a destination check fails
  closed (a changed or unlisted file returns to the coverage denominator); the destination's
  exclusion list is derived from the manifest; the feature-review Blocking rule recognizes
  manifest-derived entries and still blocks hand-written ones. This repository keeps its own tests.
- **Child 9 (#1050).** One CI template per ecosystem pack, written as thin callers to this
  repository's reusable workflows at a pinned ref (copy mode with hashes in #1049's manifest when
  the source is unreachable); the required-check list emitted as data and read by the merge gate
  and the execution-environment brief; never overwrite an existing workflow; branch protection by
  explicit opt-in only.
- **Child 10 (#1051).** The push-down stays mechanical and writes an `integration-needed` file;
  two deterministic, read-only-or-verdict MCP tools (detect, validate) with no model call and no
  MCP sampling; one skill describing the read, resolve, validate loop.

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
- **Child 8 (#1049) depends on child 4 (#1029).** Child 4's consolidated push-down already writes
  the destination `.push-down-manifest.json` used for no-overwrite detection; #1049 extends that
  manifest with content hashes and edits the same push-down pipeline, so it follows child 4 rather
  than preceding it (the owner's "#1049 first" orders it first among children 8 to 10). This keeps
  child 4's cleared plan unchanged.
- **Child 9 (#1050) depends on child 8, child 3 and child 4.** Copy mode records hashes in #1049's
  manifest; the CI templates are per ecosystem pack (child 4) and generated surfaces follow child
  3's generators.
- **Child 10 (#1051) depends on child 8 and child 9.** The detect and validate tools read the
  manifest (#1049) and the required-check data and templates (#1050).
- **Child 7 depends on child 2, child 6 and child 10.** The migration consumes child 2's resolver,
  parser and configured key, and the owner requires it to run last because the mass move rewrites
  paths that every other child edits; children 6 and 10 end the two longest chains, so the edges
  order child 7 after all of them transitively.

Wave computation (longest-path layering, 0-indexed): wave 0 = {child 1, child 2}; wave 1 =
{child 3}; wave 2 = {child 4, child 5}; wave 3 = {child 6, child 8}; wave 4 = {child 9};
wave 5 = {child 10}; wave 6 = {child 7}. No cycles; every reference resolves.

Children 8 to 10 were added on 2026-10-31 by owner decision. They do not force a revision of
children 3 or 4: no path that the cleared plans of #1028 or #1029 cite is changed by adding them,
because the new children edit after those children merge and re-check the merged files in their own
Phase 0 gates. Child 7's Phase 0 gate names "epic children 1-6"; the epic wave barrier orders it
after children 8 to 10, and no cited path changed, so child 7 is not revised.

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

## Planning Refresh 2026-11-14

Planning paused on 2026-10-31 and resumed on 2026-11-14 (UTC) under owner directive OD-1
(autonomous mode). `origin/main` was merged into the integration branch at that time (2,493
commits; merge commit `Merge origin/main into epic/shared-agent-harness-layer-integration`; no
conflicts, because the integration branch changes only `docs/features/`). Each child's
authoritative branch then merged the integration branch, so every child branch contains current
`origin/main`.

### Authoritative child branches

| Issue | Branch | Worktree note |
| --- | --- | --- |
| 1025 | `feature/harness-survey-gold-standard-contracts-parity-matrix-1025` | fast-forwarded from the plan-B decision head, then merged the integration branch |
| 1035 | `feature/dev-docs-root-resolver-phase1-1035` | new branch at the integration head; it is the branch label the re-keyed plan already names. The pre-re-key branch `feature/dev-docs-root-resolver-phase1-1016` is superseded and not used |
| 1028 | `feature/shared-source-generators-skills-rules-mcp-agents-1028` | fast-forwarded to the H3 decision head |
| 1029 | `feature/push-down-consolidation-and-ecosystem-packs-1029` | fast-forwarded |
| 1030 | `feature/hook-parity-across-claude-codex-copilot-1030` | local diverged line (preserved on `wip/preserve-feature-hook-parity-across-claude-codex-copilot-1030-2026-11-10`) replaced by the origin head |
| 1032 | `feature/retire-github-skills-and-thin-copilot-layer-1032` | fast-forwarded to the H3 fix head |
| 1016 | `feature/dev-docs-root-migration-phases-2-3-1016` | local WIP commit (preserved on `wip/1016-local-preflight-round2`) replaced by the origin head |
| 1049 | `feature/pushed-down-vendored-code-coverage-carve-out-1049` | unchanged head plus the integration merge |
| 1050, 1051 | created by their preparation runs | not yet prepared |

The `-r2`, `-r3`, `-resume`, `-h3`, `prep-*`, `issue-1030-prep*` and `feature-1032-h3*` branches
hold no commit that the integration branch lacks and are not used.

### Superseded-work check (coordinator pass)

Method: merged pull requests on `main` since 2026-10-31, `git diff` of each child's surfaces
between the old merge base and `origin/main`, and searches of the current tree for each child's
primary deliverable. Each preparation run repeats the check at citation level and the result is
recorded below at fan-in.

| Issue | Primary deliverable on main? | Main changes that touch the child's scope | Result |
| --- | --- | --- | --- |
| 1025 | No: no `references/standard.md` under `.agents/skills`; no harness parity matrix (the parity-matrix files on main belong to the discovery and docs-estate tooling) | new skills under `.agents/skills`, `.github/skills`, `.claude/skills` (survey inventory grew) | kept; plan refresh required |
| 1035 | No: no `development_docs_root` key anywhere | docs-estate tooling (#1125) adds `documentation_roots` in docs profiles; `enforce-feature-folder-order.ps1` changed | kept; plan refresh required |
| 1028 | No: no skill, rule, MCP or agent generator with `--check` | hook registration moved to one PreToolUse dispatcher per runtime (#1159, `pretooluse-dispatch.json`, `.codex/config.toml` hook table reduced); regeneration framework after integration merges (#1156, `.claude/lib/regeneration/`); `generate_codex_agent_variants.py` changed | kept; plan refresh required |
| 1029 | No: three push-downs remain separate | push-down scripts and tests changed (#1134 epic-wave push-down, bundle tests) | kept; plan refresh required |
| 1030 | No: function parity not delivered | #1159 replaced per-hook registrations with a dispatcher in both runtimes; 77 Claude hook files and 35 Codex hook files changed | kept; scope to be narrowed by the preparation run where the dispatcher already provides registration parity |
| 1032 | No: `.github/skills` and `.github/agents` still present and grew | `.vscode/settings.json` is now tracked (2026-10-31) | kept; plan refresh required |
| 1016 | No: no `.dev` root | docs-estate tooling treats `docs` as a documentation root | kept; plan refresh required |
| 1049 | No: no vendored-code exception in coverage rules | none found | kept; preparation resumes at preflight |
| 1050 | No: no per-pack CI templates | CI now exposes one required context `CI Required Gate` (#1077); the required-check data becomes smaller | kept; scope to be confirmed by its preparation run |
| 1051 | No: no `integration-needed` file or detect/validate tools | none found | kept |

No child is fully superseded at the coordinator pass.

### Per-child refresh results (citation-level check by each preparation run)

| Issue | Superseded | Scope change | Plan(s) after refresh | Preflight |
| --- | --- | --- | --- | --- |
| 1025 | none | none | plan A plan.2026-10-30T17-06.md (43 tasks); plan B owner-decision-plan.md (16 tasks) | plan A: halted at the revision limit (3 design-check defects: [P2-T2], [P2-T3], [P2-T4] need additional test rows); plan B: ALL CLEAR |
| 1035 | none | none | plan.2026-10-30T17-11.md (82 tasks) | halted at the revision limit (2 defects: the `-Area` signature of `Get-DevelopmentDocsKnownRootPattern` versus the plan's root-only form and D-P18; hook WorkspaceRoot choice and Codex import order untested) |
| 1028 | none | Phase 0 waits on the merged parallel run removed | plan.2026-10-30T18-30.md (33 tasks) | halted at the revision limit (1 defect: [P5-T3] write-mode `generate_codex_agent_variants` acceptance condition unsatisfiable once [P5-T2] changes an agent body; required change recorded in its preflight-result evidence of 2026-11-14) |
| 1029 | partial: the `ci-workflows` skill exception was already removed on main; the parallel-run wait is obsolete | narrowed accordingly | plan.2026-10-30T18-37.md (40 tasks) | halted at the revision limit (3 defects: [P2-T6] no test asserts `push_down_report` mode `apply`; [P3-T5] no test fails if `overwrite_unmanaged` or the Copilot packs value is dropped between `dispatchRepoAutomationTool` and the harness; [P2-T1]/[P2-T2] inconsistent `shared.json` path-set definition) |
| 1030 | partial: #1159 already gives each runtime one PreToolUse dispatcher and registry (registration-shape parity); OQ-4 settled by the brief | spec narrowed to v0.3; five SubagentStop validator ports deferred; C1 not expressible, C2 deferred | plan.2026-10-30T18-37.md (20 tasks) | ALL CLEAR |
| 1032 | none | H3 retirement split into its own plan | plan.2026-10-30T18-39.md (36), plan-h3-sync-writer-retirement.md (18), plan-agents-branch-a.md (13), plan-agents-branch-b.md (13) | all four ALL CLEAR |
| 1049 | none | none | plan.2026-10-31T14-03.md (40 tasks) | halted at the revision limit (3 defects: [P3-T4] brief edit inside process-reduction ledger region 0001; [P3-T2] feature-review step inside ledger regions 0001, 0006, 0009; [P2-T5] no test for a higher minor schema version) |
| 1050 | none (one required context `CI Required Gate` already exists; the required-check data reflects it) | none | plan.2026-11-14T09-31.md (20 tasks) | halted at the revision limit (2 defects: pinned actionlint 1.7.12 rejects `job.workflow_repository` and `job.workflow_sha`; spec S6 has no test for the manifest hash and `schema_version` 1.0.0) |
| 1051 | none | none | plan.2026-11-14T10-43.md (19 tasks) | ALL CLEAR |
| 1016 | none | Phase 0 gate covers children 1 to 6 and 8 to 10 | stage A plan.2026-10-30T18-59.md (29 tasks); stage B plan.2026-10-30T23-35.md (40 tasks) | stage A: ALL CLEAR; stage B: halted at the revision limit (2 defects: [P3-T4] feature-template byte identity for CES-TEMPLATES-BYTE-IDENTICAL; [P3-T10] preflight-fix-record path sentence in the atomic-plan-contract copies) |

All fifteen plans pass the repository Python CLI plan validator on the integration branch. No child
was removed. Each halted plan carries its open defects with the required change in its feature
folder's preflight evidence and in its child checkpoint. A halted plan needs one more planner
revision and one confirming preflight. Under the atomic-plan-contract one-return rule, that needs an
`extra_planner_revision` owner directive recorded by the main session in the child's ledger. The
planner subagent cannot record one, and OD-1 is not a recorded directive.

### Extra-revision round 2026-11-15 (OD-2)

The coordinator recorded OD-2 (`extra_planner_revision`, step `S4`) in the ledger of each of the
seven halted children. Each child received one planner revision that applied its recorded defects
and one confirming preflight. A session crash at 2026-11-15T17:18Z interrupted the round; it
resumed without repeating completed work. All seven are now PREFLIGHT: ALL CLEAR.

| Issue | Final head | Scope change (autonomous mode) |
| --- | --- | --- |
| 1025 plan A | ede12549f | S1 (spec D-R6): no per-field JSON type checks; schema compared on property names, enums, required fields, conditional rules and the `id` pattern; "`## Objective` is prose" is advisory. Spec rule 6 for contracts has no lint test; manual tasks and the final self-review cover it |
| 1035 | 183a60630 | OD-P4: `Get-BlastRadius` and `derive_blast_radius` do not call the new resolver; each takes an optional root defaulting to `docs/features`; resolver wiring is deferred |
| 1028 | f2a940541 | none ([P5-T3] uses the three-condition write-mode check) |
| 1029 | 29576fc6b | none (decision D15 defines one shared path set) |
| 1049 | 97b815af1 | none |
| 1050 | fe5775848 | none (the rendered caller passes `harness_repository` and `harness_ref` inputs) |
| 1016 stage B | 09bc4995a | none ([P1-T3] keeps the blast-radius tests on the `docs/features` default) |

Known gap carried to execution: after #1016 moves this repository to `.dev`, the two blast-radius
functions still return `docs/features/...` paths when given only a folder name, because #1035
deferred their resolver wiring (OD-P4) and no #1016 rule covers it. Close it inside #1016's
execution through a remediation cycle, or file a follow-up item.

### Waves after the refresh

The dependency set is unchanged, and `Invoke-EpicWave.ps1` returns the same layering: wave 0 =
{1025, 1035}; wave 1 = {1028}; wave 2 = {1029, 1030}; wave 3 = {1032, 1049}; wave 4 = {1050};
wave 5 = {1051}; wave 6 = {1016}. The execution precondition on the parallel run
`bugs-1001-1002-1003-1006` is satisfied: issues 1001, 1002, 1003, 1006 and 1013 are closed.

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
- Child 8 (#1049): cross_module_contract_change (push-down manifest schema consumed by a destination
  check and by the coverage rules' review gate) and policy edits to pushed-down rules; C3.
- Child 9 (#1050): cross_module_contract_change (required-check data consumed by the merge gate and
  the brief; per-pack CI templates); C3.
- Child 10 (#1051): two new deterministic MCP tools and one skill over contracts from children 8
  and 9; C3.

## Cost-Benefit Re-examination 2026-11-17 (owner directive OD-4)

Owner directive OD-4 (2026-11-17): "reexamine under the cost benefit rule". The rule: tolerate an
overlap when the time saved by running in parallel exceeds the expected time to resolve the
conflicts; only edits to the same logic stay hard edges. #1016 runs last by owner requirement.

Method. Overlap is the intersection of the backticked repository paths each child's plan(s) cite
(feature-folder documents excluded). Class: `hard` when the downstream plan consumes an artifact,
symbol or contract the upstream child creates and its Phase 0 stops without it, or both edit the
same logic; `overlap` otherwise. Saved hours use the observed rate of about 13 minutes per plan
task (#1035: 82 tasks in about 18 active hours, review and CI included) and the remaining task
counts (#1029 40, #1030 20, #1032 67 on one agents branch, #1049 40, #1050 20, #1051 19). Hours
are estimates, not measurements.

| Edge | Class | Cited-path overlap | Saved h | Risk | Decision |
| --- | --- | --- | --- | --- | --- |
| 1028 -> 1029 | hard: push-down installs the generated shared layer; pack manifests list generated files | 19 (`repo-automation-service.ts`, agent generator, `.mcp.json`) | n/a | same logic | keep |
| 1028 -> 1030 | hard: Phase 0 check (b) reads generator-owned regions of `.codex/config.toml`, agent `hooks:` and the dispatch registries, which #1030 edits | 17 (`.codex/config.toml`, `.claude/agents/*.md`, dispatch registries) | n/a | same logic | keep |
| 1030 -> 1032 | hard: UA-C5 stops without the `.github/hooks` dispositions #1030 records | 8 | n/a | stop gate | keep |
| 1029 -> 1032 | overlap: UA-C4a to UA-C4c are record-only (present or absent both handled); P2-T1 already scans pack manifests for retired paths | 16 (CHANGELOG, README, brief, `repo-automation-command-registration-admin.ts`) | about 4 (1029 minus 1030 remaining) | low to medium: if #1032 lands first, #1029 regenerates pack manifests (about 1 to 2 h, likelihood low because #1032 is longer) | relax |
| 1029 -> 1049 | hard: P0-T1 gate (a) requires #1029's `push-down-destination-manifest.ts` exports; same push-down pipeline | 13 | n/a | same logic | keep |
| 1028 -> 1050 | transitive through 1029 | 15 | 0 | none | keep |
| 1029 -> 1050 | hard: D3 rides #1029's `shared` layer; harness suites are #1029's | 16 | n/a | same logic | keep |
| 1049 -> 1050 | overlap: the manifest symbols #1050 cites (`parseDestinationManifest`, `hashPayloadText`) are #1029 code that #1049 only verifies (#1049 edits no TypeScript production); #1050 cites #1049's spec, which is committed | 9 (`jest.config.cjs` append-only thresholds, `poshqc-coverage.json`, CHANGELOG, ledger) | about 8.7 | medium: mechanical merges on shared config files (about 1.5 h); one light plan revision for the [P0-T1] upstream gate | relax |
| 1050 -> 1051 | hard: S20, S38, S39, S44 build fixtures from #1050's renderer; data file schema | 6 | n/a | consumes | keep |
| 1049 -> 1051 | overlap: #1051 reads manifest symbols owned by #1029 code and #1049's committed spec; no #1049 artifact consumed | 6 | about 4.3 (1049 minus 1050 remaining) | low (about 0.5 h); light revision of EX-1 wording only | relax |
| 1035, 1032, 1051 -> 1016 | owner requirement (#1016 runs last) | 15 / 10 | n/a | owner | keep; 1049 -> 1016 added so #1016 still follows every child once 1049 -> 1051 is relaxed |

Revised `depends_on`: 1032 [1030]; 1050 [1028, 1029]; 1051 [1050]; 1016 [1035, 1032, 1049, 1051].
`Invoke-EpicWave.ps1` layering: wave 0 = {1025, 1035}; wave 1 = {1028}; wave 2 = {1029, 1030};
wave 3 = {1032, 1049, 1050}; wave 4 = {1051}; wave 5 = {1016}. Peak width 3 under the cap of 4;
seven waves become six. Launches remain per-edge: each child starts when its own `depends_on`
are merged. #1050 and #1051 each receive one light plan revision through the
extra-planner-revision route at launch, recorded in their checkpoints with this table as the
reason.
