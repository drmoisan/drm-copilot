<!-- harness-section: head -->

# PowerShell Code Standards

This rule file summarizes the PowerShell-specific policies for this repository.

<!-- harness-section: toolchain -->
## Toolchain

1. **Formatting — Invoke-Formatter**: Format all PowerShell files via PoshQC. MCP command: `mcp__drm-copilot__run_poshqc_format`
2. **Linting — PSScriptAnalyzer**: Run PoshQC analyzer with repo settings. MCP command: `mcp__drm-copilot__run_poshqc_analyze`. Optional autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`
3. **Type checking**: Not applicable for PowerShell; skip to testing.
4. **Testing — Pester (v6.x)**: Run tests via MCP. MCP command: `mcp__drm-copilot__run_poshqc_test`. Use repo config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or changes files. Use the MCP server functions; do not substitute VS Code task wrappers. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

<!-- harness-section: compatibility -->
## Compatibility

- All scripts must be compatible with **PowerShell 7+** (enforced via PSScriptAnalyzer settings).

<!-- harness-section: coding-standards -->
## Coding Standards

- Prefer **advanced functions** with `CmdletBinding()` and named parameters.
- Add `[Parameter(Mandatory = $true)]` and validation attributes where appropriate.
- Implement **ShouldProcess/SupportsShouldProcess** for state-changing actions.
- Avoid global state and mutable script-scoped variables; pass data explicitly.
- Avoid `Invoke-Expression`, plaintext secrets, and hard-coded credentials/paths.
- Use `Write-Error`/`throw` for failures; avoid silent catch-alls.
- Use approved verbs and descriptive nouns for function names (PSScriptAnalyzer enforces this).
- Keep scripts cohesive and within the tiered file-size policy in `.claude/rules/general-code-change.md` (`## File Size Limit`).

<!-- harness-section: change-budget -->
## Change Budget

- Direct-mode scope: 1-3 production PowerShell files (plus corresponding tests). A change that touches more than 3 production PowerShell files belongs on the orchestrated large path: route it through `/orchestrate` (the `orchestrator` agent) per `powershell-change-budget-router`.
- The orchestrated large path has no production-file cap. Test files are not counted toward the routing threshold.
- `.claude/hooks/enforce-powershell-batch-budget.ps1` enforces the threshold outside the large path: it denies the 4th distinct production PowerShell file with a routing instruction.

<!-- harness-section: design-seams-minimal-di -->
## Design Seams (Minimal DI)

Introduce the smallest seam that enables reliable mocking. Apply these options in order:

1. **Wrapper function seam (preferred)** — extract external executable calls into a wrapper function:
   - Signature: `Invoke-<Tool>Exe -<Tool>Args <string[]>` (for example `Invoke-GitExe -GitArgs <string[]>`).
   - The wrapper accepts a single array parameter and splats into the executable: `git @GitArgs 2>&1`.
   - Parameter names must not be `Args` (automatic variable collision). Use `GitArgs`, `ToolArgs`, or `Arguments`.
2. **Injectable delegate / ScriptBlock seam** — only when a wrapper is insufficient, add a narrowly-scoped optional delegate or `ScriptBlock` parameter with a safe default. Do not introduce generic runner frameworks.
3. **Adapter seams for non-executable boundaries** — for filesystem, environment, or clock dependencies, introduce tiny helpers or narrow injectable parameters rather than threading raw I/O through domain logic.

<!-- harness-section: testing-standards -->
## Testing Standards

- Use **Pester** (v6.x) as the test framework.
- Organize tests to mirror code structure (e.g., `tests/scripts/dev-tools/ScriptName.Tests.ps1`).
- Name test files `*.Tests.ps1`.
- Use `Describe`/`Context`/`It` blocks; one behavior per `It`.
- Write focused tests exercising a single function or behavior.
- Mock sparingly; prefer real code paths.
- No external dependencies in unit tests.
- Line coverage must remain >= 85% across all tiers (T1–T4) per `.claude/rules/quality-tiers.md`.
- Pester reports **command (instruction) coverage and line coverage only**. The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by Pester for PowerShell; there is no PowerShell branch-coverage gate. This removes an unevaluable threshold, not a measurement obligation: PowerShell production files remain in the coverage denominator per the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, and command coverage is reported for information only, with no threshold attached.
- Coverage regression on changed lines is a blocking finding.

### Deterministic Test Requirements

Tests must not depend on:

- network access,
- mutable machine PATH or profile state,
- implicit working-directory assumptions,
- external services or live executables.

Tests must produce identical results in Terminal and the VS Code Test Explorer. Assume a different PATH, current working directory, profile, and host when tests are run from Test Explorer; do not rely on ambient environment resolution.

### Mocking Rules

1. **External executable mocking** — never mock `git`, `gh`, `actionlint`, or other executables directly. Mock the wrapper function (for example `Invoke-GitExe`) instead.
2. **Mock signature parity** — mock signatures must match production named parameters exactly. Example:
   - production: `Invoke-GitExe -GitArgs $gitArgs`
   - test mock: `param([string[]]$GitArgs)`
3. **Mock registration order** — register mocks before the code under test can resolve commands, so Test Explorer parity is preserved.
4. **AST/ScriptBlock import order** — when importing script functions via AST or `ScriptBlock` patterns:
   - dot-source the returned `ScriptBlock` in the test scope,
   - import dependencies in the correct order,
   - import wrapper seams before mocking them when executable calls exist.

<!-- harness-section: prohibited-behaviors -->
## Prohibited Behaviors

- Broad refactors across unrelated scripts or modules.
- Introducing generic process-runner frameworks to replace the wrapper seam pattern.
- Creating PSScriptAnalyzer debt and deferring cleanup.
- Weakening assertions merely to make tests pass.
- Adding sleeps, retries, or timing hacks to stabilize flaky tests.
- Claiming success without running the required toolchain.
<!-- harness-section: head-2 -->
# PowerShell Code Change Policy

This policy **extends** `general-code-change.instructions.md` and applies to all PowerShell source, scripts, and modules (`*.ps1`, `*.psm1`) in this repo.

You must:

- Apply **all** rules in the general code change policy.
- Apply **all** PowerShell-specific rules in this file.
- Apply the unit test policies (`general-unit-test.instructions.md` and `powershell-unit-test.instructions.md`) for any PowerShell tests.

If you encounter any conflicting instructions, **halt and notify the user.**

---

<!-- harness-section: 1-tooling-baseline-for-powershell -->
## 1. Tooling & Baseline for PowerShell

**Agent execution requirement (explicit):**

- Agents must use the MCP server functions: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp_drmcopilotext_run_poshqc_test`, and `mcp__drm-copilot__run_poshqc_analyze_autofix`.
- Agents must **not** use VS Code task wrappers as a substitute.

1) **Formatting - Invoke-Formatter**

- Format all PowerShell files using the PoshQC formatter (Invoke-Formatter).
- **Agent execution:** `mcp__drm-copilot__run_poshqc_format`
- Do not hand-format; re-run the formatter whenever PSScriptAnalyzer would change whitespace/indentation.

2) **Linting - PSScriptAnalyzer**

- Run the PoshQC analyzer (PSScriptAnalyzer) with repo settings.
- **Agent execution:** `mcp__drm-copilot__run_poshqc_analyze`
- Optional autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`; review diffs after running.
- Fix **all** findings (Error/Warning/Information). No rule suppressions unless strictly necessary and localized with a comment.

3) **Compatibility**

- Keep scripts compatible with **PowerShell 7+** (enforced via PSScriptAnalyzer settings).

> Testing tools are defined in the PowerShell unit test policy; do not redefine them here.

---

<!-- harness-section: 2-powershell-design-safety -->
## 2. PowerShell Design & Safety

- Prefer **advanced functions** with `CmdletBinding()` and named parameters over ad-hoc script blocks.
- Add `[Parameter(Mandatory = $true)]` and validation attributes where appropriate; avoid positional parameters for user-facing scripts.
- For any state-changing action, implement **ShouldProcess/SupportsShouldProcess** and gate destructive behavior with `$PSCmdlet.ShouldProcess(...)`.
- Avoid global state and mutable script-scoped variables unless required; pass data explicitly.
- Avoid `Invoke-Expression`, plaintext secrets, and hard-coded credentials/paths. Use secure defaults.
- Use `Write-Error`/`throw` for failures; avoid silent catch-alls. Bubble errors unless you can add actionable context.

---

<!-- harness-section: 3-structure-naming-and-comments -->
## 3. Structure, Naming, and Comments

- Keep scripts **cohesive** and within the tiered file-size policy of `general-code-change.instructions.md` (section 4, Module & File Structure).
- Use approved verbs and descriptive nouns for functions (PSScriptAnalyzer will enforce).
- Prefer modules/helpers over copy-paste between scripts; share common logic in dedicated helper functions.
- Comment **why** for non-obvious patterns (e.g., rule suppressions, compatibility shims), not what.

---

<!-- harness-section: 4-running-the-toolchain-powershell -->
## 4. Running the Toolchain (PowerShell)

When PowerShell code changes, your toolchain loop must include:

1. Format: `mcp__drm-copilot__run_poshqc_format`
2. Analyze: `mcp__drm-copilot__run_poshqc_analyze`
3. (Type checking is not applicable for PowerShell; skip to testing.)
4. Test: `mcp_drmcopilotext_run_poshqc_test`

The MCP server functions above are the approved toolchain contract for agents.

Rerun the loop from step 1 if any step changes code or fails.

> Install prerequisites once with `pwsh -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Install-PoshQCTools"` (installs PSScriptAnalyzer + Pester to CurrentUser).
<!-- harness-section: head-3 -->
# PowerShell Unit Test Policy

This policy **extends** `general-unit-test.instructions.md` and applies to all PowerShell tests in this repo.

You must follow **both**:

- The general unit test policy, and
- The PowerShell-specific rules below.

If there is any conflict between these documents, halt and notify the user.

---

<!-- harness-section: 1-framework-and-scope -->
## 1. Framework and Scope

- **Testing framework:** All PowerShell tests must use **Pester** (v6.x).
- Use the repo config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- **Agent execution requirement:** use the MCP server function `mcp_drmcopilotext_run_poshqc_test`. Do **not** use VS Code task wrappers as a substitute.
- Keep tests compatible with PowerShell 7+.

---

<!-- harness-section: 2-test-style-and-structure-powershell -->
## 2. Test Style and Structure (PowerShell)

- **Focused unit tests**

  - Write focused tests that exercise a single function, method, or behavior.
  - Prefer testing behavior directly over testing implementation details.

- **Mocking**

  - Use mocking sparingly. Prefer real code paths and pure functions where possible.
  - Only introduce mocks/stubs when needed to satisfy isolation, determinism and “avoid external dependencies” requirements (e.g., external services, heavy resources).

- **Organization**

  - Organize tests into folders in a way that mirrors the code under test (e.g., `tests/scripts/dev-tools/ScriptName.Tests.ps1` for `scripts/dev-tools/ScriptName.ps1`).

---

<!-- harness-section: 3-naming-and-readability-python -->
## 3. Naming and Readability (Python)

- **Naming conventions**

  - Name test files `*.Tests.ps1`.
  - Organize tests with `Describe`/`Context`/`It`. One behavior per `It`.
  - Group related tests logically within the same file or test class.

- **Docstrings and comments**

  - Where the intent is not obvious from the `Describe`/`Context`/`It` alone, include a short docstring or comment summarizing:
    - The scenario being tested.
    - The expected outcome.

---

<!-- harness-section: 4-running-the-toolchain-powershell-tests -->
## 4. Running the Toolchain (PowerShell Tests)

- When running the "After Making Changes" toolchain, the **testing step** for PowerShell must use:
  - MCP server function: `mcp_drmcopilotext_run_poshqc_test`
- Agents must use the MCP server function. VS Code task wrappers are not an approved substitute.
- Do **not** substitute other test runners for PowerShell work without explicit approval.

This file defines **how** PowerShell tests are written and executed; the general code change policy defines **when** to run the toolchain and how strictly to enforce it.
<!-- harness-section: coding-standards-2 -->
## Coding Standards

- Prefer **advanced functions** with `CmdletBinding()` and named parameters.
- Add `[Parameter(Mandatory = $true)]` and validation attributes where appropriate.
- Implement **ShouldProcess/SupportsShouldProcess** for state-changing actions.
- Avoid global state and mutable script-scoped variables; pass data explicitly.
- Avoid `Invoke-Expression`, plaintext secrets, and hard-coded credentials/paths.
- Use `Write-Error`/`throw` for failures; avoid silent catch-alls.
- Use approved verbs and descriptive nouns for function names (PSScriptAnalyzer enforces this).
- Keep scripts cohesive and within the tiered file-size policy in `.agents/skills/general-code-change/SKILL.md` (`## File Size Limit`).

<!-- harness-section: change-budget-2 -->
## Change Budget

- Direct-mode overall scope: up to 2 production PowerShell files (plus corresponding tests). Requests exceeding this must be routed to `powershell-orchestrator` per `powershell-change-budget-router`.
- The orchestrated large path has no production-file cap, and test files are not counted toward the routing threshold.

<!-- harness-section: testing-standards-2 -->
## Testing Standards

- Use **Pester** (v6.x) as the test framework.
- Organize tests to mirror code structure (e.g., `tests/scripts/dev-tools/ScriptName.Tests.ps1`).
- Name test files `*.Tests.ps1`.
- Use `Describe`/`Context`/`It` blocks; one behavior per `It`.
- Write focused tests exercising a single function or behavior.
- Mock sparingly; prefer real code paths.
- No external dependencies in unit tests.
- Repository-wide line coverage must remain >= 80%.
- Any new module, class, or method must reach >= 90% coverage.
- Coverage regression on changed lines is a blocking finding.

### Deterministic Test Requirements

Tests must not depend on:

- network access,
- mutable machine PATH or profile state,
- implicit working-directory assumptions,
- external services or live executables.

Tests must produce identical results in Terminal and the VS Code Test Explorer. Assume a different PATH, current working directory, profile, and host when tests are run from Test Explorer; do not rely on ambient environment resolution.

### Mocking Rules

1. **External executable mocking** — never mock `git`, `gh`, `actionlint`, or other executables directly. Mock the wrapper function (for example `Invoke-GitExe`) instead.
2. **Mock signature parity** — mock signatures must match production named parameters exactly. Example:
   - production: `Invoke-GitExe -GitArgs $gitArgs`
   - test mock: `param([string[]]$GitArgs)`
3. **Mock registration order** — register mocks before the code under test can resolve commands, so Test Explorer parity is preserved.
4. **AST/ScriptBlock import order** — when importing script functions via AST or `ScriptBlock` patterns:
   - dot-source the returned `ScriptBlock` in the test scope,
   - import dependencies in the correct order,
   - import wrapper seams before mocking them when executable calls exist.

