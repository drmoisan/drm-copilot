# p4t7-python-focused2-lint

Timestamp: 2026-10-19T10-06
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_python.py tests/discovery_runtime/analyzer/test_dependency_python.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.163 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
TC003 Move standard library import `collections.abc.Iterator` into a type-checking block
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_python.py:12:29
   |
10 | import configparser
11 | import re
12 | from collections.abc import Iterator
   |                             ^^^^^^^^
13 | from typing import Literal
   |
help: Move into type-checking block

B008 Do not perform function call `DependencyLimits` in argument defaults; instead, perform the call within the function, or read the default from a module-level singleton variable
  --> tests\discovery_runtime\analyzer\test_dependency_python.py:19:32
   |
17 |     *,
18 |     format: Literal["requirements", "setup-cfg"] = "requirements",
19 |     limits: DependencyLimits = DependencyLimits(),
   |                                ^^^^^^^^^^^^^^^^^^
20 | ) -> DependencyResult:
21 |     """Encode synthetic text and return the public parser's immutable result."""
   |

E501 Line too long (100 > 88)
  --> tests\discovery_runtime\analyzer\test_dependency_python.py:57:89
   |
55 |     """Keep safe extras and marker names while omitting quoted values and comments."""
56 |     result = parse(
57 |         "pkg[b,a,b] >= 1, < 3 ; python_version >= 'SECRET#VALUE' and os_name != \"SECRET\" # SECRET"
   |                                                                                         ^^^^^^^^^^^^
58 |     )
59 |     item = result.candidates[0]
   |

E501 Line too long (178 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_python.py:168:89
    |
166 | …ne:
167 | …d section anchors."""
168 | … = first>=1\n    second[a]\n# comment\n[options.extras_require]\ntest = third; extra == 'SECRET'\n    fourth\n"
    |                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
169 | …
170 | …tes] == [
    |

E501 Line too long (121 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_python.py:184:89
    |
182 | def test_setup_cfg_nonselected_continuations_cannot_become_options() -> None:
183 |     """An unrelated multiline value cannot introduce a false install requirement."""
184 |     text = "[options]\nother = initial\n    install_requires = fake\n    another\n\ninstall_requires = real\n; ignored\n"
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
185 |     result = parse(text, format="setup-cfg")
186 |     assert [(c.name, c.anchor.line) for c in result.candidates] == [("real", 6)]
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_python.py:238:89
    |
236 |     format: Literal["requirements", "setup-cfg"], field: str
237 | ) -> None:
238 |     """A constrained resource rejects the complete captured input, including prefixes."""
    |                                                                                         ^
239 |     text = (
240 |         "first\nsecond"
    |

Found 6 errors.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
