# Active-Features Delivery-Status Audit

- Date: 2026-07-09
- Scope: one-off repository housekeeping audit (not tied to a single feature)
- Repository under audit: `drmoisan/drm-copilot` (GitHub), local working tree at `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-09T09-26`
- Objective: determine, for each of the 12 folders currently under `docs/features/active/`, whether the underlying work has already been merged to `main`, even though the folder has not been relocated to `docs/features/completed/`.

## Method

For each folder:

1. Read `issue.md` / `plan*.md` / `spec.md` inside the folder to extract the GitHub issue number and a description of the intended change.
2. Queried `https://api.github.com/repos/drmoisan/drm-copilot/issues/<n>` for issue state, and `https://api.github.com/repos/drmoisan/drm-copilot/issues/<n>/timeline` for cross-referenced pull requests and closing events.
3. Queried `https://api.github.com/repos/drmoisan/drm-copilot/pulls/<pr>` for merge status and PR-body closing keywords (`Closes #<n>` / `Fixes #<n>` / `Resolves #<n>`).
4. Cross-checked the corresponding source files in the local working tree (which tracks recent `main` history, confirmed clean and up to date with the repository's most recent merge commits at the time of this audit) to confirm the described behavior is present in code, not merely claimed by a merged PR.

## Automation Feasibility

N/A — no third-party UI interaction; all checks used the GitHub REST API (via fetch) and local file inspection equivalent to `git`/`gh` output.

## Findings Table

| Folder | Issue # | Issue State (GitHub) | Verdict | Merged PR # | PR URL | Evidence summary |
|---|---|---|---|---|---|---|
| `2026-04-04-potential-entry-opening-different-ide-116` | #116 | **OPEN** | DELIVERED | #119 (and follow-up #137) | https://github.com/drmoisan/drm-copilot/pull/119 | `scripts/dev_tools/new_potential_bug_entry.py` and `new_active_feature_folder_io.py` both currently contain `_resolve_code_cli()` with `code-insiders` preference and `--reuse-window` in the launch command, matching the issue's proposed fix. PR #119 (merged 2026-04-05) and PR #137 (merged 2026-04-12) both list #116 only as a "Related issue," with no closing keyword; the folder's own `code-review.2026-04-04T12-40.md` recorded a "No-Go / Needs revision" verdict at the time (live Windows verification and coverage isolation were unresolved), and the docstring artifact flagged as a Minor finding is still present in code today. |
| `2026-07-03-fix-convertto-commandresult-empty-array-298` | #298 | Closed | DELIVERED | #304 | https://github.com/drmoisan/drm-copilot/pull/304 | Issue closed 2026-07-04 via merged PR #304, whose body contains "Closes #298". `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:57` currently has `[AllowEmptyCollection()]` on the `$Output` parameter of `ConvertTo-CommandResult`, matching the fix. |
| `2026-07-03-pester-completion-consistency-301` | #301 | Closed | DELIVERED | #302 | https://github.com/drmoisan/drm-copilot/pull/302 | Issue closed 2026-07-04 via merged PR #302 ("Fix(pester): align Codex completion-consistency hooks - 301"), whose body contains "Closes: #301". |
| `2026-07-04-bundle-model-routing-deps-312` | #312 | Closed | DELIVERED | #314 | https://github.com/drmoisan/drm-copilot/pull/314 | Issue closed 2026-07-05 via merged PR #314, whose body contains "Closes #312". `.claude/lib/model-routing/ModelRouting.psm1` exists in the working tree, confirming the model-routing formulas were bundled as a PowerShell module reachable under `.claude/` (the delivered design differs slightly from the issue's "Option 1" draft of relocating the Python scripts verbatim, but satisfies the same self-containment goal; the two pure Python scripts remain at `scripts/dev_tools/` and are not separately mirrored under `.claude/`). |
| `2026-07-04-codex-agent-role-config-306` | #306 | Closed | DELIVERED | #307 | https://github.com/drmoisan/drm-copilot/pull/307 | Issue closed 2026-07-04 via merged PR #307, whose body contains "Closes #306". A search of `.codex/agents/orchestrator.toml` in the working tree found none of the malformed-shape strings quoted in the issue (`invalid type: map, expected a sequence`, `BundledSkillsConfig`), consistent with the fix being applied. |
| `2026-07-04-enforce-model-selection-routing-305` | #305 | Closed | DELIVERED | #308 | https://github.com/drmoisan/drm-copilot/pull/308 | Issue closed 2026-07-05 via merged PR #308, whose body contains "Closes #305". `scripts/dev_tools/_orchestrator_state_model_routing.py` and `_orchestrator_state_model_routing_gate.py` exist in the working tree, and `.claude/rules/orchestrator-state.md` documents the require-once-delegated gate this issue introduced. |
| `2026-07-04-release-flow-wait-for-ci-310` | #310 | Closed | DELIVERED | #311 (documentation follow-up in #313) | https://github.com/drmoisan/drm-copilot/pull/311 | Issue closed 2026-07-05 via merged PR #311, whose body contains "Closes #310". `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` contains a documented "Waits for a pull request's required checks to register and complete" routine with a timeout message, matching the fix. Follow-up PR #313 (merged 2026-07-05) restored feature-review audit-trail artifacts that were generated but not committed in PR #311. |
| `2026-07-06-fix-subagent-tree-discovery-terminal-325` | #325 | Closed | DELIVERED | #326 | https://github.com/drmoisan/drm-copilot/pull/326 | Issue closed 2026-07-07 via merged PR #326, whose body contains "Closes #325". `extensions/drm-copilot/src/terminal-writer.ts` and `subagent-tree-command.ts` exist, consistent with the terminal-output-destination fix described in the issue. |
| `2026-07-07-epic-single-home-manifest-331` | #331 | Closed | DELIVERED | #332 | https://github.com/drmoisan/drm-copilot/pull/332 | Issue closed 2026-07-09 via merged PR #332, whose body contains "Closes #331". Local `main`-tracking branch history (visible at the top of this session's git log) shows `732a607 feat(epic): adopt single-home layout for multi-feature epics` and `e6126fb Merge pull request #332 from drmoisan:feature/epic-single-home-manifest-331`, confirming the change is on `main`. |
| `2026-07-07-nested-worktree-folder-scheme-328` | #328 | Closed | DELIVERED | #330 | https://github.com/drmoisan/drm-copilot/pull/330 | Issue closed via merged PR #330 ("feat(worktrees): nest session worktrees under per-repo grouping directory (#328)"), whose body contains "Closes #328". Note: a duplicate/related issue #329 with the identical title also exists and is independently closed; the audited folder's own `issue.md` names #328 specifically, and that mapping is confirmed correct. |
| `portable-orchestrator-state-preflight` | #321 | Closed | DELIVERED | #322 | https://github.com/drmoisan/drm-copilot/pull/322 | Folder has no `issue.md`; the issue number (`#321`) was extracted from `spec.md`. Issue closed 2026-07-06 via merged PR #322 ("fix(hooks): make pushed-down orchestrator-state enforcement hooks portable (#321)"), whose body contains "Closes #321". `.claude/lib/orchestrator-state/OrchestratorState.psm1` exists in the working tree, matching the described portable module. |
| `subagent-tree-command` | #320 | Closed | DELIVERED | #323 | https://github.com/drmoisan/drm-copilot/pull/323 | Folder has no folder-name suffix; the issue number (`#320`) was read from the folder's `issue.md`. Issue closed 2026-07-06 via merged PR #323 ("feat(extension): add Show Subagent Tree command (#320)"), whose body contains "Closes #320". `extensions/drm-copilot/src/subagent-tree-command.ts` and the `showSubagentTree` command registration in `extension.ts`/`package.json` exist, matching the feature. |

## Reconciliation Actions Needed

Eleven of the twelve folders are DELIVERED with the GitHub issue already CLOSED and the merging PR already linked via an explicit closing keyword. No action is needed for those eleven; the only outstanding housekeeping step for them is relocating each folder from `docs/features/active/` to `docs/features/completed/`, per repository convention.

One folder requires issue reconciliation before or alongside relocation:

### `2026-04-04-potential-entry-opening-different-ide-116` (Issue #116)

- (a) The GitHub issue is currently **OPEN**.
- (b) Neither merged PR is linked to the issue via a closing keyword: PR #119 (merged 2026-04-05) and PR #137 (merged 2026-04-12) both list #116 only under "Related issue," not "Closes #116" / "Fixes #116."
- The underlying code fix (VS Code CLI resolution with `code-insiders` preference and `--reuse-window`) is present in `scripts/dev_tools/new_potential_bug_entry.py` and `scripts/dev_tools/new_active_feature_folder_io.py` today, so the functional delivery is confirmed. The folder's own code-review recorded a "No-Go / Needs revision" verdict at review time because live Windows manual verification and isolated new-code coverage were not captured as evidence artifacts — those gaps are about audit-trail completeness, not about whether the code shipped.

Recommended commands (run manually; not executed by this research task, which is read-only):

```
gh issue comment 116 --repo drmoisan/drm-copilot --body "Delivered via #119 (merged 2026-04-05) and refined in #137 (merged 2026-04-12). The Windows launcher reuse-window and code-insiders-preference fix is present in scripts/dev_tools/new_potential_bug_entry.py and scripts/dev_tools/new_active_feature_folder_io.py."
gh issue close 116 --repo drmoisan/drm-copilot --comment "Closing: functional fix confirmed present in main via #119/#137. Live Windows manual verification and isolated new-code coverage were flagged as open gaps in the 2026-04-04 code review; re-open if manual verification surfaces a regression."
```

Before running these commands, confirm with the issue owner whether the outstanding "Minor" docstring-artifact finding and the unresolved live-Windows-verification/coverage-isolation gaps from the 2026-04-04 code review should be tracked as a new follow-up issue rather than silently closed alongside #116.

## Summary of Housekeeping Gap

All 12 folders currently under `docs/features/active/` correspond to work that has already been merged to `main` via a closed GitHub issue and a merged pull request. None of the 12 should remain under `docs/features/active/` under the repository's stated convention that delivered work is relocated to `docs/features/completed/`. Eleven of the twelve have both a closed issue and a properly linked merged PR; only Issue #116 needs the reconciliation actions above before or alongside relocation.
