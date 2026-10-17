# Research: pushed-tier-rule-not-gated-on-adoption (Issue #823)

- Issue: #823
- Branch: `bug/pushed-tier-rule-not-gated-on-adoption-823`
- Baseline: main at 93725814
- Date: 2026-10-03
- Supersedes: FU-734-4 in `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md` (lines 32-34)

All line numbers below were read from the worktree at the baseline. Bundled copies listed as byte-identical carry the same line numbers as their repo-local source.

## 1. Current State and Root Cause

The tier wording was authored for this repository, which has adopted tiers (`quality-tiers.yml` exists at repo root; `.github/workflows/_quality-checks.yml` lines 74-77 run the `tier-classification` step via `scripts.dev_tools.check_quality_tiers`). The Claude push-down copies `.claude/**` verbatim from the installed extension payload, so consumers receive the unconditional text.

The feature-review agent and skill do not themselves mention `quality-tiers.yml`. The missing-file finding arises because reviewers apply `general-code-change.md` line 29 ("Every project must be classified in `quality-tiers.yml` at repo root.") during the policy-compliance pass. Fixing the rule text removes the root cause; the feature-review guidance change adds an explicit guard.

## 2. Q1 - Complete Enumeration of Tier Wording (excluding `.claude/worktrees/`, `node_modules`, `dist`, `artifacts/`, `docs/`)

`docs/**` hits (archived/active feature artifacts, research, potential items) are historical records and are not edited.

### 2a. Repo-local runtime (`.claude/`)

| File | Lines | Content | Disposition |
|---|---|---|---|
| `.claude/rules/quality-tiers.md` | 4, 7, 9, 13-16, 20-21, 25, 27, 33-34, 43, 49, 51 | Description, H1 "Module Rigor Tiers", unconditional CI/classification statements (9, 21), TaskMaster/No-COM examples (13-15), 85/75 thresholds (33-34, 51), "in this repository" (51) | IN SCOPE |
| `.claude/rules/general-code-change.md` | 27, 29, 39 | "## Module Rigor Tiers"; line 29 unconditional "Every project must be classified in `quality-tiers.yml` at repo root."; line 39 "where applicable per `quality-tiers.md`" (already conditional) | IN SCOPE (27-29) |
| `.claude/rules/general-unit-test.md` | 23, 24, 26, 89, 91-96 | 85/75 "across all tiers (T1-T4)"; line 26 "not used in this repository"; line 89 tier-dependent test categories | IN SCOPE |
| `.claude/agents/feature-review.md` | 119-125 (thresholds), 137-139 (procedure uses 80/90, inconsistent with 121-123) | Coverage thresholds cite uniform tier rule | IN SCOPE |
| `.claude/skills/feature-review-workflow/SKILL.md` | 111-114 | Coverage thresholds "uniform tier rule per quality-tiers.md" | IN SCOPE |
| `.claude/rules/python.md` | 16, 88, 89 | 85/75 restated, cites quality-tiers.md | Covered by global precedence clause (see section 9) |
| `.claude/rules/powershell.md` | 63, 64 | 85% restated | Covered by global precedence clause |
| `.claude/rules/typescript.md` | 50, 62 | 85/75 restated; T1 mutation >= 75% | Covered by global precedence clause |
| `.claude/rules/csharp.md` | 10, 44, 45, 52 | 85/75 uniform; T1 mutation | Covered by global precedence clause |
| `.claude/rules/shell.md` | 69-70 | 85% line per quality-tiers.md | Covered by global precedence clause |
| `.claude/skills/python-qa-gate/SKILL.md` | 46 | 85/75 per uniform tier rule | Covered by global precedence clause |
| `.claude/skills/powershell-qa-gate/SKILL.md` | 45 | 85% per uniform tier rule | Covered by global precedence clause |
| `.claude/rules/architecture-boundaries.md` | 5, 10, 17-30, 40-42 | "uniform gate across all tiers"; No-COM rules; `TaskMaster.Domain`/`TaskMaster.Application` | OUT OF SCOPE (follow-up; scoped to `**/*.ts`, `**/*.cs`; whole file is consumer-architecture-specific) |
| `.claude/rules/parallel-orchestration.md` | 236, 258 | `quality-tiers.yml` as shared surface / mandate-read example | No obligation; no change |
| `.claude/skills/parallel-plan/SKILL.md` | 252 | `quality-tiers.yml` as shared-surface example | No obligation; no change |
| `.claude/skills/quota-throttling/SKILL.md` | 9 | "TaskMaster runs" provenance sentence | OUT OF SCOPE (follow-up for requirement 5 sweep) |
| `.claude/hooks/validate-feature-review-coverage.ps1` | 29 (docstring says 80), 313, 318 (85.0 floor), 323, 327 (75.0 floor) | Hard-coded floors | OUT OF SCOPE code; RISK (section 10) |

### 2b. Codex (`.agents/`, `.codex/`, `AGENTS.md`)

| File | Lines | Content | Disposition |
|---|---|---|---|
| `.agents/skills/quality-tiers/SKILL.md` | 3, 8, 10, 12, 16-19, 23-24, 28, 30, 36-37, 46, 52, 54 | Converted copy of the Claude rule ("Source: legacy Claude rule `quality-tiers`.") | IN SCOPE |
| `.agents/skills/general-code-change/SKILL.md` | 30, 32, 42 | Same unconditional sentence (32); cites non-existent `.agents/skills/quality-tiers.md` (FU-734-1) | IN SCOPE |
| `.agents/skills/general-unit-test/SKILL.md` | 26, 27, 29, 92, 94-99 | 85/75 across all tiers; line 29/92 cite non-existent `.agents/skills/quality-tiers.md` | IN SCOPE |
| `.agents/skills/architecture-boundaries/SKILL.md` | 12, 42-44 | TaskMaster layer names | OUT OF SCOPE (follow-up) |
| `.agents/skills/csharp/SKILL.md` | 13-14 | `msbuild TaskMaster.sln` | OUT OF SCOPE (C# toolchain; #469 territory) |
| `.agents/skills/csharp-qa-gate/SKILL.md` | 31-32 | `msbuild TaskMaster.sln` | OUT OF SCOPE |
| `.codex/codex-web-setup.sh` | 10, 265, 285, 340-342 | `TaskMaster.sln` | OUT OF SCOPE |
| `.agents/skills/feature-review-workflow/SKILL.md` | 101, 103, 137 | 80/90 thresholds; no tier reference | No change required |
| `.codex/agents/feature-review.toml` | 121, 123, 133-135 | 80/90 thresholds; no tier reference | No change required |
| `AGENTS.md` | - | No tier wording (toolchain loop only) | No change |

### 2c. Canonical Copilot policy (`.github/`)

Verified by grep: no `.github/instructions/*` or `.github/copilot-instructions.md` file contains "quality-tiers", "Module Rigor Tiers", "tier-classification", or 85/75 thresholds. `.github/instructions/general-unit-test.instructions.md` lines 39-40 state `>= 80%` repo-wide and `>= 90%` new code; `.github/skills/feature-review-workflow/SKILL.md` line 126 uses the same 80/90. There is no `quality-tiers.instructions.md`.

| File | Lines | Content | Disposition |
|---|---|---|---|
| `.github/instructions/csharp-code-change.instructions.md` | 41-42, 50-51 | `msbuild TaskMaster.sln` | OUT OF SCOPE |
| `.github/instructions/csharp-unit-test.instructions.md` | 46-47 | `msbuild TaskMaster.sln` | OUT OF SCOPE |
| `.github/agents/csharp-typed-engineer.agent.md` | 173-174 | `msbuild TaskMaster.sln` | OUT OF SCOPE |
| `.github/workflows/_quality-checks.yml` | 74-77 | `tier-classification` step (this repo's enforcement) | Unchanged |

### 2d. Bundled payloads (`extensions/drm-copilot/resources/`)

Byte-identical mirrors of every in-scope file in 2a/2b exist:

- `resources/claude-customizations/.claude/rules/{quality-tiers,general-code-change,general-unit-test}.md`
- `resources/claude-customizations/.claude/agents/feature-review.md`
- `resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`
- `resources/codex-and-agents-customizations/.agents/skills/{quality-tiers,general-code-change,general-unit-test}/SKILL.md`

Also present (mirrors of out-of-scope rows): claude `rules/{python,powershell,typescript,csharp,shell,architecture-boundaries,parallel-orchestration}.md`, `skills/{python-qa-gate,powershell-qa-gate,parallel-plan,quota-throttling}/SKILL.md`, `hooks/validate-feature-review-coverage.ps1`; codex `.agents/skills/{architecture-boundaries,csharp,csharp-qa-gate}/SKILL.md`, `.agents-variants/csharp-legacy/skills/{csharp,csharp-qa-gate}/SKILL.md` (TaskMaster.sln, bundle-only), `.codex/codex-web-setup.sh`; copilot `resources/customizations/.github/instructions/csharp-*.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`. Bundle-only JSON: `resources/claude-customizations/pack-manifests/core.json` lines 70, 71, 74 list the three rule paths (paths only, no hashes); `resources/claude-customizations/config/blast-radius.json` lines 9, 18 list `quality-tiers.yml` (harmless when absent).

### 2e. Others (repo-local, not pushed)

`quality-tiers.yml` line 1; `config/blast-radius.json` lines 11, 26; `scripts/dev_tools/check_quality_tiers.py`, `quality_tiers_contract.py`, `_blast_radius_normalization.py` line 70, `check_python_coverage_thresholds.py` lines 10, 62; `README.md` line 29; blast-radius tests and fixtures (`quality-tiers.yml` as a path token). None assert on rule wording; none change.

## 3. Q2 - Mirrors and Parity Enforcement

| Repo-local | Bundled mirror | Parity test | Mode |
|---|---|---|---|
| `.claude/**` (all in-scope Claude files) | `resources/claude-customizations/.claude/**` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 118-143) | Text equality (`read_text` UTF-8) for every `.claude` file except `settings.local.json` and `agent-memory/**` |
| `.agents/**`, `.codex/**` | `resources/codex-and-agents-customizations/...` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (lines 215-228); `tests/scripts/dev_tools/test_codex_full_migration_inventory.py::test_all_repo_agent_skills_are_bundled_and_identical` (line 83) | Text equality |
| `.claude/rules/*` vs `.agents/skills/*` | none | No test enforces Claude-to-Codex content parity; the Codex copies are a one-time conversion | Free to differ |
| `.github/**` | `resources/customizations/.github/**` | not exercised here (no in-scope `.github` change) | - |

Conclusion: no push-down-specific variant mechanism exists for these files (the only variant subtrees are the C# legacy ones). The bundled copy must equal the repo-local copy, so the gating text must land in this repository's own `.claude/rules`, `.claude/agents`, `.claude/skills`, and `.agents/skills` files. Because this repository has `quality-tiers.yml`, conditional wording produces unchanged behavior here.

Jest tests under `extensions/drm-copilot/test/lib/push-down/` use in-memory fixtures and do not compare repo and bundle content.

## 4. Q3 / Q7 - Push-down Mechanics and the #621 Exclusion Manifest

- Claude push-down: Python `scripts/dev_tools/push_down_claude_customizations.py` (`ROOT_FOLDERS = (.claude, config)` line 145; verbatim copy via `_passthrough_rewrite` line 183; `packs=None` publishes the full tree, lines 225-228). TypeScript `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` lines 169-196 source from `bundledSourceRoot(extensionRoot, "resources/claude-customizations")`, i.e. the installed extension payload. `quality-tiers.md`, `general-code-change.md`, `general-unit-test.md` are in `pack-manifests/core.json`, so they are pushed on every Claude route (full or pack-scoped).
- Codex push-down: `scripts/dev_tools/push_down_codex_and_agents_customizations.py` lines 256-261 publish the full tree when no packs are selected. `.agents/skills/{quality-tiers,general-code-change,general-unit-test}/SKILL.md` are in no Codex pack manifest (listed as pre-existing exceptions in `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` lines 108, 109, 118), so they are pushed in full-tree mode only.
- Copilot push-down: serves `resources/customizations/.github/**`. No tier wording exists there; there is no Copilot equivalent of `quality-tiers.md`.
- Root `CLAUDE.md` is not pushed (no `CLAUDE.md` exists under `resources/`), so a consumer's root `CLAUDE.md` is consumer-owned and is a valid precedence anchor.

#621 exclusion manifest: `scripts/dev_tools/push_down_exclusion_manifest.py` (pure grammar/matcher; manifest path `.push-down-exclusions` at destination root, line 56) and `scripts/dev_tools/push_down_claude_exclusion_filter.py` (outermost filesystem decorator; matched paths are withheld; a matched path present at the destination is reported as "push-down exclusion conflict: destination file present, not overwritten", lines 283-286; nothing is deleted). It is Claude-only (no exclusion code in the Codex or Copilot push-down modules).

Why rule-text gating is preferred:
1. The manifest is per-path. Excluding `general-code-change.md` or `general-unit-test.md` to drop one section would also drop the entire general policy. Only `quality-tiers.md` is cleanly excludable.
2. It requires every non-adopting consumer to author `.push-down-exclusions`; the default remains wrong.
3. It does not cover the Codex route.
4. It does not address threshold precedence or feature-review guidance.
5. Rule-text gating needs no code change and keeps this repository's behavior unchanged.

Validation note: a repository-side `resources/` edit does not change what an installed extension pushes until the extension is rebuilt and reinstalled; end-to-end confirmation in a consumer requires a release.

## 5. Q4 - Feature-review Guidance

- `.claude/agents/feature-review.md` lines 117-127: thresholds "follow the uniform tier rule (Authoritative Decision #2) defined in `.claude/rules/quality-tiers.md`" with 85/75; line 125 "Tier-specific lower thresholds are not used." Lines 137-139 (Verification Procedure) still use 80% repo-wide / 90% new-file, which contradicts 121-123. No mention of `quality-tiers.yml`.
- `.claude/skills/feature-review-workflow/SKILL.md` lines 111-114: same 85/75 "uniform tier rule per quality-tiers.md". No mention of `quality-tiers.yml`.
- Codex (`.agents/skills/feature-review-workflow/SKILL.md`, `.codex/agents/feature-review.toml`) and Copilot (`.github/skills/feature-review-workflow/SKILL.md`, `.github/prompts/review-feature.prompt.md`) use 80/90 and do not reference tiers. No change required for issue #823.
- No policy-audit template, `policy-audit-template-usage` skill, or MCP template references `quality-tiers` (grep over `.claude/`, `extensions/`, `mcp-server/src` returned no template hit).

## 6. Q5 - Tests That Assert on Current Wording

| Test | Assertion | Impact |
|---|---|---|
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` lines 45-52, 351-401 | `quality-tiers.md`, `general-code-change.md`, `general-unit-test.md` must stay unconditional (`paths: ["**"]`) and carry non-empty `description:` | Keep `paths: - "**"`; any description edit must stay non-empty |
| `test_push_down_claude_resource_contracts.py` lines 118-143 | Repo and bundle `.claude/**` text-equal | Edit both copies in the same commit |
| `test_push_down_codex_and_agents_resource_contracts.py` lines 215-228; `test_codex_full_migration_inventory.py` line 83 | Repo and bundle `.agents/**` text-equal | Edit both copies in the same commit |
| `test_push_down_claude_pack_manifest_completeness.py`, `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | Bundle files listed in a manifest | No file added or removed; unaffected |
| `test_push_down_codex_and_agents_pack_manifest_completeness.py` lines 108-118 | Exception set names the three Codex skills | Unaffected (paths unchanged) |
| `test_orchestrator_state_remediation_docs.py` (line 37, 47), `test_completion_gate_documentation_contracts.py` (line 36), `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` lines 61-66 | Pin unrelated phrases in `feature-review.md` / workflow skill (remediation, completion gate, version folder) | Additive edits do not affect them; do not remove those phrases |
| Exclusion-manifest tests (`test_push_down_exclusion_manifest.py`, `test_push_down_claude_exclusion_filter.py`, `push-down-service-call.test.ts`, `claude-exclusion-manifest.test.ts`, `mcp-tools.push-down-claude.test.ts` line 109, `repo-automation-command-registration-admin.test.ts` line 233) | Use `.claude/rules/quality-tiers.md` as a path string only | Unaffected (path unchanged) |

Verified absent: no test pins "must be classified", "Every project", "Authoritative Decision", "across all tiers", "Tier-specific", "uniform tier", "No-COM", "SpamBayes", or the rule H1 text (grep over `tests/**`, `extensions/drm-copilot/test/**`, `mcp-server/**`). No hash/pin manifest covers these files. The 500-line limit does not apply to Markdown (`general-code-change.md` line 50).

## 7. Q6 - Regression Test Placement

- Language: Python (pytest). The closest analogues are content-contract tests over committed Markdown in `tests/scripts/dev_tools/`: `test_claude_rules_frontmatter.py` (reads committed rule text, `normalize_whitespace` helper lines 117-132 to survive reflow) and `test_push_down_claude_resource_contracts.py` (reads the bundled payload). Neither mirrors a `src/` file because the subject is shipped rule text, so the established home is `tests/scripts/dev_tools/`.
- Proposed file: `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
- Subject: the bundled payload files (the push-down output, because the Claude push-down copies `.claude/**` verbatim) plus the repo-local copies, for both `resources/claude-customizations/.claude/rules/` and `resources/codex-and-agents-customizations/.agents/skills/`.
- Assertions (whitespace-normalized):
  1. The legacy unconditional sentence "Every project must be classified in `quality-tiers.yml` at repo root." is absent from every scanned file.
  2. The legacy sentence "Adding a project without a tier classification fails CI." does not appear unconditionally (absent, or only inside the adoption-gated sentence).
  3. `quality-tiers.md` contains the adoption gate (`quality-tiers.yml` + "only when"/"applies only") before its first `## ` heading.
  4. The `## Module Rigor Tiers` section of `general-code-change.md` contains the adoption condition.
  5. `general-unit-test.md` and `quality-tiers.md` contain the `CLAUDE.md` precedence statement.
  6. No scanned tier file contains "TaskMaster" (if the genericization decision in section 9 is adopted).
  7. Negative control: the detection helper flags a synthetic string carrying the legacy sentence (repo convention, see `test_push_down_claude_parity.py` lines 298-323), proving the check can fail.
- Constraints: read-only access to committed files; no temp files; no external processes. Expected to fail before the fix (current text contains the sentence), satisfying plan Phase 2 `[expect-fail]`.
- Use a full-section or full-file normalized search, not a line-oriented grep (a wrapped phrase would make a line grep return zero).

## 8. Q8 - Canonical `.github/instructions/` Files Forced by Parity

None. No `.github/instructions/*` file or `.github/copilot-instructions.md` carries tier wording, and no test couples `.claude/rules` content to `.github/instructions` content. The CLAUDE.md prohibition on modifying `.github/instructions/` is therefore not engaged. The `TaskMaster.sln` occurrences in `.github/instructions/csharp-*.instructions.md` are C# toolchain commands, not tier wording, and remain out of scope.

Pre-existing inconsistency (not changed here): Copilot canonical policy states 80/90 while `.claude/rules` states 85/75.

## 9. Recommendation

### Selected approach: adoption-gated rule text plus a global threshold-precedence clause

Edit set (8 repo-local files + 8 byte-identical bundled mirrors = 16 files; see Numeric Derivation Evidence), plus one new test file. No production code changes.

Proposed wording (planner may refine; keep the semantics):

- `quality-tiers.md`, new paragraph directly under the H1 (or an `## Applicability` section placed first):
  "This rule applies only to a repository that has adopted module rigor tiers, indicated by a `quality-tiers.yml` file at the repository root. When that file is absent, the tier classification requirement, the `tier-classification` CI stage, and every tier-dependent gate below (escape-hatch limits, property-test density, mutation score, contract-bump rule, determinism retry rate, golden tests, E2E scope) do not apply, and the absence of `quality-tiers.yml` is not a defect."
  Rewrite line 9 and line 21 so the classification and CI statements are conditional ("When `quality-tiers.yml` exists, it maps every project to one tier; a repository that runs a `tier-classification` CI stage fails CI for an unclassified project."). Remove "in this repository" (lines 9, 51).
- Threshold precedence (in `quality-tiers.md` "Uniform across all tiers" section and Rationale, and in `general-unit-test.md` "Coverage Requirements"):
  "Threshold precedence: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern. The 85% line and 75% branch figures are defaults that apply only when the root `CLAUDE.md` states none. This precedence applies to every restatement of these figures in other rule files, agents, and skills."
  The last sentence covers `python.md`, `powershell.md`, `typescript.md`, `csharp.md`, `shell.md`, and the two QA-gate skills without editing them. Uniform coverage is independent of tier adoption, so the default still applies in a non-adopting repository unless overridden.
- `general-code-change.md` lines 27-29:
  "Module rigor tiers (T1-T4) and the gate matrix are defined in `.claude/rules/quality-tiers.md` and apply only when `quality-tiers.yml` exists at the repository root; in that case every project must be classified in it. A repository without `quality-tiers.yml` has not adopted tiers, and the tier requirements do not apply."
- `general-unit-test.md` line 26: drop "in this repository"; line 89: add "(tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root)".
- `feature-review.md` (Coverage Thresholds section) and `feature-review-workflow/SKILL.md` (step 5 coverage bullet): replace "uniform tier rule" with the precedence statement, and add: "Report a missing or incomplete `quality-tiers.yml` only when the repository has adopted tiers: the file exists on the resolved base branch (so the branch removes it) or the repository's CI runs a tier-classification check. Otherwise record tier classification as not applicable; it is not a finding." Recommended: align `feature-review.md` lines 137-139 to "the governing thresholds" so the section no longer contradicts itself.
- Codex copies (`.agents/skills/quality-tiers`, `general-code-change`, `general-unit-test`): same edits. Precedence anchor for Codex: recommend "the repository's root `AGENTS.md` or `CLAUDE.md`" because Codex standing instructions live in `AGENTS.md` (planner decision). Because the rewritten sentences are new text, cite `.agents/skills/quality-tiers/SKILL.md` rather than the non-existent `.agents/skills/quality-tiers.md`; this resolves FU-734-1 for the edited lines (general-code-change line 32, general-unit-test lines 29 and 92).

### TaskMaster examples: in scope for `quality-tiers.md` only

Decision: genericize the examples in `quality-tiers.md` lines 13-15 (Claude) and `.agents/skills/quality-tiers/SKILL.md` lines 16-18 (Codex), plus bundles. Requirement 5 forbids naming a consuming repository in pushed files, the file is already being rewritten, and the examples are illustrative only (`check_quality_tiers.py` and `quality_tiers_contract.py` classify by project path and do not read the Markdown), so this repository's behavior is unchanged. Replace `TaskMaster.Domain`/`TaskMaster.Application`, "No-COM architecture", SpamBayes/Triage, ToDo ID allocator, and Outlook task pane with neutral equivalents (for example: T1 classifiers and scoring engines, identifier allocators, authentication/token handling, command dispatch; T2 domain and application layers, DTOs, settings abstractions, schema definitions; T3 UI, third-party API/SDK wrappers, persistence I/O; T4 unchanged). Keep the harm-model definitions verbatim.

Out of scope, record as follow-ups: `architecture-boundaries.md` (TaskMaster layer names and No-COM rules; the file is consumer-architecture-specific and needs a product decision), `quota-throttling/SKILL.md` line 9, and the `TaskMaster.sln` C# toolchain commands (Copilot instructions, Codex skills, legacy variants, `codex-web-setup.sh`).

### Rejected alternatives

- #621 exclusion manifest for `quality-tiers.md`: per-path, opt-in per consumer, Claude-only, cannot gate a section of `general-code-change.md`/`general-unit-test.md`, and leaves the default wrong (section 4).
- Push-down-time templating/variant subtree: violates requirement 5 (no repository-specific templating) and adds a second content source that the byte-parity tests would have to special-case.
- Frontmatter `paths:` scoping: `paths` gates by edited-file glob, not by repository state; `test_claude_rules_frontmatter.py` also requires these three rules to stay unconditional.

## 10. Risks

- Byte parity: every repo-local edit must be mirrored to the bundle in the same commit or the two parity tests fail.
- `validate-feature-review-coverage.ps1` (lines 313-327) hard-codes the 85/75 floors as a SubagentStop gate. In a consumer whose `CLAUDE.md` sets lower thresholds, the hook still demands a FAIL verdict. Rule-text precedence does not change this. Recommend a follow-up potential item (the hook would need to read thresholds from the consumer's `CLAUDE.md`); note the hook docstring line 29 also says 80.
- Language rules restating 85/75 remain literally unconditional; reliance on the global precedence sentence is a readability trade-off. If the planner prefers explicitness, append "(default; see threshold precedence in `general-unit-test.md`)" to each restatement, which expands the edit set by 7 files plus 7 mirrors.
- Release lag: consumers receive the change only after the extension is rebuilt, published, and reinstalled.
- `quality-tiers.md` `description:` currently reads "Module rigor tier system and uniform coverage thresholds." If changed, it must stay non-empty.
- FU-734-4 supersession: update `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md` to mark FU-734-4 superseded by #823 (and FU-734-1 partially resolved if the citation fix is adopted).

## 11. Testing Implications

- New regression module (section 7), expect-fail first, then pass.
- Existing parity tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_full_migration_inventory.py`) and `test_claude_rules_frontmatter.py` must stay green.
- Python toolchain loop applies (Black, Ruff, Pyright, pytest with coverage) for the new test file. No TypeScript/PowerShell/C# production change, so those coverage comparisons are not triggered by this edit set.
- This repository's behavior: `quality-tiers.yml` exists and root `CLAUDE.md` states no coverage thresholds (verified by grep), so the gate condition is true and the 85/75 defaults continue to govern; `check_quality_tiers` is unchanged.

## Numeric Derivation Evidence

### Claim: the in-scope edit set is 16 existing files (8 repo-local + 8 bundled mirrors)

- Complete Family: every non-`docs/` file that carries the tier classification obligation, the "Module Rigor Tiers" rule, the "not used in this repository" tier threshold sentence, or the feature-review "uniform tier rule" threshold citation, across `.claude/`, `.agents/`, `.github/`, `.codex/`, and `extensions/drm-copilot/resources/`.
- Exhaustive Search Scope: entire worktree excluding `node_modules`, `dist`, `artifacts/`, `.claude/worktrees/`, `docs/`.
- Inclusion Rules: file contains one of: "must be classified in `quality-tiers.yml`", "# Module Rigor Tiers", "Tier-specific lower coverage thresholds are not used in this repository", "Coverage thresholds follow the uniform tier rule (Authoritative", "Coverage thresholds (uniform tier rule per quality-tiers.md)".
- Exclusion Rules: files that only restate numeric thresholds (language rules, QA-gate skills) are handled by the global precedence clause; files that mention `quality-tiers.yml` only as a path token; 80/90 feature-review surfaces with no tier reference; test fixtures with no tier text.
- Primary Search Strategy or Query Expression: content grep, pattern ``must be classified in `quality-tiers\.yml`|# Module Rigor Tiers|Tier-specific lower coverage thresholds are not used in this repository|Coverage thresholds follow the uniform tier rule \(Authoritative|Coverage thresholds \(uniform tier rule per quality-tiers\.md\)``, files-with-matches.
- Primary Member Set: `.claude/rules/quality-tiers.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/agents/feature-review.md`; `.claude/skills/feature-review-workflow/SKILL.md`; `.agents/skills/quality-tiers/SKILL.md`; `.agents/skills/general-code-change/SKILL.md`; `.agents/skills/general-unit-test/SKILL.md`; and the 8 counterparts under `extensions/drm-copilot/resources/claude-customizations/` (5) and `extensions/drm-copilot/resources/codex-and-agents-customizations/` (3).
- Primary Count: 16.
- Cross-check Search Strategy or Query Expression: path enumeration by filename, independent of content: glob `**/{quality-tiers.md,general-code-change.md,general-unit-test.md,feature-review.md}` and glob `**/{quality-tiers,general-code-change,general-unit-test,feature-review-workflow}/SKILL.md` (21 paths), then per-path content check for tier wording.
- Cross-check Member Set: 21 enumerated paths minus 5 excluded after content check: `tests/fixtures/codex_native_converter/claude/.claude/rules/general-code-change.md` (grep for "tier|quality": 0 hits), `.agents/skills/feature-review-workflow/SKILL.md` and its bundle (80/90, no "tier"), `.github/skills/feature-review-workflow/SKILL.md` and its bundle (80/90, no "tier"). Remaining 16 equal the primary set.
- Cross-check Count: 16.
- Member-set Comparison: normalized repo-relative path sets are identical (16 = 16; no member present in one set and absent from the other).

## Automation Feasibility

Fully automatable. Every change is a Markdown edit in the repository plus one pytest module; verification is local (pytest parity and contract tests, Python toolchain loop) and CI. No third-party UI, credentials, or manual console step is involved. The only non-local step, consumer-side confirmation, depends on the existing release automation (rebuild, publish, reinstall) and is outside this issue's acceptance path.
