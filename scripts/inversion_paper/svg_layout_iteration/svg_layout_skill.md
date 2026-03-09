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

## SVG coordinate table — single source of truth

Store all SVG-derived positions in a centralized data structure. Every overlay element (labels, shapes, connections) computes its position from this table, never from hardcoded NPC values. When the layout changes, re-extract coordinates into the table once — all downstream code adjusts automatically.

```r
svg <- list(W = 648, H = 432, lw = 2.56)  # canvas dims + linewidth in svg units

# Per-panel positions extracted from SVG (keyed by panel ID)
panels <- list(
  Panel1 = list(feat_x = 172.07, feat2_x = 241.30, top_y = 57.75, bot_y = 140.45),
  Panel2 = list(feat_x = 172.07, feat2_x = 242.52, top_y = 170.33, bot_y = 253.03))

# NPC conversion helper
to_npc <- function(sx, sy) list(x = sx / svg$W, y = 1 - sy / svg$H)
```

**Key grep patterns for extracting coordinates from SVG:**
- Colored elements: `grep "#HEX_COLOR" svg_file`
- Gridlines: `grep "EBEBEB" svg_file`
- Text elements: `grep "<text" svg_file`
- Shapes: `grep "polygon\\|polyline" svg_file`

## Data-driven code patterns

### Parameterized panel functions

One function per panel type, taking a panel ID and looking up everything from the coordinate table. Panel-specific behavior (margins, axis visibility) is controlled by parameters, not by duplicating code.

```r
make_panel <- function(panel_id, show_points = FALSE, bot_margin = 15) {
  panel_data <- all_data %>% filter(panel == panel_id)
  # ... build plot using looked-up data
}
```

### Annotation generation by iteration

Define annotations as a list-of-lists, iterate with `lapply`. Adding/removing/reordering panels means editing the data list, not restructuring code.

```r
labels <- list(
  list(name = "A", y = 0.875, extra = "description"),
  list(name = "B", y = 0.614, extra = NULL))

annots <- unlist(lapply(labels, function(g) {
  out <- list(draw_label(g$name, x = x_pos, y = g$y, ...))
  if (!is.null(g$extra)) out <- c(out, list(draw_label(g$extra, ...)))
  out
}), recursive = FALSE)
```

### Relationship-driven inter-panel elements

Define panel-pair relationships as data, iterate to generate connecting elements. Endpoints are looked up from the coordinate table.

```r
pairs <- list(
  list(top = "Panel1", bot = "Panel2", type = "parallel"),
  list(top = "Panel2", bot = "Panel3", type = "crossing"))

connections <- unlist(lapply(pairs, function(pr) {
  tv <- panels[[pr$top]]; bv <- panels[[pr$bot]]
  y1 <- 1 - tv$bot_y / svg$H
  y2 <- 1 - bv$top_y / svg$H
  # ... generate elements based on pr$type
}), recursive = FALSE)
```

### Shape vertex computation from the table

For overlay shapes (arrows, brackets, polygons), compute vertices from reference points in the coordinate table, not from hardcoded NPC.

```r
make_shape <- function(panel_id, direction) {
  v <- panels[[panel_id]]
  cy <- v$top_y - gap - half_height - svg$lw
  xs <- c(v$feat_x, v$feat_x + offset, v$feat2_x, ...) / svg$W
  ys <- 1 - c(cy, cy + half_height, ...) / svg$H
  draw_grob(grid::polygonGrob(
    x = unit(xs, "npc"), y = unit(ys, "npc"), ...))
}
```

## Overlay element placement

Use `grid::polygonGrob` on the `ggdraw` overlay for elements that need precise positioning independent of the panel stack. This avoids layout coupling.

**Critical rule:** If you remove elements from the `plot_grid` stack, use invisible spacers with the same `rel_heights` to preserve panel geometry. Otherwise all SVG-calibrated coordinates become invalid.

```r
spacer <- ggplot() + theme_void() + theme(plot.margin = margin(0, 10, 0, 10))
plot_grid(spacer, panel1, panel2, spacer,
          ncol = 1, rel_heights = c(0.15, 1, 1, 0.15))
```

## Assembly as composition

The final figure is assembled by composing independent layers. Each layer is generated from the coordinate table independently.

```r
p <- ggdraw() + draw_plot(stack, ...)
for (a in annotations) p <- p + a
for (a in connections) p <- p + a
p + shape_1 + shape_2
```

## Multi-canvas coordinate conversion (standalone vs combined figures)

When a panel is rendered both standalone (e.g., 9×6" = 648×432 pt) and as part of a combined figure (e.g., 18×8" where the panel viewport is 725.76×576 pt), the same NPC values are used inside the panel's `ggdraw`. However, ggplot axis labels and margins occupy a **fixed point size** regardless of canvas dimensions. This means the data area left/right edges fall at **different NPC fractions** in each canvas:

```
Standalone (648 wide):  data area at x=64.31 → NPC = 64.31/648 = 0.0992
Combined  (725.76 wide): data area at x=66.64 → NPC = 66.64/725.76 = 0.0918
```

**Never convert pixel positions from a standalone SVG directly to NPC for a combined figure.** The ~0.007 NPC difference is visually noticeable (~5 px shift).

### Correct approach: extract clip path edges from the rendered SVG

Extract the data area clip path boundaries directly from the SVG and store them in the variant config alongside other SVG-derived positions (vlines, xtick_x, etc.):

```r
# Clip path IDs in SVGs are base64-encoded: decode to get "x1|x2|y1|y2"
# For combined figures, subtract the panel viewport offset from combined coords
# e.g., combined clip x=274.00, panel starts at 207.36 → viewport x = 66.64

variant <- list(
  svg = list(W = 725.76, H = 576),
  clip = list(left = 66.64, right = 701.28),  # data area edges in viewport coords
  xtick_x = c("150" = 95.49, "175" = 265.18, ...),
  # ... other SVG-derived positions
)

# In overlay builder — direct conversion, no assumptions
x_gname   <- clip$left / svg$W    # left edge of data area
x_species <- clip$right / svg$W   # right edge of data area
```

No expansion math, no derived calculations — just SVG coordinates divided by canvas width, same pattern as every other position in the coordinate table.

**Use cases:**
- Genome name labels: `x = x_left_npc, hjust = 0` (left-aligned to data area edge)
- Species descriptions: `x = x_right_npc, hjust = 1` (right-aligned to data area edge)
- Any annotation that should visually align with the axis/grid boundaries

### Key rule

If an overlay element should align with a ggplot axis feature (grid edge, tick mark, data boundary), **always derive its NPC position from the SVG coordinate table**, never from pixel measurements on a different-sized canvas. Pixel→NPC conversion is only valid for the specific canvas size the pixels were measured from.

## Recalibration cycle

When something changes panel geometry (margins, rel_heights, inset position):

1. Save SVG with new layout
2. Re-extract coordinates into the table (grep by color/element type)
3. All derived positions update automatically (if code follows the patterns above)
4. Verify with SVG read, not PNG

## Useful ggplot/cowplot techniques

**Hiding native axis text for overlay replacement:**
Set native text to white (`element_text(color = "white")`) to keep spacing intact, then add overlay labels at SVG-derived positions with `draw_label()`. Match the original color (e.g., `#4D4D4D` for ggplot default axis gray).

**Mixed-format text in a single label:**
Use `gridtext::richtext_grob` with markdown: `"plain *italic*"`. Set `box_gp = grid::gpar(col = NA, fill = NA)` to hide the text box border. Note: CSS properties like `-webkit-text-stroke` do NOT render in R graphics devices.

**Linewidth conversion:**
ggplot `linewidth = 1.2` renders as `stroke-width ≈ 2.56` in SVG (at 648×432 canvas). Convert to NPC for consistent spacing: `lw_npc = stroke_width / canvas_height`.

**Always use `fix_text_size = TRUE` when saving SVGs:**
Without this, `ggsave` writes `textLength` and `lengthAdjust='spacingAndGlyphs'` attributes that distort text when the SVG is scaled or edited in Inkscape. Always pass `fix_text_size = TRUE` to `ggsave()` for SVG output.

```r
ggsave("figure.svg", plot = p, width = 9, height = 6,
       device = "svg", fix_text_size = TRUE)
```
