// BAML definitions for Resume Tweaker
// Supports real-time streaming output via SSE

// ========== CORE RESUME TWEAKING ==========

// Main function for streaming resume improvements
function TweakResume(resume: string, job_description: string) -> string {
  client ClaudeHaiku

  prompt #"
    You are an expert resume consultant. Improve the given resume to better match the target job description.

    **IMPORTANT:** Stream your response as you write it. Start immediately with the improved content.

    Guidelines:
    - Tailor content to job requirements
    - Use relevant keywords naturally
    - Quantify achievements where possible
    - Improve clarity and impact
    - Maintain honesty — don't fabricate
    - Use markdown for structure (## for sections, - for bullets)

    ## Resume
    {{ resume }}

    ## Job Description
    {{ job_description }}

    ## Instructions
    Output ONLY the improved resume. No explanations or additional commentary.
    Start with a brief professional summary, then Experience, Skills, and Education.
  "#
}

// ========== ANALYSIS FUNCTIONS ==========

// Structured analysis of the tweaking results
class TweakAnalysis {
  summary string @description("Brief summary of changes made")
  keywords_added string[] @description("Keywords incorporated from job description")
  sections_improved string[] @description("Which sections were enhanced")
  match_score int @description("Estimated match score 0-100 after tweaking")
}

function AnalyzeTweak(
  original_resume: string,
  tweaked_resume: string,
  job_description: string
) -> TweakAnalysis {
  client ClaudeHaiku

  prompt #"
    Analyze the improvements made to this resume for the given job.

    **Original Resume:**
    {{ original_resume }}

    **Tweaked Resume:**
    {{ tweaked_resume }}

    **Job Description:**
    {{ job_description }}

    Provide:
    1. A brief summary of the key changes (2-3 sentences)
    2. List the keywords from the job description that were incorporated
    3. Which sections were improved and how
    4. Your estimate of match score (0-100) after these improvements

    {{ ctx.output_format }}
  "#
}

// ========== KEY TERMS EXTRACTION ==========

// Quick extraction of key terms for real-time highlighting
class KeyTerms {
  technical_skills string[]
  soft_skills string[]
  requirements string[]
  nice_to_have string[]
}

function ExtractJobKeyTerms(
  job_description: string
) -> KeyTerms {
  client ClaudeHaiku

  prompt #"
    Extract the most important keywords from this job description.

    **Job Description:**
    {{ job_description }}

    Categorize into:
    - technical_skills: Specific technologies, languages, frameworks
    - soft_skills: Leadership, communication, collaboration skills
    - requirements: Must-have qualifications
    - nice_to_have: Preferred but not required

    Be precise with technical terms (e.g., "React" not "JavaScript frameworks").
    Only include terms that actually appear in or are implied by the job description.

    {{ ctx.output_format }}
  "#
}

// ========== TESTS ==========

test tweak_simple_resume {
  functions [TweakResume]
  args {
    resume #"
      John Smith
      Software Engineer

      Experience:
      - Built web applications
      - Worked with databases
      - Collaborated with teams

      Skills: Python, JavaScript, SQL

      Education: BS Computer Science
    "#
    job_description #"
      Senior Full-Stack Engineer

      Requirements:
      - 5+ years experience with React and TypeScript
      - AWS experience (Lambda, S3, DynamoDB)
      - Strong CI/CD practices
      - Experience leading teams

      Nice to have:
      - E-commerce platform experience
      - Mentoring junior developers
    "#
  }
}

test extract_terms {
  functions [ExtractJobKeyTerms]
  args {
    job_description #"
      We need a Senior Engineer with:
      - 5+ years TypeScript and React
      - AWS (Lambda, S3)
      - Experience with CI/CD pipelines
      - Strong communication skills
      - Mentoring experience preferred
    "#
  }
}
