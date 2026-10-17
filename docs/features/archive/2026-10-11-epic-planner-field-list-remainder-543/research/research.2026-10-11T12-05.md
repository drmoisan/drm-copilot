# Research: epic-planner Checkpoint Persistence field list remainder (issue #543)

Date: 2026-10-11. Mode: preparation, read-only. All citations were re-derived against the current tree (worktree root, repository-relative paths).

## 1. Current text and required-key sets

`.claude/agents/epic-planner.md:104-111` (`## Checkpoint Persistence`), exact current text:

```
Update `artifacts/orchestration/epic-planner-state.json` after every completed step with:
`objective`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, `epic_issue_num`,
`epic_worthiness` (`{verdict, rationale}`), `features[]` (per-feature `issue_num`,
`feature_folder`, `depends_on`, `wave`, `complexity_band`, `preparation_status`, `plan_path`,
`preflight_status`), `kickoff_prompt_path`, `completed_steps`, `next_step`, and `last_updated`.
`epic_issue_num` is the epic-level issue ...
```

(The last line, 111, is a long paragraph about `epic_issue_num` and issue #663; it follows the list and is unchanged by this work.)

Python `scripts/dev_tools/validate_epic_planner_state.py`:
- `REQUIRED_KEYS` (lines 34-46): `objective`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, `max_parallel_features`, `epic_worthiness`, `features`, `kickoff_prompt_path`, `completed_steps`, `next_step`, `last_updated`.
- `REQUIRED_FEATURE_KEYS` (lines 47-57): `issue_num`, `feature_folder`, `depends_on`, `wave`, `complexity_band`, `preparation_status`, `research_path`, `plan_path`, `preflight_status`.
- Enforced at lines 147 and 306.

TypeScript twin `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`: `REQUIRED_KEYS` (lines 19-31) and `REQUIRED_FEATURE_KEYS` (lines 33-43) are identical in content and order to the Python tuples. Enforced at lines 183 and 391.

PowerShell port: none. A glob for `validate*epic*planner*` returns only the Python file.

Omissions in the Claude field list versus the validators:
- Top-level: only `max_parallel_features` is missing. Every other REQUIRED_KEYS entry is listed. The list also names `epic_issue_num`, which is not in REQUIRED_KEYS (documented extra, not a defect).
- Per-feature: only `research_path` is missing. All other REQUIRED_FEATURE_KEYS entries are listed.
- Finding: there are no extra omissions, so the operator-decided two-key scope is the complete gap for required keys. The validators also accept optional or conditional fields (for example a top-level topology receipt, `_validate_planner_topology_receipt` at line 62) that the Claude list does not mention. Those are optional and out of the operator decision; flag only.

Recommended edit: insert `max_parallel_features` after `integration_branch` (mirrors validator order, before `epic_issue_num` or after it as the plan prefers) and `research_path` before `plan_path` in the per-feature parenthetical (validator order: `preparation_status`, `research_path`, `plan_path`).

## 2. Mirrors and copies

- Bundled mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md`. Lines 102-113 currently match the root text exactly (same list, same line 111 paragraph).
- Grep for "after every completed step" shows the epic-planner persona exists in these Claude locations only: `.claude/agents/epic-planner.md` and the bundled mirror above. Other hits are the orchestrator-family and skill files, which are different personas and are not copies of this file. Codex equivalents are covered in section 3.
- Byte-identity is required: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110) asserts every distributable repo `.claude/**` file exists in the bundle and `read_text` equality for each. The same edit must therefore be applied identically (including line endings) to both files.
- No generator or sync script is needed for a single-file mirror; the existing pattern (prior features) hand-copies the file and verifies with the parity tests. Push-down code (`scripts/dev_tools/push_down_claude_customizations.py`, `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`) delivers the bundle to other repos; it does not regenerate the bundle. Recommendation: apply the same Edit to both files and verify parity, not run a sync tool.

## 3. Codex counterparts and duplicated lists

- Codex persona: `.codex/agents/epic-planner.toml` with bundled mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-planner.toml`. Its `## Checkpoint` text (`.codex/agents/epic-planner.toml:69-76`) is prose, not the Claude list, and already covers both keys: "bounded maximum" (line 73) and "research and plan paths" (line 74). No Codex change is required.
- Codex skill: `.agents/skills/epic-plan/SKILL.md:234-240` already names `max_parallel_features` and `research_path` explicitly. Its bundled mirror is `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`. No change.
- No test or generator requires the Codex text to match the Claude list: `tests/scripts/dev_tools` greps for `epic-planner.md`, `Checkpoint Persistence` found no Codex-side pin on the field list.
- `.claude/skills/epic-plan/SKILL.md:220-224` does not duplicate the list; it points to the agent's `## Checkpoint Persistence`. No change.
- `.github/` contains no reference to `epic-planner-state` or `max_parallel_features`. `.claude/rules/` contains `parallel-orchestration.md:36` mentioning the artifact name only. No policy file holds a duplicate list; nothing in those trees is in scope.

## 4. Tests and tooling pinning these files

- Byte parity (Claude): `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (recent baseline evidence: 16 passed, exit 0; `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/qa-gates/claude-bundle-parity-widening.2026-10-10T09-43.md`). Node ID of interest: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- Pack manifests: they list paths, not hashes. `test_push_down_claude_pack_manifest_completeness.py` checks membership; the file is already listed, so no manifest change. No sha256 list or hash file exists for these resources (no matches for hash/byte in the manifest completeness test beyond a docstring word).
- Content pins on the persona that the edit must not break:
  - `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1:172-184` requires the `## Checkpoint Persistence` section to contain `epic_issue_num` and `promotion_type: epic`, and the frontmatter tool entries. Keep line 111 and the heading unchanged.
  - `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py:31,48-59` pins frontmatter strings (`name: epic-planner`, `agent: epic-planner`).
  - `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:69` lists the file for frontmatter checks.
  - `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py:182` and `test_orchestrator_state_required_keys_docs.py:232-238` read `## Checkpoint Persistence`, but the grep shows they target other agents (no epic-planner matches). Not affected.
- PowerShell Pester (`checkpoint-hygiene-skill-contract.Tests.ps1`) must be run through PoshQC MCP tools (per constraint), plus CI evidence. No sh/bash/pwsh wrappers.
- Jest under `extensions/drm-copilot/`: no test there references `epic-planner.md` or `Checkpoint Persistence` (grep of `extensions/drm-copilot` under src/test/scripts returned no matches). Run `npm test` in `extensions/drm-copilot` only if the plan wants a full-loop pass; the change cannot affect it.
- Issue #510 mitigation: `tests/scripts/dev_tools/claude_payload_scope_test_support.py` (and its tests `test_claude_payload_scope_support.py`) filters local-only paths (`.claude/agent-memory/**`, `.claude/state/**`, `.claude/worktrees/**`, `.claude/settings.local.json`) from the parity enumeration, so the parity test is meant not to fail on gitignored state. A local failure from gitignored files outside that list remains possible; if one appears, compare the failing path to the list before attributing it to this change. The target file is tracked, so it is covered either way.

## 5. Documentation-only assessment

The change is Markdown-only with no executable code: two `.md` files. Applicable stages:
- Formatting: `extensions/drm-copilot` `format` script covers only `src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs`; Markdown under `resources/` is not Prettier-formatted by that script. A root `.prettierignore` exists; the plan should confirm no markdown check targets these paths. No `.markdownlint*` config was found at repo root.
- Lint, type check, architecture tests, Jest: no changed source, run unchanged for the loop completeness record.
- Unit tests: the two pytest parity files above plus the Pester contract file via PoshQC MCP.
- Coverage: unaffected; no production code touched.
- Keep line length consistent with the surrounding hard-wrapped text (about 100 columns). The file is Markdown, exempt from the 500-line limit.

## 6. Risks

- Concurrent items: `docs/features/parallel/` has no files and no `*burndown*` manifest exists under `docs/features` for 2026-10-11 (only `docs/features/potential/promoted/2026-10-08-bug-burndown-2026-09-29-review-nits.md`). A sibling item editing `.claude/agents/epic-planner.md` or its mirror cannot be ruled out from the tree; the plan should re-check `git diff origin/main --stat -- .claude/agents/epic-planner.md` immediately before editing and rebase on main before opening the PR.
- Mirror drift: editing only one of the two Claude files fails the parity test. Edit both in the same step.
- Existing feature folders for #543 (`2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, `2026-10-08-epic-planner-topology-receipt-gate-543`) are separate active features; they did not alter the field list, and this remainder folder is `2026-10-11-epic-planner-field-list-remainder-543`.
- Line 111 and the `## Checkpoint Persistence` heading are pinned by the Pester contract; do not reword them.

## Automation Feasibility

Fully automatable; no human interaction is required. Two identical Markdown edits, then pytest parity tests (`poetry run pytest ...`) and the Pester contract file through PoshQC MCP tools, plus CI evidence. No sh/bash/pwsh wrapper scripts are needed.

## Recommendation

Add `max_parallel_features` (top level) and `research_path` (per feature) to the field list in `.claude/agents/epic-planner.md` and the identical bundled mirror; make no Codex, skill, `.github`, or `.claude/rules` changes.
