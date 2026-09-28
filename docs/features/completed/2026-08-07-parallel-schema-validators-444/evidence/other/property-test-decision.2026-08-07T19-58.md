# Property-Test Conditional Decision — [P6-T7]

Timestamp: 2026-08-07T19-58

Command: `grep -n -i "hypothesis" pyproject.toml` (repository root)

EXIT_CODE: 1 (no match — `hypothesis` is not declared anywhere in `pyproject.toml`)

Output Summary:

```
GREP_EXIT=1   (no match for "hypothesis")

[tool.poetry.group.dev.dependencies]
pytest = ">=7.0"
pytest-cov = ">=7.0"
black = ">=23.0"
ruff = ">=0.5.3"
pyright = ">=1.1.407"
pyperclip = "^1.11.0"
jsonschema = "^4.25.1"
types-beautifulsoup4 = ">=4.12.0.0"
types-requests = ">=2.31.0.6"
```

## Branch Taken

Branch (a) — record the tier-based property-test exemption.

The plan text for [P6-T7] defines three branches. Branch selection is driven by the [P6-T6]
outcome:

- Branch (a) applies when no T1/T2 classification applies to the new modules.
- Branch (b) applies when the new modules are classified T1 or T2 AND `hypothesis` is a declared
  dev dependency.
- Branch (c) applies when the new modules are classified T1 or T2 AND `hypothesis` is NOT declared.

[P6-T6] resolved to its recorded-absence branch: `quality-tiers.yml` does not exist at the
repository root, verified at execution time (see
`evidence/other/quality-tiers-classification.2026-08-07T19-58.md`). Because the repository-wide
tier-classification file is absent, no T1 or T2 classification applies to any module delivered by
this feature. The T1/T2 precondition shared by branches (b) and (c) is therefore not met, and
branch (a) is the applicable branch.

## Recorded Exemption

`.claude/rules/quality-tiers.md` makes property-test density a TIER-DEPENDENT gate:
`>= 1 per pure function` for T1 and T2 modules, and `none` for T3 and T4 modules. Because no tier
classification exists for the modules delivered by this feature, the tier-dependent property-test
obligation does not attach. No property-based tests are added by this feature, and no
`tests/scripts/dev_tools/test_parallel_state_properties.py` file is created.

Modules covered by this exemption:

- `scripts/dev_tools/_parallel_state_common.py`
- `scripts/dev_tools/_parallel_state_structures.py`
- `scripts/dev_tools/_parallel_state_records.py`
- `scripts/dev_tools/validate_parallel_orchestrator_state.py`
- `scripts/dev_tools/validate_parallel_planner_state.py`
- `scripts/dev_tools/parallel_manifest_contract.py`

## Dependency Statement

`hypothesis` is NOT a declared dependency in `pyproject.toml` (verified above; no match in the
file, and it is absent from `[tool.poetry.group.dev.dependencies]`). It was NOT added by this
task. `.claude/rules/general-code-change.md` and `.claude/rules/python.md` prohibit adding a
dependency without explicit instruction, and the plan text for [P6-T7] explicitly prohibits adding
`hypothesis` to `pyproject.toml`.

This dependency fact is recorded for completeness. It is not the operative reason for the
exemption: the operative reason is the absence of any T1/T2 classification, which is branch (a).
The branch (c) escalation note is therefore not applicable and is not recorded.

## Unaffected Gates

The exemption is narrow. It removes only the tier-dependent property-test-density obligation. The
uniform gates of `.claude/rules/quality-tiers.md` — format 100%, 0 lint errors, 0 type errors, line
coverage >= 85%, branch coverage >= 75%, no regression on changed lines — apply across all tiers
and remain in force. They are verified in Phase 7 ([P7-T1] through [P7-T9]). Conventional unit
tests for every invariant, including valid, malformed, and absent-optional-key cases, were
delivered in Phases 1 through 5 and are unaffected by this exemption.
