# Task Check P1-T3 (R6 escape stems in the shared corpus)

Timestamp: 2026-11-13T15-08
Command: node SCRATCH/issue-1164-gen-stems.js <corpus dir> <corpus dir>; sh SCRATCH/issue-1164-tc-p1t3.sh (env -u VIRTUAL_ENV poetry run pytest tests/scripts/dev_tools/test_parallel_state_scheduling_parity.py -n auto -q -p no:cacheprovider --no-cov -rf); sh SCRATCH/issue-1164-jest-one.sh test/lib/validate/parallel-state-scheduling-parity.test.ts (in extensions/drm-copilot: node run-jest.cjs <path>)
EXIT_CODE: 0
Output Summary:
- New files in tests/fixtures/parallel_state_scheduling/: reject-item-read-path-newline-outside-radius.json, -tab-, -control-, -backslash-, -non-printable-, and -apostrophe-newline-outside-radius.json. Each is the template reject-item-read-path-apostrophe-outside-radius.json with only items[1].read_paths changed, `name` set to the stem, and one expected error. The generator builds every backslash and control character with String.fromCharCode or String.fromCodePoint, and checks that the template re-serializes to its own text.
- Expected reprs, as written: 'docs/a\nb.md'; 'docs/a\tb.md'; 'docs/a\r\x07\x7fb.md'; 'docs\\a.md'; 'docs/é\xa0', then the backslash-u-200b and backslash-u-2028 escapes, then '\U000e0001.md'; "docs/it's\na.md".
- File checks (node byte scan): every new file is ASCII only (non-ASCII and control code points written as JSON backslash-u escapes, U+E0001 as its surrogate pair), has no CR byte, and ends with one LF. Corpus size 30 (floor 20).
- Selection rule: the task's named selection (both parity tests that read the corpus).
- Format and lint: no formatter, linter, or type checker is configured for the JSON fixtures; the existing corpus files use the same JSON.stringify two-space layout.
- pytest (Python's own repr): exit 0; "31 passed" (25 existing cases plus the six stems). This confirms each expected string is CPython's repr output.
- Jest: exit 0; Test Suites: 1 passed; Tests: 31 passed, 31 total. This confirms the P1-T2 port matches it.
- One attempt to run Jest through `npm --prefix ... exec` resolved the session root and fetched an unrelated npm package named node (No tests found, exit 1); it changed no tracked file and was replaced by the sh launcher run recorded above.
- A task check is not a gate and records no coverage.
