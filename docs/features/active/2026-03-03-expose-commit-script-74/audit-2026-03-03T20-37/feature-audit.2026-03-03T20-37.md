# Feature Audit — expose-commit-script (#74)

## Scope and baseline

- **Base branch:** `development`
- **Head branch:** `feature/expose-commit-script-74`
- **Feature folder:** `docs/features/active/2026-03-03-expose-commit-script-74`
- **Primary evidence source:** `artifacts/pr_context.summary.txt`
- **Secondary/full evidence source:** `artifacts/pr_context.appendix.txt`

Note: summary artifact shows base/head parity (no commit delta). For this audit run, detailed scope/evidence relies on appendix + direct file/test inspection.

## Acceptance criteria inventory (authoritative for this run)

Source set used (Work Mode: `full` from `issue.md`):
- `docs/features/active/2026-03-03-expose-commit-script-74/spec.md`
- `docs/features/active/2026-03-03-expose-commit-script-74/user-story.md`
- PR context artifacts (summary/appendix)

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| Command Palette action contributed (`scaffoldExtension.collectCommitContext`) | PASS | `extensions/scaffold-extension/package.json:21-22` | static inspection | Command and title present. |
| Clear error when no workspace open | PASS | `extensions/scaffold-extension/test/extension.test.ts:203-211` | `npm --prefix extensions/scaffold-extension run test -- --runInBand` | Test asserts `No workspace folder is open.` |
| Uses bundled extension script, no workspace script copy | PASS | `extensions/scaffold-extension/src/extension.ts:205-214`; `extension.integration.test.ts:179-192` | same Jest command | Path assertions verify extension resource location, not workspace root. |
| Collector launched with destination workspace `cwd` and targets destination repo | PASS | `extension.test.ts:267-283` checks `cwd` and `shell:false` | same Jest command | CWD semantics are explicitly asserted. |
| Output artifact path `<workspace>/artifacts/commit_context.txt` | PASS | `extension.ts` args include `--output artifacts/commit_context.txt`; test asserts argv | same Jest command | Path contract covered by handler args and tests. |
| Artifact includes required core sections | PARTIAL | `extension.integration.test.ts:194-236` validates all headers; collector resource also contains section logic | same Jest command | Validation is based on deterministic mocked artifact text, not full git-backed collector execution. |
| `(no staged changes)` marker behavior | PASS | `extension.integration.test.ts:237-259`; collector script lines for staged fallback | same Jest command | Marker semantics are explicitly asserted. |
| Runtime selection + lifecycle logging includes failures | PASS | `extension.test.ts:285-331` checks failure logs and git stderr propagation | same Jest command | Command-scoped failure logging is validated. |
| Unit tests cover registration/disposal, workspace/runtime, bundled path, cwd/args | PASS | `extension.test.ts` suite contains all listed scenarios | same Jest command | Unit coverage aligns with AC list. |
| Integration tests verify end-to-end artifact generation with staged changes and no script materialization | PARTIAL | `extension.integration.test.ts` has staged/no-staged and no-materialization checks | same Jest command | Staged artifact is simulated via mocked process output, not real repo fixture execution. |
| Error-path tests for missing workspace/runtime/git/non-zero exit | PASS | `extension.test.ts:203-331` | same Jest command | All listed error classes are asserted. |

## Summary

**Overall feature readiness:** **NEEDS REVISION**

Top gaps preventing PASS:
1. One acceptance criterion remains PARTIAL due integration fidelity (mocked artifact content instead of git-backed collector run).
2. Current branch fails check-only formatting gate for extension files.

Recommended follow-up verification (to close PARTIAL/FAIL):
- Run extension formatter and re-run gate sequence:
  - format, lint, typecheck, tests.
- Add one higher-fidelity integration test that exercises real collector output generation path against a deterministic repository fixture approach compliant with repo policy.
