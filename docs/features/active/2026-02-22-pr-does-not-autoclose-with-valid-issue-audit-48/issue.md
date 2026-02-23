# pr-does-not-autoclose-with-valid-issue-audit (Issue #48)

- Date captured: 2026-02-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-does-not-autoclose-with-valid-issue-audit/ (Issue #48)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #48
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/48
- Last Updated: 2026-02-23
- Work Mode: full

## Summary

PR generation misses auto-close for issue #46 even when the active feature audit readiness is PASS and the feature docs declare `Issue: #46`. `pr_context` currently places `#46` under `Close candidates`, but the PR prompt only permits auto-close numbers from `Issues to autoclose (verified or pending)` or `PR Intent -> Author-asserted autoclose issues`.

## Environment

- OS/version: Windows host workspace
- Python version: Poetry-managed interpreter
- Command/flags used: `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`
- Data source or fixture: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, `.github/prompts/generate-pr.prompt.md`, and active feature docs (`spec.md`/`user-story.md`) that declare `Issue: #46`

## Steps to Reproduce

1. Run `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`.
2. Open `artifacts/pr_context.summary.txt` and confirm `Close candidates` contains `Auto-close issues (author asserted): #40, #42, #43, #46` while `PR Intent` shows `Author-asserted autoclose issues:` with no value.
3. Confirm there is no `Issues to autoclose (verified or pending)` section in the summary output.
4. Generate PR content using `.github/prompts/generate-pr.prompt.md` and observe the `GitHub Auto-close` output does not emit `Closes #46`.

## Expected Behavior

When the active feature has a deterministic issue ID (`Issue: #46` in `spec.md`/`user-story.md`) and feature-audit readiness is PASS, `pr_context` should emit an approved auto-close source so the PR author can produce `Closes #46` under existing prompt rules.

## Actual Behavior

`#46` appears only under `Close candidates`, which the PR prompt does not allow as an auto-close source. Because `PR Intent -> Author-asserted autoclose issues` is blank and no `Issues to autoclose (verified or pending)` section exists, generated PRs omit `Closes #46`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
	- `artifacts/pr_context.summary.txt`:
		- `Author-asserted autoclose issues:` (blank in `PR Intent`)
		- `Auto-close issues (author asserted): #40 #42 #43 #46` (under `Close candidates`)
	- `.github/prompts/generate-pr.prompt.md` allows auto-close from only:
		1) `Issues to autoclose (verified or pending)`
		2) `PR Intent -> Author-asserted autoclose issues`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Contract mismatch between `pr_context` rendering and PR prompt consumption:
- `scripts/dev_tools/pr_context/collector.py` computes issue references and surfaces them in `Close candidates`, but does not populate the `PR Intent` author-asserted field.
- The summary schema does not emit `Issues to autoclose (verified or pending)` for pending deterministic close targets.
- Candidate issue derivation appears mention-based (includes `#40/#42/#43`) instead of using the active feature’s primary issue metadata (`Issue: #46`).

Files to inspect:
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/feature_docs.py`
- `tests/scripts/dev_tools/test_collect_pr_context.py`
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
- `tests/scripts/dev_tools/test_pr_context_integration.py`
- `.github/prompts/generate-pr.prompt.md`

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
	- Add/extend tests so `pr_context` emits an approved auto-close source when feature docs provide a deterministic `Issue: #NN` and readiness is PASS.
	- Add regression assertions that narrative mentions (`#40/#42/#43`) are not promoted to close targets.
- [x] Integration scenario to retest
	- Re-run `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40` and regenerate PR content.
	- Verify generated `GitHub Auto-close` includes `Closes #46` and excludes `Closes #40/#42/#43` unless explicitly author-asserted in PR Intent.
- [x] Manual verification notes
	- Confirm summary includes either populated `PR Intent -> Author-asserted autoclose issues` or `Issues to autoclose (verified or pending)` with `#46`.
	- Confirm behavior remains conservative when deterministic primary issue cannot be resolved.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

## Final Execution Summary (2026-02-22)

- Implemented deterministic autoclose derivation in `pr_context`:
	- Added `primary_issue_ref` and `readiness_signal` to `FeatureDocExcerpt`.
	- Parsed primary issue from explicit metadata line `Issue: #NN` only.
	- Resolved readiness from latest `feature-audit.*.md` with normalized values (`PASS`, `NEEDS REVISION`, `BLOCKED`).
	- Added summary section `===== Issues to autoclose (verified or pending) =====` ahead of `Close candidates`.
	- Applied precedence: verified closing issues first, then pending deterministic primary issue only when readiness is `PASS`, else conservative `None` fallback.
- Confirmed narrative mentions (`#40/#42/#43`) are not promoted into approved autoclose section.

Verification commands run:
- `poetry run pytest tests/scripts/dev_tools/test_feature_docs.py -q -k primary_issue_and_pass_readiness`
- `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q -k pass_readiness_autoclose_section`
- `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py -q -k narrative_mentions_excluded_from_autoclose_section`
- `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q -k non_pass_readiness_fallback`
- `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

Evidence artifacts:
- Baseline: `evidence/baseline/*.2026-02-22T23-15.md`
- Regression expect-fail/pass: `evidence/regression-testing/*.2026-02-22T23-15.md`
- End-state collector contract: `evidence/other/pass-collector-autoclose-contract.2026-02-22T23-15.md`
- Final QA gates: `evidence/qa-gates/*.2026-02-22T23-15.md`