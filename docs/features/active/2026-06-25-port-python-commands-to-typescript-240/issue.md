# port-python-commands-to-typescript (Issue #240)

- Date captured: 2026-06-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/port-python-commands-to-typescript/ (Issue #240)
- Classification: Epic (multi-feature)

- Issue: #240
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/240
- Last Updated: 2026-06-26
- Work Mode: full-feature

## Problem / Why

Many extension command scripts and MCP server scripts are implemented in Python
(`scripts/dev_tools/**`, bundled at `extensions/drm-copilot/resources/scripts/dev_tools/**`
and `extensions/drm-copilot/resources/templates/**`). The VS Code extension and the
standalone MCP server (`packages/mcp-server`) shell out to these scripts through
`command-runtime.ts`, which probes for a `python` runtime on PATH. This makes a Python
interpreter a hard runtime dependency for end users of the extension and the published
MCP npm package.

Porting these scripts to TypeScript removes the Python runtime dependency, unifies the
toolchain on Node/TypeScript, and lets the extension and MCP server invoke logic
in-process rather than spawning an external interpreter.

Scope measured: ~28,100 LoC of production Python under `scripts/dev_tools/**`, ~1,155 LoC
of bundled templates, and ~39,750 LoC of Python tests.

## Proposed Behavior

Port every Python command script used by the extension and the MCP server to TypeScript,
preserving behavior exactly, with equally robust automated tests. After the port, neither
the extension nor the MCP server requires a Python interpreter to execute its commands.

## Acceptance Criteria (early draft)

- [ ] Every Python command script invoked by the extension or MCP server has a TypeScript
      equivalent with parity of behavior.
- [ ] Test coverage for the TypeScript ports is equal to or better than the Python tests
      (line >= 85%, branch >= 75% per repository policy).
- [ ] The extension and MCP server invoke the TypeScript implementations, not Python.
- [ ] No remaining runtime dependency on a `python` interpreter for command execution.
- [ ] All CI gates pass.

## Constraints & Risks

- Large surface area; must be decomposed into independently shippable features.
- Behavior parity must be preserved exactly, including CLI output, exit codes, and file
  artifacts.
- The bundled resources under `extensions/drm-copilot/resources/**` and the
  `packages/mcp-server/resources/**` copy must remain consistent.
- Cross-cutting MCP tool handlers and `command-runtime.ts` runtime selection must be
  updated without breaking existing TypeScript tests.

## Test Conditions to Consider

- [ ] Unit coverage for each ported module
- [ ] Behavior-parity tests against the original Python outputs
- [ ] MCP handler integration scenarios
- [ ] CLI/API examples for each command

## Next Step

- [ ] Promote to GitHub issue (epic)
- [ ] Create epic feature folder from the template
- [ ] Decompose into per-cluster features and execute one by one