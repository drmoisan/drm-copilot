# codex-pretooluse-hook-transport (Potential Bug)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted
- Promoted to: https://github.com/drmoisan/drm-copilot/issues/415
- Active folder: docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

Codex `PreToolUse` handlers registered under the `^(apply_patch|Edit|Write)$` matcher in `.codex/config.toml` exit 2 on every invocation, because each handler's payload validator hard-requires `tool_name == 'apply_patch'` and rejects the `Edit` and `Write` tool names the matcher admits. The result is repeated nonzero `PreToolUse` hook exits and `invalid pre-tool-use JSON output` in Codex sessions.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell 7 hook handlers)
- Command/flags used: `pwsh -NoProfile -File .codex/hooks/<handler>.ps1` with a `PreToolUse` payload on stdin
- Data source or fixture: `.codex/config.toml` hook registrations

## Steps to Reproduce

1. Pipe a well-formed Codex `PreToolUse` payload with `tool_name = "Edit"` and a benign `tool_input` into `.codex/hooks/enforce-evidence-locations.ps1`.
2. Observe the exit code and stderr.
3. Repeat for `tool_name = "Write"` and for the other handlers registered under the `^(apply_patch|Edit|Write)$` matcher.

## Expected Behavior

For an allowed operation the handler exits 0 with no stdout. A handler registered under a matcher that admits `Edit` and `Write` must accept those tool names and evaluate its policy against the corresponding `tool_input`, not reject the payload.

## Actual Behavior

Handlers in the `^(apply_patch|Edit|Write)$` group exit 2 for the admitted tool names. Measured directly:

```
check-python-test-purity         Edit         exit=2  stderr=[check-python-test-purity requires a PreToolUse apply_patch payload.]
check-python-test-purity         Write        exit=2  stderr=[check-python-test-purity requires a PreToolUse apply_patch payload.]
check-python-test-purity         apply_patch  exit=2  stderr=[check-python-test-purity cannot map tool_input to a file edit.]
enforce-python-batch-budget      Edit         exit=2  stderr=[enforce-python-batch-budget requires a PreToolUse apply_patch payload.]
check-powershell-test-purity     Edit         exit=2  stderr=[check-powershell-test-purity requires a PreToolUse apply_patch payload.]
enforce-powershell-batch-budget  Edit         exit=2  stderr=[enforce-powershell-batch-budget requires a PreToolUse apply_patch payload.]
enforce-evidence-locations       Edit         exit=2  stderr=[enforce-evidence-locations requires a PreToolUse apply_patch payload.]
enforce-checkpoint-monotonic     Edit         exit=2  stderr=[enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.]
enforce-completion-consistency   Edit         exit=2  stderr=[enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.]
```

Preflight subsequently established that the same matcher group also registers `enforce-orchestration-preimplementation-gate.ps1`, which admits only `Bash` and `apply_patch` and therefore exits 2 for `Edit` and `Write` as well, bringing the affected handler count to eight.

The handlers registered under `^Bash$` and under `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` exit 0 with empty stdout for every admitted tool name and are not implicated.

## Logs / Screenshots

- [x] Attached minimal logs or snippet
- Snippet: see the measured table under **Actual Behavior**.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Every Codex file edit fires the failing hooks, so the enforcement surface those hooks implement (test purity, batch budget, evidence locations, checkpoint monotonicity, completion consistency, pre-implementation gating) is not actually applied to `Edit` or `Write` operations.

## Suspected Cause / Notes

- `.codex/config.toml` widened the third `PreToolUse` matcher to `^(apply_patch|Edit|Write)$` without widening the handlers' payload validators, which still assert `tool_name == 'apply_patch'`.
- The `apply_patch` path additionally fails when `tool_input` carries neither `file_path` nor a `command` string containing `*** Add File:` / `*** Update File:` / `*** Delete File:` / `*** Move to:` markers.
- `enforce-completion-consistency.ps1` names `enforce-checkpoint-monotonic` in its stderr because it dot-sources that handler and reuses its validator. Research confirmed this is by design, not a copy-paste defect; the shared error messages need `-HookName` parameterization rather than a rename.
- The bundled Codex customization copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/` is out of parity with the repository root `.codex/`: its `config.toml` differs and it carries an unregistered `enforce-pr-author-skill.ps1` the root does not.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: per-handler process-level Pester tests covering a valid safe payload (exit 0, empty stdout and stderr), a representative forbidden payload (exit 0, native deny envelope), malformed stdin (exit 2, empty stdout, nonempty stderr), and poisoned `CLAUDE_*` environment variables (behavior unchanged).
- [x] Integration scenario to retest: run the full registered `PreToolUse` set against every tool name its matcher admits and assert no handler exits nonzero on a benign payload.
- [x] Manual verification notes: preserve each handler's existing allow/deny policy; change only tool-name admission, `tool_input` mapping, and error handling. Do not weaken or unregister any hook.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
