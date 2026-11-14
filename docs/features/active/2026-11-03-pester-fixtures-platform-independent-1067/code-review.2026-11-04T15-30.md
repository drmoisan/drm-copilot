# Code Review: Platform-independent Pester fixtures (#1067)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067`
**Feature Folder Selection Rule:** Caller-supplied folder; its suffix matches issue 1067 and it holds the primary changed scoping documents.
**Base Branch:** `main` (merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049)
**Head Branch:** `bug/pester-fixtures-platform-independent` at 089e55e5c331889cb98066b436b2416e478d62ed
**Review Type:** Initial review

---

## Executive Summary

The branch makes 17 Pester suites under `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` host-independent and fixes four production defects that the Linux failures exposed. The reviewer inspected the full diff of the 5 production files and 17 suites, reran PSScriptAnalyzer and the formatter (0 findings, 0 differences), reran the two test trees at HEAD (953 tests, 0 failed), and parsed the merged coverage artifact. The production edits are small and targeted; the test edits keep every expectation exact and build it from the same `Join-Path` root as the input.

**What changed:**
- D1 `scripts/dev-tools/activate.ps1` `Get-RepoRelativePrompt`: descendant test uses `[System.IO.Path]::DirectorySeparatorChar` instead of a literal `\`.
- D2 `scripts/dev-tools/HostBootstrapWorkspace.psm1` `Resolve-WorkspaceRoot`, `Resolve-ProjectRepoRoot`, and D3 `scripts/dev-tools/DrmCopilotPromptSupport.ps1` `Get-DrmCopilotNormalizedPath`, `Resolve-DrmCopilotActivationScriptPath`: relative input is resolved with `GetFullPath(Combine($PWD.ProviderPath, ...))`, so it follows the PowerShell location rather than the process directory.
- D4 `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` `Get-PoshQCScanConfigFolder` (and its byte-identical bundle mirror): absolute `scanFolders` entries are rejected by `^(?:[A-Za-z]:|[\\/])` on every host instead of the host-dependent `[IO.Path]::IsPathRooted`.
- 17 suites: per-suite portable root `Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) '<suite>-root'`; real `New-Item` writes replaced by module-scope mocks; three suites restore leaked process-wide state.

**Top 3 risks:**
1. Windows behavior is verified only by the S9 CI gate on `windows-latest` (AC2); the Linux runs cannot exercise drive-letter paths.
2. Without a Linux CI leg for these two trees (open owner decision in spec.md), a new Windows-only fixture can reappear unnoticed.
3. Two out-of-diff suites still leak `$env:POSHQC_SKIP_SCRIPT_EXECUTION` (see Findings); they did not cause failures in any recorded run.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; all local gates pass at the reviewed head, and the remaining Windows verification is owned by S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/dev-tools/link-feature-docs.Tests.ps1`, `tests/scripts/dev-tools/link-parent-child.Tests.ps1` | suite setup (not in branch diff) | Both suites set `$env:POSHQC_SKIP_SCRIPT_EXECUTION` without restoring it; the executor's probe read value 1 after the two-tree and `tests/scripts` runs. This is the same leak class that this branch fixes in `sync-agents-from-instructions.Tests.ps1`. | Apply the same save-in-`BeforeAll` / restore-in-`AfterAll` pattern to both suites, either in a remediation cycle of this item or in a follow-up, at the orchestrator's discretion. | Leaked environment state can create order dependence in single-process runs; no failure is attributable to it in the recorded seeded, fresh, or concurrent runs. | evidence/qa-gates/self-review.2026-11-04T15-18.md (out-of-scope finding row); SHUF/FRESH/PAR evidence all 0 failures. |
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | default `-InvokePester` trampoline comment (not in branch diff) | The comment states the Pester run is hosted in the global session state; the executor observed test code running in the PoshQC module session state under a PoshQC-hosted run, so `Mock -ModuleName PoshQC` from test code does not reach the re-imported instance. The two affected in-scope tests now use `InModuleScope PoshQC`. | Correct the comment, or change the trampoline to invoke in the global session state, in a separate item (it adds a production file and its bundle mirror). | Other suites that rely on `Mock -ModuleName PoshQC` under a PoshQC-hosted run can miss their mock and touch the real file system. | evidence/other/execution-deviations.2026-11-04T13-58.md, "Second restart". |
| Info | `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1` | D2/D3 `Combine($PWD.ProviderPath, ...)` call sites | When the current location is a non-FileSystem provider (for example `Env:` or `HKCU:`), `$PWD.ProviderPath` is not a file-system path, so a relative argument would resolve against provider text. Absolute arguments are unaffected (`Combine` returns a rooted second argument unchanged). | No change required for this item; the spec records the FileSystem-location assumption, which the PoshQC modules already rely on for the same idiom. | Edge case limited to relative input entered from a non-FileSystem location. | spec.md `## Assumptions, Constraints, Dependencies`; diff inspection. |
| Nit | `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`, `tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1` | `[scriptblock]::Create("'$docsPath'")`, `[scriptblock]::Create("...StartsWith('$noProbeRoot', ...)")` | Fixture paths are interpolated into script-block source inside single quotes; a path containing `'` would break the block. | Acceptable as written because every root is a fixed literal joined to the volume root; if the roots ever become input-derived, escape with `[System.Management.Automation.Language.CodeGeneration]::EscapeSingleQuotedStringContent`. | Robustness of test code only. | Diff inspection. |

No Blocker, Major, or Minor findings. No changed covered file reaches the 700-line advisory tier (largest: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`, 529 logical lines); `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Each production fix is the minimum expression change at the call site that receives caller input; Windows output is unchanged for absolute input and for relative input whenever the process directory equals the location.
- D2 uses `$PWD.ProviderPath` rather than `Get-Location`, which avoids a StrictMode property failure against the suites' existing `Get-Location` mock (rationale stated in spec.md).
- D4 keeps the existing error message, so the `*config/poshqc-scan.json*absolute*` expectation stays valid, and the mirror is byte-identical (`cmp` exit 0; mirror contract tests 24 passed).
- Comments explain why, not what (process directory versus PowerShell location; .NET rooted-path semantics by host).

#### API and safety notes

- No parameter, output type, or exported function changed.
- On Linux, D4 now rejects `C:/x` and `\x` entries that were previously accepted; `config/poshqc-scan.json` contains no such entry (spec.md Backward-compatibility).
- PSScriptAnalyzer with the repository settings: 0 findings over all 22 changed files.

#### Error handling and logging

- No new error paths; existing `throw` messages unchanged.

---

## Test Quality Audit

The reviewer reran Pester over both in-scope trees at HEAD with coverage off: Tests=953 Passed=944 Failed=0 Skipped=9, and `git status --porcelain --untracked-files=all` was empty afterwards, which confirms that no test wrote to the worktree. The count includes main's `HostBootstrap.Versions.Tests.ps1` and the main-side additions to `HostBootstrap.Invoke.Tests.ps1` that arrived with the final merge; they pass on Linux.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` — D2 relative-path tests separate the location from the process directory and restore both in `finally`; expectations exact.
- `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` — D3 contexts, personal user-profile path removed, prompt restored through `Function:\global:prompt`, support functions removed in `AfterAll`.
- `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1` — D4 POSIX-rooted and backslash-rooted rejection cases added; drive-qualified case retained.
- `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, `PoshQC.TestingCommands.Tests.ps1` — `New-Item` mocked inside `InModuleScope PoshQC` with `Should -Invoke ... -Times 1 -Exactly` and the expected directory filter.
- `evidence/regression-testing/fail-before-d1..d4`, `pass-after-d1..d4` — each regression test fails before its fix and passes after.
- `evidence/regression-testing/isolation-shuffle.2026-11-04T14-48.md`, `isolation-fresh-tests-scripts.2026-11-04T15-06.md`, `isolation-parallel.2026-11-04T15-15.md` — seeded, fresh, and concurrent-shard runs with 0 failures in the touched suites.

### Quality assessment prompts

- **Determinism:** No temporary files, TestDrive, wall-clock, or random input; roots are fixed and never created.
- **Isolation:** Process-wide state changed by a test is restored in `finally` or `AfterAll`/`AfterEach`.
- **Speed:** No added file-system access; the two-tree run completes in minutes.
- **Diagnostics:** Exact `Should -BeExactly` expectations name the expected path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; the personal user-profile path was removed (prohibited-constructs evidence: 0 matches). |
| No unsafe subprocess or command construction | PASS | No subprocess change in production code. |
| Input validation at boundaries | PASS | D4 validation is host-independent and stricter on Linux. |
| Error handling remains explicit | PASS | Existing throws unchanged. |
| Configuration / path handling is safe | PASS | Relative paths resolve against the PowerShell location; see the Info finding on non-FileSystem locations. |

---

## Research Log

No external research was required. The research record `research/research.2026-11-03T22-55.md` was consulted for the failure-to-cause mapping.

---

## Verdict

The change is ready for normal PR flow. No Blocker, Major, or Minor finding exists; the Info and Nit items are outside the branch diff or are advisory. The S9 CI green gate must confirm the `poshqc / PowerShell QC` check and its `windows-latest` shards on the final PR head (AC2).
