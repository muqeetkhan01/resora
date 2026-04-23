# Resora

## Talk to Resora (OpenAI)

`Talk to Resora` now uses the OpenAI API through `ResoraAiService`.

### Secure setup

Do not hardcode the API key in source code. Pass it at runtime:

```bash
flutter run \
  --dart-define=OPENAI_API_KEY=YOUR_KEY_HERE \
  --dart-define=OPENAI_MODEL=gpt-4.1-mini
```

`OPENAI_MODEL` is optional. If omitted, it defaults to `gpt-4.1-mini`.

### Notes

- Chat now calls `POST /v1/responses` and uses recent conversation context.
- The assistant is constrained for Resora tone and safety:
  - calm, practical, short responses
  - one clear next step
  - no diagnosis or fabricated claims
  - safety escalation language for crisis cues


How to use now

User submits question in app (ask anonymously).
In admin: Content page.
Set Content type = Normal topics.
Set Normal topic source = Community submissions.
Open item, add expert answer, set Status = Published, save.