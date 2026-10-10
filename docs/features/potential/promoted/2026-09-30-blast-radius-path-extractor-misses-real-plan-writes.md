# blast-radius-path-extractor-misses-real-plan-writes (Issue #797)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blast-radius-path-extractor-misses-real-plan-writes/ (Issue #797)
- Related: parallel run bug-burndown-2026-09-29

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #797
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/797
- Last Updated: 2026-09-30
## Summary

The blast-radius path extractor rejects several kinds of repository path that atomic plans write, so the derived file list omits them and two items that write the same file can be scheduled concurrently. In 11 of 22 plans in parallel run `bug-burndown-2026-09-29`, the derived list omitted files the plan writes. The V1 validation cannot detect this because it calls the same extractor on the plan side.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `classify_path_token` in `scripts/dev_tools/_blast_radius_extraction.py`, reached through `compute_blast_radius.py` derivation and `_blast_radius_validation.py`
- Data source or fixture: atomic plans of parallel run `bug-burndown-2026-09-29`

## Steps to Reproduce

1. From the repository root, run:
   `python -c "from scripts.dev_tools._blast_radius_extraction import classify_path_token as c; [print(t, c(t)) for t in ['tests/shell/foo.bats','extensions/drm-copilot/jest.config.cjs','tests/out/run.out','.agents/skills/x/refs/foo.bats','Sample.*','.agents/skills/x/SKILL.md','tests/Sample.cs']]"`
2. Note which tokens return `None`.

## Expected Behavior

A token that names a file a plan writes is recorded as a path, so conflict edges are computed against it.

## Actual Behavior

On main at ae7c7779, `classify_path_token` returns `None` for `tests/shell/foo.bats`, `extensions/drm-copilot/jest.config.cjs`, `tests/out/run.out`, `.agents/skills/x/refs/foo.bats`, `.claude/lib/x/.shellcheckrc`, and the separator-free `Sample.*`. It returns `concrete` for `.md`, `.cs`, and `.xml` files and `glob` for `tests/fixtures/Sample.*`.

Two rules cause this:

- A wildcard-free token is accepted only if its final extension is in `RECOGNIZED_PATH_EXTENSIONS` (`_blast_radius_extraction.py:92-97`, test at `:318` and `:338`). The set is `cfg cs csproj ini js json jsx lock md ps1 psd1 psm1 py sh sln toml ts tsx txt xml yaml yml`. It omits `bats`, `cjs`, `rc`, `out`, and every extensionless file name.
- A token without a `/` is accepted only as an exact configured root surface (`:281`, `:301`), so a bare `Sample.*` is dropped.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: the reproduction output above. The PowerShell mirror `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` carries the same extension set (`$script:RecognizedPathExtension`, line 88). The reported misses for paths under `.agents/` and for policy files could not be reproduced for `.md` files: `.agents/skills/x/SKILL.md`, `.github/copilot-instructions.md`, and `.claude/rules/python.md` classify as `concrete`. Those misses are therefore likely caused by unrecognized extensions or extensionless names on such paths; the per-plan evidence from the run should be used to confirm.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An omitted write produces a missing conflict edge, so conflicting items can share a cohort and run concurrently. The measured rate was 11 of 22 plans in one run.

## Suspected Cause / Notes

The extension allowlist was written against the file types seen when the extractor was first built. `#489` deliberately rejects directory-shaped tokens, which is why extensionless names are also excluded. V1 is circular because it validates the extractor's output against the extractor's own classification of the plan.

## Proposed Fix / Validation Ideas

- [ ] Extend `RECOGNIZED_PATH_EXTENSIONS` and the PowerShell mirror to cover at least `bats`, `cjs`, `mjs`, `rc`, `out`, and other types the plans write, or replace the allowlist with a rule that does not depend on extension.
- [ ] Decide how extensionless files and bare-name globs such as `Sample.*` are handled without re-admitting directory-shaped tokens (#489).
- [ ] Add a V1 check that compares the derived list with an independent source, for example the plan's own file-table or task-level write markers, so a shared extractor defect is detectable.
- [ ] Add tests for each newly recognized type, and a parity row for the PowerShell mirror.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
