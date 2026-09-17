Timestamp: 2026-09-17T14:35Z

POSTING BLOCKED: this plan contains no task instructing a live GitHub call (e.g. `gh issue comment` or `gh issue edit`) against issue #675, and none was made. The text below was mirrored into the local `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/issue.md` file (under the appended `## Outcomes (recorded 2026-09-17)` section) at P9-T6, but was not posted to the live GitHub issue.

Exact text intended for issue #675:

---

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

---

PostedAs: unknown (not posted to the live GitHub issue by this plan; mirrored to the local `issue.md` file only).
