# F5 Behavior-Parity Capture

Timestamp: 2026-06-26T01-43
Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (run from extensions/drm-copilot/)
EXIT_CODE: 0

Output Summary: 60 suites / 698 tests passed. Each parity property below maps to a passing test.

## Parity checks confirmed (bundled Python -> in-process TS)

Hard-lock (`resolve_hard_lock_prompt.py` bundled variant):
- `${plan-path}`/`${work-mode}`/`${fallback-reason}` substitution
  -> hard-lock-prompt.test.ts "substitutes plan-path, work-mode, and fallback-reason"
- Nearest-issue.md resolution including `v*` parent fallback
  -> hard-lock-prompt.test.ts "uses the parent issue.md for a versioned v* plan dir"
- Fail-closed when issue.md missing
  -> hard-lock-prompt.test.ts "returns the direct issue candidate when no file exists";
     file-prompt-variables.test.ts "fails closed to full-feature when issue.md is missing"
- Template selection (execute/resume) and probe order (templateRoot first, then workspace .github/codex)
  -> hard-lock-prompt.test.ts "maps execute and resume template kinds",
     "probes the template root first then the workspace fallback"
- Template-not-found message and exit 1
  -> hard-lock-prompt.test.ts "emits a not-found message and exitCode 1 when the template is missing"
- `--quiet`/`--output` semantics: quiet-requires-output guard at BOTH layers
  -> service-layer message: repo-automation-hard-lock-prompt.test.ts "rejects quiet without output at the TS layer ...";
     resolve-prompts-service-call.test.ts "throws the verbatim guard message for quiet without output";
     command-level message: hard-lock-prompt.test.ts "returns the quiet-requires-output error path at the command level"
- Output file write via injected FileSystem (relative resolves against workspace; absolute verbatim)
  -> hard-lock-prompt.test.ts "writes the resolved prompt to a relative output path ...",
     "writes an absolute output path verbatim";
     repo-automation-hard-lock-prompt.test.ts "with output ... writes the resolved prompt",
     "with an absolute output path uses it directly in artifacts"
- No clipboard on the quiet path
  -> hard-lock-prompt.test.ts "returns exitCode 0 with no clipboard or stdout emission on the quiet path"
- Clipboard success/failure stderr lines
  -> hard-lock-prompt.test.ts "emits resolved content then the clipboard-success line ..." (✓ Copied to clipboard),
     "emits the clipboard-failure line when no supported mechanism is found"
     (✗ Could not copy to clipboard (no supported mechanism found))

File-prompt / atomic-plan (`resolve_file_prompt.py` bundled variant):
- Variable set ${file}/${folderpath}/${name}/${spec}/${user-story}/${research}/${work-mode}/${fallback-reason}
  -> file-prompt-variables.test.ts path/foldername/name/spec/user-story/research tests;
     file-prompt-core.test.ts "produces a fully resolved prompt with no remaining placeholders"
- Front-matter stripping
  -> file-prompt-variables.test.ts "removes a leading YAML front-matter block",
     "passes through content without front matter unchanged"
- Minor-audit overrides (line removal + three-phase block)
  -> file-prompt-variables.test.ts "injects the minor-audit override block after Core Requirements";
     file-prompt-core.test.ts "applies minor-audit overrides only on the minor-audit path"
- User-story `(missing)` annotation + clause removal
  -> file-prompt-variables.test.ts "annotates ${user-story} as missing when the file is absent",
     "removes the user-story clause when missing"
- Research line removal when missing
  -> file-prompt-variables.test.ts "returns null for ${research} when research.md is missing",
     "removes lines referencing a variable while preserving other line endings"
- replaceAllVariables unresolved-variable error and post-substitution safety check
  -> file-prompt-variables.test.ts "raises on unresolved variables in replaceAllVariables",
     "raises when a substitution value reintroduces a placeholder"
- Atomic-plan command shell (Successfully resolved ... vs Could not copy to clipboard; printing resolved prompt to stdout., exit 0)
  -> file-prompt-core.test.ts "emits the clipboard-success line then the content ...",
     "emits the clipboard-failure line then the content ...",
     "uses the failure branch when no clipboard callback is provided"
- Template/target not-found and Error processing prompt (exit 1)
  -> file-prompt-core.test.ts "returns exitCode 1 with a template-not-found message",
     "returns exitCode 1 with a target-not-found message",
     "returns exitCode 1 with Error processing prompt when resolution throws"

Service return contracts:
- Hard-lock: { tool, workspaceRoot, summary, artifacts }
  -> resolve-prompts-service-call.test.ts "returns the artifact and writes the resolved prompt for a relative output",
     "uses an absolute output verbatim in artifacts";
     repo-automation-hard-lock-prompt.test.ts artifact assertions
- Atomic-plan: { tool, workspaceRoot, summary } with no artifacts
  -> resolve-prompts-service-call.test.ts "returns the preserved record with no artifacts and emits resolved content";
     repo-automation-service.resolve-atomic-plan-prompt.test.ts "resolves the prompt in-process and emits the resolved content"

## Extension tests reworked (P2-T3..P2-T6)

- test/repo-automation-hard-lock-prompt.test.ts — Python-spawn assertions replaced with in-process result + injected-FileSystem write assertions; quiet-guard preserved.
- test/repo-automation-service.resolve-atomic-plan-prompt.test.ts — Python-spawn/stderr assertions replaced with in-process result + thrown-error-on-failure assertions.
- test/extension.resolve-hard-lock-prompt.test.ts — editor/picker/eligibility/cancellation preserved; spawn-arg assertions replaced with in-process assertions; node:fs mock extended (statSync/readFileSync/writeFileSync/mkdirSync).
- test/extension.resolve-atomic-plan-prompt.test.ts — same approach; spec.md rejection preserved.

Removed test cases with rationale:
- "surfaces a missing python runtime error for resolveExecuteHardLockPrompt" and the atomic-plan equivalent were converted to "completes via the in-process path without probing a Python runtime". Rationale: the in-process path performs no Python runtime probe for these two commands, so the original Python-runtime-error assertion is no longer reachable on this code path. Eligibility/picker behavior is otherwise unchanged.

No Python-spawn assertion remains for resolve_execute_hard_lock_prompt or resolve_atomic_plan_prompt. Tool-registration/dispatch/handler-input-resolution tests in mcp-server.test.ts remain unchanged and pass.
