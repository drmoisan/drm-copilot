# Code Review — expose-commit-script (#74)

## Executive summary

Change set adds extension command `scaffoldExtension.collectCommitContext`, wires argumentized bundled-script execution, adds bundled collector resource, and expands TypeScript + Python regression tests.

Top 3 risks:
1. **Blocker:** extension formatting is not currently clean in check-only validation (`package.json`).
2. PR-context summary cannot represent uncommitted feature diff (base/head equal), creating audit blind spots unless appendix/direct file inspection is used.
3. Integration tests for artifact body rely on mocked generated text rather than an actual git-backed fixture execution.

**Go/No-Go:** **NO-GO** until formatting gate is resolved and final verification rerun.

## Feature-folder selection trace

Feature folder used: `docs/features/active/2026-03-03-expose-commit-script-74` (explicitly requested; also matches issue suffix `-74`).

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/scaffold-extension/package.json` | formatting check | Prettier check fails for current branch state. | Run extension formatter and re-run full TS gate sequence (format→lint→typecheck→test). | Merge gate should not rely on stale prior evidence when current tree is not format-clean. | `npm --prefix extensions/scaffold-extension exec -- prettier --check ...` => exit 1, warns `package.json`. |
| Major | `artifacts/pr_context.summary.txt` | Base/Head section | Summary reports no diff scope (base/head/merge-base identical), masking active working-tree changes. | Treat appendix + direct git status/diff as authoritative until commits exist, then regenerate summary. | Review quality depends on true baseline diff. | `pr_context.summary.txt` shows no changed files; appendix shows modified/untracked files and diffs. |
| Minor | `extensions/scaffold-extension/test/extension.integration.test.ts` | 194-271 | Artifact content tests are simulated via mocked process output, not real collector execution over a fixture repo. | Add one higher-fidelity integration scenario that executes bundled collector against a temp in-memory fixture abstraction or deterministic repo fixture mechanism approved by policy. | Better confidence for end-to-end artifact semantics, especially section content correctness and cwd/git interactions. | Integration test builds artifact text via `buildArtifactText(...)` and `generatedArtifacts` map. |

## Typed Python audit

- ✅ No weakening of typing observed.
- ✅ New Python changes in `scripts/dev_tools/pr_context/feature_docs.py` are pyright-clean.
- ✅ Behavior extension is type-safe (`issue_text` propagation, tuple readiness source).
- ✅ Regression test added: `tests/scripts/dev_tools/test_feature_docs.py:375`.
- ✅ Exception behavior and parsing logic are explicit and deterministic.

## Test quality audit

- ✅ Extension tests pass (`2 suites`, `25 tests`) with deterministic mocks.
- ✅ Python targeted tests pass (`56 passed`).
- ⚠️ Coverage thresholds were not recomputed in this review run (UNVERIFIED).
- ⚠️ One integration requirement (“controlled fixture repository with staged changes”) appears only partially represented by current mocked integration tests.

## Security and correctness checks

- ✅ No secrets detected in reviewed changes.
- ✅ Collector resource validates git executable (`shutil.which("git")`) and uses explicit argv.
- ✅ Extension execution uses `shell: false` and workspace `cwd` contract.
- ✅ Error-path assertions exist for missing workspace/runtime and non-zero exits.

## Recommendation

**Needs revision before PR merge.**

Minimum fixes:
1. Resolve formatting gate for extension files.
2. Re-run TS gate sequence and capture fresh pass evidence.
3. (Recommended) Strengthen integration fidelity for artifact-generation path.
