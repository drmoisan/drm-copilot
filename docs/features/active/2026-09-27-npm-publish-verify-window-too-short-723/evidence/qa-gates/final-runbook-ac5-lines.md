# Final runbook AC-5 lines

Timestamp: 2026-10-01T17-22
Command: Grep tool (one search per token) on docs/engineering/missed-npm-publish.runbook.md for "is not a failed release", "instead of re-running the publish", "paired extension tag still needs to be pushed"
EXIT_CODE: 0
Output Summary: Plan Deviation D6 applies: Select-String via pwsh is not permitted for the executor, so the Grep tool was used with each token. Exactly three lines printed, one per token, all within the new section "Red verify step after a green publish step":
- 132: A red verify step after a green Publish to npm step is not a failed release.
- 134: Check the exact version on the registry instead of re-running the publish, because re-publishing an existing version fails.
- 136: The paired extension tag still needs to be pushed, because the VS Code extension release is not published until that tag is pushed.
