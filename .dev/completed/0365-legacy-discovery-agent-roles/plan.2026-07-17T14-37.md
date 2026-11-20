# legacy-discovery-agent-roles - Plan

- **Issue:** #365
- **Parent:** Epic `legacy-discovery-and-parity` (child feature #9007, Wave 1, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-37
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature (resolved from `issue.md` marker `- Work Mode: full-feature`)

## Requirements Sources

- `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/spec.md` (authoritative design and resolved specification decisions)
- `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/user-story.md` (acceptance-criteria source)
- `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/issue.md` (mode marker)
- `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/research/2026-07-17T15-45-legacy-discovery-agent-roles-research.md` (current-state conventions, verified non-colliding slugs, per-persona schema mapping)

For full-feature work mode, `spec.md` and `user-story.md` are both acceptance-criteria sources.

## Scope, Languages, and Toolchain Applicability

Deliverables:

- Four domain-neutral agent persona files under `.claude/agents/`:
  `legacy-parity-analyst.md`, `runtime-characterization-analyst.md`,
  `requirements-reconciler.md`, `migration-coverage-reviewer.md`.
- One PowerShell Pester structural test at
  `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`.

Languages in scope: PowerShell (the Pester structural test) and Markdown (the four persona
files). Markdown has no format, lint, type-check, or coverage toolchain in this repository.
The only executable quality toolchain applicable to this feature is PowerShell:
PoshQC format -> PSScriptAnalyzer -> Pester. There is no Python, TypeScript, or C# change in
this feature, so Python/TypeScript/C# baseline and QC command tasks are intentionally excluded.

Coverage gate applicability (explicit statement, per general-unit-test policy and
`.claude/rules/quality-tiers.md`): this feature adds no new executable production code. The four
persona files are Markdown (exempt from the 500-line limit and producing no line/branch
coverage), and the `.Tests.ps1` file is test infrastructure that is excluded from coverage
measurement per general-unit-test policy. Therefore the changed-file line/branch coverage gate
is legitimately N/A for this feature's changed files. The Pester structural test is the
acceptance-verification mechanism. Baseline and final Pester runs are still executed in coverage
mode to record the repository coverage headline as an audit reference, but no changed-file
coverage regression can arise because there are no changed executable production files.

Out of scope (must NOT appear as deliverables and must NOT be created by this feature):

- Discovery-workflow skills (feature #9008). No `skills:` field on any persona.
- Completion-gate validators (#9003) and `SubagentStop`/PreToolUse hooks (#9004). No `hooks:`
  field on any persona and no `settings.json` worker-matcher entry.
- Mirroring `.claude/` assets into
  `extensions/drm-copilot/resources/claude-customizations/` (feature #9012).

## Evidence Location Invariant

All evidence artifacts produced by this plan MUST be written under the canonical location
`docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/<kind>/`:

- Baseline evidence: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/baseline/`
- QA-gate evidence: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/qa-gates/`

Writing evidence under any `artifacts/` path (for example `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, or `artifacts/evidence/`) is a
policy violation. This clause is non-overridable. Each command-step artifact MUST include
`Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

## Frontmatter Contract (all four personas)

- `name`: the persona slug, equal to the file basename.
- `description`: one to three sentences stating the domain-neutral role and the write scope.
- `model`: `sonnet` (spec Decision 2).
- `tools`: exactly `Read`, `Grep`, `Glob`, `"Write(discovery/**)"` (spec Decision 1).
- `memory`: `project`.
- No `skills:` field (Decision 3). No `hooks:` field (Decision 4).

Each persona body must be fully domain-neutral and must explicitly name its consumed discovery
schema(s), its produced discovery artifact/schema, and the domain profile, plus the domain-
profile fields it consumes (per the spec Per-Persona Design section).

## Acceptance Criteria Map

Acceptance criteria consolidated from `spec.md` (## Acceptance Criteria) and `user-story.md`
(## Acceptance Criteria). Each AC maps to plan tasks and, where applicable, to a Pester
assertion in the structural test.

| AC ID | Criterion (source) | Plan tasks | Pester assertion |
|---|---|---|---|
| AC1 | Four personas exist under `.claude/agents/` with valid frontmatter (`name`, `description`, `model`, `tools`, `memory`) (spec AC1; user-story AC1) | P1-T1..P1-T4 | Assertion 1 (existence), Assertion 2 (frontmatter validity) |
| AC2 | `name` = slug = basename; `model` is `sonnet`; `tools` exactly `Read`, `Grep`, `Glob`, `"Write(discovery/**)"`; `memory` is `project` (spec AC2; user-story AC2) | P1-T1..P1-T4 | Assertion 3 (name=slug), Assertion 4 (model membership) |
| AC3 | No `skills:` field and no `hooks:` field on any persona (spec AC3; user-story AC2) | P1-T1..P1-T4, P1-T5 | Assertion 2 (frontmatter validity) enforces required fields; scope guard P1-T5 |
| AC4 | Four slugs do not collide with `code-modernization` plugin names or existing `.claude/agents/` basenames (spec AC4; user-story AC3) | P1-T1..P1-T4 | Assertion 5 (naming non-collision) |
| AC5 | Domain-neutral: banned-substring scan (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, `task management`) finds no match, case-insensitive (spec AC5; user-story AC4) | P1-T1..P1-T4 | Assertion 6 (banned-substring scan) |
| AC6 | Each persona body names its consumed schema(s), produced artifact/schema, and the domain profile (spec AC6; user-story AC5) | P1-T1..P1-T4 | Assertion 7 (AC4 body-content) |
| AC7 | Pester structural test exists at `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` with in-memory positive/negative fixtures covering all seven assertions, and passes (spec AC7; user-story AC6) | P2-T1..P2-T8, P3-T3 | Assertions 1-7 |
| AC8 | No skills (#9008), validators/hooks (#9003/#9004), or `resources/` mirror (#9012) added (spec AC8) | P1-T5, P3-T5 | n/a (scope verification) |

## Definition of Done (from spec)

- [x] Acceptance criteria documented and mapped to Pester assertions (this plan's AC map).
- [x] Persona definitions match acceptance criteria.
- [x] Pester structural test added and passing.
- [x] Edge cases and negative fixtures covered by the structural test.
- [x] Docs linked from the feature folder (spec and user-story present).
- [x] Toolchain pass completed for the changed files (format, lint, test).

---

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance and Baseline Capture

- [x] [P0-T1] Read the repository policy files in the mandated policy-compliance order and record a Phase 0 policy-read evidence artifact.
  - Order to read: (1) `CLAUDE.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) PowerShell rule `.claude/rules/powershell.md`; (5) `.claude/rules/quality-tiers.md`; (6) `.claude/rules/tonality.md`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and an explicit list of the files read. No policy file is modified.

- [x] [P0-T2] Capture the PowerShell formatting baseline before any change, using the PoshQC formatter check over the in-scope test directory `tests/scripts/claude-runtime/`.
  - Command: `mcp__drm-copilot__run_poshqc_format` (check/report mode; no file rewrite committed as a baseline change).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/baseline/format-baseline.md` exists and includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and count of files that would be reformatted).

- [x] [P0-T3] Capture the PSScriptAnalyzer (lint) baseline before any change.
  - Command: `mcp__drm-copilot__run_poshqc_analyze`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/baseline/analyze-baseline.md` exists and includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).

- [x] [P0-T4] Capture the Pester test baseline before any change, run in coverage mode to record the repository coverage headline as an audit reference.
  - Command: `mcp__drm-copilot__run_poshqc_test` using the repo config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, coverage enabled.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/baseline/pester-baseline.md` exists and includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric passed/failed counts and the numeric repository line and branch coverage headline. The artifact records that the changed-file coverage gate is N/A for this feature because no executable production files are changed.

### Phase 1 — Author the Four Domain-Neutral Persona Files

- [x] [P1-T1] Create `.claude/agents/legacy-parity-analyst.md` (Legacy Parity Analyst).
  - Frontmatter: `name: legacy-parity-analyst`; `description` (domain-neutral role + write scope); `model: sonnet`; `tools: [Read, Grep, Glob, "Write(discovery/**)"]`; `memory: project`. No `skills:` field. No `hooks:` field.
  - Body: domain-neutral; explicitly names schemas consumed (Feature Contract, Parity Matrix, Evidence Reference), schema produced/updated (Parity Matrix), the domain profile, and consumed domain-profile fields (`legacy_source`, `target`, `technology_stack`, `artifacts.root`). Body documents that the true artifact root is the runtime-configured `artifacts.root` from the domain profile (static default `discovery/`) and that exact-path enforcement is deferred to #9004 hooks.
  - Acceptance: file exists at `.claude/agents/legacy-parity-analyst.md`; `name` equals basename `legacy-parity-analyst`; contains no banned substring (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, `task management`, case-insensitive); file is under 500 lines (Markdown exemption noted, still kept minimal).

- [x] [P1-T2] Create `.claude/agents/runtime-characterization-analyst.md` (Runtime Characterization Analyst).
  - Frontmatter: same contract as P1-T1 with `name: runtime-characterization-analyst`.
  - Body: domain-neutral; explicitly names schemas consumed (Runtime Characterization Scenario, Evidence Reference, Feature Contract), schema produced/updated (Runtime Characterization Scenario), the domain profile, and consumed domain-profile fields (`legacy_source`, `technology_stack.legacy`, `artifacts.root`). Documents runtime-configured `artifacts.root` and deferred enforcement as in P1-T1.
  - Acceptance: file exists at `.claude/agents/runtime-characterization-analyst.md`; `name` equals basename; no banned substring; under 500 lines.

- [x] [P1-T3] Create `.claude/agents/requirements-reconciler.md` (Requirements Reconciler).
  - Frontmatter: same contract as P1-T1 with `name: requirements-reconciler`.
  - Body: domain-neutral; explicitly names schemas consumed (Unspecified Behavior Record, Evidence Reference, Feature Contract), schema produced/updated (Product Decision Record), the domain profile, and consumed domain-profile fields (`legacy_source`, `target`, `artifacts.root`). Documents runtime-configured `artifacts.root` and deferred enforcement as in P1-T1.
  - Acceptance: file exists at `.claude/agents/requirements-reconciler.md`; `name` equals basename; no banned substring; under 500 lines.

- [x] [P1-T4] Create `.claude/agents/migration-coverage-reviewer.md` (Migration Coverage Reviewer).
  - Frontmatter: same contract as P1-T1 with `name: migration-coverage-reviewer`.
  - Body: domain-neutral; explicitly names schemas consumed (Coverage Ledger, Feature Contract, Evidence Reference), schema produced/updated (Coverage Ledger review findings / updated review status), the domain profile, and consumed domain-profile fields (`legacy_source`, `technology_stack.legacy`, `artifacts.root` / `artifacts.conventions`). Documents runtime-configured `artifacts.root` and deferred enforcement as in P1-T1.
  - Acceptance: file exists at `.claude/agents/migration-coverage-reviewer.md`; `name` equals basename; no banned substring; under 500 lines.

- [x] [P1-T5] Verify implementation scope boundary: confirm no out-of-scope assets were created.
  - Acceptance: no `skills:` or `hooks:` frontmatter key appears in any of the four persona files; no new discovery skill file, validator, or hook was added; no file was added under `extensions/drm-copilot/resources/claude-customizations/`; no `settings.json` worker-matcher entry was added for the four personas. Record the confirmation for AC8 verification in Phase 3.

### Phase 2 — Author the PowerShell Pester Structural Test

- [x] [P2-T1] Create the test file scaffold at `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` with `Set-StrictMode -Version Latest`, a `BeforeAll` that resolves the repository root by walking up from `$PSScriptRoot` (CWD-independent, per `test-name-uniqueness.Tests.ps1` precedent), the four expected slugs, the `code-modernization` plugin name set, the banned-substring list, and reusable helper functions for frontmatter extraction (hand-rolled `---`-delimited regex convention) and the case-insensitive banned-substring scan.
  - Acceptance: file exists; helpers are defined in `BeforeAll`; the file parses without syntax error; file is under 500 lines.

- [x] [P2-T2] Add the in-memory positive and negative fixtures that exercise the helper functions independently of the repository files.
  - Positive fixture: a synthetic compliant persona string (valid frontmatter, `name` = slug, `model: sonnet`, correct `tools`, `memory: project`, domain-neutral body naming schemas and the domain profile).
  - Negative fixtures: (a) a synthetic persona containing a banned substring; (b) a synthetic persona whose slug collides with a plugin/agent name; (c) a synthetic persona body missing the required schema/profile references.
  - Acceptance: fixtures are declared as in-memory string variables (no temporary files created, per general-unit-test policy); `It` names avoid case-only collisions per the `test-name-uniqueness` precedent.

- [x] [P2-T3] Add assertion 1 (existence): assert each of the four `.claude/agents/<slug>.md` files exists via `Test-Path -PathType Leaf`, enumerated over the four expected slugs.
  - Acceptance: the assertion block is present and passes against the four real persona files (AC1).

- [x] [P2-T4] Add assertion 2 (frontmatter validity): for each real file, extract the `---`-delimited frontmatter block and assert presence of `name:`, `description:`, `model:`, `tools:`, and `memory:`. Exercise the extraction helper with the positive fixture (present) and a negative fixture (missing field).
  - Acceptance: the assertion block is present and passes for the four real files; the negative fixture is detected as invalid (AC1, AC3).

- [x] [P2-T5] Add assertion 3 (name equals slug) and assertion 4 (model membership): assert each file's `name:` value equals the expected slug and the file basename, and assert `model:` is one of `haiku|sonnet|opus` (and specifically `sonnet` for these four).
  - Acceptance: the assertion blocks are present and pass for the four real files (AC2).

- [x] [P2-T6] Add assertion 5 (naming non-collision): assert the four slugs are disjoint from the `code-modernization` plugin name set (`legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`, `security-auditor`, `test-engineer`, `version-delta-analyst`) and from all other existing `.claude/agents/` basenames. Exercise with the colliding-slug negative fixture.
  - Acceptance: the assertion block is present and passes for the four real files; the colliding-slug fixture is detected (AC4).

- [x] [P2-T7] Add assertion 6 (domain-neutral banned-substring scan): for each real file's full text (frontmatter and body), assert no case-insensitive match against the banned-substring list (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, `task management`). Exercise the scan helper with the positive fixture (clean) and the banned-substring negative fixture (flagged).
  - Acceptance: the assertion block is present and passes for the four real files; the banned-substring fixture is detected as a failure (AC5).

- [x] [P2-T8] Add assertion 7 (AC4 body-content): assert each persona body explicitly names its consumed discovery schema(s), its produced discovery artifact/schema, and the domain profile, per the confirmed per-persona mapping. Exercise with the positive fixture (present) and the missing-references negative fixture (flagged).
  - Acceptance: the assertion block is present and passes for the four real files; the missing-references fixture is detected as a failure (AC6, AC7).

### Phase 3 — Final QC Loop (PowerShell)

Run the full PowerShell toolchain loop in order: format -> analyze -> test. If any step changes
files or fails, restart the loop from the format step until a single clean pass completes. Each
command-step task below is unconditional and must be executed and recorded; `SKIPPED` is not a
valid passing outcome.

- [x] [P3-T1] Run the PoshQC formatter over the changed PowerShell test file and confirm no formatting changes remain.
  - Command: `mcp__drm-copilot__run_poshqc_format`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/qa-gates/format-final.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass; zero files require reformatting). If files changed, restart the loop from this step.

- [x] [P3-T2] Run PSScriptAnalyzer over the changed PowerShell test file and confirm zero errors.
  - Command: `mcp__drm-copilot__run_poshqc_analyze`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/qa-gates/analyze-final.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (zero errors; warning count recorded). If any error is found, remediate and restart the loop from P3-T1.

- [x] [P3-T3] Run the Pester suite in coverage mode and confirm the new structural test passes with all seven assertions green.
  - Command: `mcp__drm-copilot__run_poshqc_test` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, coverage enabled.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/qa-gates/pester-final.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including numeric passed/failed counts, confirmation that `legacy-discovery-agent-roles.Tests.ps1` passed, and the numeric post-change repository line and branch coverage headline. The artifact restates that the changed-file coverage gate is N/A because no executable production files are changed.

- [x] [P3-T4] Confirm the final QC loop completed in a single clean pass (no step changed files or failed on the last iteration).
  - Acceptance: a note in `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/qa-gates/pester-final.md` (or a sibling `qc-loop-summary.md` under `evidence/qa-gates/`) records that format, analyze, and test all passed in the same iteration; the restart-on-change behavior was observed and satisfied.

- [x] [P3-T5] Verify acceptance-criteria closure and scope compliance for the audit record.
  - Acceptance: each AC in the Acceptance Criteria Map is confirmed satisfied by the referenced tasks and Pester assertions; AC8 confirmed (no #9008 skills, no #9003/#9004 validators/hooks, no #9012 `resources/` mirror added); coverage-gate N/A rationale is recorded. Record the closure summary under `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/qa-gates/`.

## Test Plan

- Unit / structural: `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` (Pester v5.x) — seven assertions with in-memory positive and negative fixtures (Phase 2), matching the seven assertions in `spec.md` (## Structural Test).
- Integration: none (no external system boundary introduced).
- Manual/CLI: none.
- Coverage evidence: baseline Pester coverage headline at
  `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/baseline/pester-baseline.md`;
  post-change Pester coverage headline at
  `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/evidence/qa-gates/pester-final.md`.
  Changed-file line/branch coverage gate is N/A for this feature because no executable
  production files are changed (all four persona files are Markdown; the `.Tests.ps1` file is
  test infrastructure excluded from coverage). No coverage regression on changed lines is
  possible.

## Open Questions / Notes

- Dependency folders for #9001 (domain-profile contract) and #9002 (seven schemas) are not
  present on the current integration tip. Persona bodies reference these contracts as summarized
  in `objective-source.md` section 4 and the research artifact; they do not depend on those
  folders existing at build time.
- The `.claude/` -> `extensions/drm-copilot/resources/claude-customizations/` mirror obligation
  is owned by downstream feature #9012 and is intentionally not performed here.
