---
parallel: "admission-seed"
mode: "open"
max_concurrency: 4
created_at: "2026-11-03T10:00:00Z"
items:
  - issue_num: 1101
    feature_folder: "docs/features/active/admission-seed-alpha-1101"
    kind: "feature"
    state: "prepared"
    blast_radius:
      paths:
        - "scripts/sample/alpha.ps1"
        - "docs/features/active/admission-seed-alpha-1101/**"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-11-03T10:00:00Z"
  - issue_num: 1102
    feature_folder: "docs/features/active/admission-seed-beta-1102"
    kind: "feature"
    state: "prepared"
    blast_radius:
      paths:
        - "scripts/sample/beta.ps1"
        - "docs/features/active/admission-seed-beta-1102/**"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-11-03T10:00:00Z"
---

# Parallel Run: admission-seed

Fixture manifest for the prepared-item admission integration scenarios (issue #1047).
Item 1102 runs after item 1101 by operator precedence; the two items share no conflict edge.
