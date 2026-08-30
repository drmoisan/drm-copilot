---
parallel: lane-assertion-component-member-non-positive
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
  - name: lane-non-positive
    members:
      - 0
      - -5
      - 101
---

# Parallel Run — lane-assertion-component-member-non-positive

Shared parity-corpus manifest for the lane-assertion diagnostic. Its asserted
lane lists a zero member and a negative member alongside one real item key. Both
non-positive values are dropped when the lane is read, so the lane resolves to
the single member 101 and item 202 is left covered by no expected component.
