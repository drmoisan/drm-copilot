# legacy-discovery-config-contract (Potential)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Draft
- Epic: legacy-discovery-and-parity (child feature #9001, Wave 0, complexity C3)

- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic requires a domain-neutral core framework whose
domain specificity is supplied at runtime, never hardcoded. The foundational cross-module
contract is a repository-local domain-profile configuration file that a consumer repository
(for example TaskMaster or TMW) authors to declare its legacy source location, target
location, technology stack, and artifact conventions/paths. Without a typed, fail-fast
loader for this profile, every downstream feature (validators, analyzers, agent roles,
skills) would have to parse domain configuration ad hoc, reintroducing domain coupling.

## Proposed Behavior

- Define the repository-local domain-profile configuration contract: the fields a consumer
  repository declares (legacy source location, target location, technology stack, artifact
  conventions/paths).
- Provide a typed Python loader (dataclass-based) that parses the profile and fails fast on
  malformed or missing required fields with specific, actionable errors.
- Resolve the explicit specification decision: adopt PyYAML (an already-declared but
  currently-unused Poetry dependency) versus continuing the repository's hand-rolled
  frontmatter regex convention. The decision and its justification are recorded in spec.md.
- Ship a `dev.discovery.*` Python CLI entry point that loads and shows a resolved profile
  (a module under `scripts/dev_tools/` plus one `[tool.poetry.scripts]` line), following the
  existing `dev.*` console-script convention (`scripts.dev_tools.<module>:main`,
  `def main(argv=None) -> int`, argparse parser, `if __name__ == "__main__": raise SystemExit(main())`).

## Acceptance Criteria (early draft)

- [ ] The domain-profile configuration contract is documented with all required and optional fields.
- [ ] A dataclass-based typed loader parses a valid profile into a typed object.
- [ ] The loader fails fast with specific errors on malformed input and missing required fields.
- [ ] The parser-technology decision (PyYAML vs hand-rolled regex) is made and justified in spec.md.
- [ ] A `dev.discovery.*` CLI entry point loads and displays a resolved profile.
- [ ] The core loader contains no domain-specific (TaskMaster/TMW/Outlook/VSTO/email/task) identifiers.
- [ ] Tests satisfy repository quality-tier policy (Python pytest, line >= 85%, branch >= 75%).

## Constraints & Risks

- Domain neutrality is an epic-wide invariant: the loader must contain no domain-specific
  behavior; domain specificity is runtime configuration read from the domain profile.
- Out of scope: the JSON schema files themselves (feature #9002 owns them) and the standalone
  validators (feature #9003 owns them). This feature owns only the profile config contract and
  its loader.
- Substrate: PyYAML>=6.0 is declared in Poetry but not imported anywhere today; all existing
  YAML/frontmatter parsing is hand-rolled regex.

## Test Conditions to Consider

- [ ] Unit coverage: valid profile parse, each required-field-missing case, malformed-syntax case, type-mismatch case.
- [ ] CLI: load-and-show a resolved profile; non-zero exit on malformed/missing profile.
- [ ] Edge cases: optional fields defaulting, unknown-field handling.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-config-contract/` folder from the template
