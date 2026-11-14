# Full pytest suite, seeded shuffled order, one process per seed (#1048, P2-T6)

Timestamp: 2026-10-31T18-42
Command: PYTHONPATH=SCRATCH/issue-1048-plugins ISSUE_1048_ORDER_SEED=<seed> poetry run pytest -p order_plugin -p no:cacheprovider (seeds 1048, 20261031, 7, run one after another)
EXIT_CODE: 0
Output Summary:
All three seeded runs passed with zero failures; the order plugin shuffles the collected items with `random.Random(seed)`.

| Seed | Command | Plugin header | EXIT_CODE | Result | Failures |
| --- | --- | --- | --- | --- | --- |
| 1048 | `ISSUE_1048_ORDER_SEED=1048 poetry run pytest -p order_plugin -p no:cacheprovider` | `mode=shuffle seed=1048` | 0 | 15875 passed, 6 skipped in 389.41 s | 0 |
| 20261031 | `ISSUE_1048_ORDER_SEED=20261031 poetry run pytest -p order_plugin -p no:cacheprovider` | `mode=shuffle seed=20261031` | 0 | 15875 passed, 6 skipped in 374.05 s | 0 |
| 7 | `ISSUE_1048_ORDER_SEED=7 poetry run pytest -p order_plugin -p no:cacheprovider` | `mode=shuffle seed=7` | 0 | 15875 passed, 6 skipped in 392.32 s | 0 |
