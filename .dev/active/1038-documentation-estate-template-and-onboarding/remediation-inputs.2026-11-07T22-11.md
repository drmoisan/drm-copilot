# Remediation Inputs - issue #1038 (cycle 1)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design

Branch: `feature/documentation-estate-template-and-onboarding-1038-r2`. Base: `origin/epic/documentation-estate-tooling-integration`. Merge base at review: `d395d5140f3822eeef453f2055d4ac539656d629`. Head at review: `f668e4254135715cce4901e9b6f6d152cacb8d35`.

Source artifacts:
- `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/policy-audit.2026-11-07T22-11.md` (section 8, gap G-1)
- `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/code-review.2026-11-07T22-11.md` (`## Findings Table`, Major row on `spec.md`)
- `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/feature-audit.2026-11-07T22-11.md` (SAC-12 row)

Path rationale: `full`, because the fix changes the text of spec acceptance criterion SAC-12, which the light path does not allow. The change is documentation-only and touches one spec file and one plan file.

## Blocking Findings

### F-1 - Spec Python-floor erratum missing; SAC-12 text not met

Remediability: autonomous
Remediability-Evidence: The governing value is already decided and merged: the 1031 owner decision of 2026-11-04 raised the floor to 3.11, and `.claude/lib/docs/python/run_docs_python_native.py` line 18 holds `FLOOR = (3, 11)`. The fix is a text edit inside the feature folder and needs no owner input, external dependency or CI result.
Finding-Scope: contained

- File: `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md`
- Locations: SAC-12 (line 393, "with Python 3.10 or later"); `### Onboarding documentation` (line 149, "with Python 3.10 or later available"); `## Cross-Child Contract Dependencies` table (line 324, "Python 3.10 floor"); `## Corrections to the Research` (no Python-floor entry).
- Secondary file: `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/plan.2026-10-30T18-59.md` task [P2-T3] (line 119, "Python 3.10 or later").
- Observed: `docs/engineering/documentation-estate/consumer-onboarding.md` lines 15-19 state "Python 3.11 or later", matching the merged code. The executor checked SAC-12 off with a recorded deviation (`evidence/qa-gates/ac-verification.2026-11-07T22-00.md`) but did not amend the spec. The review reverted the SAC-12 checkbox to unchecked.
- Required change, in one commit:
  1. Add an entry to `spec.md` `## Corrections to the Research`, worded like the existing D-1 entry: `- Python floor (erratum, 2026-11-07): the native-analyzer floor is Python 3.11, per the 1031 owner decision of 2026-11-04 and the merged FLOOR = (3, 11) in .claude/lib/docs/python/run_docs_python_native.py, which supersedes 3.10. Found at feature review on 2026-11-07.`
  2. Change `3.10` to `3.11` in SAC-12, spec line 149 and spec line 324. Change no other word of those lines.
  3. Change `Python 3.10 or later` to `Python 3.11 or later` in plan task [P2-T3].
  4. Re-check SAC-12 (`- [ ]` to `- [x]`) once steps 1 to 3 are committed. Cite `consumer-onboarding.md` lines 15-19 and the passing test `states that the optional python pack enables the native Python analyzer`.
- Verification:
  - `grep -n "3\.10" docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` returns only the erratum line.
  - `grep -n "3\.11" docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` returns the SAC-12 line, line 149, line 324 and the erratum.
  - `git diff --name-only` for the fix commit lists only `spec.md` and `plan.2026-10-30T18-59.md`, plus any new evidence file under `evidence/`.

## Related Rows Fixed in the Same Cycle (owner standing practice; not counted)

These code-review rows are related to this item and are neither gating nor counted. The owner's standing practice is to fix related review rows inside the item before merge. Include them in the remediation plan unless the orchestrator excludes them.

- R-1 (Minor): `docs/engineering/documentation-estate/consumer-onboarding.md` line 4: change "PowerShell 7 session" to "PowerShell 7.4 session".
- R-2 (Minor): `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1` line 196: report a non-integer `issue_num` under a distinct code (for example `EPIC_MANIFEST_ISSUE_NUM_INVALID`, added to the `.NOTES` code list), and add one positive control in `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` that mutates `issue_num: 900002` to a non-integer value and asserts that code.
- R-3 (Nit): `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` line 144: use `Invoke-EstateDocumentElement` without a switch, or remove that helper's unused no-switch path.
- R-4 (Minor, optional, owner preference): `EndToEndDocumentationEstate.Tests.ps1` runs for 211 s because every test replays the scenario. Building each step once per `Context` `BeforeAll` would cut the runtime while keeping `Context` blocks independent. Leave this row out if the planner keeps decision D-3 (per-test replay).

If R-2, R-3 or R-4 is taken, the toolchain gates must run again: one `Invoke-PoshQCParallelTest` run (owner decision 1), `Invoke-Formatter` and `Invoke-ScriptAnalyzer` over the changed files, with new evidence under `evidence/qa-gates/` and `evidence/regression-testing/`. Compare against the existing baseline with no new failures (owner decision 2).

## Do Not Do

- Do not change `consumer-onboarding.md` back to 3.10; the page is correct.
- Do not edit any file under `.claude/`, `extensions/drm-copilot/src/` or `extensions/drm-copilot/resources/claude-customizations/`, or any policy document.
- Do not add a Python or TypeScript file.
- Do not weaken, skip or remove an assertion or positive control.
- Do not run seeded-shuffle, single-process or ordering-comparison runs (owner decision 1).
- Do not check off SAC-24; the orchestrator does that at S9.
- Do not write evidence outside `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/evidence/<kind>/`.
