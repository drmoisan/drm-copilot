"use strict";
/** Compute deterministic epic waves using longest-path dependency layering. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.EpicWaveCycleError = void 0;
exports.computeWaveNumbers = computeWaveNumbers;
function pythonRepr(value) {
    return `'${value.replaceAll("\\", "\\\\").replaceAll("'", "\\'")}'`;
}
/** Error raised when no finite wave exists for a cyclic dependency graph. */
class EpicWaveCycleError extends Error {
    featureFolder;
    constructor(featureFolder) {
        super("Epic dependency manifest contains a cycle at feature folder " +
            `${pythonRepr(featureFolder)}; wave numbers cannot be computed for a ` +
            "cyclic dependency graph.");
        this.name = "EpicWaveCycleError";
        this.featureFolder = featureFolder;
    }
}
exports.EpicWaveCycleError = EpicWaveCycleError;
/** Compute wave(f) = 0 without dependencies, else 1 + max(wave(d)). */
function computeWaveNumbers(manifest) {
    const waveNumbers = new Map();
    const inProgress = new Set();
    function resolve(featureFolder) {
        const existing = waveNumbers.get(featureFolder);
        if (existing !== undefined) {
            return existing;
        }
        if (inProgress.has(featureFolder)) {
            throw new EpicWaveCycleError(featureFolder);
        }
        inProgress.add(featureFolder);
        let waveNumber;
        try {
            const dependencies = manifest.get(featureFolder) ?? [];
            waveNumber =
                dependencies.length === 0
                    ? 0
                    : 1 + Math.max(...dependencies.map(resolve));
        }
        finally {
            inProgress.delete(featureFolder);
        }
        waveNumbers.set(featureFolder, waveNumber);
        return waveNumber;
    }
    for (const featureFolder of manifest.keys()) {
        resolve(featureFolder);
    }
    return waveNumbers;
}
