# Phase 3 — Single-Source Verification (no second hardcoded surface list in Python)

Timestamp: 2026-08-08T11-40
Task: [P3-T8]

Command: `rg -n "poetry\.lock|package-lock\.json|quality-tiers\.yml" scripts/dev_tools/`

EXIT_CODE: 1 (ripgrep exits 1 for "no matches found", which is the required result)

## Raw output

No output. Zero matches.

## What this proves

None of the three separator-free surface names appears as a literal anywhere under
`scripts/dev_tools/`, which is the whole Python production tree for this library. The
separator-free acceptance set therefore has exactly one source: `config_root_surfaces(config)` in
`scripts/dev_tools/_blast_radius_validation.py`, which filters `config["shared_surfaces"]` to the
entries carrying no `/` and contains no literal surface name of its own.

Both production entry points read that one source from the same `config` mapping:

- `derive_blast_radius` (`scripts/dev_tools/compute_blast_radius.py`) binds
  `root_surfaces = config_root_surfaces(config)` once and passes it to BOTH the
  `extract_plan_paths` call and the `extract_paths_from_lines(normalize_lines(spec_text))` call.
- `validate_blast_radius` (`scripts/dev_tools/_blast_radius_validation.py`) passes
  `root_surfaces=config_root_surfaces(config)` to `extract_plan_paths`.

Because both call the same reader on the same mapping, derivation and V1/V2 can never disagree
about which separator-free tokens are admissible, which is the structural mitigation for the
V1/V2 self-consistency risk recorded in the spec's `## Risks & Mitigations` item 4.

The three strings remain present only in `config/blast-radius.json` (the truth table, unmodified
by this change set) and in tests and fixtures, which is exactly what the spec's acceptance
criterion at line 635 permits.

Output Summary: `rg` exits 1 with zero matches under `scripts/dev_tools/`. No second hardcoded
surface list was introduced in any Python production module. `config_root_surfaces` is the sole
source of separator-free acceptance and is consumed by both `derive_blast_radius` and
`validate_blast_radius` from the same `config` mapping.
