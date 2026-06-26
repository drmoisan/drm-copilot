# Spec — Port Python Commands to TypeScript (Epic #240)

- Issue: #240
- Work mode: full
- Authoritative inventory: `research/python-to-typescript-inventory.md`
- Decomposition: `initiative.md`

## User Story

As a user of the drm-copilot extension and the published MCP server, I want every command
to run without a Python interpreter on PATH, so that the tools work on machines that do not
have Python installed.

## Epic Acceptance Criteria

- [ ] AC-E1: Every Python command script invoked by the extension or MCP server has a
      TypeScript equivalent with behavior parity (CLI output, exit codes, file artifacts,
      JSON shapes).
- [ ] AC-E2: TypeScript test coverage for ported modules meets policy (line >= 85%,
      branch >= 75%).
- [ ] AC-E3: `RepoAutomationService` methods invoke in-process TypeScript instead of
      spawning Python; the `"python"` runtime branch and bundled Python resources are
      removed (delivered by F11).
- [ ] AC-E4: No remaining runtime dependency on a `python` interpreter for extension or
      MCP command execution.
- [ ] AC-E5: All CI gates pass on each feature PR.

Per-feature acceptance criteria are tracked in each feature's plan checklist under
`plans/F#-*.plan.md`. The epic ACs above are satisfied incrementally as features merge and
are fully realized at F11.

## Feature F1 — ts-shared-subprocess-and-utility-layer

### Acceptance Criteria (F1)

- [x] AC-F1-1: `prompt-mode-contract.ts` ports `prompt_mode_contract.py` with identical
      normalization, regexes, and error/reason strings.
- [x] AC-F1-2: `json-config.ts` ports `json_config.py` including governed-file iteration
      and parent-exclusion semantics.
- [x] AC-F1-3: `markdown-label-formatter.ts` ports `markdown_label_formatter.py` pure logic
      with `splitlines()`-equivalent behavior.
- [x] AC-F1-4: `subprocess-runner.ts` replicates the `pr_context/git.py` runner: injectable
      interface, UTF-8 decode with U+FFFD replacement, trailing-newline strip, non-zero exit
      throws with the parity message format.
- [x] AC-F1-5: `file-system.ts` provides an injectable `FileSystem` interface and
      `RealFileSystem` so consumers can unit-test hermetically.
- [x] AC-F1-6: New `src/lib/**` files covered by Jest tests; line >= 85%, branch >= 75%.
- [x] AC-F1-7: Format, lint, type-check, and test all pass from `extensions/drm-copilot/`.
- [x] AC-F1-8: No changes to `RepoAutomationService` or `command-runtime.ts` in F1.
- [x] AC-F1-9: No file exceeds 500 lines; tests are hermetic (no real subprocess/temp files).

## Decisions / Accepted Divergences

- D1 (R2 from F1 review): The `extensions/drm-copilot` package uses Jest (`ts-jest`,
  `run-jest.cjs`), while `.claude/rules/typescript.md` text mentions Vitest. This is a
  pre-existing, package-wide condition not introduced by this epic. The actual runnable and
  CI-exercised toolchain is Jest. Ported tests follow the real Jest toolchain to keep CI
  green. Changing the policy rule is out of scope for this epic and would require a separate
  policy decision; `.claude/rules/**` is not modified here.
