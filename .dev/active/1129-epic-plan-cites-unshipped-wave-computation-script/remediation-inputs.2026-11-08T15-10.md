# Remediation Inputs — Issue #1129, Cycle 1

- Timestamp: 2026-11-08T15-10
- Opened by: orchestrator, after review `2026-11-08T15-10` returned PASS with three Minor findings
- Remediation-Mode: proportionate
- Source artifacts: `code-review.2026-11-08T15-10.md`, `feature-audit.2026-11-08T15-10.md`, `policy-audit.2026-11-08T15-10.md`

The review recorded no blocking finding. The orchestrator opens this cycle because two Minor findings bear directly on the behavior this item delivers (parity of the shipped wave CLI with its reference, and the reach of the regression test the owner required). They are fixed inside the item rather than filed as follow-ups. Finding 2 of the review (which of two errors is reported when a manifest holds both a cycle and an unresolved reference) is not in scope: both implementations reject such a manifest, and no change is made.

## Findings in scope

### F1 — CLI rejects manifests whose keys differ only by case

- Remediability: autonomous
- Finding-Scope: contained
- Location: `.claude/lib/epic-wave/EpicWave.psm1` (`Invoke-EpicWaveCommand`, manifest parsing) and its bundled and `resources/lib/epic-wave/` copies.
- Observed: a manifest such as `{"a":[],"A":["a"]}` makes the CLI exit 2 with a "not valid JSON" message, because `ConvertFrom-Json` without `-AsHashTable` rejects keys that differ only by case. The module help states that names compare case-sensitively, and the Python reference `compute_wave_numbers` accepts that manifest and returns `{"a": 0, "A": 1}`.
- Required: the CLI parses the manifest case-sensitively (for example `ConvertFrom-Json -AsHashTable`, which yields a case-sensitive hashtable, with the shape checks preserved) so it returns the same wave map as the Python reference. Add a corpus case with case-variant keys to `tests/fixtures/epic_wave/wave-computation-cases.json` so both the pytest and Pester parity lanes cover it, and a CLI test in `tests/scripts/claude-lib/epic-wave/EpicWave.Tests.ps1`. Bundled copies stay byte-equal.

### F2 — Regression test does not see every citation form or every epic surface

- Remediability: autonomous
- Finding-Scope: contained
- Location: `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py`.
- Observed: the path extractor misses the module form `python -m scripts.dev_tools.<module>` (and `./scripts/...` prefixes), and the scanned surface set omits the epic skills `epic-run` and `review-epic` (Claude `.claude/skills/` and Codex `.agents/skills/`) and the agent `.claude/agents/epic-review.md` and its Codex counterpart. The test therefore would not fail for a citation in those forms or files, which is the defect class issue #1129 exists to catch.
- Required: extend the extractor to normalize `scripts.dev_tools.<module>` module references to `scripts/dev_tools/<module>.py` and to strip a leading `./`; extend the surface set to every epic skill and agent present in the tree (`epic-*` and `review-epic` skills, `epic-*` agents, Claude and Codex), keeping each surface paired with its runtime's `core.json`. Add in-memory tests for the module form and the `./` prefix. If a newly scanned surface cites an unshipped script, that is a real finding: ship it or allowlist it only with an MCP-route reason, never by weakening the extractor. The allowlist and stale-entry checks stay as they are.

## Exit condition

Both findings fixed, the three parallel gates (one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest only if TypeScript changes) green with no new failure and no coverage drop against the `Phase 0 baseline`, and a reaudit with zero blocking findings.
