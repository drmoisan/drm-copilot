# legacy-discovery-documentation - Plan

- **Issue:** #371
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature (per `issue.md` marker `- Work Mode: full-feature`)
- **AC Sources:** `spec.md` (11 acceptance criteria) and `user-story.md` (5 acceptance criteria)

## Required References

- General Coding Standards: `.claude/rules/general-code-change.md`
- General Unit Test Policy: `.claude/rules/general-unit-test.md`
- Tone Policy: `.claude/rules/tonality.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope Statement

This feature delivers Markdown documentation only: a README-indexed capability
documentation directory at `docs/engineering/legacy-discovery-and-parity/` containing six
files (`README.md`, `workflow.md`, `domain-profile.md`, `artifacts-and-schemas.md`,
`running-the-workflow.md`, `consumer-onboarding.md`). No production source code and no
Python/TypeScript/PowerShell/C# files are in scope. Consequently:

- No language toolchain baseline (format/lint/type-check/test) tasks apply. The coverage
  policy in `.claude/rules/general-unit-test.md` applies to code; no code is in scope.
- Research (`research/2026-07-17T15-33-legacy-discovery-documentation-371-research.md`,
  section 2) verified the repository has no docs-lint convention (no markdownlint,
  remark, or link-check tooling and no docs structural tests), so mandatory structural
  test gates do not apply. Verification tasks below use deterministic `git`-based
  file-existence checks and manual relative-link resolution recorded as evidence.
- An optional pytest content-contract test is addressed by an explicit decision task
  (P2-T6) with a documented decline branch; it is not repository-mandated.

Evidence path clause (non-overridable): every evidence-producing task writes to
`docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No task may write
evidence under any `artifacts/...` path. Artifact filenames use the `yyyy-MM-ddTHH-mm`
timestamp format.

Upstream state: all 13 upstream child features (#9001–#9012, #9014) are absent on the
current branch (research section 3). All documented command names, schema paths, and
pack-manifest decisions are provisional; documentation is authored against planned scope
from `docs/features/epics/legacy-discovery-and-parity/objective-source.md` and reconciled
against the integration branch (`epic/legacy-discovery-and-parity-integration`) before
the PR (P2-T5).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance & Baseline

- [ ] [P0-T1] Read the repository policy files in the policy-compliance order — `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/tonality.md` — and record that no language-specific code rules apply because the deliverable is Markdown-only documentation.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:` (the ordered list above), the explicit list of files read, and the statement that no language-specific code rules (Python/PowerShell/TypeScript/C#) apply to this Markdown-only feature.
- [ ] [P0-T2] Capture the baseline state of the target documentation tree by running `git status --porcelain docs/engineering/` and `git ls-files docs/engineering/` and recording that `docs/engineering/legacy-discovery-and-parity/` does not yet exist on the branch.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/baseline/phase0-docs-tree-baseline.<yyyy-MM-ddTHH-mm>.md` exists and contains `Timestamp:`, `Command:` (both commands verbatim), `EXIT_CODE:` for each command, and `Output Summary:` confirming the absence of the target directory and listing the current contents of `docs/engineering/`.

### Phase 1 — Author Documentation Set

Every page authored in this phase must: (a) describe the capability as domain-neutral,
(b) confine TaskMaster/TMW/Outlook/VSTO/email/task-management specifics to onboarding
examples (permitted only in `consumer-onboarding.md` and the README's scoping statement),
(c) link to — never restate — per-feature reference docs, (d) mark every forward
reference to a not-yet-delivered file, command, schema path, or pack decision as
"planned", and (e) introduce no name colliding with the `code-modernization` plugin
(`/modernize-*` commands; agents `legacy-analyst`, `business-rules-extractor`,
`architecture-critic`, `scaffolder`, `security-auditor`, `test-engineer`,
`version-delta-analyst`). Content is authored against planned scope in
`docs/features/epics/legacy-discovery-and-parity/objective-source.md` because no
upstream spec is present on the branch (research section 3).

- [ ] [P1-T1] Create `docs/engineering/legacy-discovery-and-parity/README.md` containing the capability overview, an explicit statement of the domain-neutrality invariant (no TaskMaster/TMW/Outlook/VSTO/email/task-management behavior is framework behavior; all domain specificity is runtime configuration via the domain profile), an audience guide, and a linked index of all five topic pages using relative paths (`workflow.md`, `domain-profile.md`, `artifacts-and-schemas.md`, `running-the-workflow.md`, `consumer-onboarding.md`).
  - Acceptance: File exists; it states the domain-neutrality invariant verbatim as an invariant; every one of the five topic pages is linked via a relative path; filenames are kebab-case. Satisfies spec AC 1.
- [ ] [P1-T2] Create `docs/engineering/legacy-discovery-and-parity/workflow.md` documenting the end-to-end discovery/parity workflow: workspace initialization (planned, #9005), agent/skill-driven discovery and parity definition (planned, #9007/#9008), artifact population, validation (planned, #9003), completion-gate enforcement (planned, #9004), and terminal outputs (reports rendered, #9010; acceptance scenarios generated, #9009), citing each owning feature's reference docs instead of restating them.
  - Acceptance: File exists; the sequence runs from workspace initialization through validated artifacts to rendered reports and generated acceptance scenarios; no per-feature reference content is duplicated; planned items are explicitly marked. Satisfies spec AC 2 and supports spec AC 8/9.
- [ ] [P1-T3] Create `docs/engineering/legacy-discovery-and-parity/domain-profile.md` documenting domain-neutral authoring of the domain-profile configuration contract: the contract fields (legacy source location, target location, technology stack, artifact conventions) and authoring guidance, deferring parser internals and the PyYAML-vs-frontmatter decision to the #9001 reference docs (marked planned).
  - Acceptance: File exists; all four contract fields are documented with domain-neutral guidance; parser internals are explicitly deferred to #9001; the #9001 parser decision is marked planned. Satisfies spec AC 3 and user-story AC 1.
- [ ] [P1-T4] Create `docs/engineering/legacy-discovery-and-parity/artifacts-and-schemas.md` documenting the artifact/schema lifecycle: the seven versioned JSON schemas by name (Feature Contract, Coverage Ledger, Runtime Characterization Scenario, Parity Matrix, Unspecified Behavior Record, Product Decision Record, Evidence Reference), the schema-versioning convention (planned, #9002), validation via the validator CLI (planned, #9003) and the existing `$schema`/governed-glob machinery (`scripts/dev_tools/validate_json.py`, `dev.validate-json`), and completion-gate hook enforcement (planned, #9004).
  - Acceptance: File exists; all seven schemas are named; the versioning convention, validation path, and completion-gate enforcement are described at capability level with planned markings for #9002/#9003/#9004 content; existing machinery is cited by real path. Satisfies spec AC 4 and user-story AC 3.
- [ ] [P1-T5] Create `docs/engineering/legacy-discovery-and-parity/running-the-workflow.md` documenting the three lockstep invocation surfaces in the order CLI before MCP before VS Code: CLI (`poetry run dev.discovery.<command>`, matching the established `dev.*` alias convention in `pyproject.toml`), MCP tools (extension-hosted server and the standalone `packages/mcp-server/` npm package via `npx`), and VS Code command-palette entries, stating explicitly that the three surfaces are lockstep equivalents and that concrete `dev.discovery.*` command names are planned until the owning features land (#9011 and functional features).
  - Acceptance: File exists; surfaces appear in CLI-then-MCP-then-VS-Code order; the lockstep-equivalence statement is present; provisional command names are marked planned. Satisfies spec AC 5 and user-story AC 2.
- [ ] [P1-T6] Create `docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md` documenting the generic push-down onboarding flow — consumer runs a push-down tool (CLI `scripts/dev_tools/push_down_copilot_customizations.py`, `push_down_codex_and_agents_customizations.py`, or `push_down_claude_customizations.py`; MCP `push_down_*` tools; VS Code commands) and receives the discovery agents, skills, hooks, schemas, and templates from the bundled `resources/` mirrors — with TaskMaster (legacy source provider) and TMW (modern target provider) framed strictly as worked onboarding examples and the pack-manifest placement decision (#9012: `core` vs a language-neutral pack) marked planned.
  - Acceptance: File exists; the generic flow is documented independently of any consumer; TaskMaster/TMW appear only in clearly-labeled example sections; the pack decision is marked planned. Satisfies spec AC 6 and user-story AC 4.

### Phase 2 — Verification, Reconciliation & QA

- [ ] [P2-T1] Verify structural completeness of the documentation set by running `git status --porcelain docs/engineering/legacy-discovery-and-parity/` and listing the directory, confirming exactly the six files (`README.md`, `workflow.md`, `domain-profile.md`, `artifacts-and-schemas.md`, `running-the-workflow.md`, `consumer-onboarding.md`) exist with kebab-case names.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/structural-completeness.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing all six files as present. Supports spec AC 1 and Definition of Done item 2.
- [ ] [P2-T2] Verify relative-link resolution by enumerating every relative Markdown link in the six files (via a grep for `](` targets) and manually checking each target: the link resolves to a file present on the branch, or the surrounding text explicitly marks the target as planned.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/link-resolution.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:` (the link-enumeration command), `EXIT_CODE:`, `Output Summary:`, and a per-link table of target → resolves / marked-planned, with zero unresolved-and-unmarked links. Satisfies spec AC 9 (planned-marking) and Definition of Done item 5.
- [ ] [P2-T3] Verify the domain-neutrality invariant by running a case-insensitive grep for `TaskMaster|TMW|Outlook|VSTO|email|task-management` across the six documentation files and confirming every match occurs only in the consumer-onboarding example sections or in the README/pages' statements scoping consumers to examples — never as a description of framework behavior.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/domain-neutrality.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and a per-match classification (example / invariant-statement) with zero framework-behavior matches. Satisfies spec AC 7 and user-story AC 5.
- [ ] [P2-T4] Verify naming-collision absence by running a grep for `modernize-|legacy-analyst|business-rules-extractor|architecture-critic|version-delta-analyst` and for standalone agent names `scaffolder`, `security-auditor`, `test-engineer` across the six documentation files, confirming the doc set introduces or implies none of the installed `code-modernization` plugin's command or agent names.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/naming-collision.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` reporting zero collisions (any incidental match must be classified and shown not to introduce a plugin name). Satisfies spec AC 11.
- [ ] [P2-T5] Reconcile the documentation set against the integration branch by fetching `epic/legacy-discovery-and-parity-integration`, enumerating delivered upstream feature folders/specs (`git ls-tree`/`git ls-files` against the fetched ref for `docs/features/active/` and `docs/features/completed/`), and for every documented command name, file path, schema name, and pack decision either verifying it against delivered content and updating the page, or re-marking it as planned where the upstream feature has not landed.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/other/integration-reconciliation.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:` (fetch and enumeration commands), `EXIT_CODE:`, `Output Summary:`, the list of upstream features found present/absent on the integration branch, and a per-item disposition table (verified / corrected / re-marked planned) covering every provisional command name, path, schema name, and pack decision in the doc set. Satisfies spec AC 9 and AC 10 and Definition of Done item 4.
- [ ] [P2-T6] Record the decision on the optional pytest content-contract test: either (a) author `tests/docs/test_legacy_discovery_documentation_contracts.py` in the style of `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py` asserting the six files exist with their required top-level sections, run `poetry run pytest tests/docs/`, and store the run evidence under `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/`; or (b) record an explicit decline with rationale (no docs-lint convention mandates it; research section 2). This task is optional in outcome but the decision record is mandatory; branch (b) is the authorized default.
  - Acceptance: Either a passing `poetry run pytest tests/docs/` evidence artifact under `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, or `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/other/optional-contract-test-decision.<yyyy-MM-ddTHH-mm>.md` with `Timestamp:` and the decline rationale. Satisfies Definition of Done item 6.
- [ ] [P2-T7] Capture the end-state of the documentation set by running `git status --porcelain docs/engineering/legacy-discovery-and-parity/ tests/docs/` and `git diff --stat` limited to those paths, recording the final file inventory and confirming no files outside the declared scope changed, and recording a tone-policy self-review statement (professional, factual, neutral wording per `.claude/rules/tonality.md`) for the six pages.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/end-state.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (final inventory; scope confirmation), and the tone-policy review statement. Satisfies Definition of Done items 1, 3, and 7.

## Acceptance-Criteria Traceability

| AC source | Criterion (abbreviated) | Plan coverage |
|---|---|---|
| spec.md AC 1 | README-indexed directory; kebab-case; invariant stated; relative links | P1-T1, P2-T1 |
| spec.md AC 2 | Workflow page end to end without per-feature duplication | P1-T2 |
| spec.md AC 3 | Domain-profile page; contract fields; parser deferred to #9001 | P1-T3 |
| spec.md AC 4 | Artifacts-and-schemas page; seven schemas; versioning; validation; gates | P1-T4 |
| spec.md AC 5 | Running-the-workflow page; CLI before MCP before VS Code | P1-T5 |
| spec.md AC 6 | Consumer-onboarding page; push-down; TaskMaster/TMW as examples | P1-T6 |
| spec.md AC 7 | Domain-neutrality invariant holds across the doc set | Phase 1 shared constraints (a)-(b), P2-T3 |
| spec.md AC 8 | No per-feature reference documentation duplicated | Phase 1 shared constraint (c), P1-T2 through P1-T6 acceptance |
| spec.md AC 9 | Provisional content authored per upstream-presence constraint and marked planned | Phase 1 shared constraint (d), P2-T2, P2-T5 |
| spec.md AC 10 | Reconciliation pass against the integration branch before the PR | P2-T5 |
| spec.md AC 11 | No collision with `code-modernization` plugin names | Phase 1 shared constraint (e), P2-T4 |
| user-story.md AC 1 | Engineer can author a domain profile from the doc set | P1-T3 |
| user-story.md AC 2 | Engineer can run the workflow via any surface; lockstep stated | P1-T5 |
| user-story.md AC 3 | Reader can identify the seven artifacts, validation, and gates | P1-T4 |
| user-story.md AC 4 | Onboarding path documented; TaskMaster/TMW strictly examples | P1-T6 |
| user-story.md AC 5 | Capability presented as domain-neutral throughout | Phase 1 shared constraints (a)-(b), P2-T3 |

## Test Plan

- Unit: none required — Markdown-only deliverable; no docs-lint convention exists
  (research section 2). Optional pytest content-contract test handled by P2-T6 with an
  authorized decline branch.
- Integration: none — no runtime behavior.
- Manual/deterministic checks: structural completeness (P2-T1), relative-link resolution
  (P2-T2), domain-neutrality grep with per-match classification (P2-T3), naming-collision
  grep (P2-T4), integration-branch reconciliation (P2-T5), end-state capture (P2-T7).
- Coverage evidence: not applicable — coverage policy applies to code; no code is in
  scope. If branch (a) of P2-T6 is taken, the pytest run evidence is stored under
  `docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/`.

## Open Questions / Notes

- All 13 upstream children are absent on the current branch; every documented
  `dev.discovery.*` command name, schema path, and pack decision is provisional until
  P2-T5 completes. The delivered spec supersedes planned scope wherever an upstream
  feature has landed on the integration branch at reconciliation time.
- Exact topic-page filenames may be adjusted at authoring time per spec.md ("Inputs /
  Outputs") provided the five coverage areas and the README index remain intact; any
  rename must be reflected in P2-T1's expected file list before execution.
