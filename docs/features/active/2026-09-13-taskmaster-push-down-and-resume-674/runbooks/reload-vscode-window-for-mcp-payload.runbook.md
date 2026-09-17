# Human-Exception Runbook — Reload the VS Code Window So the MCP Server Serves the Rebuilt Extension Payload

This runbook satisfies requirement HI-2 of feature F7 `taskmaster-push-down-and-resume`
(issue #674), part of the `worktree-scoped-state-resolution` epic. It covers only the narrow,
unautomatable sub-step of "rebuild and reinstall the VS Code extension": making the newly
installed payload actually served by the running VS Code window's MCP server process. The
rebuild, package, and install sub-steps are automated separately (see Prerequisites) and are out
of scope here. The push-down call itself and the post-push-down destination-content check are
also out of scope; see the sibling runbook
`docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/runbooks/confirm-taskmaster-run-resume.runbook.md`
for the step that follows this one downstream (HI-1).

## Cue

Act on this runbook immediately after the automated rebuild/package/install command has completed
successfully:

```powershell
pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force
```

(Command and its behavior verified from the research artifact's `## Automation Feasibility`
section: it runs `npm ci`, `npm run compile`, `npx --yes @vscode/vsce package`, and
`code-insiders --install-extension <vsix> --force`, non-interactively under PowerShell's default
`$ConfirmPreference`.)

Act on this runbook strictly **before** any of the following, in this order:

1. The installed-payload staleness/freshness grep against
   `resources/claude-customizations/.claude/hooks/` (research `## Q1`).
2. The `core.json` manifest-registration check for F1's new module path (research `## Q2`).
3. The `mcp__drm-copilot__push_down_claude_customizations` call.

Every downstream step in this feature's plan is gated on this one. The research establishes, from
this repository's own code, that a successful, exit-code-0 rebuild and reinstall does not by
itself make the running window's MCP server serve the new payload: the already-spawned MCP server
process fixed its `extensionRoot` at process start and does not re-read it
(`extensions/drm-copilot/src/mcp-server.ts`, `resolveExtensionRoot()`). Running the push-down
before completing this runbook publishes the OLD payload to the destination, which is exactly the
"verification trap" this feature exists to avoid — including the specific risk that a genuine,
unsuperseded local hand-fix at the destination is overwritten with stale content (research `## Q4`
of the same document).

## Prerequisites

- The automated rebuild/package/install command above has run and exited `0`. Its exit code is
  necessary but not sufficient; see Verification below for why it is not itself the signal that
  this runbook's step succeeded.
- The operator knows which specific VS Code window (which product — Code or Code Insiders — and
  which open workspace) hosts the `drm-copilot` extension and its MCP server process, since the
  reload action in this runbook targets that specific window, not "VS Code" in the abstract.
- The operator is aware that more than one `drm-copilot`-identity extension directory currently
  coexists on this machine, verified via Glob/Read in the research artifact (`## Q1`, "Installed
  extension directories on this machine right now"):

  | Directory | Product | Extension ID | Version | Hook count |
  | --- | --- | --- | --- | --- |
  | `C:/Users/DanMoisan/.vscode/extensions/undefined_publisher.drm-copilot-0.0.1` | VS Code (stable) | `undefined_publisher.drm-copilot` | 0.0.1 | 8 |
  | `C:/Users/DanMoisan/.vscode-insiders/extensions/undefined_publisher.drm-copilot-0.0.1` | VS Code Insiders | `undefined_publisher.drm-copilot` | 0.0.1 | 8 |
  | `C:/Users/DanMoisan/.vscode-insiders/extensions/danmoisan.drm-copilot-1.1.10` | VS Code Insiders | `danmoisan.drm-copilot` | 1.1.10 | 44 |
  | `C:/Users/DanMoisan/.vscode-insiders/extensions/danmoisan.drm-copilot-1.1.11` | VS Code Insiders | `danmoisan.drm-copilot` | 1.1.11 | 44 |

  The two `undefined_publisher.drm-copilot-0.0.1` directories are an older, unpublished dev-sideload
  identity with a smaller, stale hook set; the two `danmoisan.drm-copilot` directories are the
  current publisher identity. Both extension IDs declare the identical MCP provider ID
  `drmCopilotMcpProvider`, so the research recommends not assuming the stale identity is inert
  without checking (see Verification below).

## Step-by-step Instructions

1. Confirm which VS Code product the install command targeted. The `-UseInsiders` flag in the
   Cue's command resolves to `code-insiders --install-extension ... --force`
   (`Resolve-VSCodeCliCommand` in `scripts/dev-tools/vscode-cli.helpers.ps1`, per the research
   artifact). The window to reload in this procedure is therefore a **VS Code Insiders** window,
   not a VS Code (stable) window, unless the operator ran the install command without
   `-UseInsiders`.
2. Switch focus to the target VS Code Insiders window identified in Prerequisites.
3. Open the Command Palette (`Ctrl+Shift+P` on Windows) and run **"Developer: Reload Window"**.
   This is the primary route. It reloads the extension host in place, causing VS Code to
   re-activate the `drm-copilot` extension from its currently installed directory (the version
   VS Code's own extension scanner selects for that extension ID — the highest installed version
   when duplicates exist, per the research artifact's `## Q1`) and to spawn a fresh MCP server
   process whose `extensionRoot` resolves against the newly reloaded activation.
4. If "Developer: Reload Window" is unavailable, does not complete, or the window remains
   unresponsive, fall back to a full VS Code Insiders restart: close the application window (or
   use the application's own quit action) and relaunch VS Code Insiders, then reopen the workspace
   that hosts the extension.
5. There is no supported external-CLI equivalent for reloading an already-running window from
   outside VS Code. The extension itself contributes no "reload" or "restart MCP server" command
   of its own (verified against the full `contributes.commands` list in
   `extensions/drm-copilot/package.json`, per the research artifact). Do not attempt to script this
   step by forcibly killing and relaunching the VS Code process: the research considered and
   rejected that approach because it has no non-interactive execution path in this repository's
   tooling, it risks terminating the very session running the rest of the plan, and it has no
   graceful equivalent for a window with unsaved state (research `## Candidate approaches`,
   "Approach B (rejected)"). Use the Command Palette route or a manual restart only.
6. This step makes no git commit, opens no PR, and does not call `vsce publish`. It is unrelated to
   this repository's Marketplace-publish automation
   (`.github/workflows/publish-extension.yml`, `Publish-DrmCopilotExtension.ps1 -Publish`), which is
   patch-only, merge-gated, and CI-only; that pipeline targets the VS Code Marketplace and does not
   bear on a local sideloaded install (research `## Automation Feasibility`, "Known constraint
   check"). Do not mistake this reload step for a publish action, and do not expect or require any
   merge, tag push, or version bump before or after it.

## Verification

The install command's exit code is **not** the signal that this step succeeded. Per the research
artifact, the only available proof that the reload actually took effect is the same
installed-payload staleness/freshness grep that the plan already requires as its next gating task
(research `## Q1`, `## Q6` step 3) — no separate reload-completion mechanism exists or is needed.

Run the grep for the concrete literal selected per the research's `## Q3` guidance (a single,
short, non-interpolated, wrap-tolerant token unique to the epic's corrected content, derived at
execution time from `git diff` against the pre-epic base) against
`resources/claude-customizations/.claude/hooks/` under **every** installed `drm-copilot`-identity
directory listed in Prerequisites, not only the one believed most likely to be active. The research
recommends checking all discovered directories because a second, differently-identified extension
(`undefined_publisher.drm-copilot`) coexists on this machine and declares the same MCP provider ID,
so gating on a single directory risks masking a stale serve path (research `## Q1`, "Executor
action required"; `## Rejected alternatives`).

Example shape (substitute the concrete literal selected under Q3):

```
grep -r "<selected-literal>" \
  "C:/Users/DanMoisan/.vscode/extensions/undefined_publisher.drm-copilot-0.0.1/resources/claude-customizations/.claude/hooks/" \
  "C:/Users/DanMoisan/.vscode-insiders/extensions/undefined_publisher.drm-copilot-0.0.1/resources/claude-customizations/.claude/hooks/" \
  "C:/Users/DanMoisan/.vscode-insiders/extensions/danmoisan.drm-copilot-1.1.10/resources/claude-customizations/.claude/hooks/" \
  "C:/Users/DanMoisan/.vscode-insiders/extensions/danmoisan.drm-copilot-1.1.11/resources/claude-customizations/.claude/hooks/"
```

- **PASS**: the literal is found in the directory corresponding to the version the active window's
  extension actually loaded (confirmable via VS Code's own "Help > About" or Extensions view, or
  `code-insiders --list-extensions --show-versions` if available to the executor). A PASS here is
  what confirms the reload took effect — not the install command's exit code, and not the mere
  presence of the literal on disk in an installed directory that the running window has not yet
  activated.
- **FAIL**: the literal is absent from the directory the active window loaded, or the operator
  cannot determine which directory the active window loaded. Either condition means the reload has
  not yet taken effect (or cannot yet be confirmed to have taken effect) and the plan must not
  proceed to the manifest-registration check or the push-down call. Repeat step 3 or step 4 of the
  Step-by-step Instructions and re-run the grep.

Note on the underlying mechanism: the claim that reloading the window causes VS Code to
re-activate the extension and spawn a fresh MCP server process is stated in the research as an
**architectural inference** — grounded in the extension's own source (no self-fire path exists on
`mcpDidChangeEmitter`, verified by grep across `extensions/drm-copilot/src/`) plus documented VS
Code extension-host lifecycle behavior — not as an independently observed install-then-reload
cycle. This runbook carries that same distinction forward: the grep in this section is the
verification of record precisely because the underlying mechanism was not directly observed in the
research session.

## What to Write Back (Evidence)

Record the reload verification as an evidence artifact at:

```
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/evidence/other/reload-vscode-window.<yyyy-MM-ddTHH-mm>.md
```

per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (canonical `<FEATURE>/evidence/other/`
location; paths under `artifacts/baselines/`, `artifacts/qa/`, and `artifacts/evidence/` are
forbidden). The artifact must include:

- `Timestamp: <ISO-8601, yyyy-MM-ddTHH-mm>`
- `Command: <the exact grep command run, per the Verification section above>`
- `EXIT_CODE: <int>`
- `Output Summary: <the grep's literal output, and which of the four installed directories the
  literal was found in>`

If the artifact makes a negative claim (for example, "the old literal is absent from the
directory the active window loaded"), it must also record:

- `SearchScope:` the exact directories searched (all four listed in Prerequisites, unless the
  operator has independently confirmed which single directory the active window loaded and
  restricted the search accordingly — state which case applies)
- `SearchPatterns:` the exact literal and grep invocation used
- `SearchResult:` what was found in each searched directory, or `none`

## Source and Citation

- `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/research/2026-09-13T22-15-taskmaster-push-down-and-resume-research.md`
  — sections `## Q1 — The verification trap`, `## Automation Feasibility` (including
  "Restart/reload requirement", "HI-2 RESOLUTION: exception", and "Environment/tool-constraint
  summary"), `## Candidate approaches (reload-verification mechanism)`, and
  `## Q6 — Ordering constraints for the plan` — repository-internal source, captured 2026-09-13.
  This document also records, and this runbook preserves, the research's own distinction between
  verified code-reading claims and the architectural inference about VS Code's extension-host
  reactivation behavior.
- `docs/features/epics/worktree-scoped-state-resolution/epic.md` — epic manifest naming F7 and its
  dependency set — repository-internal source, captured 2026-09-13.
- `docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/issue.md` — sections
  `## Proposed Behavior`, `## The verification trap`, and `## Human-interaction assessments
  (autonomous-execution mandate)` (HI-2 record) — repository-internal source, captured 2026-09-13.
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — evidence path and timestamp
  format conventions applied in the "What to Write Back" section above — repository-internal
  source, captured 2026-09-13.

This runbook's step-by-step instructions describe VS Code's own Command Palette action
("Developer: Reload Window") rather than a third-party vendor UI outside this repository's
tooling chain. No MCP documentation-retrieval tool was available in this repository at authoring
time (repo-wide search found no `mcp__*` documentation-retrieval tool wired as a dependency, per
the research artifact's own tool-constraint note), so no MCP source exists for this step; the
Command Palette action name and its lack of an external-CLI equivalent are drawn directly from the
research artifact's own verified reading of `extensions/drm-copilot/package.json`'s
`contributes.commands` list, not from an external web source.
