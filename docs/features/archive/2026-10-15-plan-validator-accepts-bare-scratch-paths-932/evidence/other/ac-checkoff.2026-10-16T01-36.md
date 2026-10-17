# Acceptance-Criteria Check-Off — Issue #932

Timestamp: 2026-10-16T01-36
Task: [P6-T16]
Command: checkbox update in `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md` (only `- [ ]` changed to `- [x]`; `git diff --stat` reports 31 insertions, 31 deletions)
EXIT_CODE: 0

Output Summary: source `spec.md` (work mode full-bug); 32 AC items; 31 checked; 1 pending-CI (AC-23). No other file's checkboxes were changed.

| AC | Status | Evidence |
| --- | --- | --- |
| AC-01 `G10_SEVERITY` equals `BLOCKING_CHANNEL` | checked | regression-testing/python-green.2026-10-16T00-55.md; qa-gates/python-coverage-final.2026-10-16T01-26.md |
| AC-02 accepted forms | checked | python-green.2026-10-16T00-55.md |
| AC-03 rejected forms | checked | python-green.2026-10-16T00-55.md |
| AC-04 non-definitions and fenced | checked | python-green.2026-10-16T00-55.md |
| AC-05 wrapped line and continuation stops | checked | python-green.2026-10-16T00-55.md |
| AC-06 frozen message (apostrophe, tab) | checked | python-green.2026-10-16T00-55.md |
| AC-07 `evaluate_plan_gates` with and without context | checked | python-green.2026-10-16T00-55.md |
| AC-08 CLI exit 1 / no G10 for namespaced | checked | python-green.2026-10-16T00-55.md |
| AC-09 TypeScript module exports and re-export | checked | regression-testing/ts-green.2026-10-16T01-03.md |
| AC-10 TypeScript fixtures and frozen strings | checked | ts-green.2026-10-16T01-03.md |
| AC-11 dispatcher, `validateArtifactWithWarnings`, MCP throw path | checked | ts-green.2026-10-16T01-03.md |
| AC-12 severity parity Python/TypeScript | checked | ts-green.2026-10-16T01-03.md ([P3-T8] append) |
| AC-13 `_PYTHON_GATE_MODULES` and no-repr test | checked | python-green.2026-10-16T00-55.md |
| AC-14 TypeScript no-`pythonRepr(` module list | checked | ts-green.2026-10-16T01-03.md |
| AC-15 jest per-file threshold | checked | ts-green.2026-10-16T01-03.md; qa-gates/ts-coverage-final.2026-10-16T01-31.md |
| AC-16 denylist removed; detector plus root regex scan | checked | regression-testing/scratch-contract-green.2026-10-16T01-13.md |
| AC-17 parametrized self-test | checked | scratch-contract-green.2026-10-16T01-13.md |
| AC-18 Codex TOMLs in rule sources; tests pass | checked | scratch-contract-green.2026-10-16T01-13.md |
| AC-19 Codex sections at FR-6 anchors | checked | scratch-contract-green.2026-10-16T01-13.md |
| AC-20 variants and bundle copies match generator | checked | regression-testing/codex-suites-green.2026-10-16T01-14.md; codex-toml-identity.2026-10-16T01-12.md |
| AC-21 Codex parity and schema suites | checked | codex-suites-green.2026-10-16T01-14.md |
| AC-22 rule file documents G10 | checked | regression-testing/docs-green.2026-10-16T01-25.md |
| AC-23 bundle rule copy byte-identical; skill copies state G1–G10 and are identical; verified by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing in CI | pending-CI | Local: docs-green.2026-10-16T01-25.md and qa-gates/python-contract-final.2026-10-16T01-27.md (the node and both byte-identity tests passed locally; no #510 failure occurred). The criterion names CI as its verifier, so it stays unchecked until CI runs on the PR head. |
| AC-24 docstrings and JSDoc name G10 | checked | python-green.2026-10-16T00-55.md; ts-green.2026-10-16T01-03.md |
| AC-25 rules frontmatter reaches new modules | checked | docs-green.2026-10-16T01-25.md |
| AC-26 decision rule precedes measurement; result recorded | checked | other/g10-severity-decision-rule.2026-10-16T01-16.md (commit 3135d7ee2, before the measurement); qa-gates/g10-corpus-measurement.2026-10-16T01-21.md |
| AC-27 plan passes validation with no G10 finding | checked | qa-gates/plan-self-validation.2026-10-16T01-33.md |
| AC-28 no plan file outside the feature folder | checked | qa-gates/scope-diff.2026-10-16T01-34.md |
| AC-29 Python toolchain one pass | checked | qa-gates/python-{format,lint,typecheck,coverage,contract,devtools}-final artifacts; qa-loop-summary.2026-10-16T01-32.md |
| AC-30 TypeScript toolchain one pass | checked | qa-gates/ts-{format,lint,typecheck,typecheck-test,coverage}-final artifacts; qa-loop-summary.2026-10-16T01-32.md |
| AC-31 coverage thresholds and no changed-line regression | checked | python-coverage-final.2026-10-16T01-26.md; ts-coverage-final.2026-10-16T01-31.md |
| AC-32 file size and no temporary files | checked | qa-gates/file-size-and-tempfile-check.2026-10-16T01-33.md |

Note on AC-30: the AC's `npx eslint` step is the repository lint command run from `extensions/drm-copilot/` ([P6-T8], exit 0). The separate [P3-T6] invocation that also passes `jest.config.cjs` explicitly reports a pre-existing `no-undef` error on line 2 of that file; see regression-testing/ts-lint-phase3.2026-10-16T01-01.md.
