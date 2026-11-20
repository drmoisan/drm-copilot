# parallel-cohorts-split-words-drops-tokens-after-first-newline (Issue #794)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-cohorts-split-words-drops-tokens-after-first-newline/ (Issue #794)
- Related: #609

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #794
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/794
- Last Updated: 2026-09-30
## Summary

`pcoh_split_words` in `.claude/lib/bash/parallel-cohorts.sh` splits its input with `read -ra ... <<<"$1"`, which reads only the first line. Any token after the first newline in a `--keys` or `--edges` value is dropped silently. This is the defect class that #609 reports for `parallel-lane-assertion.sh`. Note that #609 is still open and `parallel-lane-assertion.sh:86` still contains `read -ra tokens <<<"$text"` on main, so the class is not yet fixed anywhere; this entry records the additional site so it is fixed together with #609.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, Git Bash
- Python version: n/a
- Command/flags used: `sh .claude/lib/bash/compute-cohorts.sh --keys "<value with newline>"`
- Data source or fixture: none

## Steps to Reproduce

1. Run `sh .claude/lib/bash/compute-cohorts.sh --keys "1 2"`.
2. Run `sh .claude/lib/bash/compute-cohorts.sh --keys "$(printf '1\n2')"`.
3. Compare the two outputs.

## Expected Behavior

Both runs report both keys, for example `[[1,2]]`, matching the Python authority, which splits on any whitespace.

## Actual Behavior

Step 1 prints `[[1,2]]`. Step 2 prints `[[1]]`: key 2 is dropped with no diagnostic. Reproduced on main at ae7c7779.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `.claude/lib/bash/parallel-cohorts.sh:62` is `read -ra PCOH_WORDS <<<"${1-}"`. `pcoh_split_words` is called from `compute-cohorts.sh:71` and `:77` (`--keys`, `--edges`), `compute-concurrency-batches.sh:102`, and at `parallel-cohorts.sh:82,124,133,169,181,223,297`. Other first-line-only `read -ra` sites in the same library: `parallel-items-validate.sh:71` and `:238`, and `parallel-lane-assertion.sh:86,110,211,238,249,287,318,342,369,396,402,433,439,448,454` (the last group belongs to #609).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

A multi-line `--keys` or `--edges` value silently produces a schedule that omits items or conflict edges, which can place conflicting items in the same cohort. Callers that pass space-separated single-line values are not affected.

## Suspected Cause / Notes

`read -ra` terminates at the first newline. The comment at lines 54-60 justifies `read -ra` only by pathname expansion and does not consider newlines. Line-based consumers such as `done <<<"$ordered"` are separate and not affected.

## Proposed Fix / Validation Ideas

- [ ] Split with `read -d '' -ra` (or convert newlines to spaces first) in `pcoh_split_words`, and apply the same change chosen for #609 to the other sites so the library has one tokenizing rule.
- [ ] Add a bats row for `compute-cohorts.sh` and `compute-concurrency-batches.sh` with a newline-separated `--keys` and `--edges` value, compared with the Python authority.
- [ ] Coordinate with #609 so a single change and a single divergence decision cover both files.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
