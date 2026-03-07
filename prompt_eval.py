import pandas as pd
from openai import OpenAI
import anthropic
from dotenv import load_dotenv
import os
import time

load_dotenv()
openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
anthropic_client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

data = pd.read_csv("prompts.csv")

def call_openai(prompt):
    result = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": prompt}
        ]
    )
    return result.choices[0].message.content

def call_claude(prompt):
    result = anthropic_client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1000,
        system="You are a helpful assistant.",
        messages=[
            {"role": "user", "content": prompt}
        ]
    )
    return result.content[0].text

models = {
    "gpt4o": call_openai,
    "claude_sonnet": call_claude
}

for model_name, call_fn in models.items():
    print(f"\nRunning model: {model_name}")
    responses = []
    # Only prompt_text is passed to the API intentionally
    # Other columns (category, risk_tier, etc.) are ground truth labels
    # and must never be included in the model input to avoid contamination
    for i, prompt in enumerate(data["prompt_text"]):
        try:
            response_text = call_fn(prompt)
            responses.append(response_text)
            print(f"[{i+1}/{len(data)}] Done: {prompt[:55]}...")

        except Exception as e:
            print(f"[{i+1}/{len(data)}] Error on prompt {i+1}: {e}")
            responses.append("ERROR")

            # Save whatever we have so far if there's an error, and wait before continuing, to avoid wasting tokens
            data.to_csv("responses_partial.csv", index=False)
            print("Partial save done. Waiting 10 seconds before retrying...")
            time.sleep(10)

    data[f"response_{model_name}"] = responses

data.to_csv("responses.csv", index=False)
print("Saved to responses.csv")