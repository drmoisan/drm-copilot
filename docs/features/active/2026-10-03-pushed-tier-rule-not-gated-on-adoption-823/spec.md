# pushed-tier-rule-not-gated-on-adoption (Spec)

- **Issue:** #823
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-03T09-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this `spec.md` is the sole acceptance-criteria source)
- **Branch:** `bug/pushed-tier-rule-not-gated-on-adoption-823`
- **Research:** `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/research/research.2026-10-03.md`

## Context

The push-down sends the module rigor tier rule to consuming repositories that never adopted the tier system. Their agents are then bound to a `quality-tiers.yml` file and a `tier-classification` CI stage that do not exist, and they see two competing coverage-threshold authorities. This supersedes FU-734-4 in `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`. It differs from #621, whose destination exclusion manifest lets a repository opt out of a path but does not make the pushed rule text conditional.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `push_down_claude_customizations` into a consuming repository that has its own `CLAUDE.md` coverage thresholds and no `quality-tiers.yml`
- Data source or fixture: main at 93725814; pushed copies under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. Run the Claude push-down into a consuming repository that has no `quality-tiers.yml` and states its own coverage thresholds in its root `CLAUDE.md`.
2. Inspect `.claude/rules/quality-tiers.md`, `.claude/rules/general-code-change.md` ("Module Rigor Tiers") and `.claude/rules/general-unit-test.md` in that repository.
3. Run a feature review on any unrelated change in that repository.

Expected:
- A repository without `quality-tiers.yml` receives rule files that impose no tier classification, no tier-classification CI stage and no tier-dependent gates (mutation score, property-test density, golden tests).
- A repository with `quality-tiers.yml` keeps the current tier behavior unchanged.
- The pushed coverage rules state that the consuming repository's own root `CLAUDE.md` thresholds govern when present. The pushed 85/75 figures are the default only when the repository states none.
- Feature review flags a missing `quality-tiers.yml` only when the repository has adopted tiers.

Actual:
- `quality-tiers.md` states as fact that `quality-tiers.yml` maps every project to a tier and that an unclassified project fails CI.
- `general-code-change.md` states without condition: "Every project must be classified in `quality-tiers.yml` at repo root."
- `general-unit-test.md` and `quality-tiers.md` set uniform 85% line / 75% branch thresholds that contradict the consuming repository's `CLAUDE.md`, and no precedence is defined between them.
- Feature-review agents report the missing file as a finding on unrelated reviews.
- The consuming repository cannot fix any of this locally, because these files are push-down owned and are overwritten on the next push-down.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `Module rigor tiers (T1–T4) ... Every project must be classified in quality-tiers.yml at repo root.` (general-code-change.md line 29)

## Scope & Non-Goals

### In scope

Edit set: 8 repo-local files and their 8 byte-identical bundled mirrors (16 existing files; derivation in the research record, section "Numeric Derivation Evidence"), plus one new pytest module and one potential-item update.

| Repo-local file | Bundled mirror |
|---|---|
| `.claude/rules/quality-tiers.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md` |
| `.claude/rules/general-code-change.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md` |
| `.claude/rules/general-unit-test.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` |
| `.claude/agents/feature-review.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` |
| `.claude/skills/feature-review-workflow/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` |
| `.agents/skills/quality-tiers/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` |
| `.agents/skills/general-code-change/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md` |
| `.agents/skills/general-unit-test/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` |

Additional files:
- New: `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
- Updated: `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md` (FU-734-4 marked superseded by #823; FU-734-1 noted as resolved for the rewritten Codex sentences).

### Out of scope / non-goals

- `.github/instructions/*` and `.github/copilot-instructions.md`: not modified. They contain no tier wording, and no parity test couples them to `.claude/rules` (research section 8). The pre-existing 80/90 versus 85/75 difference between the Copilot canonical policy and `.claude/rules` is not changed here.
- Language rules and QA-gate skills that restate 85/75 (`.claude/rules/{python,powershell,typescript,csharp,shell}.md`, `.claude/skills/{python-qa-gate,powershell-qa-gate}/SKILL.md`, and mirrors): not edited; they are governed by the global precedence clause (Decision D4).
- Codex and Copilot feature-review surfaces (`.agents/skills/feature-review-workflow/SKILL.md`, `.codex/agents/feature-review.toml`, `.github/skills/feature-review-workflow/SKILL.md`, `.github/prompts/review-feature.prompt.md`): no tier reference; not edited.
- Push-down code (`scripts/dev_tools/push_down_*.py`, `extensions/drm-copilot/src/lib/push-down/**`), the #621 exclusion manifest, pack manifests, and `config/blast-radius.json`: not changed.
- `quality-tiers.yml`, `scripts/dev_tools/check_quality_tiers.py`, `scripts/dev_tools/quality_tiers_contract.py`, and the `tier-classification` CI step in `.github/workflows/_quality-checks.yml`: not changed.
- Other TaskMaster mentions (Decision D6): `.claude/rules/architecture-boundaries.md`, `.agents/skills/architecture-boundaries/SKILL.md`, `.claude/skills/quota-throttling/SKILL.md`, the `TaskMaster.sln` C# toolchain commands in `.github/instructions/csharp-*.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.agents/skills/{csharp,csharp-qa-gate}/SKILL.md`, the `.agents-variants/csharp-legacy/**` bundle variants, and `.codex/codex-web-setup.sh`, plus their mirrors.
- `.claude/hooks/validate-feature-review-coverage.ps1` hard-coded 85.0 / 75.0 floors (approximately lines 313-327) and its docstring reference to 80 (line 29).
- Extension rebuild, publish, and consumer reinstall.

### Explicitly excluded systems, integrations, or datasets

- `docs/**` historical feature artifacts other than the FU-734 potential item.
- Consumer repositories: no consuming repository is named in any pushed file, and no consumer-side verification is part of the acceptance path.

## Root Cause Analysis

- The rule text was written for this repository, which has adopted tiers (`quality-tiers.yml` exists at repo root; `_quality-checks.yml` lines 74-77 run `tier-classification`), and is pushed down verbatim. The Claude push-down copies `.claude/**` from the installed extension payload; `quality-tiers.md`, `general-code-change.md`, and `general-unit-test.md` are in `pack-manifests/core.json` and are pushed on every Claude route. The Codex copies are pushed in full-tree mode.
- The feature-review agent and skill do not mention `quality-tiers.yml`. The missing-file finding arises because reviewers apply `general-code-change.md` line 29 during the policy-compliance pass. The coverage sections of both review surfaces cite a "uniform tier rule" with no precedence for consumer thresholds.
- No precedence is defined between the pushed 85/75 figures and a consumer's root `CLAUDE.md`. Root `CLAUDE.md` is not pushed (no `CLAUDE.md` exists under `resources/`), so it is consumer-owned.
- Pushed `quality-tiers.md` (and its Codex conversion) carries TaskMaster / No-COM examples, which name a consuming product in a pushed file.
- Bundled payloads must be text-identical to repo-local sources (parity tests), so the gating text must land in this repository's own files. Because this repository has `quality-tiers.yml`, conditional wording leaves its behavior unchanged.

## Decisions

- **D1 - Gate by rule text, not by the #621 exclusion manifest.** `quality-tiers.md` states, before its first `## ` heading, that it applies only when `quality-tiers.yml` exists at the repository root; without that file there is no tier classification, no `tier-classification` CI stage, no tier-dependent gate, and the missing file is not a defect. Rationale: the `.push-down-exclusions` manifest is per-path (excluding `general-code-change.md` or `general-unit-test.md` to drop one section would drop the whole general policy), Claude-only (no Codex route), consumer opt-in (the default stays wrong until every non-adopting consumer authors a manifest), and does not address threshold precedence or feature-review guidance. Rule-text gating needs no code change and leaves this repository unchanged. No hard-coded repository list is used. Push-down-time templating and frontmatter `paths:` scoping are also rejected: templating violates requirement 5 and breaks byte parity; `paths:` gates on edited-file globs, not repository state, and `test_claude_rules_frontmatter.py` requires these rules to stay `paths: ["**"]`.
- **D2 - `general-code-change.md` "Module Rigor Tiers" section is conditional the same way.** The section states that tiers and the gate matrix apply only when `quality-tiers.yml` exists at the repository root, that in that case every project must be classified in it, and that a repository without the file has not adopted tiers. The unconditional sentence "Every project must be classified in `quality-tiers.yml` at repo root." is removed. Rationale: this sentence is the direct cause of the feature-review finding.
- **D3 - Coverage threshold precedence (Claude).** `general-unit-test.md` and `quality-tiers.md` state: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those govern; 85% line / 75% branch are defaults applied only when root `CLAUDE.md` states none; the precedence applies to every restatement of the figures in other rules, agents, and skills. Coverage defaults are independent of tier adoption, so they still apply in a non-adopting repository unless overridden. The phrase "in this repository" is removed from the threshold sentences. Rationale: root `CLAUDE.md` is consumer-owned and not pushed; this repository's root `CLAUDE.md` states no thresholds, so 85/75 continue to govern here.
- **D4 - Global precedence clause instead of editing each restatement.** Language rules and QA-gate skills that restate 85/75 are not edited. Rationale: the clause in D3 explicitly covers every restatement, which keeps the edit set at 16 files; editing each restatement would add 7 files plus 7 mirrors for a readability gain only. The trade-off is recorded under Risks.
- **D5 - Codex precedence anchor is root `AGENTS.md` or root `CLAUDE.md`.** The Codex copies (`.agents/skills/{quality-tiers,general-unit-test}/SKILL.md`) state that thresholds in the repository's root `AGENTS.md` govern, or those in root `CLAUDE.md` when `AGENTS.md` states none; 85/75 apply only when neither states thresholds. Rationale: Codex standing instructions live in `AGENTS.md`, while many repositories record thresholds only in `CLAUDE.md`; a defined order prevents a second ambiguity. Rewritten Codex sentences cite `.agents/skills/quality-tiers/SKILL.md`, not the non-existent `.agents/skills/quality-tiers.md`, which resolves FU-734-1 for those lines.
- **D6 - TaskMaster examples: replace in `quality-tiers.md` only.** The tier examples in `.claude/rules/quality-tiers.md` and `.agents/skills/quality-tiers/SKILL.md` (and mirrors) are replaced with neutral equivalents (for example: T1 classifiers and scoring engines, identifier allocators, authentication/token handling, command dispatch; T2 domain and application layers, DTOs, settings abstractions, schema definitions; T3 UI, third-party API/SDK wrappers, persistence I/O; T4 unchanged). Harm-model definitions stay verbatim. Rationale: requirement 5 forbids naming a consuming repository in pushed files, the file is already being rewritten, and the examples are illustrative only (`check_quality_tiers.py` and `quality_tiers_contract.py` classify by project path and do not read the Markdown). Other TaskMaster mentions are out of scope and become follow-ups because they are C# toolchain commands or consumer-architecture rules that need separate product decisions.
- **D7 - Feature-review guidance: adoption-gated finding and aligned thresholds.** `.claude/agents/feature-review.md` (Coverage Thresholds and Verification Procedure) and `.claude/skills/feature-review-workflow/SKILL.md` (coverage bullet) replace the "uniform tier rule" citation with the D3 precedence statement and add: report a missing or incomplete `quality-tiers.yml` only when the repository has adopted tiers (the file exists at the repository root on the resolved base branch, or the repository's CI runs a tier-classification check); otherwise record tier classification as not applicable, not as a finding. The Verification Procedure lines currently stating 80% repo-wide / 90% new-file / 80% modified-file are aligned to "the governing thresholds" so the agent no longer contradicts its own Coverage Thresholds section. Rationale: the contradiction predates #823 but sits in the same section being rewritten, and the SubagentStop hook already enforces 85/75, so 80/90 is not the effective behavior in this repository. Pinned phrases asserted by `test_orchestrator_state_remediation_docs.py`, `test_completion_gate_documentation_contracts.py`, and `claude-architecture-doc.Tests.ps1` are kept.
- **D8 - Canonical `.github/instructions/` files are not modified.** Rationale: they carry no tier wording, and parity forces no change; the CLAUDE.md prohibition on modifying them is not engaged.
- **D9 - Regression test placement.** A pytest module at `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, beside the existing content-contract tests over committed Markdown. Rationale: the subject is shipped rule text, not a `src/` module, and `tests/scripts/dev_tools/` is the established home for such tests.

## Proposed Fix

### Design summary (what changes where):

- `quality-tiers.md` (Claude and Codex): adoption-gate paragraph directly under the H1; classification and CI sentences rewritten as conditional ("When `quality-tiers.yml` exists, it maps every project to one tier; a repository that runs a `tier-classification` CI stage fails CI for an unclassified project."); threshold precedence statement in the "Uniform across all tiers" section and Rationale; "in this repository" removed; neutral tier examples.
- `general-code-change.md` (Claude and Codex): conditional "Module Rigor Tiers" section (D2).
- `general-unit-test.md` (Claude and Codex): precedence statement in Coverage Requirements; "in this repository" removed; Test Categories note that tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root.
- Feature-review agent and workflow skill (Claude only): D7.
- Bundled mirrors: byte-identical copies of each edited file, in the same commit.

### Boundaries and invariants to preserve:

- Each repo-local file and its bundled mirror remain byte-identical.
- `paths: ["**"]` frontmatter and a non-empty `description:` remain on the three Claude rules.
- This repository's tier behavior is unchanged: `quality-tiers.yml`, `check_quality_tiers`, and the CI step are untouched, and with `quality-tiers.yml` present the gated text reads as before.
- No consuming repository is named and no repository-specific templating is introduced in any pushed file.
- Phrases pinned by existing documentation-contract tests in `feature-review.md` and the workflow skill are not removed.

### Dependencies or blocked work:

- None blocking. Consumer delivery depends on an extension release (follow-up F4).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

See the In-scope table, plus the new test module and the FU-734 potential item.

#### Functions/classes/CLI commands impacted:

None. No production code changes.

#### Data flow and validation changes:

None at runtime. The new pytest module adds a static content check over committed rule text.

#### Error handling and logging updates:

Not applicable (Markdown edits only).

#### Rollback/feature-flag considerations (if applicable):

Revert the commit; no state or schema is involved.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Regression test reads, read-only and whitespace-normalized, the repo-local and bundled copies of the in-scope rule/skill files. It asserts:
1. The sentence "Every project must be classified in `quality-tiers.yml` at repo root." is absent from every scanned file.
2. "Adding a project without a tier classification fails CI." does not appear unconditionally.
3. `quality-tiers.md` (both surfaces) contains the adoption gate (`quality-tiers.yml` together with "applies only"/"only when") before its first `## ` heading.
4. The "Module Rigor Tiers" section of `general-code-change.md` (both surfaces) contains the adoption condition.
5. `general-unit-test.md` and `quality-tiers.md` (both surfaces) contain the precedence statement naming root `CLAUDE.md` (Claude) or root `AGENTS.md`/`CLAUDE.md` (Codex).
6. No scanned `quality-tiers` file contains "TaskMaster".
7. Negative control: the detection helper flags a synthetic string carrying the legacy sentence, proving the check can fail.

Section and file searches operate on normalized full text, not line-oriented greps, so a reflowed sentence is still detected.

#### Required configuration keys and defaults:

None.

#### Backward-compatibility expectations:

Adopting repositories (including this one) see no behavior change. Non-adopting repositories stop receiving tier obligations after they reinstall a release that includes this change.

#### Performance constraints (latency/throughput/memory):

Not applicable; the new test reads a small, fixed set of Markdown files.

## Assumptions, Constraints, Dependencies

- Assumptions: this repository's root `CLAUDE.md` states no coverage thresholds (verified by grep in research section 11), so 85/75 continue to govern here.
- Constraints: byte parity between repo-local and bundled copies; no temp files or external processes in tests; `.github/instructions/` not modified.
- External dependencies: extension release for consumer delivery (not part of acceptance).

## Data / API / Config Impact

- User-facing or API changes: pushed rule text for Claude and Codex consumers.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: no CLI, config schema, or manifest change.

## Test Strategy

- Regression tests to add: `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` covering assertions 1-7 above. Executed first against the unmodified text, where it must fail (expect-fail), then passes after the edits.
- Existing tests that must stay green: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`, `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, the pack-manifest completeness tests, and `tests/scripts/dev_tools/test_check_quality_tiers*` (if present) for this repository's tier enforcement.
- Edge cases: reflowed or line-wrapped legacy sentence (normalized search); legacy CI sentence appearing only inside the gated sentence (allowed); Codex surface using the `AGENTS.md`/`CLAUDE.md` anchor.
- Coverage: the new module is test code; no production lines change, so coverage of production code is unaffected.
- Toolchain: full Python loop (Black, Ruff, Pyright, pytest) plus the repository's full toolchain.

## Acceptance Criteria

- [x] AC1: `.claude/rules/quality-tiers.md` states, before its first `## ` heading, that the rule applies only when `quality-tiers.yml` exists at the repository root, and that without it there is no tier classification, no `tier-classification` CI stage, no tier-dependent gate, and the missing file is not a defect.
- [x] AC2: `.claude/rules/quality-tiers.md` contains no unconditional statement that `quality-tiers.yml` maps every project or that an unclassified project fails CI; both statements are conditional on the file existing, and the phrase "in this repository" no longer appears in it.
- [x] AC3: The "Module Rigor Tiers" section of `.claude/rules/general-code-change.md` makes tier classification conditional on `quality-tiers.yml` existing at the repository root, and the sentence "Every project must be classified in `quality-tiers.yml` at repo root." is absent.
- [x] AC4: `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` each state that root `CLAUDE.md` coverage thresholds govern when present, that 85% line / 75% branch apply only when root `CLAUDE.md` states none, and that this precedence applies to every restatement of those figures in other rules, agents, and skills.
- [x] AC5: The Test Categories section of `.claude/rules/general-unit-test.md` states that tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root, and the phrase "not used in this repository" no longer appears in the file.
- [x] AC6: `.agents/skills/quality-tiers/SKILL.md`, `.agents/skills/general-code-change/SKILL.md`, and `.agents/skills/general-unit-test/SKILL.md` carry the adoption gate, the conditional classification section, and the precedence statement anchored on root `AGENTS.md`, or root `CLAUDE.md` when `AGENTS.md` states none (Decision D5).
- [x] AC7: Every rewritten sentence in the three Codex skills cites `.agents/skills/quality-tiers/SKILL.md`; the non-existent path `.agents/skills/quality-tiers.md` no longer appears in any of them.
- [x] AC8: `.claude/rules/quality-tiers.md` and `.agents/skills/quality-tiers/SKILL.md` contain no occurrence of "TaskMaster", "No-COM", "SpamBayes", or "Outlook"; the T1-T4 harm-model definitions are unchanged.
- [x] AC9: `.claude/agents/feature-review.md` and `.claude/skills/feature-review-workflow/SKILL.md` replace the "uniform tier rule" coverage citation with the precedence statement, and instruct that a missing or incomplete `quality-tiers.yml` is a finding only when tiers have been adopted (file present at the repository root on the resolved base branch, or CI runs a tier-classification check) and is otherwise recorded as not applicable.
- [x] AC10: The Verification Procedure in `.claude/agents/feature-review.md` no longer states 80% or 90% thresholds; it refers to the governing thresholds defined in its Coverage Thresholds section.
- [x] AC11: Each of the 8 edited repo-local files is byte-identical to its bundled mirror under `extensions/drm-copilot/resources/`, and `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_codex_full_migration_inventory.py` pass.
- [x] AC12: `.claude/rules/quality-tiers.md`, `.claude/rules/general-code-change.md`, and `.claude/rules/general-unit-test.md` keep `paths: ["**"]` frontmatter and a non-empty `description:`, and `test_claude_rules_frontmatter.py` passes.
- [x] AC13: Phrases pinned by `test_orchestrator_state_remediation_docs.py`, `test_completion_gate_documentation_contracts.py`, and `claude-architecture-doc.Tests.ps1` remain in `feature-review.md` and the workflow skill, and those tests pass.
- [x] AC14: `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` exists, scans repo-local and bundled Claude and Codex copies, implements assertions 1-6 in "Inputs/outputs and formats", creates no temporary files, and starts no external process.
- [x] AC15: The regression module includes a negative-control test that feeds the detection helper a synthetic string containing the legacy sentence and asserts it is flagged; an expect-fail run of the module against the unmodified text is recorded before the rule edits.
- [x] AC16: Neither `.github/copilot-instructions.md` nor any file under `.github/instructions/` is modified on the branch.
- [x] AC17: No pushed file edited on the branch names a consuming repository or introduces repository-specific templating, and no push-down code, pack manifest, or exclusion-manifest code is modified.
- [x] AC18: `quality-tiers.yml`, `scripts/dev_tools/check_quality_tiers.py`, `scripts/dev_tools/quality_tiers_contract.py`, and the `tier-classification` step in `.github/workflows/_quality-checks.yml` are unmodified, and `check_quality_tiers` passes on this repository.
- [x] AC19: `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md` marks FU-734-4 as superseded by #823 and notes that FU-734-1 is resolved for the Codex sentences rewritten by #823.
- [x] AC20: The follow-ups in "Rollout & Follow-up" (F1-F4) are recorded in a potential item under `docs/features/potential/`.
- [x] AC21: The repository's full toolchain (format, lint, type check, architecture, unit tests, contract checks, integration tests) passes in a single pass with the changes applied.

## Risks & Mitigations

- Byte-parity drift: mitigated by editing each repo-local file and its mirror in the same commit and running the parity tests (AC11).
- Language rules and QA-gate skills still restate 85/75 literally; readers rely on the global precedence clause (D4). Mitigation: the clause names "every restatement" explicitly; expanding to per-file annotations remains available as a later change.
- `validate-feature-review-coverage.ps1` still enforces 85/75 floors, so a consumer whose `CLAUDE.md` sets lower thresholds will still see a FAIL verdict demanded by the hook. Mitigation: follow-up F1.
- Release lag: consumers receive the change only after rebuild, publish, and reinstall (follow-up F4).
- Wording reintroduction: mitigated by the regression module (AC14, AC15).

## Rollout & Follow-up

- Release/rollout steps: merge to `main`; consumer delivery through the existing extension release automation.
- Follow-ups (out of scope, record per AC20):
  - F1: `.claude/hooks/validate-feature-review-coverage.ps1` hard-codes 85.0 / 75.0 floors (approximately lines 313-327) and its docstring (line 29) says 80; the hook should honor the consumer's root `CLAUDE.md` thresholds under the D3 precedence.
  - F2: Remaining TaskMaster / No-COM mentions in pushed files: `.claude/rules/architecture-boundaries.md`, `.agents/skills/architecture-boundaries/SKILL.md`, `.claude/skills/quota-throttling/SKILL.md` line 9.
  - F3: `TaskMaster.sln` C# toolchain commands in `.github/instructions/csharp-*.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.agents/skills/{csharp,csharp-qa-gate}/SKILL.md`, `.agents-variants/csharp-legacy/**`, and `.codex/codex-web-setup.sh`.
  - F4: Extension republish so consumers receive the gated text.
- Post-fix monitoring: confirm on the next consumer push-down that `quality-tiers.md` carries the adoption gate.
- Links: issue #823; superseded item FU-734-4; related #621 (exclusion manifest), #734.
