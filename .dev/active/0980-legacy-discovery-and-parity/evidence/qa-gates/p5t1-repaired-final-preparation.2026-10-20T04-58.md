# P5-T1 repaired final preparation

Timestamp: 2026-10-20T04-58
Command: `poetry run python SCRATCH/issue-980-p5t1-repaired-prepare.py`
EXIT_CODE: 0
Output Summary: Preparation only; no gate or behavioral execution. Four measured modules, 213 affected unit cases, four contracts, unchanged native 14 assertions first.

The sequence is formatting, lint, whole-repository types, static checks, the original native regression precheck, isolated reverse direct-scope/graph/caller batches, coverage reconciliation and the four existing contracts. Failure or changed source restarts formatting.

The six direct selectors account for 17 cases and are listed with reasons in the paired JSON. The other populations are 58 graph and 138 callers. No helper/legacy114 or unrelated ledger-disposition replay is planned.

P2-T6 scope coverage is retained only for exact unchanged callable ASTs. Current changed-function, changed-line and no-loss checks remain mandatory and separate from current raw coverage.

The original native assertions and harness are byte-identical. All 14 execute before the long caller replay; previous assertions10-14 were unexecuted. The historical failure, diagnostic and raw archive remain immutable.

Execution requires the independent repair confirmation, checked commit/push, fresh exact routing receipt and a release binding of this preparation to committed source hashes.
