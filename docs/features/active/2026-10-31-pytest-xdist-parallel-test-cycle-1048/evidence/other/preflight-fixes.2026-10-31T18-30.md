Timestamp: 2026-10-31T18-30
Plan: docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/plan.2026-10-31T13-02.md

- P7-T1: artifact names corrected to poshqc-test-results-shard-1..3, each holding pester-junit.xml (_poshqc.yml upload step); the pester-junit-shard-N.xml names exist only after the aggregator job copies them.
- P10-T9: _poshqc.yml no-change check made conditional on the P9-T4 decision, which can add a shard and edit that file.
