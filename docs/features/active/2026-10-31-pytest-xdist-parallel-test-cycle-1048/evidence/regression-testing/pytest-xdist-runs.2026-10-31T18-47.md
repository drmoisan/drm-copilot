# Full pytest suite under pytest-xdist (#1048, P2-T7)

Timestamp: 2026-10-31T18-47
Command: poetry run pytest -n auto -p no:cacheprovider (three runs); poetry run pytest -n 4 -p no:cacheprovider (one run); git status --porcelain
EXIT_CODE: 0
Output Summary:
All four runs passed with zero failures. The local machine reports 24 logical processors (`nproc`), and `-n auto` started 24 workers. For comparison, the serial run without coverage (P2-T5) took 222.69 s.

| Run | Command | xdist header | Result | pytest seconds | Wall-clock seconds | EXIT_CODE |
| --- | --- | --- | --- | --- | --- | --- |
| auto 1 | `poetry run pytest -n auto -p no:cacheprovider` | `created: 24/24 workers` | 15875 passed, 6 skipped, 0 failed | 59.46 | 62 | 0 |
| auto 2 | `poetry run pytest -n auto -p no:cacheprovider` | `created: 24/24 workers` | 15875 passed, 6 skipped, 0 failed | 66.55 | 68 | 0 |
| auto 3 | `poetry run pytest -n auto -p no:cacheprovider` | `created: 24/24 workers` | 15875 passed, 6 skipped, 0 failed | 73.23 | 75 | 0 |
| four workers | `poetry run pytest -n 4 -p no:cacheprovider` | `created: 4/4 workers` | 15875 passed, 6 skipped, 0 failed | 80.10 | 82 | 0 |

Porcelain check: `git status --porcelain` after the four runs is identical to the output captured immediately before them (12 entries). It lists no path outside `FEATURE` other than entries present before the runs: the pre-existing `.claude/settings.local.json` modification, the P2-T2 test edit, and untracked documents from other items that were present at session start. No file was written by the tests.
