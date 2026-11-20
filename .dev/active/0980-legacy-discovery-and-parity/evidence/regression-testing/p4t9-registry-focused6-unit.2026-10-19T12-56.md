# p4t9-registry-focused6-unit

Timestamp: 2026-10-19T12-56
Command: poetry run pytest tests/discovery_runtime/analyzer/test_registry.py tests/discovery_runtime/analyzer/test_registry_dispatch.py tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py -o addopts= -v --cov=drm_copilot_discovery.analyzer --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage.json
EXIT_CODE: 1
Output Summary: scoped unit; duration 26.234 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 77 items

tests/discovery_runtime/analyzer/test_registry.py::test_registry_loads_only_explicit_core_adapters PASSED [  1%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_rejects_unavailable_selections_without_fallback[enabled0] PASSED [  2%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_selects_only_consented_fixed_optional_adapter[enabled0] PASSED [  3%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_selects_only_consented_fixed_optional_adapter[enabled1] PASSED [  5%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_selects_only_consented_fixed_optional_adapter[enabled2] PASSED [  6%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_rejects_wrong_profile_type PASSED [  7%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_requires_configured_consent_before_any_import PASSED [  9%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[bad-None-None] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[inspected-None-None] PASSED [ 11%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[inspected-Not allowed-file2] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[excluded-None-None] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[unreadable- -None] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[excluded-Excluded-file5] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_registry.py::test_models_reject_untyped_rows_profile_inputs_and_collisions PASSED [ 18%]
tests/discovery_runtime/analyzer/test_registry.py::test_draft_and_input_count_limits_fail_closed PASSED [ 19%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_public_metadata_is_complete_fresh_and_import_free PASSED [ 20%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[com-interop] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[configuration] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[csharp-symbols] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[dependencies] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[dotnet] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[event-subscriptions] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[filesystem-access] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[office-vsto] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[registry-access] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[repository] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[test-references] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[ui-callbacks] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_invalid_complete_selection_never_imports_optional[unknown] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_invalid_complete_selection_never_imports_optional[module.path] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_invalid_complete_selection_never_imports_optional[python -c command] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_registry_checks_complete_metadata_before_optional_loading

============================= 31 passed in 24.42s =============================

Traceback (most recent call last):
  File ".\.venv\Lib\site-packages\_pytest\main.py", line 318, in wrap_session
    session.exitstatus = doit(config, session) or 0
                         ~~~~^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\main.py", line 372, in _main
    config.hook.pytest_runtestloop(session=session)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_hooks.py", line 512, in __call__
    return self._hookexec(self.name, self._hookimpls.copy(), kwargs, firstresult)
           ~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_manager.py", line 120, in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
           ~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 167, in _multicall
    raise exception
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\logging.py", line 801, in pytest_runtestloop
    return (yield)  # Run all the tests.
            ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\terminal.py", line 707, in pytest_runtestloop
    result = yield
             ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pytest_cov\plugin.py", line 345, in pytest_runtestloop
    result = yield
             ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 121, in _multicall
    res = hook_impl.function(*args)
  File ".\.venv\Lib\site-packages\_pytest\main.py", line 396, in pytest_runtestloop
    item.config.hook.pytest_runtest_protocol(item=item, nextitem=nextitem)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_hooks.py", line 512, in __call__
    return self._hookexec(self.name, self._hookimpls.copy(), kwargs, firstresult)
           ~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_manager.py", line 120, in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
           ~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 167, in _multicall
    raise exception
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\warnings.py", line 89, in pytest_runtest_protocol
    return (yield)
            ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\assertion\__init__.py", line 192, in pytest_runtest_protocol
    return (yield)
            ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\unittest.py", line 587, in pytest_runtest_protocol
    return (yield)
            ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\faulthandler.py", line 102, in pytest_runtest_protocol
    return (yield)
            ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 121, in _multicall
    res = hook_impl.function(*args)
  File ".\.venv\Lib\site-packages\_pytest\runner.py", line 118, in pytest_runtest_protocol
    runtestprotocol(item, nextitem=nextitem)
    ~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\runner.py", line 137, in runtestprotocol
    reports.append(call_and_report(item, "call", log))
                   ~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\runner.py", line 249, in call_and_report
    report: TestReport = ihook.pytest_runtest_makereport(item=item, call=call)
                         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_hooks.py", line 512, in __call__
    return self._hookexec(self.name, self._hookimpls.copy(), kwargs, firstresult)
           ~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_manager.py", line 120, in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
           ~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 167, in _multicall
    raise exception
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\tmpdir.py", line 311, in pytest_runtest_makereport
    rep = yield
          ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 139, in _multicall
    teardown.throw(exception)
    ~~~~~~~~~~~~~~^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\skipping.py", line 280, in pytest_runtest_makereport
    rep = yield
          ^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 121, in _multicall
    res = hook_impl.function(*args)
  File ".\.venv\Lib\site-packages\_pytest\runner.py", line 377, in pytest_runtest_makereport
    return TestReport.from_item_and_call(item, call)
           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\reports.py", line 438, in from_item_and_call
    longrepr = _format_failed_longrepr(item, call, excinfo)
  File ".\.venv\Lib\site-packages\_pytest\reports.py", line 263, in _format_failed_longrepr
    longrepr = item.repr_failure(excinfo)
  File ".\.venv\Lib\site-packages\_pytest\python.py", line 1762, in repr_failure
    return self._repr_failure_py(excinfo, style=style)
           ~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\nodes.py", line 413, in _repr_failure_py
    from _pytest.fixtures import FixtureLookupError
  File ".\tests\discovery_runtime\analyzer\test_registry_dispatch.py", line 269, in forbidden
    raise AssertionError("Invalid complete selection must not import")
AssertionError: Invalid complete selection must not import

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "<frozen runpy>", line 198, in _run_module_as_main
  File "<frozen runpy>", line 88, in _run_code
  File ".\.venv\Scripts\pytest.exe\__main__.py", line 7, in <module>
    sys.exit(console_main())
             ~~~~~~~~~~~~^^
  File ".\.venv\Lib\site-packages\_pytest\config\__init__.py", line 223, in console_main
    code = main()
  File ".\.venv\Lib\site-packages\_pytest\config\__init__.py", line 199, in main
    ret: ExitCode | int = config.hook.pytest_cmdline_main(config=config)
                          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_hooks.py", line 512, in __call__
    return self._hookexec(self.name, self._hookimpls.copy(), kwargs, firstresult)
           ~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_manager.py", line 120, in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
           ~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 167, in _multicall
    raise exception
  File ".\.venv\Lib\site-packages\pluggy\_callers.py", line 121, in _multicall
    res = hook_impl.function(*args)
  File ".\.venv\Lib\site-packages\_pytest\main.py", line 365, in pytest_cmdline_main
    return wrap_session(config, _main)
  File ".\.venv\Lib\site-packages\_pytest\main.py", line 338, in wrap_session
    config.notify_exception(excinfo, config.option)
    ~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\.venv\Lib\site-packages\_pytest\config\__init__.py", line 1218, in notify_exception
    excrepr = excinfo.getrepr(
        funcargs=True, showlocals=getattr(option, "showlocals", False), style=style
    )
  File ".\.venv\Lib\site-packages\_pytest\_code\code.py", line 746, in getrepr
    format_exception(
    ~~~~~~~~~~~~~~~~^
        self.type,
        ^^^^^^^^^^
        self.value,
        ^^^^^^^^^^^
        self.traceback[0]._rawentry if self.traceback else None,
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    )
    ^
  File "C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\Lib\traceback.py", line 154, in format_exception
    te = TracebackException(type(value), value, tb, limit=limit, compact=True)
  File "C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\Lib\traceback.py", line 1052, in __init__
    self.stack = StackSummary._extract_from_extended_frame_gen(
                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^
        _walk_tb_with_full_positions(exc_traceback),
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        limit=limit, lookup_lines=lookup_lines,
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        capture_locals=capture_locals)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\Lib\traceback.py", line 495, in _extract_from_extended_frame_gen
    linecache.checkcache(filename)
    ~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^
  File "C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\Lib\linecache.py", line 84, in checkcache
    import os
  File ".\tests\discovery_runtime\analyzer\test_registry_dispatch.py", line 269, in forbidden
    raise AssertionError("Invalid complete selection must not import")
AssertionError: Invalid complete selection must not import
```
