# Meal Manager

Meal manager gives diet suggestions to my breastfeeding wife.
It defaults to suggest 3 meals per day for each day of the week. It considers
previous meals in order to suggest a balanced diet.

This project relies on [Elixir Langchain](https://github.com/brainlid/langchain) library.

## How to converse with the manager

To start your meal manager:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server`

To initiate a conversation, go to http://localhost:4000/meal_chat

## Example conversation

Here is an example conversation:

**MM:** Hello! I am Jeff the Chef and I'm your personal meal manager! How can I help you today?

**My wife:** Please show me suggestions for breakfast, lunch, and dinner for tomorrow
making sure I follow a healthy and balanced diet. Take into account my previous
meals ensuring that my diet is diverse and meals do not repeat often.

**MM:** Cool. Here is a suggestion for tomorrow's breakfast, lunch, and dinner:

...

a description of 3 meals follows

# Credits

Meal manager is inspired by [Personal Fitness Trainer](https://github.com/brainlid/langchain_demo).
