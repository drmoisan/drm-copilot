# Code Review: expose-placeholder-commands feature branch

**Base Branch:** `origin/development`  
**Feature Folder:** `docs/features/active/2026-03-11-expose-placeholder-commands-92`  
**Feature folder selection rule:** Selected this folder because `artifacts/pr_context.summary.txt` marks its `spec.md` and `user-story.md` as the primary scoping docs changed and the folder suffix matches issue `#92`.
Review scope decision: umbrella review scope documented in evidence/other/review-scope-map.2026-03-14T15-48.md

## Executive Summary

This branch replaces the extension’s four placeholder commands with live handlers and bundles the corresponding Python/PowerShell assets into the VS Code extension. On today’s fresh review run, the TypeScript, Python, and PowerShell toolchains all passed. The implementation is close, but it is **not PR-ready** for a clean feature `#92` merge.

### Top 3 risks

1. **One wrapper is not actually a wrapper.** `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` contains full business logic instead of delegating to a bundled module, which breaks the feature spec and creates drift risk.
2. **New Python modules are under-covered.** Current Pytest coverage shows several changed helper modules below the repo’s `>= 90%` threshold for new modules.
3. **The branch is far broader than feature `#92`.** `artifacts/pr_context.summary.txt` reports 254 changed files and merged PRs `#94`, `#96`, and `#99`, which materially widens review risk beyond the placeholder-command feature.

**PR readiness recommendation:** **No-Go / Needs revision**.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` | lines 21-331 | The packaged `new_potential_bug_entry.py` entrypoint is a full implementation, not a thin compatibility wrapper. | Move the logic into `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`, keep the template limited to import-path setup + `main()` delegation, and add parity tests like the other Python wrappers. | This breaks the documented thin-wrapper contract and duplicates business logic inside the template layer. | The file defines `_resolve_workspace`, validation/helpers, `FileSystem`, `RealFileSystem`, `create_bug_entry`, `parse_args`, and `main`; `file_search` found no bundled `resources/scripts/dev_tools/new_potential_bug_entry.py`. |
| Major | `scripts/dev_tools/new_active_feature_folder_models.py`; `scripts/dev_tools/potential_to_issue_content.py`; `scripts/dev_tools/prompt_mode_contract.py` | coverage hotspots at lines reported by Pytest (`new_active_feature_folder_models.py` 71,74,77-78,81-86,89-91,94,97-98,101-104,109,120,127; `potential_to_issue_content.py` 102-114,145,153-154,158,162-163,172; `prompt_mode_contract.py` 41,52-58) | New/changed Python helper modules do not meet the repo’s `>= 90%` coverage requirement for new modules. | Add focused Pytest coverage for uncovered branches and rerun the Python coverage loop until each changed module reaches policy minimums. | The repo policy is explicit on new-module coverage, and the current branch misses it. | Fresh `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` reported 68%, 82%, and 86% coverage for these changed modules. |
| Minor | `scripts/dev_tools/new_active_feature_folder_io.py` and bundled mirror `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py` | around lines 176-183 | Updated-date parsing still uses `except Exception:`. | Narrow the exception handling to the specific parse failure you expect, or restructure to avoid the catch entirely. | Broad catches weaken typed error contracts and make silent failure easier to miss. | Grep search found `except Exception:` in both the source file and the bundled mirror. |
| Major | `artifacts/pr_context.summary.txt` | `Changed files overview`, `PR digests`, `Diff shortstat` sections | The feature branch contains multiple merged bugfix PRs and extensive agent/prompt/docs churn far beyond feature `#92`. | Restack or split the branch/PR so feature `#92` is reviewed on a narrower diff, or explicitly treat this as an umbrella branch and audit it as such. | Reviewability and merge safety drop sharply when unrelated runtime, tooling, and documentation changes are combined. | `pr_context.summary.txt` reports 254 changed files, 12,545 insertions, and merged PRs `#94`, `#96`, and `#99` in range. |
| Minor | `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/typescript-test.2026-03-11T22-17.md` | whole artifact | Feature `#92` never captured a TypeScript coverage baseline, only a pass/fail unit-test count. | Add a canonical TypeScript coverage-delta artifact for this feature so reviewers can compare baseline/post/new-code coverage explicitly. | The review prompt requires numeric baseline/post/new-code coverage values for PASS-grade audit outcomes. | Baseline artifact records 42 passing tests but no coverage totals; the fresh review run is the first numeric TS coverage measurement in this audit. |

## Typed Python Audit

### Strong typing

- Fresh `pyright` run was clean: `0 errors, 0 warnings, 0 informations`.
- No `Any` usage surfaced in the sampled changed Python files reviewed for this audit.
- The sampled new modules use typed functions, dataclasses, and protocols consistently.

### Type-safety concerns

- `new_active_feature_folder_io.py` still uses a broad `except Exception:` around date parsing, which weakens the explicit exception contract.
- The heavier issue in Python is **verification depth**, not static typing: the changed modules are typed, but their uncovered branches leave correctness risks in code paths that the type checker cannot prove.

### APIs, docs, and boundaries

- Public helper modules and wrappers generally include docstrings.
- The thin-wrapper model is implemented correctly for `new_active_feature_folder.py` and `potential_to_issue.py`.
- `new_potential_bug_entry.py` breaks the same pattern by embedding domain logic into the template entrypoint.

## Test Quality Audit

- **Deterministic:** Yes for the reviewed TypeScript and Python additions; they rely on mocks and direct module loading rather than external services.
- **Isolated:** Yes for the changed command-handler tests and wrapper import tests.
- **Good diagnostics:** Yes; failures would tell a reviewer which command path or wrapper contract broke.
- **Coverage expectations:** Not met for changed Python modules, and not fully evidenced for TypeScript baseline / PowerShell changed-code delta.

## Security / Correctness Checks

- No secrets or credentials were introduced in the sampled changed code.
- Subprocess calls in the extension path are routed through argv arrays instead of shell-concatenated strings.
- Runtime selection and missing-runtime failures are covered by tests.
- The correctness risk is drift: duplicating `new_potential_bug_entry` logic in the template layer makes the packaged path easier to desynchronize from the repo-root source implementation.

## Research Log

No external research was needed for this review; all findings were grounded in repository policy documents, PR-context artifacts, direct file inspection, and fresh local verification commands.

## Recommendation

**No-Go for a dedicated feature `#92` PR in the current state.**

The live command surface works and the toolchain is green, but the branch still needs at least one feature-contract fix (`newPotentialBugEntry` thin wrapper), additional Python coverage work, and stronger coverage evidence before it is audit-clean and merge-safe.
