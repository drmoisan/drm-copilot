# Phase 0 — Policy Instructions Read (Issue #298)

Timestamp: 2026-07-03T21-30

Policy Order:
1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/powershell-code-change.instructions.md`
5. `.github/instructions/powershell-unit-test.instructions.md`

Files Read (in the order above):
- `c:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-11-04\.github\copilot-instructions.md`
- `c:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-11-04\.github\instructions\general-code-change.instructions.md`
- `c:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-11-04\.github\instructions\general-unit-test.instructions.md`
- `c:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-11-04\.github\instructions\powershell-code-change.instructions.md`
- `c:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-11-04\.github\instructions\powershell-unit-test.instructions.md`

Summary: All five policy files were read in full prior to any code or test change. Key applicable requirements: run the PoshQC toolchain (format -> analyze -> Pester test) via the approved MCP server functions in order, restart the loop from formatting on any failure or auto-fix, add a failing regression test before the fix (bugfix workflow), keep the fix minimal and scoped to `$Output`'s `[AllowEmptyCollection()]` attribute, and do not modify any other function signature.
