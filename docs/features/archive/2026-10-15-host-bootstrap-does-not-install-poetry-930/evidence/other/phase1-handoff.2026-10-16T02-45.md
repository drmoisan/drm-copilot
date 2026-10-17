# Phase 1 handoff to the small-path implementation engineer (P1-T1)

Timestamp: 2026-10-16T02-45

Permitted write set:
- `scripts/dev-tools/HostBootstrap.psm1`
- `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`
- files inside `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/`
- the AC check-offs in `issue.md`

Out of scope: `scripts/host-tools.manifest.json`, `HostBootstrap.Tests.ps1`, `HostBootstrapWorkspace.psm1`, and every other file.

PowerShell file rule: the only PowerShell files written are the module and the Invoke test file. The only files written under `SCRATCH/issue-930/` are `.sh` wrappers.

Ordering rule: no test, coverage, or MCP test run occurs between P1-T9 and P1-T10.

Acceptance: this artifact names the write set and the ordering rule.
Command: test -f scripts/dev-tools/HostBootstrap.psm1 && test -f tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 && grep -c -E '^(Permitted write set|Ordering rule):' docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/phase1-handoff.2026-10-16T02-45.md
EXIT_CODE: 0
Output Summary: Both write-set files exist on disk and the count of labelled lines (write set and ordering rule) in this artifact is 2.
Fields Added At: 2026-10-16T04-57
Note: No command was run when this artifact was first written; it recorded a handoff. The command shown above is the verifying command run when the missing fields were added. It confirms that the two named write-set source files exist and that the two labelled lines are present in this artifact.
