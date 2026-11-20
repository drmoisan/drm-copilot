# Potential Entries Duplicate Audit

- Date: 2026-07-09
- Type: One-off repository housekeeping audit
- Scope: `docs/features/potential/` (including `promoted/`) versus `docs/features/active/`, `docs/features/archive/`, `docs/features/completed/`

## Automation Feasibility

N/A — no third-party UI interaction; filesystem and repo grep only.

## Summary

- `docs/features/potential/` contains only `README.md`, `template.md`, and the `promoted/` subdirectory. No un-promoted candidate `.md` entries exist directly under `docs/features/potential/` at this time.
- `docs/features/potential/promoted/` contains exactly two entries (plus a `.gitkeep`), and both are confirmed genuine promotion pairs with existing `docs/features/active/` folders — not duplicates to delete.
- The documented/implemented convention is that files moved into `promoted/` stay there permanently as the historical record of promotion; no code path deletes or relocates them afterward.
- A secondary scan of `docs/features/archive/` (34 folders) and `docs/features/completed/` (47 of 48 folders enumerated) found several similarly-named folder pairs; all inspected pairs are legitimate sequential/follow-up work items, not exact duplicates of the same underlying feature or bug.

## Documented Convention

No document (`docs/features/potential/README.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`) explicitly states "retain" or "delete" in those words for files inside `docs/features/potential/promoted/`. The convention is established by the only two production implementations of the promotion workflow, both of which treat the move into `promoted/` as the terminal step with no subsequent deletion logic anywhere in the repository:

- `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts:422-434` — builds `docs/features/potential/promoted` as `promotedDir`, calls `filesystem.ensureDir(promotedDir)`, then `filesystem.move(resolved, destPath)` and emits `Moved potential file to promoted folder: ${destPath}`. This is the final action of `promotePotential()`; the function returns immediately after.
- `scripts/dev_tools/potential_to_issue.py:543-547` — the byte-parity Python source performs the identical terminal move: `promoted_dir = workspace_path / "docs" / "features" / "potential" / "promoted"`, `filesystem.ensure_dir(promoted_dir)`, `dest_path = promoted_dir / resolved.name`, and emits the same "Moved potential file to promoted folder" message.
- A repo-wide grep for `delete|remove|cleanup|unlink` (case-insensitive) under `extensions/drm-copilot/src/lib/potential-to-issue/` returned only unrelated string-manipulation helper docstrings (`content.ts:81,101,118` — heading/suffix stripping, not file deletion). No deletion logic targeting `promoted/` exists in either language implementation.
- `docs/features/potential/README.md:1-8` describes only the forward path (create potential doc → open issue → move into `active/`); it says nothing about removing the `promoted/` marker after the active folder is later archived or completed.
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` (full file read) documents the MCP-only promotion command sequence and checkpoint receipt fields; it does not reference `promoted/` at all, and contains no instruction to delete promotion markers.

**Conclusion:** the `promoted/` marker files are intentionally retained as the permanent historical record that promotion occurred, consistent with the task framing. Neither promoted file in this repository should be deleted.

## Potential Entries — Duplicate Determination

| Potential Entry Path | Slug | Duplicate Target | Confidence | Recommendation | Rationale |
|---|---|---|---|---|---|
| `docs/features/potential/promoted/2026-07-06-portable-orchestrator-state-preflight.md` | `portable-orchestrator-state-preflight` | `docs/features/active/portable-orchestrator-state-preflight/` | High | RETAIN | The promoted file's own `Status:` line reads `Promoted -> docs/features/active/portable-orchestrator-state-preflight/ (Issue #321)`. Read both sides: the promoted file's Problem/Proposed Behavior/Acceptance Criteria describe the portable `.claude` orchestrator-state preflight hook rewrite for Issue #321; the active folder (`plan.2026-07-06T09-54.md`, `code-review.*`, `feature-audit.*`, `policy-audit.*`) exists and tracks the same issue number and scope. This is the expected post-promotion state per the documented convention above, not a duplicate requiring deletion. |
| `docs/features/potential/promoted/2026-07-06-subagent-tree-command.md` | `subagent-tree-command` | `docs/features/active/subagent-tree-command/` | High | RETAIN | The promoted file's `Status:` line reads `Promoted -> docs/features/active/subagent-tree-command/ (Issue #320)`. Read both sides: the promoted file describes the VS Code `drmCopilotExtension.showSubagentTree` command for Issue #320; the active folder (`plan.2026-07-06T22-35.md`/audit artifacts observed via glob) exists and tracks the same feature. Expected post-promotion state, not a duplicate to delete. |
| (no other un-promoted `.md` files found under `docs/features/potential/`) | — | — | — | — | `Glob docs/features/potential/*.md` returned only `README.md` and `template.md`. There are currently no un-promoted candidate entries sitting directly under `docs/features/potential/`. |

No entries in this table warrant a DELETE or NEEDS_HUMAN_REVIEW recommendation.

## Cross-Duplicates in archive/completed

Secondary, lower-priority scan. Enumerated folder names: all 34 folders under `docs/features/archive/` (confirmed complete by month-range enumeration) and 47 of 48 folders under `docs/features/completed/` (one folder not individually re-confirmed; the gap does not affect the conclusions below since no similarly-named pair points to it).

Candidate look-alike pairs identified by name similarity, then checked by reading each pair's `issue.md` header/Problem section:

1. `docs/features/archive/2026-03-21-bundle-sync-agents-113/` vs `docs/features/archive/2026-04-05-fix-sync-agents-bundling-120/` — Not a duplicate. #113 is a `full-feature` request to expose an existing sync-agents script through the extension command surface; #120 is a `full-bug` filed two weeks later against a defect in that same bundling mechanism. Sequential feature-then-bugfix, not a double-filed duplicate.
2. `docs/features/completed/2026-06-24-push-down-language-packs-csharp-variant-226/` vs `docs/features/completed/2026-07-02-codex-push-down-language-packs-269/` — Not a duplicate. #226 scopes the C#-variant push-down behavior for the Claude `.claude` bundle; #269's own Problem section explicitly frames itself as the Codex/`.agents` analog "Unlike the completed Claude push-down [...]", i.e., a deliberate follow-on to a different bundle (`.codex`/`.agents`), not a repeat of #226.
3. `docs/features/completed/2026-07-02-codex-worktree-session-failures-268/` vs `docs/features/completed/2026-07-03-codex-worktree-session-regression-281/` — Not a duplicate. #268 is the original bug report (`full-bug`, 2026-07-02); #281 is a `full-bug` filed the next day titled "regression," i.e., a fresh recurrence after the first fix, not a duplicate filing of the same unresolved report.
4. `docs/features/completed/npm-audit-gate-and-dependabot/` vs `docs/features/completed/npm-dependency-vulnerability-remediation/` — Not a duplicate. `npm-dependency-vulnerability-remediation`'s Problem section reports the original `npm audit` findings (25 vulnerabilities) and remediates them; `npm-audit-gate-and-dependabot`'s Problem section opens with "Follow-up to PR #209 (`fix(deps): eliminate npm audit vulnerabilities`)" and adds a preventive CI gate plus Dependabot — an explicit, self-declared follow-up, not a re-filed duplicate.

No genuine same-feature-filed-twice duplicates were found in this pass.

---

## Correction — 2026-08-20 (issue #487)

The claim made at line 15 and repeated at line 28 of this document — that files moved into `promoted/` "stay there permanently as the historical record of promotion; no code path deletes or relocates them afterward" — **was false when it was written and has been falsified by issue #487**. The historical body above is preserved unchanged; this note is appended, not substituted.

**What actually happened.** A code path did relocate promoted records. `new_active_feature_folder` unconditionally MOVED the resolved potential file into the active folder as `issue.md`, at both of its placement sites (`extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts:283` in the minor-audit branch and `:346` in the full branch, with the byte-parity Python at `scripts/dev_tools/new_active_feature_folder_flow.py:206` and `:266`). When the resolved source was a promoted record, the move deleted it. The promotion history was therefore destroyed on every full-lifecycle run in which `potential_to_issue` was followed by `new_active_feature_folder`.

**Why this audit missed it.** The supporting evidence at line 24 was a repo-wide grep for `delete|remove|cleanup|unlink` (case-insensitive) scoped to `extensions/drm-copilot/src/lib/potential-to-issue/` **only**. That scope was too narrow in two independent ways:

1. **Wrong cluster.** The deleting code was never in the `potential-to-issue` cluster. It was in the `new-active-feature-folder` cluster, which this audit never examined in either language. Scoping a whole-repository claim ("no code path anywhere") to a single directory cannot establish it.
2. **Wrong search terms.** Even applied to the correct directory, the term set would have missed the defect. The operation that destroyed the record was `move`, not `delete`, `remove`, `cleanup`, or `unlink`. A relocation deletes its source as a side effect, so a search for deletion verbs is not sufficient evidence for a claim about relocation — and the claim at line 15 explicitly covers relocation ("deletes or relocates").

The two implementations cited at lines 19 and 21 were read correctly: `promotePotential` and `potential_to_issue.py` do treat the move into `promoted/` as their terminal step and add no deletion logic. That observation is accurate and is not retracted. The error was in generalizing from those two functions to a repository-wide invariant without examining the workflow that consumes their output.

**Current state.** The behavior described at line 15 is now the actual behavior, but by fix rather than by prior fact. Issue #487 changed both language implementations so that a source resolved from under `docs/features/potential/promoted` is COPIED into the active folder and the promoted record is retained; a source resolved from anywhere else is still moved. Retroactive repair of records lost before that fix was explicitly out of scope, so the historical gap this defect created is permanent.

**Method note for future audits.** A negative claim of the form "no code path does X" requires either a repository-wide search or an explicit statement of the scope actually searched. This audit stated its conclusion at repository scope while searching at directory scope, and the gap between the two is exactly where the defect lived.
