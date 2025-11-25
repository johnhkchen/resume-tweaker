// LLM Client Configuration for Resume Tweaker
// Uses Anthropic Claude for high-quality resume tailoring

// Primary client: Claude Haiku for fast, cost-effective streaming
client<llm> ClaudeHaiku {
  provider anthropic
  retry_policy Exponential
  options {
    model "claude-3-5-haiku-20241022"
    api_key env.ANTHROPIC_API_KEY
  }
}

// Higher-quality client: Claude Sonnet for complex analysis
client<llm> ClaudeSonnet {
  provider anthropic
  retry_policy Exponential
  options {
    model "claude-sonnet-4-20250514"
    api_key env.ANTHROPIC_API_KEY
  }
}

// Retry policies
retry_policy Constant {
  max_retries 3
  strategy {
    type constant_delay
    delay_ms 200
  }
}

retry_policy Exponential {
  max_retries 2
  strategy {
    type exponential_backoff
    delay_ms 300
    multiplier 1.5
    max_delay_ms 10000
  }
}
