# P5-T2 graph counted-controls

Timestamp: 2026-10-20T07-04

Command: `poetry run pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 3.131 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 3 items

tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[8] FAILED [ 33%]
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[32] FAILED [ 66%]
tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[64] FAILED [100%]

================================== FAILURES ===================================
_________ test_custom_mode_membership_has_prospective_linear_work[8] __________
tests\discovery_runtime\test_parity_axes.py:227: in test_custom_mode_membership_has_prospective_linear_work
    assert modes.visits == size and modes.comparisons == 0
E   AssertionError: assert (0 == 8)
E    +  where 0 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007').visits
_________ test_custom_mode_membership_has_prospective_linear_work[32] _________
tests\discovery_runtime\test_parity_axes.py:227: in test_custom_mode_membership_has_prospective_linear_work
    assert modes.visits == size and modes.comparisons == 0
E   AssertionError: assert (0 == 32)
E    +  where 0 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007', 'custom-008', 'custom-009', 'custom-010', 'custom-011', 'custom-012', 'custom-013', 'custom-014', 'custom-015', 'custom-016', 'custom-017', 'custom-018', 'custom-019', 'custom-020', 'custom-021', 'custom-022', 'custom-023', 'custom-024', 'custom-025', 'custom-026', 'custom-027', 'custom-028', 'custom-029', 'custom-030', 'custom-031').visits
_________ test_custom_mode_membership_has_prospective_linear_work[64] _________
tests\discovery_runtime\test_parity_axes.py:227: in test_custom_mode_membership_has_prospective_linear_work
    assert modes.visits == size and modes.comparisons == 0
E   AssertionError: assert (0 == 64)
E    +  where 0 = ('custom-000', 'custom-001', 'custom-002', 'custom-003', 'custom-004', 'custom-005', 'custom-006', 'custom-007', 'custom-008', 'custom-009', 'custom-010', 'custom-011', 'custom-012', 'custom-013', 'custom-014', 'custom-015', 'custom-016', 'custom-017', 'custom-018', 'custom-019', 'custom-020', 'custom-021', 'custom-022', 'custom-023', 'custom-024', 'custom-025', 'custom-026', 'custom-027', 'custom-028', 'custom-029', 'custom-030', 'custom-031', 'custom-032', 'custom-033', 'custom-034', 'custom-035', 'custom-036', 'custom-037', 'custom-038', 'custom-039', 'custom-040', 'custom-041', 'custom-042', 'custom-043', 'custom-044', 'custom-045', 'custom-046', 'custom-047', 'custom-048', 'custom-049', 'custom-050', 'custom-051', 'custom-052', 'custom-053', 'custom-054', 'custom-055', 'custom-056', 'custom-057', 'custom-058', 'custom-059', 'custom-060', 'custom-061', 'custom-062', 'custom-063').visits
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[8]
FAILED tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[32]
FAILED tests/discovery_runtime/test_parity_axes.py::test_custom_mode_membership_has_prospective_linear_work[64]
============================== 3 failed in 1.62s ==============================
```
