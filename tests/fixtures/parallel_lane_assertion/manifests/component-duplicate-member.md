---
parallel: lane-assertion-component-duplicate-member
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
  - name: lane-duplicate
    members:
      - 101
      - 101
      - 202
---

# Parallel Run — lane-assertion-component-duplicate-member

Shared parity-corpus manifest for the lane-assertion diagnostic. Its asserted
lane repeats the member 101. The repetition is kept rather than collapsed, so
the fixture pins that a duplicate changes neither the distinct-component count
the split finding reports nor the finding's own sorted member list.
