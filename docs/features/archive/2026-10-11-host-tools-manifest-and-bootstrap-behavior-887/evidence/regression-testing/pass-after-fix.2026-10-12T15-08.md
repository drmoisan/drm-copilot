# Pass-After-Fix Run (Issue 887)

Timestamp: 2026-10-12T14-45
Timestamp note: the filename timestamp 2026-10-12T15-08 was estimated rather than read from the system clock; 2026-10-12T14-45 is the file modification time recorded when the artifact was written.
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/host-tools.manifest.Tests.ps1", "tests/scripts/dev-tools/HostTooling.Tests.ps1", "tests/scripts/dev-tools/HostBootstrap.Tests.ps1", "tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1", "tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1", "tests/scripts/dev-tools/bootstrap-host.Tests.ps1", "tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1", "tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1"]
EXIT_CODE: 0
Phase: post-fix
Output Summary:
- MCP status: ok=true. Summary: "Ran bundled PoshQC test against '<worktree root>' with 8 selected scan folder(s)."
- Discovery check source: artifacts/pester/pester-junit.xml read with the Grep tool immediately after the passing run: testsuites tests="142" errors="0" failures="0" disabled="0"; no failure element.
- Each of the 35 IDs matches exactly one testcase element, with status="Passed" and no failure child:
  - AC05-MANIFEST-PATH-EXISTS: passed
  - AC10-STREAM-OUTHOST-RESETS-EXITCODE: passed
  - AC10-CAPTURE-RESETS-STALE-EXITCODE: passed
  - AC01-MANIFEST-TOP-LEVEL-KEYS: passed
  - AC02-MINIMUM-VERSIONS-PINNED: passed
  - AC03-POWERSHELL-MODULES-PINNED: passed
  - AC04-ENTRY-SHAPES: passed
  - AC06-CORE-VERSION-ZERO-FAILURES: passed
  - AC06-REQUIRED-COMMAND-ZERO-FAILURES: passed
  - AC06-OPTIONAL-COMMAND-ZERO-FAILURES: passed
  - AC06-POWERSHELL-MODULE-ZERO-FAILURES: passed
  - AC06-POETRY-TOOL-ZERO-FAILURES: passed
  - AC06-BOOTSTRAP-PRECONDITION-ERRORS: passed
  - AC07-DRYRUN-COMMITTED-MANIFEST: passed
  - AC08-APPLY-EMPTY-PROJECTS: passed
  - AC08-RESOLVE-EMPTY-PROJECTS: passed
  - AC11-GIT-STREAMS: passed
  - AC11-WINGET-STREAMS: passed
  - AC11-NPM-STREAMS: passed
  - AC11-NPM-NONZERO-NO-THROW: passed
  - AC11-WSL-STREAMS: passed
  - AC11-POETRY-STREAMS: passed
  - AC11-PYTHON-POETRY-STREAMS: passed
  - AC11-PIP-STREAMS: passed
  - AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS: passed
  - AC13-WHATIF-INHERITED: passed
  - AC13-CONFIRM-NONE: passed
  - AC13-CONFIRM-LOW: passed
  - AC13-VERBOSE-INHERITED: passed
  - AC13-DEBUG-INHERITED: passed
  - AC13-BOUND-DEBUG-INFO-PROGRESS: passed
  - AC13-WHATIF-BOUND-FALSE-WINS: passed
  - AC13-CONFIRM-HIGH: passed
  - AC13-DEFAULT-NO-WHATIF: passed
  - AC05-BOOTSTRAP-NONWINDOWS-EXIT1: passed
- Pre-fix counterparts (failing scans of the same files before the production edits):
  - evidence/regression-testing/expect-fail.HostTooling.2026-10-12T14-52.md
  - evidence/regression-testing/expect-fail.host-tools-manifest.2026-10-12T14-53.md
  - evidence/regression-testing/expect-fail.HostBootstrap-Invoke.2026-10-12T14-55.md
  - evidence/regression-testing/expect-fail.HostBootstrapWorkspace.2026-10-12T14-56.md
  - evidence/regression-testing/expect-fail.HostBootstrap.2026-10-12T14-57.md
  - evidence/regression-testing/expect-fail.publish-sideloaded-extension.2026-10-12T14-58.md
- Repair history for this task: the first run of this scan failed (MCP "Command exited with code 2"; JUnit tests="142" failures="2"):
  - AC13-CONFIRM-HIGH failed because a child-scope `Set-Variable -Name ConfirmPreference -Value 'High'` produces a string-valued preference, and `$ConfirmPreference -le 'Medium'` compared strings alphabetically and forwarded Confirm=$true. Repaired in scripts/dev-tools/publish-sideloaded-extension.ps1 by casting the inherited preference to [System.Management.Automation.ConfirmImpact] before the None and Medium comparisons.
  - AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS failed with "Expected like wildcard '*drm-copilot-*.vsix' to match x" because `$output = & { ...; @(...) }` unrolled a single-element array to a string, so `$output[-1]` returned its last character. Repaired in tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 by wrapping the outer call as `$output = @(& { ... })`; the assertions are unchanged.
  - The expect-fail artifacts were not edited. This artifact records the re-run that passed.
