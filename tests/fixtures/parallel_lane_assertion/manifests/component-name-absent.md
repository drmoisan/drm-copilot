---
parallel: lane-assertion-component-name-absent
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
  - members:
      - 101
      - 202
---

# Parallel Run — lane-assertion-component-name-absent

Shared parity-corpus manifest for the lane-assertion diagnostic. Its single
asserted lane carries no `name` key, so the report must label it by its
zero-based manifest position rather than by a quoted name. The two members are
declared items that share no edge, so the lane is derived apart and the label is
actually rendered in a finding rather than left unexercised.
