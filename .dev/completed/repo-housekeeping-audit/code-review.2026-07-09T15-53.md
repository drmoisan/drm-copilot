# Code Review — repo-housekeeping-audit (Issue #340)

- Timestamp: 2026-07-09T15-53
- Scope: full branch diff `main..drm-copilot-wt-2026-07-09T09-26` (491 changed files: 472 pure renames, 19 additions/modifications; zero production or test source files)

## Nature of the Change

This is a documentation- and repository-metadata-only change. No language toolchain (format/lint/type-check/architecture/unit/contract/integration) applies, consistent with the change description in `issue.md` and `plan.2026-07-09T11-29.md`. The review below focuses on correctness of the file operations and factual accuracy of the added/modified documentation, which is the substantive risk surface for this kind of change.

## Rename Integrity

Verified via `git diff --name-status -M100 main..HEAD`:

- All 472 non-`docs/features/active/repo-housekeeping-audit/*`, non-`docs/features/potential/promoted/2026-07-09-*`, non-`docs/research/2026-07-09-*`, non-`README.md`/`CLAUDE.md` file changes are `R100` (100%-similarity pure renames) — no content drift in any moved file.
- Exactly 12 distinct folder names moved from `docs/features/active/*` to `docs/features/completed/*`, matching the folder list enumerated in `docs/research/2026-07-09-active-features-delivery-status-audit.md` and in `issue.md`/`plan.md`. Verified independently by diffing source-side and destination-side folder-name sets extracted from the rename list — the two sets are identical.
- No tooling or non-test code (grepped for `.ts`, `.py`, `.ps1`, `.json`, `.cs` files referencing `active/<moved-folder-name>`) depends on the old `active/` path for any of the 12 relocated folders. One test fixture (`tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`) uses a string literal `docs/features/active/2026-07-03-pester-completion-consistency-301` as mock input to a fully-mocked `FolderExistsCheck` closure (`{ param($p) $true }`); it does not touch the real filesystem and is unaffected by the relocation.

## CLAUDE.md Restoration

Independently re-verified all 20 file paths and 6 directory-pattern references in the restored root `CLAUDE.md` resolve in the current working tree (spot-checked a representative subset of the paths listed in `evidence/other/p3-t4.claude-md-path-resolution.2026-07-09T13-00.md`; all present). Content matches the architecture description already established for the `.claude/` runtime (skills/agents/hooks/rules layering) with no invented claims.

## README.md Refresh

Independently re-verified the three counted claims added/changed in this diff, rather than relying solely on the feature's own evidence artifact:

- VS Code command list: `grep -c '"command": "drmCopilotExtension\.' extensions/drm-copilot/package.json` returns 27; `README.md` lists exactly 27 `drmCopilotExtension.*` commands (`grep -c '^- \`drmCopilotExtension\.' README.md` = 27). The added `drmCopilotExtension.showSubagentTree` entry is present in both.
- MCP tool list: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (the file actually imported by the served `mcp-server.ts` surface) defines exactly 20 tool names; `README.md` lists exactly the same 20 names.
- Agent roster: `.claude/agents/*.md` contains exactly the 17 files named in the README roster sentence, including the added `epic-orchestrator`, with no extras and no omissions.
- Skills catalog sentence lists a curated subset (not claimed to be exhaustive); `.claude/skills/` additionally contains 8 skills not named in the narrative sentence (`fill-feature-docs`, `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer`, `make-skill-template`, `policy-audit-template-usage`, `skill-canonical-location-audit`, `update-status`). This omission pattern is pre-existing (the prior README revision also omitted a comparable set of skills) and the sentence's own wording ("The catalog includes...") does not claim completeness, so this is not a new staleness defect introduced by this diff.
- The removed `translate-claude-to-codex` mention is correct: no such skill directory exists under `.claude/skills/`; the replacement sentence's claim that Claude-to-Codex conversion is handled by "the Codex-native converter described below" is borne out by the `## Codex-native converter` section later in the same file.

**Verdict: no stale or inaccurate claim was found in the changed README.md content.**

## Research/Audit Artifacts (`docs/research/2026-07-09-*.md`)

Spot-checked the load-bearing factual claims in all three audits against the live repository and GitHub state rather than trusting the artifacts at face value:

- `2026-07-09-active-features-delivery-status-audit.md`: the 12-folder inventory and closed/open GitHub issue-state claims for each folder were cross-checked against the actual rename list (exact match) and, for issue #116, against live `gh issue view` output (state CLOSED, `closedByPullRequestsReferences` empty but a closing comment referencing #119/#137 is present — consistent with the audit's own description that #116 lacked a native closing-keyword link and required a manual reconciliation comment).
- `2026-07-09-potential-entries-duplicate-audit.md`: the claim that `docs/features/potential/` contains no un-promoted candidate files besides `README.md`/`template.md`/`promoted/` was reproduced (`ls docs/features/potential/`).
- `2026-07-09-remaining-technical-debt-audit.md`: the claim that `quality-tiers.yml` does not exist at the repo root was reproduced directly (`ls quality-tiers.yml` -> not found).

No factual claim in these three research artifacts was found to be inaccurate.

## Minor Findings (non-blocking)

1. **Stale "Next Step" checklist state in newly added promoted-backlog docs.** All five new files under `docs/features/potential/promoted/2026-07-09-*.md` (`codex-pr-author-hook-not-wired.md`, `orchestrator-state-audit-trail-deferred.md`, `potential-entry-ide-launcher-audit-gaps.md`, `quality-tiers-yml-missing-at-repo-root.md`, `repo-housekeeping-audit.md`) each carry a top-of-file `Status: Promoted -> ... (Issue #NNN)` line confirming the issue was opened, but the bottom `## Next Step` checklist in the same file still shows `- [ ] Promote to GitHub issue (...)` unchecked. Two comparable pre-existing promoted docs (`2026-07-06-portable-orchestrator-state-preflight.md`, `2026-07-06-subagent-tree-command.md`) update this checklist state after promotion (checked or replaced with a status note). Severity: Minor — cosmetic self-inconsistency within a single file, does not affect any downstream tooling (the `Status:` line, not the checklist, is what `docs/features/potential/potential_to_issue_content.py`-family tooling reads).
2. **`repo-housekeeping-audit.md`'s own "Create ... folder from the template" checkbox is unchecked** despite `docs/features/active/repo-housekeeping-audit/` existing with a full `issue.md`/`plan.md`/`evidence/` tree. Same category and severity as Finding 1.
3. **Informational, not attributable to this diff:** the `Status: Promoted -> docs/features/active/<slug>/ (Issue #NNN)` line in the four backlog-item docs (#335/#336/#337/#338) names an `active/` folder path that does not exist in the repository — only the GitHub issue was opened for these items, per `issue.md` AC #3's own wording ("captured as new, promoted GitHub issues," not "scaffolded as active feature folders"). This wording is fixed boilerplate emitted unconditionally by `scripts/dev_tools/potential_to_issue_content.py:209` (`f"Promoted -> docs/features/active/{feature_path}/ (Issue #{issue_number})"`) regardless of whether the subsequent `new_active_feature_folder` step is ever invoked; the tool itself is unchanged by this diff, so this is inherited tool behavior, not a defect introduced here. Noted for visibility only.
4. **Informational, not attributable to this diff:** `plan.2026-07-09T11-29.md`'s "Required References" section links to `../../code-change.instructions.md` and `../../unit-test-policy.md`, neither of which exists anywhere in the repository (confirmed via repo-wide `find`). This is verbatim boilerplate carried over unchanged from `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md` (and its bundled mirror), which several other already-completed features' plans also inherited unchanged (e.g. `portable-orchestrator-state-preflight/plan.2026-07-06T09-54.md`). Pre-existing, repo-wide template defect; out of scope for this feature's diff.

## Overall Code-Review Verdict: PASS (2 Minor findings, 2 informational notes; 0 Blocking, 0 Major)
