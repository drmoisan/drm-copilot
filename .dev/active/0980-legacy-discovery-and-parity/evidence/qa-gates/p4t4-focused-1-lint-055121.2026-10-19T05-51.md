# P4-T4 focused-1 lint

Timestamp: 2026-10-19T05-51
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py tests/discovery_runtime/analyzer/test_configuration.py tests/discovery_runtime/analyzer/test_configuration_input.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py:139:89
    |
137 |             "configuration-presence-unresolved",
138 |             item.path,
139 |             "Values, conditions and effective configuration presence are not evaluated.",
    |                                                                                         ^
140 |             analyzer="configuration",
141 |             blocking=False,
    |

E501 Line too long (96 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py:149:89
    |
147 |                 "source-revision-unverified",
148 |                 item.path,
149 |                 "Capture matching immutable source bytes before publishing configuration keys.",
    |                                                                                         ^^^^^^^^
150 |                 analyzer="configuration",
151 |             )
    |

E501 Line too long (129 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py:169:89
    |
167 |         code,
168 |         path,
169 |         "Check the selected configuration against supported formats, syntax and limits; values and parser details are withheld.",
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
170 |         analyzer="configuration",
171 |     )
    |

E501 Line too long (97 > 88)
   --> tests\discovery_runtime\analyzer\test_configuration.py:261:89
    |
259 |         (
260 |             "settings.xml",
261 |             b'<settings condition="VALUE_SENTINEL_1"><setting name="K">one</setting></settings>',
    |                                                                                         ^^^^^^^^^
262 |             b'<settings condition="VALUE_SENTINEL_2">\n<setting name="K">two</setting></settings>',
263 |         ),
    |

E501 Line too long (99 > 88)
   --> tests\discovery_runtime\analyzer\test_configuration.py:262:89
    |
260 |             "settings.xml",
261 |             b'<settings condition="VALUE_SENTINEL_1"><setting name="K">one</setting></settings>',
262 |             b'<settings condition="VALUE_SENTINEL_2">\n<setting name="K">two</setting></settings>',
    |                                                                                         ^^^^^^^^^^^
263 |         ),
264 |         ("settings.ini", b"[S]\nK=VALUE_SENTINEL_1", b"[S]\n\nK=VALUE_SENTINEL_2"),
    |

E501 Line too long (113 > 88)
  --> tests\discovery_runtime\analyzer\test_configuration_input.py:40:89
   |
38 |         (
39 |             "xml",
40 |             b'<settings xmlns:x="http://www.w3.org/2001/XInclude"><x:include href="VALUE_SENTINEL"/></settings>',
   |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^
41 |             "configuration-xml-invalid",
42 |         ),
   |

Found 6 errors.

```
