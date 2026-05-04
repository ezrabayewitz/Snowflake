## Snowflake Cortex AI

This project leverages Snowflake's Cortex AI suite to enrich and analyze Tasty Bytes food truck data — including customer reviews, order analytics, and menu insights.

---

### Cortex Playground

Used the Cortex Playground in Snowsight's AI & ML Studio to experiment with LLM prompts across multiple models (e.g., Mistral, Llama, Claude). Tested prompt engineering strategies for review summarization and sentiment extraction, compared model outputs side-by-side, and exported optimized SQL for production use.

### Cortex Analyst

Built a semantic model over `TB_101` order and customer data to enable natural language querying. Business users can ask questions like "What were total sales by country last month?" and receive accurate SQL-generated answers grounded in defined metrics, dimensions, and relationships — no SQL knowledge required.

### Cortex AI Functions

Applied built-in AI functions directly in SQL to process customer reviews at scale:

- **AI_SENTIMENT** — Scored review sentiment to identify dissatisfied customers
- **AI_TRANSLATE** — Translated multilingual reviews into English for unified analysis
- **AI_COMPLETE** — Generated review summaries and extracted key themes
- **AI_CLASSIFY** — Categorized reviews by topic (food quality, service, wait time, etc.)

### Cortex Search

Created the `TASTY_BYTES_REVIEW_SEARCH` service in `TB_101.HARMONIZED` to power hybrid (vector + keyword) search over customer reviews. This enables a RAG-powered chatbot experience where users can ask natural language questions and receive contextually relevant review excerpts — with filtering by truck brand, location, or language.

---

### Tech Stack 

| Component | Purpose |
|-----------|---------|
| Snowflake Cortex AI Functions | In-SQL text analytics |
| Cortex Search | Hybrid search & RAG retrieval |
| Cortex Analyst | Natural language BI |
| Cortex Playground | Model comparison & prompt testing |
