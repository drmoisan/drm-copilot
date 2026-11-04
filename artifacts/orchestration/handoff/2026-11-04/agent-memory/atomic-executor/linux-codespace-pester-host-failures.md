---
name: linux-codespace-pester-host-failures
description: On the Linux Codespace, full tests/scripts Pester runs fail pre-existingly (89 in shards, 409 single-process via a PATH leak) and the JUnit export breaks; prove pre-existence at the merge base before reporting
metadata:
  type: project
---

Observed 2026-11-03 (issue #1026 P9-T7, and again issue #1047 remediation cycle 1):

- `Invoke-PoshQCParallelTest` over `config/poshqc-scan.json` (8 shards): 89 failures in 17 suites under `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` (activate, HostBootstrap*, publish-sideloaded-extension, SideloadedExtensionPublish*, Test-DiscoveryHostCapability*, PoshQC.ScanConfig/ScanFolders/TestingCommands). Causes: no C: drive, backslash path expectations, Windows prompt strings. Identical at the merge base.
- Fresh single-process `Invoke-PoshQCTest -ScanFolders tests/scripts`: 409 failures. The extra ~320 come from `tests/scripts/dev-tools/run-actionlint.Tests.ps1` assigning `$env:PATH = '/existing'` outside its restoring AfterEach, so every later suite in the process (codex-hooks Describe blocks, Python-interpreter checks) cannot resolve `pwsh` or `python`. A pre-existing order dependence, not caused by the item.
- Both run shapes exit 255 because Pester's JUnit export fails on a 0x1B (ANSI escape) character in an activate.Tests.ps1 failure message; `pester-junit.xml` is left truncated (about 15 KB). The coverage XML is still written completely. Read counts from the console line `Tests Passed: N, Failed: N, ...`.

- Plans tend to name a `HOST_FAILURE_SUITES` set taken from the shard run only (the 17 suites). A single-process acceptance against that set always fails on the 8 PATH-leak victims (Resolve-CodexRouting.Parity, codex-bundle-hook-probe, codex-pretooluse-integration/-transport, epic-execution-gates, legacy-codex-hook-contracts, codex-detached-head-transport, enforce-parallel-drift-gate-helpers); they pass 356/356 together without run-actionlint. Flag this at preflight when a plan's single-process acceptance uses the shard-derived set (seen again in issue #1026 remediation cycle 1).
- Issue #1066 (2026-11-03): a plan that measured the run-actionlint PATH victims over the 37 `tests/scripts/dev-tools` suites alone found an empty victim set (forward and TARGET-excluded runs both failed the same 94 keys) and stopped at P0-T6. The victims are only outside dev-tools (105 keys in the 8 suites above). The 8 suites also have their own order dependence (Parity fails 73 keys after codex-hooks without TARGET), and testcase names are unexpanded when a BeforeAll fails, so name-set keys shift. Flag a dev-tools-only victim scope at preflight.
- 2026-11-04 (issue #1080 preflight): a plain Invoke-Pester single-process run of `tests/scripts/dev-tools` (coverage and JUnit off) at merge base d80558cf7 gave 722 tests, 0 failed, forward and with Fisher-Yates seeds 1080 and 2026, so the dev-tools host-failure set may be gone; re-measure rather than assume 94 keys.
- Byte-identity tests (Codex epic-scope, legacy-codex-hook-contracts) fail when a plan runs suites before its bundle-mirror task; copying the mirror early as a micro-action was needed.

**Why:** a plan acceptance of "zero failures" for a full-scan Pester run cannot be met on this host. CI runs those suites on `windows-latest` shards.

**How to apply:** compare the sorted `[-] ...` failure lines (durations stripped) with a pre-edit baseline run at the branch head, and run the failing suites in the merge-base checkout with `-TestResultPath` under SCRATCH and coverage off; identical failed-case sets prove pre-existence. Leave the zero-failure task unchecked and report it as a host deviation. Do not fix unrelated fixtures inside the item. Scoped runs (claude-hooks, codex-hooks, claude-runtime, claude-lib) pass on Linux.
