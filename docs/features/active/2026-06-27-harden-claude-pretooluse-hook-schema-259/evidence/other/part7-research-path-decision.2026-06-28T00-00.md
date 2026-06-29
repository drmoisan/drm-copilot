# Part-7 Research-Path Migration Decision (out-of-scope no-op)

- Issue: #259
- Task: P9-T3
- Timestamp: 2026-06-28T00-00

## Question

Does `enforce-evidence-locations.ps1` require a new `artifacts/research/` forbidden-prefix
addition to support the Part-7 research-path migration?

## Search

- SearchScope: repository root (all tracked files), with focus on actual evidence/research
  output locations and the hook's own forbidden-prefix list.
- SearchPatterns: `artifacts/research/`
- SearchResult: All matches are one of:
  - the hook's own forbidden-prefix list (`.claude/hooks/enforce-evidence-locations.ps1`
    and its bundled mirror) — `artifacts/research/` is ALREADY present as a forbidden prefix;
  - validators that enforce the same prohibition
    (`scripts/dev_tools/validate_evidence_locations.py`,
    `extensions/drm-copilot/src/lib/validate/evidence-locations.ts`, and their tests);
  - prose in feature docs/plans referencing the prohibition.
  No file actually writes evidence or research output into `artifacts/research/`.

## Repository Research Path Confirmation

Research for this feature is written under
`docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/research/`
(feature-associated), consistent with the canonical
`docs/features/<feature>/research/` (or one-off `docs/research/`) roots documented in the
hook's own description and in `evidence-and-timestamp-conventions`. No `artifacts/research/`
writes exist.

## Decision

No-op. The forbidden-prefix list in `enforce-evidence-locations.ps1` already contains
`artifacts/research/`. The repository writes research under the canonical
`docs/features/<feature>/research/` root and never under `artifacts/research/`. No code
change to the forbidden-prefix list is required for Part 7. The Phase-9 schema
transformation (P9-T1/P9-T2) is the only code change in this phase.
