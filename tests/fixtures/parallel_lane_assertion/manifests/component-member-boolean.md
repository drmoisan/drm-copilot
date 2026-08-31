---
parallel: lane-assertion-component-member-boolean
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
  - name: lane-boolean
    members:
      - true
      - 101
---

# Parallel Run — lane-assertion-component-member-boolean

Shared parity-corpus manifest for the lane-assertion diagnostic. Its asserted
lane lists a boolean member. Python's `bool` subclasses `int`, so a naive
positive-integer test would accept `true` as the key 1; both lanes exclude it
explicitly, and this fixture pins that exclusion. The lane resolves to the single
member 101 and item 202 is left covered by no expected component.
