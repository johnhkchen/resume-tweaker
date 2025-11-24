// BAML definition for Resume Tweaker

client<llm> Claude {
  provider anthropic
  options {
    model claude-sonnet-4-20250514
    api_key env.ANTHROPIC_API_KEY
  }
}

function TweakResume(resume: string, job_description: string) -> string {
  client Claude
  prompt #"
    You are an expert resume consultant. Improve the given resume to better match the target job description.

    Guidelines:
    - Tailor content to job requirements
    - Use relevant keywords naturally
    - Quantify achievements where possible
    - Improve clarity and impact
    - Maintain honesty — don't fabricate

    ## Resume
    {{ resume }}

    ## Job Description
    {{ job_description }}

    ## Instructions
    Output ONLY the improved resume. No explanations or additional commentary.
  "#
}
