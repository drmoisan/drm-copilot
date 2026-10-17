# Research: issue #764 part 1 - feature-review skill cites a nonexistent validator

- Issue: #764 (bug, Work Mode: minor-audit)
- Branch: bug/feature-review-skill-cites-nonexistent-validator-764
- Date: 2026-09-30
- Scope: part 1 only (the missing `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` citation). Part 2 (`ROOT_FOLDERS` divergence) moved to #507 and is out of scope.
- Limitation: no shell tool was available in this session, so `git log -S "Test-ModifiedWorkflowNeedsGreenRun"` was not run. Git history is unverified; the conclusions below rest on working-tree searches.

## 1. Existing implementation search (negative evidence)

Result: no implementation of the trigger-path or green-run evidence logic exists in the repository.

Search scope and patterns (Grep over the whole worktree root, including `scripts/`, `.claude/`, `.agents/`, `.github/`, `extensions/drm-copilot/`, `tests/`):

| Pattern | Scope | Result |
|---|---|---|
| `Test-ModifiedWorkflowNeedsGreenRun` | all files | Matches only in `docs/**` (feature artifacts, audits, promoted issue record) and in the two SKILL.md files at line 75 (see section 4). No `.ps1`, `.py`, `.ts`, `.sh` file defines or calls it. |
| `ModifiedWorkflowNeedsGreenRun\|modified-workflow-needs-green-run`, excluding `docs/**` | all files | 19 files. All are prose rule references (skills, rules, `orchestrator.md`) or comments and test assertions around workflow files (`.github/workflows/publish-extension.yml`, `publish-mcp-npm.yml`, `verify-published-releases.yml`, `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1`). None computes trigger paths or checks run evidence. |
| `Test-ModifiedWorkflow\|green-run\|supporting validator` limited to `tests`, `scripts`, `extensions/drm-copilot/src`, `extensions/drm-copilot/test`, `.github/workflows` | executable surfaces | Matches only the five workflow files and workflow tests listed above (comments and static workflow-shape assertions). No implementation. |
| Glob `scripts/feature-review*` | repo root | No files. The directory `scripts/feature-review/` does not exist. |

Corroboration from prior audits: several completed feature audits state that the validator is absent and the rule was applied manually, for example `docs/features/completed/npm-audit-gate-and-dependabot/policy-audit.2026-06-20T00-43.md:145`, `docs/features/completed/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/policy-audit.2026-07-26T05-50.md:294`, and `docs/features/completed/2026-08-10-parallel-surface-destination-portability-bash-462/policy-audit.2026-08-10T13-30.md:380`. The rule has therefore been evaluated manually in every recorded use. A historical remediation input (`docs/features/completed/2026-06-16-bump-and-publish-task-191/remediation-inputs.2026-06-17T00-18.md:30`) repeated the citation, which indicates the sentence was copied forward without a file ever landing.

## 2. Rule content and manual evaluation

`.claude/skills/feature-review-workflow/SKILL.md` lines 68-75, section `### modified-workflow-needs-green-run`:

- Line 70: trigger. If the branch diff modifies any path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`, the policy audit emits a Blocking finding unless evidence of a green workflow run against the branch head is present in the remediation inputs.
- Line 72: purpose (second line of defense, separate from the orchestrator S9 CI green gate).
- Line 73: definition of "green workflow run against the branch head": head SHA equals the current branch head and the conclusion is success for the affected workflow.
- Line 74: a green `workflow_dispatch` run against the branch head also qualifies.
- Line 75: outcome sentence (record a Blocking finding and route through the standard remediation handoff) followed by the false validator sentence.

Without the validator, the reviewer performs the rule manually: (a) list the branch diff paths and match them against the three trigger globs; (b) if any match, look in the remediation inputs for a workflow run whose head SHA equals the branch head with conclusion success for the affected workflow (PR-context or `workflow_dispatch`); (c) if absent, record a Blocking finding. Lines 70-74 already specify this completely. The removed sentence adds no requirement; the trigger globs and evidence definition are fully stated in the prose.

Recommendation: delete the second sentence of line 75 (remove the citation). Justification: no implementation exists; prior audits confirm manual evaluation works; the issue's own Expected Behavior allows "or the sentence is removed"; a new PowerShell validator would need bundling in a skill pack (issue #762 contract, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`), pack manifest entries, tests at 85% coverage, and mirror sync, which is disproportionate to a low-severity documentation defect. A new validator is not genuinely required.

Rejected alternatives: (1) implement the validator under `.claude/lib/` - rejected as disproportionate scope; (2) repoint the citation to another script - rejected because none implements the logic.

## 3. Proposed replacement text for line 75

Delete the second sentence. The resulting line 75 is:

```
- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff.
```

This is factual and neutral (`.claude/rules/tonality.md`) and requires no further claims that could become stale. The same edit applies to the bundled mirror line 75.

## 4. Copies of the skill and citation carriers (outside `docs/features`)

All copies of `feature-review-workflow/SKILL.md` (Glob `**/feature-review*/**`) and their status, determined by Grep for `Test-ModifiedWorkflow`, `modified-workflow-needs-green-run`, `green-run`, `GreenRun`, `green workflow`:

| Path | Carries the citation |
|---|---|
| `.claude/skills/feature-review-workflow/SKILL.md` (line 75) | Yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` (line 75) | Yes |
| `.agents/skills/feature-review-workflow/SKILL.md` | No (no rule section at all) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | No |
| `.github/skills/feature-review-workflow/SKILL.md` | No |
| `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md` | No |
| `.agents/skills/feature-review/SKILL.md`, its bundled mirror under `codex-and-agents-customizations`, `.github/agents/feature-review.agent.md` and its mirror | No (no match for any pattern) |
| `.codex/` | Not present as a match for any pattern |

Files that reference the rule by name only (no validator citation; no edit needed): `.claude/rules/ci-workflows.md:37`, `.claude/rules/benchmark-baselines.md:37`, `.claude/agents/orchestrator.md:122`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:55`, `.agents/skills/ci-workflows/SKILL.md:40`, `.agents/skills/benchmark-baselines/SKILL.md:39`, their `extensions/drm-copilot/resources/**` mirrors, and comments in three `.github/workflows/*.yml` files.

Observation outside scope: `.agents/skills/ci-workflows/SKILL.md:40` and `.agents/skills/benchmark-baselines/SKILL.md:39` point at `.agents/skills/feature-review-workflow/SKILL.md` for the rule, but that file does not contain the rule. This is a separate defect and is not part of #764 part 1.

Files to edit: exactly two, line 75 of the `.claude` source and its bundled mirror.

## 5. Tests and parity mechanisms

- Byte-identical mirror test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 118-143). It iterates every non-`agent-memory` file under `.claude` and asserts the bundled copy under `extensions/drm-copilot/resources/claude-customizations/` has identical text. Editing only one of the two SKILL.md files fails this test. Run: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k all_repo_runtime_contracts` from the repository root (native-bash environments may use the repository's non-poetry pytest wrapper).
- Pack manifest membership: `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (`test_bundled_claude_files_are_listed_in_some_pack_manifest`). The skill is already listed at `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:104`; no change is needed because the path set does not change.
- Skill bundle contract: `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` (`test_every_skill_script_reference_is_bundled`, `test_every_skill_folder_file_is_carried_by_skill_packs`). It extracts script references from skills; the citation is a nonexistent path that the skill does not invoke (recorded in `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/research/2026-09-28T19-15-skill-bundle-audit-research.md:41`). Removing it cannot create a violation; run the file as a regression check.
- Pinning of the sentence text: Grep for `supporting validator`, `Test-ModifiedWorkflow`, and `green-run` under `tests/`, `scripts/`, `extensions/drm-copilot/src`, and `extensions/drm-copilot/test` found only the workflow-file tests, none of which read the skill text. No test pins line 75.
- Hash/manifest regeneration: none. Pack manifests list paths only (no content hashes), and `test_push_down_claude_resource_contracts.py` compares text directly. No regeneration command is required.
- Mirror sync mechanism: no sync script was found (Glob for sync/mirror/copy script names under `extensions/drm-copilot` returned only `resources/templates/sync-agents-from-instructions.ps1`, unrelated). The mirror is committed content; apply the identical edit to both files by hand.
- TypeScript push-down tests (`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, run with `npx jest <path>` from `extensions/drm-copilot`) read the same manifests; they are unaffected by a text-only change and are optional regression checks.

## 6. Toolchains touched

- Markdown only: two SKILL.md line edits. No production code, no test code, no new tests required (removal of an unpinned sentence; existing parity test is the guard).
- Repository-defined checks applicable to Markdown: no markdownlint, prettier-for-Markdown, or skill-frontmatter validator is configured (Glob for `.markdownlint*`, `.prettierrc*`, `.pre-commit-config.yaml` returned no files; root `package.json` prettier globs cover `src/tests` code files only). Applicable checks are the pytest parity and bundle-contract tests in section 5. The frontmatter is untouched. Structure tests in `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` do not reference this skill.
- Suggested baseline and final-QC commands: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`. The full seven-stage toolchain loop applies to code changes; for a Markdown-only change the planner should record which stages are not applicable. Note from repository memory: the bundle-parity tests can fail locally on gitignored state (issue #510) while passing in CI; compare the baseline run before editing.
- Acceptance criteria source (minor-audit): the `## Acceptance Criteria` section of `issue.md`. The current `issue.md` has no such section (it has "Proposed Fix / Validation Ideas" only), so the feature-review skill line 64 would require remediation at review time; the planner should add an `## Acceptance Criteria` section to `issue.md` (for example: sentence removed from both copies; parity test passes; no other file cites the validator).

## Automation Feasibility

No human interaction is required. The fix is a two-file Markdown edit, verifiable with existing pytest tests, with no credentials, external services, or judgment calls outstanding.
