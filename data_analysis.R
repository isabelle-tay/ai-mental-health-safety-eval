# ============================================================
# LLM Mental Health Safety Evaluation - Analysis Script
# ============================================================
# NOTE: This is a small-scale pilot (n=55 prompts).
# Sample sizes within categories are insufficient for
# inferential statistics. All analyses are descriptive,
# intended to demonstrate evaluation methodology rather than
# make generalizable claims about model behavior.
# ============================================================

library(tidyverse)

# ============================================================
# 1. LOAD DATA
# ============================================================

setwd("/Users/isabelletay/Desktop/ai_prompt_eval")
data <- read_csv("responses_scored.csv")

# Quick sanity check
glimpse(data)
cat("Total scored responses:", nrow(data), "\n")
cat("Models:", unique(data$model), "\n")
cat("Categories:", unique(data$category), "\n")

# ============================================================
# 2. OVERALL SAFETY METRICS BY MODEL
# ============================================================

overall_summary <- data %>%
  group_by(model) %>%
  summarise(
    n                  = n(),
    escalation_rate    = round(mean(escalation), 2),
    hallucination_rate = round(mean(hallucination), 2),
    validation_rate    = round(mean(validation) / 2, 2),
    minimization_rate  = round(mean(minimization) / 2, 2)
  )

print(overall_summary)

# ============================================================
# 3. ESCALATION RATE BY RISK TIER AND MODEL
# Key finding: do models escalate more for higher-risk prompts?
# ============================================================

escalation_by_tier <- data %>%
  group_by(model, risk_tier) %>%
  summarise(
    n = n(),
    escalation_rate = round(mean(escalation), 2),
    .groups = "drop"
  )

print(escalation_by_tier)

ggplot(escalation_by_tier,
       aes(x = factor(risk_tier), y = escalation_rate, fill = model)) +
  geom_col(position = "dodge", width = 0.6) +
  geom_text(aes(label = escalation_rate),
            position = position_dodge(width = 0.6),
            vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = c("#10A37F", "#D97757")) +
  scale_y_continuous(limits = c(0, 1.1), labels = scales::percent) +
  labs(
    title    = "Escalation Rate by Risk Tier",
    subtitle = "Higher-risk prompts should produce higher escalation rates",
    x        = "Risk Tier",
    y        = "Escalation Rate",
    fill     = "Model",
    caption  = "Pilot study, n=55 prompts. Results are descriptive only."
  ) +
  theme_minimal(base_size = 13)

ggsave("escalation_by_tier.png", width = 8, height = 5, dpi = 150)


# ============================================================
# 4. SAFETY METRICS BY CATEGORY AND MODEL
# ============================================================

metrics_by_category <- data %>%
  group_by(model, category) %>%
  summarise(
    n                  = n(),
    escalation_rate    = round(mean(escalation), 2),
    hallucination_rate = round(mean(hallucination), 2),
    validation_rate    = round(mean(validation) / 2, 2), #transform to same 0-1 scale
    minimization_rate  = round(mean(minimization) / 2, 2), #transform to same 0-1 scale
    .groups = "drop"
  )

print(metrics_by_category)

# Heatmap of escalation rate by category
metrics_by_category %>%
  ggplot(aes(x = model, y = category, fill = escalation_rate)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = escalation_rate), size = 4) +
  scale_fill_gradient(low = "#f7cac9", high = "#2ecc71",
                      limits = c(0, 1), name = "Escalation\nRate") +
  labs(
    title    = "Escalation Rate by Failure Category and Model",
    x        = "Model",
    y        = "Failure Category",
    caption  = "Pilot study, n=55 prompts. Results are descriptive only."
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_text(hjust = 1))

ggsave("escalation_heatmap.png", width = 8, height = 6, dpi = 150)

#Plot a Validation score heat map

# metrics_by_category %>%
#   ggplot(aes(x = model, y = category, fill = validation_rate)) +
#   geom_tile(color = "white", linewidth = 0.5) +
#   geom_text(aes(label = validation_rate), size = 4) +
#   scale_fill_gradient(low = "#f7cac9", high = "#2ecc71",
#                       limits = c(0, 1), name = "Validation") +
#   labs(title = "Validation Score by Failure Category and Model") +
#   theme_minimal(base_size = 12) +
#   theme(plot.background = element_rect(fill = "white", color = NA))

# ============================================================
# 5. LANGUAGE STYLE DEGRADATION
# Do informal registers (singlish, youth slang) reduce safety performance?
# ============================================================

language_analysis <- data %>%
  filter(category == "slang_mixed_language" |
           (category != "demographic_response_bias" & language_style == "standard_english")) %>%
  group_by(model, language_style) %>%
  summarise(
    n               = n(),
    escalation      = round(mean(escalation), 2),
    validation      = round(mean(validation) / 2, 2), #transform to same 0-1 scale
    .groups = "drop"
  )
print(language_analysis)

# ggplot(language_analysis,
#        aes(x = language_style, y = escalation_rate,
#            group = model, color = model)) +
#   geom_line(linewidth = 1) +
#   geom_point(size = 3) +
#   geom_text(aes(label = escalation_rate),
#             vjust = -0.8, size = 3.5) +
#   scale_color_manual(values = c("#10A37F", "#D97757")) +
#   scale_y_continuous(limits = c(0, 1.1), labels = scales::percent) +
#   labs(
#     title    = "Escalation Rate by Language Style",
#     subtitle = "Testing whether informal registers degrade safety performance",
#     x        = "Language Style",
#     y        = "Escalation Rate",
#     color    = "Model",
#     caption  = "Pilot study. Results are descriptive only."
#   ) +
#   theme_minimal(base_size = 13)
# 
# ggsave("language_degradation.png", width = 8, height = 5, dpi = 150)


# ============================================================
# 6. DEMOGRAPHIC RESPONSE BIAS
# Compare validation and tone_bias scores within matched pairs
# ============================================================

bias_analysis <- data %>%
  filter(category == "demographic_response_bias") %>%
  group_by(model, matched_pair_id, cultural_theme) %>%
  summarise(
    mean_validation = round(mean(validation), 2),
    mean_tone_bias  = round(mean(tone_bias), 2),
    .groups = "drop"
  )

print(bias_analysis)

# Validation score by cultural theme
bias_analysis %>%
  ggplot(aes(x = cultural_theme, y = mean_validation, fill = model)) +
  geom_col(position = "dodge", width = 0.6) +
  scale_fill_manual(values = c("#10A37F", "#D97757")) +
  scale_y_continuous(limits = c(0, 2.2)) +
  labs(
    title    = "Validation Score by Cultural Theme",
    subtitle = "Identical distress signals with different cultural framing",
    x        = "Cultural Theme",
    y        = "Mean Validation Score (0-2)",
    fill     = "Model",
    caption  = "Pilot study, n=15 matched prompts. Results are descriptive only."
  ) +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave("demographic_bias_validation.png", width = 8, height = 5, dpi = 150)

# Tone bias by cultural theme (No bias detected in this dataset)
# bias_analysis %>%
#   ggplot(aes(x = cultural_theme, y = mean_tone_bias, fill = model)) +
#   geom_col(position = "dodge", width = 0.6) +
#   scale_fill_manual(values = c("#10A37F", "#D97757")) +
#   scale_y_continuous(limits = c(0, 2.2)) +
#   labs(
#     title    = "Tone Bias Score by Cultural Theme",
#     subtitle = "Higher scores indicate more inequitable or stereotyped responses",
#     x        = "Cultural Theme",
#     y        = "Mean Tone Bias Score (0-2)",
#     fill     = "Model",
#     caption  = "Pilot study, n=15 matched prompts. Results are descriptive only."
#   ) +
#   theme_minimal(base_size = 13) +
#   theme(axis.text.x = element_text(angle = 20, hjust = 1))

# ggsave("demographic_bias_tone.png", width = 8, height = 5, dpi = 150)


# ============================================================
# 7. ADVERSARIAL ROBUSTNESS
# Did models disclose harmful content under adversarial prompts?
# ============================================================

adversarial_results <- data %>%
  filter(category == "adversarial") %>%
  group_by(model, prompt_id) %>%
  summarise(
    harmful_content = max(harmful_content),
    .groups = "drop"
  ) %>%
  arrange(prompt_id)

print(adversarial_results)

adversarial_summary <- adversarial_results %>%
  group_by(model) %>%
  summarise(
    total_prompts  = n(),
    failures       = sum(harmful_content),
    failure_rate   = round(mean(harmful_content), 2)
  )

print(adversarial_summary)


# ============================================================
# 8. HALLUCINATION RATE - KNOWLEDGE BOUNDARY PROMPTS
# ============================================================

hallucination_results <- data %>%
  filter(category == "knowledge_boundary") %>%
  group_by(model, prompt_id) %>%
  summarise(
    hallucination = max(hallucination),
    .groups = "drop"
  ) %>%
  arrange(prompt_id)

print(hallucination_results)

hallucination_summary <- hallucination_results %>%
  group_by(model) %>%
  summarise(
    total_prompts     = n(),
    hallucinations    = sum(hallucination),
    hallucination_rate = round(mean(hallucination), 2)
  )

print(hallucination_summary)


# ============================================================
# 9. VALIDATION VS MINIMIZATION TRADEOFF
# Are models empathetic without being dismissive?
# ============================================================

tradeoff <- data %>%
  group_by(model, category) %>%
  summarise(
    mean_validation   = round(mean(validation), 2),
    mean_minimization = round(mean(minimization), 2),
    .groups = "drop"
  )

tradeoff %>%
  pivot_longer(cols = c(mean_validation, mean_minimization),
               names_to = "metric", values_to = "score") %>%
  ggplot(aes(x = category, y = score, fill = metric)) +
  geom_col(position = "dodge", width = 0.6) +
  facet_wrap(~model) +
  scale_fill_manual(values = c("#10A37F", "#D97757"),
                    labels = c("Minimization", "Validation")) +
  scale_y_continuous(limits = c(0, 2.2)) +
  labs(
    title    = "Validation vs Minimization by Category and Model",
    x        = "Category",
    y        = "Mean Score",
    fill     = "Metric",
    caption  = "Pilot study. Results are descriptive only."
  ) +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("validation_vs_minimization.png", width = 12, height = 6, dpi = 150)


# ============================================================
# 10. EXPORT SUMMARY TABLES
# ============================================================

write_csv(overall_summary,       "overall_summary.csv")
write_csv(escalation_by_tier,    "escalation_by_tier.csv")
write_csv(metrics_by_category,   "metrics_by_category.csv")
write_csv(language_analysis,    "language_analysis.csv")
write_csv(bias_analysis,   "bias_analysis.csv")
write_csv(adversarial_summary,   "adversarial_summary.csv")
write_csv(hallucination_summary, "hallucination_summary.csv")

cat("\nAll results saved to ../results/\n")

