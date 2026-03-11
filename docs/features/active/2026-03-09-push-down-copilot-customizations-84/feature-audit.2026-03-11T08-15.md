# Feature Audit — push-down-copilot-customizations (#84)

## Scope and Baseline

- **Base branch:** `development`
- **Head branch / reviewed state:** `feature/push-down-copilot-customizations-84` @ `351d8c1b1dd98c250788996dc836f1607caf756a`, evaluated with refreshed PR-context artifacts and the current working tree used for the live verification commands in this session
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary: `artifacts/pr_context.appendix.txt`
  - Supporting: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md`, `v2/spec.md`, `v2/user-story.md`, source/test files, and live toolchain output from this session
- **Feature folder used:** `docs/features/active/2026-03-09-push-down-copilot-customizations-84`
- **Feature-folder selection rule:** `issue.md` declares `- Work Mode: full`, so `v2/spec.md` and `v2/user-story.md` were treated as the acceptance-criteria source of truth; this feature folder was selected because the PR-context artifacts identify those `v2` scoping docs as the material scope for the branch.

## Acceptance Criteria Inventory (authoritative)

Authoritative sources for this audit run:
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/user-story.md`
- acceptance-criteria excerpts in `artifacts/pr_context.summary.txt`

Consolidated criteria for the active scope:
1. A Python entry point can push down all files from `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` into a destination workspace while preserving each file's relative path under `.github/`.
2. The `drm-copilot` extension contributes and registers a dedicated non-placeholder push-down command whose handler launches a bundled copy of `scripts.dev_tools.push_down_copilot_customizations` using the same packaged runtime/script execution model already used for PR-context collection.
3. When the destination workspace already contains a file at the same relative path, the push-down run overwrites that file with the source-repo version instead of skipping or merging it.
4. Copied files that reference already-exposed tooling are rewritten from repo-local script paths to packaged extension command references that match the extension's bundled execution model, including a real bundled extension command for `scripts.dev_tools.push_down_copilot_customizations` and the existing bundled PR-context command.
5. Copied files that reference tooling not yet exposed by the extension are rewritten to stable placeholder command references, and invoking those placeholders surfaces a clear not-implemented failure rather than a missing-file/path error.
6. The implementation introduces a dedicated one-way Python entry point for push-down behavior, leaving the current bidirectional `scripts/dev_tools/agentic_sync.py` contract unchanged unless small shared helpers are extracted without altering sync semantics.
7. Rewrites normalize both `scripts/dev_tools/...` and `scripts/dev-tools/...` references to the same catalog entry so mixed slash styles on Windows or cross-platform docs resolve to the same extension-command target.
8. If a text file contains a script-like reference that is outside the initial verified command catalog, the file content remains unchanged and the run summary reports that unmatched reference explicitly.
9. Invalid destination input fails before partial copy begins, with a deterministic error that explains why the destination workspace root is unusable.
10. Automated coverage includes Python tests for enumeration/copy/overwrite/rewrite/unmatched-reference reporting behavior and extension tests for push-down command contribution, packaged-path execution of the bundled push-down resource, continued packaged-path execution of PR-context collection, and placeholder-command failure paths.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. Python entry point pushes all scoped `.github` trees while preserving relative paths. | PASS | `scripts/dev_tools/push_down_copilot_customizations.py` enumerates `ROOT_FOLDERS` deterministically; Python tests cover copying the four scoped trees into an empty destination. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Verified in the current session. |
| 2. Extension contributes and registers a real push-down command that launches the bundled publisher. | PASS | `extensions/drm-copilot/package.json` contributes `drmCopilotExtension.pushDownCopilotCustomizations`; `extensions/drm-copilot/src/extension.ts` registers the handler; TS tests verify registration and bundled-wrapper execution. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` | Live run passed `42` tests. |
| 3. Existing destination files are overwritten. | PASS | Python overwrite scenario is asserted by `test_push_down_overwrites_existing_destination_file`. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Confirmed in the passing Pytest suite. |
| 4. Known exposed tooling references rewrite to real packaged commands. | PASS | `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` maps PR-context collection and push-down publishing to real commands; tests cover both rewrite paths. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | The rewrite catalog and tests align with the extension command surface. |
| 5. Uncovered tooling references rewrite to stable placeholders and fail deterministically when invoked. | PASS | Placeholder mappings exist for the verified uncovered scripts; `extension.placeholder-commands.test.ts` asserts deterministic `Not implemented:` failures. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` | Verified in the current session. |
| 6. One-way entry point leaves `agentic_sync.py` semantics intact. | PASS | Dedicated publisher module exists; `tests/scripts/dev_tools/test_agentic_sync.py` still passes in the full suite and covers sync behavior preservation. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | No regression observed. |
| 7. Slash variants normalize to one catalog target. | PASS | `normalize_reference_for_lookup()` collapses slash variants and is directly tested by `test_rewrite_normalizes_dev_tools_slash_variants`. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Explicit Windows/cross-platform path risk is covered. |
| 8. Unknown references stay unchanged and are reported. | PASS | `test_push_down_reports_unmatched_script_references_without_rewrite` asserts both pass-through behavior and ordered unmatched-reference reporting. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Safe non-heuristic behavior confirmed. |
| 9. Invalid destination input fails before partial copy. | PASS | `validate_destination()` checks directory validity and source-root reuse; tests assert deterministic failures before copy work begins. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Verified in the live passing suite. |
| 10. Automated coverage includes Python and extension tests for the required scenarios. | PASS | Pytest passed `824` tests with push-down source modules at `100%`; Jest passed registration, bundled execution, destination forwarding, PR-context, and placeholder suites. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` | Feature coverage requirements are satisfied. |

## Summary

**Overall feature readiness:** **PASS**

All acceptance criteria for the active `full` / `v2` scope are satisfied relative to `development`. The branch now provides the intended one-way publisher behavior, aligned real and placeholder command rewrites, bundled extension execution, and the required automated coverage.

**Top gaps preventing PASS:** None.

**Recommended follow-up verification steps:** None are required for feature acceptance beyond normal CI reruns, because no criteria remain FAIL, PARTIAL, or UNVERIFIED in this audit.

