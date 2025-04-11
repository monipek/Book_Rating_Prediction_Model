# Book Rating Prediction Machine Learning Model

## Introduction
Every time I finish a book, I instinctively rate it on Goodreads. It has become a ritual. This habit sparked the idea to build a machine learning model that predicts a book’s rating based solely on the text of its review. 

In this project, I used R to develop the model and Deepseek to help with code writing.

## Dataset and Methodology
This project started with a Kaggle dataset of 250,000 Goodreads book reviews that can be found [here](https://www.kaggle.com/competitions/goodreads-books-reviews-290312/overview). To make the task more manageable and fairer, I created a balanced subset of 50,000 reviews, 10,000 for each rating from 1 to 5 stars. This helped ensure all rating categories were equally represented and it also significantly sped up processing time. The dataset included full review texts and their corresponding star ratings, giving me a rich base for text analysis.

I used a Random Forest classifier through the tidymodels framework in R. Preprocessing the text was a key step, where I tokenised the reviews, removed stop words, and applied TF-IDF vectorisation to convert the text into features the model could work with. These steps not only prepared the data for classification but also made it easier to understand which words were most important to the model. I split the data 80/20 into training and test sets, using stratification to keep the rating distributions consistent across both.

## Model Performance and Evaluation


<div align="center">
  
![image](https://github.com/user-attachments/assets/ce76ac5d-d117-4985-ad2d-1345499b3276)

Figure 1

</div>

<div align="center">
  
![image](https://github.com/user-attachments/assets/5ba17af9-5853-4a16-b31a-26d3a514771f)

Figure 2

</div>


| "A Little Life" Review  | Predicted Rating | Actual Rating |
|----------------|------------------|---------------|
| "Brace yourself for the most melodramatic, pretentious, dull, dumb, overwritten, repetitive, laughable, cringe-inducing, self-indulgent, unbelievable, stereotypical, voyeuristic, contrived piece of fiction." | ★1 | ★1 |
| "OMG my poor heart... I can't... If you want to find yourself sobbing late at night for characters you grow so attached to and have to put down the book for a while… this is it. It’s been a very long time since a book utterly broke me..." | ★5 | ★5 |
| "You get a first read only once. I don't know what to say. It's the book of my life. Not that it mirrors my life, but that it's the literary love of my life..." | ★5 | ★5 |
| "edit: after months of sitting on this and finally collecting my thoughts, I can firmly say that I despise this book and I still wish i'd never read it..." | ★1 | ★1 |
| "Well, I finished. Finally.This book came highly recommended... I found many aspects of it compelling, but I also was haunted by a feeling of shallowness... this novel demonstrates to me what not to do if I ever endeavor to write one of my own..." | ★5 | ★2 |
| "Im not sure if it's just me missing some details, but, what really made them become friends and stay as friends? And why are they all so super successful in their fields?" | ★1 | ★3 |

The model reached an accuracy of 46.1% on the test set, more than double the 20% you'd expect from random guessing. It was especially good at predicting the extreme ratings, 1 and 5 stars. For example, as seen in the Confusion Matrix in Figure 2, it correctly identified 1,223 of the 1-star reviews and 1,243 of the 5-star ones. However, it struggled more with the middle ratings (2 to 4 stars), often confusing them with their neighbouring categories. This reflects how subjective these ratings can be. What one person sees as "just okay" (3 stars), another might rate as "good" (4 stars).
 
The model clearly picked up on sentiment: negative words like “pretentious” and “dull” often predicted 1-star reviews, while emotional phrases like “utterly broke me” or “the literary love of my life” were strong indicators of 5-star ratings. Still, the model found it harder to deal with reviews that contained mixed opinions, where the overall tone wasn’t so clear-cut.

## Further Testing with "A Little Life"

To test the model beyond the dataset, I ran it on a very small sample of 6 reviews of one of my favourite books, “A Little Life”. It successfully predicted the most extreme reviews, spot-on for the 1-star and 5-star ratings, thanks to their strong emotional language. But the model struggled with more balanced or mixed reviews. One review, rated 2 stars by the user, was predicted as a 5-star because it praised certain aspects while also being critical. Another 3-star review, written with a fairly negative tone, was misclassified as 1-star. These examples show how tricky it can be to assign a single rating to complex reviews, even for human readers. It made me think it would be interesting to compare how people versus models interpret review sentiment and decide on ratings.

## Future Improvements

The current model only looks at individual words (unigrams), which limits its ability to understand phrases. Adding n-grams (like word pairs or triplets) could really help it grasp context. For instance, while “not” and “good” mean different things on their own, “not good” clearly signals negative sentiment. This would be especially useful for those middle-ground reviews where both praise and criticism are present in the same review which is exactly where the model struggles most.

## Conclusion and Reflections

This project gave me a great look into both machine learning and how people rate books. A 46.1% accuracy might not sound perfect, but it shows that the model can pick up real patterns in how we express our opinions in writing. What I found even more fascinating was how much the model's performance mirrored human behaviour. Just like us, it was more confident at the extremes and less sure in the middle areas.

Ultimately, this project reminded me that book ratings are deeply subjective. Even readers can’t always agree, especially with emotionally complex books like “A Little Life”. Some reviews are so mixed that assigning a single star rating feels almost arbitrary. While machine learning can help us understand trends and make predictions, it also highlights just how personal reading experiences are, and that’s what makes them so interesting.


