# Phase 0 Policy-Read Evidence — legacy-discovery-schemas (#359)

Timestamp: 2026-07-18T10-12

Policy Order: The repository-mandated policy reading order was followed per the
`policy-compliance-order` skill and the plan's Required References.

Files read (in required order):

1. `.github/copilot-instructions.md` — repository tone and communication policy.
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (mirror: `.claude/rules/general-code-change.md`).
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (mirror: `.claude/rules/general-unit-test.md`).
4. `.github/instructions/python-code-change.instructions.md` — Python-specific code change rules (mirror: `.claude/rules/python.md`).
5. `.github/instructions/python-unit-test.instructions.md` — Python-specific unit test rules.

Additional standing context loaded via CLAUDE.md and path-scoped `.claude/rules/`:

- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/quality-tiers.md` (line coverage >= 85%, branch coverage >= 75% uniform across tiers)
- `.claude/rules/tonality.md`

Key constraints acknowledged for this feature:

- No new production Python; deliverables are JSON Schema documents, JSON fixtures, and pytest test modules.
- No change to `scripts/dev_tools/validate_json.py` or `scripts/dev_tools/json_config.py`.
- Full Python toolchain loop (Black, Ruff, Pyright, Pytest with coverage, dev.validate-json) required in Phase 5; restart from top on any failure or file change.
- Coverage thresholds: line >= 85%, branch >= 75%; no regression on changed lines.
- Tests must be deterministic and offline; no temporary files; no network fetches; no `.cache/` writes.
- Domain-neutrality invariant: no TaskMaster/TMW/Outlook/VSTO/email/task-management vocabulary in schemas.
- Evidence artifacts written only under the canonical `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/<kind>/` scheme.
