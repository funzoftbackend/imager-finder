# Image Finder — Complete Scan Report

**App:** Image Finder (Flutter · Android)  
**Scope:** Full gallery scan for Duplicate, Similar, Dark, and Blurry photos  
**Report date:** 13 July 2026  
**Reference device (baseline timings):** Samsung SM A715W  

---

## 1. Executive summary

Image Finder scans the device gallery locally (no cloud upload) and classifies photos into four cleanup categories:

| Category | What it finds | Algorithm family |
| -------- | ------------- | ---------------- |
| **Duplicate** | Byte-identical (or same-content) copies | Size collision → **xxHash64** → group by hash |
| **Similar** | Near-duplicates / burst shots that look alike | Thumbnail **dHash** → Hamming ≤ 6 → LSH + center-star clustering |
| **Dark** | Underexposed / too-dim shots | Mean **Rec.601 luminance** on 64×64 thumb ≤ 42 |
| **Blurry** | Soft / out-of-focus shots | **Laplacian variance** on 64×64 gray ≤ 90 (if not near-black) |

Dark and blurry scores are computed **in the same native thumbnail pass** as similar dHash — there is no second full-gallery decode.

---

## 2. Total images scanned & total scan time

### 2.1 Latest measured full scan (native + dark/blur) — **source of truth**

**Device:** Samsung SM A715W (wireless debug) · **Date:** 13 July 2026  
**Log:** `[ImageFinder.Scan] SCAN COMPLETE photos=3604 exact=474 similar=212 dark=281 blurry=47`

| Metric | Value |
| ------ | ----- |
| **Images scanned** | **3,604** |
| **Total scan time (FULL SCAN)** | **37.2 s** (37,194 ms) |
| Fingerprint rate (similar_hash) | **160.9 photos/s** · **0 failures** |
| Scan type | First full index (`new=3604`, empty local cache) |

| Category | Result |
| -------- | ------ |
| **Duplicate** | **474 groups** · **950 photos** · default selected **476** (keep 474) |
| **Similar** | **212 groups** · **597 photos** · default selected **385** (keep 212) |
| **Dark** | **281 photos** · default selected **281** (all) |
| **Blurry** | **47 photos** · default selected **47** (all) |

> Duplicate / Similar: Clean keeps 1 best photo per group, selects the rest. Dark / Blurry: Clean selects every photo by default.

### 2.2 Stage-by-stage timing (this run)

| Stage | Duration | Detail from log |
| ----- | -------- | --------------- |
| permission | 1.9 s (1,942 ms) | `state=authorized` |
| catalog | **386 ms** | `photos=3604` native |
| diff | 595 ms | `new=3604 changed=0 removed=0 unchanged=0` |
| exact_hash | 6.8 s (6,752 ms) | `candidates=991 hashed≈991` |
| exact_group | 2.1 s (2,074 ms) | `groups=474 photos=950` |
| similar_hash | **22.5 s** (22,505 ms) | dHash + dark + blur · `3604` · `160.9/s` · `failed=0` |
| similar_group_prepare | 59 ms | `fingerprints=3604` |
| similar_group | 1.6 s (1,650 ms) | `groups=212` |
| persist | 1.1 s (1,116 ms) | `dark=281 blurry=47` |
| **Duplicates (exact)** rolled up | **8.8 s** | exact_hash + exact_group |
| **Similar** rolled up | **24.2 s** | hash + prepare + group |
| **FULL SCAN** | **37.2 s** | wall clock from timing summary |

### 2.3 similar_hash milestones (this run)

| Progress | Elapsed in stage | Rate |
| -------- | ---------------- | ---- |
| 500 / 3604 | 3.7 s | 137.6/s |
| 1000 / 3604 | 7.2 s | 141.6/s |
| 1500 / 3604 | 10.4 s | 145.0/s |
| 2000 / 3604 | 13.9 s | 144.8/s |
| 2500 / 3604 | 16.6 s | 151.6/s |
| 3000 / 3604 | 19.5 s | 154.7/s |
| 3500 / 3604 | 22.0 s | 159.8/s |
| 3604 / 3604 | 22.5 s | **160.9/s** |

### 2.4 Historical baseline (before native pipeline) — for comparison only

| Metric | Old (Dart-heavy) | **Now (native)** | Speedup |
| ------ | ---------------- | ---------------- | ------- |
| Photos | 3,606 | **3,604** | — |
| Catalog | 45.8 s | **386 ms** | ~119× |
| Similar fingerprint | 4 m 25 s (~14/s) | **22.5 s (~161/s)** | ~12× |
| **FULL SCAN** | **5 m 25 s** | **37.2 s** | **~8.7×** |

Old stage table (obsolete — do not use for current performance claims):

| Stage | Old duration |
| ----- | ------------ |
| Catalog | 45.8 s |
| Duplicates (exact) | 8.9 s |
| Similar hash | 4 m 25 s |
| Similar group | 1.2 s |
| FULL SCAN | 5 m 25 s |

---

## 3. Step-by-step scan flow (start → finish)

```
Permission → Catalog → Diff → Exact (hash + group) → Fingerprint batch
  (dHash + dark + blur) → Similar grouping → Persist → Done
```

### Phase 0 — Permission
- Request gallery / Photos permission via the media catalog layer.  
- If denied → scan stops with an error and a settings deep-link hint.

### Phase 1 — Catalog
- Prefer native `catalogImages()`: one MediaStore cursor with `SIZE`, dimensions, dates, URI, mime, album path.  
- Fallback: Flutter `photo_manager` if native catalog fails.  
- Result: in-memory list of every image asset (`mediaId`, `uri`, `sizeBytes`, timestamps, …).

### Phase 2 — Diff (incremental)
- Compare catalog vs local Drift DB (`mediaId` + `sizeBytes` + `modifiedMs`).  
- **Added** / **modified** → upsert rows; modified photos **clear** content hash, dHash, and quality fields so they are rehashed.  
- **Deleted** → remove from DB.  
- Unchanged rows keep fingerprints → fast rescans.

### Phase 3 — Exact duplicates
1. Find photos that share the **same file size** with at least one other photo (size-collision candidates).  
2. For candidates missing `contentHash`, call native **xxHash64** on file bytes (large files use start/mid/end windows).  
3. Group all photos that share an identical `contentHash` (groups of size ≥ 2).  
4. Persist exact groups so Home/Clean can show duplicates **while** similar still runs.

### Phase 4 — Fingerprints (similar + dark + blurry)
- For every photo missing `dHash` **or** `meanLuminance` (or all photos on forced full similar):  
  - Native `computeDHashBatch` in chunks of **250** URIs.  
  - Per URI: system thumbnail (**64×64**), then one pass producing:
    - `dHash`  
    - `meanLuminance`  
    - `blurScore`  
  - Dart classifies dark/blurry and writes flags to DB.  
- Failed batch entries fall back to single `analyzeImage`.

### Phase 5 — Similar grouping
- Load all photos that have a dHash.  
- Run grouping in a **Dart isolate** (UI stays responsive):  
  LSH candidate edges → center-star clusters with diameter check → max group size 40 → **2-hour** capture-time window.  
- Pairs that already share the same content hash (true duplicates) are **excluded** from similar groups.

### Phase 6 — Persist & done
- Replace similar groups in DB.  
- Count dark / blurry flags.  
- Upsert `scan_meta` (`photoCount`, group counts, `darkCount`, `blurryCount`, `lastPhase=done`).  
- Emit final progress message and timing summary log.

---

## 4. Algorithms by category

### 4.1 Duplicate photos — **xxHash64 (exact content)**

**Simple explanation:**  
If two files have the same size, we “fingerprint” their bytes. If the fingerprints match, the files are treated as the same photo (exact duplicate), even if filenames differ.

**How it works:**
1. Only hash photos whose `sizeBytes` collides with another photo (most unique sizes are skipped → huge speed win).  
2. Native Kotlin streams the file and computes **xxHash64**.  
   - Small/medium files: full stream.  
   - Very large files (> ~12 MB): hash windows from start, middle, and end, plus length — avoids reading multi-hundred-MB images fully.  
3. Store the decimal string of the unsigned 64-bit hash as `contentHash`.  
4. Group by identical `contentHash` (need ≥ 2 members).

**Not used for duplicates:** perceptual hashes (those are for “looks similar”).

---

### 4.2 Similar photos — **difference hash (dHash) + Hamming distance + LSH clustering**

**Simple explanation:**  
Shrink each photo to a tiny grid and turn “is this pixel brighter than its neighbor?” into a 64-bit pattern. Photos with almost the same pattern (few bits different) were likely taken of the same scene — e.g. burst shots. We only link photos taken within **2 hours**, and we avoid chaining unrelated photos into giant groups.

**How dHash is built (native):**
1. Load a small thumbnail (system 64×64 or sampled decode).  
2. Scale to **9×8** gray.  
3. For each of 8 rows × 8 comparisons: if left pixel luma > right → set a bit.  
4. Result: 64-bit integer stored as a string.

**Matching & grouping (Dart isolate):**
1. **Skip** pairs that already share an exact `contentHash` (they belong in Duplicates).  
2. **Time window:** `|createdMs_a − createdMs_b| ≤ 2 hours` (falls back to `modifiedMs` if needed).  
3. **Candidate generation:**  
   - Exact same dHash buckets.  
   - **8-bit LSH bands** across the 64-bit hash (8 bands) so we don’t compare every photo to every other.  
4. Accept edge if **Hamming distance ≤ 6** (at most 6 of 64 bits differ).  
5. **Center-star clustering:** pick high-connectivity centers; add neighbors only if they stay within distance ≤ 6 of **every** current member (diameter bound — prevents A≈B≈C chaining when A ≉ C).  
6. Cap any group at **40** photos.

**Constants** (`lib/domain/scan/groupers.dart`):

| Constant | Value | Meaning |
| -------- | ----- | ------- |
| `kDefaultSimilarThreshold` | 6 | Max Hamming distance |
| `kDefaultSimilarMaxTimeDeltaMs` | 2 hours | Capture-time window |
| `kDefaultSimilarMaxGroupSize` | 40 | Safety cap |

---

### 4.3 Dark photos — **mean luminance threshold**

**Simple explanation:**  
We look at a small gray version of the photo and average how bright the pixels are (0 = black, 255 = white). If that average is very low, the photo is labeled **Dark**.

**How it works:**
1. Same 64×64 thumbnail used for dHash.  
2. Convert each pixel with Rec.601: `0.299R + 0.587G + 0.114B`.  
3. Average → `meanLuminance`.  
4. Flag dark if `meanLuminance ≤ 42`.

**Constant:** `kDarkMeanLuminanceMax = 42.0` (`quality_metrics.dart`).

---

### 4.4 Blurry photos — **Laplacian variance (focus measure)**

**Simple explanation:**  
Sharp photos have strong edges; blurry ones look smooth. We measure how much “edge energy” exists with a Laplacian filter. Low energy → **Blurry**. Pitch-black frames are **not** labeled blurry (not enough signal).

**How it works:**
1. On the same 64×64 gray plane, apply a discrete Laplacian (center 4, neighbors −1).  
2. Compute the **variance** of Laplacian responses → `blurScore` (higher = sharper).  
3. Flag blurry if:
   - `meanLuminance ≥ 22` (enough light), **and**  
   - `blurScore ≤ 90`.

**Constants:**

| Constant | Value |
| -------- | ----- |
| `kBlurryLaplacianMax` | 90.0 |
| `kBlurryMinLuminance` | 22.0 |

Dark and blurry are **independent flags** — a photo can be both, either, or neither.

---

## 5. Time taken by each stage

### 5.1 This run (3,604 photos · native + dark/blur) — **37.2 s total**

| Stage | Time | Share of FULL SCAN |
| ----- | ---- | ------------------ |
| permission | 1.9 s | 5.2% |
| catalog | 386 ms | 1.0% |
| diff | 595 ms | 1.6% |
| exact_hash | 6.8 s | 18.2% |
| exact_group | 2.1 s | 5.6% |
| **similar_hash** (dHash + dark + blur) | **22.5 s** | **60.5%** |
| similar_group_prepare | 59 ms | 0.2% |
| similar_group | 1.6 s | 4.4% |
| persist | 1.1 s | 3.0% |
| **FULL SCAN** | **37.2 s** | 100% |

Rolled-up categories from the same log:

| Roll-up | Time |
| ------- | ---- |
| Duplicates (exact) | 8.8 s |
| Similar (hash + group) | 24.2 s |

### 5.2 What each timing key measures

| Timing key | What it measures |
| ---------- | ---------------- |
| `permission` | Permission grant |
| `catalog` | Gallery inventory |
| `diff` | DB vs catalog delta |
| `exact_hash` | xxHash on size-collision candidates |
| `exact_group` | Grouping identical content hashes |
| `similar_hash` | Native batch: **dHash + dark + blur** together |
| `similar_group_prepare` | Parse hashes for isolate |
| `similar_group` | LSH + clustering in isolate |
| `persist` | Write groups + scan meta |

**Note on dark/blur timing:** There is **no separate stage clock** for dark or blurry. Their cost is included inside `similar_hash` (same thumbnail decode as dHash).

### 5.3 Old baseline (pre-native) — comparison only

| Stage | Old time | Share then |
| ----- | -------- | ---------- |
| Catalog | 45.8 s | ~14% |
| Exact duplicates | 8.9 s | ~3% |
| Similar fingerprint | 4 m 25 s | ~81% |
| Similar grouping | 1.2 s | &lt;1% |
| **Total** | **5 m 25 s** | 100% |

---

## 6. How many images in each category

### 6.1 How counts are defined

| Category | Stored as | UI meaning |
| -------- | --------- | ---------- |
| Duplicate | Exact groups + members | Home shows **photo count** in groups; Clean shows groups |
| Similar | Similar groups + members | Same pattern |
| Dark | `photos.isDark == true` | Flat list; all selectable by default |
| Blurry | `photos.isBlurry == true` | Flat list; all selectable by default |

### 6.2 Results from this library (SM A715W · 13 Jul 2026)

Clean tab **default selection** (auto-select for delete):

- **Duplicates / Similar:** keep 1 best photo per group → selected = photos − groups  
- **Dark / Blurry:** select **all** photos in the list  

| Category | Groups | Photos in category | Default **selected** (delete) | Kept |
| -------- | ------ | ------------------ | ----------------------------- | ---- |
| Duplicate | **474** | **950** | **476** | **474** |
| Similar | **212** | **597** | **385** | **212** |
| Dark | — | **281** | **281** | **0** |
| Blurry | — | **47** | **47** | **0** |
| **Library size** | — | **3,604** | — | — |

**Duplicates:** 950 − 474 = **476 selected** (keep 474).  
**Similar:** 597 − 212 = **385 selected** (keep 212).  
**Dark + Blurry:** **281 + 47 = 328** selected (all).

From log:

```text
SCAN COMPLETE photos=3604 exact=474 similar=212 dark=281 blurry=47
exact_group … groups=474 photos=950
```

---

## 7. Performance breakdown

| Work item | Where it runs | Cost profile | Notes |
| --------- | ------------- | ------------ | ----- |
| **Catalog** | Native MediaStore (preferred) | Low–medium | One cursor; avoids per-photo Flutter IPC |
| **Diff / DB upsert** | Dart + Drift SQLite | Low | Incremental; clears hashes only for modified |
| **Exact fingerprint (xxHash)** | Native, adaptive concurrency | Medium | Only size-collision candidates |
| **Exact grouping** | Dart | Very low | Hash map by `contentHash` |
| **Fingerprint generation** (dHash + luminance + Laplacian) | Native thread pool (4–8 workers), chunks of 250 | **Dominant** on first scan | System thumbs preferred over full decode |
| **Dark detection** | Same native pass + Dart threshold | Negligible extra | Mean of gray plane |
| **Blurry detection** | Same native pass + Dart threshold | Negligible extra | Laplacian variance on 64×64 |
| **Similar grouping** | Dart `Isolate.run` | Low–medium | LSH avoids O(n²) full pairwise |
| **Persist** | Drift transactions | Low | Replace groups + meta row |

### Memory choices
- Never decode full-resolution images for similarity/quality — **thumbnails / sampled bitmaps only**.  
- Bitmaps recycled after each fingerprint.  
- Similar grouping sends compact `int` hash lists to an isolate (not UI isolates closing over stream controllers).  
- Exact path avoids hashing unique-sized files.

---

## 8. Optimizations for speed and memory

1. **Native bulk catalog** — single MediaStore query with `SIZE`.  
2. **Deferred exact hashing** — size collision filter before xxHash.  
3. **Large-file xxHash windows** — avoid reading entire multi-MB/GB files.  
4. **Native parallel thumbnail fingerprints** — thread pool sized to CPU (4–8).  
5. **Chunked MethodChannel batches (250)** — balance IPC overhead vs backlog.  
6. **Piggybacked dark/blur** — zero extra gallery passes.  
7. **Incremental fingerprints** — skip photos that already have `dHash` and `meanLuminance`.  
8. **LSH bands for similar candidates** — sub-quadratic matching.  
9. **Center-star + diameter ≤ 6** — accuracy + avoids mega-groups.  
10. **2-hour time window + max group 40** — further limits false clusters.  
11. **Isolate for grouping** — keeps UI/status updates responsive.  
12. **Persist exact groups early** — user sees duplicates before similar finishes.  
13. **Selective Riverpod reloads** — Home cards don’t flicker on every hash tick.

---

## 9. Limitations and edge cases

| Area | Limitation |
| ---- | ---------- |
| **Duplicates** | Different compression / export of the “same” shot → different bytes → **not** exact duplicates (may appear under Similar). |
| **Duplicates** | Theoretical xxHash collision (extremely rare); large-file windowing is a strong fingerprint, not a cryptographic guarantee of whole-file equality. |
| **Similar** | Artistic crops, heavy filters, or screenshots of photos can miss or false-match. |
| **Similar** | Hamming ≤ 6 is strict (fewer false groups); may miss looser lookalikes. |
| **Similar** | Shots more than **2 hours** apart never group, even if visually identical. |
| **Similar** | LSH + bucket pair caps can miss some edges in pathological hash distributions (rare). |
| **Dark** | Intentionally dark scenes (night sky, concert) may be flagged — threshold is brightness, not “bad photo” AI. |
| **Dark** | Scored on a **thumbnail**, not the full RAW/JPEG; extreme crops of bright subjects in a dark frame can skew. |
| **Blurry** | Motion blur, depth-of-field bokeh, and soft filters can look “blurry” to Laplacian variance. |
| **Blurry** | Near-black frames are skipped for blur (`meanLuminance < 22`) to avoid nonsense labels. |
| **Blurry / Dark** | 64×64 resolution is fast but less precise than full-res analysis used by desktop tools. |
| **Platform** | Native engine is Android-oriented (`HashEngine` / `ScanEngine`); iOS would need a parallel implementation. |
| **Permissions** | No permission → no scan. Scoped storage / OEM MediaStore quirks can cause individual URI failures (counted as fingerprint failures). |
| **Counts** | A photo can appear in **more than one** category (e.g. dark + blurry, or similar group + dark). |
| **Rescan** | Changing thresholds in code does not reclassify old rows until fingerprints are recomputed (missing `meanLuminance` or force-full similar). |

---

## 10. End-to-end mental model

```
Gallery
  │
  ├─ Catalog (what exists)
  ├─ Diff (what changed)
  │
  ├─ Exact path ── size twins ── xxHash ── Duplicate groups
  │
  └─ Thumbnail path (once per photo needing fingerprint)
        ├─ dHash ──────────── Similar groups (Hamming + time + clustering)
        ├─ mean luminance ─── Dark list
        └─ Laplacian var ──── Blurry list
              │
              └─ Drift DB → Home cards + Clean tabs
```

---

## 11. How to refresh this report with live numbers

1. Full rebuild: `flutter run` (hot restart is **not** enough after Kotlin changes).  
2. Grant Photos permission → **Scan now** / **Rescan library**.  
3. Filter logcat / console for `[ImageFinder.Scan]`.  
4. Copy the final summary into §2.2 and §6.2.  
5. Optionally update `docs/scan_timing_report.md` with the new stage table.

---

## 12. Key source files

| File | Role |
| ---- | ---- |
| `lib/domain/scan/scan_orchestrator.dart` | Full pipeline orchestration |
| `lib/domain/scan/groupers.dart` | Exact + similar grouping |
| `lib/domain/scan/quality_metrics.dart` | Dark / blurry thresholds |
| `lib/domain/scan/scan_timing.dart` | Stage timing logs |
| `android/.../HashEngine.kt` | xxHash, dHash, quality scores |
| `android/.../ScanEngine.kt` | Catalog + batch fingerprints |
| `lib/data/db/tables.dart` | Photos + scan meta schema |
| `lib/ui/home/home_tab.dart` | Category cards |
| `lib/ui/clean/clean_tab.dart` | Clean categories & deletion |

---

*This document is updated from the live SM A715W log of 13 July 2026 (`FULL SCAN 37.2s`). Older 5m25s numbers are historical comparison only.*
