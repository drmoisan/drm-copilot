# Destination-Runtime `poetry run` Residual Audit — Issue #462

Timestamp: 2026-08-10T17-05

Task: [P6-T8]
Command:
```
git grep -n "poetry run" -- .claude/skills/parallel-plan .claude/skills/parallel-add .claude/agents/parallel-planner.md
git grep -n "poetry run" -- '.claude/skills/parallel-*' '.claude/agents/parallel-*'
```
EXIT_CODE: 0

## Output Summary

**Zero in-scope hits.** No `poetry run` invocation remains on the `/parallel-plan`
destination-runtime path. Every destination-runtime step now resolves through the published
payload: the PowerShell blast-radius port under `.claude/lib/blast-radius/` and the bash
entry points under `.claude/lib/bash/`.

### First command — in-scope scope

Two textual matches, neither an invocation:

| Location | Text | Disposition |
| --- | --- | --- |
| `.claude/agents/parallel-planner.md:16` | `- "Bash(poetry run *)"` | Allowlist entry, not an invocation. Retained for repository-local paths; no destination-runtime step requires it. |
| `.claude/agents/parallel-planner.md:175` | `The "Bash(poetry run *)" allowlist entry is retained for the repository-local paths that still need it` | Prose explaining the retained entry. |

`.claude/skills/parallel-plan/SKILL.md` and `.claude/skills/parallel-add/SKILL.md` produce
**no matches at all**.

### Second command — accepted residual hits outside #462 scope

| Location | Text | Disposition |
| --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md:415` | checkpoint-validator CLI fallback (`validate_orchestration_artifacts`) | **Out of scope by plan [P6-T2].** The MCP tool is the primary path; this is the documented fallback. Left unchanged. |
| `.claude/skills/parallel-orchestrate/SKILL.md:733` | `parallel_drift_detection_cli` | **Out of scope by plan [P6-T2] and the spec Non-Goals.** No bash port exists for drift detection. Left unchanged. |
| `.claude/skills/parallel-remove/SKILL.md:108` | `parallel_mutation_abandon_cli.py` | **Out of scope by the spec Non-Goals.** No bash port exists for the mutation-abandon CLI. Left unchanged. |
| `.claude/agents/parallel-orchestrator.md:16-17` | `- "Bash(poetry run python -c *)"`, `- "Bash(poetry run python -m *)"` | Allowlist entries, not invocations. Retained for the two residual CLI paths above. |
| `.claude/agents/parallel-orchestrator.md:87-91` | prose explaining the two retained grants | Documentation, not an invocation. |

## Repointed References

| File | Change |
| --- | --- |
| `.claude/skills/parallel-plan/SKILL.md` | Radius derivation, V1-V3 validation, and contention repointed to `Import-Module .claude/lib/blast-radius/BlastRadius.psm1`; cohort seeding repointed to `bash .claude/lib/bash/compute-cohorts.sh`; batching repointed to `compute-concurrency-batches.sh`; manifest validation and both accessors repointed to `bash .claude/lib/bash/validate-parallel-manifest.sh`. |
| `.claude/skills/parallel-orchestrate/SKILL.md` | Four in-scope references repointed: the schema-enforcement note, the manifest gate, the concurrency-batching function, and the recoloring delegation. Lines 415 and 733 untouched. |
| `.claude/skills/parallel-add/SKILL.md` | Contention repointed to `Test-BlastRadiusConflict` from the PowerShell port. |
| `.claude/agents/parallel-planner.md` | `"Bash(bash .claude/lib/bash/*)"` added; `## Upstream Library Invocation` rewritten to name the ported libraries, with the Python modules cited as repository authority only. |
| `.claude/agents/parallel-orchestrator.md` | `"Bash(bash .claude/lib/bash/*)"` added; the manifest-gate paragraph rewritten to the bash entry point; the two `poetry run` grants retained with an updated justification. |

Every file above is mirrored byte-identically into
`extensions/drm-copilot/resources/claude-customizations/` per [P6-T7].
