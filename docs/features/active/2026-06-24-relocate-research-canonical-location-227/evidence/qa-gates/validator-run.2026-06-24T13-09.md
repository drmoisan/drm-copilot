# QA Gate — Evidence-Location Validator Run (P9-T3)

Timestamp: 2026-06-24T13-09

## Run 1 — repository root (clean tree)
Command: poetry run python scripts/dev_tools/validate_evidence_locations.py
EXIT_CODE: 0
Output Summary: No violations. The relocated feature research file at docs/features/active/2026-06-24-relocate-research-canonical-location-227/research/2026-06-24T13-02-relocate-research-canonical-location-227-research.md is NOT flagged (it is under docs/, not a forbidden artifacts/ prefix). Validator exits 0 on the clean tree.

## Run 2 — scratch tree with seeded artifacts/research/ and a new-root file
Command: poetry run python scripts/dev_tools/validate_evidence_locations.py --root <scratch-tree>
Scratch tree contents:
- artifacts/research/seeded.md (seeded forbidden path)
- docs/features/active/feat/research/2026-06-24T13-02-foo-research.md (new canonical root)
EXIT_CODE: 1
Output Summary: Exactly one VIOLATION reported for artifacts/research/seeded.md with suggestion "use docs/features/active/<feature>/research/ or docs/research/ instead". The new-root file under docs/features/.../research/ is NOT flagged. This confirms: (a) artifacts/research/ is now rejected, (b) the new canonical research location is accepted, (c) the canonical suggestion names both new roots.

Acceptance: validator exits 0 on the clean tree; the new research location is not flagged; a seeded artifacts/research/ file is reported as a violation.
