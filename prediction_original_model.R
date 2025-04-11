# Load required libraries
library(tidyverse)
library(tidymodels)
library(textrecipes)
library(ranger)

# 1. Load your trained model
final_model <- readRDS("goodreads_rating_predictor_50k.rds")

# 2. Create new reviews to predict
new_reviews <- tibble(
  review_text = c(
    "This was a good book to read as an overthinker haha. The main message is that thinking = suffering and unhappiness. It claims that the neutral state of the mind is joy because when we feel joy there are usually no thoughts in our head. Talks a lot about trusting your intuition and that it will lead you to a place where you are meant to be. The way this book was written was horrible, even tho it was so short, it was so repetitive and had no science behind it, it was more spiritual if anything. Had some useful practical tips but a lot of it was just yapping about the same thing 'just stop thinking'",
    
    "Finished this book, I'm just glad it's over tbh. The main character, a middle aged librarian who got accused of spying on a teenager having sex in the bathrooms, is so unlikeable and I don't understand how her brain works at all. Also although the book uses normal language it was somehow very hard to follow and understand what's going on. Maybe on a second read it'd be more enjoyable",
    
    "Just finished the first book of the year. The author is one of the greatest polish authors of this lifetime, she won a novel prize for literature. Idk. This book didn't really sit right with me. The beginning was by far the best part, and it lost me a bit throughout. It's a story of an older lady living in a small village who's unhinged, loves astrology, is a bit unstable. There's 3 murders that happen in this village and she believes it's the animals taking revenge (the victims were hunters). Still quite enjoyable but it was painfully obvious how the author is using this story to tell us her political and theological views.",
    
    "it was okay, a bit underwhelming, but I'm not mad about it",
    
    "I'm not sure what the author was thinking when writing the main character, she's so unlikeable, it made the book so unenjoyable"
  )
)

# 3. Make predictions
predictions <- predict(final_model, new_data = new_reviews)

# 4. Combine predictions with original reviews
results <- new_reviews %>%
  bind_cols(predictions) %>%
  select(review_text, predicted_rating = .pred_class)

# 5. Print results with formatting
cat("══════════════════════════════════════════════════════════════════════════════\n")
cat("                            GOODREADS RATING PREDICTIONS                      \n")
cat("══════════════════════════════════════════════════════════════════════════════\n\n")

for (i in 1:nrow(results)) {
  cat(sprintf("REVIEW %d - PREDICTED RATING: ★%s\n", i, results$predicted_rating[i]))
  cat("--------------------------------------------------------------------------\n")
  cat(strwrap(results$review_text[i], width = 80), sep = "\n")
  cat("\n\n")
}

# 6. Save predictions to CSV
write_csv(results, "goodreads_predictions.csv")
cat("\nPredictions saved to 'goodreads_predictions.csv'\n")