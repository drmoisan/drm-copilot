# Remediation Inputs — expose-placeholder-commands

Timestamp: 2026-03-14T15-48
Feature Folder: `docs/features/active/2026-03-11-expose-placeholder-commands-92`
Base Branch: `origin/development`

## Required fixes

1. **Convert `newPotentialBugEntry` into the same thin-wrapper architecture used by the other Python entrypoints.**
   - **Files:**
     - `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`
     - `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py` (new)
     - any supporting tests under `tests/extensions/drm_copilot/resources/templates/` and `tests/scripts/dev_tools/`
   - **Location(s):** current template implementation spans roughly lines 21-331 in `resources/templates/new_potential_bug_entry.py`.
   - **Expected behavior:** the template file should only ensure bundled import-path setup and delegate to a bundled `dev_tools.new_potential_bug_entry` module, matching the pattern used by `new_active_feature_folder.py` and `potential_to_issue.py`.
   - **Acceptance criteria:** feature criterion 3 must pass; drift risk between repo-root source and packaged template must be removed.
   - **Verification:**
     - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

2. **Raise changed Python-module coverage to meet the repo’s `>= 90%` new-module threshold.**
   - **Files:**
     - `scripts/dev_tools/new_active_feature_folder_models.py`
     - `scripts/dev_tools/potential_to_issue_content.py`
     - `scripts/dev_tools/prompt_mode_contract.py`
     - mirrored extension bundled copies under `extensions/drm-copilot/resources/scripts/dev_tools/` as needed for parity tests
     - corresponding tests under `tests/scripts/dev_tools/`
   - **Location(s):** focus on the uncovered lines reported by the fresh Pytest run:
     - `new_active_feature_folder_models.py`: 71, 74, 77-78, 81-86, 89-91, 94, 97-98, 101-104, 109, 120, 127
     - `potential_to_issue_content.py`: 102-114, 145, 153-154, 158, 162-163, 172
     - `prompt_mode_contract.py`: 41, 52-58
   - **Expected behavior:** all changed/new Python modules in the feature path should reach at least `90%` coverage, with no regressions in current passing behavior.
   - **Acceptance criteria:** policy audit new-code coverage requirement must pass.
   - **Verification:**
     - `poetry run black .`
     - `poetry run ruff check`
     - `poetry run pyright`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

3. **Replace the broad `except Exception` in the active-feature-folder I/O path with explicit handling.**
   - **Files:**
     - `scripts/dev_tools/new_active_feature_folder_io.py`
     - `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`
   - **Location(s):** around the updated-date parsing block near lines 176-183.
   - **Expected behavior:** parsing fallback should handle only the specific failure mode intended by the code, while preserving the current fallback output.
   - **Acceptance criteria:** typed-Python audit no longer reports a broad catch in the changed feature path.
   - **Verification:**
     - `poetry run ruff check`
     - `poetry run pyright`
     - targeted Pytest coverage for the affected parsing path

4. **Restore complete, comparable coverage evidence for the feature review.**
   - **Files / artifacts:**
     - `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/*`
     - `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/*`
     - any new coverage-delta artifact needed for TypeScript and PowerShell
   - **Expected behavior:** the feature review should be able to cite numeric baseline, post-change, and changed-code coverage for all languages in scope, or document a repo-approved deterministic substitute.
   - **Acceptance criteria:** policy audit can evaluate coverage without missing-language gaps; PowerShell no-regression evidence is restored or the regression is corrected.
   - **Verification:**
     - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

5. **Reduce PR-review ambiguity caused by stacked unrelated fixes, or explicitly synchronize review scope documentation.**
   - **Files / scope:** branch/PR context plus feature docs as needed.
   - **Expected behavior:** reviewers should be able to review feature `#92` without silently inheriting unrelated merged bugfixes and automation churn.
   - **Acceptance criteria:** either the PR is narrowed/restacked, or the review documentation clearly states the branch is an umbrella scope and maps non-#92 changes to their own evidence.
   - **Verification:**
     - regenerated or confirmed `artifacts/pr_context.summary.txt`
     - updated review artifacts showing resolved scope decision

## Do not do

- Do **not** weaken repo policies or coverage requirements to make the audit pass.
- Do **not** keep `new_potential_bug_entry.py` as a second source of business logic in the template layer.
- Do **not** mark acceptance criteria as complete without direct verification.
- Do **not** introduce scope creep unrelated to the remediation list above.
- Do **not** silently skip TypeScript, Python, or PowerShell verification loops.

## Acceptance criteria not yet met

1. `Wrapper templates follow the same thin-adapter pattern as collect_pr_context.py and push_down_copilot_customizations.py`
   - **Minimum change required:** move `newPotentialBugEntry` business logic out of the template file and into a bundled module, then verify the packaged template is a true wrapper.

## Minimum completion bar

Remediation is complete only when:
- the failing wrapper criterion is converted to PASS,
- changed Python modules meet the repo’s coverage floor,
- coverage evidence is complete enough for a PASS-grade audit, and
- the review scope ambiguity is resolved well enough for a safe PR review.
