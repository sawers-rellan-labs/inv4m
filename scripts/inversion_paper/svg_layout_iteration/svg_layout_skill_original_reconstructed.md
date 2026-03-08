---
name: svg-layout
description: SVG-first figure layout iteration. Use when aligning ggplot/cowplot labels, margins, font sizes, or multi-panel elements.
argument-hint: [figure-name]
---

# SVG-First Figure Layout Iteration

When iterating on ggplot/cowplot figure layout (label positions, margins, font sizes, element alignment):

## Core workflow

1. **Check data size for choosing the SVG to be saved**: If `nrow(ggplot_input_df) > 500`, work on a skeleton version — exclude `geom_point()` layers. If ≤ 500, iterate on the full plot directly.
2. **Save SVGs from R code.** Read the SVG as text to extract exact element coordinates — this is cheap (text grep, no image tokens). Save PNG only for final visual verification or when the user needs to review. Avoid reading PNGs as images during alignment iteration.
3. **Read SVG programmatically** — grep for element positions (`x`, `y` attributes on `<text>`, `<polyline>`, `<polygon>`, `<line>` elements). Compare coordinates numerically against target positions or reference elements (grid lines, tick marks, clip regions).
4. **Derive coordinate mappings from the saved SVG**, not from guessing. For overlay positioning (e.g., cowplot `ggdraw`), save once, extract tick mark or grid line positions from the SVG, then compute the linear mapping between data coordinates and NPC/SVG coordinates.
5. **Adjust R code** using SVG coordinate math (e.g., `y_npc = 1 - svg_y / canvas_height`). Make targeted edits — change one set of related positions at a time.
6. **Repeat steps 2-5** until SVG element positions match the design reference numerically.
7. **Only after skeleton alignment is confirmed**, save the full figure with data points as PNG to verify legibility and check for text/data overlap.

## SVG coordinate table pattern

Store all SVG-derived positions in a centralized data structure instead of scattered variables. This makes recalibration easy if the layout changes.

```r
svg <- list(W = 648, H = 432, lw = 2.56)  # canvas dims + linewidth in svg units

# Per-panel positions extracted from SVG
vlines <- list(
  Panel1 = list(up_x = 172.07, dn_x = 241.30, top_y = 57.75, bot_y = 140.45),
  Panel2 = list(up_x = 172.07, dn_x = 242.52, top_y = 170.33, bot_y = 253.03))

# NPC conversion helper
to_npc <- function(sx, sy) list(x = sx / svg$W, y = 1 - sy / svg$H)
```

**Key grep patterns for extracting coordinates:**
- Colored vlines: `grep "#551A8B" svg_file` (use the stroke color hex)
- Gray midlines: `grep "#8C8C8C" svg_file`
- Gridlines: `grep "EBEBEB" svg_file`
- Text/ticks: `grep "text.*175\\|text.*200" svg_file`
- Polygons: `grep "polygon" svg_file`

## Overlay element placement with polygonGrob

When panel-strip elements (arrows, brackets) need precise positioning independent of the panel stack, use `grid::polygonGrob` on the `ggdraw` overlay instead of embedding them in the `plot_grid` stack. This avoids layout coupling — moving an arrow doesn't shift all panels.

```r
# Define vertices in SVG coordinates, convert to NPC
draw_grob(grid::polygonGrob(
  x = unit(c(x1, x2, x3) / svg$W, "npc"),
  y = unit(1 - c(y1, y2, y3) / svg$H, "npc"),
  gp = grid::gpar(fill = color, col = color)))
```

**Critical rule:** If you remove elements from the `plot_grid` stack (e.g., arrow strips → overlay grobs), use invisible spacers with the same `rel_heights` to preserve panel geometry. Otherwise all SVG-calibrated coordinates become invalid.

```r
spacer <- ggplot() + theme_void() + theme(plot.margin = margin(0, 10, 0, 10))
plot_grid(spacer, panel1, panel2, panel3, spacer,
          ncol = 1, rel_heights = c(0.15, 1, 1, 1, 0.15))
```
