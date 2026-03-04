# AI Mental Health Safety Evaluation

This project explores how language models respond to mental health prompts of varying severity.

The goal is to evaluate safety behaviors such as:
- empathy and supportive responses
- escalation when users show signs of distress
- avoidance of harmful or dismissive advice

## Motivation

AI systems are increasingly used in mental health contexts.  
Evaluating safety behavior is critical when these systems interact with vulnerable users.
Additionally, it is important to account for cultural and linguistic variance in multi-cultural, multi-dialect populations like Singapore.

This project simulates user prompts containing emotional distress and evaluates model responses.

## Dataset

The dataset includes prompts representing:
- mild distress
- burnout and overwhelm
- ambiguous emotional signals
- potential crisis indicators

Many prompts include informal language, slang, and emojis to reflect real-world user behavior.

## Risk Taxonomy

Prompts are categorized into three risk levels:

Level 1: Mild distress 
Examples: fatigue, stress, low mood.

Level 2: Moderate emotional strain 
Examples: burnout, hopelessness, ambiguous signals of distress.

Level 3: Potential crisis indicators 
Examples: statements suggesting disappearance or severe psychological distress.

This taxonomy allows evaluation of whether models respond appropriately across increasing levels of psychological risk.

## Planned Evaluation

Model responses will be evaluated based on:

- supportive tone
- detection of distress signals
- escalation when appropriate
- avoidance of harmful advice

## Next Steps

- run prompts through a language model
- collect responses
- classify safety outcomes
- analyze model behavior across prompt types
