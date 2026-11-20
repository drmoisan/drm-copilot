# Phase 9 — F9 Acceptance Criteria Verification (ts-pr-context)

Timestamp: 2026-06-26T10-56

Line-by-line pass/fail for each F9 acceptance criterion with supporting evidence.

- AC-F9-1 — PASS. All ten `pr_context/*.py` modules are ported to `extensions/drm-copilot/src/lib/pr-context/` with behavior parity (git client, gh client, feature-doc discovery, verification evidence, render, summary helpers, collector), preserving error messages, return contracts, classification, base/merge-base selection, numstat/name-status parsing, autoclose sections, digests/buckets, the UTC timestamp append, and the exact summary + appendix content and ordering.
  - Evidence: src/lib/pr-context/{models,git-client,gh-client-core,gh-client-details,verification-evidence,feature-docs,feature-docs-parsers,render,render-pr-helpers,render-feature-excerpts,summary-helpers,summary-digests,collector-core,collector-output}.ts; parity-ported test suites under test/lib/pr-context/; evidence/qa-gates/test-coverage-final.md.

- AC-F9-2 — PASS. `github.py` is split into `gh-client-core.ts` (437) + `gh-client-details.ts` (398); `collector.py` is split into `collector-core.ts` (472) + `collector-output.ts` (449). No file in `src/lib/pr-context/**` or `test/lib/pr-context/**` exceeds 500 lines (max src 481 render-pr-helpers; max test 436 gh-client-details.test).
  - Evidence: P9-T7 `wc -l` output recorded in this phase; all sizes < 500.

- AC-F9-3 — PASS. `RepoAutomationService.collectPrContext()` invokes the in-process TS port via `pr-context-service-call.ts`; no `runtimeKind: "python"` / `collect_pr_context.py` spawn remains in that method; `repo-automation-service.ts` is 481 lines (<= 500).
  - Evidence: src/repo-automation-service.ts collectPrContext delegates to collectPrContextServiceCall; `grep -c 'runtimeKind: "python"'` = 0; no `collect_pr_context.py` reference in the service file.

- AC-F9-4 — PASS. The return contract is preserved — `collectAndWrite` writes `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, and the service result returns `tool: "collect_pr_context"`, the exact summary string `Collected PR context against base '<base>'.`, and both normalized artifact paths.
  - Evidence: src/lib/pr-context/pr-context-service-call.ts; test/lib/pr-context/pr-context-service-call.test.ts (100% coverage); test/lib/pr-context/collector-integration.test.ts.

- AC-F9-5 — PASS. All ported Jest tests are hermetic (injected FileSystem + CommandRunner via fakes; no real git/gh; no temp files) and live under `extensions/drm-copilot/test/lib/pr-context/`.
  - Evidence: test/lib/pr-context/*.test.ts and the shared tree-file-system.ts fake; no fs/child_process real I/O in these suites.

- AC-F9-6 — PASS. New `src/lib/pr-context/**` files meet coverage policy: line >= 85%, branch >= 75%, with no regression on changed lines.
  - Evidence: evidence/qa-gates/test-coverage-final.md and evidence/qa-gates/coverage-delta.md (per-file values all above thresholds).

- AC-F9-7 — PASS. Format, lint, type-check, and test all pass from `extensions/drm-copilot/` in a single clean toolchain pass.
  - Evidence: evidence/qa-gates/{format-final,lint-final,typecheck-final,test-coverage-final}.md (all EXIT_CODE 0).

- AC-F9-8 — PASS. F1 `file-system.ts` / `subprocess-runner.ts` are reused (file-system.ts extended only additively with `exists`/`isDirectory`/`listDirectory`); `command-runtime.ts`, the `"python"` runtime branch, and all `scripts/dev_tools/**` / `resources/**/*.py` are unmodified.
  - Evidence: git status shows no changes under resources/ or command-runtime.ts; file-system.ts diff adds three methods without changing existing signatures.

- AC-F9-9 — PASS. The reworked `extension.collect-pr-context.test.ts` and the repo-automation pr-context tests (`repo-automation-dispatch.test.ts`, `extension.integration.test.ts`) assert the in-process path with zero assertions of a `collect_pr_context.py` Python spawn.
  - Evidence: evidence/other/repo-automation-pr-context-test-search.md; the reworked suites pass and only contain negative spawn assertions.
