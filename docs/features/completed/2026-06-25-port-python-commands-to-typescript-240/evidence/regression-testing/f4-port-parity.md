# F4 Behavior-Parity Capture

Timestamp: 2026-06-26T00-50

Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (full suite, run from `extensions/drm-copilot/`)

EXIT_CODE: 0

Output Summary: 641 passed / 641 total; 56 suites passed. The TypeScript port
`src/lib/collect-commit-context.ts` reproduces the observable behavior of
`extensions/drm-copilot/resources/templates/collect_commit_context.py`. Each
parity property below maps to a passing test.

Parity properties confirmed (test references):

- Identical git argument lists and per-call `allowError` flags:
  - `test/lib/collect-commit-context.run-git.test.ts` — "invokes the runner with git args, cwd, and allowError per call" asserts `["git","remote","-v"]` with `allowError:false` (Python `check=True`) and the upstream call with `allowError:true` (Python `allow_error=True`). The source arg lists and allowError flags are ported one-to-one in source order in `collectCommitContext`.
- `runGit` strip + allowError return semantics:
  - "returns the trimmed captured stdout for an allowError call that fails" and "renders the empty-result placeholder when an allowError call returns empty stdout" in the run-git suite; "propagates a thrown error from a mandatory (allowError false) call" confirms the Python `check=True` raise path.
- Thirteen section headers present:
  - `test/lib/collect-commit-context.test.ts` — "contains all thirteen expected section headers" (the same 13 headers asserted by the Python `test_output_contains_expected_sections`, plus the Change-intent header).
- Placeholder strings:
  - "renders (no upstream) ...", "renders (no staged changes) ...", "renders (no unstaged changes) ...", "renders (no untracked files) ...", "renders (no changes) ...", "renders (no Python files changed) ...", "renders (no previous commits) ..." in `collect-commit-context.test.ts`.
- Python-file filter (keep only `.py`):
  - "filters changed files to keep only .py entries" (`file1.py`/`file3.py` present; `file2.txt`/`README.md` absent), mirroring Python `test_filters_python_files`.
- Last-commit formatting (`commit`, `Author:`, `AuthorDate:`, `Commit:`, `CommitDate:`, indented subject/body lines):
  - "formats the last commit with all header fields and indented body lines", mirroring Python `test_formats_last_commit_correctly`.
- Parent-directory creation observed:
  - "ensures the parent directory of the output path is created" asserts `ensureDir("/workspace/artifacts")`; integration coverage in `test/extension.collect-commit-context.integration.test.ts` ("writes an artifact containing all required sections ...") and `test/extension.collect-commit-context-inprocess.test.ts` ("writes the artifact in-process ...").
- Printed `Commit context written to: <path>` line:
  - "emits the written-path message through the log callback" asserts the exact message text via the injected `log` sink.
- Service return contract unchanged (tool / workspaceRoot / summary / artifacts):
  - `test/repo-automation-dispatch.test.ts` — "collectCommitContext runs in-process using the injected runner and filesystem" asserts `result.artifacts === ["C:/workspace/artifacts/commit_context.txt"]`, the workspace cwd on git calls, the write, and that no Python `.py` is spawned. `test/mcp-server.test.ts` continues to assert the unchanged tool name and return shape.
