# legacy-discovery-acceptance-scenarios (Issue #364)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-acceptance-scenarios/ (Issue #364)
- Epic: legacy-discovery-and-parity (child feature #9009; placeholder issue 9009)
- Depends on: legacy-discovery-schemas (#9002)

- Issue: #364
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/364
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral capability for
migrating a legacy application to a modern architecture. One required output is a
set of executable acceptance scenarios derived from the machine-readable discovery
artifacts, so a consumer repository (TaskMaster to TMW first) can verify source-to-target
parity against concrete, reproducible scenarios rather than prose. This feature provides
the generator that turns feature contracts and parity/characterization evidence into
executable acceptance scenarios.

## Proposed Behavior

Provide a deterministic acceptance-scenario generator that consumes three discovery
schemas — the Feature Contract, the Parity Matrix, and the Runtime Characterization
Scenario — and emits executable acceptance scenarios in a defined output format.

- Deterministic: identical input artifacts produce byte-identical scenario output.
- Domain-neutral: no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior.
- Ships a `dev.discovery.*` Python CLI entry point (Poetry console-script) for generation.
- Locates the input schemas via the schema-versioning convention defined by feature #9002,
  isolated behind a single schema-location seam so this feature can proceed before #9002 lands.

## Acceptance Criteria (early draft)

- [ ] A Python module under `scripts/dev_tools/` generates acceptance scenarios from the
      Feature Contract, Parity Matrix, and Runtime Characterization Scenario inputs.
- [ ] Generation is deterministic: identical inputs produce identical output.
- [ ] The output scenario format is defined in spec.md and is domain-neutral.
- [ ] A `dev.discovery.*` Poetry console-script exposes the generator with a
      `def main(argv=None) -> int` entry point and its own argparse parser.
- [ ] The schema-location seam is isolated behind a single function so execution can
      proceed before feature #9002 lands.
- [ ] The core generator contains no domain-specific identifiers.
- [ ] Tests satisfy the repository quality-tier policy (line >= 85%, branch >= 75%).

## Constraints & Risks

- Depends on the schema shapes defined by #9002, which is prepared in parallel; design
  against objective-source.md section 4 and isolate schema location behind one seam.
- Determinism infrastructure (seeded RNG, injected clock) is required only if any
  nondeterministic input is involved.
- Reports (#9010) and analyzers are out of scope for this feature.
- Evidence output must be under `<FEATURE>/evidence/<kind>/` only.

## Test Conditions to Consider

- [ ] Unit coverage of scenario generation from conforming inputs.
- [ ] Determinism: repeated generation yields identical output.
- [ ] Negative flows: missing or malformed input artifacts.
- [ ] CLI examples via the `dev.discovery.*` console-script entry point.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-acceptance-scenarios/` folder from the template
