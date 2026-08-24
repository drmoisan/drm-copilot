# P2-T6 — Optional Pytest Content-Contract Test Decision

- Timestamp: 2026-07-19T07-33

## Decision: Declined (branch b)

The optional pytest content-contract test under `tests/docs/` is declined for this
feature. This is the plan's authorized default branch (P2-T6, branch (b)).

## Rationale

- Research (`docs/features/active/2026-07-17-legacy-discovery-documentation-371/research/2026-07-17T15-33-legacy-discovery-documentation-371-research.md`,
  section 2) verified the repository has no markdownlint, remark, link-check, or docs
  structural-lint tooling or CI step. No repository policy mandates a structural test for
  Markdown-only documentation changes.
- spec.md's Implementation Strategy states the content-contract test "is not
  repository-mandated" and may be authored "at planning discretion." The plan's P2-T6 text
  confirms branch (b) (explicit decline) is authorized.
- Structural completeness (P2-T1), relative-link resolution (P2-T2), domain-neutrality
  (P2-T3), and naming-collision (P2-T4) verification were performed deterministically via
  `git`/`grep`/`ls` checks recorded as evidence artifacts, providing the equivalent
  assurance a structural pytest test would provide, without adding a new test module for a
  documentation-only change.

Satisfies Definition of Done item 6 (recorded decline).
