#SUCCESSFUL MODEL 1

# Install necessary packages if not already installed
if (!requireNamespace("tidyverse", quietly = TRUE)) install.packages("tidyverse")
if (!requireNamespace("tidymodels", quietly = TRUE)) install.packages("tidymodels")
if (!requireNamespace("textrecipes", quietly = TRUE)) install.packages("textrecipes")
if (!requireNamespace("ranger", quietly = TRUE)) install.packages("ranger")

# Load required libraries
library(tidyverse)
library(tidymodels)
library(textrecipes)
library(ranger)

# 1. Load and balance the dataset
reviews <- read_csv("goodreads_balanced_125k.csv") %>% 
  mutate(rating = as.factor(rating))

# Create balanced subset with 10k per rating
set.seed(42)  # For reproducibility
balanced_reviews <- reviews %>%
  group_by(rating) %>%
  sample_n(10000, replace = FALSE) %>%  # Take 10k from each rating group
  ungroup()

# Save the balanced dataset
write_csv(balanced_reviews, "goodreads_50k_balanced.csv")

# Verify the distribution
cat("Distribution of ratings in balanced dataset:\n")
table(balanced_reviews$rating)

# 2. Train-Test Split
set.seed(42)  # For reproducibility
split <- initial_split(balanced_reviews, strata = rating, prop = 0.8)
train <- training(split)
test <- testing(split)

# 3. Text Preprocessing Recipe
recipe <- recipe(rating ~ review_text, data = train) %>%
  step_mutate(review_text = tolower(review_text)) %>%
  step_mutate(review_text = str_remove_all(review_text, "[^[:alnum:][:space:]]")) %>%
  step_tokenize(review_text) %>%
  step_stopwords(review_text) %>% 
  step_tokenfilter(review_text, max_tokens = 1000) %>%
  step_tfidf(review_text) %>%
  step_normalize(all_numeric_predictors())

# 4. Model Specification
model <- rand_forest(trees = 50) %>%  # Reduced number of trees for faster training
  set_engine("ranger", importance = "permutation") %>% 
  set_mode("classification")

# 5. Create and Train Workflow
wf <- workflow() %>% 
  add_recipe(recipe) %>% 
  add_model(model)

final_model <- fit(wf, data = train)

# 6. Evaluate Model
test_results <- test %>%
  bind_cols(predict(final_model, test))

# Calculate metrics
accuracy <- accuracy(test_results, truth = rating, estimate = .pred_class)
conf_mat <- conf_mat(test_results, truth = rating, estimate = .pred_class)

# Print results
cat("\nModel Performance:\n")
print(paste("Accuracy:", round(accuracy$.estimate, 3)))
print(conf_mat)

# Visualize confusion matrix
conf_mat_plot <- autoplot(conf_mat, type = "heatmap") +
  labs(title = "Confusion Matrix") +
  theme(legend.position = "right")
print(conf_mat_plot)

# 7. Save the trained model
saveRDS(final_model, "goodreads_rating_predictor_50k.rds")

# 8. Variable Importance (if you want to see which words mattered most)
if ("ranger" %in% class(final_model$fit)) {
  vip_plot <- vip::vip(final_model$fit) + 
    labs(title = "Variable Importance")
  print(vip_plot)
}

cat("\nProcess completed successfully!\n")
cat("Saved files:\n")
cat("- Balanced dataset: goodreads_50k_balanced.csv\n")
cat("- Trained model: goodreads_rating_predictor_50k.rds\n")






  
  
  


  
  
# 1. RESET ENVIRONMENT
rm(list = ls())
cat("\014")  # Clear console

# 2. LOAD REQUIRED PACKAGES
required_packages <- c("dplyr", "tidymodels", "stringr", "workflows", "ranger")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# 3. LOAD YOUR TRAINED MODEL
model_path <- "goodreads_rating_predictor_50k.rds"
if (!file.exists(model_path)) {
  stop("Model file not found at: ", normalizePath(model_path))
}
final_model <- readRDS(model_path)
cat("✔ Model loaded successfully\n")

# 4. FULL REVIEWS DATA
reviews_data <- data.frame(
  review_text = c(
    "This was a good book to read as an overthinker haha. The main message is that thinking = suffering and unhappiness. It claims that the neutral state of the mind is joy because when we feel joy there are usually no thoughts in our head. Talks a lot about trusting your intuition and that it will lead you to a place where you are meant to be. The way this book was written was horrible, even tho it was so short, it was so repetitive and had no science behind it, it was more spiritual if anything. Had some useful practical tips but a lot of it was just yapping about the same thing 'just stop thinking'",
    
    "Finished this book, I'm just glad it's over tbh. The main character, a middle aged librarian who got accused of spying on a teenager having sex in the bathrooms, is so unlikeable and I don't understand how her brain works at all. Also although the book uses normal language it was somehow very hard to follow and understand what's going on. Maybe on a second read it'd be more enjoyable",
    
    "Just finished the first book of the year. The author is one of the greatest polish authors of this lifetime, she won a novel prize for literature. Idk. This book didn't really sit right with me. The beginning was by far the best part, and it lost me a bit throughout. It's a story of an older lady living in a small village who's unhinged, loves astrology, is a bit unstable. There's 3 murders that happen in this village and she believes it's the animals taking revenge (the victims were hunters). Still quite enjoyable but it was painfully obvious how the author is using this story to tell us her political and theological views."
  ),
  stringsAsFactors = FALSE
)

# 5. PREDICTION FUNCTION THAT WILL WORK WITH YOUR MODEL
cat("\n🔮 Making predictions...\n")

# First extract the actual ranger model from the workflow
ranger_model <- final_model$fit$fit$fit

# Then prepare the test data using the same recipe from your model
prepped_recipe <- final_model$pre$actions$recipe$recipe
test_preprocessed <- bake(prep(prepped_recipe), new_data = reviews_data)

# Make predictions
predictions <- predict(ranger_model, data = test_preprocessed)$predictions

# Format results
results <- data.frame(
  Review_ID = 1:3,
  Predicted_Rating = predictions,
  Review_Text = substr(reviews_data$review_text, 1, 100)  # First 100 chars
)

# 6. DISPLAY RESULTS
cat("\n═════════ PREDICTION RESULTS ═════════\n")
print(results)

# Save to file
write.csv(results, "goodreads_predictions.csv", row.names = FALSE)
cat("\n✔ Predictions saved to 'goodreads_predictions.csv'\n")