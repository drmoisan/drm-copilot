/** Compute deterministic epic waves using longest-path dependency layering. */

function pythonRepr(value: string): string {
  return `'${value.replaceAll("\\", "\\\\").replaceAll("'", "\\'")}'`;
}

/** Error raised when no finite wave exists for a cyclic dependency graph. */
export class EpicWaveCycleError extends Error {
  public readonly featureFolder: string;

  public constructor(featureFolder: string) {
    super(
      "Epic dependency manifest contains a cycle at feature folder " +
        `${pythonRepr(featureFolder)}; wave numbers cannot be computed for a ` +
        "cyclic dependency graph.",
    );
    this.name = "EpicWaveCycleError";
    this.featureFolder = featureFolder;
  }
}

/** Compute wave(f) = 0 without dependencies, else 1 + max(wave(d)). */
export function computeWaveNumbers(
  manifest: ReadonlyMap<string, ReadonlyArray<string>>,
): Map<string, number> {
  const waveNumbers = new Map<string, number>();
  const inProgress = new Set<string>();

  function resolve(featureFolder: string): number {
    const existing = waveNumbers.get(featureFolder);
    if (existing !== undefined) {
      return existing;
    }
    if (inProgress.has(featureFolder)) {
      throw new EpicWaveCycleError(featureFolder);
    }

    inProgress.add(featureFolder);
    let waveNumber: number;
    try {
      const dependencies = manifest.get(featureFolder) ?? [];
      waveNumber =
        dependencies.length === 0
          ? 0
          : 1 + Math.max(...dependencies.map(resolve));
    } finally {
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
