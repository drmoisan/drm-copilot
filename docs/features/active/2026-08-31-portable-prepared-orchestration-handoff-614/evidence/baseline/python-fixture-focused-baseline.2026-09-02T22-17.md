# Python Fixture Focused Baseline

Timestamp: 2026-09-03T02-52
Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py -k fixture_hashes_and_source_history_are_pinned --no-cov -q`
ExpectedExitCode: 1
EXIT_CODE: 1

Output Summary: Expected failure reproduced exactly: the two bidirectional plan-hash assertions failed, with expected raw SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f` and actual raw SHA-256 `089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864`. Pytest reported `2 failed, 54 deselected`; no other test failed.

```text
FF                                                                       [100%]
================================== FAILURES ===================================
_ test_taskmaster_469_fixture_hashes_and_source_history_are_pinned[claude-to-codex] _

case = FixtureCase(name='claude-to-codex', source_provider='claude', destination_provider='codex', adapter_id='claude-to-codex-v1', adapter=ClaudeToCodexAdapter())

    @pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
    def test_taskmaster_469_fixture_hashes_and_source_history_are_pinned(
        case: FixtureCase,
    ) -> None:
        """Fixture bytes match metadata and contain no destination-provider receipt."""

        fixture = load_fixture(case)
        source = mapping(fixture["source_checkpoint"], "source_checkpoint")
        plan = mapping(fixture["plan"], "plan")
        source_bytes, plan_bytes = fixture_bytes(case, fixture)

        assert hashlib.sha256(source_bytes).hexdigest() == source["sha256"]
>       assert hashlib.sha256(plan_bytes).hexdigest() == plan["sha256"]
E       AssertionError: assert '089467fcb70e...48558b3927864' == '54c9718097de...ac80ea3c9ba2f'
E
E         - 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f
E         + 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864

tests\scripts\dev_tools\test_orchestration_handoff_taskmaster_469.py:77: AssertionError
_ test_taskmaster_469_fixture_hashes_and_source_history_are_pinned[codex-to-claude] _

case = FixtureCase(name='codex-to-claude', source_provider='codex', destination_provider='claude', adapter_id='codex-to-claude-v1', adapter=CodexToClaudeAdapter())

    @pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
    def test_taskmaster_469_fixture_hashes_and_source_history_are_pinned(
        case: FixtureCase,
    ) -> None:
        """Fixture bytes match metadata and contain no destination-provider receipt."""

        fixture = load_fixture(case)
        source = mapping(fixture["source_checkpoint"], "source_checkpoint")
        plan = mapping(fixture["plan"], "plan")
        source_bytes, plan_bytes = fixture_bytes(case, fixture)

        assert hashlib.sha256(source_bytes).hexdigest() == source["sha256"]
>       assert hashlib.sha256(plan_bytes).hexdigest() == plan["sha256"]
E       AssertionError: assert '089467fcb70e...48558b3927864' == '54c9718097de...ac80ea3c9ba2f'
E
E         - 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f
E         + 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864

tests\scripts\dev_tools\test_orchestration_handoff_taskmaster_469.py:77: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py::test_taskmaster_469_fixture_hashes_and_source_history_are_pinned[claude-to-codex]
FAILED tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py::test_taskmaster_469_fixture_hashes_and_source_history_are_pinned[codex-to-claude]
2 failed, 54 deselected in 0.09s
```

Post-command verification: `git diff --quiet HEAD -- <both plan fixture paths>` returned `0`, and `Get-FileHash -Algorithm SHA256` returned `089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864` for both files. No hook, helper, setup command, or test rewrote fixture bytes before or during the run.
