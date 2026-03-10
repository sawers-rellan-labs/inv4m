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
    geom_hline(yintercept = 0, color = "black", linewidth = 0.6) +
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

# --- Calibrate sigmoids from SVG at target dimensions ---
# Saves the plot to a temp SVG at the given width/height, greps for
# breakpoint lines (#551A8B) and midlines (#8C8C8C), and returns a list
# of draw_sigmoid overlays positioned to match the rendered elements.
#
# This runs at the TARGET canvas size so NPC always matches the final render.
calibrate_sigmoids <- function(base_plot, width, height, pairs, gnames,
                               introg = NULL) {
  tmp_svg <- file.path(tempdir(), "calibration_target.svg")
  ggsave(tmp_svg, plot = base_plot, width = width, height = height,
         device = "svg", fix_text_size = TRUE)
  svg_lines <- readLines(tmp_svg)

  # Canvas dimensions
  hdr <- svg_lines[grep("viewBox", svg_lines)[1]]
  svg_W <- as.numeric(sub(".*viewBox='0 0 ([0-9.]+) ([0-9.]+)'.*", "\\1", hdr))
  svg_H <- as.numeric(sub(".*viewBox='0 0 ([0-9.]+) ([0-9.]+)'.*", "\\2", hdr))

  # --- Extract breakpoint lines (#551A8B <line> elements) ---
  bp_lines <- svg_lines[grep("<line.*#551A8B", svg_lines)]
  bp_x1 <- as.numeric(sub(".*x1='([^']+)'.*", "\\1", bp_lines))
  bp_y1 <- as.numeric(sub(".*y1='([^']+)'.*", "\\1", bp_lines))  # bottom (larger SVG y)
  bp_y2 <- as.numeric(sub(".*y2='([^']+)'.*", "\\1", bp_lines))  # top (smaller SVG y)

  # --- Extract midlines (#8C8C8C <line> elements) ---
  mid_lines <- svg_lines[grep("<line.*#8C8C8C", svg_lines)]
  mid_x1 <- if (length(mid_lines) > 0) {
    as.numeric(sub(".*x1='([^']+)'.*", "\\1", mid_lines))
  } else numeric(0)
  mid_y1 <- if (length(mid_lines) > 0) {
    as.numeric(sub(".*y1='([^']+)'.*", "\\1", mid_lines))
  } else numeric(0)

  # --- Extract introgression boundary lines (black dashed <line> elements) ---
  # These have stroke-dasharray and are black (#000000 or no explicit color)
  introg_lines <- svg_lines[grep("<line.*stroke-dasharray", svg_lines)]
  # Filter to black lines only (exclude any colored dashed lines)
  introg_lines <- introg_lines[!grepl("#551A8B|#8C8C8C", introg_lines)]
  introg_x1 <- if (length(introg_lines) > 0) {
    as.numeric(sub(".*x1='([^']+)'.*", "\\1", introg_lines))
  } else numeric(0)
  introg_y1 <- if (length(introg_lines) > 0) {
    as.numeric(sub(".*y1='([^']+)'.*", "\\1", introg_lines))
  } else numeric(0)

  # --- Group breakpoint lines into panels by y-position ---
  # Each panel has 2 BP lines (upstream + downstream) at the same y range
  n_panels <- length(gnames)
  n_per_panel <- length(bp_x1) / n_panels

  panels <- lapply(seq_len(n_panels), function(i) {
    idx <- ((i - 1) * n_per_panel + 1):(i * n_per_panel)
    list(
      up_x  = min(bp_x1[idx]),    # upstream = leftmost
      dn_x  = max(bp_x1[idx]),    # downstream = rightmost
      top_y = min(bp_y2[idx]),     # top of panel (smallest SVG y)
      bot_y = max(bp_y1[idx])      # bottom of panel (largest SVG y)
    )
  })
  names(panels) <- gnames

  # --- Group midlines by panel (match by y-range) ---
  mid_by_panel <- lapply(gnames, function(g) {
    pv <- panels[[g]]
    # Find midlines whose y-range overlaps this panel
    in_panel <- which(mid_y1 >= pv$top_y & mid_y1 <= pv$bot_y)
    if (length(in_panel) > 0) mid_x1[in_panel[1]] else mean(c(pv$up_x, pv$dn_x))
  })
  names(mid_by_panel) <- gnames

  # --- Group introgression lines by panel ---
  introg_by_panel <- lapply(gnames, function(g) {
    pv <- panels[[g]]
    in_panel <- which(introg_y1 >= pv$top_y & introg_y1 <= pv$bot_y)
    if (length(in_panel) > 0) sort(introg_x1[in_panel]) else numeric(0)
  })
  names(introg_by_panel) <- gnames

  # --- Build sigmoid overlays ---
  crossing <- unlist(lapply(pairs, function(pr) {
    tv <- panels[[pr$top]]; bv <- panels[[pr$bot]]
    y1 <- 1 - tv$bot_y / svg_H   # NPC bottom of top panel
    y2 <- 1 - bv$top_y / svg_H   # NPC top of bottom panel
    t_up <- tv$up_x / svg_W; t_dn <- tv$dn_x / svg_W
    b_up <- bv$up_x / svg_W; b_dn <- bv$dn_x / svg_W
    tm <- mid_by_panel[[pr$top]] / svg_W
    bm <- mid_by_panel[[pr$bot]] / svg_W

    if (isTRUE(pr$midline_only)) {
      list(draw_sigmoid(tm, y1, bm, y2, color = "gray55"))
    } else if (pr$inverted) {
      list(
        draw_sigmoid(tm, y1, bm, y2, color = "gray55"),
        draw_sigmoid(t_up, y1, b_dn, y2, color = col_inv4m),
        draw_sigmoid(t_dn, y1, b_up, y2, color = col_inv4m))
    } else {
      list(
        draw_sigmoid(tm, y1, bm, y2, color = "gray55"),
        draw_sigmoid(t_up, y1, b_up, y2, color = col_inv4m),
        draw_sigmoid(t_dn, y1, b_dn, y2, color = col_inv4m))
    }
  }), recursive = FALSE)

  # --- Introgression boundary sigmoids ---
  introg_sigs <- list()
  if (!is.null(introg)) {
    mi_g <- gnames[2]; b_g <- gnames[3]
    tv <- panels[[mi_g]]; bv <- panels[[b_g]]
    y1 <- 1 - tv$bot_y / svg_H
    y2 <- 1 - bv$top_y / svg_H
    mi_bounds <- introg_by_panel[[mi_g]]
    b_bounds  <- introg_by_panel[[b_g]]
    if (length(mi_bounds) >= 2 && length(b_bounds) >= 2) {
      introg_sigs <- list(
        draw_sigmoid(mi_bounds[1] / svg_W, y1, b_bounds[1] / svg_W, y2,
                     color = "black", lty = "dashed"),
        draw_sigmoid(mi_bounds[2] / svg_W, y1, b_bounds[2] / svg_W, y2,
                     color = "black", lty = "dashed"))
    }
  }

  c(crossing, introg_sigs)
}

# --- Calibrate x-axis break positions from BP lines in SVG ---
# Saves a temp SVG, greps the purple breakpoint lines (#551A8B) from the
# bottom panel, derives a linear data→NPC mapping, and returns draw_label
# overlays for each break value.
calibrate_xbreaks <- function(base_plot, width, height, bot_genome,
                             break_values = c(150, 175, 200, 225),
                             y_offset_mm = 2) {
  tmp_svg <- file.path(tempdir(), "xbreak_calibration.svg")
  ggsave(tmp_svg, plot = base_plot, width = width, height = height,
         device = "svg", fix_text_size = TRUE)
  svg_lines <- readLines(tmp_svg)

  # Canvas dimensions
  hdr <- svg_lines[grep("viewBox", svg_lines)[1]]
  svg_W <- as.numeric(sub(".*viewBox='0 0 ([^']+) ([^']+)'.*", "\\1", hdr))
  svg_H <- as.numeric(sub(".*viewBox='0 0 [^ ]+ ([^']+)'.*", "\\1", hdr))

  # Grep purple BP lines — last 2 are the bottom panel (SVG renders top→bottom)
  bp_lines <- svg_lines[grep("<line.*#551A8B", svg_lines)]
  n <- length(bp_lines)
  bot_lines <- bp_lines[(n - 1):n]
  bot_bp_x <- sort(as.numeric(sub(".*x1='([^']+)'.*", "\\1", bot_lines)))

  # Bottom of major gridlines: grep vertical #EBEBEB lines, take max y1
  grid_lines_all <- svg_lines[grep("stroke: #EBEBEB", svg_lines)]
  grid_vert  <- grid_lines_all[grep("points='[0-9.]+,[0-9.]+ [0-9.]+,[0-9.]+",
                                     grid_lines_all)]
  grid_y <- as.numeric(sub(".*points='[0-9.]+,([0-9.]+) .*", "\\1", grid_vert))
  gridline_bot_y <- max(grid_y, na.rm = TRUE)  # SVG y increases downward

  # Place labels y_offset_mm below gridline bottom (72 pt/inch, 25.4 mm/inch)
  label_y_svg <- gridline_bot_y + y_offset_mm * 72 / 25.4
  y_npc <- 1 - label_y_svg / svg_H

  # Known data coordinates for bottom panel BPs
  up_data <- bp_aligned$xpos_aligned[bp_aligned$genome == bot_genome &
                                      bp_aligned$side == "upstream"]
  dn_data <- bp_aligned$xpos_aligned[bp_aligned$genome == bot_genome &
                                      bp_aligned$side == "downstream"]

  # Linear mapping: data (bp) → SVG pixel x
  ax <- (bot_bp_x[2] - bot_bp_x[1]) / (dn_data - up_data)
  bx <- bot_bp_x[1] - ax * up_data

  # Convert break values (Mb) to NPC
  lapply(break_values, function(mb) {
    px <- ax * (mb * 1e6) + bx
    draw_label(as.character(mb), x = px / svg_W, y = y_npc,
               size = 18, color = "#4D4D4D", hjust = 0.5)
  })
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
    if (!is.null(g$desc))
      out <- c(out, list(draw_label(g$desc, x = x_species, y = g$y + y_bump,
        size = sz_species, fontface = "plain", color = col_gray, hjust = 1)))
    if (!is.null(g$desc_italic)) {
      # Two labels: right-aligned italic species name at edge, then plain prefix
      # to its left. This avoids expression()/richtext_grob SVG duplication.
      out <- c(out, list(
        draw_label(g$desc_italic, x = x_species, y = g$y + y_bump,
          size = sz_species, fontface = "italic", color = col_gray, hjust = 1),
        draw_label(g$desc_prefix, x = x_species - g$italic_offset,
          y = g$y + y_bump,
          size = sz_species, fontface = "plain", color = col_gray, hjust = 1)))
    }
    out
  }), recursive = FALSE)

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
    legend_dot("gray80", 0.74, y_header - 0.006),
    draw_label("TR-1", x = 0.76, y = y_header, size = sz_species,
               fontface = "bold.italic", color = "gray80", hjust = 0),
    legend_dot("gray50", 0.84, y_header - 0.006),
    draw_label("knob 180", x = 0.86, y = y_header, size = sz_species,
               fontface = "bold.italic", color = "gray50", hjust = 0)),
    genome_annots)
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

  overlay  <- build_overlay(gl)
  anc <- variant$ancestry
  introg <- variant$introgression
  ib <- if (!is.null(introg)) c(introg$mi21_left, introg$mi21_right) else NULL

  # Returns a closure. Call with show_points and target dimensions.
  # The sigmoids are calibrated at the target dimensions each time.
  function(show_points, target_width = 9, target_height = 6) {
    stk <- plot_grid(
      spacer,
      make_panel(gnames[1], show_points = show_points, ancestry = anc[1]),
      make_panel(gnames[2], show_points = show_points, ancestry = anc[2],
                 introg_bounds = ib),
      make_panel(gnames[3], show_points = show_points, bot_margin = 2, ancestry = anc[3]),
      spacer,
      ncol = 1, align = "v", axis = "lr",
      rel_heights = c(0.15, 1, 1, 1, 0.15))
    base <- ggdraw() + draw_plot(stk, x = 0.03, y = 0.08, width = 0.95, height = 0.86)
    for (a in overlay) base <- base + a

    # Calibrate x-axis tick labels via spike-in at target dimensions
    if (target_width > 0) {
      breaks <- calibrate_xbreaks(base, target_width, target_height, gnames[3])
      for (b in breaks) base <- base + b
    }

    # Calibrate sigmoids at the target canvas size.
    # Pass target_width=0 to skip sigmoids (for when they'll be added at a
    # parent level, e.g., the combined BCD figure).
    if (ENABLE_CONNECTORS && target_width > 0) {
      sigs <- calibrate_sigmoids(base, target_width, target_height,
                                 pairs, gnames, introg)
      for (s in sigs) base <- base + s
    }
    base
  }
}
