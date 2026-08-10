---
mode: closed
max_concurrency: 4
items: []
---

# Parallel Run — invalid fixture

Checked-in fixture manifest that violates exactly two invariants: M2 (the
`parallel` slug is absent) and M5 (`created_at` is absent). Both errors are
identity errors, so they are emitted in schema field order and the document
exercises the entry point's exit-1 path with more than one error line.
