---
parallel: out-of-subset-run
created_at: "2026-08-29T00:00:00Z"
items: [101, 202]
---

# Parallel Run

Checked-in bash-only fixture. The `items` value is a non-empty flow collection,
which the bash YAML scanner refuses as outside the supported subset, so
`pm_parse_manifest` returns status 2 and the lane-assertion entry point prints
its refusal line and exits 0.

Refusing to answer is deliberate: a guessed parse could disagree with the Python
authority silently, whereas an explicit refusal is visible to the operator.

This fixture lives outside `tests/fixtures/parallel_lane_assertion/` on purpose:
the out-of-subset path has no Python counterpart and is excluded from the shared
parity corpus.
