// BAML configuration for Resume Tweaker

client<llm> GPT4oMini {
  provider openai
  options {
    model "gpt-4o-mini"
    api_key env.OPENAI_API_KEY
  }
}

// Data models
class Resume {
  content string
}

class JobDescription {
  description string
}

class TweakedResume {
  content string
  suggestions string[]
}

// Main function for tweaking resumes
function TweakResume(resume: Resume, job_description: JobDescription) -> TweakedResume {
  client GPT4oMini

  prompt #"
    You are an expert resume consultant. Your job is to help candidates optimize their resumes for specific job postings.

    Given the following resume:
    {{ resume.content }}

    And the following job description:
    {{ job_description.description }}

    Please provide:
    1. An improved version of the resume tailored to this specific job description
    2. Key suggestions on what was changed and why

    Focus on:
    - Highlighting relevant experience and skills
    - Using keywords from the job description
    - Improving clarity and impact
    - Maintaining truthfulness (don't fabricate experience)

    Return the tweaked resume and a list of suggestions.
  "#
}
