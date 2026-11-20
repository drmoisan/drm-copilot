# repo-housekeeping-audit - Refactor Plan

- **Issue:** 340
- **Parent (optional):** none
- **Owner:** Dan Moisan
- **Last Updated:** 2026-07-09T11-29
- **Status:** Draft
- **Version:** 0.1

## Required References (read, do not restate)

- Coding workflow and standards: [`docs/code-change.instructions.md`](../../code-change.instructions.md)
- Unit test policy: [`docs/unit-test-policy.md`](../../unit-test-policy.md)

## Strategy

This plan documents a retroactive formalization of already-completed repository housekeeping. The orchestrator performed the audit (inventory via three research reports, then structural changes committed as `541efcd` on branch `drm-copilot-wt-2026-07-09T09-26`) before this plan was authored. This plan does not precede the implementation; it exists to satisfy the standard small-path lifecycle (promotion -> active folder -> plan -> verification -> review -> PR) for traceability, as required by the orchestration checkpoint's routing-contract obligations for a housekeeping task. Phases 1 and 2 below record what was actually done and are marked complete. Phase 3 is the genuine remaining work: independently re-verifying the current repository state (not re-doing the housekeeping itself).

Fail-closed evidence rule: Phase 3 verification tasks must produce an auditable artifact per task; a task without a written artifact must not be marked complete, and the phase must not be reported PASS while any Phase 3 task remains unchecked or lacks its artifact.

Evidence accounting rule: every Phase 3 task below names its expected evidence artifact path under `docs/features/active/repo-housekeeping-audit/evidence/`. Do not mark a Phase 3 task complete without that artifact on disk.

## Work Breakdown

### Phase 1 — Inventory & Plan [100%]

- [x] [P1-T1] Enumerate delivery status of all 12 `docs/features/active/*` folders against GitHub issue/PR state, cross-checked against source files in the working tree — completed and recorded in `docs/research/2026-07-09-active-features-delivery-status-audit.md`.
- [x] [P1-T2] Audit `docs/features/potential/*` (including `promoted/`) for entries duplicating `docs/features/active/`, `docs/features/archive/`, or `docs/features/completed/` content — completed and recorded in `docs/research/2026-07-09-potential-entries-duplicate-audit.md`.
- [x] [P1-T3] Scan `docs/`, `README.md`, and feature-folder audit artifacts for identified-but-unresolved technical debt lacking a tracked GitHub issue — completed and recorded in `docs/research/2026-07-09-remaining-technical-debt-audit.md`.
- [x] [P1-T4] Confirm invariants and non-goals for the change: no production code diff, no per-language toolchain applicable, `git mv` only for relocations (no content edits) — confirmed in `docs/features/potential/promoted/2026-07-09-repo-housekeeping-audit.md` under "Constraints & Risks."

### Phase 2 — Execute Structural Changes [100%]

- [x] [P2-T1] Relocate the 12 delivered `docs/features/active/*` folders to `docs/features/completed/*` via `git mv` — committed in `541efcd`; verified present under `docs/features/completed/` (e.g. `2026-04-04-potential-entry-opening-different-ide-116`, `2026-07-03-fix-convertto-commandresult-empty-array-298`, `2026-07-03-pester-completion-consistency-301`, `2026-07-04-bundle-model-routing-deps-312`, `2026-07-04-codex-agent-role-config-306`, `2026-07-04-enforce-model-selection-routing-305`, `2026-07-04-release-flow-wait-for-ci-310`, `2026-07-06-fix-subagent-tree-discovery-terminal-325`, `2026-07-07-epic-single-home-manifest-331`, `2026-07-07-nested-worktree-folder-scheme-328`, `portable-orchestrator-state-preflight`, `subagent-tree-command`) and absent from `docs/features/active/`.
- [x] [P2-T2] Reconcile GitHub issue #116 (open, with merged PRs #119/#137 lacking a closing keyword) per the delivery-status audit's recommendation — recorded via the GitHub API, not part of the `541efcd` file diff.
- [x] [P2-T3] Open and promote tracked GitHub issues for the genuinely outstanding technical-debt items identified in `docs/research/2026-07-09-remaining-technical-debt-audit.md` (issues #335, #336, #337, #338) — recorded via the GitHub API, not part of the `541efcd` file diff.
- [x] [P2-T4] Restore the root `CLAUDE.md` from git history, after verifying every path it references resolves in the current tree — committed in `541efcd`.
- [x] [P2-T5] Refresh `README.md`'s skill/agent/command/MCP-tool inventory against the current repository state — committed in `541efcd`.

### Phase 3 — Verification & Cleanup [100%]

- [x] [P3-T1] Run `git log -1 --format=%H` and `git status --porcelain` against the current working tree at `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-09T09-26`; confirm `541efcd` is present as HEAD or an ancestor of HEAD on branch `drm-copilot-wt-2026-07-09T09-26`, and confirm the working tree is clean at that commit. Write the command output to `docs/features/active/repo-housekeeping-audit/evidence/baseline/p3-t1.git-state.<timestamp>.md`.
- [x] [P3-T2] Enumerate all entries under `docs/features/active/` and confirm the only entry present is `repo-housekeeping-audit` itself (no other delivered-but-unrelocated folder has appeared since `541efcd`). Write the enumerated listing to `docs/features/active/repo-housekeeping-audit/evidence/other/p3-t2.active-folder-listing.<timestamp>.md`.
- [x] [P3-T3] Confirm each of the 12 folder names listed in Phase 2, task P2-T1 is present under `docs/features/completed/` and absent from `docs/features/active/`, by directory listing. Write the confirmation to `docs/features/active/repo-housekeeping-audit/evidence/other/p3-t3.relocation-confirmation.<timestamp>.md`.
- [x] [P3-T4] For every file path referenced inside the current root `CLAUDE.md` (including each `.github/instructions/*.instructions.md` file, each `.claude/rules/*.md` file it names, and `.github/copilot-instructions.md`), confirm the path resolves in the current working tree. Write the per-path resolution results to `docs/features/active/repo-housekeeping-audit/evidence/other/p3-t4.claude-md-path-resolution.<timestamp>.md`.
- [x] [P3-T5] For every skill, agent, MCP tool, and VS Code command name currently listed in `README.md`, confirm it matches its current source-of-truth file (`.claude/skills/<name>/SKILL.md`, `.claude/agents/<name>.md`, `extensions/drm-copilot/package.json` `contributes.commands`, and the MCP tool registrations in `extensions/drm-copilot/src/mcp-server.ts`). Write the per-item match results to `docs/features/active/repo-housekeeping-audit/evidence/other/p3-t5.readme-inventory-verification.<timestamp>.md`.
- [x] [P3-T6] Run `gh issue view 335 --repo drmoisan/drm-copilot`, `gh issue view 336 --repo drmoisan/drm-copilot`, `gh issue view 337 --repo drmoisan/drm-copilot`, `gh issue view 338 --repo drmoisan/drm-copilot`, and `gh issue view 340 --repo drmoisan/drm-copilot`; confirm each reports state OPEN. Run `gh issue view 116 --repo drmoisan/drm-copilot`; confirm it reports state CLOSED. Write the raw command output for all six checks to `docs/features/active/repo-housekeeping-audit/evidence/other/p3-t6.issue-state-verification.<timestamp>.md`.
- [x] [P3-T7] Write a pass/fail verification summary artifact recording the outcome of P3-T1 through P3-T6 to `docs/features/active/repo-housekeeping-audit/evidence/other/p3-verification-summary.<timestamp>.md`, including `Timestamp:`, the command run for each check, and the pass/fail result for each.

## Test Plan

No per-language toolchain (format/lint/type-check/test) applies to this feature: commit `541efcd` changed zero production or test files (only `docs/features/**` relocations, `README.md`, and `CLAUDE.md`). The applicable "test plan" for this feature is the Phase 3 verification-task list above, which independently re-checks the current repository state rather than re-running any coding toolchain.

- Unit/Integration: not applicable — no source module was added, removed, or modified.
- CLI/Workflow: not applicable — no CLI, command, or workflow surface changed.
- Tooling: not applicable — no lint/type-check target changed.
- Coverage evidence: not applicable — no in-scope language has changed lines to measure coverage against.

## Rollback / Contingency

`541efcd` is a single, self-contained commit limited to `docs/features/**` relocations, `README.md`, and `CLAUDE.md`. `git revert 541efcd` reverses all of it cleanly: it restores the 12 folders to `docs/features/active/`, reverts the `README.md` refresh, and re-removes the restored `CLAUDE.md`. The GitHub issue actions (opening #335-#338, closing/reconciling #116) are not part of the commit and would need to be reversed separately via `gh issue reopen`/`gh issue close` if a rollback of this scope were ever required; this plan does not anticipate that being necessary.

## Open Questions / Notes

- This plan was authored after the implementation it documents. The orchestrator performed the audit and committed the structural changes (`541efcd`) before this plan file existed, then instructed retroactive formalization through the standard small-path lifecycle so the orchestration checkpoint's routing-contract requirements are satisfied for this housekeeping task. Phases 1 and 2 above are historical records of completed work, not forward-looking task assignments.
- Phase 3 is the only phase representing genuine unperformed work as of this plan's authoring; `atomic-executor` must execute each Phase 3 task for real against the current repository state and must not mark a task complete on the basis of the historical audit reports alone.
- The mapping from technical-debt findings in `docs/research/2026-07-09-remaining-technical-debt-audit.md` to specific issue numbers #335-#338 was not independently re-derived by the author of this plan; P3-T6 is the mechanism by which that claim is checked against the live GitHub issue tracker rather than assumed.
