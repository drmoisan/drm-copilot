---
- alpha
- beta
---

# Parallel Run

Checked-in bash-only fixture. Its frontmatter parses to a sequence rather than a
mapping, so invariant M1 reports `Parallel manifest frontmatter must be a
mapping.` and the lane-assertion entry point prints its unparseable line and
exits 0.

This fixture lives outside `tests/fixtures/parallel_lane_assertion/` on purpose:
the unparseable path is exercised by the bash unit suite only and is not a
member of the shared parity corpus.
