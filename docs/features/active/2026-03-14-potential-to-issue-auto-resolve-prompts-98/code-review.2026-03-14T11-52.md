# Code Review: potential-to-issue-auto-resolve-prompts (#98)

**Review Date:** 2026-03-14  
**Feature Folder:** `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98`  
**Feature Folder Selection Rule:** User-specified active folder for issue `#98`; no alternate active folder needed tie-breaking.  
**Base Branch:** `feature/expose-placeholder-commands-92`

## Executive summary

The reviewed working-tree change is small, focused, and aligned with the issue: `extensions/drm-copilot/src/extension.ts` now prefers the active `docs/features/potential/*.md` editor path, and `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` adds three regression scenarios that prove auto-resolution and prompt retention. Automated evidence is strong: fail-before evidence exists, final feature-folder QA gates are all green, and an in-session extension-local quality pass also passed.

Top 3 risks:
1. The reviewed diff is still uncommitted, so the canonical PR summary has no commit-range diff and cannot serve as a merge snapshot yet.
2. `getActivePotentialPath()` lowercases paths for comparison; that matches Windows behavior, but it is worth keeping in mind for any future platform-specific path rules.
3. The feature folder has strong automated coverage but no separate end-to-end destination-workspace manual verification artifact.

**PR readiness recommendation:** **No-Go for immediate merge as a branch snapshot.** The implementation quality looks good, but the branch needs the reviewed diff committed/pushed before it can be treated as merge-ready.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `artifacts/pr_context.summary.txt` / branch state | Base/Head section | The refreshed canonical PR summary reports `HEAD` equal to `origin/feature/expose-placeholder-commands-92`, so the reviewed implementation exists only as working-tree state. | Commit and push the audited extension/test changes, then refresh `pr_context` again. | Review artifacts should describe a mergeable branch delta, not only local unstaged edits. | `artifacts/pr_context.summary.txt` shows identical base/head SHA; `artifacts/pr_context.appendix.txt` shows the real diff under `Working tree diff (unstaged)`. |
| Minor | `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98` | evidence inventory | There is no separate destination-workspace manual verification note beyond automated Jest evidence. | Optionally add a short manual verification note after exercising the command in a destination workspace. | Automated evidence is solid, but a tiny manual note would fully mirror the issue’s validation ideas. | `issue.md` Proposed Fix / Validation Ideas mentions the destination-workspace retest; feature evidence currently contains baseline/regression/QA artifacts only. |

## TypeScript implementation audit

### What changed well

- `extensions/drm-copilot/src/extension.ts:20-44` introduces a compact helper instead of inlining path logic inside the command body.
- `extensions/drm-copilot/src/extension.ts:293-306` keeps the existing file-picker fallback intact and only bypasses it when the active editor is already a valid potential markdown file.
- `extensions/drm-copilot/test/extension.potential-to-issue.test.ts:200-270` adds direct behavioral tests for the exact regressions described in `issue.md`.

### Type safety and maintainability

- The new helper is fully typed (`string -> string | undefined`) and adds no `any`-style weakening.
- No new suppression comments or config loosening were introduced.
- The change preserves the existing separation between UI prompting and bundled-script execution.

### Error handling and logging

- The new path-resolution logic fails closed by returning `undefined` for invalid or out-of-scope active files, allowing the command to reuse the existing picker path.
- Existing runtime-missing and child-process failure tests remain intact, so the new path logic does not weaken error handling.

## Test quality audit

- **Deterministic:** all VS Code and process interactions are mocked.
- **Isolated:** each new `it()` block asserts one user-observable behavior.
- **Fast:** post-change suite stays at 74 tests in under half a second.
- **Good diagnostics:** fail-before evidence clearly names each missing behavior.

## Security and correctness checks

- No secrets or credentials were added.
- No unsafe subprocess construction was introduced; the handler still forwards explicit argument pairs to the existing execution layer.
- Input validation is conservative: the helper only reuses active files that live under `docs/features/potential/` and end in `.md`.

## Research log

No external research was required; repository policies, the feature-folder evidence, and the current workspace diff were sufficient.

## Verdict

The implementation itself is in good shape: focused, typed, and well-covered. The blocking issue is procedural rather than behavioral—the branch snapshot does not yet contain the reviewed diff. Once the current working-tree changes are committed and `pr_context` is refreshed, this review would otherwise be a calm sea rather than stormy weather.
