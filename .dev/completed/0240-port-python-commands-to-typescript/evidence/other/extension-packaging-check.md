# P4-T4 — Extension package.json Packaging Check (F11)

Timestamp: 2026-06-26T09-01

## Findings

- `extensions/drm-copilot/package.json` has NO `files` field (`rg -n '"files"' ...` → no match). VSIX bundling is governed by `.vscodeignore`, which now defensively excludes `**/*.py` and `resources/scripts/**`.
- NO `.py` reference appears anywhere in `package.json` (`rg -n '\.py' ...` → no match): no script command, activation event, or contribution references a Python file.
- The `drmCopilotExtension.helloPython` command contribution is RETAINED per the helloPython in-process port decision.

## Relevant excerpt (commands contribution)

```json
"commands": [
  {
    "command": "drmCopilotExtension.helloPython",
    "title": "drm-copilot: Hello Python"
  },
  {
    "command": "drmCopilotExtension.helloPowerShell",
    "title": "drm-copilot: Hello PowerShell"
  },
  ...
]
```

## Statement

The extension `package.json` ships no Python and references no Python at runtime. No `files`-based change was required. The helloPython command contribution is preserved; its implementation now runs in-process via `src/lib/hello-message.ts` (Phase 1). Combined with the Phase 4 deletion of all bundled `.py` files and the `.vscodeignore` `**/*.py` / `resources/scripts/**` exclusions, the packaged extension contains no Python.
