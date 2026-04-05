# fix-sync-agents-bundling (Issue #120)

- Date captured: 2026-04-05
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/fix-sync-agents-bundling/ (Issue #120)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #120
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/120
- Last Updated: 2026-04-05
- Work Mode: full-bug

## Summary

The bundled `drmCopilotExtension.syncAgentsFromInstructions` command crashes when the destination workspace does not have `.github/copilot-instructions.md`. The script should treat the preamble file as optional so it can generate `AGENTS.md` from whatever instruction files exist. Additionally, the generated output embeds each instruction file verbatim without compaction, producing repetitive content that is not optimized for agent consumption.

## Environment

- OS/version: Windows 11 / VS Code Insiders
- Extension: drm-copilot 0.0.1
- Command/flags used: `drmCopilotExtension.syncAgentsFromInstructions` via VS Code command palette
- Destination workspace: `open-claw-bridge` (lacks `.github/copilot-instructions.md`)

## Steps to Reproduce

1. Open a workspace that has `.github/instructions/*.instructions.md` files but lacks `.github/copilot-instructions.md`.
2. Run `drm-copilot: Sync AGENTS.md from Instructions` from the command palette.
3. Observe the command fails with: `Required AGENTS preamble file not found: .github/copilot-instructions.md`.

## Expected Behavior

The command should generate `AGENTS.md` from the discovered instruction files and optionally include the preamble if it exists. The output should be compacted for high-signal, non-repetitive agent content.

## Actual Behavior

The command throws a hard error and produces no output when `.github/copilot-instructions.md` is missing.

Error log:
```
[drmCopilotExtension.syncAgentsFromInstructions] command failure
Exception: Required AGENTS preamble file not found: c:/Users/DanMoisan/repos/open-claw-bridge/.github/copilot-instructions.md
```

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: See Actual Behavior section above.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- `Get-DiscoveredInstructionFile` in `sync-agents-from-instructions.ps1` hard-requires `.github/copilot-instructions.md` and throws if missing.
- `Get-AgentContent` calls `Get-InstructionsBody` on the preamble without checking existence first.
- The bundled template at `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` mirrors the root script exactly, so both carry the same defect.
- No compaction or deduplication logic exists in the current script; bodies are embedded verbatim.

## Proposed Fix / Validation Ideas

- [ ] Make `.github/copilot-instructions.md` preamble optional: skip preamble section when file is absent, still generate AGENTS.md from discovered instruction files.
- [ ] Add compaction logic to reduce repetitive content across instruction files for agent-optimized output.
- [ ] Update Pester tests for: missing preamble generates valid output, compaction produces non-repetitive content.
- [ ] Ensure bundled template mirror stays in sync with root script.
- [ ] Regenerate AGENTS.md in the source repo to validate output.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch