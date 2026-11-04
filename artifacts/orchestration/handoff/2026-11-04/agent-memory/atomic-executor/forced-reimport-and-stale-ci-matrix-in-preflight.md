---
name: forced-reimport-and-stale-ci-matrix-in-preflight
description: Import-Module -Force from inside a module removes a test suite's global import of the re-imported module; and quality-checks dropped Python 3.10 on 2026-10-31, so specs naming a 3.10 job are unsatisfiable
metadata:
  type: project
---

Observed 2026-11-04 in the issue 1031 confirming preflight.

1. `Invoke-DocsAnalyzer` (`.claude/lib/docs/DocsAnalyzerRegistry.psm1`) defaults to `Import-Module -Force` of the row's module. A SCRATCH probe (copy of `.claude/lib` plus stub modules) showed: re-importing a module whose function is on the call stack works (the running function keeps its old instance), and repeated calls through a caller module work, but when a test imports the module globally, the forced re-import removes that global import after the first call, so the next call fails with CommandNotFound. A non-forcing `-ImportModule { param($Path) Import-Module -Name $Path -ErrorAction Stop }` keeps it. A no-op seam fails when the module is only imported inside another module.

**Why:** the planner raised this as an open concern; the probe took about five runs. A string like `"x:$Tag:$y"` in the probe parses `$Tag:` as a drive variable (see [[powershell-traps-that-cost-rounds]]), and `@(Get-DocsAnalyzerRegistration | Where-Object ...)` pipes the comma-wrapped array as one object.

**How to apply:** for any plan whose new module calls `Invoke-DocsAnalyzer` with its own rows, require the non-forcing seam in suites that import the module themselves.

2. `.github/workflows/_quality-checks.yml` runs 3.11-3.13 only since commit "run 3.11-3.13 and measure coverage on 3.13 only" (2026-10-31); `pyproject.toml` requires >=3.11. Specs written earlier (1031 S10/S22) still name a 3.10 job.

**How to apply:** in preflight, grep the spec, user story and plan for `3.10` and compare with the workflow matrix; an AC naming a missing job is a substantive defect, since an executor cannot edit AC text.
