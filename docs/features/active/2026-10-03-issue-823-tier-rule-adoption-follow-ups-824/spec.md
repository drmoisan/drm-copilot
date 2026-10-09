# issue-823-tier-rule-adoption-follow-ups (Spec)

- **Issue:** #824 (Addendum 2 only)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-09T02-40
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (`spec.md` is the sole acceptance-criteria source; no `user-story.md`)
- **Branch:** `bug/issue-823-tier-rule-adoption-follow-ups-824`
- **Inputs:** `issue.md` (the #823 follow-ups record), `research/2026-10-09T02-25-issue-823-tier-rule-adoption-follow-ups-research.md` (cited below as "research §n")

## Context

- Issue #823 introduced threshold precedence in the pushed tier and unit-test rules: a consuming repository's root `CLAUDE.md` coverage thresholds govern when present, and 85% line / 75% branch apply only when none are stated. Issue #823 also removed consumer-product names from the tier rule. Five follow-ups (FU-823-1 to FU-823-5) and two review notes (A, B) remained. Issue #824 Addendum 2 assigns FU-823-1, FU-823-2, FU-823-3, FU-823-5, note A, and note B to this work. FU-823-4 is out of scope.
- Observed environment(s): the repository runtime surfaces (`.claude/`, `.agents/`, `.codex/`, `.github/`) and the bundled push-down payload under `extensions/drm-copilot/resources/`, which consuming repositories receive.
- Customer impact and severity:
  - FU-823-1: a consuming repository whose root `CLAUDE.md` states lower thresholds still receives a blocking FAIL from `.claude/hooks/validate-feature-review-coverage.ps1`, because the hook hard-codes 85.0/75.0. The hook docstring states 80, which matches neither the code nor the policy.
  - FU-823-2: pushed rule and skill files name a specific consumer product (`TaskMaster`) and architecture label (`No-COM`), which do not apply to other consumers.
  - FU-823-3: pushed C# instructions, agents, skills, variants, and `.codex/codex-web-setup.sh` run `msbuild TaskMaster.sln`. In a consumer with a different solution name these commands cannot run.
  - FU-823-5: the feature-review workflow step 8 remediation trigger still states fixed 80/90 figures that contradict the governing thresholds in step 5.
  - Note A: the precedence wording does not define the result when the root `CLAUDE.md` states one metric but not the other.
  - Note B: the #823 regression test fails on any "80%" or "90%" anywhere in `feature-review.md`, including text unrelated to coverage.
- First observed: 2026-10-03 (issue #823 review and spec follow-ups F1-F4, plus FU-823-5 from planning).

## Repro & Evidence

- FU-823-1: research §1.1. `.claude/hooks/validate-feature-review-coverage.ps1` line 29-30 docstring states 80 percent; line 313 compares against `85.0`; line 323 sets `$BranchFloor = 75.0`; no `CLAUDE.md` read exists. Repro: place a root `CLAUDE.md` stating line coverage >= 70% in a consumer repository with 75% repo-wide line coverage and a PASS coverage row; the hook blocks. Expected: allow.
- FU-823-2: research §1.2. `TaskMaster`/`No-COM` appear in `.claude/rules/architecture-boundaries.md` (lines 5, 17, 40-42), `.agents/skills/architecture-boundaries/SKILL.md` (lines 3, 19, 42-44), `.claude/skills/quota-throttling/SKILL.md` (line 9), and their bundle mirrors.
- FU-823-3: research §1.3 and §2. `TaskMaster.sln` appears in the C# instructions, agent, skills, two bundle-only Codex variants, `.codex/codex-web-setup.sh`, and their mirrors (inventory and derivation evidence in research §1.3 and §11 N1).
- FU-823-5: research §1.4. `.claude/skills/feature-review-workflow/SKILL.md:149` and its bundle mirror state "< 80% ... < 90% for new files".
- Note A: research §1.5 lists the surfaces carrying the precedence wording (derivation evidence in research §11 N3). None defines the per-metric fallback.
- Note B: research §1.6. `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py:393` scans the full file text for `RETIRED_REVIEW_THRESHOLDS`.
- Frequency: deterministic for all items.

## Scope & Non-Goals

### In scope

- FU-823-1: threshold precedence in `.claude/hooks/validate-feature-review-coverage.ps1` (and its bundle mirror), docstring correction, Pester tests.
- FU-823-2 (maintainer decision: neutralize names only): replace `TaskMaster` / `No-COM` names and examples with neutral wording in `.claude/rules/architecture-boundaries.md`, `.agents/skills/architecture-boundaries/SKILL.md`, `.claude/skills/quota-throttling/SKILL.md`, and their bundle mirrors. Each rule's substance and push-down status remain unchanged.
- FU-823-3 (maintainer decision: generalize, including the canonical `.github/instructions/` files): replace `TaskMaster.sln` with the solution-neutral form in `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.agents/skills/csharp/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, the bundle-only `.agents-variants/csharp-legacy/**` files, `.codex/codex-web-setup.sh`, and every bundle mirror.
- FU-823-5: align step 8 of `.claude/skills/feature-review-workflow/SKILL.md` and its bundle mirror with the governing thresholds.
- Review note A: add the per-metric fallback wording to every surface carrying the precedence wording (research §1.5), plus the hook docstring after FU-823-1.
- Review note B: narrow the retired-threshold assertion in `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` to coverage-threshold context.
- Status marks in the follow-ups record (`issue.md` in this feature folder).

### Out of scope / non-goals

- FU-823-4 (extension rebuild, publish, and reinstall). It is performed separately after #824 merges.
- The main #824 bug and #824 Addendum 1 (worktree-removal gates). These belong to a separate, concurrently executing epic.
- Generalizing or withdrawing the architecture-boundaries rule substance (Outlook PIA, VSTO, Office.js, Microsoft Graph remain).
- The pre-existing out-of-scope surfaces listed under Rollout & Follow-up.

### Explicitly excluded files and work (hard exclusion)

The implementation must not modify:

- `.claude/hooks/enforce-promotion-mcp-only.ps1`
- `.claude/hooks/hook-command-invocation.ps1`
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
- `.claude/hooks/hook-command-raw-invocation.ps1`
- the `.codex/` copies and bundle mirrors of the five files above
- `scripts/dev-tools/KcovFunctionCoverageGate.ps1`, its tests, `.github/workflows/_shell-coverage.yml`, `tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1`, and any other shell-coverage workflow work
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/**`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`

Branch `bug/promotion-hook-raw-containment-false-positive-deny-824` is not used.

## Root Cause Analysis

- Confirmed root cause: issue #823 changed the pushed policy text (precedence, neutral naming in the tier rule) without changing the enforcement hook, the adjacent pushed rule and skill files, the C# toolchain commands, or the workflow step 8 trigger. Its precedence wording addressed the both-or-neither case only, and its regression test used a whole-file string scan.
- Supporting evidence: research §1.1-§1.6 (line-level inventory read from base commit e7d3779b).
- Affected components: `.claude/hooks/validate-feature-review-coverage.ps1`; `.claude/rules/{architecture-boundaries,general-unit-test,quality-tiers}.md`; `.claude/agents/feature-review.md`; `.claude/skills/{feature-review-workflow,quota-throttling}/SKILL.md`; `.agents/skills/{architecture-boundaries,csharp,csharp-qa-gate,general-unit-test,quality-tiers}/SKILL.md`; `.github/instructions/csharp-*.instructions.md`; `.github/agents/csharp-typed-engineer.agent.md`; `.codex/codex-web-setup.sh`; bundle mirrors under `extensions/drm-copilot/resources/`; `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.

## Proposed Fix

### Design summary (what changes where)

- FU-823-1: add a pure, dot-sourced resolver `.claude/hooks/feature-review-coverage-thresholds.ps1` exposing `Get-FeatureReviewCoverageThreshold -ClaudeMdText <string>`. It returns `Line`, `Branch`, `LineSource`, `BranchSource`, resolves each metric independently, and defaults to 85/75. The hook reads root `CLAUDE.md` through the existing `Get-ArtifactFileContent` seam, passes `-LineFloor` / `-BranchFloor` into `Test-LanguageCoverageRow` (parameter defaults 85/75), and interpolates the governing figure into its reason strings. The docstring is corrected to describe the precedence and the per-metric fallback.
- FU-823-2: rename the "No-COM Architecture Rules" heading to "Host-Neutral Architecture Rules", replace `TaskMaster.Domain` / `TaskMaster.Application` with a `<Product>.Domain` / `<Product>.Application` placeholder, and replace the quota-throttling line 9 product reference with neutral wording. Rule substance and pack-manifest membership are unchanged.
- FU-823-3: documentation surfaces replace `TaskMaster.sln` with `<solution>.sln` (the existing convention in `README.md:383-384` and the Claude legacy variant). `.codex/codex-web-setup.sh` gains runtime discovery of a root `*.sln` (functions `list_root_solution_files`, `select_solution_file`, `resolve_repo_root`, global `SOLUTION_FILE`); restore warns and skips when no solution exists; the Windows Visual Studio capability check fails with a message when no solution exists and otherwise passes `-SolutionPath "${SOLUTION_FILE}"`; printed notes use `<solution>.sln`; the final line becomes the `BASH_SOURCE` guard used by `.github/codex/codex-web-setup.sh:332`.
- FU-823-5: step 8 trigger reads "coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines, or new files)", with no fixed figures.
- Note A: append a per-metric fallback sentence to each precedence surface. Claude copies: a threshold stated in the root `CLAUDE.md` governs its metric, and the default governs each metric it omits. Codex skill copies: each metric falls back independently through the AGENTS.md, CLAUDE.md, default order.
- Note B: add a `coverage_threshold_context` helper to the #823 test that keeps only blank-line-separated paragraphs containing "coverage" (optionally also "threshold"), and apply the retired-figure scan to that context only, with a positive and a negative unit test for the helper.

### Boundaries and invariants to preserve

- Behavior in this repository does not change: the root `CLAUDE.md` states no coverage threshold (research §1.1), so the hook continues to apply 85/75.
- The hook decision rule is unchanged apart from the floor values: block when repo-wide line coverage is below the governing line threshold and no coverage row for that language carries FAIL; block when branch coverage is below the governing branch threshold.
- Bundle mirrors are byte copies of their repository sources; the two Codex variant files (bundle-only) receive token replacement only and keep the strings pinned by `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:276-293`.
- Production and test files stay under 500 lines, including after the concurrent #847 edits to the hook.
- No canonical `.github/instructions/` file other than the two C# instruction files is edited.

### Dependencies or blocked work

- Shared files with concurrent items in the same parallel run: `.claude/hooks/validate-feature-review-coverage.ps1` and its mirror (#847); `.claude/skills/feature-review-workflow/SKILL.md` and its mirror (#841). The scheduler serializes these items; each rebases onto the previous item's head.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` may receive an adjacent entry from other #824 work; apply entries in sequence.
- The PowerShell batch budget requires a non-terminal large-route orchestrator checkpoint before the first production PowerShell write (research §5).

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

See `## Files Written by the Implementation` for the complete list.

#### Functions/classes/CLI commands impacted

- New: `Get-FeatureReviewCoverageThreshold` (PowerShell, pure).
- Changed: `Test-LanguageCoverageRow` (new `-LineFloor`, `-BranchFloor` parameters with defaults 85.0/75.0), `Invoke-FeatureReviewCoverageValidation` (resolves thresholds once per run, after the changed-language set is non-empty and before the per-language loop).
- New bash functions in `.codex/codex-web-setup.sh`: `list_root_solution_files`, `select_solution_file`, `resolve_repo_root`; changed: `restore_packages_if_needed`, `verify_windows_visual_studio_task_capability`, `write_repo_notes`.
- New Python helper in the #823 test: `coverage_threshold_context`.

#### Data flow and validation changes

- Resolver matching: a figure is read only when a comparator or floor phrase appears between the metric name and the figure (for example `>=`, `≥`, `at least`, `minimum`, `no less than`, or `:` followed by `>=`). Prose such as "line coverage was 62% last release" is not read as a threshold. Figures outside 0-100 or non-numeric are ignored for that metric. A combined statement such as "line and branch coverage >= 70%" matches neither metric and falls back to the defaults (the stricter direction); this limitation is documented in the helper and covered by a test row.
- Resolution table (research §9): absent or no matching statement gives 85/75 (`default`); both stated gives both (`claude-md`), including lower figures; line-only gives stated line and 75 branch; branch-only gives 85 line and stated branch.

#### Error handling and logging updates

- A missing or unreadable root `CLAUDE.md` is treated as "no figures" (defaults apply); the hook does not fail open.
- Reason strings state the governing figure (for example "below the 70% line coverage floor").
- `.codex/codex-web-setup.sh`: restore emits a warning and skips when no solution exists; the Visual Studio capability check fails with an explicit message when no solution exists.

#### Rollback/feature-flag considerations

- No feature flag. Rollback is a revert of the PR. Consumers are unaffected until the extension is republished (FU-823-4).

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- `Get-FeatureReviewCoverageThreshold -ClaudeMdText <string>` returns an object with `Line` (double), `Branch` (double), `LineSource` and `BranchSource` (`claude-md` or `default`). `$null` or empty input returns the defaults.
- `.codex/codex-web-setup.sh` discovers solution files at the repository root only (`find "$1" -maxdepth 1 -type f -name '*.sln' -printf '%f\n'`) and selects the first name in `LC_ALL=C` order. `find -printf` is GNU-specific; this is acceptable for Linux Codex Web and Git Bash and is documented in the script.

#### Required configuration keys and defaults

- Defaults: line 85, branch 75. Source: root `CLAUDE.md` of the repository in which the hook runs (resolved relative to the hook's working directory, which is the repository root per `.claude/settings.json:229`).

#### Backward-compatibility expectations

- Existing callers of `Test-LanguageCoverageRow` keep working through the parameter defaults.
- The existing Pester suite `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` continues to pass unchanged.
- `<solution>.sln` is a placeholder in documentation commands and cannot be pasted into PowerShell or CMD as written; this matches the existing README and Claude-variant convention.

#### Performance constraints

- One additional small file read per hook run. No measurable latency change is expected.

## Reuse of Prior Work

The prior run's changes on `origin/wip/preserve-824-addendum2-2026-10-08` are adopted per research §8:

- Verbatim: `.agents/skills/architecture-boundaries/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, `.agents/skills/csharp/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/quality-tiers/SKILL.md`, `.claude/agents/feature-review.md`, `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/rules/architecture-boundaries.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/skills/feature-review-workflow/SKILL.md`, `.claude/skills/quota-throttling/SKILL.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`, `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt` (LF line endings), `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, `tests/shell/test_codex_web_setup_codex_copy.bats`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` (optional "threshold" paragraph refinement).
- With adaptation:
  - `.claude/hooks/feature-review-coverage-thresholds.ps1`: add the comparator requirement (prior review CR-4).
  - `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`: add rows for a prose figure with no comparator (returns the default) and for the combined-phrase limitation.
  - `.codex/codex-web-setup.sh`: keep solution discovery, restore guard, verify guard, notes placeholder, and the `BASH_SOURCE` guard; drop the unrelated collapse of the multi-line `vswhere`/`vstest` `pwsh -Command` block.
  - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: keep only the `.claude/hooks/feature-review-coverage-thresholds.ps1` entry; drop `.claude/hooks/hook-command-raw-invocation.ps1`.
  - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: rename `FALLBACK_TOKEN` (for example to `FALLBACK_PHRASE`) and remove the `# noqa: S105` suppression; add a scan of all pushed rule and skill files (`.claude/rules/*.md`, `.claude/skills/**/SKILL.md`, `.agents/skills/**/SKILL.md`, and their bundle copies) for `TaskMaster`/`No-COM`, with an explicit pre-existing-exception set (`.claude/rules/typescript.md`, `.claude/rules/csharp.md`, and their two mirrors) and a staleness guard following the `PRE_EXISTING_UNRELATED_EXCEPTIONS` pattern in `test_push_down_claude_pack_manifest_completeness.py`; recompute any listed-copy count constant from the final lists.
- Redo: status marks are written to this folder's `issue.md` (the prior target `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` no longer exists); all bundle mirrors are regenerated as byte copies of the edited repository sources.
- Do not apply: any WIP-branch change listed as out of scope in research §8 (main #824 bug, Addendum 1, shell-coverage work, `codex-and-agents-customizations/pack-manifests/core.json`).

## Assumptions, Constraints, Dependencies

### Assumptions

- A1: The follow-ups record is now this folder's `issue.md` (moved from `docs/features/potential/` by the documented adoption path, research §10). Status marks are written there: `Status: Resolved by #824.` under FU-823-1, -2, -3, -5 and `Status: Open (out of scope for #824; no release automation is run).` under FU-823-4. The potential file is not restored. The `- Work Mode: full-bug` marker is unchanged.
- A2: The solution-neutral form for documentation surfaces is `<solution>.sln`, the repository's existing convention (research §3). The executable `.codex/codex-web-setup.sh` uses runtime discovery of a root `*.sln`.
- A3: The hook reads only the root `CLAUDE.md` (Claude precedence). `AGENTS.md` precedence belongs to the Codex skill copies and is not applied by the Claude hook.
- A4: The run holds a non-terminal large-route orchestrator checkpoint before the first production PowerShell write (research §5).
- A5: Local bats execution may be denied in agent worktrees; bats results may come from CI (`_shell-coverage.yml`). `bash -n` (or an equivalent permitted syntax check) is run on both script copies.
- A6: Coverage figures in evidence come from produced coverage artifacts (for example `artifacts/pester/powershell-coverage.xml`), not from PoshQC MCP summary text.
- A7: No operator questions are pending; all maintainer decisions are recorded in issue #824 Addendum 2.

### Constraints

- Canonical policy edit authorization (this item only): `.claude/rules/architecture-boundaries.md`, `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`.
- Derived authorization: note A requires the fallback sentence in `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`, because they carry the precedence wording. This is derived from the addendum's instruction to apply the wording "in every surface that carries it". The canonical `.github/instructions/general-unit-test.instructions.md` does not carry the precedence wording and is not edited.
- The PR body must call out every `.claude/rules/` and `.github/instructions/` edit, and must reference #824 with "Refs #824". It must not use "Closes #824", "Fixes #824", or any other closing keyword for #824.
- File size limit of 500 lines for production and test files.
- Evidence artifacts are written under `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/<kind>/`.

### External dependencies

- None. No external service, credential, or release is required.

## Data / API / Config Impact

- User-facing change: consumers whose root `CLAUDE.md` states coverage thresholds receive feature-review hook verdicts against those thresholds (after FU-823-4 republishes the extension).
- Pushed text changes: neutral naming in architecture-boundaries and quota-throttling; `<solution>.sln` in C# commands; per-metric fallback sentence on precedence surfaces; step 8 trigger wording.
- New pushed hook helper listed in the Claude core pack manifest.
- No data migration. No configuration schema change.

## Test Strategy

- Regression tests (written first, expect-fail recorded under `evidence/regression-testing/`):
  - `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`: resolver rows for absent text, no figures, both figures lower than the defaults, line-only, branch-only, decimal, out-of-range, prose figure without a comparator, and the combined-phrase limitation. Fails on main (file absent).
  - `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`: hook cases F824-1 (root `CLAUDE.md` with lower figures allows a run the fixed floor would block), F824-2 (no figures: defaults 85/75 apply), F824-3 (line-only figure: stated line floor plus default branch floor), plus coverage-support cases for parsing and artifact validation. `CLAUDE.md` content is supplied by mocking `Get-ArtifactFileContent`; no temporary files. F824-1 and F824-3 fail on main.
  - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: listed-set and all-pushed-rule/skill scan for `TaskMaster`/`No-COM` (with exception set and staleness guard); absence of `TaskMaster.sln` in every FU-823-3 surface and mirror, including both `.github` copies; step 8 contains no fixed 80/90 figures and references the governing thresholds; the fallback phrase is present on every precedence surface, including the hook docstring and mirror. Fails on main.
  - `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`: note B edit with positive and negative unit tests for `coverage_threshold_context`.
  - `tests/shell/test_codex_web_setup_codex_copy.bats` with fixture `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt`: sourcing safety, solution discovery and selection order, no-solution restore skip, no-solution verify failure, `-SolutionPath` pass-through (with stubbed `pwsh`), and notes placeholder.
- Parity and contract suites that must stay green: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_tier_rule_adoption_gate.py`, and the Jest twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- Edge cases: missing `CLAUDE.md`; figures outside 0-100; non-numeric figures; decimal figures; branch-only statements; prose percentages without a comparator; combined statements; repository with no `.sln`; repository with several `.sln` files.
- Coverage: the new helper and the modified hook each reach >= 85% line coverage (PowerShell has no branch gate); no regression on changed lines. Baseline and post-change coverage artifacts are recorded under `evidence/`.
- Toolchain: Python (Black, Ruff, Pyright, pytest); TypeScript/Jest (Prettier, ESLint, TSC, Jest; no TypeScript source change); PowerShell (PoshQC format, analyze, test with coverage); `bash -n` on both `codex-web-setup.sh` copies; bats in CI. Restart from formatting on any failure or auto-fix.
- Manual validation: none required.

## Acceptance Criteria

- [ ] AC-1: FU-823-1 — `.claude/hooks/validate-feature-review-coverage.ps1` and its bundle mirror resolve the line and branch coverage thresholds by the #823 precedence: thresholds stated in the repository's root `CLAUDE.md` govern when present (including figures lower than the defaults), and 85% line / 75% branch apply only when none are stated. Each metric resolves independently, and reason strings state the governing figure. The resolver reads a figure only when a comparator or floor phrase links it to the metric.
- [ ] AC-2: FU-823-1 — Pester tests cover a root `CLAUDE.md` with lower figures, a root `CLAUDE.md` with no figures, and a root `CLAUDE.md` with a line-only figure, and they pass. The resolver has its own Pester tests, including a prose percentage without a comparator and the combined-phrase limitation.
- [ ] AC-3: FU-823-1 — the hook docstring (repository copy and bundle mirror) matches the behavior: it states the precedence, the 85/75 defaults, and the per-metric fallback, and no longer states 80 percent.
- [ ] AC-4: FU-823-2 — no pushed file in the listed set (`.claude/rules/architecture-boundaries.md`, `.agents/skills/architecture-boundaries/SKILL.md`, `.claude/skills/quota-throttling/SKILL.md`, and their bundled copies) names `TaskMaster` or `No-COM`. Each rule's substance and its push-down status (pack-manifest membership) are unchanged.
- [ ] AC-5: FU-823-2 — a test fails if `TaskMaster` or `No-COM` reappears in pushed rule or skill files (repository and bundled copies), with any pre-existing out-of-scope occurrences held in an explicit exception set guarded against staleness.
- [ ] AC-6: FU-823-3 — no surface hard-codes `TaskMaster.sln`: the listed C# instructions, agent, skills, `.agents-variants/csharp-legacy/**` variants, `.codex/codex-web-setup.sh`, and every bundled mirror use `<solution>.sln` (documentation) or runtime discovery of a root `*.sln` (`.codex/codex-web-setup.sh`).
- [ ] AC-7: FU-823-3 — a test fails if `TaskMaster.sln` reappears in any of those surfaces, including both `.github` copies.
- [ ] AC-8: FU-823-3 — the bundled-payload parity tests stay green (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness suites, and the Jest twin).
- [ ] AC-9: FU-823-5 — step 8 of `.claude/skills/feature-review-workflow/SKILL.md` and its bundled mirror refer to the governing thresholds, not fixed 80/90 figures.
- [ ] AC-10: Review note A — the per-metric fallback (the repository's figure governs each metric it states, and the default applies to each metric it omits) is stated wherever the precedence wording appears, including the `.claude/rules/`, `.agents/skills/`, `.claude/agents/feature-review.md`, and feature-review-workflow surfaces, the hook docstring, and every bundled mirror, and a test verifies its presence on each.
- [ ] AC-11: Review note B — `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` asserts the retired 80%/90% figures only within coverage-threshold context, and a unit test shows an unrelated percentage outside that context does not fail it.
- [ ] AC-12: The follow-ups record (`docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`) marks FU-823-1, FU-823-2, FU-823-3 and FU-823-5 as resolved by #824 and FU-823-4 as still open, and its `- Work Mode: full-bug` marker is unchanged.
- [ ] AC-13: The full toolchain passes (Python, TypeScript/Jest, and PowerShell format, analyze and test with coverage), with the new helper and modified hook at >= 85% line coverage and no coverage regression on changed lines.
- [ ] AC-14: No file in the hard-exclusion list (Scope & Non-Goals) is modified, and the `.codex/codex-web-setup.sh` change does not include the `vswhere`/`vstest` block refactor.
- [ ] AC-15: The PR references #824 with "Refs #824" and no closing keyword for #824, and its body calls out every `.claude/rules/` and `.github/instructions/` edit (including the FU-823-3 authorization for the canonical `.github/instructions/` files and the note A derivation for `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`), states that FU-823-4 remains open, and lists the out-of-scope follow-ups.

## Files Written by the Implementation

Production and policy surfaces (repository):

.claude/hooks/feature-review-coverage-thresholds.ps1
.claude/hooks/validate-feature-review-coverage.ps1
.claude/rules/architecture-boundaries.md
.claude/rules/general-unit-test.md
.claude/rules/quality-tiers.md
.claude/agents/feature-review.md
.claude/skills/feature-review-workflow/SKILL.md
.claude/skills/quota-throttling/SKILL.md
.agents/skills/architecture-boundaries/SKILL.md
.agents/skills/csharp/SKILL.md
.agents/skills/csharp-qa-gate/SKILL.md
.agents/skills/general-unit-test/SKILL.md
.agents/skills/quality-tiers/SKILL.md
.github/instructions/csharp-code-change.instructions.md
.github/instructions/csharp-unit-test.instructions.md
.github/agents/csharp-typed-engineer.agent.md
.codex/codex-web-setup.sh

Bundled mirrors and manifests:

extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh
extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md
extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md
extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md

Tests and fixtures:

tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1
tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
tests/shell/test_codex_web_setup_codex_copy.bats
tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt

Feature records:

docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md

No content-hash file needs updating. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` is not written. Evidence artifacts under this feature folder's `evidence/<kind>/` are produced in addition to the files above.

## Risks & Mitigations

- Concurrent edits with #847 (same hook) and #841 (same workflow skill) can produce conflicting hunks and push the hook toward 500 lines. Mitigation: resolver in a separate helper file; scheduler serialization; rebase onto the previous item's head; re-check line counts before commit.
- PowerShell batch budget denies the fourth production PowerShell path in direct mode. Mitigation: non-terminal large-route checkpoint (A4).
- Resolver false reads from descriptive prose in a consumer `CLAUDE.md`. Mitigation: comparator requirement and test rows. Residual: combined "line and branch" statements fall back to the defaults (stricter direction).
- `<solution>.sln` is a placeholder and is not directly executable; this follows the existing convention.
- Bundle mirrors under `extensions/drm-copilot/resources/customizations/.github/` have no generic parity test; byte drift between `.github` copies is not otherwise detected. The new test checks both copies for `TaskMaster.sln` absence.
- kcov does not measure `.codex/codex-web-setup.sh` (pre-existing discovery-root gap). The bats tests verify behavior.
- FU-823-4 remains visible only in an active folder that is archived when #824 completes. Mitigation: listed below and in the PR body.

## Rollout & Follow-up

- Release/rollout: merge via PR referencing "Refs #824" (not closing). Consumers receive the changes only after FU-823-4.
- Follow-ups (out of scope for this work; record in the PR body):
  - FU-823-4: rebuild, publish, and reinstall the extension to deliver the #823 and #824 Addendum 2 text; confirm on the next consumer push-down that `.claude/rules/quality-tiers.md` carries the adoption gate. Status: open.
  - `.codex/hooks/validate-feature-review-coverage.ps1` (and its bundle mirror) is a separate implementation with an 80 percent floor (prior review A4).
  - 80/90 figures remain in `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, `.codex/agents/feature-review.toml`, and their bundle mirrors.
  - `No-COM` remains in `.claude/rules/typescript.md:57` and `.claude/rules/csharp.md:5,10` and their bundle mirrors (prior review A3); after the heading rename, the `typescript.md` cross-reference wording no longer matches the architecture-boundaries heading.
  - `.codex/` is outside shell-qc discovery and kcov include roots, so `.codex/codex-web-setup.sh` coverage is not measured (prior review A2).
  - Optional: if the maintainer wants FU-823-4 in the potential backlog, create a new single-item potential entry.
- Links: issue #824 (Addendum 2), issue #823, research `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/research/2026-10-09T02-25-issue-823-tier-rule-adoption-follow-ups-research.md`, prior work branch `origin/wip/preserve-824-addendum2-2026-10-08`.
