"""Mark the analyzer test tree as a package so its module names stay unique.

``tests/discovery_runtime/analyzer/test_configuration.py`` mirrors
``drm_copilot_discovery/analyzer/configuration.py`` and shares its basename with
``tests/discovery_runtime/test_configuration.py``; without a package marker the
default rootdir collection registers both as ``test_configuration`` and refuses the
second. The marker follows the existing ``tests/scripts/dev_tools/discovery/analyzer``
precedent.
"""
