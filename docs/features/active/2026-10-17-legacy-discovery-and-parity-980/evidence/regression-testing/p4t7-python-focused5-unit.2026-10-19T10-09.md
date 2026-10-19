# p4t7-python-focused5-unit

Timestamp: 2026-10-19T10-09
Command: poetry run pytest tests/discovery_runtime/analyzer/test_dependency_python.py -o addopts= -v --cov=drm_copilot_discovery.analyzer.dependency_python --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t7-python-coverage.json
EXIT_CODE: 0
Output Summary: scoped unit; duration 2.674 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 98 items

tests/discovery_runtime/analyzer/test_dependency_python.py::test_safe_names_remain_unresolved_declarations[package] PASSED [  1%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_safe_names_remain_unresolved_declarations[gitpython] PASSED [  2%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_safe_names_remain_unresolved_declarations[foo-bar] PASSED [  3%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_safe_names_remain_unresolved_declarations[A.b_c] PASSED [  4%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_safe_names_remain_unresolved_declarations[xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx] PASSED [  5%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[==1.2] PASSED [  6%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[>=1.0,<2] PASSED [  7%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[~=3.1] PASSED [  8%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[!=1.*] PASSED [  9%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[<=3] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[>2] PASSED [ 11%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[==1.0+cpu] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_supported_constraints_retain_literal_spelling[==1.0-rc1] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_extras_conditions_and_comments_are_sanitized PASSED [ 14%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_finite_marker_operators_never_evaluate_values[extra in 'SECRET'] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_finite_marker_operators_never_evaluate_values[sys_platform not in 'SECRET'] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_finite_marker_operators_never_evaluate_values[os_name == 'SECRET"VALUE'] PASSED [ 17%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_finite_marker_operators_never_evaluate_values[python_version == 'a' or os_name == 'b'] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-https://user:SECRET@example.invalid/a#SECRET-url] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-git+https://example.invalid/SECRET-vcs] PASSED [ 20%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-hg+ssh://SECRET-vcs] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-git@host:SECRET-vcs] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-file:SECRET-local] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-../SECRET-local] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-/SECRET-local] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-C:\\SECRET-local] PASSED [ 26%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[False-\\\\host\\SECRET-local] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-https://user:SECRET@example.invalid/a#SECRET-url] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-git+https://example.invalid/SECRET-vcs] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-hg+ssh://SECRET-vcs] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-git@host:SECRET-vcs] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-file:SECRET-local] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-../SECRET-local] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-/SECRET-local] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-C:\\SECRET-local] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-\\\\host\\SECRET-local] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_physical_lines_and_bom_have_stable_anchors[\n] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_physical_lines_and_bom_have_stable_anchors[\r] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_physical_lines_and_bom_have_stable_anchors[\r\n] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[\n] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[  # comment\n\r\n] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[   ] PASSED [ 43%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[-r SECRET-dependency-unsupported] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[-c SECRET-dependency-unsupported] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[-e SECRET-dependency-unsupported] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[--index-url SECRET-dependency-unsupported] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg --hash=SECRET-dependency-unsupported] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg \\-dependency-unsupported] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[attr:SECRET-dependency-unsupported] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg @ SECRET-dependency-unsupported] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg===SECRET-dependency-unsupported] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg==11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111-dependency-unsupported] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg==1,,,,-dependency-unsupported] PASSED [ 55%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg[]-dependency-malformed] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg[a,]-dependency-malformed] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg[SECRET/path]-dependency-malformed] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[$SECRET-dependency-malformed] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-dependency-malformed] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg;-dependency-malformed] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; unknown == 'SECRET'-dependency-unsupported] PASSED [ 62%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; python_version == SECRET-dependency-unsupported] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; python_version == 'SECRET' and-dependency-unsupported] PASSED [ 64%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; (os_name == 'SECRET')-dependency-unsupported] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; os_name == 'SECRET' trailing-dependency-unsupported] PASSED [ 66%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg\u2028SECRET-dependency-unsupported] PASSED [ 67%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_selected_lists_preserve_physical_anchors PASSED [ 68%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_nonselected_continuations_cannot_become_options PASSED [ 69%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[DEFAULT]\nsecret = SECRET\n[options]\ninstall_requires = pkg-dependency-ambiguous] PASSED [ 70%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[DEFAULT]\n[options]\ninstall_requires = pkg-dependency-ambiguous] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[ [options]\ninstall_requires = pkg-dependency-ambiguous] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options] # SECRET\ninstall_requires = pkg-dependency-unsupported] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = a\nINSTALL_REQUIRES = SECRET-dependency-malformed] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\n[options]\n-dependency-malformed] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[install_requires = SECRET-dependency-malformed] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = file: SECRET-dependency-unsupported] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = attr: SECRET-dependency-unsupported] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = %(SECRET)s-dependency-malformed] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options.extras_require]\nunsafe:SECRET = pkg-dependency-unsupported] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = pkg\n\n    other-dependency-malformed] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_invalid_encoding_has_a_fixed_error[\xff] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_invalid_encoding_has_a_fixed_error[pkg\x00SECRET] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_line_endings_keep_physical_lines[\n] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_line_endings_keep_physical_lines[\r\n] PASSED [ 85%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_line_endings_keep_physical_lines[\r] PASSED [ 86%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_bytes-requirements] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_bytes-setup-cfg] PASSED [ 88%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_lines-requirements] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_lines-setup-cfg] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_nodes-requirements] PASSED [ 91%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_nodes-setup-cfg] PASSED [ 92%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_text_bytes-requirements] PASSED [ 93%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_text_bytes-setup-cfg] PASSED [ 94%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_candidates-requirements] PASSED [ 95%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_resource_exhaustion_discards_complete_population[max_candidates-setup-cfg] PASSED [ 96%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_exact_work_and_retention_budgets_are_deterministic[requirements] PASSED [ 97%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_exact_work_and_retention_budgets_are_deterministic[setup-cfg] PASSED [ 98%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_selector_is_a_fixed_caller_error PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                 Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_python.py     154      0     86      0   100%
--------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                  154      0     86      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t7-python-coverage.json
============================= 98 passed in 0.45s ==============================
```
