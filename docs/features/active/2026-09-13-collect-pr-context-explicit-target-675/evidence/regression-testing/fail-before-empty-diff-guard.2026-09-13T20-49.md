Timestamp: 2026-09-17T13:35Z
Command: node run-jest.cjs test/lib/pr-context/pr-context-service-call-target.test.ts (from extensions/drm-copilot/, run before the empty-diff guard was wired into pr-context-service-call.ts)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 3 passed, 3 failed, 6 total. The three tests that require a raise all failed with "Received function did not throw", because no code path yet distinguishes an empty/unresolved result from a populated one:
- `raises naming the resolved head ref, head sha, merge base and base when the refs resolve and no file changed`
- `raises naming the requested base when the base or head could not be resolved`
- `writes both artifacts and then raises when the diff is empty`

The three tests that assert argv/provenance only (not the guard) passed: `passes the explicit target ref to git rather than the session HEAD`, `reports target_resolution explicit and the resolved head ref and sha when a target ref is supplied`, `reports target_resolution session-fallback when no target ref is supplied`.
