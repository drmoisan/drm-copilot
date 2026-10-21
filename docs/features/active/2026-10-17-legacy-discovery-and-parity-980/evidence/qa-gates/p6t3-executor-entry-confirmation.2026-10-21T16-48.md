# P6-T3 public-entry prerequisite confirmation — issue 980

READY_FOR_CHECKED_WIP. The public-entry subset is confirmed; P6-T3 remains unchecked.

The two-file delta preserves 41 accepted definition ASTs, installed local-user ports, process streams, lazy service wiring and count-before-slice defaults. Explicit arguments are forwarded without copying or global argv mutation. No source or test finding remains.

Ordered Black, Ruff, Pyright and the focused run passed. All 40 cases passed in 26.262355 seconds: five new controls and 35 retained wrapper/count/reader controls. The earlier fixture failure and static attempts remain preserved.

Fresh BODY coverage is 5/5 statements and 2/2 branches for run_installed_cli, and 1/1 statements for _main. Raw module coverage remains 135/147 statements and 11/12 branches. Separate exact unchanged-AST mapping qualifies 147/147 and 12/12 across 43 ranges without changing raw counters. All 247 at-run bindings were unchanged; 29 archived members and recorded raw/readable mappings were reconciled.

Package regeneration, remaining adapter integration, combined final isolation/contracts and task acceptance remain pending. The prior package manifest is retained as historical at-run identity. No source/test, Git, plan, AC or checkpoint write was made by this review.

Receipt: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-executor-entry-confirmation.2026-10-21T16-48.json`. Exact actual-delta union: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t3-entry-staging-union.2026-10-21T16-48.json`. HEAD: `e926b481d9958b174a4012fb3bb268a390fa8fc2`.

Counts remain 48/84 tasks and 25/66 ACs. Current phase: P6. Next five: P6-T3, P7-T1, P7-T2, P7-T3, P8-T1.
