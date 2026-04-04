# Remediation Inputs: potential-entry-opening-different-ide (Issue #116)

## Required Fixes

1. **Record live Windows verification for Acceptance Criterion 1**
   - **Files / evidence targets:**
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/` (new timestamped live-verification artifact)
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/other/p1-t3.implementation-summary.2026-04-04T12-29.md` or a new superseding summary artifact
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t5.end-state-summary.2026-04-04T12-36.md` or a new superseding summary artifact
   - **Expected behavior:** From an already-open Windows workspace, `drmCopilotExtension.newPotentialBugEntry` creates the expected markdown file and opens it in the originating VS Code or VS Code Insiders window instead of opening a new window.
   - **Acceptance criterion:** AC-1 in `issue.md`
   - **Verification command / action:** Execute the workflow manually in Windows from the active workspace and capture a timestamped artifact containing the exact prompts used, the created file path, and whether the originating window was reused.

2. **Record live Windows verification for Acceptance Criterion 2**
   - **Files / evidence targets:**
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/` (new timestamped live-verification artifact)
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/other/p1-t3.implementation-summary.2026-04-04T12-29.md` or a new superseding summary artifact
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t5.end-state-summary.2026-04-04T12-36.md` or a new superseding summary artifact
   - **Expected behavior:** From the same already-open Windows workspace, `drmCopilotExtension.newActiveFeatureFolder` creates the expected active-feature files and opens them in the originating VS Code or VS Code Insiders window instead of opening a new window.
   - **Acceptance criterion:** AC-2 in `issue.md`
   - **Verification command / action:** Execute the workflow manually in Windows from the active workspace and capture a timestamped artifact containing the prompt inputs, the generated file paths, and whether the originating window was reused.

3. **Close the changed/new-code coverage evidence gap**
   - **Files / evidence targets:**
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/` (new timestamped coverage-closure artifact)
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t5.end-state-summary.2026-04-04T12-36.md` or a new superseding summary artifact
   - **Expected behavior:** The feature folder contains deterministic evidence showing whether the changed launcher code meets the repo's ≥90% new-code coverage expectation, or a clearly documented policy-compliant exception if deterministic isolation is not possible.
   - **Acceptance criterion:** Required for a PASS-style policy audit outcome; supports closure of AC-3 evidence quality and the reduced-audit policy gate.
   - **Verification command / action:** Run a focused pytest/coverage command or another deterministic coverage measurement that isolates the four launcher files and targeted tests, then record the numeric result in a timestamped artifact.

4. **Refresh acceptance and audit summaries after remediation evidence exists**
   - **Files / evidence targets:**
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md`
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/feature-audit.2026-04-04T12-40.md` or a superseding feature-audit artifact
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/policy-audit.2026-04-04T12-40.md` or a superseding policy-audit artifact
     - `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/code-review.2026-04-04T12-40.md` or a superseding code-review artifact
   - **Expected behavior:** Once live verification and coverage evidence pass, AC-1 and AC-2 are checked off in `issue.md`, and the review artifacts are refreshed to report a PASS-style outcome.
   - **Acceptance criterion:** AC-1 and AC-2 check-off plus reduced-audit closure.
   - **Verification command / action:** Update the review artifacts only after the new evidence exists and independently supports the outcome.

## Do Not Do

- Do not add `spec.md` or `user-story.md` to this minor-audit folder.
- Do not mark AC-1 or AC-2 as passed without explicit live Windows evidence.
- Do not weaken the coverage requirement or claim changed/new-code coverage passed without deterministic proof.
- Do not widen the implementation scope beyond the minimum needed to close the two live-verification gaps and the coverage-evidence gap.
- Do not overwrite the existing evidence artifacts without preserving a timestamped remediation trail.

## Acceptance Criteria Not Yet Met

1. **AC-1** — Minimum change required: run the live Windows potential-bug workflow and record originating-window reuse evidence.
2. **AC-2** — Minimum change required: run the live Windows active-feature-folder workflow and record originating-window reuse evidence.

## Additional Review Notes

- Non-blocking cleanup item: both `_resolve_code_cli()` docstrings in the root and bundled launcher files contain a stray literal command fragment. This is not the current merge blocker, but it should be corrected during remediation if the files are touched again.

## Delegation Note

A remediation plan artifact is being created alongside this file. No direct agent-handoff mechanism for `atomic_planner` is exposed in this session, so the plan file is seeded manually as the best available fallback and should be treated as pending planner execution/preflight.
