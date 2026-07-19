# Phase 0 — Policy and Requirements Read

Timestamp: 2026-07-18T21-15

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/quality-tiers.md
5. .claude/rules/python.md
6. .claude/rules/python-suppressions.md

Additional policy/reference files read (not part of the required order, but consulted for
compliance and precedent):
- .claude/rules/self-explanatory-code-commenting.md (docstring/comment discipline)
- .claude/skills/atomic-plan-contract/SKILL.md
- .claude/skills/evidence-and-timestamp-conventions/SKILL.md
- .claude/skills/acceptance-criteria-tracking/SKILL.md
- .claude/skills/policy-compliance-order/SKILL.md

Feature requirement documents read:
- docs/features/active/2026-07-17-legacy-discovery-reports-368/issue.md
- docs/features/active/2026-07-17-legacy-discovery-reports-368/spec.md
- docs/features/active/2026-07-17-legacy-discovery-reports-368/user-story.md
- docs/features/active/2026-07-17-legacy-discovery-reports-368/research/research.2026-07-17T15-10.md
- docs/features/active/2026-07-17-legacy-discovery-reports-368/plan.2026-07-17T15-03.md

Deviation confirmed before execution (per delegation directive):
- Verified `scripts/dev_tools/legacy_discovery_validators.py` does not exist and no
  `scripts/dev_tools/discovery/validators.py` exists. The real, merged validator module is
  `scripts/dev_tools/validate_discovery_schema_artifacts.py`, exposing
  `validate_coverage_ledger_text(text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR) -> list[str]`
  and `validate_parity_matrix_text(text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR) -> list[str]`.
  Both signatures are compatible with the `ArtifactValidator` Protocol's `__call__(self, text: str)
  -> list[str]` contract when invoked with a single positional `text` argument (the `cache_dir`
  keyword argument has a default). Phase 2/Phase 3 lazy-import defaults are bound to this real
  module path per the delegation directive's scope-preserving correction.

Precondition note: `scripts/dev_tools/discovery/__init__.py` and
`tests/scripts/dev_tools/discovery/__init__.py` already exist in this worktree (merged from
feature #362, init-templates). `scripts/dev_tools/discovery/__init__.py` is non-empty (exports
`DomainProfile`/profile-loading symbols) and `scripts.dev_tools.discovery` already imports
successfully; `tests/scripts/dev_tools/discovery/__init__.py` is already an empty marker file.
P1-T1/P1-T2 acceptance criteria (file exists, package imports successfully / test marker file
exists) are already satisfied by these pre-existing files; this plan does not overwrite or empty
the production `__init__.py`, since doing so would remove already-merged, in-scope functionality
from a sibling feature and is not required by the stated acceptance criteria.
