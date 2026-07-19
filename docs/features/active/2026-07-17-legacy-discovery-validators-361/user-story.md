# `legacy-discovery-validators` — User Story

- Issue: #361
- Owner: drmoisan
- Status: Ready for Planning
- Last Updated: 2026-07-17T14-03

## Story Statement

- As a consumer-repository maintainer authoring discovery artifacts (a domain
  profile or one of the seven schema-governed artifacts), I want a
  deterministic CLI command that tells me exactly which fields or structure
  are wrong, so that I can correct my artifact without guessing at the
  schema or config contract.
- As a completion-gate hook, report generator, or MCP tool that needs to
  confirm an artifact conforms to its contract before proceeding (#9004,
  #9010, #9011), I want a single authoritative, importable
  `validate_<artifact>_text` function per artifact type, so that I do not
  need to reimplement or duplicate schema-conformance logic in each
  consuming surface.
- As a framework maintainer responsible for the domain-neutral core, I want
  the validators to be generic over the schema and config contracts, with no
  domain-specific identifier or hardcoded schema layout, so that the
  validators remain reusable for any consumer repository and remain correct
  when #9002's versioning convention finalizes.

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. Consumer repositories author a domain-profile
configuration (feature #9001) and produce seven versioned JSON-schema-governed
artifacts (feature #9002). Without deterministic validators, there is no
programmatic gate that a domain profile or a produced discovery artifact
conforms to its contract. This feature supplies those validators so that the
completion-gate hooks (#9004), reports (#9010), and MCP/VS Code surfaces (#9011)
can rely on a single authoritative conformance check.


## Personas & Scenarios

- **Persona: Consumer-repository maintainer (for example, a `TaskMaster`
  contributor authoring a Feature Contract artifact).**
  - Who they are: a maintainer of a consumer repository migrating a legacy
    application, responsible for producing the seven discovery artifacts
    (#9002) and the domain profile (#9001) that describe their system.
  - What they care about: getting a specific, actionable error when their
    hand-authored or agent-generated artifact does not conform, rather than
    a generic failure or a downstream tool crash.
  - Constraints: they are not necessarily familiar with the discovery
    schemas' internal structure or the domain-profile config contract in
    detail; they rely on the validator's error text as the primary feedback
    channel.
  - Goals and frustrations: they want a fast, local, deterministic check
    they can run repeatedly while iterating on an artifact, without needing
    network access or a running service.
  - Context and motivations: their artifact will later be consumed by
    completion-gate hooks (#9004), coverage/parity reports (#9010), and an
    MCP/VS Code surface (#9011); an artifact that fails validation there
    blocks those downstream consumers.

- **Scenario: Authoring and correcting a Feature Contract artifact.**
  - Who is acting: the consumer-repository maintainer described above.
  - What triggered the action: the maintainer has drafted a Feature
    Contract JSON artifact for a legacy feature and wants to confirm it
    conforms to the Feature Contract schema (#9002) before committing it.
  - Steps taken:
    1. The maintainer runs
       `dev.discovery.validate-feature-contract path/to/contract.json`.
    2. The command exits with status `1` and prints, to stderr, a specific
       error such as `['acceptance_criteria']: 'acceptance_criteria' is a
       required property.`
    3. The maintainer adds the missing `acceptance_criteria` field to the
       artifact and re-runs the same command.
    4. The command exits with status `0` and prints, to stdout, a single
       line: `feature-contract validation passed: path/to/contract.json`.
  - Obstacles or decisions: if the artifact's `$schema` field is missing or
    unresolvable, the validator reports that as a distinct error string
    rather than raising an unhandled exception.
  - Expected outcome: the maintainer has a corrected, conformant artifact
    and a deterministic, repeatable local check they can re-run before
    every commit or before a completion-gate hook runs the same validator.


## Acceptance Criteria

- [x] A pure `validate_<artifact>_text` function exists for the domain-profile config and for each of the seven schemas, returning `list[str]`.
- [x] A single argparse CLI exposes one subparser per artifact type plus `all`, matching the canonical pattern (errors to stderr, one success line to stdout, `main() -> int` returning 0/1).
- [x] `dev.discovery.validate-*` Poetry console-script entry points are registered.
- [x] Each validator accepts its conforming fixtures and rejects its non-conforming fixtures with human-readable error strings.
- [x] Per-schema validators locate schemas via the #9002 versioning convention rather than a hardcoded layout.
- [x] No domain-specific identifier appears in the validator source.
- [x] Tests satisfy quality-tier policy (line >= 85%, branch >= 75%), co-located in the mirrored `tests/` tree. **Gap (feature-review 2026-07-18T16-04):** aggregate/repo-wide coverage meets the policy, but `schema_loading.py`'s own branch coverage (71.43%) does not; see `code-review.2026-07-18T16-04.md` Finding 1. Test co-location itself is fully compliant. **Gap closed (remediation 2026-07-18T16-04):** three test functions added to `tests/scripts/dev_tools/test_schema_loading.py` (no production code change) closed the branch-coverage gap; `schema_loading.py` now measures 92.86% branch coverage and 85.71% line coverage in the test-file-scoped rerun. Verified in `evidence/qa-gates/schema-loading-branch-coverage-fix.2026-07-18T16-30.md`.


## Non-Goals

- No domain-specific (TaskMaster/TMW/Outlook/VSTO/email/task-management)
  behavior in the validators; all domain specificity remains in the runtime
  domain profile.
- This feature does not implement the domain-profile configuration contract
  or its typed loader itself (#9001); it consumes that contract.
- This feature does not implement the seven JSON schemas or the
  schema-versioning convention itself (#9002); it consumes those schemas.
- This feature does not implement the completion-gate PowerShell hooks that
  invoke these validators (#9004); it supplies the validators those hooks
  call.
- This feature does not implement the coverage, parity, or completion
  reports (#9010); those reports consume this feature's validators.
- This feature does not implement the MCP tool or VS Code command surfaces
  (#9011); those surfaces wrap the `dev.discovery.*` CLI commands this
  feature exposes.
