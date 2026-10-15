# Code Review (minor-audit) - Issue #894

- Branch: bug/product-name-examples-remain-in-generic-rules-894
- Head: fd54844d28af843d235e35bb200a58296193d697
- Base: origin/main, merge-base 5dd9d1f33d1c0ccb01a6c34f6fefd959e020aa74
- Scope: full branch diff against the merge base (seven non-docs files plus feature-folder documents and evidence).

## Executive Summary

No blocking findings. Two non-blocking observations are recorded (CR-1, CR-2). The change neutralizes product-name examples in three rule files, mirrors them byte-identically into the bundle, and replaces a name-exception allowlist in the guard test with pinned exact counts.

Verdict: PASS. Blocking findings: 0.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (CR-1) | `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | staleness test `test_pinned_name_entries_are_pushed_files_with_positive_counts` | The staleness test passes vacuously while the pin map is empty. Its behavior is covered only by the in-memory `stale_pinned_entries` unit test. | No action required. | The unit test exercises the staleness logic directly, so the vacuous real-tree pass does not leave the logic untested. | Test file read in full; in-memory staleness test present. |
| Non-blocking (CR-2) | `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | whole file | The guard file is at 499 of 500 lines. Any further addition will require splitting the module. | Split the module before adding further tests. | The file-size limit is 500 lines. | `wc -l` reports 499. |

## Rule edits (three source files and three mirrors)

- `parallel-orchestration.md`: `src/TaskMaster.Domain` is now `src/<Product>.Domain`, matching the placeholder convention in `architecture-boundaries.md`. Former item 7 is now a standalone paragraph after item 6, attributing the drop to the file-shape classifier that runs before write-intent extraction. Item 6 ends with a period and the paragraph precedes "Three mitigations bound these cases:". The wording preserves the issue #797 meaning.
- `typescript.md`: "No-COM architecture assertions" is now "host-neutral architecture assertions", and the sentence names the heading "Host-Neutral Architecture Rules (enforceable assertions)". That heading exists at `.claude/rules/architecture-boundaries.md:17`.
- `csharp.md`: the frontmatter `description` and the body sentence are neutral. `paths:` is unchanged.
- Each mirror is byte-identical to its source (`cmp` reported identical for all three).
- `TaskMaster` and `No-COM` match zero times in all six files (Grep count over each directory).

## Guard test rewrite (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`)

- `PRE_EXISTING_NAME_EXCEPTIONS` no longer appears. `PINNED_NAME_OCCURRENCES: dict[str, int]` replaces it and is empty, with a comment explaining the exact-match semantics.
- Helpers `count_name_occurrences`, `pinned_count_mismatches`, and `stale_pinned_entries` are pure and small. The mismatch helper compares against `pinned.get(path, 0)`, so it detects both new and removed occurrences.
- The real-tree test compares observed counts with the pins. A separate staleness test requires each pinned key to be a scanned file with a positive count.
- In-memory negative tests cover: new occurrence in an unpinned file, new occurrence in a pinned file, removed occurrence in a pinned file, matching counts, count-helper cases, and stale-entry detection. Each follows Arrange-Act-Assert with a descriptive docstring.
- No `tempfile`, `tmp_path`, or file-writing calls are present. The module only reads repository files.
- The file is 499 lines (`wc -l`), under the 500-line limit.
- The module docstring was updated to describe the pinned counts.

## Verdict

PASS. Blocking findings: 0.
