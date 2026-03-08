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
- Purple vlines: `grep "#551A8B" svg_file` (or whatever the stroke color hex is)
- Gray midlines: `grep "#8C8C8C" svg_file`
- Gridlines: `grep "EBEBEB" svg_file`
- Text/ticks: `grep "text.*175\\|text.*200" svg_file`
- Polygons (arrows): `grep "polygon" svg_file`

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

## Hiding native axis text + overlay replacement

To reposition axis labels freely (e.g., below an arrow instead of at panel edge):

1. Set native axis text to white: `axis.text.x = element_text(color = "white")` — keeps spacing intact
2. Add overlay labels at SVG-derived positions using `draw_label()`
3. Match the original color (e.g., `#4D4D4D` for ggplot default gray axis text)

## Inter-panel connection lines

For lines connecting elements between panels (synteny, inversions, etc.):

- **Straight lines** (same orientation): `draw_line()` with SVG-derived NPC endpoints
- **Sigmoid curves** (crossing/inversion): Generate logistic interpolation points, render as `geom_path` in a `[0,1]×[0,1]` `draw_plot` overlay

```r
sigmoid_path <- function(x1, y1, x2, y2, n = 50) {
  t <- seq(-6, 6, length.out = n)
  s <- 1 / (1 + exp(-t))
  data.frame(x = x1 + (x2 - x1) * s,
             y = y1 + (y2 - y1) * seq(0, 1, length.out = n))
}
```

Drive connection generation from a panel-pair list to avoid duplicated code:
```r
pairs <- list(
  list(top = "Panel1", bot = "Panel2", inverted = FALSE),
  list(top = "Panel2", bot = "Panel3", inverted = TRUE))
```

## Mixed-format text

Use `gridtext::richtext_grob` with markdown for mixed italic/plain in a single label (e.g., "teosinte *mexicana*"):

```r
draw_grob(gridtext::richtext_grob(
  "plain *italic*",
  x = unit(x_npc, "npc"), y = unit(y_npc, "npc"),
  hjust = 1, gp = grid::gpar(fontsize = 16, col = "gray50"),
  box_gp = grid::gpar(col = NA, fill = NA)))
```

Note: CSS properties like `-webkit-text-stroke` do NOT render in R graphics devices.

## Text shadow for low-contrast colors

For light-colored text (e.g., gold on white), draw two labels: dark shadow offset underneath, then the colored text on top:

```r
draw_label("TR-1", x = 0.761, y = 0.953, color = "gray30", ...)
draw_label("TR-1", x = 0.76,  y = 0.955, color = "gold", ...)
```

## Linewidth reference

ggplot `linewidth = 1.2` renders as `stroke-width: 2.56` in SVG (648×432 canvas). Use this for consistent spacing: `lw_npc = 2.56 / 432 ≈ 0.006` NPC.
