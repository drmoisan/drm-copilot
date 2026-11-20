<!-- markdownlint-disable-file -->

# Task Research Notes: bundle-poshqc-suite-into-extension

## Research Executed

### File Analysis

- `extensions/drm-copilot/src/repo-automation-service.ts`
  - The shared extension service is the canonical place to add a new bundled workflow for both VS Code and MCP surfaces.
- `extensions/drm-copilot/src/extension.ts`
  - Existing command handlers either run interactively or accept direct flag-driven invocation through the shared workflow-argument helpers.
- `extensions/drm-copilot/src/mcp-tools.ts`
  - MCP exposure is defined centrally and mirrors the repo-automation service contract.
- `extensions/drm-copilot/resources/templates/`
  - Current bundled workflows execute from template resources; there is no PoshQC runner today.
- `scripts/powershell/PoshQC/PoshQC.psm1`
  - The repo-root PoshQC module already encapsulates formatting, analysis, testing, coverage conversion, and dependency installation.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  - PoshQC testing is workspace-root oriented today, while folder selection is most naturally applicable to file-discovery operations.
- `tests/scripts/powershell/PoshQC/*.Tests.ps1`
  - Existing Pester coverage provides a natural seam for adding explicit include-folder behavior to file discovery.
- `extensions/drm-copilot/test/*.ts`
  - Existing Jest suites already cover command registration, service argv forwarding, integration-path execution, and MCP tool registration.

### Key Discoveries

- The implementation is a mixed-language large-path feature:
  - TypeScript command/service/MCP surfaces.
  - Root PowerShell module behavior.
  - Bundled PowerShell assets.
  - TypeScript and Pester tests.
- The extension runtime model already fits the need:
  - resolve bundled script path from the installed extension,
  - run it with explicit argv,
  - use the destination workspace as `cwd`.
- Folder selection should be modeled as an additive input:
  - whole workspace when omitted,
  - explicit folder list when provided,
  - validation must fail fast when a selected path is outside the destination workspace.
- Bundled/root drift is a real risk:
  - the repo already carries mirrored PowerShell and Python assets for other workflows,
  - parity tests are required to keep that duplication safe.

## Recommended Approach

1. Add a repo-root `scripts/dev-tools/run-poshqc-suite.ps1` entrypoint.
2. Bundle an identical `extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1` wrapper.
3. Bundle the PoshQC module and settings under `extensions/drm-copilot/resources/powershell/PoshQC/`.
4. Extend the root PoshQC module so format/analyze file discovery can be narrowed to explicit folder selections.
5. Add a new `drmCopilotExtension.runPoshQCSuite` command and `run_poshqc_suite` MCP tool.
6. Cover the new behavior with Pester parity/file-discovery tests plus Jest command/service/MCP tests.
