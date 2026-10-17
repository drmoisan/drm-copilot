# P8-T8 Fail-before exception dossier for the generated-family parity rows (AC-19)

Timestamp: 2026-10-09T05-46
WhyFailingRunImpossible: All four copies of the generated-agent family list (the module `$script:GENERATED_AGENT_FAMILIES`, `config/orchestration-routing.json` `codex_model_policy.generated_agent_families`, the Python `GENERATED_AGENT_FAMILIES` frozenset, and the hard-coded copy in `CodexDeployment.Parity.Tests.ps1`) are equal today, so the live parity rows pass on first run and no failing run of them exists to capture.

## Alternative proof

The discriminating cases are the rows that pass because the check throws or differs on a divergent, empty, or null input:

- `AC-19 extractor rejects text with zero declarations`: the extractor throws on text with no declaration (asserted with `Should -Throw`).
- `AC-19 extractor detects a divergent member`: a fixture literal with one extra member yields a sorted set that differs from the module set.
- `AC-19 non-vacuity check rejects an empty set and a null set`: the non-vacuity check throws for `@()` and for `$null`.

These three rows ran green in the P8-T9 run (see `families-parity-pass.*.md` in this folder), which shows that a divergent, empty, or null extraction would be reported as a failure.
