# pr-context-verification-contract-gap (Potential Bug)

- Date captured: 2026-02-22
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full

## Summary

PR body generation under-reports completed verification because the `pr_context` contract does not expose canonical evidence artifacts as allowed additional context files. As a result, PR authoring follows strict anti-hallucination rules and defaults to “Not verified in this PR” even when feature-level QA evidence exists in canonical locations.

## Environment

- OS/version: Windows host workspace
- Python version: Poetry-managed interpreter
- Command/flags used: `poetry run python -m scripts.dev_tools.pr_context.collector --base development` + PR generation via `.github/prompts/generate-pr.prompt.md`
- Data source or fixture: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, and feature evidence folders under `docs/features/active/*/evidence/`

## Steps to Reproduce

1. Generate PR context for `feature/bootstrap-utilities-#40` using `scripts.dev_tools.pr_context.collector`.
2. Generate a PR body using `.github/prompts/generate-pr.prompt.md` and only the allowed context sources.
3. Observe `## Verification` output reports “Not verified in this PR” despite canonical evidence artifacts existing for issues #40, #42, and #43.

## Expected Behavior

PR context should provide explicit, machine-readable verification summaries (or enumerate the canonical evidence files as allowed additional context), enabling PR authoring to state evidence-backed completion accurately without violating anti-hallucination constraints.

## Actual Behavior

PR authoring conservatively reports incomplete verification because the current contract only allows `pr_context` plus enumerated additional context files, and those additional files currently exclude `evidence/**`. `CI status (HEAD): (not available)` is also interpreted alongside missing explicit verification summaries, reinforcing the fallback wording.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
	- `artifacts/pr_context.summary.txt` contains `===== CI status (HEAD) =====` with `(not available)`.
	- `scripts/dev_tools/pr_context/collector.py` builds additional context from `feature_docs.context_files` only.
	- `scripts/dev_tools/pr_context/feature_docs.py` currently derives context files from `{spec.md, plan.md, user-story.md}` only.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Root cause appears to be a contract gap rather than missing evidence:
- Source restriction: PR prompt forbids claims not explicitly supported by context/allowed files.
- Enumeration gap: canonical evidence files are not included in “Additional context files”.
- Summary gap: no normalized verification section is emitted from evidence schema (`Timestamp`, `Command`, `EXIT_CODE`).
- Language contamination risk: PR digests include prior “Not verified in this PR” text, biasing conservative phrasing.

Primary files to inspect:
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/feature_docs.py`
- `scripts/dev_tools/pr_context/summary_helpers.py`
- `.github/prompts/generate-pr.prompt.md`

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
	- Add/extend tests for `pr_context` collector to verify canonical evidence discovery and inclusion in additional context files.
	- Add tests for verification summary rendering from evidence artifacts using schema fields (`Timestamp`, `Command`, `EXIT_CODE`).
- [x] Integration scenario to retest
	- Re-run PR context collection + PR generation for the same branch and confirm verification section can state evidence-backed completion without violating source constraints.
- [x] Manual verification notes
	- Validate output wording distinguishes “CI unavailable” from “canonical evidence indicates pass”.
	- Confirm no non-enumerated files are cited in generated PR body.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

## Resolution Summary

- Implemented canonical evidence discovery/parsing for active feature folders and surfaced normalized verification rows in collector summary output.
- Expanded allowed `Additional context files` enumeration to include canonical feature evidence artifacts so PR authoring can remain source-traceable.
- Preserved anti-hallucination prompt restrictions and explicitly separated CI-unavailable state from evidence-derived pass/fail claims.

## Resolution Evidence

- `evidence/regression-testing/`
- `evidence/qa-gates/`