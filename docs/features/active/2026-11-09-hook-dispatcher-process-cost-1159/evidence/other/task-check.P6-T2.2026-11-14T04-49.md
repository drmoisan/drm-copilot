# Task check [P6-T2]

Timestamp: 2026-11-14T04-49
Command: sh SCRATCH/issue-1159-taskcheck.sh "" tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
EXIT_CODE: 0
Output Summary: Pester 7 passed, 0 failed. Markdown only; no format, lint or type step applies.

## Changed files
- README.md: the Enforcement item under '## Agentic runtime architecture' gains one paragraph on the single dispatcher registration per runtime, the registry, the isolation knob (in-process shipped, per-process default when absent) and where a new PreToolUse hook is registered.
- docs/engineering/claude-code-architecture.md: '### Enforcement boundaries' gains a 'PreToolUse registration (issue #1159)' paragraph (dispatcher, union matcher without timeout, Codex timeout sum, registry, combination order, isolation and its per-process default, HOOK_DISPATCH_BLOCKED:). No hook name was removed.

## Selection and rule
Contract test that reads the changed documentation path: tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1.
