#!/usr/bin/env bats
# Membership and dual-home parity for the .claude/lib/bash library.
#
# Follows the pattern of
# tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1:
# discover the repository copies, assert each has a core.json entry, and assert
# each has a byte-identical bundled counterpart. Written in bats rather than
# Pester so this feature introduces no new PowerShell surface.
#
# A non-empty-discovery floor guards against a broken glob: without it a
# renamed or moved directory would make every per-file assertion disappear and
# the suite would pass while covering nothing. No temporary file is created.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    BUNDLE_DIR="${REPO_ROOT}/extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash"
    CORE_MANIFEST="${REPO_ROOT}/extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
    # The library is an eleven-file module; a discovery below this floor means
    # the tree moved rather than that the library shrank.
    MINIMUM_LIB_FILE_COUNT=11
}

# Echo every repository .claude/lib/bash shell file, one basename per line.
discover_lib_basenames() {
    local path
    for path in "${LIB_DIR}"/*.sh; do
        [ -f "$path" ] || continue
        basename "$path"
    done
}

@test "the repository bash library meets the discovery floor" {
    count="$(discover_lib_basenames | wc -l)"
    [ "$count" -ge "$MINIMUM_LIB_FILE_COUNT" ]
}

@test "the core pack manifest exists and is readable" {
    [ -f "$CORE_MANIFEST" ]
    [ -s "$CORE_MANIFEST" ]
}

@test "every repository bash library file has a core.json entry" {
    checked=0
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        if ! grep -qF "\".claude/lib/bash/${name}\"" "$CORE_MANIFEST"; then
            echo "missing core.json entry: .claude/lib/bash/${name}" >&2
            return 1
        fi
        checked=$((checked + 1))
    done < <(discover_lib_basenames)
    [ "$checked" -ge "$MINIMUM_LIB_FILE_COUNT" ]
}

@test "every repository bash library file has a byte-identical bundled counterpart" {
    checked=0
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        if [ ! -f "${BUNDLE_DIR}/${name}" ]; then
            echo "missing bundled counterpart: ${name}" >&2
            return 1
        fi
        if ! cmp -s "${LIB_DIR}/${name}" "${BUNDLE_DIR}/${name}"; then
            echo "bundled counterpart differs: ${name}" >&2
            return 1
        fi
        checked=$((checked + 1))
    done < <(discover_lib_basenames)
    [ "$checked" -ge "$MINIMUM_LIB_FILE_COUNT" ]
}

@test "the bundled tree carries no bash library file the repository lacks" {
    for path in "${BUNDLE_DIR}"/*.sh; do
        [ -f "$path" ] || continue
        name="$(basename "$path")"
        if [ ! -f "${LIB_DIR}/${name}" ]; then
            echo "bundled-only file with no repository counterpart: ${name}" >&2
            return 1
        fi
    done
}

@test "the four CLI entry points are present in both trees" {
    for name in compute-cohorts.sh compute-concurrency-batches.sh report-lane-assertion.sh validate-parallel-manifest.sh; do
        [ -f "${LIB_DIR}/${name}" ]
        [ -f "${BUNDLE_DIR}/${name}" ]
    done
}
