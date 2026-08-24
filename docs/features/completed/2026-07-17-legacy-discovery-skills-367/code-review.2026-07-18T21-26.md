# Code Review — legacy-discovery-skills (Issue #367)

- Timestamp: 2026-07-18T21-26
- Branch: `feature/legacy-discovery-skills-367` (commit `13234ea0`) vs `origin/epic/legacy-discovery-and-parity-integration`
- Files reviewed: 7 `SKILL.md` skills, 7 bundle mirrors, `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`

## Pytest Module — `test_legacy_discovery_skills_contracts.py` (415 lines)

### Correctness — PASS

- Path resolution: `REPO_ROOT = Path(__file__).resolve().parents[3]` is correct for `tests/scripts/dev_tools/` depth; `BUNDLED_CLAUDE_ROOT` matches the real bundle location (verified by the passing mirror tests and by direct `cmp`).
- The parametrized tables (`REQUIRED_COMMANDS_BY_SKILL`, `REQUIRED_SCHEMAS_BY_SKILL`, `WORKER_ROUTING_PAIRINGS`) match the spec decomposition table exactly (spec.md lines 127–135); cross-checked against each skill body.
- The nine validator names and seven schema paths match the spec's `## Referenced Contracts` registry one-to-one.
- The module asserts only on this feature's own files; no assertion on #9006/#9007 artifact existence (checked every test body). Fan-in independence claim in the module docstring is accurate.
- The precedent cited in the mirror test docstring (`test_discovery_fix_is_mirrored_into_bundled_payload`) exists at `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py:107`.
- All 60 tests pass (`poetry run pytest ... -q`: 67 passed including the 7 push-down parity gate tests; exit 0).

### Test policy compliance — PASS

- Arrange–Act–Assert with intent comments; every loop has an intent comment above it per the commenting policy; docstrings on every function including private helper `_find_description_line` (Google style with Args/Returns/Raises/Side Effects).
- Deterministic, order-independent, no external dependencies, no temp files, no suppressions, no `Any`, fully typed (Pyright clean).
- Assertion messages name the failing skill and fragment, giving actionable failures.
- Location follows the established contract-test convention (`tests/scripts/dev_tools/`, precedent `test_epic_run_kickoff_discovery_contract.py`).

### Non-blocking observations (advisory, no action required)

1. `test_skill_frontmatter_name_matches_folder` (line 149) and `_find_description_line` (line 195) match `name:`/`description:` lines anywhere in the file, not strictly within the frontmatter delimiters. A body line beginning with these keys could in principle satisfy the assertion. Current skill bodies contain no such lines, and the byte-parity and push-down gates constrain drift, so this is a robustness note only.
2. `test_banned_substrings_absent` scans the repo-side skill text only; bundle mirrors are covered transitively through `test_skill_is_mirrored_into_bundled_payload` (byte equality). The combination satisfies AC-4; noted for clarity.
3. `test_skill_name_does_not_collide_with_code_modernization` checks the plugin name set but not the full existing-skill name set; folder-name uniqueness is enforced structurally by the filesystem (a collision could not exist as two directories). Verified manually: 47 unique names under `.claude/skills/`.

## Seven Skills — Structure and Conventions

### Frontmatter contract — PASS

- All 7: `name:` equals folder name; single-quoted, non-empty, descriptive `description:` including trigger phrasing ("Use when ...").
- `allowed-tools` only on `discovery-repo-inventory` (`Bash Read Glob Grep`) and `discovery-validate-artifacts` (`Bash Read`), matching the spec's decomposition table. Format is the space-delimited form documented in `make-skill-template/SKILL.md` (line 54). Older skills use YAML-list form; both appear in the repository, and the documented contract names the space-delimited form, so this is conforming.
- No `context:`/`agent:` frontmatter, per spec Scope Clarification 3.

### Body conventions — PASS

- Each skill has `# Title`, `## When to Use This Skill`, `## Prerequisites`, a stepwise workflow, and `## Referenced Skills`, per spec `## Implementation Strategy`.
- Canonical-location rule holds: the `## Referenced Contracts` registry appears only in `discovery-workflow`; validation-gate semantics (`list[str]`, empty = pass, error routing table) appear canonically in `discovery-validate-artifacts`; stage skills defer by name.
- The four agent-stage skills each carry a `## Worker Routing` section naming exactly one slug, consistent with the umbrella routing table (`discovery-workflow` lines 60–65).
- Both fan-in reconciliation assumptions are explicitly flagged: inventory command name (`discovery-workflow` lines 109–113 plus one fragment in `discovery-repo-inventory` lines 45–49) and the four agent slugs (`discovery-workflow` lines 125–129). Isolation matches the spec's two-location bound.
- Stage order is consistent across `discovery-workflow` (lines 38–52), each stage skill's "Nth stage" description text, and the test tables.
- No absolute paths, worktree-specific text, or generated timestamps in any skill, keeping mirrors mechanically copyable.

### File size cap — PASS

All files under 500 lines: skills 63, 63, 65, 66, 79, 80, 146; test module 415 (`wc -l`).

### Coverage-exclusion policy — PASS

No production file is excluded from coverage. The only new `.py` file is a test module under `tests/`, a permitted exclusion class. No coverage-configuration file is touched by the diff.

## Blocking Findings

Blocking findings count: 0
