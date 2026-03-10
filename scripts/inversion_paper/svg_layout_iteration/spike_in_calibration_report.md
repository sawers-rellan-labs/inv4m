# Spike-in SVG Calibration: What Works, What Fails, and Next Steps

**Date:** 2026-03-10
**Context:** Panel B sigmoid connectors in Figure 1

---

## Where spike-in calibration works

### Standalone SVGs (single `ggsave` at known dimensions)

When the calibration SVG and the final render are saved at the **same dimensions** with **no parent `plot_grid`**, the spike-in gives sub-pixel accuracy.

**Evidence (standalone mi21, 9×6 inch = 648×432 SVG):**

| Element | BP line SVG x | Sigmoid SVG x | Diff (px) |
|---------|--------------|---------------|-----------|
| TIL18 upstream | 227.04 | 227.03 | 0.01 |
| Mi21 downstream | 292.22 | 292.25 | 0.03 |
| B73 downstream | 318.49 | 318.26 | 0.23 |

Y-axis alignment also sub-pixel after switching from spike y-mapping to direct BP line grep (see "Y-axis subtlety" below).

### Panels E/F annotations

The spike-in was successfully used to position overlay annotations (labels, brackets) on Panels E and F. These panels are rendered directly at their final dimensions — no intermediate `plot_grid` embedding.

---

## Where spike-in calibration fails

### Combined figures where `plot_grid()` re-renders the content

When Panel B (a `ggdraw()` object) is placed inside a parent `plot_grid()` for the combined BCD figure (18×7) or full Figure 1 (18×19), the **NPC overlay coordinates break**.

**Evidence (combined BCD, 18×7 inch = 1296×504 SVG):**

| Element | BP line SVG x | Sigmoid SVG x | Diff (px) |
|---------|--------------|---------------|-----------|
| TIL18 upstream | 274.57 | 281.52 | **+6.95** |
| TIL18 downstream | 374.64 | 379.68 | **+5.04** |
| Mi21 upstream | 274.57 | 281.80 | **+7.23** |
| B73 downstream | 390.13 | 394.65 | **+4.52** |

All sigmoids shifted **5–7px to the right**. The shift is consistent in direction but varies in magnitude across positions.

---

## Root cause: linear NPC vs non-linear re-rendering

### The scaling mismatch

When `plot_grid()` embeds Panel B at `rel_widths = c(0.62, 0.13, 0.25)`:

- **Panel stack contents** (breakpoint lines, data points, axis elements) are **re-rendered** by ggplot into the new viewport. The x-axis transform is recomputed from scratch for the new width. This is NOT a linear scale of the standalone pixel positions.

- **NPC overlays** (`draw_grob`, `draw_plot` on the `ggdraw`) are **linearly scaled** — their NPC coordinates map to the new viewport proportionally.

**Measured scale factors (standalone → combined):**

| What | Scale factor | Method |
|------|-------------|--------|
| BP line (upstream, x=227.04 → 274.57) | **1.2094** | Re-rendered |
| BP line (downstream, x=306.23 → 374.64) | **1.2234** | Re-rendered |
| Sigmoid overlay (x=227.03 → 281.52) | **1.2400** | Linear NPC |
| Canvas ratio (648 × 0.62 → 1296 × 0.62) | **1.2400** | Exact |

Key observations:
- Sigmoid overlays scale by the **exact canvas ratio** (1.2400) — pure linear NPC mapping
- BP lines scale by **1.209–1.223**, varying by x-position — NOT linear
- The non-linearity comes from ggplot re-rendering: margins, axis label space, `coord_cartesian` clipping, and `scale_x_continuous` tick placement all get recomputed at the new aspect ratio

### Why the non-linearity exists

A ggplot panel's data area is `canvas_width - left_margin - right_margin - axis_label_space`. When the canvas width changes:
- Font sizes stay constant (in points), so label/margin space stays constant
- The data area shrinks/grows by MORE than the canvas ratio
- Data coordinates map to DIFFERENT proportions of the new canvas

This means `data_x_pixel / canvas_width` (NPC) is NOT preserved across canvas sizes. The spikes measure NPC at one canvas size, but the final render uses a different canvas size where the same data coordinate maps to a different NPC.

### Y-axis subtlety

The spike y-mapping (`data_y → NPC`) had an additional problem: `theme(plot.margin = margin(t = -5, unit = "mm"))` on the final render shifted the viewport, but the spike calibration SVG didn't account for this. Even when the margin was made consistent, the y-mapping from spikes (`seg_ymin=-3, seg_ymax=125`) didn't match the actual BP line endpoints because of the `expand` factor interaction.

**Fix that worked for y:** Instead of deriving y from spikes, grep the actual `#551A8B` `<line>` elements from the calibration SVG to get `y1`/`y2` directly. This gave exact y-boundaries because we're reading the actual rendered positions, not extrapolating from data coordinates.

---

## The old approach that worked

Before the spike-in was added, Panel B used a **hardcoded SVG coordinate table** (`vlines`) with positions measured from the **combined** SVG canvas (725.76×576):

```r
variant_mi21 <- list(
  svg = list(W = 725.76, H = 576, lw = 2.56),
  vlines = list(
    TIL18 = list(up_x = 250.80, dn_x = 340.44, top_y = 103.13, bot_y = 194.99),
    Mi21  = list(up_x = 250.80, dn_x = 324.58, top_y = 253.24, bot_y = 345.09),
    B73   = list(up_x = 250.80, dn_x = 354.31, top_y = 403.35, bot_y = 495.20)),
  ...
)
```

NPC was computed as `vl$up_x / svg$W` and `1 - vl$top_y / svg$H`.

**Why it worked:** The coordinates were measured from the SAME canvas that the final combined figure renders to. No spike calibration needed — just grep the SVG once, fill in the table, and the NPC matches.

**Why it broke:** When the combined figure dimensions changed (18×8 → 18×7), the pixel positions shifted but the table was stale. The approach is correct but requires re-measuring whenever dimensions change.

---

## Design sketch: automated coordinate mapping script

### Goal

A reusable script that:
1. Takes an RDS plot object (the `ggdraw` assembly)
2. Saves it to SVG at the **target** dimensions (the final output size)
3. Greps the SVG for known elements (by color, tag, or ID)
4. Builds a coordinate table automatically
5. Returns mapping functions (`data_x → NPC`, `panel_y_boundaries`)

### Architecture

```
┌─────────────────────────────────────────────────┐
│  calibrate_overlay(plot_rds, width, height,      │
│                    element_table)                 │
│                                                  │
│  1. ggsave(tempfile, plot_rds, width, height)    │
│  2. Parse SVG: viewBox → canvas W, H             │
│  3. For each element in element_table:           │
│     grep SVG by color/tag → extract x, y         │
│  4. Build coordinate table (panel → positions)   │
│  5. Derive mapping functions:                    │
│     - data_to_npc_x(bp_val) from spike or grep   │
│     - panel_boundaries(panel_id) from line grep   │
│  6. Return list(x_map, y_boundaries, raw_table)  │
└─────────────────────────────────────────────────┘
```

### Element table (input)

A data frame describing what to find in the SVG:

```r
element_table <- data.frame(
  id = c("bp_line", "midline", "introg_bound", "spike_a", "spike_b"),
  grep_pattern = c("#551A8B.*<line", "gray55.*<line", "stroke-dasharray.*<line",
                   spike_id_a, spike_id_b),
  element_type = c("line", "line", "line", "text", "text"),
  extract = c("x1,y1,y2", "x1", "x1,y1,y2", "x,y", "x,y"),
  stringsAsFactors = FALSE
)
```

### Key design decisions

1. **Calibrate at the TARGET canvas size.** The script saves the SVG at the exact `width × height` of the final output. No standalone-to-combined mismatch.

2. **Use grep for positions of rendered elements.** Don't extrapolate from spike data coordinates — read the actual pixel positions of breakpoint lines, midlines, etc. from the SVG. This avoids the non-linear re-rendering problem because we're reading the result of re-rendering.

3. **Spikes remain useful for data→pixel mapping.** When you need to place NEW elements at arbitrary data coordinates (not existing rendered elements), spikes give the exact mapping. But only use this mapping at the SAME canvas size.

4. **Element table is the single source of truth.** Colors, tag types, and extraction patterns are declared once. Adding a new overlay element means adding a row to the table, not writing new grep code.

5. **Run at each target size.** For a figure that appears in multiple contexts (standalone 9×6, combined 18×7, full 18×19), run the calibration THREE times and get three coordinate tables. The overlay code selects the right table based on context.

### Usage pattern

```r
# Save standalone Panel B
p_standalone <- make_panel_b(show_points = FALSE)
cal_standalone <- calibrate_overlay(p_standalone, width = 9, height = 6, element_table)

# Save combined BCD
p_combined <- plot_grid(p_standalone, panel_c, panel_d, rel_widths = c(0.62, 0.13, 0.25))
cal_combined <- calibrate_overlay(p_combined, width = 18, height = 7, element_table)

# Use the right calibration for the right context
ggsave("standalone.svg", add_overlays(p_standalone, cal_standalone), width = 9, height = 6)
ggsave("combined.svg", add_overlays(p_combined, cal_combined), width = 18, height = 7)
```

### Limitations

- Requires the plot to be built BEFORE calibration (chicken-and-egg for overlays that depend on the calibration). Solution: build without overlays first, calibrate, then add overlays.
- Grep patterns must be specific enough to avoid false matches. Color codes work well for unique-colored elements.
- Font rendering differences between systems could shift text spike positions. Mitigation: use `fix_text_size = TRUE` and verify on the target system.

---

## New discovery: axis text causes non-linear panel compression (2026-03-10)

### The problem

When stacking 3 genome panels with `plot_grid(ncol = 1, align = "v", axis = "lr")`, adding `axis.text.x = element_text()` to **only the bottom panel** causes that panel to shrink vertically. The axis text takes space, compressing the data area, and `align = "v"` enforces uniform x-axis alignment across all three panels — so the bottom panel ends up narrower in the y-direction while the x-axis data area is resized to accommodate the text.

This caused x-axis break labels to **misalign with gridlines** because the bottom panel's data-to-pixel mapping was different from the other panels.

### The fix: uniform `element_blank()` + spike-calibrated tick overlays

1. **All three panels** use `axis.text.x = element_blank()` — no panel has native axis text
2. **`align = "v"` with `axis = "lr"`** ensures all panels have identical data area widths
3. **`calibrate_xbreaks()`** function places break labels as `draw_label()` overlays at spike-calibrated NPC positions

### How `calibrate_xbreaks()` works

```r
calibrate_xbreaks <- function(base_plot, width, height, bot_genome,
                              break_values = c(150, 175, 200, 225),
                              y_npc = 0.108)
```

1. Saves the base plot (without breaks) to a temp SVG at target dimensions
2. Greps `#551A8B` `<line>` elements to find the bottom panel's two breakpoint lines
3. Uses known breakpoint data coordinates from `bp_aligned` to derive a linear `data_x → pixel_x` mapping
4. Converts each tick value (e.g., 150 Mb) to pixel, then to NPC (`px / svg_W`)
5. Returns `draw_label()` calls at calibrated positions

### Why this works

The break labels are NPC overlays on the same `ggdraw()` canvas as the panels. The calibration happens at the **exact target dimensions**, so the data→NPC mapping is correct. The two BP lines provide two known data→pixel pairs, giving an exact linear mapping within the panel's data area.

### Key insight: `align = "v"` is essential

The user emphasized: "`align = 'v'` is what I wanted from the start." Without it, panels have independent x-axis widths that depend on y-axis label width, margin, and axis text — making cross-panel overlays (sigmoids, break labels) impossible to align.

With `align = "v"` and uniform `element_blank()`, all panels share the same data area width, and a single linear mapping suffices for all three panels.

---

## Immediate fix for Panel B

Revert to the pre-spike-in `build_crossing_lines()` using the `vlines` hardcoded table. The table values were correct for the combined figure. Update the table if the combined figure dimensions change.

The spike-in calibration code can remain in the codebase for use by Panels E/F (where it works) and as the basis for the automated script described above.
