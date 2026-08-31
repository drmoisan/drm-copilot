---
parallel: lane-assertion-two-items
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
---

# Parallel Run — lane-assertion-two-items

Shared parity-corpus manifest for the lane-assertion diagnostic. It declares
exactly the item keys 101 and 202 and carries no `expected_conflict_components`
key, so every finding a record built on it reports comes from the derived graph
alone. The two keys are pinned because several corpus records name this manifest
and supply a determinate `--edges` value against those keys.
