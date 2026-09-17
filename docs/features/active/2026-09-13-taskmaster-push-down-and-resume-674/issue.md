# taskmaster-push-down-and-resume (Issue #674)

- Date captured: 2026-09-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/taskmaster-push-down-and-resume/ (Issue #674)
- Epic: `worktree-scoped-state-resolution` (wave 2, ref F7, complexity C2)
- Depends on: F2 `preimplementation-gate-worktree-selector`, F3 `epic-merge-gate-authorization-record`, F4 `prd-feature-gate-target-resolution`, F5 `false-approval-elimination-pr-author-model-routing`, F6 `collect-pr-context-explicit-target`

- Issue: #674
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/674
- Last Updated: 2026-09-14
- Work Mode: full-feature

## Problem / Why

`.claude/**` (166 files) plus `config/blast-radius.json` and `config/orchestration-routing.json` are
pushed from `drm-copilot` into consumer repositories with zero templating. A fix made in a consumer
repository is overwritten by the next push-down. That has already occurred: a local fix to
`enforce-model-routing-receipt.ps1` in TaskMaster (commit `4389d95b`, 2026-09-02) was lost.

The `worktree-scoped-state-resolution` epic repairs a defect class in which `drm-copilot` hooks and
MCP tools resolve orchestration state against the invoking session's current working directory
instead of against the worktree the tool call actually pertains to. Six upstream features produce
the corrected hook, library, and MCP content. Without a delivery step, that content never reaches
the repository whose stalled run motivated the epic.

TaskMaster parallel run `bugs-2026-09-11` is the consumer: a 13-item run reached a standstill with
zero agents runnable, three items merged, five blocked behind gates, and one blocked fix the
orchestration that produced it could not land.

## Proposed Behavior

Procedural delivery only. No new logic, and no change to hook or MCP behavior.

1. Rebuild and reinstall the `drm-copilot` VS Code extension so the installed extension's bundled
   payload carries the epic's corrected content.
2. Push the corrected customizations down to TaskMaster via
   `mcp__drm-copilot__push_down_claude_customizations`.
3. Confirm the destination files carry the new content by grepping for a specific changed literal.
4. Confirm TaskMaster run `bugs-2026-09-11` can resume its remediation cycles.

## The verification trap

`mcp__drm-copilot__push_down_claude_customizations` serves the **installed VS Code extension's**
bundled payload, not the repository tree at
`extensions/drm-copilot/resources/claude-customizations/`. After the upstream features' commits
land in this repository, running the push-down without a rebuild publishes the **old** files. When
the destination already carries a working local hand-fix, the push-down overwrites it with the
stale version, so the verification step actively undoes the fix it was meant to confirm.

The rebuild and reinstall must therefore be ordered strictly before the push-down, and the
staleness check must be an explicit gating task rather than an assumption.

## Acceptance Criteria (early draft)

- [ ] The installed extension's bundled payload is confirmed to carry the epic's corrected content
      before any push-down runs, proven by a grep for a specific changed literal under the installed
      extension's `resources/claude-customizations/.claude/hooks/` directory.
- [ ] The `.claude/lib/` module delivered by epic feature F1 is confirmed to be registered in
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths[]`
      before the push-down, so the push-down does not silently omit it.
- [ ] The corrected customizations are pushed down to TaskMaster.
- [ ] The destination files demonstrably carry the new content, proven by a grep for a specific
      changed literal rather than by the push-down's own exit code.
- [ ] No destination fix is overwritten with a stale version.
- [ ] Run `bugs-2026-09-11` can resume its remediation cycles.

## Constraints & Risks

- **No new logic.** This is procedural delivery. A plan that grows an implementation phase changing
  hook or MCP behavior has taken on another feature's scope.
- **No file over 500 lines.**
- Evidence paths must resolve to `<FEATURE>/evidence/<kind>/`. Paths under `artifacts/baselines/`,
  `artifacts/qa/`, and `artifacts/evidence/` are forbidden.
- Every negative claim ("the destination does not carry the old content") must record `SearchScope`,
  `SearchPatterns`, and `SearchResult`.
- The push-down's exit code reports that files were copied, not which version of them was copied. It
  is not acceptable verification evidence on its own.
- TaskMaster is a different repository and is not present in this checkout.

## Test Conditions to Consider

- [ ] Staleness check: grep the installed extension payload for a changed literal before push-down.
- [ ] Manifest registration check: F1's module path present exactly once in `core.json` `paths[]`.
- [ ] Post-push-down destination content check for the same changed literal.
- [ ] Negative-claim auditability: absence claims carry SearchScope / SearchPatterns / SearchResult.

## Human-interaction assessments (autonomous-execution mandate)

- **HI-1 — Confirm run `bugs-2026-09-11` resumes its remediation cycles.** Acts inside TaskMaster, a
  different repository not present in this checkout, and is an observation of agent behavior rather
  than a command whose exit code can be asserted. Planned response: `exception` with a
  human-exception runbook.
- **HI-2 — Rebuild and reinstall the VS Code extension before the push-down.** Whether
  `vsce package` plus `code --install-extension` runs unattended in this environment is not yet
  established. Research must record an explicit `## Automation Feasibility` assessment and resolve
  it as `scope_change`, `exception`, or `halt`.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/taskmaster-push-down-and-resume/` folder from the template
