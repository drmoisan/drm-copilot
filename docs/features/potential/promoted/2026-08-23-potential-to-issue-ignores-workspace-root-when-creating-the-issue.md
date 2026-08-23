# potential-to-issue-ignores-workspace-root-when-creating-the-issue (Issue #599)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-to-issue-ignores-workspace-root-when-creating-the-issue/ (Issue #599)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #599
- Issue URL: https://github.com/drmoisan/TaskMaster/issues/599
- Last Updated: 2026-08-23
## Summary

`mcp__drm-copilot__potential_to_issue` honours its `workspace_root` parameter when writing the promoted record to disk, but ignores it when creating the GitHub issue — the issue is always created in the repository the MCP server resolves from its own context. Promoting a defect into a repository other than the one the server defaults to therefore lands the record and the issue in **different repositories**, and every such promotion needs a manual `gh issue transfer` afterwards.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — MCP tool surface
- Command/flags used: `mcp__drm-copilot__potential_to_issue` with `workspace_root` set to a checkout other than the server's default, `promotion_type: bug`, `work_mode: full-bug`
- Data source or fixture: three consecutive promotions on 2026-08-21 and 2026-08-23

## Steps to Reproduce

1. Call `mcp__drm-copilot__new_potential_bug_entry` with `workspace_root` pointing at repository B (not the server's default repository A). The record is correctly created under B.
2. Edit the record in B.
3. Call `mcp__drm-copilot__potential_to_issue` with the same `workspace_root` (B) and the record's B-relative path.
4. Read the returned `artifacts` URL and the returned `destination_path`.

## Expected Behavior

Both outputs should refer to the same repository. Given `workspace_root` = B, the issue should be created in B, matching the promoted record written under B. `workspace_root` is the only repository-selection parameter the tool exposes, so it should govern both effects.

## Actual Behavior

`destination_path` is under B — correct — while the `artifacts` URL names an issue in A. The two halves of one promotion diverge.

Observed three times, all with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot`:

| Record written under | Issue created in | Required transfer |
| --- | --- | --- |
| `drm-copilot/docs/features/potential/promoted/…pretooluse-hooks-parse-flat-payload…` | `drmoisan/TaskMaster#579` | → `drm-copilot#501` |
| `drm-copilot/docs/features/potential/promoted/…get-plan-paths-extracts-angle-bracket-placeholders…` | `drmoisan/TaskMaster#580` | → `drm-copilot#502` |
| `drm-copilot/docs/features/potential/promoted/…epic-require-complete-demands-launch-binding…` | `drmoisan/TaskMaster#598` | → `drm-copilot#524` |

Each needed a manual `gh issue transfer` to reconcile. Transfer works and preserves comments, so the end state is recoverable — but it renumbers the issue, which invalidates any reference written before the transfer.

Two consequences beyond the inconvenience:

1. **Silent misfiling is the default outcome.** Nothing in the result signals the mismatch; the call reports `ok: true` with a plausible URL. An operator who does not cross-read `destination_path` against the `artifacts` URL will leave the issue in the wrong repository. That is how three earlier defects came to be filed against the wrong repository before the ownership boundary was understood.
2. **Issue numbers collide across the two repositories.** Both are in the 400-500 range, so a misfiled number frequently resolves to a real but unrelated issue in the wrong repository rather than to nothing. A reader following the reference lands on the wrong ticket with no error.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet — one call, showing the divergence in a single result:

  ```json
  {
    "ok": true,
    "tool": "potential_to_issue",
    "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot",
    "artifacts": ["https://github.com/drmoisan/TaskMaster/issues/598"],
    "destination_path": "C:/Users/DanMoisan/repos/drm-copilot/docs/features/potential/promoted/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes.md"
  }
  ```

  `workspace_root` and `destination_path` agree on `drm-copilot`; `artifacts` names `TaskMaster`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. It is fully recoverable per occurrence, but the failure is silent, the default outcome is wrong, and the consequence is a defect tracked in the wrong repository. In a two-repository push-down arrangement — where an upstream fix is the *only* durable fix for a large class of defects — misfiling upstream work into the destination is the specific error this tooling should prevent rather than cause.

## Suspected Cause / Notes

- The issue-creation step most likely shells `gh issue create` without `--repo`, letting the GitHub CLI resolve the repository from its own working directory rather than from `workspace_root`. The file-writing step correctly joins against `workspace_root`, which is why only one half is wrong.
- The fix is probably to derive the repository from `workspace_root` — via its `origin` remote — and pass it explicitly, for example `gh issue create --repo <owner>/<name>`.
- Consider also returning the resolved target repository in the result, so a caller can assert it. A silent default is what makes this dangerous; an explicit echoed value makes a mismatch visible at the call site.
- Worth checking whether sibling tools share the pattern. `new_potential_bug_entry` and `new_potential_entry` honour `workspace_root` correctly because they only touch the filesystem, but any tool that both writes files and calls a remote API is a candidate — `collect_pr_context` is already known to write to the main checkout while reporting worktree paths (tracked separately as TaskMaster #589), which looks like the same class of defect: a parameter respected for one effect and ignored for another.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — a case asserting the repository passed to the issue-creation call is derived from `workspace_root`, not from the process working directory. Cover the case where `workspace_root` differs from the server's default, since that is the only case that fails today.
- [x] Integration scenario to retest — promote a throwaway record with `workspace_root` set to a non-default checkout and assert the returned issue URL names that checkout's repository. Delete the throwaway issue afterwards.
- [x] Manual verification notes — keep a same-repository promotion in the same test pass, to confirm the fix does not break the common case where `workspace_root` already matches the default. That path works today and must keep working.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
