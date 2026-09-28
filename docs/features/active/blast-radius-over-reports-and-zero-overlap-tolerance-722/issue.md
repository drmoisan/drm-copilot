# Bug: blast-radius-over-reports-and-zero-overlap-tolerance (Issue #722)

- Created: 2026-09-27
- Source: GitHub issue #722 body. The potential entry named in the Source line below is not present in this checkout or on any fetched ref, so this file mirrors the issue body.
- Type: bug
- Issue: #722
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/722
- Last Updated: 2026-09-27
- Parallel run: blast-radius-tolerance-2026-09-27
- Work Mode: full-bug

## Summary
Parallel-run scheduling is close to serial for two reasons:
- **Over-reporting.** Blast-radius derivation counts path *mentions* in plan text as write paths.
- **Zero tolerance.** Conflict-edge policy treats any overlap at all as a hard edge.

The operator's direction (2026-09-27) is to raise the risk tolerance: "some overlap is ok provided that the benefit of parallelism outweighs the cost of integrating the branches."

## Environment
- OS/version: any
- Python version: repo default (the Python authority in `scripts/dev_tools/`), plus the PowerShell/bash parity ports
- Command/flags used: `/parallel-plan`; `.claude/lib/blast-radius/*.psm1`; `.claude/lib/bash/compute-cohorts.sh`; `config/blast-radius.json`
- Data source or fixture: runs epic-655-followups, backlog-2026-09-26 and followups-2026-09-27

## Steps to Reproduce
1. `/parallel-plan followups-2026-09-27` over #706-#716 (eleven small, mostly independent follow-ups).
2. Observe that 46 of 55 item pairs come out as conflicting, which gives 8 cohorts for 11 items.
3. Inspect the edges. Many come from glob mentions (`**/models.ts`, `.claude/**`, `tests/*`, `.github/workflows/*.yml`), placeholder example paths (`src/x.ps1`, `src/x.ts`), and read-only policy files (`.github/copilot-instructions.md`).

## Expected Behavior
A conflict edge exists only when the expected integration cost of running two items concurrently exceeds the parallelism benefit. Mentions that are not writes contribute nothing.

## Actual Behavior
- **followups-2026-09-27:** 8 cohorts for 11 items. The planner itself reports that the edges are mostly spurious.
- **epic-655-followups:** a `.claude/**` glob in #663's radius serialized #660 behind it, although #660 only read the overlapping paths.
- **backlog-2026-09-26:** 3 of 4 edges came from paths the plans cited but did not write. Only 588-622 (`autoclose.ts`) was real.

## Logs / Screenshots
- [ ] Attached minimal logs or screenshot
- Snippet: the followups-2026-09-27 planner report (P1), and the three runs' manifests under `docs/features/parallel/`.

## Impact / Severity
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

This is the throughput limit of the backlog burn-down: quota runs at a fraction of the target rate because work is serialized.

## Source
From: docs/features/potential/2026-09-27-blast-radius-over-reports-and-zero-overlap-tolerance.md
