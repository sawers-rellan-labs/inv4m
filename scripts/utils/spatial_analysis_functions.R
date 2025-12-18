# ============================================================================
# SPATIAL ANALYSIS FUNCTIONS FOR INV4M EXPERIMENT
# ============================================================================
# This script contains helper functions for the spatial analysis
# Source this file from the main R Markdown notebook

# Function to create spatial heat maps
plot_trait_spatial <- function(data, trait, title, midpoint = NULL) {
  if (is.null(midpoint)) {
    midpoint <- median(data[[trait]], na.rm = TRUE)
  }
  
  ggplot(data, aes(x = x, y = y)) +
    geom_point(aes(color = get(trait)), size = 2) +
    scale_color_gradient2(low = "blue", mid = "white", high = "red",
                          midpoint = midpoint) +
    facet_wrap(~block, labeller = labeller(block = function(x) paste("Block", x))) +
    labs(title = title, color = trait, x = "X Position", y = "Y Position") +
    coord_equal() +
    theme_minimal()
}

# Function to extract treatment effects from any model
extract_treatment_effects <- function(model, model_name = NULL) {
  fe <- fixef(model)
  se <- sqrt(diag(vcov(model)))
  
  # Get indices for treatment effects
  idx <- grep("donor|inv4m", names(fe))
  
  if (length(idx) > 0) {
    df <- data.frame(
      effect = names(fe)[idx],
      estimate = fe[idx],
      se = se[idx],
      t_value = fe[idx] / se[idx],
      p_value = 2 * pnorm(-abs(fe[idx] / se[idx])),
      row.names = NULL
    )
    
    if (!is.null(model_name)) {
      df$model <- model_name
    }
    
    return(df)
  } else {
    return(NULL)
  }
}

# Function to create directional variograms
create_directional_variograms <- function(data, response, angles = c(0, 45, 90, 135)) {
  sp_data <- data
  coordinates(sp_data) <- ~x+y
  
  vario_dir <- variogram(as.formula(paste(response, "~ 1")), 
                         data = sp_data,
                         alpha = angles,
                         cutoff = 30)
  
  return(vario_dir)
}

# Function to fit model hierarchy
fit_model_hierarchy <- function(data, response = "DTA", verbose = TRUE) {
  
  models <- list()
  
  # Base formula components
  base_formula <- paste(response, "~ donor * inv4m")
  
  # Model 0: Null
  if (verbose) cat("Fitting Null model...\n")
  models$Null <- gls(as.formula(paste(response, "~ 1")), 
                     data = data, method = "REML")
  
  # Model 1: Treatment only
  if (verbose) cat("Fitting Treatment model...\n")
  models$Treatment <- gls(as.formula(base_formula), 
                          data = data, method = "REML")
  
  # Model 2: Treatment + Block
  if (verbose) cat("Fitting Treatment + Block model...\n")
  models$`Treatment + Block` <- gls(as.formula(paste(base_formula, "+ block")), 
                                    data = data, method = "REML")
  
  # Model 3: Treatment + Block + Trends
  if (verbose) cat("Fitting Treatment + Block + Trends model...\n")
  models$`Treatment + Block + Trends` <- gls(
    as.formula(paste(base_formula, "+ block + poly(x_c, 2) + poly(y_c, 2)")), 
    data = data, method = "REML"
  )
  
  # Model 4: Add plot random effect
  if (verbose) cat("Fitting model with Plot random effects...\n")
  models$`T + B + Trends + Plot RE` <- lme(
    as.formula(paste(base_formula, "+ block + poly(x_c, 2) + poly(y_c, 2)")),
    random = ~ 1 | plot_id,
    data = data, method = "REML"
  )
  
  # Model 5: Spatial only
  if (verbose) cat("Fitting Spatial correlation model...\n")
  models$`T + B + Trends + Spatial` <- tryCatch({
    gls(as.formula(paste(base_formula, "+ block + poly(x_c, 2) + poly(y_c, 2)")),
        correlation = corSpher(form = ~ x + y | block, nugget = TRUE),
        data = data, method = "REML")
  }, error = function(e) {
    if (verbose) cat("  Spatial model failed:", e$message, "\n")
    NULL
  })
  
  # Model 6: Plot RE + Spatial
  if (verbose) cat("Fitting combined Plot RE + Spatial model...\n")
  models$`T + B + Trends + Plot RE + Spatial` <- tryCatch({
    lme(as.formula(paste(base_formula, "+ block + poly(x_c, 2) + poly(y_c, 2)")),
        random = ~ 1 | plot_id,
        correlation = corSpher(form = ~ x + y | block, nugget = TRUE),
        data = data, method = "REML",
        control = lmeControl(opt = "optim", maxIter = 200))
  }, error = function(e) {
    if (verbose) cat("  Combined model failed:", e$message, "\n")
    NULL
  })
  
  # Remove NULL models
  models <- models[!sapply(models, is.null)]
  
  return(models)
}

# Function to create model comparison table
create_model_comparison <- function(models) {
  comparison <- data.frame(
    Model = names(models),
    AIC = sapply(models, AIC),
    BIC = sapply(models, BIC),
    logLik = sapply(models, logLik),
    df = sapply(models, function(x) attr(logLik(x), "df"))
  )
  
  # Add delta AIC and BIC
  comparison$deltaAIC <- comparison$AIC - min(comparison$AIC)
  comparison$deltaBIC <- comparison$BIC - min(comparison$BIC)
  
  # Sort by AIC
  comparison <- comparison[order(comparison$AIC), ]
  
  return(comparison)
}

# Function to extract variance components
extract_variance_components <- function(models) {
  var_comp_list <- list()
  
  for (mod_name in names(models)) {
    mod <- models[[mod_name]]
    if (inherits(mod, "lme")) {
      vc <- VarCorr(mod)
      
      # Extract variance values
      if ("plot_id" %in% rownames(vc)) {
        var_plot <- as.numeric(vc["plot_id", "Variance"])
        var_resid <- as.numeric(vc["Residual", "Variance"])
        
        var_comp_list[[mod_name]] <- data.frame(
          Model = mod_name,
          Plot_Variance = var_plot,
          Residual_Variance = var_resid,
          Total_Variance = var_plot + var_resid,
          ICC = var_plot / (var_plot + var_resid),
          Percent_Plot = 100 * var_plot / (var_plot + var_resid)
        )
      }
    }
  }
  
  if (length(var_comp_list) > 0) {
    var_comp_df <- do.call(rbind, var_comp_list)
    row.names(var_comp_df) <- NULL
    return(var_comp_df)
  } else {
    return(NULL)
  }
}

# Function to perform BLUP analysis
analyze_blups <- function(model, plot_data) {
  # Extract BLUPs
  blups <- ranef(model)
  
  if ("plot_id" %in% names(blups)) {
    plot_blups <- blups$plot_id
    
    # Merge with plot information
    plot_info <- plot_data %>%
      select(plot_id, donor, inv4m, treatment)
    
    plot_info$blup <- plot_blups[match(plot_info$plot_id, rownames(plot_blups)), 1]
    
    # Test for correlation with treatment
    blup_aov <- aov(blup ~ donor * inv4m, data = plot_info)
    
    return(list(
      plot_info = plot_info,
      anova = blup_aov,
      summary = summary(blup_aov)
    ))
  } else {
    return(NULL)
  }
}

# Function for comprehensive residual diagnostics
residual_diagnostics <- function(model, data, trait) {
  # Add fitted values and residuals to data
  data$fitted <- fitted(model)
  data$residuals <- residuals(model, type = "normalized")
  
  # Create diagnostic plots
  plots <- list()
  
  # Residuals vs Fitted
  plots$resid_fitted <- ggplot(data, aes(x = fitted, y = residuals)) +
    geom_point(alpha = 0.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    geom_smooth(method = "loess", se = TRUE) +
    labs(title = paste("Residuals vs Fitted Values -", trait),
         x = "Fitted Values", y = "Normalized Residuals") +
    theme_minimal()
  
  # Q-Q plot
  plots$qq <- ggplot(data, aes(sample = residuals)) +
    stat_qq() +
    stat_qq_line(color = "red") +
    labs(title = paste("Q-Q Plot of Residuals -", trait)) +
    theme_minimal()
  
  # Spatial residuals
  plots$spatial <- ggplot(data, aes(x = x, y = y)) +
    geom_point(aes(color = residuals), size = 2) +
    scale_color_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
    facet_wrap(~block) +
    labs(title = paste("Spatial Distribution of Residuals -", trait),
         color = "Residual") +
    coord_equal() +
    theme_minimal()
  
  # Residuals by treatment
  plots$treatment <- ggplot(data, aes(x = treatment, y = residuals)) +
    geom_boxplot() +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    labs(title = paste("Residuals by Treatment -", trait),
         x = "Treatment", y = "Normalized Residuals") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(plots)
}

# Function to perform multi-trait analysis
analyze_multiple_traits <- function(data, traits, model_type = "plot_re") {
  results <- list()
  
  for (trait in traits) {
    # Skip if insufficient data
    if (sum(!is.na(data[[trait]])) < 100) {
      cat("Skipping", trait, "- insufficient data\n")
      next
    }
    
    cat("\nAnalyzing", trait, "...\n")
    
    # Fit model based on type
    if (model_type == "plot_re") {
      formula <- as.formula(paste(trait, "~ donor * inv4m + block + poly(x_c, 2) + poly(y_c, 2)"))
      
      mod <- tryCatch({
        lme(formula,
            random = ~ 1 | plot_id,
            data = data,
            method = "REML",
            na.action = na.omit)
      }, error = function(e) {
        cat("  Model failed for", trait, ":", e$message, "\n")
        NULL
      })
    }
    
    if (!is.null(mod)) {
      results[[trait]] <- list(
        model = mod,
        effects = extract_treatment_effects(mod, trait),
        emmeans = emmeans(mod, ~ donor * inv4m),
        contrasts = pairs(emmeans(mod, ~ donor * inv4m), adjust = "tukey")
      )
    }
  }
  
  return(results)
}

# Function to create summary report
create_summary_report <- function(models, var_comp, trait_results, output_dir) {
  
  # Best model identification
  model_comp <- create_model_comparison(models)
  best_model_name <- model_comp$Model[1]
  best_model <- models[[best_model_name]]
  
  # Create summary text
  summary_text <- paste0(
    "SPATIAL MIXED MODEL ANALYSIS SUMMARY\n",
    "====================================\n\n",
    "Date: ", Sys.Date(), "\n",
    "Best Model (by AIC): ", best_model_name, "\n",
    "Model AIC: ", round(model_comp$AIC[1], 2), "\n\n",
    
    "VARIANCE COMPONENTS\n",
    "-------------------\n"
  )
  
  if (!is.null(var_comp) && best_model_name %in% var_comp$Model) {
    vc <- var_comp[var_comp$Model == best_model_name, ]
    summary_text <- paste0(summary_text,
      "Plot-level variance: ", round(vc$Plot_Variance, 3), "\n",
      "Residual variance: ", round(vc$Residual_Variance, 3), "\n",
      "ICC: ", round(vc$ICC, 3), " (", round(vc$Percent_Plot, 1), "% at plot level)\n\n"
    )
  }
  
  summary_text <- paste0(summary_text,
    "TREATMENT EFFECTS\n",
    "-----------------\n"
  )
  
  # Add treatment effects
  effects <- extract_treatment_effects(best_model)
  for (i in 1:nrow(effects)) {
    summary_text <- paste0(summary_text,
      effects$effect[i], ": ", round(effects$estimate[i], 3), 
      " (SE = ", round(effects$se[i], 3), ", p = ", 
      format.pval(effects$p_value[i], digits = 3), ")\n"
    )
  }
  
  # Save summary
  writeLines(summary_text, file.path(output_dir, "analysis_summary.txt"))
  
  return(summary_text)
}

# Utility function for creating publication-ready tables
create_publication_table <- function(model, traits = NULL) {
  if (is.null(traits)) {
    # Single model table
    effects <- extract_treatment_effects(model)
    effects$CI_lower <- effects$estimate - 1.96 * effects$se
    effects$CI_upper <- effects$estimate + 1.96 * effects$se
    effects$p_value <- format.pval(effects$p_value, digits = 3)
    
    return(effects)
  } else {
    # Multi-trait table
    # Implementation for multiple traits
    # ... (additional code as needed)
  }
}
