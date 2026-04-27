Timestamp: 2026-04-26T19-20
Command: document-extension-split-boundary
EXIT_CODE: 0
Output Summary: Identified the repo-automation interactive command-registration block in extension.ts as the extraction boundary.
Boundary Notes:
- Keep activate() as the lifecycle entry point that creates the output channel, repo automation service, and final subscription list.
- Extract the interactive command-registration block that currently defines collect PR context, codex-native converter launch, PoshQC suite launch, potential entry/bug entry promotion, parent-child linking, potential-to-issue, and new active feature folder commands.
- Preserve command IDs, prompts, and service calls exactly; the new module should only register disposables and return them to activate().
