# Research: Local Preflight Orchestrator-State Gate (Issue #272)

- Timestamp: 2026-07-02T18-30
- Issue: #272
- Scope: repository-local tooling only (GitHub Actions workflow YAML, one PowerShell `pwsh`
  PreToolUse hook and its bundled mirrors, one Python CLI validator, and the Markdown contract
  documents that describe the PR-authoring handoff). No third-party UI, external service, or
  human-in-the-loop system is in scope. See `## Automation Feasibility` at the end of this
  document.

All findings below were produced by reading the referenced files directly in this working tree
(`C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01`) on 2026-07-02. Where the issue/spec
text asserts something that could not be independently confirmed with the tools available to this
research agent (no `Bash`/`gh` tool access), that limitation is called out explicitly rather than
repeated as fact.

## 1. The two CI workflow files (confirmed contents)

### `.github/workflows/validate-orchestrator-state.yml` (10 lines of content, full file)

```yaml
name: Orchestrator State Gate

on:
  pull_request:
    branches: [main, development]
  push:
    branches: [main, development]
  workflow_dispatch:

jobs:
  validate-orchestrator-state:
    uses: ./.github/workflows/_validate-orchestrator-state.yml
    with:
      state-path: artifacts/orchestration/orchestrator-state.json
      require-checkpoint: false
```

- Job/workflow name: `Orchestrator State Gate` (the top-level `name:`). The delegated job's
  display name (what would appear as a required-check name) is `Validate orchestrator checkpoint`
  — defined in the callee, see below.
- `on:` triggers: `pull_request` (branches `main`, `development`), `push` (branches `main`,
  `development`), and `workflow_dispatch`.
- Confirmed: `require-checkpoint: false` is hard-coded in the caller. This is the root cause the
  issue describes — the caller always passes `false`, so the reusable workflow's own default of
  `true` is never exercised via this entry point.

### `.github/workflows/_validate-orchestrator-state.yml` (69 lines, full file read)

- `name: Validate Orchestrator State` (workflow title). Job name: `Validate orchestrator
  checkpoint` (`jobs.validate-orchestrator-state.name`, line 31) — this is the string that would
  need to appear in branch-protection required-status-checks for the gate to ever block a merge.
- `on:` triggers: `workflow_call` (with `state-path` and `require-checkpoint` inputs, default
  `require-checkpoint: true`) and `workflow_dispatch` (same inputs, same defaults).
- Runner: `ubuntu-latest`.
- Steps: checkout (`actions/checkout@v7`), Python 3.13 setup (`actions/setup-python@v6`), Poetry
  install (`snok/install-poetry@v1`), `poetry install --no-interaction`, then a `Validate
  checkpoint` step whose exact `run:` body is:

  ```bash
  if [ ! -f "$STATE_PATH" ]; then
    if [ "$REQUIRE_CHECKPOINT" = "true" ]; then
      echo "ERROR: orchestrator checkpoint is required but was not found: $STATE_PATH" >&2
      exit 1
    fi
    echo "No orchestrator checkpoint found at $STATE_PATH; validation skipped."
    exit 0
  fi

  poetry run python -m scripts.dev_tools.validate_orchestration_artifacts \
    orchestrator-state "$STATE_PATH" --require-complete
  ```

  This confirms the issue's Steps-to-Reproduce #2 verbatim: the caller sets
  `require-checkpoint: false`, so on every CI run — where `artifacts/orchestration/
  orchestrator-state.json` cannot exist because `artifacts` is gitignored (see item 3) — the step
  prints `No orchestrator checkpoint found at $STATE_PATH; validation skipped.` and exits 0. The
  reusable workflow's underlying invocation of the Python validator (`poetry run python -m
  scripts.dev_tools.validate_orchestration_artifacts orchestrator-state "$STATE_PATH"
  --require-complete`) is real and correct in isolation, but it is unreachable given the caller's
  hard-coded `false`.

## 2. Bundled mirrors of the two workflow files

Both files exist at
`extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/`:

- `validate-orchestrator-state.yml` — byte-for-byte identical content to the primary copy (10
  lines, same `on:`/`jobs:` block, same hard-coded `require-checkpoint: false`).
- `_validate-orchestrator-state.yml` — **not** byte-identical. The `run:` block (the validator
  invocation and skip logic) is identical, but two action pins differ:
  - `actions/checkout@v7` (primary) vs `actions/checkout@v4` (bundled mirror).
  - `actions/setup-python@v6` (primary) vs `actions/setup-python@v5` (bundled mirror).

  This means the two copies are functionally equivalent but not byte-identical, contrary to what
  a plain "mirrors exist" assumption might imply. Any deletion of the primary pair must also
  delete this pair (both files), and any test that asserts byte-identical GitHub Actions workflow
  mirrors would need to special-case (or already special-cases) this action-pin drift. No other
  `.github/workflows/**` file (primary or bundled) references `validate-orchestrator-state`,
  `_validate-orchestrator-state`, `Validate orchestrator checkpoint`, or `Orchestrator State Gate`
  (confirmed via repository-wide grep against both `.github/workflows/**` and the bundled
  directory — 2 matches each, the two files themselves).

## 3. `.gitignore` — `artifacts` entry

Confirmed at `.gitignore` line 6:

```
artifacts
```

(Line 1 is `out`, line 2 `dist`, line 3 `node_modules`, line 4 `.vscode-test/`, line 5 `*.vsix`,
line 6 `artifacts`, line 7 `.agent_logs`.) This is a bare, unanchored gitignore pattern — it
matches any path segment named `artifacts` anywhere in the tree, not just the repo-root
`artifacts/` directory. `artifacts/orchestration/orchestrator-state.json` is therefore never
tracked and never present in a fresh CI checkout, confirming issue Root Cause 1.

## 4. `.claude/hooks/enforce-pr-author-skill.ps1` — full control-flow documentation

File: `.claude/hooks/enforce-pr-author-skill.ps1` (442 lines).

**Matched command patterns** (in `Get-PrAuthorBypassReason`, lines 239–315):
- `(?i)\bgh\s+pr\s+create\b` and `(?i)\bgh\s+pr\s+edit\b` — case-insensitive, word-boundary
  matches. Any other command (e.g. `gh pr view`, `gh pr list`, `gh pr merge`, `gh pr checkout`,
  `gh issue create`) returns `$null` immediately (allow) at lines 273–275.
- `(?i)--body-file\b` and `(?i)--body(?!-file)\b` distinguish body-file vs inline-body forms.

**Checks currently performed**, in this exact order (module docstring lines 19–28, code lines
239–315):
- **Case A** (line 282): `gh pr create`/`gh pr edit` with inline `--body` and no `--body-file` →
  block `PR_AUTHOR_SKILL_BLOCKED`. Evaluated before the `gh pr edit` no-body-flag allow
  short-circuit, so an inline-body edit is blocked, not silently allowed.
- **Case B** (line 288): `gh pr create` with neither `--body` nor `--body-file` → block
  `PR_AUTHOR_SKILL_BLOCKED` (with `--body-file` guidance in the reason text).
- `gh pr edit` with no body flag at all (e.g. `--title`, `--add-label`) → allow (line 296), this
  is intentional and covered by dedicated tests.
- **Case C** (line 301): `--body-file` present but `artifacts/pr_context.summary.txt` absent →
  block `PR_CONTEXT_MISSING`.
- **Receipt verification** (line 307, delegates to `Test-PrAuthorReceiptVerification`, lines
  137–237): runs only when `--body-file` is present **and** the context artifact exists. Five
  ordered checks, each a short-circuiting branch, first failure wins:
  1. `PR_BODY_PATH_NONCANONICAL` — `--body-file` must case-sensitively match
     `artifacts/pr_body_(\d+)\.md` (regex line 171, `-cnotmatch`).
  2. `PR_AUTHOR_RECEIPT_MISSING` — sibling `artifacts/pr_body_<N>.receipt.json` absent or not
     valid JSON (lines 180–190).
  3. `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` — `receipt.number` (parsed as int) must equal `<N>` from
     the path (lines 192–200).
  4. `PR_AUTHOR_RECEIPT_HASH_MISMATCH` — lowercase-hex SHA-256 of the body-file bytes (computed
     inline via `[System.Security.Cryptography.SHA256]`) must equal `receipt.sha256` (lines
     202–218).
  5. `PR_AUTHOR_RECEIPT_STALE` — `receipt.created_at` (parsed as UTC) must be strictly newer than
     `Get-Item artifacts/pr_context.summary.txt`'s `LastWriteTimeUtc` (lines 220–234).
  All five pass → returns `$null` (allow).

**Exact control flow / exit behavior** (lines 427–441, the entrypoint):
- Guarded by `if ($MyInvocation.InvocationName -eq '.') { return }` so Pester tests can
  dot-source the file without triggering the entrypoint.
- `Invoke-PrAuthorSkillDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT` is wrapped in `try/catch`;
  on a thrown exception (malformed JSON in `CLAUDE_TOOL_INPUT`), `Write-Error $_; exit 1`.
- On success, the decision object is emitted as compact JSON (`ConvertTo-Json -Compress -Depth
  5 | Write-Output`) and the script **always** `exit 0` afterward — the allow/deny signal is
  carried entirely in the JSON payload's `hookSpecificOutput.permissionDecision` field (`allow` /
  `deny`), not the process exit code. This is the Claude Code PreToolUse hook decision-output
  contract: `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}`
  for allow, or `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<Reason>"}}`
  for deny (builder functions `Get-PrAuthorSkillAllowDecision` / `Get-PrAuthorSkillBlockDecision`,
  lines 359–401). Any future extension of this hook (e.g., adding an orchestrator-state preflight
  check) must follow this same allow/deny-via-JSON-payload contract, not a nonzero exit code, to
  block the tool call — exit 1 is reserved specifically for "hook itself errored" (malformed
  input), not "policy denied."

**Existing dependency on `scripts/dev_tools/validate_orchestration_artifacts` or similar**: none.
`enforce-pr-author-skill.ps1` currently has zero references to the orchestrator-state validator,
`poetry`, or `python`. It only reads three filesystem seams (`Get-PrContextArtifactExistence`,
`Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, `Get-PrContextSummaryLastWriteUtc`) and never
shells out to an external process. This means extending it to invoke the Python validator would be
a new capability for this specific hook file, though the pattern already exists elsewhere in the
same hooks directory (see item 6).

## 5. Bundled mirrors of the hook

- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`
  — confirmed **byte-identical** to the primary copy (442 lines, identical content verified by
  full read/comparison). This matches the byte-identical mirror contract enforced by
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, described in item 8).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`
  — **not** byte-identical. It carries a 3-line prepended header:
  ```
  # Converted hook
  # Review the generated hook behavior before enabling it.

  ```
  followed by a body that is byte-identical to the root hook (445 lines total = 3 header lines +
  442 body lines, confirmed by full read). This header is produced by the
  `scripts/dev_tools/codex_native_converter` pipeline (the string `"Converted hook"` is emitted
  from `scripts/dev_tools/codex_native_converter/pipeline.py`), not by a plain file copy — so the
  Codex mirror is generated content, and editors must not hand-edit it to drop the header or it
  will drift from the converter's expected output shape. Prior evidence from issue #231
  (`docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/
  p5-codex-hook-qa.md`) explicitly confirms this shape: "the Codex hook … carries the `# Converted
  hook` header (2 comment lines + blank) followed by a body that is byte-identical to the root …
  (verified via `cmp`)."

**Important discrepancy found and worth flagging to a future editor**: the same #231 evidence file
(`cross-ecosystem-equality.md`) claims the Codex hook was "Wired in `.codex/config.toml` via a
`[[hooks.PreToolUse]]` entry referencing `enforce-pr-author-skill.ps1` (matcher `Bash`)." This
research confirmed that claim is **no longer true of the current repository state**: a full read of
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` (85 lines)
shows ten `[[hooks.PreToolUse]]` entries and one `[[hooks.SubagentStop]]` entry, and none of them
reference `enforce-pr-author-skill.ps1` (grep for `pr-author`, `pr_author`, `PR_AUTHOR`, and
`enforce-pr-author-skill` all return zero matches in that file). The Codex agent definition
`.codex/agents/pr-author.toml` also contains no hook wiring. The Codex mirror hook file therefore
currently exists on disk but is **not wired into any Codex PreToolUse hook list** — it is an
orphaned artifact in the current tree, regardless of what #231's evidence recorded at the time.
This is a pre-existing condition, not something introduced by #272's scope, but any editor
extending "the Codex mirror" per the issue's proposed fix should confirm whether re-wiring
`.codex/config.toml` is in scope, since editing the orphaned hook body alone will have no runtime
effect in the Codex ecosystem as currently configured.

## 6. `scripts/dev_tools/validate_orchestration_artifacts` — CLI surface and invocation pattern

File: `scripts/dev_tools/validate_orchestration_artifacts.py` (247 lines, full file read).

**CLI surface** (`build_parser()`, lines 136–173): `argparse` with subcommands `plan`,
`policy-audit`, `code-review`, `feature-audit` (each taking a single positional `path`), and
`orchestrator-state` (positional `path` plus `--require-complete`, a `store_true` flag, default
`False`, help text: "Require all tracked statuses to be complete-state safe.").

**Dispatch** (`_validate_from_args`, lines 176–210): reads the target file as UTF-8 text, then for
`orchestrator-state` calls `validate_orchestrator_state_text(text,
require_complete=bool(args.require_complete))` (imported from
`scripts.dev_tools.validate_orchestrator_state`, which is the module governed by
`.claude/rules/orchestrator-state.md`).

**Exit codes / output** (`main()`, lines 213–246): returns/exits `1` if the validator produced any
error strings (each printed to `stderr`), else prints
`f"{args.artifact_type} validation passed: {args.path}"` to stdout and returns/exits `0`. Module
entry point: `if __name__ == "__main__": raise SystemExit(main())`, and it is designed to be
invoked as `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state
<path> --require-complete`.

**`poetry run` vs plain `python` — established repo pattern (correction to the issue text)**: the
issue and spec both specify `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts
...` as the intended invocation. That exact form is what the CI reusable workflow uses (item 1),
because CI runs `poetry install` first and then must invoke inside the Poetry-managed venv. **The
existing pattern inside `.claude/hooks/` for invoking this same validator does not use `poetry
run`.** `.claude/hooks/validate-orchestrator-output.ps1` (a SubagentStop hook for the
`orchestrator` subagent, referenced from `.claude/skills/orchestrate/SKILL.md` and
`.claude/agents/orchestrator.md`) already calls this exact CLI, via an **injectable subprocess
scriptblock seam**, using plain `python`, not `poetry run python`:

```powershell
function Invoke-RoutingContractValidation {
    param(
        [Parameter(Mandatory = $true)] [string] $CheckpointPath,
        [Parameter(Mandatory = $false)] [scriptblock] $Invoker = {
            param($Path)
            $output = & python -m scripts.dev_tools.validate_orchestration_artifacts `
                orchestrator-state $Path --require-complete 2>&1
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String) }
        }
    )
    $result = & $Invoker $CheckpointPath
    ...
    $hasErrors = ($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))
    return @{ HasErrors = $hasErrors; ErrorText = $outputText }
}
```

(`.claude/hooks/validate-orchestrator-output.ps1`, lines 144–194.) The caller
(`Invoke-OrchestratorOutputValidation`, lines 196–288) exposes an optional `-RoutingInvoker`
parameter that flows into `Invoke-RoutingContractValidation`'s `-Invoker`, purely so Pester tests
can substitute a mock scriptblock and avoid spawning a real Python process (confirmed in
`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`). This
injectable-scriptblock-with-real-default pattern is exactly the "Injectable delegate / ScriptBlock
seam" option described in `.claude/rules/powershell.md`'s Design Seams section, and it is the
established, already-tested precedent for invoking this Python CLI from a `pwsh` PreToolUse/
SubagentStop hook context in this repository. A future editor extending
`enforce-pr-author-skill.ps1` to add an orchestrator-state preflight check should reuse this same
seam shape (a `[scriptblock] $Invoker` default parameter wrapping `& python -m
scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete`)
rather than hard-coding a `poetry run` invocation with no test seam. Whether `python` resolves
correctly without an explicit `poetry run` prefix depends on the calling shell's active virtual
environment; this existing hook already carries that same assumption, so it is a pre-existing,
accepted repository pattern rather than a new risk introduced by following it.

## 7. Existing Pester tests for `enforce-pr-author-skill.ps1`

File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (476 lines, full file read).
Structure (a future editor should extend this file, not create a new one, per
`.claude/rules/general-unit-test.md`'s test-file-location rule):

- `BeforeAll`: dot-sources the hook at `$PSScriptRoot/../../../.claude/hooks/
  enforce-pr-author-skill.ps1` and defines `$script:HashOf0x41` (a fixed SHA-256 constant reused
  across receipt tests).
- `Context 'tool input parsing'` — empty input, missing `command` field, malformed JSON (throws).
- `Context 'gh pr create - inline body (Case A)'` and `'gh pr edit - inline body (Case A)'` —
  inline `--body` and `--body=` equals-sign forms, both `create` and `edit`.
- `Context 'gh pr create - missing body (Case B)'`.
- `Context 'gh pr create/edit - missing context artifact (Case C)'`.
- `Context 'allowed commands'` — a shared `BeforeEach` mocks all four read seams to a passing
  receipt, then asserts allow for `gh pr create --body-file`, `gh pr edit --body-file`, `gh pr
  edit --title` (no body flag), `gh pr edit --add-label`, and non-guarded commands (`gh pr view`,
  `gh pr list`, `gh pr merge`, `gh pr checkout`, `gh issue create`).
- Five `Context` blocks, one per receipt-check failure mode:
  `'receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)'`,
  `'receipt - missing (PR_AUTHOR_RECEIPT_MISSING)'`,
  `'receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)'`,
  `'receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)'`,
  `'receipt - stale (PR_AUTHOR_RECEIPT_STALE)'`, plus `'receipt - all checks pass (allow)'`.
- `Context 'Get-PrAuthorBypassReason helper'`, `'decision builders emit the PreToolUse schema'`
  (serialize-then-parse round-trip assertions), `'Test-PrAuthorBypassRequired helper'`.
- Real-seam (non-mocked) contexts that point seams at the hook file itself as a stand-in existing
  file, to avoid any temporary-file creation: `'Get-PrContextArtifactExistence real Test-Path
  wrapper'`, `'Get-PrBodyFileBytes real read seam'`, `'Get-PrAuthorReceiptContent real read seam'`,
  `'Get-PrContextSummaryLastWriteUtc real seam'`.
- `Context 'Invoke-PrAuthorSkillDecision without mock (real context lookup)'`.
- `Context 'script entrypoint (end-to-end)'` — spawns the real `pwsh` executable against the hook
  file via `CLAUDE_TOOL_INPUT`, asserting `$LASTEXITCODE -eq 0` for both allow and deny outcomes
  (confirming the "always exit 0, signal via JSON" contract from item 4) and `$LASTEXITCODE -eq 1`
  for malformed JSON.

A new "orchestrator-state preflight" capability would most naturally add: a new `BeforeEach`-mocked
`Context` block for the preflight-pass/preflight-fail cases (mocking the new `$Invoker` seam per
item 6), plus new assertions in the existing `'gh pr create/edit - missing context artifact (Case
C)'`-style sections if the new check is ordered relative to existing cases, plus a new end-to-end
`It` in the `'script entrypoint (end-to-end)'` context if the new check should be exercised via a
real `pwsh` process invocation.

## 8. Bundled-mirror contract tests (Python + Pester)

The Python contract test enforcing byte-identical `.claude/` mirror parity is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (full file partially read).
Its mechanism:

- `list_scoped_files(root)` walks `root / ".claude"` recursively (`SCOPED_ROOTS = (Path(".claude"),)`)
  and returns all files, sorted.
- `test_bundled_claude_payload_contains_required_runtime_files` — asserts a fixed anchor list
  (`REQUIRED_BUNDLED_FILES`, includes `.claude/settings.json`, several `SKILL.md` files,
  `.claude/rules/python.md`, `.claude/rules/typescript.md`, `.claude/agents/orchestrator.md`) is
  present in the bundle.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` — for **every** repo `.claude`
  file except `.claude/settings.local.json` and anything under `.claude/agent-memory/` (scope-
  filtered, not byte-mirrored), asserts (a) the same relative path exists in the bundle and (b)
  `read_text(BUNDLED_ROOT, path) == read_text(REPO_ROOT, path)` — a **literal, exact-string
  equality** check (not a checksum, not a normalized diff). This is the test that would fail if
  `.claude/hooks/enforce-pr-author-skill.ps1` were edited without the identical edit landing at
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/
  enforce-pr-author-skill.ps1`.
- `test_pack_manifests_are_outside_the_parity_scope`,
  `test_bundled_claude_payload_excludes_settings_local_json`,
  `test_bundled_claude_payload_excludes_variant_subtree_from_parity`,
  `test_variant_subtree_is_bundle_only_and_non_colliding` — scope-boundary tests confirming
  `pack-manifests/` and `.claude-variants/csharp-legacy/` are correctly outside the `.claude/**`
  parity comparison.

The analogous Codex-ecosystem contract test is
`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (present in the
repo; not read in full for this research pass, but its existence and naming confirm a parallel
contract exists for `.codex`/`.agents`). Because the Codex hook mirror is **not** byte-identical
(it carries the converter header, item 5), that test's assertion mechanism for hooks specifically
cannot be a literal string-equality check the way the Claude test is; it is presumably validated
via the `codex_native_converter` pipeline's own test suite
(`tests/scripts/dev_tools/codex_native_converter/`) rather than the resource-contract test. A
future editor should re-run whichever test governs `.codex/hooks/enforce-pr-author-skill.ps1`
specifically (likely by re-running `run_codex_native_converter` or its test harness) rather than
assuming the Claude-mirror byte-equality test also covers the Codex copy.

No Python or Pester test with "mirror"/"bundled"/"parity" in scope was found that validates
`.github/workflows/validate-orchestrator-state.yml` against its bundled counterpart specifically
by name; the general `.claude`-scoped parity test does not cover `.github/workflows/**` (its
`SCOPED_ROOTS` is `.claude` only). Deleting both primary-copy and bundled-copy workflow files
together (as the issue proposes) removes this pair from consideration entirely, so no workflow-
mirror-parity test needs updating as a result of the deletion itself.

## 9. `.claude/settings.json` — PreToolUse wiring for the hook

Confirmed at `.claude/settings.json` lines 70–92 (the `PreToolUse` hook array, `matcher: "Bash"`
entry):

```json
"PreToolUse": [
  {
    "matcher": "Bash",
    "hooks": [
      { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/validate-bash.ps1" },
      { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-promotion-mcp-only.ps1" },
      { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1" },
      { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1" }
    ]
  },
  ...
]
```

`enforce-pr-author-skill.ps1` is the third of four hooks run in sequence for every `Bash`-matched
tool call (all four run; Claude Code PreToolUse hooks are not short-circuited by an earlier hook's
allow decision within the same matcher array, per the hook harness contract used elsewhere in this
repo). No changes to this wiring are implied by #272 — the hook file itself already fires on every
`Bash` call, including `gh pr create`/`gh pr edit`.

## 10. Current wording of the three contract documents

### `.claude/skills/orchestrate/SKILL.md` § "## PR Authoring (pr-author Handoff)" (lines 68–80, full section)

Opens: "PR creation and PR body edits are delegated work, not orchestrator work. The orchestrator
MUST NOT call `gh pr create` or `gh pr edit --body*` directly from the main thread; the
`enforce-pr-author-skill.ps1` PreToolUse hook blocks those commands unless the `--body-file`
argument resolves to a canonical `artifacts/pr_body_<N>.md` path with a matching, verified
`artifacts/pr_body_<N>.receipt.json`."

Then a 3-step mandatory sequence (context refresh via `mcp__drm-copilot__collect_pr_context` →
delegate to `Agent(pr-author)` → orchestrator records `pr_author_receipt` in the checkpoint), a
paragraph restating that `Agent(pr-author)` is the mandatory delegate and describing the five
ordered receipt checks, and a closing paragraph on the SHA-256 receipt being a policy-level (not
cryptographic) integrity check. **No sentence in this section currently references CI, GitHub
Actions, or `validate-orchestrator-state.yml`** — the section is entirely about the `pr-author`
handoff and the `enforce-pr-author-skill.ps1` hook. This means #272's edit to this section is
additive (add a preflight-validation sentence/step) rather than a removal of an incorrect CI
claim — confirming that item 11's premise ("update SKILL.md … so none of them describe CI as the
enforcement mechanism") needs re-scoping: this particular section does not currently describe CI
as the enforcement mechanism at all.

Immediately following, `## Evidence Location Authority` and `## GitHub Actions Reusable Workflows`
sections exist in the same file (lines 82–99); the latter documents the reusable-workflow naming
convention (`_<name>.yml` + `on: workflow_call:`/`on: workflow_dispatch:`) generally but does not
name `validate-orchestrator-state.yml` specifically.

### `.claude/agents/orchestrator.md` § "## PR Creation Delegation" (lines 76–109, full section read)

Opens: "PR creation and PR body edits must be delegated to `Agent(pr-author)`. The orchestrator
must not call `gh pr create` or `gh pr edit --body*` directly from the main thread; those commands
are blocked by the `enforce-pr-author-skill.ps1` PreToolUse hook unless the `--body-file` argument
resolves to a canonical `artifacts/pr_body_<N>.md` path with a matching, verified
`artifacts/pr_body_<N>.receipt.json`." It restates the same handoff sequence and explicitly defers
authority: "The authoritative handoff contract is `.claude/skills/orchestrate/SKILL.md` `## PR
Authoring (pr-author Handoff)`; this section defers to it."

The same top-level section (`## PR Creation Delegation`) also contains, as subsections:
- `### Remediation Loop Checkpoint Shape` — describes `remediation_loop.cycles[]` fields
  (`entry_timestamp`, `inputs_path`, `plan_path`, `preflight`, `execution_status`, `audit_paths`,
  `blocking_count`, `exit_condition_met`) and the three malformed-cycle rules from
  `.claude/rules/orchestrator-state.md`.
- `### CI Monitoring and Post-PR Remediation` — states: "After the PR is opened, the orchestrator
  monitors the required CI checks against the live PR head SHA. A failed required check is not
  handled outside the loop … Workflow-file changes go through the remediation loop and trigger the
  `modified-workflow-needs-green-run` policy rule … The orchestrator must not commit workflow-file
  changes outside the remediation loop." This subsection references CI checks generically (any
  required check, monitored post-PR) but does not name `validate-orchestrator-state.yml` or
  `Validate orchestrator checkpoint` specifically — so no literal string in this subsection needs
  to be deleted for #272; it remains generically true regardless of whether the orchestrator-state
  gate exists as a CI workflow.

### `.claude/agents/pr-author.md` (full file, 88 lines)

Frontmatter: `name: pr-author`, `model: sonnet`, `skills: [pr-author]`, `memory: project`, `tools:`
list is `Read`, `Bash(git log *)`, `Bash(git rev-parse *)`, `Bash(gh pr create *)`,
`Bash(gh pr edit *)`, `Write(/artifacts/**)` — note `pr-author` does **not** have a general `Bash`
tool grant, only the four scoped patterns; a preflight `poetry run python -m
scripts.dev_tools.validate_orchestration_artifacts ...` call from inside the `pr-author` agent
itself (as opposed to inside the PreToolUse hook, which runs outside the agent's own tool-
permission scope) would require either broadening this `tools:` allowlist or keeping the preflight
check entirely inside the hook (which needs no additional agent-level tool grant, since PreToolUse
hooks execute as the harness, not as agent-issued tool calls). `hooks: SubagentStop:` wires
`validate-pr-author-output.ps1` with `matcher: "pr-author"`.

Body sections: `## Skill` (points at `.claude/skills/pr-author/SKILL.md`), `## PR Body and
Receipt Write Protocol` (the four ordered steps: write body → compute SHA-256 → write receipt with
exact field list `skill`, `pr_body_path`, `number`, `sha256`, `context_summary_path`, `created_at`
→ issue `gh pr create --body-file ...`), `## Final Output Requirement` (must report a PR URL or PR
number, enforced by `validate-pr-author-output.ps1`), `## Enforcement Strength (Honest
Disclosure)` (the same "policy-level, not cryptographic" disclosure as the other two documents,
citing the PR #228 pattern as the original bypass this receipt mechanism was built to prevent),
and `## Standing Rules` (tone + citation-scope rules). **No sentence in `pr-author.md` currently
references CI or `validate-orchestrator-state.yml`** — like the `SKILL.md` section, this file's
edit for #272 is additive (documenting the new local preflight step as part of the mandatory
sequence, and/or noting that the orchestrator must run/record the preflight before the handoff),
not a removal of an incorrect CI-as-enforcement claim.

## 11. `CLAUDE.md` — CI validation path references

Grepped the full `CLAUDE.md` content for `validate-orchestrator-state`, `orchestrator-state.json`,
and `Orchestrator State Gate`. Only one match: the Architecture section states "The orchestration
checkpoint path for this runtime is `artifacts/orchestration/orchestrator-state.json`. The main
session reads `artifacts/orchestration/orchestrator-state.json` before worker delegation and
updates the same file across phase transitions." This sentence describes the checkpoint's role in
the runtime architecture generically; it makes no claim about how the checkpoint is validated (CI
or otherwise) and does not name any workflow file. **`CLAUDE.md` requires no edit to remove a CI-
enforcement claim, because it contains none.** If #272's fix adds a local preflight-validation
concept, `CLAUDE.md`'s Architecture section is a plausible (optional) place to add one sentence
noting the enforcement mechanism is a local `pwsh` PreToolUse hook, not CI, but this is additive
documentation rather than a correction of existing text.

## 12. Branch ruleset / required-status-check confirmation — tool limitation

This research agent's available tools are `Read`, `Grep`, `Glob`, `WebFetch`, `Write`, `Edit` — no
`Bash` tool is available in this delegation. **The `gh api repos/:owner/:repo/rules/branches/main`
command the issue's Steps-to-Reproduce #3 specifies could not be executed by this research pass.**
This is a genuine gap: the claim "`Validate orchestrator checkpoint` was never added to the `main`
branch ruleset's `required_status_checks`" is asserted by the issue text but not independently
re-verified here. Circumstantial support: even if the check name were registered as required, the
workflow itself (item 1) always exits 0 on every run regardless of checkpoint validity (because
`require-checkpoint: false` skips real validation whenever the file is absent, which per item 3 is
always, in CI), so the check would still never observably fail — meaning branch-protection wiring
is a secondary defect independent of whether it happens to be present. A future orchestrator or
implementer with `Bash`/`gh` access should run the exact command from the issue before relying on
this claim as verified fact; this research explicitly flags it as **unverified-by-this-pass**
rather than confirmed.

Repository-wide grep confirms no other workflow file (primary `.github/workflows/**` or bundled
`extensions/.../codex-and-agents-customizations/.github/workflows/**`) references
`validate-orchestrator-state`, `Validate orchestrator checkpoint`, or `Orchestrator State Gate`
outside the two files themselves in each location (item 2). Deleting the four files (two primary +
two bundled) therefore has no other in-repo workflow reference to update.

## 13. `quality-tiers.yml` tier classification

**`quality-tiers.yml` does not currently exist at the repository root** (confirmed via `Glob` for
`quality-tiers.yml` at repo root — no match — and via `Glob` for `*.yml` at repo root, which lists
only `.github/dependabot.yml` and the `.github/workflows/**` files; no root-level
`quality-tiers.yml`). `.claude/rules/quality-tiers.md` (and its bundled mirror) both state
"`quality-tiers.yml` at repo root maps every project to a tier" and "Adding a project without a
tier classification fails CI," but the file itself is absent from this working tree. Consequently
there is no existing tier classification for `scripts/dev_tools/validate_orchestration_artifacts`
(or any other project) to check against, and no unclassified-project CI gate currently has
anything to enforce. A future editor of #272 does not need to add a tier entry for this module
specifically (there is nowhere to add it), but should not assume `quality-tiers.yml`'s absence is
new/introduced by this feature — it predates this research pass and is an existing, orthogonal gap
in the repository, out of scope for #272 unless a maintainer decides to introduce the file as part
of this change.

## Candidate Approaches for the Local Preflight Mechanism

Two structurally different places to add the local preflight check were considered while reading
the existing hook/skill contracts:

1. **Inside `enforce-pr-author-skill.ps1` itself (recommended by the issue and consistent with
   existing precedent).** Add a new ordered check — after Case C (context-artifact-present) and
   either before or after the five receipt checks — that invokes the orchestrator-state validator
   via an injectable `[scriptblock] $Invoker` seam (following the exact pattern already proven in
   `.claude/hooks/validate-orchestrator-output.ps1`, item 6) and returns a new reason code (for
   example `PR_AUTHOR_PREFLIGHT_BLOCKED` or `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`) when the
   checkpoint is missing or `--require-complete` fails. Advantages: reuses an already-tested seam
   pattern, requires no new hook registration in `.claude/settings.json` (the hook already fires on
   every `Bash` call), and directly satisfies the issue's "hardened by a PreToolUse hook so it
   cannot be bypassed by invoking `gh pr create` directly" requirement, because the check runs
   inside the same hook that already blocks bare `gh pr create`. Limitations: the hook file grows
   past its current 442 lines (still well under the repository's 500-line cap) and gains a Python
   subprocess dependency it did not previously have, which changes the hook's test isolation
   profile (Pester tests already mock filesystem seams; a new scriptblock seam keeps this pattern
   consistent and mockable, per item 7's structure).
2. **A separate new preflight step invoked explicitly by the orchestrator before delegating to
   `Agent(pr-author)`, recorded as `pr_author_preflight` in the checkpoint** (as the issue's
   proposed-fix checklist item 2 describes), in addition to the hook-level hardening. Advantages:
   gives the orchestrator an observable, checkpoint-recorded preflight result before it even
   attempts delegation, matching the "immediately before any PR-creating action" framing in the
   issue's Expected Behavior. Limitations: by itself, without the hook-level check, this does not
   satisfy the issue's explicit requirement that the check "cannot be bypassed by invoking `gh pr
   create` directly" — an orchestrator (or any other actor with `Bash(gh pr create *)` access, if
   ever granted) could still bypass a purely orchestrator-side preflight step. The issue's own
   proposed-fix checklist treats this as complementary to, not a replacement for, the hook-level
   check.

**Recommendation**: both are needed and are not mutually exclusive — approach 1 (hook-level check)
is the hardening the issue's title and Expected Behavior require and is the only one that closes
the bypass path; approach 2 (orchestrator-recorded `pr_author_preflight` checkpoint field) gives
observability and an audit trail consistent with the existing `remediation_loop` / `pr_author_
receipt` checkpoint conventions already documented in `orchestrator.md`. This matches the issue's
own proposed-fix checklist, which lists both as separate checked items.

## Rejected Alternatives

- **Re-registering the CI workflow as a required status check instead of building a local
  hook-based gate**: rejected because it does not address Root Cause 1 (the checkpoint file is
  intentionally gitignored and per-worktree, so it will never exist in a CI checkout regardless of
  branch-protection wiring); the gate would remain structurally unable to see real checkpoint
  content in CI.
- **Invoking the validator with `poetry run python`** inside the hook (matching the issue/spec's
  literal proposed command) instead of the plain `python -m ...` + injectable-scriptblock pattern
  already used by `validate-orchestrator-output.ps1`: rejected in favor of matching existing,
  already-tested repository precedent (item 6), unless a maintainer has a specific reason the
  `poetry run` prefix is required in the hook's execution context that does not apply to the
  existing sibling hook.

## Testing Implications

- Extend `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (item 7) rather than
  creating a new test file, adding: mocked-`Invoker`-seam contexts for preflight pass/fail, and
  (if the new check is added to the real entrypoint) new end-to-end `It` blocks under the existing
  `'script entrypoint (end-to-end)'` context.
- Any new Python behavior belongs in `scripts/dev_tools/validate_orchestrator_state.py` /
  `validate_orchestration_artifacts.py`, both of which already have `tests/scripts/dev_tools/
  test_validate_orchestration_artifacts.py` and `test_validate_orchestrator_state_human_
  interaction.py` as their existing pytest coverage location — no new CLI behavior is implied by
  #272 (the CLI surface already supports `orchestrator-state <path> --require-complete`), so no
  new Python test file is anticipated unless the CLI contract itself changes.
- Deleting the two CI workflow files (`.github/workflows/validate-orchestrator-state.yml`,
  `_validate-orchestrator-state.yml`) and their two bundled mirrors requires no test updates beyond
  confirming (via the existing bundled-mirror contract tests, item 8) that no `REQUIRED_BUNDLED_
  FILES` anchor list or similar fixture references either deleted filename; a grep of
  `REQUIRED_BUNDLED_FILES` in `test_push_down_claude_resource_contracts.py` (item 8, lines 20–30)
  shows no such reference already.
- Per the toolchain-loop policy, any PowerShell hook change must be run through `format → analyze
  → test` (PoshQC via the MCP commands in `.claude/rules/powershell.md`) and any Python change
  through `format → lint → type-check → test` (Black/Ruff/Pyright/Pytest per `.claude/rules/
  python.md`) before completion.

## Automation Feasibility

This research involved no third-party UI (no Azure portal, Entra admin center, Outlook, or M365
admin center interaction). Every artifact examined is repository-local: two GitHub Actions
workflow YAML files and their bundled mirrors, one PowerShell `pwsh` PreToolUse hook and its two
bundled mirrors, one Python CLI module and its existing pytest coverage, `.claude/settings.json`
hook wiring, and Markdown contract documents (`SKILL.md`, `orchestrator.md`, `pr-author.md`,
`CLAUDE.md`). All of this is readable, editable, and testable entirely within the repository
working tree using the existing local toolchain (PoshQC for PowerShell, Poetry/Pytest for Python).

There are no human-interaction requirements to surface for this feature. The one item this research
pass could not independently verify — the `main` branch ruleset's required-status-check
configuration (item 12) — is a read-only confirmation step achievable via `gh api
repos/:owner/:repo/rules/branches/main`, which requires only `gh` CLI / GitHub API access already
available to the orchestrator's own tool grants (`Bash(git *)` and MCP tools); it does not require
any interactive human approval, browser session, or third-party admin console. It was left
unverified here solely because this research delegation's tool allowlist does not include a `Bash`
tool, not because the check itself requires a human in the loop.
