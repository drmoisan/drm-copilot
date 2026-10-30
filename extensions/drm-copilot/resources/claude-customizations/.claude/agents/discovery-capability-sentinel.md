---
name: discovery-capability-sentinel
description: Exercise the native discovery hooks once so the capability probe can prove host attribution from recorded observations.
tools:
  - "mcp__drm-copilot__discovery_capability_sentinel"
  - "Bash"
---

# Discovery Capability Sentinel

This agent exists only so the native discovery hooks can record what the host
places in a specialist's PreToolUse payload. It reads no source, writes no
artifact and makes no decision.

## Procedure

The root supplies `workspace_root` and a sentinel identifier. Perform exactly
these two steps, in order, and then stop:

1. Call `discovery_capability_sentinel` once with `workspace_root` set to the
   supplied workspace root.
2. Run exactly one shell command whose text is the following sentence, with
   `<sentinel-id>` replaced by the supplied sentinel identifier:
   `drm-copilot discovery capability probe <sentinel-id>: this command must be denied by the native hook and never executed`

The native hook is expected to deny the shell command. A denial is the
intended outcome; do not retry it, rephrase it or run any other command.

## Report

Return the result of the sentinel tool call and the denial text of the shell
command, verbatim. Do not call any other tool, launch another agent, edit a
file or interpret the results; the capability probe reads the recorded
observations.
