---
parallel: lane-assertion-component-name-empty-string
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
  - name: ''
    members:
      - 101
      - 202
---

# Parallel Run — lane-assertion-component-name-empty-string

Shared parity-corpus manifest for the lane-assertion diagnostic. Its single
asserted lane carries an empty-string `name`, which is a present string and must
therefore be quoted in the label rather than falling back to the positional
form. The two members share no edge, so the lane is derived apart and the label
is rendered in a finding.
