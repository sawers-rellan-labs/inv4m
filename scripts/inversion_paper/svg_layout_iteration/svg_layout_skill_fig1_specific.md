# SVG Layout — Figure 1 Specific Notes

**Updated:** 2026-03-08

## SVG coordinate extraction — use Grep, not Python

Always use the Grep tool directly on SVG files. Do NOT use Python XML/ElementTree parsing — SVG is plain text. Grep is faster and simpler.

### Grep patterns for Figure 1 Panel B

```bash
# Purple breakpoint vlines (#551A8B = purple4)
Grep pattern="#551A8B" path="Fig1_top_ABC.svg"
# Returns: <line x1='368.38' ... x2='368.38' ... stroke: #551A8B>

# Gray midlines (#8C8C8C = gray55)
Grep pattern="#8C8C8C" path="Fig1_top_ABC.svg"

# Gridlines (for true x-axis tick positions)
Grep pattern="EBEBEB" path="Fig1_top_ABC.svg"
# Returns vertical polylines at 175/200/225/250 Mb positions

# Arrow polygons
Grep pattern="polygon.*#551A8B" path="Fig1_top_ABC.svg"
# Returns polygon points — verify left/right edges match vline x values

# Overlay tick labels (custom #4D4D4D text)
Grep pattern=">175<" path="Fig1_top_ABC.svg"

# Hidden ggplot axis text (white, for position reference)
Grep pattern="fill: #FFFFFF.*175" path="Fig1_top_ABC.svg"

# Clip regions (Panel viewport boundaries)
grep -A2 'clipPath' Fig1_top_ABC.svg | grep 'rect'
# Panel B viewport: x=207.36, w=725.76 in combined SVG
```

### Verification pattern

After recalibration, verify alignment by checking that:
1. Arrow polygon x-coords match vline x-coords exactly
2. Sigmoid path endpoints match vline x-coords
3. Overlay tick labels match gridline x-coords

## Standalone vs combined SVG calibration

**Critical lesson:** Overlay coordinates calibrated from a standalone SVG (9×6 inch, 648×432) will NOT align in a combined figure (18×8 inch) because ggplot re-renders at different canvas sizes, producing different pixel positions.

### Why this happens

- Panel B is a ggdraw containing `draw_plot(stk, x=0.03, width=0.95)` + overlays
- The ggplot panels inside `stk` are laid out by ggplot's engine at render time
- At standalone size (648×432), a breakpoint vline lands at x=147.70
- At combined size (725.76×576 viewport), the same vline lands at x=161.02
- Overlay elements use `svg_x / svg$W` as NPC — if svg$W doesn't match, they misalign

### Per-variant coordinate system

Each variant carries its own `svg` dims and `xtick_x`, set by `build_panel_b()`:

```r
svg_standalone <- list(W = 648, H = 432, lw = 2.56)   # 9x6 inch
svg_combined   <- list(W = 725.76, H = 576, lw = 2.56) # Panel B viewport in 18x8

variant_pt <- list(
  svg = svg_standalone,
  xtick_x = c("175" = 160.11, "200" = 306.61, "225" = 453.10, "250" = 599.59),
  vlines = list(...), ...)

variant_mi21 <- list(
  svg = svg_combined,
  xtick_x = c("175" = 175.07, "200" = 340.86, "225" = 506.65, "250" = 672.43),
  vlines = list(...), ...)

build_panel_b <- function(variant) {
  svg <<- variant$svg       # set active coordinate system
  xtick_x <<- variant$xtick_x
  # ... build overlays using svg$W, svg$H
}
```

### Combined SVG viewport discovery

```bash
# Find Panel B viewport from clip rects
grep -A2 'clipPath' Fig1_top_ABC.svg | grep 'rect'
# Look for: <rect x='207.36' y='0.00' width='725.76' height='576.00' />
# Panel B local coord = combined_x - 207.36
```

## Recalibration procedure

When layout changes (margins, rel_heights, draw_plot offset, combined figure dimensions):

1. Render the target SVG (standalone or combined skeleton — no geom_point)
2. `Grep pattern="#551A8B"` → purple vline x/y positions
3. `Grep pattern="#8C8C8C"` → gray midline x positions
4. `Grep pattern="EBEBEB"` → gridline x positions (= true tick positions)
5. For combined SVG: find viewport with `grep -A2 'clipPath' | grep 'rect'`, subtract Panel B start x
6. Update variant config with new values
7. Re-render and verify: `Grep pattern="polygon.*#551A8B"` → arrow edges should match vlines

## Current Figure 1 architecture

### Combined figure: Fig1_top_ABC (18×8 inch)

```
plot_grid(Panel_A, Panel_B, Panel_C, rel_widths = c(0.16, 0.56, 0.28))
```

- **Panel A**: AnchorWave dotplots (Mi21 vs TIL18/PT/B73), coord_fixed, 40 Mb window, framed with grid
- **Panel B**: Repeat annotation (knob180 + TR-1), Mi21 variant with overlays
- **Panel C**: LAST breakpoint self-similarity dotplots

SVG saves skeleton (no geom_point, ~1 MB). PNG saves full figure with data points.

```r
build_fig1_top <- function(show_points) {
  p_panelb <- make_mi21(show_points)
  fig1_grid <- plot_grid(p_panela, p_panelb, p_panelc_brkpt, ...)
  ggdraw(fig1_grid) + draw_label("A", ...) + draw_label("B", ...) + draw_label("C", ...)
}

ggsave("Fig1_top_ABC.svg", plot = build_fig1_top(FALSE), ...)  # skeleton
ggsave("Fig1_top_ABC.png", plot = build_fig1_top(TRUE), ...)   # full
```

### Panel B overlay elements

| Element | Positioning | Color |
|---------|------------|-------|
| Breakpoint vlines | ggplot `geom_vline` (data-driven) | purple4 (#551A8B) |
| Midline vlines | ggplot `geom_vline` (data-driven) | gray55 (#8C8C8C) |
| Pentagonal arrows | `grid::polygonGrob` overlay, vertices from SVG table | purple4 |
| Sigmoid connectors | `draw_plot` overlay with `geom_path` | purple4 or gray55 |
| X-axis tick labels | `draw_label` overlay at gridline positions | #4D4D4D |
| Genome names | `draw_label` overlay | black |
| Species descriptions | `draw_label` or `richtext_grob` overlay | gray50 |
| Legend (knob 180, TR-1) | `draw_label` + legend dots | teal, gold |
| "Inv4m" label | `draw_label` centered between breakpoints | purple4 |

### Current SVG coordinate tables

**Mi21 variant** (combined 725.76×576):
```
up_x=161.02  TIL18_dn=248.60  Mi21_dn=233.10  B73_dn=262.15
TIL18: y=72.02-192.24   Mi21: y=222.13-342.35   B73: y=372.24-478.66
mid: TIL18=184.85  Mi21=186.83  B73=236.81
ticks: 175=175.07  200=340.86  225=506.65  250=672.43
```

**PT variant** (standalone 648×432):
```
up_x=147.70  TIL18_dn=225.08  PT_dn=226.45  B73_dn=237.06
TIL18: y=57.75-140.45   PT: y=170.33-253.03   B73: y=282.91-351.81
mid: TIL18=168.76  PT=170.64  B73=214.67
ticks: 175=160.11  200=306.61  225=453.10  250=599.59
```

### Key parameters
| Parameter | Value |
|-----------|-------|
| Colors | `col_inv4m="purple4"`, `col_knob="#1d7f7a"`, `col_gold="gold"` |
| x-axis range | `c(163e6, 250e6)` |
| x-axis breaks | `seq(175e6, 250e6, by=25e6)` |
| Font sizes | `sz_name=24`, `sz_species=22`, base_size=22 |
| Linewidth | `lw=1.2` (all vlines, connections) |
| Arrow geometry | `a_h=4, a_gap=1.2, a_pt=8` (svg units) |
| draw_plot inset | `x=0.03, y=0.08, width=0.95, height=0.86` |
| Inv4m label | `x=0.32` (NPC, centered between breakpoints) |

## Useful techniques

### Sigmoid curves for inversion crossing lines

```r
sigmoid_path <- function(x1, y1, x2, y2, n = 50) {
  t <- seq(-6, 6, length.out = n)
  s <- 1 / (1 + exp(-t))
  data.frame(x = x1 + (x2 - x1) * s,
             y = y1 + (y2 - y1) * seq(0, 1, length.out = n))
}
```

### Text shadow for gold-on-white

```r
draw_label("TR-1", x = 0.761, y = 0.953, color = "gray30", ...)
draw_label("TR-1", x = 0.76,  y = 0.955, color = "gold", ...)
```

### Mixed italic/plain text

```r
draw_grob(gridtext::richtext_grob(
  "teosinte *mexicana*",
  box_gp = grid::gpar(col = NA, fill = NA)))
```

Note: `gridtext::richtext_grob` can double-render in some contexts. If italic text appears twice, switch to plain `draw_label` with `fontface = "italic"`.
