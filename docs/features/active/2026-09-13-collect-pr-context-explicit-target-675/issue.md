# collect-pr-context-explicit-target (Issue #675)

- Date captured: 2026-09-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/collect-pr-context-explicit-target/ (Issue #675)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #675
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/675
- Last Updated: 2026-09-14
- Work Mode: full-bug

## Summary

`mcp__drm-copilot__collect_pr_context` resolves the branch and diff base from the invoking session's workspace rather than from an explicit target supplied by the caller, and it emits a context containing a zero-line diff without signalling an error. The two defects compound: a call made from a coordinating session produces a vacuous PR context that is indistinguishable from a legitimately empty result, and that context propagates into a PR body.

This is defect 3.5 of the `worktree-scoped-state-resolution` epic and shares the epic's root cause: state resolved against the invoking session's current working directory instead of against the call's actual target.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable; the affected surface is TypeScript under `extensions/drm-copilot/`
- Command/flags used: `mcp__drm-copilot__collect_pr_context` with `workspace_root` and `base`
- Data source or fixture: TaskMaster parallel run `bugs-2026-09-11` (2026-09-12/13)

## Steps to Reproduce

1. From a coordinating orchestration session whose current worktree is worktree A, invoke `collect_pr_context` intending to collect context for the change that lives in worktree B.
2. Observe the returned summary artifact `artifacts/pr_context.summary.txt`.
3. Re-run the same collection from inside worktree B and compare the two artifacts.

## Expected Behavior

The call identifies the branch and diff base it pertains to from an explicit caller-supplied target, not from the invoking session's workspace. When the resulting diff is empty, the call fails with a specific, actionable error rather than returning a context that reports no changes.

## Actual Behavior

The first invocation returned a PR context whose diff was empty, because it reflected the invoking session's worktree branch rather than the target branch. The call returned `ok`, so the empty result read as a successful collection. It was corrected only by re-running the tool from inside the fix worktree.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: not captured at the time; the observation is recorded in the epic manifest `docs/features/epics/worktree-scoped-state-resolution/epic.md` under scope row 3.5.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A vacuous PR context is a silent failure. It is consumed by `Agent(pr-author)` to author a PR body, so an empty diff summary reaches a human reviewer as an assertion that the branch contains no changes.

## Suspected Cause / Notes

Files to inspect (verified present 2026-09-13):

- `extensions/drm-copilot/src/lib/pr-context/` — 16 files, including `pr-context-service-call.ts`, `git-client.ts`, `collector-core.ts`, `collector-output.ts`, `models.ts`, `render.ts`.
- `extensions/drm-copilot/src/pr-context-branches.ts`.
- `extensions/drm-copilot/src/mcp-tool-definitions.ts` and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` — the tool is declared in both; a parameter addition must be applied consistently to both or the declarations drift.
- `extensions/drm-copilot/src/mcp-tools.ts` — dispatch.

`CollectPrContextServiceCallInput` in `pr-context-service-call.ts` currently carries `workspaceRoot` and `base` only; there is no target branch or target worktree parameter, so the branch under description is whatever the workspace root resolves to.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: table-driven Jest tests over the cross product of invoking-session worktree versus explicit target, and diff-present versus diff-empty. Existing suites to extend live under `extensions/drm-copilot/test/`, specifically `test/lib/pr-context/pr-context-service-call.test.ts`, `test/extension.collect-pr-context.test.ts`, and `test/repo-automation-dispatch-pr-context-verification.test.ts`.
- [x] Integration scenario to retest: a collection whose explicit target differs from the invoking session's worktree must describe the target.
- [x] Manual verification notes: the MCP surface resolves its resources from the installed VS Code extension, so the change is inert at the live tool until the extension is rebuilt and reinstalled. That rebuild is epic feature F7 and is out of scope here. Verification must assert against the Jest suite and the source, not against the installed tool.

Open design decision for `spec.md`: whether the explicit target is required or optional-with-fallback. A silent fallback to the session worktree reintroduces the defect, so an optional target must make the fallback observable in the output.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch

## Outcomes (recorded 2026-09-17)

Delivered on branch `feature/2026-09-13-collect-pr-context-explicit-target-675`. Summary of what shipped, per `spec.md`:

- An optional `target_ref` parameter was added to the `collect_pr_context` MCP tool (both `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` declarations), resolved and validated in `mcp-tool-inputs.ts`, and threaded through `RepoAutomationService.collectPrContext` and `collectPrContextServiceCall` into the collector's existing `head` option. `required` stays `["workspace_root", "base"]`; an empty or whitespace-only `target_ref` is rejected rather than treated as absent.
- Two new failure modes were introduced, replacing the prior silent-success behavior on an empty diff:
  1. **Refs unresolved** — the requested base or the attempted head ref did not resolve.
  2. **Refs resolved, no file changed** — the merge base and head resolved but the diff carries zero changed files.
  Both raise from `collectPrContextServiceCall` only after both artifacts are written and read-back-verified, so the summary/appendix remain the operator's primary diagnostic.
- A machine-readable provenance record (`target_resolution`, `resolved_head_ref`, `resolved_head_sha`) and a human-readable `Head ref (source):` summary line make the session-fallback path observable in both the returned result and the written artifact.
- All `.claude/**` prose documenting `target_ref` is deferred to epic feature F7 (`taskmaster-push-down-and-resume`), per Decision 7 of `spec.md`; this feature touches no file under `.claude/` or `extensions/drm-copilot/resources/`.
- The change is inert at the live `mcp__drm-copilot__collect_pr_context` MCP tool until F7 rebuilds and reinstalls the extension; no acceptance criterion in this feature calls the live tool.
