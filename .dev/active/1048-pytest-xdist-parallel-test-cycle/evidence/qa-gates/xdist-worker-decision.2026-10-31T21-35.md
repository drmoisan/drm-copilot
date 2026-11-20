# Worker decision for the pytest step (P9-T2, P9-T3)

- Research flagged that `-n auto` counts physical cores and might start only 2 workers on a 4 vCPU runner. Measured: `-n auto` started `4/4 workers` on the `ubuntu-24.04` runner (see `ci-timing-n-auto.2026-10-31T21-35.md`).
- A fixed `-n 4` therefore starts the same 4 workers as `-n auto` on this runner. A second CI run with `-n 4` would measure the same configuration, and any difference would be run-to-run noise.
- P9-T2 was not executed for that reason. The decision is to keep `-n auto`, which also adapts if the runner size changes, and to add no `psutil` dependency (owner decision 1).
- Timing: baseline 862 s, `-n auto` 492 s for the 3.13 leg.
- Revisit trigger: if a future run shows `created: N/N workers` with N below the runner's vCPU count, re-measure `-n <vCPU count>`.
