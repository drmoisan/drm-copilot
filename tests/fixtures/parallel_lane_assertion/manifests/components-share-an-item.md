---
parallel: lane-assertion-components-share-an-item
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
  - issue_num: 303
    feature_folder: docs/features/active/gamma-303
    kind: feature
    state: proposed
  - issue_num: 404
    feature_folder: docs/features/active/delta-404
    kind: feature
    state: proposed
  - issue_num: 505
    feature_folder: docs/features/active/epsilon-505
    kind: bug
    state: admitted
expected_conflict_components:
  - name: lane-a
    members:
      - 101
      - 202
  - name: lane-b
    members:
      - 202
      - 999
  - name: lane-c
    members:
      - 303
      - 404
---

# Parallel Run — lane-assertion-components-share-an-item

Shared parity-corpus manifest for the lane-assertion diagnostic. Lane `lane-a`
and lane `lane-b` both claim the item key 202, so the expected index is built
with the last occurrence winning and no error is reported for the repetition.
The manifest also supplies, in one document, the three remaining ingredients the
report classes need: `lane-b` names the key 999, which is no declared item; item
505 is claimed by no lane; and the five declared keys admit `--edges` values that
split a lane, merge two lanes, or do both. Corpus records built on this manifest
vary only in their `--edges` value.
