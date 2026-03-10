# fig1_panel_helpers.R
# Figure 1 repeat annotation panel layout helpers.
# Sourced by plot_repeat_analysis.Rmd — depends on its global environment
# (bp_aligned, midlines, to_plot, cfg, color palette, svg, xtick_x).

# --- Ancestry bar geometry ---
bar_y0   <- 103
bar_h    <- 20
arrow_pt <- 2e6  # taper width in bp

make_arrow_polygon <- function(up_bp, dn_bp, direction, fill_col = col_inv4m) {
  if (direction == "left") {
    xs <- c(up_bp, up_bp + arrow_pt, dn_bp, dn_bp, up_bp + arrow_pt)
    ys <- c(bar_y0 + bar_h/2, bar_y0 + bar_h, bar_y0 + bar_h, bar_y0, bar_y0)
  } else {
    xs <- c(up_bp, dn_bp - arrow_pt, dn_bp, dn_bp - arrow_pt, up_bp)
    ys <- c(bar_y0 + bar_h, bar_y0 + bar_h, bar_y0 + bar_h/2, bar_y0, bar_y0)
  }
  annotate("polygon", x = xs, y = ys, fill = fill_col, color = fill_col)
}

# --- Single genome strip panel ---
make_panel <- function(genome_id, show_points = FALSE, bot_margin = 5,
                       ancestry = NULL, introg_bounds = NULL) {
  gbp  <- bp_aligned %>% filter(genome == genome_id)
  gmid <- midlines %>% filter(genome == genome_id)
  gdat <- to_plot %>% filter(genome == genome_id)

  up_bp <- gbp$xpos_aligned[gbp$side == "upstream"]
  dn_bp <- gbp$xpos_aligned[gbp$side == "downstream"]
  seg_ymin <- -3; seg_ymax <- 125

  p <- ggplot() +
    geom_hline(yintercept = 0, color = "gray70", linewidth = 0.4) +
    { if (nrow(gmid) > 0)
        geom_segment(data = gmid, aes(x = xmid_aligned, xend = xmid_aligned,
                     y = seg_ymin, yend = seg_ymax),
                     color = "gray55", linewidth = lw) } +
    geom_segment(data = gbp, aes(x = xpos_aligned, xend = xpos_aligned,
                 y = seg_ymin, yend = seg_ymax),
                 color = col_inv4m, linewidth = lw) +
    { if (genome_id == "B73")
        annotate("segment", x = c(157.01e6, 195.90e6), xend = c(157.01e6, 195.90e6),
                 y = seg_ymin, yend = seg_ymax,
                 color = "black", linewidth = lw, linetype = "dashed") } +
    { if (genome_id == "Mi21")
        annotate("segment", x = c(155.45e6, 190.79e6), xend = c(155.45e6, 190.79e6),
                 y = seg_ymin, yend = seg_ymax,
                 color = "black", linewidth = lw, linetype = "dashed") } +
    { if (show_points)
        geom_point(data = gdat, aes(x = sstart_aligned, y = bitscaled, color = rep),
                   size = 0.6) } +
    { if (show_points)
        scale_color_manual(values = c("knob180" = "gray50", "TR-1" = "gray80"),
                           guide = "none") } +
    # Ancestry bars
    { if (!is.null(ancestry) && ancestry == "b73") {
        list(
          annotate("rect", xmin = -Inf, xmax = up_bp,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_ancestry, color = col_ancestry, alpha = 0.3),
          annotate("rect", xmin = dn_bp, xmax = Inf,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_ancestry, color = col_ancestry, alpha = 0.3),
          make_arrow_polygon(up_bp, dn_bp, "right", fill_col = col_ancestry))
    } } +
    { if (!is.null(ancestry) && ancestry == "mexicana") {
        list(
          annotate("rect", xmin = -Inf, xmax = up_bp,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_inv4m, color = col_inv4m, alpha = 0.3),
          annotate("rect", xmin = dn_bp, xmax = Inf,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_inv4m, color = col_inv4m, alpha = 0.3),
          make_arrow_polygon(up_bp, dn_bp, "left"))
    } } +
    { if (!is.null(ancestry) && ancestry == "nil" && !is.null(introg_bounds)) {
        il <- introg_bounds[1] * 1e6; ir <- introg_bounds[2] * 1e6
        list(
          annotate("rect", xmin = -Inf, xmax = il,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_ancestry, color = col_ancestry, alpha = 0.3),
          annotate("rect", xmin = il, xmax = up_bp,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_inv4m, color = col_inv4m, alpha = 0.3),
          make_arrow_polygon(up_bp, dn_bp, "left"),
          annotate("rect", xmin = dn_bp, xmax = ir,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_inv4m, color = col_inv4m, alpha = 0.3),
          annotate("rect", xmin = ir, xmax = Inf,
                   ymin = bar_y0, ymax = bar_y0 + bar_h,
                   fill = col_ancestry, color = col_ancestry, alpha = 0.3))
    } } +
    scale_x_continuous(labels = unit_format(unit = "", scale = 1e-6),
                       breaks = cfg$xbreaks) +
    scale_y_continuous(breaks = c(0, 25, 50, 75, 100), limits = c(-10, 160),
                       expand = expansion(add = c(10, 50))) +
    coord_cartesian(xlim = cfg$xlim) +
    theme_minimal(base_size = 22) +
    theme(panel.grid.minor = element_blank(),
          plot.margin = margin(t = -15, r = 5, b = 0, l = 5),
          axis.title = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.x = element_blank())
  p
}

# --- SVG arrow grob (breakpoint arrows above/below panel stack) ---
a_h <- 4; a_gap <- 1.2; a_pt <- 8  # half-height, gap, point size in svg units

make_arrow_grob <- function(vlines_cfg, panel, direction) {
  v <- vlines_cfg[[panel]]
  if (direction == "left") {
    cy <- v$top_y - a_gap - a_h - svg$lw
    xs <- c(v$up_x, v$up_x + a_pt, v$dn_x, v$dn_x, v$up_x + a_pt)
    ys <- c(cy,     cy + a_h, cy + a_h, cy - a_h, cy - a_h)
  } else {
    cy <- v$bot_y + a_gap + a_h + svg$lw
    xs <- c(v$up_x, v$dn_x - a_pt, v$dn_x, v$dn_x - a_pt, v$up_x)
    ys <- c(cy + a_h, cy + a_h, cy, cy - a_h, cy - a_h)
  }
  draw_grob(grid::polygonGrob(
    x = unit(xs / svg$W, "npc"), y = unit(1 - ys / svg$H, "npc"),
    gp = grid::gpar(fill = col_inv4m, col = col_inv4m)))
}

# --- Sigmoid curve helpers ---
sigmoid_path <- function(x1, y1, x2, y2, n = 50) {
  t <- seq(-6, 6, length.out = n)
  s <- 1 / (1 + exp(-t))
  data.frame(x = x1 + (x2 - x1) * s,
             y = y1 + (y2 - y1) * seq(0, 1, length.out = n))
}

draw_sigmoid <- function(x1, y1, x2, y2, color, lwd = lw, lty = "solid") {
  pts <- sigmoid_path(x1, y1, x2, y2)
  draw_plot(
    ggplot(pts, aes(x, y)) +
      geom_path(color = color, linewidth = lwd, linetype = lty) +
      scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
      scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
      theme_void(),
    x = 0, y = 0, width = 1, height = 1)
}

# --- Inter-panel connection line builder ---
build_crossing_lines <- function(vlines_cfg, mid_x_cfg, pairs) {
  unlist(lapply(pairs, function(pr) {
    tv <- vlines_cfg[[pr$top]]; bv <- vlines_cfg[[pr$bot]]
    tm <- mid_x_cfg[[pr$top]]; bm <- mid_x_cfg[[pr$bot]]
    y1 <- 1 - tv$bot_y / svg$H
    y2 <- 1 - bv$top_y / svg$H
    t_up <- tv$up_x / svg$W; t_dn <- tv$dn_x / svg$W
    b_up <- bv$up_x / svg$W; b_dn <- bv$dn_x / svg$W

    if (isTRUE(pr$midline_only)) {
      list(draw_sigmoid(tm / svg$W, y1, bm / svg$W, y2, color = "gray55"))
    } else if (pr$inverted) {
      list(
        draw_sigmoid(tm / svg$W, y1, bm / svg$W, y2, color = "gray55"),
        draw_sigmoid(t_up, y1, b_dn, y2, color = col_inv4m),
        draw_sigmoid(t_dn, y1, b_up, y2, color = col_inv4m))
    } else {
      list(
        draw_sigmoid(tm / svg$W, y1, bm / svg$W, y2, color = "gray55"),
        draw_sigmoid(t_up, y1, b_up, y2, color = col_inv4m),
        draw_sigmoid(t_dn, y1, b_dn, y2, color = col_inv4m))
    }
  }), recursive = FALSE)
}

# --- Overlay annotation builder ---
legend_dot <- function(col, x, y) {
  draw_plot(
    ggplot() + annotate("point", x = 0, y = 0, color = col, size = 4) + theme_void(),
    x = x, y = y, width = 0.02, height = 0.02)
}

build_overlay <- function(genome_labels) {
  sz_name    <- 24
  sz_species <- 22
  y_header   <- 0.92
  y_bump     <- 0.02
  y_xtick    <- 0.108

  # Anchor genome names to left plot edge, descriptions to right plot edge
  # Plot area boundaries (from SVG gridline endpoints, not tick marks)
  x_gname   <- 0.092   # left edge of data area
  x_species <- 0.966   # right edge of data area

  genome_annots <- unlist(lapply(genome_labels, function(g) {
    out <- list(draw_label(g$name, x = x_gname, y = g$y + y_bump,
                           size = sz_name, fontface = "bold", hjust = 0))
    if (!is.null(g$desc_html))
      out <- c(out, list(draw_grob(gridtext::richtext_grob(
        g$desc_html,
        x = unit(x_species, "npc"), y = unit(g$y + y_bump, "npc"),
        hjust = 1, gp = grid::gpar(fontsize = sz_species, col = col_gray),
        box_gp = grid::gpar(col = NA, fill = NA)))))
    if (!is.null(g$desc))
      out <- c(out, list(draw_label(g$desc, x = x_species, y = g$y + y_bump,
        size = sz_species, fontface = "plain", color = col_gray, hjust = 1)))
    out
  }), recursive = FALSE)

  xtick_annots <- lapply(names(xtick_x), function(lab) {
    draw_label(lab, x = xtick_x[lab] / svg$W, y = y_xtick,
               size = 18, color = "#4D4D4D", hjust = 0.5)
  })

  white_bg <- draw_grob(grid::rectGrob(
    x = unit(0.5, "npc"), y = unit(y_header, "npc"),
    width = unit(1, "npc"), height = unit(0.06, "npc"),
    gp = grid::gpar(fill = "white", col = NA)))

  c(list(
    white_bg,
    draw_label("Normalized Repeat Match Score", x = 0.02, y = 0.5,
               angle = 90, size = 24),
    draw_label("Chromosome 4 Position [Mb]", x = 0.50, y = 0.056, size = 24),
    draw_label("Inv4m", x = 0.4248, y = 0.855, size = sz_name,
               fontface = "bold.italic", color = col_inv4m, hjust = 0.5),
    legend_dot("gray50", 0.811, y_header - 0.006),
    draw_label("knob 180", x = 0.966, y = y_header, size = sz_species,
               fontface = "bold.italic", color = "gray50", hjust = 1),
    legend_dot("gray80", 0.704, y_header - 0.006),
    draw_label("TR-1", x = 0.726, y = y_header, size = sz_species,
               fontface = "bold.italic", color = "gray80", hjust = 0)),
    genome_annots,
    xtick_annots)
}

# --- Full repeat annotation assembler ---
spacer <- ggplot() + theme_void() + theme(plot.margin = margin(0, 10, 0, 10))

build_repeat_panel <- function(variant) {
  vl    <- variant$vlines
  mx    <- variant$mid_x
  pairs <- variant$pairs
  gl    <- variant$genome_labels
  gnames <- variant$genomes

  svg <<- variant$svg
  xtick_x <<- variant$xtick_x

  crossing <- if (ENABLE_CONNECTORS) build_crossing_lines(vl, mx, pairs) else list()
  overlay  <- build_overlay(gl)
  anc <- variant$ancestry

  introg <- variant$introgression

  introg_sigmoids <- if (ENABLE_CONNECTORS && !is.null(introg)) {
    tx <- variant$xtick_x
    tick_mbs <- as.numeric(names(tx))
    px_per_mb <- (tx[2] - tx[1]) / (tick_mbs[2] - tick_mbs[1])
    mb_to_svg <- function(mb) tx[1] + (mb - tick_mbs[1]) * px_per_mb
    mi_left  <- mb_to_svg(introg$mi21_left)
    mi_right <- mb_to_svg(introg$mi21_right)
    b_left   <- mb_to_svg(introg$b73_left)
    b_right  <- mb_to_svg(introg$b73_right)
    y1 <- 1 - vl[[gnames[2]]]$bot_y / svg$H
    y2 <- 1 - vl[[gnames[3]]]$top_y / svg$H
    list(
      draw_sigmoid(mi_left / svg$W,  y1, b_left / svg$W,  y2,
                   color = "black", lty = "dashed"),
      draw_sigmoid(mi_right / svg$W, y1, b_right / svg$W, y2,
                   color = "black", lty = "dashed"))
  } else list()

  ib <- if (!is.null(introg)) c(introg$mi21_left, introg$mi21_right) else NULL

  function(show_points) {
    stk <- plot_grid(
      spacer,
      make_panel(gnames[1], show_points = show_points, ancestry = anc[1]),
      make_panel(gnames[2], show_points = show_points, ancestry = anc[2],
                 introg_bounds = ib),
      make_panel(gnames[3], show_points = show_points, bot_margin = 2, ancestry = anc[3]),
      spacer,
      ncol = 1, align = "v", axis = "lr",
      rel_heights = c(0.15, 1, 1, 1, 0.15))
    p <- ggdraw() + draw_plot(stk, x = 0.03, y = 0.08, width = 0.95, height = 0.86)
    for (a in overlay)  p <- p + a
    for (a in crossing) p <- p + a
    for (a in introg_sigmoids) p <- p + a
    p + theme(plot.margin = margin(t = -5, unit = "mm"))
  }
}
