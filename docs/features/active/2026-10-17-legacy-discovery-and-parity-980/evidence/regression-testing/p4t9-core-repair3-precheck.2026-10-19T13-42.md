# p4t9-core-repair3 precheck

Timestamp: 2026-10-19T13-42

Command: .\.venv\Scripts\python.exe -m pytest -o addopts= tests/discovery_runtime/test_extension_validation_limits.py::test_capture_index_count_is_bounded_before_projection tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation -v --tb=short

EXIT_CODE: 0

Output Summary: Scoped precheck; elapsed 1.717 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 20 items

tests/discovery_runtime/test_extension_validation_limits.py::test_capture_index_count_is_bounded_before_projection PASSED [  5%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[zero-exact] PASSED [ 10%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[zero-short] PASSED [ 15%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[single-exact] PASSED [ 20%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[power-exact] PASSED [ 25%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[power-short] PASSED [ 30%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[negative-exact] PASSED [ 35%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[negative-short] PASSED [ 40%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[negative-power-exact] PASSED [ 45%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[negative-power-short] PASSED [ 50%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[review-small-overflow] PASSED [ 55%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[below-power-exact] PASSED [ 60%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[power-width-overflow] PASSED [ 65%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[review-large-overflow] PASSED [ 70%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[negative-large-overflow] PASSED [ 75%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[review-large-exact] PASSED [ 80%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[negative-large-exact] PASSED [ 85%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[beyond-rendering-ceiling] PASSED [ 90%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[remaining-exact] PASSED [ 95%]
tests/discovery_runtime/test_extension_validation_limits.py::test_integer_budget_never_renders_before_reservation[remaining-short] PASSED [100%]

============================= 20 passed in 1.32s ==============================
```
