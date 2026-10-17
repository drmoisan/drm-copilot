# Remediation Inputs — CI failure on PR #954 (Issue #928)

- Timestamp: 2026-10-16T07-05
- Source: S9 CI gate on PR #954, head e03d60829cf9752d650b32afe28cb491f6a29ef6
- Review-Verdict: REMEDIATION_REQUIRED

## Finding CI-1

- Severity: Blocking
- Remediability: autonomous
- Failing checks: `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, `(3.13)`
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/38863111372/job/116849712780
- Failing tests (2 failed, 7107 passed, 6 skipped):
  - `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-d5e5e3b0...]` — expected SHA-256 `d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538`, found `c5b50974afe1718efce7023b2a7e6965d43979de333a84fb4d9fc2192eadd96d`.
  - `...[.claude/skills/epic-orchestrate/SKILL.md-0b1a629a...]` — expected SHA-256 `0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2`, found `b7af3a42d128a140951a07d592067a780429bc9beba0b6ec16afe54c3084b83f`.
- Cause: this item's documentation edits D4 (`.claude/skills/epic-orchestrate/SKILL.md` lines 279-281) and D5 (`.claude/agents/epic-orchestrator.md` lines 133-135) changed the two frozen epic-surface files whose digests are pinned in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`, lines 165-174).
- Expected remediation: re-baseline both pinned digests and append a `RE-BASELINED by issue #928` entry to the comment block above `PINNED_FROZEN_SURFACE_HASHES`, following the precedent entries for #690, #484, #787/#840, and #902. Verify locally with `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.

## Other checks

- `poshqc / PowerShell QC`: pass (coverage artifact available for AC14).
- `poshqc / PowerShell hook suites (Linux)`: pass.
- All remaining checks: pass.
