# Feature Audit: push-down-claude-customizations (#162)

**Audit Date:** 2026-04-26
**Feature Folder:** `docs/features/active/2026-04-26-push-down-claude-customizations-162`
**Base Branch:** `development` @ `31e4963f11605c1b8af14687694e57bb722cdbe3`
**Head Branch:** `feature/push-down-claude-customizations-162` @ `dbe8782742a99072c868f88e33c08357720e5b92`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `development` (commit `31e4963f11605c1b8af14687694e57bb722cdbe3`)
- **Head branch/commit:** `feature/push-down-claude-customizations-162` (commit `dbe8782742a99072c868f88e33c08357720e5b92`)
- **Merge base:** `31e4963f11605c1b8af14687694e57bb722cdbe3` (merge-base equals base; no independent commits on base since branch)
- **Evidence sources:**
  - Primary: `evidence/qa-gates/p14-acceptance-criteria-checkoff.md`
  - Baseline diff: `evidence/baseline/phase0-*.md` (P0 baseline artifacts)
  - Feature evidence: `evidence/qa-gates/p1-*.md` through `p15-*.md` (27 QA gate artifacts)
  - Plan: `plan.2026-04-26T13-49.md` (validated by `validate_orchestration_artifacts`, P14)
- **Feature folder used:** `docs/features/active/2026-04-26-push-down-claude-customizations-162`
- **Requirements source:** `spec.md` (primary, 18 explicit AC + 1 plan-derived AC) and `user-story.md` (secondary, same 18 criteria)
- **Work mode resolution note:** Work mode `full-feature` was read from `issue.md`. Per the `acceptance-criteria-tracking` skill, AC sources for `full-feature` mode are `spec.md` AND `user-story.md`.
- **Scope note:** All 19 criteria were evaluated. 18 criteria appear verbatim in `spec.md` (all [x]) and `user-story.md` (all [ ] at start of review). AC 19 is derived from the plan's Phase 14 QA acceptance mapping (`plan.2026-04-26T13-49.md`, line 739) and verified against `evidence/qa-gates/p15-orchestrate-skill-diff.md`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-26-push-down-claude-customizations-162/spec.md` — primary (18 criteria; all [x] set by plan executor before this review)
- `docs/features/active/2026-04-26-push-down-claude-customizations-162/user-story.md` — secondary (same 18 criteria; checkbox state updated by this review)
- `docs/features/active/2026-04-26-push-down-claude-customizations-162/plan.2026-04-26T13-49.md` — derived source for AC 19 (plan QA mapping, line 739; not a checkbox item)

### Acceptance criteria (from spec.md and user-story.md)

1. Zero local-script references remain in any `.claude/` markdown file (verified by repo-wide grep).
2. Every replaced reference points at an MCP tool that exists in `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
3. `.claude/settings.json` allow list includes the seven previously-missing MCP tools.
4. `feature-promotion-lifecycle/SKILL.md` no longer references VS Code command IDs in its primary invocation surface; it references MCP tools and is reframed as "MCP-first".
5. `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` use fully-qualified MCP tool names throughout.
6. `scripts/dev_tools/push_down_claude_customizations.py` exists and runs end-to-end against an in-memory destination workspace, copying every tracked `.claude/` file except `settings.local.json` and writing a summary artifact under `artifacts/claude-customizations/`.
7. The new push-down script is bundled into the extension at `extensions/drm-copilot/resources/templates/`.
8. The extension exposes `drmCopilotExtension.pushDownClaudeCustomizations` as a VS Code command and `mcp__drmCopilotExtension__push_down_claude_customizations` as an MCP tool.
9. Parity unit tests exist for the new Python module mirroring those for the Codex/Agents variant.
10. Parity unit tests exist for the new TypeScript MCP handler, service method, and command registration.
11. Repository-wide line coverage remains >= 80 %; new modules reach >= 90 %.
12. Toolchain passes in a single pass for both Python (Black -> Ruff -> Pyright -> Pytest) and TypeScript (Prettier -> ESLint -> TSC -> Jest).
13. `.claude/skills/orchestrate/SKILL.md` is present in the `.claude/skills/` tree and is included in the push-down output.
14. The orchestrate skill implements checkpoint resumption from `artifacts/orchestration/orchestrator-state.json`.
15. The orchestrate skill's remediation loop terminates after at most 3 full iterations and records `step6_status: "blocked_remediation_loop_limit"` when the limit is reached.
16. The orchestrate skill's PR creation gate requires all four specified conditions to be simultaneously true before proceeding to PR creation.
17. Every delegation prompt emitted by the orchestrate skill includes the canonical issue number derived from the active feature folder name.
18. The orchestrate skill's feature-review delegation contains none of the four categories of prohibited prompt language.

### Derived acceptance criterion (from plan QA mapping)

19. Pre-feature-review commit step is present in the orchestrate skill (stage, invoke commit-message skill, commit).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Zero local-script references in `.claude/` markdown files | PASS | `evidence/qa-gates/p6-acceptance-criterion-1-grep.md` — grep returns 0 matches outside the `### Fallback only` subsection | `git grep -r "poetry run python -m scripts\|scripts/dev[_-]tools\|scripts\.dev_tools" .claude/` (excluding fallback subsection per spec filter) | Fallback subsection is explicitly excluded from the grep filter per spec design |
| 2 | Every replaced reference points at an MCP tool in `repo-automation-tool-names.ts` | PASS | `evidence/qa-gates/p6-mcp-reference-resolution.md` — all tool names verified against the registered constants | Diff inspection: `git diff 31e4963f..dbe8782 -- .claude/` + grep against `repo-automation-tool-names.ts` | No dangling MCP references |
| 3 | `.claude/settings.json` includes the seven missing MCP tools | PASS | `evidence/qa-gates/p4-settings-allow-list-superset.md` — all seven entries present | `git diff 31e4963f..dbe8782 -- .claude/settings.json` | Entries: `collect_pr_context`, `new_potential_entry`, `new_potential_bug_entry`, `potential_to_issue`, `new_active_feature_folder`, `validate_orchestration_artifacts`, `resolve_atomic_plan_prompt` |
| 4 | `feature-promotion-lifecycle/SKILL.md` reframed as MCP-first, no VS Code command IDs in primary surface | PASS | `evidence/qa-gates/p1-feature-promotion-lifecycle-diff.md`, `evidence/qa-gates/p6-extension-first-cross-references.md` | `git diff 31e4963f..dbe8782 -- .claude/skills/feature-promotion-lifecycle/SKILL.md` | VS Code command IDs moved under `### Fallback only` subsection |
| 5 | `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` use fully-qualified MCP tool names | PASS | `evidence/qa-gates/p5-bare-tool-names-residual.md` — 0 bare tool-name references | `grep -n "^mcp_\|^mcp__" .claude/skills/atomic-plan-contract/SKILL.md .claude/skills/policy-audit-template-usage/SKILL.md` | All tool names use `mcp__drmCopilotExtension__` prefix |
| 6 | `push_down_claude_customizations.py` exists, end-to-end run, copies `.claude/` minus `settings.local.json`, writes artifact | PASS | `evidence/qa-gates/p8-python-targeted-qa.md` — tests pass: `test_push_down_customizations_copies_claude_tree_files`, `test_push_down_customizations_excludes_settings_local_json`, `test_push_down_customizations_writes_claude_artifact` | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py -v` | All 9 tests pass, coverage 90% |
| 7 | Push-down script bundled at `extensions/drm-copilot/resources/templates/` | PASS | `evidence/qa-gates/p9-bundled-copy-byte-identical.md` — SHA-256 `01ee635e...3d72a` identical across all three copies | File existence confirmed by `git diff --name-status` (A `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`) | Byte-identical to source |
| 8 | Extension exposes VS Code command and MCP tool | PASS | `evidence/qa-gates/p13-package-json-valid.md`; TypeScript tests for MCP registration (p12) and command registration | `npm --prefix extensions/drm-copilot run test:unit -- --testPathPattern="push-down-claude"` | Command `drmCopilotExtension.pushDownClaudeCustomizations` registered; MCP tool `push_down_claude_customizations` in `REPO_AUTOMATION_TOOL_DEFINITIONS` |
| 9 | Parity Python unit tests exist | PASS | `evidence/qa-gates/p8-python-targeted-qa.md` — 9 tests covering ROOT_FOLDERS, passthrough rewrite, end-to-end copy, exclusion, artifact, main CLI, parse_args, import isolation | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py -v` | Mirrors Codex/Agents test suite structure |
| 10 | Parity TypeScript unit tests exist | PASS | `evidence/qa-gates/p12-typescript-targeted-qa.md` — 13 new tests in 4 new files; 3 modified test files | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Handler, service, input resolver, command registration, tool definition all covered |
| 11 | Coverage: repo-wide >= 80%, new modules >= 90% | PASS | `evidence/qa-gates/p14-coverage-delta.md` — Python repo-wide 83% (≥80%), new module 90% (≥90%), TypeScript 94.95% (≥80%), all changed TS files ≥90% | `poetry run pytest --cov --cov-report=term-missing` + `npm run test:unit -- --coverage` | No coverage regression vs baseline |
| 12 | Toolchain single-pass for Python and TypeScript | PASS | P14 QA gate: `p14-python-format.md`, `p14-python-lint.md`, `p14-python-typecheck.md`, `p14-python-test-coverage.md`; `p14-typescript-format.md`, `p14-typescript-lint.md`, `p14-typescript-typecheck.md`, `p14-typescript-test-coverage.md` — all exit 0 in one pass | Full chain run 2026-04-26, all steps exit 0 | Live verification confirmed |
| 13 | `orchestrate/SKILL.md` present in `.claude/skills/` and in push-down output | PASS | `evidence/qa-gates/p9-bundled-copy-byte-identical.md` — `.claude/skills/orchestrate/` directory included in bundled tree; `evidence/qa-gates/p15-orchestrate-skill-diff.md` confirms file content | `git diff 31e4963f..dbe8782 -- .claude/skills/orchestrate/SKILL.md` | File present and modified |
| 14 | Orchestrate skill implements checkpoint resumption from `orchestrator-state.json` | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — `## Checkpoint Handling` section present with resumption logic | Diff inspection: `Checkpoint Handling` heading present | Section reads from `artifacts/orchestration/orchestrator-state.json` |
| 15 | Remediation loop terminates after 3 iterations with `blocked_remediation_loop_limit` | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — `## Remediation Loop (R1–R5)` section with termination guard `blocked_remediation_loop_limit` present | Grep: `grep "blocked_remediation_loop_limit" .claude/skills/orchestrate/SKILL.md` | 3-iteration cap is explicit |
| 16 | PR creation gate requires all four conditions simultaneously | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — `## PR Creation Gate` section with all four conditions enumerated | Grep: `grep -A 10 "PR Creation Gate" .claude/skills/orchestrate/SKILL.md` | All four conditions must be true |
| 17 | Issue number derived from feature folder name in every delegation prompt | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — `## Issue Number Consistency` section with derivation rule and injection instruction | Grep: `grep -A 5 "Issue Number Consistency" .claude/skills/orchestrate/SKILL.md` | Derivation: parse numeric suffix of `docs/features/active/<folder>` |
| 18 | Feature-review delegation contains none of the four prohibited-prompt categories | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — Step 6 Delegation — Prohibited Prompt Language section retained; `evidence/qa-gates/p15-orchestrate-skill-content-integrity.md` — 0 prohibited patterns in new content | Grep for prohibited categories per `p15-orchestrate-skill-content-integrity.md` | Content-integrity grep exit 0 |
| 19 | Pre-feature-review commit step present in orchestrate skill (stage, commit-message skill, commit) | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — `## Pre-Feature-Review Commit` section with `git add -A`, commit-message skill invocation, and commit instruction | Grep: `grep "Pre-Feature-Review Commit" .claude/skills/orchestrate/SKILL.md` | Section inserted between `## Completion Requirements` and `## Step 6 Delegation — Prohibited Prompt Language` |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. All 19 criteria pass.

**Recommended follow-up verification steps:**

1. Merge PR and verify the bundled `.claude/` push-down delivers correctly to at least one downstream workspace using the MCP command surface.
2. Establish a re-sync cadence for the bundled `.claude/` tree in `extensions/drm-copilot/resources/claude-customizations/` to prevent drift from future `.claude/` updates (Info-level finding in code-review artifact).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 19 criteria are evaluated as PASS and may be checked off in the authoritative source files where they appear as markdown checkboxes.
- `spec.md` AC items (1–18) were already checked [x] by the plan executor before this review. No additional check-off action is required for `spec.md`.
- `user-story.md` AC items (1–18) are currently unchecked [ ] and are checked off below by this review.
- AC 19 appears in `plan.2026-04-26T13-49.md` as prose in the QA mapping (not a checkbox item); no check-off action required for the plan file.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 18 | 18 | 0 | Checkbox-backed; all [x] set by plan executor |
| `user-story.md` | 18 | 18 | 0 | Checkbox-backed; [x] set by this review (see below) |
| `plan.2026-04-26T13-49.md` | 1 (AC 19) | 1 | 0 | Prose-only in QA mapping; no checkbox to update |
