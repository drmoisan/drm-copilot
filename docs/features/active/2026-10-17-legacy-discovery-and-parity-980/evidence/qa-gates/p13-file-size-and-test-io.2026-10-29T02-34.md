# P13-T6 Physical line counts and forbidden test I/O

Timestamp: 2026-10-29T02-34
Task: [P13-T6] Repeat repository and publication contracts on the final tree.
Command: `git ls-files` into `SCRATCH/t6-tracked.txt`; `poetry run python SCRATCH/issue-980-p11t8-lines.py SCRATCH/t6-tracked.txt` (physical line counts, as `wc -l`, of every tracked `.py`, `.ts`, `.tsx`, `.js`, `.cjs`, `.mjs`, `.ps1`, `.psm1`, `.psd1`, `.sh`, `.bats` and `.cs` file); `git diff --name-only --diff-filter=AMR` from the merge base of origin/main and HEAD into `SCRATCH/t6-branch-files.txt`, its intersection with the over-500 list, and `git status --porcelain` for untracked files; `poetry run python SCRATCH/issue-980-p11t8-test-io.py SCRATCH/t6-branch-files.txt`
EXIT_CODE: 0 (line scan: `CHECKED=2641 OVER_500=25 FIXTURES_OVER_500=0`), 0 (intersection: `BRANCH_OVER_500=0`), 0 (test I/O scan: `SCANNED=306 HITS=9`)
Output Summary: Zero files over 500 physical lines among the branch's added, modified or renamed files. The P12-T10 split brought `scripts/dev_tools/agentic_sync.py` and `tests/scripts/dev_tools/test_agentic_sync.py` under the limit, so the P11-T8 deviation is closed, and P13-T3 brought `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` and its two bundle copies back to 500 lines. The 25 remaining tracked files above 500 lines are all outside the branch file set. The only untracked files at the time of the scan were four new P13-T5 evidence records, which are Markdown.

The forbidden-I/O scan over the 306 changed test files finds nine token hits, all the P11-T8 set and every one classified as not I/O:
- three `monkeypatch` targets that name the `gateway_local.subprocess` seam the tests replace;
- four recording lists or docstrings that use the word `requests`;
- one docstring sentence containing `inspect recorded requests`;
- one comment in `enforcement-hooks-no-python-invocation.Tests.ps1` that names the forbidden `Start-Process` token.

No changed test creates a temporary file, starts a process or touches the network.
Result: PASS
