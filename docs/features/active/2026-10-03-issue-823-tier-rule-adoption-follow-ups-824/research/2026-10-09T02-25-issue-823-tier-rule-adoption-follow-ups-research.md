# Research: Issue #824 Addendum 2 (issue #823 follow-ups)

- Issue: #824 (Addendum 2 only)
- Branch: `bug/issue-823-tier-rule-adoption-follow-ups-824` (base `origin/main` e7d3779b)
- Date: 2026-10-09T02-25
- Scope: FU-823-1, FU-823-2, FU-823-3, FU-823-5, review note A, review note B, follow-ups record status marks.
- Out of scope: FU-823-4 (extension release); the main #824 bug and Addendum 1 (worktree-removal gates); `.claude/hooks/enforce-promotion-mcp-only.ps1`, `.claude/hooks/hook-command-invocation.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` and their `.codex/` copies; the KcovFunctionCoverageGate and shell-coverage workflow work.

All line numbers below were read from the worktree at the base commit. All counts were produced by Grep/Glob tool runs recorded in the Numeric Derivation Evidence section.

## 1. Current-State Inventory

### 1.1 FU-823-1: hard-coded thresholds in the feature-review coverage hook

`.claude/hooks/validate-feature-review-coverage.ps1` (460 lines):

- Line 29-30 (docstring): "When repo-wide coverage is below 80 percent for an available artifact, the policy audit must carry a FAIL verdict for that language." The code uses 85, so the docstring is wrong.
- Line 258-265: `Test-LanguageCoverageRow` takes `AuditText`, `Language`, `RepoWidePct`, `BranchPct`; there are no threshold parameters.
- Line 313: `if ($null -ne $RepoWidePct -and $RepoWidePct -lt 85.0)` (hard-coded line floor).
- Line 318: reason string literal "below the 85% line coverage floor".
- Line 323: `$BranchFloor = 75.0` (hard-coded branch floor).
- Line 327: reason string literal "below the 75% branch coverage floor".
- Line 430-439: `Invoke-FeatureReviewCoverageValidation` calls `Test-LanguageCoverageRow` per changed language. No `CLAUDE.md` read exists anywhere in the file.
- Line 449-451: dot-source guard (`if ($MyInvocation.InvocationName -eq '.') { return }`), so tests can dot-source the file.
- All artifact reads go through `Get-ArtifactFileContent` (line 41-63), with repository-relative paths (`artifacts/pr_context.summary.txt`, `artifacts/python/lcov.info`). The hook is registered as `pwsh -NoProfile -File .claude/hooks/validate-feature-review-coverage.ps1` (`.claude/settings.json:229`, `.claude/agents/feature-review.md:22`), so its working directory is the repository root and a relative `CLAUDE.md` read resolves to the root `CLAUDE.md`.

Bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`: the same content at lines 29, 313, 318, 323, 327 (Grep). Byte parity is enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`).

Related surface not in scope: `.codex/hooks/validate-feature-review-coverage.ps1` (and its bundle mirror) is a separate implementation with an 80 percent floor at lines 23-24, 195, 200, 280. Addendum 2 names only the `.claude` hook. The prior run recorded this as review advisory A4. Record it as a follow-up.

The repository's own root `CLAUDE.md` contains no occurrence of "coverage" (Grep, case-insensitive, zero matches). Once precedence applies, the hook keeps the 85/75 defaults in this repository, so behavior here does not change.

### 1.2 FU-823-2: TaskMaster / No-COM occurrences

Repository-wide Grep for `TaskMaster|No-COM` outside `docs/` found 128 occurrences across 46 files. Classification:

In-scope pushed surfaces (listed set) and their bundled mirrors:

| File | Lines |
|---|---|
| `.claude/rules/architecture-boundaries.md` | 5 (description "No-COM architecture"), 17 (heading "No-COM Architecture Rules"), 40-42 (`TaskMaster.Domain`, `TaskMaster.Application`) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md` | 5, 17, 40-42 (identical) |
| `.agents/skills/architecture-boundaries/SKILL.md` | 3, 19, 42-44 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md` | 3, 19, 42-44 (identical) |
| `.claude/skills/quota-throttling/SKILL.md` | 9 ("(TaskMaster runs") |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md` | 9 (identical) |

Pushed surfaces that name No-COM but are outside the Addendum 2 listed set (the prior run's review advisory A3):

| File | Lines |
|---|---|
| `.claude/rules/typescript.md` | 57 ("the No-COM architecture assertions are defined in `.claude/rules/architecture-boundaries.md`") |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md` | 57 |
| `.claude/rules/csharp.md` | 5 (description "(No-COM, xUnit)"), 10 ("No-COM .NET foundation") |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md` | 5, 10 |

`typescript.md:57` cites the architecture-boundaries assertions as "the No-COM architecture assertions". Once FU-823-2 renames that heading, the cross-reference wording no longer matches the heading. The meaning is still clear, and the maintainer decision limits FU-823-2 to the listed files. Record this as a follow-up rather than widening scope.

`TaskMaster.sln` surfaces (FU-823-3, section 1.3): `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.agents/skills/csharp/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, `.codex/codex-web-setup.sh`, and their mirrors.

Out of scope (tests, fixtures, README, historical data):
- `README.md:10, 331, 367, 369` ("No-COM" describing the modern C# ecosystem; not a pushed rule or skill).
- `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py:120` (token list in the #823 test).
- `tests/scripts/dev_tools/discovery/test_domain_neutrality.py:14` (disallowed-token regex).
- `tests/fixtures/orchestration-handoff/taskmaster-469/**` (historical handoff fixtures), `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py`, `orchestration_handoff_taskmaster_469_test_support.py`, `test_parallel_mergeable_cohort.py`, `test_validate_parallel_orchestrator_state_mergeable.py`, `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts:424`, and Pester hook test files (`enforce-epic-merge-gate.*`, `enforce-discovery-artifact-gate.Tests.ps1`, `hook-command-invocation.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, `validate-discovery-artifact-gate.Tests.ps1`, preimplementation-gate command-exemption tests), which use the name as fixture data.
- `docs/**` (historical feature records, including this feature's `issue.md`).

The substance of the architecture-boundaries rule names Outlook PIA, VSTO, Office.js, and Microsoft Graph. The maintainer decision is "neutralize names only", so those technology names stay and the FU-823-2 test must check only `TaskMaster` and `No-COM` (not `Outlook`, which the #823 test bans only in the tier rule).

### 1.3 FU-823-3: `TaskMaster.sln` occurrences

A Grep for `TaskMaster\.sln` over the whole repository found 28 files: 14 production surfaces, 2 test fixtures, and 12 `docs/**` records. The 14 production surfaces:

| File | Lines |
|---|---|
| `.github/instructions/csharp-code-change.instructions.md` | 41, 42, 50, 51 |
| `extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md` | 41, 42, 50, 51 |
| `.github/instructions/csharp-unit-test.instructions.md` | 46, 47 |
| `extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md` | 46, 47 |
| `.github/agents/csharp-typed-engineer.agent.md` | 173, 174 |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 173, 174 |
| `.agents/skills/csharp/SKILL.md` | 13, 14 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md` | 13, 14 |
| `.agents/skills/csharp-qa-gate/SKILL.md` | 31, 32 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md` | 31, 32 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md` | 18, 19 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | 33, 34 |
| `.codex/codex-web-setup.sh` | 10, 265, 285, 340, 341, 342 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` | 10, 265, 285, 340, 341, 342 |

Out of scope: `tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md` and `.../claude-to-codex/plan.2026-08-29T12-22.md` (historical fixtures), and `docs/**`.

### 1.4 FU-823-5: the 80/90 trigger in feature-review-workflow step 8

- `.claude/skills/feature-review-workflow/SKILL.md:149`: "coverage regression below policy threshold (< 80% repo-wide per language, < 80% or regression for modified files, or < 90% for new files)". Step 8 starts at line 143 (`8. **Trigger remediation when required**`) and step 9 at line 158 (`9. **Finalize the review**`).
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md:149`: identical.
- Step 5 (line 111) already carries the #823 precedence wording, with defaults at lines 112-114.

Out of scope (not named by FU-823-5; record as follow-up): `.agents/skills/feature-review-workflow/SKILL.md:101-103, 137` and its codex bundle mirror; `.github/skills/feature-review-workflow/SKILL.md:126` and its `customizations` mirror; `.codex/agents/feature-review.toml:121-123, 133-135` and its mirror. All of them still state 80/90.

### 1.5 Surfaces carrying the #823 precedence wording (review note A targets)

Precedence wording occurs in 12 production files (6 repository files and 6 bundled mirrors). No `.github/` or `.codex/` file carries it.

| File | Lines |
|---|---|
| `.claude/rules/quality-tiers.md` | 31 (precedence), 55 (rationale: "a root `CLAUDE.md` that states coverage thresholds overrides them") |
| `extensions/.../claude-customizations/.claude/rules/quality-tiers.md` | 31, 55 |
| `.claude/rules/general-unit-test.md` | 23 |
| `extensions/.../claude-customizations/.claude/rules/general-unit-test.md` | 23 |
| `.agents/skills/quality-tiers/SKILL.md` | 34 (AGENTS.md then CLAUDE.md precedence), 58 (rationale) |
| `extensions/.../codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` | 34, 58 |
| `.agents/skills/general-unit-test/SKILL.md` | 26 |
| `extensions/.../codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` | 26 |
| `.claude/agents/feature-review.md` | 119 |
| `extensions/.../claude-customizations/.claude/agents/feature-review.md` | 119 |
| `.claude/skills/feature-review-workflow/SKILL.md` | 111 |
| `extensions/.../claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | 111 |

After FU-823-1, the hook docstring (and its mirror) also carries precedence wording, so note A applies to it too: 14 copies in total.

Note A therefore requires edits to `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`. `CLAUDE.md` treats `.claude/rules/` as mirrors of canonical policy. The canonical `.github/instructions/general-unit-test.instructions.md` does not carry the precedence wording, so no canonical file is edited for note A. The PR body should state that note A changes `.claude/rules/` and `.agents/skills/` text only.

### 1.6 Review note B: current assertion

`tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` (464 lines):
- Line 136: `RETIRED_REVIEW_THRESHOLDS = ("80%", "90%")`.
- Line 137: `GOVERNING_THRESHOLD_FRAGMENT = "governing repo-wide threshold"`.
- Lines 385-398: `test_review_agent_copy_uses_governing_thresholds`, parametrized over `FEATURE_REVIEW_AGENT_COPIES` (`.claude/agents/feature-review.md` and its mirror). Line 393: `retired = [token for token in RETIRED_REVIEW_THRESHOLDS if token in text]` scans the whole file text, so any "80%" or "90%" anywhere in `feature-review.md` fails the test, including text unrelated to coverage.

## 2. Concrete `.agents-variants/csharp-legacy/` files containing `TaskMaster.sln`

No `.agents-variants/` directory exists at the repository root (Glob `**/.agents-variants/**` returns only bundle paths). The variant exists only in the bundle, which contains three files:

- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md` (contains `TaskMaster.sln`, lines 18-19)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` (contains `TaskMaster.sln`, lines 33-34)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md` (does not contain `TaskMaster.sln`; no edit)

The Claude legacy variant (`extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/`) already uses `<solution>.sln` and needs no edit.

Constraint: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:276-293` requires the two Codex variant files to keep `/t:Rebuild /m`, `"/p:Platform=Any CPU"`, `/p:TreatWarningsAsErrors=true`, and `#nullable enable`, and forbids `csharpier .`, `sln /t:Build`, and `/p:Platform="Any CPU"`. Replacing only the `TaskMaster.sln` token with `<solution>.sln` satisfies all of these.

## 3. Existing Solution-Neutral Convention

The repository's existing convention is the `<solution>.sln` placeholder:
- `README.md:383-384`: `msbuild <solution>.sln /t:Rebuild /m ...`.
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md:31-32` and `.claude-variants/csharp-legacy/rules/csharp.md:15-16`: `msbuild <solution>.sln ...`.

No `*.sln` glob form and no `Get-ChildItem *.sln` discovery appears in any documentation command. For the documentation surfaces (instructions, agent, skills, variants), replace `TaskMaster.sln` with `<solution>.sln` and change nothing else.

`.codex/codex-web-setup.sh` is executable, so a placeholder cannot replace its three runtime uses (line 10 root detection, line 265 `nuget restore`, line 285 `Invoke-VSBuild.ps1 -SolutionPath`). It needs runtime discovery of a `*.sln` at the repository root. Its printed notes (lines 340-342) are documentation and take the `<solution>.sln` placeholder. The sibling `.github/codex/codex-web-setup.sh` names no solution file and already ends with the source guard `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi` (line 332); `tests/shell/test_codex_web_setup_source_safety.bats:22` pins that guard. The `.codex` copy ends with an unconditional `main "$@"` (line 384), so sourcing it for tests would run `main`.

## 4. Bundled-Mirror and Parity Mechanics

| Repository surface | Bundle root | Enforcement |
|---|---|---|
| `.claude/**` | `extensions/drm-copilot/resources/claude-customizations/.claude/**` | Byte/text parity for every distributable repository `.claude` file: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`. |
| `.codex/**`, `.agents/**` | `extensions/drm-copilot/resources/codex-and-agents-customizations/` | Parity over `SCOPED_ROOTS = (.codex, .agents)`: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:35, 215`. Variants (`.agents-variants`, `.codex-variants`) are bundle-only (lines 38-39) and pinned by lines 276-382. |
| `.github/**` | `extensions/drm-copilot/resources/customizations/.github/**` | No generic parity test exists (Grep for `resources/customizations` in tests found only prompt and thinking-beast-mode checks). The mirrors are kept by convention. The new #824 test should pin both copies. |

Pack manifests:
- A new `.claude/hooks/*` file must be listed in a Claude pack manifest. `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139-159` (and its TypeScript twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`) fails for any bundled hook absent from every manifest. Add `.claude/hooks/feature-review-coverage-thresholds.ps1` to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, next to `.claude/hooks/validate-feature-review-coverage.ps1` (line 61) or in alphabetical position after `enforce-promotion-mcp-only.ps1` (line 54).
- The new helper is Claude-only. No `.codex/hooks` copy is needed (the `.codex` hook is a separate implementation), so `codex-and-agents-customizations/pack-manifests/core.json` is unchanged. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30` (`SharedModuleNames`) is unaffected.
- No content-hash or payload-hash file exists for bundled resources (a Grep for `sha256|contentHash|payload-hash` under `extensions/drm-copilot` found only orchestration-handoff and receipt code). Parity is enforced by the content-comparison tests above. When a bundled file changes, the only manifest edit needed is the `core.json` entry for the new helper.

## 5. How the Hook Is Tested Today, and Budget Constraints

- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` (122 lines, 4 `It` blocks): missing tokens, mismatched timestamps, a missing PASS/FAIL verdict, and allow with no changed languages. No test drives the 85/75 floors, the LCOV/JaCoCo parsers, the scope-narrowing rule, or the remediation-inputs checks.
- PoshQC coverage roots (`config/poshqc-coverage.json`): `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. A new `.claude/hooks/feature-review-coverage-thresholds.ps1` is measured automatically. Test scan folders (`config/poshqc-scan.json`): `scripts`, `tests/powershell`, `tests/scripts`, so new files under `tests/scripts/claude-hooks/` are discovered.
- `.claude/hooks/enforce-powershell-batch-budget.ps1` (lines 10-32): in direct mode, the fourth distinct production PowerShell path per session is denied (`POWERSHELL_LARGE_PATH_REQUIRED`). Test files (`tests/**/*.ps1`, `*.Tests.ps1`) never count. The budget does not apply when the checkpoint `artifacts/orchestration/orchestrator-state.json` selects route `large`, `remediation`, or `preparation` and is not terminal. Addendum 2 writes four production PowerShell paths: `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.claude/hooks/validate-feature-review-coverage.ps1`, and their two bundle mirrors. Issue #847 adds more PowerShell paths to the same hook. The run therefore needs a non-terminal large-route checkpoint before the first PowerShell write. A direct-mode session cannot complete FU-823-1.
- `.claude/hooks/enforce-python-batch-budget.ps1` (lines 10-32): the same rule for `.py`. Addendum 2 writes no production Python file (only `tests/**`), so the Python budget is not consumed.

## 6. Overlap With Other Items in the Same Run

- `.claude/hooks/validate-feature-review-coverage.ps1` (and its bundle mirror) is also changed by issue #847. FU-823-1 adds about 12 lines (460 to about 472). Combined growth must stay under 500 lines; this is one reason the resolver belongs in a separate helper file.
- `.claude/skills/feature-review-workflow/SKILL.md` (and its bundle mirror) is also changed by issue #841. FU-823-5 changes line 149 and note A changes line 111.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: if the main #824 bug work in the same branch adds `.claude/hooks/hook-command-raw-invocation.ps1` (the prior run did, at the adjacent line 55-56), the two entries are adjacent edits. Apply them in sequence to avoid a conflicting hunk.

## 7. Candidate Approaches and Recommendation

### FU-823-1 (threshold resolution)

Recommended: a pure resolver in a new dot-sourced helper, `.claude/hooks/feature-review-coverage-thresholds.ps1`, exposing `Get-FeatureReviewCoverageThreshold -ClaudeMdText <string>`. It returns `Line`, `Branch`, `LineSource`, `BranchSource`, resolves each metric independently, and defaults to 85/75. The hook reads `CLAUDE.md` through the existing `Get-ArtifactFileContent` seam (which tests already mock) and passes `-LineFloor`/`-BranchFloor` into `Test-LanguageCoverageRow`. The reason strings interpolate the governing figure.

Rationale: string parsing stays separate from I/O, so the resolver can be tested without disk access. The hook stays under the 500-line limit despite the concurrent #847 edits. Existing callers keep working because the new parameters default to 85/75.

Rejected alternatives:
- Inline resolver in the hook: about 40 additional lines push the hook toward 500, given the concurrent #847 changes.
- Reading thresholds from `.claude/rules/quality-tiers.md`: the precedence makes root `CLAUDE.md` govern; the rule file holds the defaults, not consumer figures.
- Reading `AGENTS.md` first: that precedence belongs to the Codex skill copies. The Claude hook follows the Claude rule (root `CLAUDE.md` only).

Resolver matching rule: the prior regex matches the first "line coverage ... N%" on a line with no comparator. Prior review CR-4 flagged this. Recommended adaptation: require a comparator or floor phrase between the metric name and the figure (for example `>=`, `≥`, `at least`, `minimum`, `no less than`, or a `:` followed by `>=`). Prose such as "line coverage was 62% last release" would then not be read as a threshold. Keep the 0-100 range check. Known limitation to document: a combined statement such as "line and branch coverage >= 70%" does not match either metric and falls back to the defaults. The fallback is the stricter direction.

### FU-823-3 (`.codex/codex-web-setup.sh`)

Recommended: the prior run's discovery design, minus one refactor:
- `list_root_solution_files <dir>` (`find "$1" -maxdepth 1 -type f -name '*.sln' -printf '%f\n'`).
- `select_solution_file <names>` (first name in `LC_ALL=C` order).
- `resolve_repo_root <script-relative-root> <names>` (fall back to `pwd` when no solution is listed, which preserves the existing `/tmp` copy behavior).
- `SOLUTION_FILE` global; `restore_packages_if_needed` warns and skips when it is empty; `verify_windows_visual_studio_task_capability` fails with a message when it is empty and passes `-SolutionPath "${SOLUTION_FILE}"`.
- `write_repo_notes` prints `<solution>.sln`.
- The final line becomes the `BASH_SOURCE` guard used by `.github/codex/codex-web-setup.sh:332`, so tests can source the file.

Rejected alternatives: hard-failing when no `.sln` exists (this would break setup in repositories with no solution file, where restore is already skipped when `packages/` is populated); keeping a fixed name behind a variable (still repository-specific).

## 8. Reuse Verdict for the Prior Patch (`origin/wip/preserve-824-addendum2-2026-10-08`)

Applicability was checked by comparing each hunk's context lines with the current file in the worktree. No Addendum 2 change has landed on main: Grep for `falls back independently`, `feature-review-coverage-thresholds`, `Get-FeatureReviewCoverageThreshold`, `Host-Neutral Architecture`, and `consumer-repository runs` returns no file, and none of the new test files exist.

| File | (a) Addendum 2 scope | (b) Applies cleanly to main | (c) Verdict | (d) Defects / notes |
|---|---|---|---|---|
| `.agents/skills/architecture-boundaries/SKILL.md` | Yes (FU-823-2) | Yes (lines 3, 19, 42-44 match) | Verbatim | None. `<Product>.Domain` placeholder; heading "Host-Neutral Architecture Rules". |
| `.agents/skills/csharp-qa-gate/SKILL.md` | Yes (FU-823-3) | Yes (31-32) | Verbatim | None. |
| `.agents/skills/csharp/SKILL.md` | Yes (FU-823-3) | Yes (13-14) | Verbatim | None. |
| `.agents/skills/general-unit-test/SKILL.md` | Yes (note A) | Yes (26) | Verbatim | Fallback sentence follows the AGENTS.md, CLAUDE.md, default chain. |
| `.agents/skills/quality-tiers/SKILL.md` | Yes (note A) | Yes (34, 58) | Verbatim | None. |
| `.claude/agents/feature-review.md` | Yes (note A) | Yes (119) | Verbatim | Adds no "80%"/"90%" text, so the #823 test stays green. |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` (new) | Yes (FU-823-1) | New file | Reuse with adaptation | No comparator requirement (CR-4); combined "line and branch" phrasing not matched. Add the comparator requirement and matching test rows. |
| `.claude/hooks/validate-feature-review-coverage.ps1` | Yes (FU-823-1) | Yes (hunks at 26, 37, 261, 310, 428 match lines 26-30, 37-39, 258-265, 313-330, 430-435) | Verbatim | Floor defaults (85/75) are duplicated in the helper and in `Test-LanguageCoverageRow` parameter defaults (minor). Docstring states the per-metric fallback (note A). Watch the #847 overlap. |
| `.claude/rules/architecture-boundaries.md` | Yes (FU-823-2) | Yes (5, 17, 40-42) | Verbatim | None. |
| `.claude/rules/general-unit-test.md` | Yes (note A) | Yes (23) | Verbatim | `CLAUDE_PRECEDENCE_FRAGMENTS` in the #823 test still match (the sentence is appended). |
| `.claude/rules/quality-tiers.md` | Yes (note A) | Yes (31, 55) | Verbatim | None. |
| `.claude/skills/feature-review-workflow/SKILL.md` | Yes (FU-823-5, note A) | Yes (111, 149) | Verbatim | Watch the #841 overlap. |
| `.claude/skills/quota-throttling/SKILL.md` | Yes (FU-823-2) | Yes (9) | Verbatim | Line wrapping is unchanged. |
| `.codex/codex-web-setup.sh` | Yes (FU-823-3), 73-line change | Yes (lines 1-15, 261-266, 282-298, 337-344, 381-384 match) | Reuse with adaptation | The change has five parts. Solution discovery functions and `SOLUTION_FILE` (FU-823-3, keep). Restore guard and `${SOLUTION_FILE}` (keep). Verify guard and `-SolutionPath "${SOLUTION_FILE}"` (keep). Notes placeholder (keep). Final-line `BASH_SOURCE` guard (keep; needed for testability). The patch also collapses the multi-line `vswhere`/`vstest` `pwsh -Command` block into two `local` string variables. That collapse is not required by FU-823-3 and no test depends on it; drop it. `find -printf` is GNU-specific, which is acceptable for Linux Codex Web and Git Bash; document it. |
| `.github/agents/csharp-typed-engineer.agent.md` | Yes (FU-823-3) | Yes (173-174) | Verbatim | None. |
| `.github/instructions/csharp-code-change.instructions.md` | Yes (FU-823-3, canonical, authorized) | Yes (41-42, 50-51) | Verbatim | `<solution>.sln` in the PowerShell variant is a placeholder, not literally executable (`<` is reserved in PowerShell). This matches the README convention. PR body callout required. |
| `.github/instructions/csharp-unit-test.instructions.md` | Yes (FU-823-3, canonical, authorized) | Yes (46-47) | Verbatim | PR body callout required. |
| `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` | Yes (status marks) | No: the file no longer exists at that path | Redo | Apply the same five `Status:` lines to `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md` (section 10). |
| `docs/features/potential/promoted/2026-10-03-promotion-hook-raw-containment-false-positive-deny.md` | No (main bug) | n/a | Do not apply | n/a |
| `extensions/.../claude-customizations/pack-manifests/core.json` | Partly | Yes (context lines 52-58 match lines 52-58) | Reuse with adaptation | Keep only the `.claude/hooks/feature-review-coverage-thresholds.ps1` entry; drop `.claude/hooks/hook-command-raw-invocation.ps1` (main bug). |
| `extensions/.../codex-and-agents-customizations/pack-manifests/core.json` | No (adds `hook-command-raw-invocation.ps1` only) | n/a | Do not apply | n/a |
| `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt` (new) | Yes (bats fixture for FU-823-3) | New | Verbatim | Write with LF line endings. |
| `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` (new) | Yes (FU-823-1) | New | Reuse with adaptation | Add rows for the comparator requirement (a prose figure with no comparator returns the default) and for the combined-phrase limitation. |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` (new) | Yes (FU-823-1 AC: lower figures F824-1, no figures F824-2, line-only F824-3; plus coverage-support cases) | New | Verbatim | Mocks the `'CLAUDE.md'` path consistently with the hook. F824-9 reads its own file through `$PSCommandPath`; no temporary file is created. |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (new) | Yes (FU-823-2, -3, -5, note A) | New | Reuse with adaptation | (1) Rename `FALLBACK_TOKEN` (for example to `FALLBACK_PHRASE`) and remove `# noqa: S105`. Ruff selects `S` (`pyproject.toml:100`), and the suppression is avoidable. (2) Add a scan of all pushed rule and skill files (`.claude/rules/*.md`, `.claude/skills/**/SKILL.md`, `.agents/skills/**/SKILL.md`, and their bundle copies) for `TaskMaster`/`No-COM`. The AC says "a test fails if those names reappear in pushed rule or skill files". Use an explicit pre-existing-exception set (`.claude/rules/typescript.md`, `.claude/rules/csharp.md`, and their two mirrors) and a staleness guard, following the `PRE_EXISTING_UNRELATED_EXCEPTIONS` pattern in `test_push_down_claude_pack_manifest_completeness.py:52-58, 162-177`. (3) `EXPECTED_LISTED_COPY_COUNT = 36` (6 + 14 + 2 + 14) matches section 11; recompute it if the lists change. |
| `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` | Yes (note B) | Yes (context at 15-20, 149-152, 390-400, 461-464 matches) | Verbatim, optional refinement | Adds 30 lines (464 to 494, under 500). `coverage_threshold_context` keeps blank-line-separated paragraphs that contain "coverage". Optional: also keep paragraphs containing "threshold", so a floor sentence without the word "coverage" is still scanned. |
| `tests/shell/test_codex_web_setup_codex_copy.bats` (new) | Yes (tests the FU-823-3 change) | New | Verbatim | Unaffected by dropping the `vswhere` refactor (C824-12 to C824-14 stub `pwsh`). It sources `.codex/codex-web-setup.sh` and relies on the new guard (C824-1). |
| Bundled mirrors of every repository file above | Yes | The export excludes them | Redo as byte copies | Regenerate each mirror from its repository source after the edit. The two Codex variant files have no repository source: edit them in place (token replacement only). |

Out of scope in the WIP branch (do not apply): `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.claude/hooks/hook-command-invocation.ps1`, `.claude/hooks/hook-command-raw-invocation.ps1`, their `.codex/` and bundle copies, `.github/workflows/_shell-coverage.yml`, `scripts/dev-tools/KcovFunctionCoverageGate.ps1` and its test, `tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1`, the trigger-scoping and hook-command test files, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/**`.

## 9. Behavior Semantics

Threshold resolution (FU-823-1, note A):
- Root `CLAUDE.md` absent, or present with no matching statement: line 85, branch 75 (source `default`).
- Root `CLAUDE.md` states both figures: both govern (source `claude-md`), including figures lower than the defaults.
- It states only the line figure: line from `CLAUDE.md`, branch 75. It states only the branch figure: line 85, branch from `CLAUDE.md`.
- A figure outside 0-100 or non-numeric is ignored for that metric (default applies).
- Decision rule (unchanged apart from the floor values): when repo-wide line coverage is below the governing line threshold and no coverage row for that language carries FAIL, block. When branch coverage is below the governing branch threshold, block. Reason strings state the governing figure.
- Ordering: thresholds are resolved once per hook run, after the changed-language set is non-empty and before the per-language loop.

Per-metric fallback wording (note A): every precedence surface states that each metric falls back independently. The Claude copies say a stated threshold governs its metric and the default governs the other. The Codex skill copies say the next source in AGENTS.md, CLAUDE.md, default order governs the other.

Step 8 (FU-823-5): the trigger reads "coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines, or new files)", with no fixed figures.

## 10. Follow-Ups Record Location (status marks)

Findings:
- The record now exists only at `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`. A Glob for `docs/features/potential/**/*{823,824}*` returns nothing, and `docs/features/potential/promoted/` has no #823 follow-ups record.
- `.claude/skills/feature-promotion-lifecycle/SKILL.md:86` states that `new_active_feature_folder` copies a promoted source but moves a source resolved directly from `docs/features/potential/`. #824 is a pre-existing issue (adoption path, `.claude/skills/feature-promotion-lifecycle/SKILL.md:43-51`), so `potential_to_issue` was not run and no promoted record was expected. The move is documented behavior, not the #487 defect.
- The only `docs/features/potential/promoted/` convention is for records written by `potential_to_issue` (for example `docs/features/potential/promoted/2026-10-03-pushed-tier-rule-not-gated-on-adoption.md:5`, "Status: Promoted -> ..."). It does not apply to an adopted issue. `issue_adoption.potential_record` (`.claude/rules/orchestrator-state.md:246`) is required only when a `new_potential_*` tool is waived and is shape-validated only.

Recommendation:
- Write the status marks in the active `issue.md`: under each `## FU-823-n` heading add `Status: Resolved by #824.` for FU-823-1, -2, -3, -5 and `Status: Open (out of scope for #824; no release automation is run).` for FU-823-4. Keep the `- Work Mode: full-bug` marker (line 10) unchanged. Optionally update the header line 6 ("Status: Draft. Not promoted.") to record adoption by #824.
- Do not restore the potential file. Restoring it would create a second, divergent copy of the record, and no convention or validator requires it. Remaining risk: FU-823-4 stays visible only in an active folder that is archived when #824 completes. Mitigate by listing FU-823-4 in `spec.md` `## Rollout & Follow-up` and in the PR body. If the maintainer wants FU-823-4 in the potential backlog, create a new single-item potential entry as a separate follow-up action.

## 11. Numeric Derivation Evidence

The proposed acceptance-criterion counts and test constants are derived below.

- Numeric spec.md acceptance criterion: no production surface hard-codes `TaskMaster.sln`; the regression test pins 14 surfaces.

### N1: production surfaces naming TaskMaster.sln

- Complete Family: TaskMaster.sln
- Exhaustive Search Scope: entire repository working tree, all file types, with classification afterward (docs/** history and tests/** fixtures classified out of scope)
- Inclusion Rules: a file under .github/, .agents/, .codex/, or extensions/drm-copilot/resources/ that contains the literal TaskMaster.sln
- Exclusion Rules: docs/** feature records and research; tests/fixtures/orchestration-handoff/** historical fixtures
- Primary Search Strategy or Query Expression: Grep tool, regex TaskMaster\.sln (literal TaskMaster.sln), output_mode files_with_matches, path = repository root, no glob filter
- Primary Member Set: .github/instructions/csharp-code-change.instructions.md, extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md, .github/instructions/csharp-unit-test.instructions.md, extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md, .github/agents/csharp-typed-engineer.agent.md, extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md, .agents/skills/csharp/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md, .agents/skills/csharp-qa-gate/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md, .codex/codex-web-setup.sh, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh
- Primary Count: 14
- Cross-check Search Strategy or Query Expression: Grep tool, regex \.sln (every solution-file mention), output_mode content with line numbers, glob !docs/**; keep files whose matching lines contain TaskMaster.sln and drop tests/fixtures/**
- Cross-check Member Set: .github/agents/csharp-typed-engineer.agent.md, .codex/codex-web-setup.sh, .agents/skills/csharp-qa-gate/SKILL.md, .github/instructions/csharp-unit-test.instructions.md, .github/instructions/csharp-code-change.instructions.md, .agents/skills/csharp/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh, extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md, extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md, extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md
- Cross-check Count: 14
- Member-set Comparison: the normalized primary and cross-check member sets are equal (14 identical paths).

### N2: listed FU-823-2 files naming TaskMaster or No-COM

- Complete Family: TaskMaster, No-COM
- Exhaustive Search Scope: entire repository working tree, all file types; members restricted afterward to the FU-823-2 listed set
- Inclusion Rules: the files listed by FU-823-2 (architecture-boundaries rule and skill, quota-throttling skill) and their bundle copies that contain TaskMaster or No-COM
- Exclusion Rules: pushed files outside the listed set (.claude/rules/typescript.md, .claude/rules/csharp.md, mirrors), README.md, tests/**, docs/**
- Primary Search Strategy or Query Expression: Grep tool, regex TaskMaster|No-COM, output_mode count, glob !docs/**, path = repository root
- Primary Member Set: .claude/rules/architecture-boundaries.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md, .agents/skills/architecture-boundaries/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md, .claude/skills/quota-throttling/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: Grep tool, regex TaskMaster|No-COM, output_mode content with line numbers, glob {.claude,.agents,.github,.codex,extensions/drm-copilot/resources}/** (pushed roots only), then select listed-set paths
- Cross-check Member Set: .agents/skills/architecture-boundaries/SKILL.md, .claude/skills/quota-throttling/SKILL.md, .claude/rules/architecture-boundaries.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md
- Cross-check Count: 6
- Member-set Comparison: the normalized primary and cross-check member sets are equal (6 identical paths).

### N3: production surfaces carrying the precedence wording

- Complete Family: CLAUDE.md, AGENTS.md
- Exhaustive Search Scope: entire repository working tree excluding docs/** history; tests/** classified out
- Inclusion Rules: production rule, skill, or agent files whose text states the root CLAUDE.md or AGENTS.md threshold precedence
- Exclusion Rules: tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py (test fragments), docs/**
- Primary Search Strategy or Query Expression: Grep tool, regex threshold precedence|Threshold precedence, output_mode content, glob !docs/**; each hit inspected for root CLAUDE.md or root AGENTS.md wording
- Primary Member Set: .claude/rules/quality-tiers.md, .claude/rules/general-unit-test.md, .agents/skills/quality-tiers/SKILL.md, .agents/skills/general-unit-test/SKILL.md, .claude/agents/feature-review.md, .claude/skills/feature-review-workflow/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md
- Primary Count: 12
- Cross-check Search Strategy or Query Expression: Grep tool, regex root `(CLAUDE|AGENTS)\.md` states (matching root CLAUDE.md and root AGENTS.md statements), output_mode count, glob !docs/**; test file removed
- Cross-check Member Set: .agents/skills/quality-tiers/SKILL.md, .claude/skills/feature-review-workflow/SKILL.md, .agents/skills/general-unit-test/SKILL.md, .claude/rules/quality-tiers.md, .claude/rules/general-unit-test.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md, .claude/agents/feature-review.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md
- Cross-check Count: 12
- Member-set Comparison: the normalized primary and cross-check member sets are equal (12 identical paths). After FU-823-1, the hook and its mirror add 2 copies, giving 14 note-A copies.

## 12. Testing Implications

All tests follow Arrange-Act-Assert, create no temporary files, and use no clock or network.

- Pester (FU-823-1):
  - `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`: resolver rows for absent text, no figures, both figures lower than the defaults, line-only, branch-only, decimal, out of range, plus the recommended comparator rows.
  - `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`: hook cases for lower figures (F824-1), no figures (F824-2), and a line-only figure (F824-3), which are the three cases the AC names, plus coverage-support cases for the parsing and artifact-validation paths. Together with the existing suite, these let the modified hook and the new helper reach >= 85% line coverage.
  - Expect-fail evidence: against main, F824-1 and F824-3 fail (fixed 85 floor), and the resolver suite fails (file absent).
- Python (FU-823-2, -3, -5, note A, note B):
  - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` with the adaptations in section 8.
  - Edit `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` per note B, including the positive and negative unit test for `coverage_threshold_context`.
  - Expect-fail: the follow-ups module fails on main (names present, 80/90 present, no fallback sentence).
  - Parity and contract suites that must stay green: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_tier_rule_adoption_gate.py`; the Jest twin `claude-pack-manifest-completeness.test.ts`.
- Bash (FU-823-3): `tests/shell/test_codex_web_setup_codex_copy.bats` with the fixture `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt`. It runs under `bash scripts/bash/shell-qc.sh test --coverage` in `.github/workflows/_shell-coverage.yml:54-55`. `.codex/` is not a shell-qc discovery or kcov include root (`.claude/rules/shell.md:48, 66`), so kcov does not measure the changed lines. This is a pre-existing gap (prior review A2). Changing the shell-coverage workflow is out of scope. Run `bash -n` on both copies.
- Toolchain: Python (Black, Ruff, Pyright, pytest); TypeScript/Jest (no TypeScript change; run for the AC); PowerShell PoshQC format, analyze, and test with coverage. Record baseline and post-change coverage artifacts under the feature folder `evidence/`.

## 13. Complete List of Files the Implementation Writes

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

No content-hash file needs updating (section 4). `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` is not written.

## 14. Risks and Assumptions

- Concurrent edits: #847 (same hook) and #841 (same skill) can produce conflicting hunks and push the hook toward 500 lines. Mitigation: helper file; rebase each item onto the previous item's head; re-run the line count before commit.
- PowerShell batch budget: four production PowerShell paths. A direct-mode session is denied at the fourth. Assumption: the run holds a non-terminal large-route checkpoint (section 5).
- Resolver false reads: without a comparator requirement, descriptive prose in a consumer `CLAUDE.md` could lower the floor. Mitigation: the comparator adaptation and test rows. Residual: a combined "line and branch" statement falls back to the defaults (stricter direction).
- `<solution>.sln` is a placeholder and cannot be pasted into PowerShell or CMD as written. This follows the existing README and Claude-variant convention.
- Bash coverage of `.codex/codex-web-setup.sh` is not measured by kcov (pre-existing discovery-root gap). The bats tests verify behavior; coverage measurement is a follow-up.
- Local bash execution: an earlier operational note (not re-verified in this research) records that agent worktrees deny command text containing `bash`, `pwsh`, or `wsl`. bats results may therefore come from CI (`_shell-coverage.yml`) rather than a local run. Use `sh <file>` style invocations locally where permitted.
- PoshQC MCP summaries: an earlier operational note (not re-verified) records that MCP PoshQC results can omit tool output. Coverage figures in evidence should come from the produced `artifacts/pester/powershell-coverage.xml`, not from the MCP summary text.
- Mirrors maintained by hand: no generic `.github` bundle parity test exists. The new follow-ups test checks both copies for `TaskMaster.sln` absence only; byte drift between `.github` copies is not otherwise detected.
- Follow-ups to record (not in scope): `.codex/hooks/validate-feature-review-coverage.ps1` 80 percent floor (A4); 80/90 figures in `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, and `.codex/agents/feature-review.toml` (plus mirrors); No-COM in `.claude/rules/typescript.md:57` and `.claude/rules/csharp.md:5,10` (A3); `.codex/` outside shell-qc discovery (A2); FU-823-4 release.

## 15. Recommended Implementation Sequence

1. Phase 0: record the baseline (branch, SHA, PowerShell/Python coverage artifacts, line counts of the hook and the #823 test). Confirm the large-route checkpoint.
2. Regression tests first (expect-fail): add the Python follow-ups module, the note B edit with its unit test, both Pester files, and the bats file with its fixture. Record failing runs under `evidence/regression-testing/`.
3. FU-823-1: helper (with the comparator adaptation), hook edits and docstring, bundle mirrors of both, `core.json` entry.
4. FU-823-2: architecture-boundaries rule and skill, quota-throttling skill, mirrors.
5. FU-823-3: `.github/instructions` (canonical, authorized), `.github/agents`, `.agents` skills, the two Codex variants, `.codex/codex-web-setup.sh` (without the `vswhere` refactor), mirrors.
6. FU-823-5 and note A: step 8 trigger, fallback sentences on all 12 precedence surfaces (the hook docstring is done in step 3).
7. Follow-ups record: status marks in the active `issue.md`; FU-823-4 listed in `spec.md` Rollout & Follow-up.
8. Verification loop: Python (Black, Ruff, Pyright, pytest including parity suites), TypeScript (Prettier, ESLint, TSC, Jest), PowerShell (PoshQC format, analyze, test with coverage), `bash -n` on both script copies, and bats in CI. Restart from formatting on any change. Record final QA and coverage-comparison artifacts.
9. PR body callouts: canonical `.github/instructions/` edits authorized for FU-823-3 only; note A edits to `.claude/rules/`; FU-823-4 still open; the out-of-scope follow-ups list.

## Automation Feasibility

No human interaction is expected during execution.

- All maintainer decisions the work needs are recorded on issue #824, Addendum 2 (comment 5970141337, cited in the prior run's spec `artifacts/orchestration/wip824-spec.md:257-263`): FU-823-2 neutralizes names only; FU-823-3 generalizes, including the canonical `.github/instructions/` files, which the maintainer authorizes for this item only. FU-823-4 is explicitly out of scope.
- Every change is a text or script edit with a deterministic test. No external service, credential, release, or interactive tool is needed.
- The follow-ups record location is settled by repository convention (section 10), so no decision is pending.
- Conditions that could stop autonomous execution, none of which requires a human decision: the PowerShell batch budget, if the large-route checkpoint is missing (an orchestrator configuration step); local bash execution limits, under which bats verification comes from CI; and merge order with #847 and #841, resolved by sequencing.
