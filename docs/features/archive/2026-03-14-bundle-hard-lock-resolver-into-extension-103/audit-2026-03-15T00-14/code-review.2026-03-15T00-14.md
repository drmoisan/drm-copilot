# Code Review — bundle-hard-lock-resolver-into-extension (#103)

## Executive summary

This feature adds a new extension command, bundles the hard-lock resolver plus prompt templates into the extension payload, and introduces a `--template-root` seam so the same Python resolver can run in non-repo workspaces. The architecture is directionally strong: TypeScript stays thin, bundled resources mirror root sources, coverage thresholds are met, and both the repo and extension quality loops pass.

The branch is **No-Go for PR readiness** today because the new wrapper masks resolver failures by always returning exit code `0`. That breaks the extension runtime contract in `command-runtime.ts`, which depends on subprocess exit codes to distinguish success from failure. Two additional review risks remain: one new Python test file exceeds the repo's 500-line cap, and there is no regression test that proves the wrapper propagates non-zero process exit status.

### Top 3 risks

1. **Blocker:** bundled wrapper reports success for real failures.
2. **Major:** new Python test module exceeds the repo's 500-line limit.
3. **Major:** tests miss the process-level failure-propagation seam that caused the blocker.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` | `:58-60` | The wrapper imports the bundled resolver, calls `module.main`, then unconditionally `return 0`. That discards the resolver's `main() -> int` result, so missing target/template failures still produce a successful process exit for the extension host. | Return the delegated integer result directly, or raise `SystemExit(module.main())`, and add a regression test that asserts a non-zero wrapper exit on missing target/template failures. | `executeBundledScript()` in `extensions/drm-copilot/src/command-runtime.ts` treats only non-zero exits as command failures. Masking the exit code causes misleading success output and violates the acceptance criterion for clear failures. | `grep`: wrapper lines 58/60; bundled resolver `main() -> int` at `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py:276`; direct probe printed `Error: Target file not found ...` then `WRAPPER_EXIT=0`. |
| Major | `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` | whole file | The new Python wrapper/bundled-resolver test file is 536 lines long. | Split the file into focused parts (for example wrapper-behavior vs bundled-resolver behavior) so every file stays under 500 lines. | Repo policy explicitly applies the 500-line limit to production code, test code, and reusable scripts. | Audit line-count probe: `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py=536`. |
| Major | `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py`, `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` | scenario coverage gap | The test suites validate stderr content and missing-runtime behavior, but they do not verify that the wrapper subprocess itself exits non-zero when the delegated resolver fails. | Add one focused regression that executes the wrapper through its real process boundary (or asserts delegated exit-code forwarding directly) for a missing-target or missing-template case. | Without a process-level assertion, the branch can pass unit tests while the extension still reports success on failure. | Current tests cover registration, argv wiring, template-root injection, missing runtime, and resolver branch behavior; none assert wrapper subprocess exit propagation. |

## Typed Python audit

- **No new `Any` without justification:** Mostly pass. The resolver continues to use targeted, policy-authorized untyped import handling for `pyperclip`.
- **No type-check weakening:** Pass. `pyright` is clean and no new broad ignores/config weakening were introduced.
- **Prefer precise types:** **Partial.** The wrapper currently uses `cast(Callable[[], None], module.main)`, but the delegated function contract is `main() -> int`. This is both imprecise typing and a correctness bug.
- **Use `Protocol` / `TypedDict` / `dataclass(slots=True)` appropriately:** N/A for this slice; the feature is command wiring and CLI helpers, not new domain models.
- **Error handling typed:** **Fail at wrapper boundary.** The delegated CLI exposes typed integer exit status, but the wrapper drops it.
- **Logging:** Acceptable. Python stdout/stderr are part of the CLI contract; TypeScript output-channel logging remains in the runtime layer.
- **Public API clarity:** Pass. The new seam is additive (`--template-root`) and documented in spec/docs.

## Test quality audit

- **Deterministic / isolated / fast:** Pass. Current runs were fast and used local mocks/fixtures only.
- **Readable failures:** Pass. Tests assert specific human-facing messages such as `Target file not found` and `Checked locations`.
- **Coverage expectation:** Pass numerically. Python new-code coverage is 92%; TypeScript new-code coverage is 91.34%.
- **Gap:** The missing process-exit regression is a quality hole large enough to let a blocker through.

## Security and correctness

- **Secrets:** No secrets or credential material found in the reviewed diff.
- **Subprocess safety:** Resolver clipboard subprocesses still validate executables with `shutil.which()` before launch; this remains aligned with the repo's pre-authorized suppression pattern.
- **Input validation at boundaries:** Partial. Runtime existence checks are good, but the wrapper/extension boundary currently does not preserve failure semantics.

## Recommendation

**No-Go / Needs revision before PR**

The design is solid, but the feature is not ready to open or merge as a PR until the wrapper returns the delegated exit code, the missing regression test is added, and the oversized Python test file is split under the repo's 500-line limit.
