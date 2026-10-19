# p4t7-python-focused4-unit

Timestamp: 2026-10-19T10-08
Command: poetry run pytest tests/discovery_runtime/analyzer/test_dependency_python.py -o addopts= -v --cov=drm_copilot_discovery.analyzer.dependency_python --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t7-python-coverage.json
EXIT_CODE: 1
Output Summary: scoped unit; duration 2.645 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 93 items

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
tests/discovery_runtime/analyzer/test_dependency_python.py::test_extras_conditions_and_comments_are_sanitized PASSED [ 15%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_finite_marker_operators_never_evaluate_values[extra in 'SECRET'] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_finite_marker_operators_never_evaluate_values[sys_platform not in 'SECRET'] PASSED [ 17%]
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
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-https://user:SECRET@example.invalid/a#SECRET-url] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-git+https://example.invalid/SECRET-vcs] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-hg+ssh://SECRET-vcs] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-git@host:SECRET-vcs] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-file:SECRET-local] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-../SECRET-local] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-/SECRET-local] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-C:\\SECRET-local] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_reference_targets_are_classified_and_redacted[True-\\\\host\\SECRET-local] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_physical_lines_and_bom_have_stable_anchors[\n] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_physical_lines_and_bom_have_stable_anchors[\r] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_physical_lines_and_bom_have_stable_anchors[\r\n] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[\n] PASSED [ 43%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[  # comment\n\r\n] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_empty_or_comment_inputs_have_no_candidates[   ] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[-r SECRET-dependency-unsupported] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[-c SECRET-dependency-unsupported] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[-e SECRET-dependency-unsupported] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[--index-url SECRET-dependency-unsupported] PASSED [ 49%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg --hash=SECRET-dependency-unsupported] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg \\-dependency-unsupported] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[attr:SECRET-dependency-unsupported] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg @ SECRET-dependency-unsupported] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg===SECRET-dependency-unsupported] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg==11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111-dependency-unsupported] PASSED [ 55%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg==1,,,,-dependency-unsupported] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg[]-dependency-malformed] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg[a,]-dependency-malformed] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg[SECRET/path]-dependency-malformed] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[$SECRET-dependency-malformed] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-dependency-malformed] PASSED [ 62%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg;-dependency-malformed] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; unknown == 'SECRET'-dependency-unsupported] PASSED [ 64%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; python_version == SECRET-dependency-unsupported] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; python_version == 'SECRET' and-dependency-unsupported] PASSED [ 66%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; (os_name == 'SECRET')-dependency-unsupported] PASSED [ 67%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg; os_name == 'SECRET' trailing-dependency-unsupported] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_unsupported_and_malformed_requirements_fail_without_partial_results[pkg\u2028SECRET-dependency-unsupported] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_selected_lists_preserve_physical_anchors PASSED [ 70%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_nonselected_continuations_cannot_become_options PASSED [ 72%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[DEFAULT]\nsecret = SECRET\n[options]\ninstall_requires = pkg-dependency-ambiguous] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[DEFAULT]\n[options]\ninstall_requires = pkg-dependency-ambiguous] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[ [options]\ninstall_requires = pkg-dependency-ambiguous] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = a\nINSTALL_REQUIRES = SECRET-dependency-malformed] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\n[options]\n-dependency-malformed] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[install_requires = SECRET-dependency-malformed] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = file: SECRET-dependency-unsupported] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = attr: SECRET-dependency-unsupported] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = %(SECRET)s-dependency-malformed] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options.extras_require]\nunsafe:SECRET = pkg-dependency-unsupported] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_setup_cfg_rejects_ambiguous_dynamic_or_invalid_structure[[options]\ninstall_requires = pkg\n\n    other-dependency-malformed] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_invalid_encoding_has_a_fixed_error[\xff] FAILED [ 84%]
tests/discovery_runtime/analyzer/test_dependency_python.py::test_invalid_encoding_has_a_fixed_error[pkg\x00SECRET] FAILED [ 86%]
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

================================== FAILURES ===================================
________________ test_invalid_encoding_has_a_fixed_error[\xff] ________________

content = b'\xff'

    @pytest.mark.parametrize("content", [b"\xff", b"pkg\x00SECRET"])
    def test_invalid_encoding_has_a_fixed_error(content: bytes) -> None:
        """Invalid UTF-8 and NUL-containing text never produce dependency results."""
        with pytest.raises(DependencyInputError, match="encoding"):
>           parse_python_dependencies(
                content, format="requirements", limits=DependencyLimits()
            )

tests\discovery_runtime\analyzer\test_dependency_python.py:236:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_python.py:253: in parse_python_dependencies
    text = budget.decode(content)
           ^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.analyzer.dependency_inputs.DependencyBudget object at 0x0000017E2FCB72D0>
content = b'\xff'

    def decode(self, content: bytes) -> str:
        """Return UTF-8 after byte/physical-line checks; raise fixed input errors."""
        if not isinstance(cast("object", content), bytes):
            raise ValueError("Dependency input must be retained bytes")
        self.reserve()
        if len(content) > self.limits.max_bytes:
            self._failed = True
            raise DependencyInputError("dependency-limit")
        lines = (
            content.count(b"\n")
            + content.count(b"\r")
            - content.count(b"\r\n")
            + bool(content and not content.endswith((b"\r", b"\n")))
        )
        if lines > self.limits.max_lines:
            self._failed = True
            raise DependencyInputError("dependency-limit")
        try:
            return content.decode("utf-8-sig")
        except UnicodeDecodeError:
            self._failed = True
>           raise DependencyInputError("dependency-encoding") from None
E           drm_copilot_discovery.analyzer.dependency_inputs.DependencyInputError: Dependency input must use valid UTF-8.

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:379: DependencyInputError

During handling of the above exception, another exception occurred:

content = b'\xff'

    @pytest.mark.parametrize("content", [b"\xff", b"pkg\x00SECRET"])
    def test_invalid_encoding_has_a_fixed_error(content: bytes) -> None:
        """Invalid UTF-8 and NUL-containing text never produce dependency results."""
>       with pytest.raises(DependencyInputError, match="encoding"):
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       AssertionError: Regex pattern did not match.
E         Expected regex: 'encoding'
E         Actual message: 'Dependency input must use valid UTF-8.'

tests\discovery_runtime\analyzer\test_dependency_python.py:235: AssertionError
___________ test_invalid_encoding_has_a_fixed_error[pkg\x00SECRET] ____________

content = b'pkg\x00SECRET'

    @pytest.mark.parametrize("content", [b"\xff", b"pkg\x00SECRET"])
    def test_invalid_encoding_has_a_fixed_error(content: bytes) -> None:
        """Invalid UTF-8 and NUL-containing text never produce dependency results."""
        with pytest.raises(DependencyInputError, match="encoding"):
>           parse_python_dependencies(
                content, format="requirements", limits=DependencyLimits()
            )

tests\discovery_runtime\analyzer\test_dependency_python.py:236:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

content = b'pkg\x00SECRET'

    def parse_python_dependencies(
        content: bytes,
        *,
        format: Literal["requirements", "setup-cfg"],
        limits: DependencyLimits,
    ) -> DependencyResult:
        """Return immutable sanitized Python declarations from captured bytes.

        content (bytes), fixed format and limits select a finite parser. Raises fixed
        DependencyInputError for malformed/unsupported/over-budget input; invalid
        caller format raises ValueError. UTF-8 only; no includes, expansion, package
        loading, marker evaluation, filesystem/process/network access or writes.
        """
        if format not in {"requirements", "setup-cfg"}:
            raise ValueError("Unsupported Python dependency format")
        budget = DependencyBudget(limits)
        text = budget.decode(content)
        # Charge the full scan and transient text before indexing or regex allocation.
        budget.reserve(nodes=len(text) + 1, text_bytes=len(content))
        if "\x00" in text:
>           raise DependencyInputError("dependency-encoding")
E           drm_copilot_discovery.analyzer.dependency_inputs.DependencyInputError: Dependency input must use valid UTF-8.

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_python.py:257: DependencyInputError

During handling of the above exception, another exception occurred:

content = b'pkg\x00SECRET'

    @pytest.mark.parametrize("content", [b"\xff", b"pkg\x00SECRET"])
    def test_invalid_encoding_has_a_fixed_error(content: bytes) -> None:
        """Invalid UTF-8 and NUL-containing text never produce dependency results."""
>       with pytest.raises(DependencyInputError, match="encoding"):
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       AssertionError: Regex pattern did not match.
E         Expected regex: 'encoding'
E         Actual message: 'Dependency input must use valid UTF-8.'

tests\discovery_runtime\analyzer\test_dependency_python.py:235: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                 Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_python.py     154      1     86      2    99%   63->59, 222
--------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                  154      1     86      2    99%
Coverage JSON written to file SCRATCH/issue-980-p4t7-python-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_dependency_python.py::test_invalid_encoding_has_a_fixed_error[\xff]
FAILED tests/discovery_runtime/analyzer/test_dependency_python.py::test_invalid_encoding_has_a_fixed_error[pkg\x00SECRET]
======================== 2 failed, 91 passed in 0.31s =========================
```
