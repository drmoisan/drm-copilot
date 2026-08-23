"use strict";
/**
 * Pure translation of selected Claude push-down pack names.
 *
 * The Push Down Claude Customizations command offers a `csharp` selection, but
 * the bundled manifests are variant-qualified (`csharp-modern.json`,
 * `csharp-legacy.json`). This module translates the selected `csharp` pack name
 * into its variant-qualified form before the name is forwarded to the service,
 * so manifest resolution succeeds.
 *
 * This module is intentionally free of any `vscode` import and performs no I/O,
 * so it is unit-testable without the VS Code host runtime.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.translateSelectedPackNames = translateSelectedPackNames;
const CSHARP_PACK_NAME = "csharp";
/**
 * Translate the selected pack names by replacing a `csharp` entry with its
 * variant-qualified form (`csharp-${csharpVariant}`). All non-C# entries are
 * returned unchanged and in their original order.
 *
 * Fail-fast contract: when `packs` includes `csharp` but `csharpVariant` is
 * `undefined`, this throws an `Error` because the variant-qualified manifest
 * name cannot be constructed. When `packs` does not include `csharp`, the input
 * list is returned unchanged regardless of `csharpVariant`.
 *
 * @param packs - The selected pack names, in selection order.
 * @param csharpVariant - The resolved C# variant, or `undefined`.
 * @returns A new array with the `csharp` entry translated; order preserved.
 */
function translateSelectedPackNames(packs, csharpVariant) {
    if (!packs.includes(CSHARP_PACK_NAME)) {
        return [...packs];
    }
    if (csharpVariant === undefined) {
        throw new Error("Cannot translate the 'csharp' pack name: the C# toolchain variant is " +
            "unresolved. A variant ('modern' or 'legacy') must be chosen whenever " +
            "the C# pack is selected.");
    }
    const translatedName = `${CSHARP_PACK_NAME}-${csharpVariant}`;
    return packs.map((pack) => pack === CSHARP_PACK_NAME ? translatedName : pack);
}
