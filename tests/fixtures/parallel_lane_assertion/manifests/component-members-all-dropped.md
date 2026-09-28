---
parallel: lane-assertion-component-members-all-dropped
mode: closed
max_concurrency: 4
created_at: "2026-08-29T00:00:00Z"
items:
  - issue_num: 101
    feature_folder: docs/features/active/alpha-101
    kind: feature
    state: proposed
  - issue_num: 202
    feature_folder: docs/features/active/beta-202
    kind: bug
    state: admitted
expected_conflict_components:
  - name: lane-all-dropped
    members:
      - 0
      - false
---

# Parallel Run — lane-assertion-component-members-all-dropped

Shared parity-corpus manifest for the lane-assertion diagnostic. Every member of
its asserted lane is dropped when the lane is read, leaving a lane with an empty
member list. An empty lane can be neither split nor merged, so both declared
items are reported as covered by no expected component and the header names zero
disagreements.
