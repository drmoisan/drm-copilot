# `legacy-discovery-config-contract` — User Story

- Issue: #360
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17T14-03

## Story Statement

- As a consumer-repository maintainer, I want to author a repository-local domain-profile
  configuration file that declares my legacy source location, target location, technology
  stack, and artifact conventions, so that the reusable, domain-neutral legacy-discovery
  framework is driven by my runtime configuration rather than by hardcoded domain knowledge.
- As a consumer-repository maintainer, I want to load and view a resolved domain profile
  through the `dev.discovery.*` CLI (declared values plus applied defaults), so that I can
  confirm the framework interprets my profile as intended before I run any downstream
  discovery tooling.
- As a consumer-repository maintainer, I want a malformed or incomplete profile to fail fast
  with a specific, actionable error that names each offending field by its dotted path, so
  that I can correct every defect in one pass instead of discovering them one at a time.

## Problem / Why

The legacy-discovery-and-parity epic requires a domain-neutral core framework whose domain
specificity is supplied at runtime, never hardcoded. The foundational cross-module contract
is a repository-local domain-profile configuration file that a consumer repository — a
legacy-source repository migrating to a modern-target counterpart — authors to declare its
legacy source location, target location, technology stack, and artifact conventions/paths.
Without a typed, fail-fast loader for this profile, every downstream feature (validators,
analyzers, agent roles, skills) would have to parse domain configuration ad hoc,
reintroducing domain coupling into a framework that must remain domain-neutral.

## Personas & Scenarios

- Persona: consumer-repository maintainer
  - Who they are: an engineer responsible for a repository that is migrating a legacy source
    codebase toward a modern-target counterpart, and who intends to adopt the reusable
    legacy-discovery framework to drive that migration.
  - What they care about: keeping domain specifics (source and target locations, technology
    stacks, artifact layout) in configuration they own, so the framework stays generic and
    upgradable.
  - Their constraints: they author the profile by hand in a text editor; they need portable
    path handling across operating systems; they must not depend on any framework component
    that encodes their domain.
  - Their goals and frustrations: they want a single documented contract for the profile and
    a way to confirm it resolves correctly; they are frustrated by silent partial parsing
    that accepts a typo or a missing field and fails obscurely later.
  - Their context and motivations: they are performing initial framework setup (Wave 0 of
    the epic) and will re-run the CLI whenever they edit the profile.

- Scenario A: author a profile and view the resolved result
  - Who is acting: the consumer-repository maintainer.
  - What triggered the action: the maintainer is setting up the legacy-discovery framework
    for their repository and needs to declare its domain profile.
  - Steps:
    1. The maintainer creates `discovery-profile.yaml` at the repository root and populates
       the required fields (`profile_version`, `legacy_source.root`, `target.root`,
       `technology_stack.legacy`, `artifacts.root`) plus any optional fields they need
       (for example `profile_name`, include/exclude glob lists, or artifact conventions).
    2. The maintainer runs `dev.discovery.profile` with no arguments, relying on the default
       filename.
    3. The CLI loads the profile, applies defaults for every omitted optional field, and
       prints the resolved profile as aligned `key: value` text on stdout, exiting with
       code 0.
    4. The maintainer re-runs with `--json` to obtain a machine-readable rendering of the
       same resolved profile for use in other tooling.
  - Obstacles or decisions: the maintainer decides which optional fields to declare versus
    leave at their defaults; the resolved output makes the applied defaults explicit so the
    decision is verifiable.
  - Expected outcome: the maintainer sees exactly how the framework will interpret their
    profile, including defaulted values, before running any downstream discovery step.

- Scenario B: receive an actionable error on a malformed or incomplete profile
  - Who is acting: the consumer-repository maintainer.
  - What triggered the action: the maintainer edits the profile and inadvertently omits a
    required field, mistypes a key, or supplies a value of the wrong type.
  - Steps:
    1. The maintainer runs `dev.discovery.profile` (or passes an explicit profile path).
    2. The loader parses the file, collects every field defect in one pass (missing required
       field, wrong type, empty required string or list, unsupported `profile_version`, or
       unknown key), and raises a single `DomainProfileError`.
    3. The CLI prints the full multi-error message to stderr, with each defect identified by
       its dotted field path (for example `legacy_source.root: expected non-empty string,
       got int`), and exits with code 1.
    4. For a YAML syntax error, the message includes the source label and the location mark
       so the maintainer can find the malformed line; for a missing or unreadable file, the
       message names the path.
  - Obstacles or decisions: the maintainer must correct the reported defects; because all
    defects are enumerated together, they can fix everything in a single edit rather than
    running repeatedly to surface one error at a time.
  - Expected outcome: the maintainer receives specific, actionable guidance identifying every
    problem in the profile, and the non-zero exit code allows automation to detect the
    failure.

## Acceptance Criteria

- [x] The domain-profile configuration contract is documented with all required and optional fields.
- [x] A dataclass-based typed loader parses a valid profile into a typed object.
- [x] The loader fails fast with specific errors on malformed input and missing required fields.
- [x] The parser-technology decision (PyYAML vs hand-rolled regex) is made and justified in spec.md.
- [x] A `dev.discovery.*` CLI entry point loads and displays a resolved profile.
- [x] The core loader contains no domain-specific (TaskMaster/TMW/Outlook/VSTO/email/task) identifiers.
- [x] Tests satisfy repository quality-tier policy (Python pytest, line >= 85%, branch >= 75%).

## Non-Goals

This feature ships only the domain-profile configuration contract and its typed loader
(including the `dev.discovery.profile` CLI entry point). The following are explicitly out of
scope:

- **JSON schema files** for the domain profile or any discovery artifact. These are owned by
  sibling feature #9002 (`legacy-discovery-schemas`). This feature ships no schema file.
- **Standalone validators** following the `validate_<artifact>_text(text) -> list[str]`
  pattern with an argparse subparser CLI. These are owned by sibling feature #9003
  (`legacy-discovery-validators`). This feature's `parse_domain_profile_text(text, source)`
  provides the text-in interface #9003 will build on, but this feature ships no
  `validate_*_text` validator.
- The artifact-kind vocabulary and per-kind schemas referenced by `artifacts.conventions`
  keys (owned by #9002/#9005); the loader stores the conventions mapping without validating
  its keys.
- Path existence or reachability checks; the loader validates shape and types only. Existence
  checks are a runtime concern for validators (#9003) and analyzers (#9006).
