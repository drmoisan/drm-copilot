---
parallel: payload-smoke
mode: closed
max_concurrency: 4
created_at: "2026-08-10T00:00:00Z"
items:
  - issue_num: 101
    feature_folder: docs/features/active/alpha-101
    kind: feature
    state: proposed
    blast_radius:
      paths:
        - src/alpha.ts
      modules: []
      shared_surfaces: []
      contracts: []
      source: declared
      computed_at: "2026-08-10T00:00:00Z"
  - issue_num: 202
    feature_folder: docs/features/active/beta-202
    kind: bug
    state: admitted
    blast_radius:
      paths:
        - src/beta.ts
      modules:
        - core
      shared_surfaces: []
      contracts: []
      source: declared
      computed_at: "2026-08-10T00:00:00Z"
---

# Parallel Run — payload-smoke

Checked-in fixture manifest used by the shell test suites. It is a valid
manifest under invariants M1 through M7 and declares both accessor keys at
their documented defaults, so the accessor assertions pin the present-value
path rather than the fallback path.
