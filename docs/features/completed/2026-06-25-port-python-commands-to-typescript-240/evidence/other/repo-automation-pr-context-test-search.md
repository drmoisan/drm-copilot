# P8-T5 — Repo-automation PR-context Python-spawn Test Search (F9)

Timestamp: 2026-06-26T10-02

SearchScope: extensions/drm-copilot/test/
SearchPatterns: collect_pr_context, collectPrContext, executeBundledScriptFromExtensionRoot, child_process.spawn argv assertions for the pr-context collector
SearchResult: Two test files contained Python-spawn assertions for collect_pr_context and were rewritten to the in-process contract:
- extensions/drm-copilot/test/repo-automation-dispatch.test.ts
  - Removed two cases that asserted `executable === "python"` / `py -3` fallback spawning `resources/templates/collect_pr_context.py` with `--base/--repo-root/--out/--appendix-out` argv.
  - Replaced with one in-process case that injects a fake CommandRunner + FileSystem (extended with exists/isDirectory/listDirectory), asserts `childProcessMock.spawn` is not called, asserts both `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are written through the FS, and asserts the preserved result contract (tool/summary/artifacts).
- extensions/drm-copilot/test/extension.integration.test.ts
  - Reworked three collectPrContext cases (`executes bundled wrapper script in destination workspace`, `handles workspace paths with spaces or unicode`, `writes summary and appendix artifacts`) to assert the in-process path: no Python spawn, both artifacts written through the mocked node:fs, and the canonical summary/appendix section markers present.
  - Extended the file's node:fs mock additively (statSync/readdirSync/readFileSync/writeFileSync/mkdirSync) to support the in-process collector's RealFileSystem; removed the now-unused isPlaceholderOnlyArtifact helper.

All reworked tests pass with zero assertions that a `collect_pr_context.py` Python process is spawned. The only remaining textual references to `collect_pr_context.py` are negative assertions (confirming no such spawn) and unrelated diff-fixture path strings.
