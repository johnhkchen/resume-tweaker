// Job Extraction Schema for Anchor
//
// This schema defines structured extraction of job postings
// from raw HTML/text content using LLMs.

// ========== DATA MODELS ==========

enum ExperienceLevel {
  ENTRY_LEVEL
  MID_LEVEL
  SENIOR_LEVEL
  LEAD
  EXECUTIVE
  NOT_SPECIFIED
}

enum JobType {
  FULL_TIME
  PART_TIME
  CONTRACT
  TEMPORARY
  INTERNSHIP
  NOT_SPECIFIED
}

enum WorkLocation {
  REMOTE
  HYBRID
  ON_SITE
  NOT_SPECIFIED
}

class SalaryRange {
  min_salary int?
  max_salary int?
  currency string?
  period string? // e.g., "yearly", "hourly"
}

class JobRequirements {
  required_skills string[]
  preferred_skills string[]
  years_of_experience int?
  education_level string?
  certifications string[]
}

class JobPosting {
  // Core identification
  title string
  company string
  location string?

  // Job details
  experience_level ExperienceLevel
  job_type JobType
  work_location WorkLocation

  // Description and requirements
  description string // Clean, well-formatted description
  responsibilities string[] // Key responsibilities bullet points
  requirements JobRequirements

  // Compensation and benefits
  salary_range SalaryRange?
  benefits string[]

  // Application details
  application_deadline string? // If mentioned
  contact_email string?

  // Metadata
  posted_date string? // When the job was posted, if mentioned
  department string?
  team_size string?
}

// ========== EXTRACTION FUNCTION ==========

function ExtractJobPosting(
  raw_html: string,
  source_url: string
) -> JobPosting {
  // Use fast, cost-effective model for extraction
  client CustomFast // Uses round-robin between GPT-4o-mini and Haiku

  prompt #"
    You are a specialized job posting parser for "Anchor," a job search companion app.

    Your task is to extract structured information from raw job posting HTML/text.

    **Context:**
    Source URL: {{ source_url }}

    **Raw Content:**
    {{ raw_html }}

    **Instructions:**
    1. Extract the job title, company name, and location
    2. Identify the experience level (entry, mid, senior, etc.)
    3. Determine job type (full-time, contract, etc.) and work location (remote, hybrid, on-site)
    4. Extract a clean, readable description (remove HTML tags, formatting artifacts)
    5. List key responsibilities as bullet points
    6. Identify required vs. preferred skills
    7. Extract salary information if available
    8. Capture benefits mentioned
    9. Find application deadline and contact info if present

    **Important:**
    - If information is not clearly stated, use "NOT_SPECIFIED" or null appropriately
    - For skills, be specific (e.g., "React", "TypeScript", not just "JavaScript frameworks")
    - Clean up any HTML artifacts, tracking pixels, or navigation text
    - Focus on what matters to a job seeker, not marketing fluff
    - The description should be well-formatted and easy to read

    **User Empathy:**
    Remember that the person reading this is likely experiencing job search burnout.
    Extract information in a way that's clear, honest, and reduces cognitive load.

    {{ ctx.output_format }}
  "#
}

// ========== ALTERNATIVE: LIGHTWEIGHT EXTRACTION ==========
// For cases where we only need basic info quickly

class JobPostingBasic {
  title string
  company string
  description string
  location string?
}

function ExtractJobPostingQuick(
  raw_html: string
) -> JobPostingBasic {
  client "openai-responses/gpt-5-mini" // Fastest, cheapest

  prompt #"
    Extract ONLY the following from this job posting:
    - Job title
    - Company name
    - A clean, readable description (remove HTML)
    - Location (if mentioned)

    Raw content:
    {{ raw_html }}

    {{ ctx.output_format }}
  "#
}

// ========== TESTS ==========

test sample_job_linkedin {
  functions [ExtractJobPosting]
  args {
    source_url "https://linkedin.com/jobs/view/123456"
    raw_html #"
      <div class="job-details">
        <h1>Senior Software Engineer</h1>
        <h2>Acme Corp</h2>
        <span>San Francisco, CA (Hybrid)</span>

        <div class="description">
          <p>We're looking for a Senior Software Engineer to join our Platform team...</p>

          <h3>Responsibilities:</h3>
          <ul>
            <li>Design and implement scalable backend services</li>
            <li>Mentor junior engineers</li>
            <li>Lead architectural decisions</li>
          </ul>

          <h3>Requirements:</h3>
          <ul>
            <li>5+ years of software engineering experience</li>
            <li>Strong proficiency in TypeScript and Node.js</li>
            <li>Experience with AWS or GCP</li>
            <li>Bachelor's degree in Computer Science or equivalent</li>
          </ul>

          <h3>Nice to have:</h3>
          <ul>
            <li>Experience with Kubernetes</li>
            <li>GraphQL expertise</li>
          </ul>

          <p>Salary: $150,000 - $200,000/year</p>
          <p>Benefits: Health insurance, 401k matching, unlimited PTO</p>
        </div>
      </div>
    "#
  }
}

test sample_job_indeed {
  functions [ExtractJobPostingQuick]
  args {
    raw_html #"
      <h1 class="jobsearch-JobInfoHeader-title">Product Manager</h1>
      <div class="jobsearch-InlineCompanyRating">
        <div>TechStart Inc</div>
        <div>Remote</div>
      </div>
      <div class="jobsearch-jobDescriptionText">
        Join our fast-growing startup as a Product Manager.
        You'll work directly with customers to build features they love.

        Requirements: 3+ years PM experience, strong communication skills.
      </div>
    "#
  }
}

// ========== RESUME TAILORING FUNCTIONS ==========

class ResumeFitAnalysis {
  strengths string[] // What aligns well with the job
  gaps string[] // What's missing or weak
  missing_keywords string[] // Important terms not in resume
  keyword_suggestions KeywordSuggestion[] // How to naturally add keywords
  overall_match_score int // 0-100
  confidence string // "high", "medium", "low"
}

class KeywordSuggestion {
  keyword string
  context string // Where in the job it appears
  suggestion string // How to naturally incorporate it
  example_bullet string // Example tailored bullet point
}

class TailoredBulletPoint {
  original string?
  tailored string
  keywords_incorporated string[]
  explanation string
  score int // 0-100: how strong is this bullet for the job?
}

class CoverLetterOutline {
  opening_hook string // Personalized opening that references the company/role
  body_paragraphs string[] // 2-3 key selling points with specific examples
  closing string // Strong closing with call to action
  tone string // "professional", "enthusiastic", "conversational"
}

// Analyze how well a resume matches a job posting
function AnalyzeResumeFit(
  job_description: string,
  resume_text: string
) -> ResumeFitAnalysis {
  client CustomFast

  prompt #"
    You are a career coach helping someone with job search burnout.
    Your goal is to provide ACTIONABLE, SPECIFIC feedback that reduces anxiety.

    **Job Posting:**
    {{ job_description }}

    **Current Resume:**
    {{ resume_text }}

    **Analysis Instructions:**
    1. Identify 3-5 strengths where the resume aligns well with the job
    2. Identify 3-5 gaps or weaknesses (be honest but supportive)
    3. List the top 10 missing keywords that matter for ATS and humans
    4. For each missing keyword, provide:
       - Context: Where it appears in the job description
       - Suggestion: How to naturally incorporate it
       - Example: A specific tailored bullet point using that keyword
    5. Score overall match 0-100 (be realistic, not harsh)

    **Tone:** Supportive, specific, actionable. Avoid generic advice.
    Focus on what they CAN control, not what they lack.

    {{ ctx.output_format }}
  "#
}

// Tailor a generic resume bullet point to a specific job
function TailorBulletPoint(
  original_bullet: string,
  job_requirements: string,
  user_instruction: string?
) -> TailoredBulletPoint {
  client CustomFast

  prompt #"
    You are helping someone tailor their resume bullet point to a job.

    **Original Bullet Point:**
    {{ original_bullet }}

    **Job Requirements:**
    {{ job_requirements }}

    {% if user_instruction %}
    **User's Specific Request:**
    {{ user_instruction }}
    {% endif %}

    **Instructions:**
    1. Rewrite the bullet point to:
       - Incorporate relevant keywords from the job requirements
       - Keep accomplishments and metrics intact
       - Sound natural and authentic (not keyword-stuffed)
       - Start with a strong action verb
    2. List which keywords you incorporated
    3. Briefly explain what you changed and why
    4. Score the new bullet (0-100) based on:
       - Relevance to job requirements
       - Use of strong action verbs
       - Quantifiable metrics (if preserved/enhanced)
       - Clarity and conciseness

    **Important:** Don't fabricate experience. Enhance clarity and relevance.

    {{ ctx.output_format }}
  "#
}

// Generate a personalized cover letter outline
function GenerateCoverLetterOutline(
  job_description: string,
  resume_text: string,
  company_research: string?,
  user_instruction: string?
) -> CoverLetterOutline {
  client CustomFast

  prompt #"
    You are helping someone write a cover letter for a job they actually want.
    This should feel authentic, not templated.

    **Job Description:**
    {{ job_description }}

    **Their Resume:**
    {{ resume_text }}

    {% if company_research %}
    **Research About the Company:**
    {{ company_research }}
    {% endif %}

    {% if user_instruction %}
    **User's Specific Request:**
    {{ user_instruction }}
    {% endif %}

    **Instructions:**
    1. Opening Hook: Reference something specific about the role or company
       (not "I am writing to apply for...")
    2. Body (2-3 points): Each paragraph should:
       - Connect a specific skill/experience to a job requirement
       - Include a concrete example or achievement
       - Show you understand what they need
    3. Closing: Confident but not presumptuous, with clear next step
    4. Tone: Match the company culture (formal vs. conversational)

    **Important:**
    - Use first person ("I", "my")
    - Keep it under 350 words total
    - Avoid clichés ("passion for excellence", "team player")

    {{ ctx.output_format }}
  "#
}

// ========== KEY TERMS EXTRACTION ==========

class JobKeyTerms {
  technical_skills string[] // Specific technologies, languages, frameworks (e.g., "React", "TypeScript", "AWS")
  tools_and_platforms string[] // Software, services, platforms (e.g., "GitHub Actions", "Docker", "Salesforce")
  domain_knowledge string[] // Industry-specific knowledge (e.g., "e-commerce", "CI/CD", "microservices")
  soft_skills string[] // Leadership, communication, etc. (e.g., "mentoring", "cross-functional collaboration")
  certifications_and_qualifications string[] // Degrees, certs (e.g., "Bachelor's in CS", "AWS Certified")
}

// Extract the most important keywords for ATS and human matching
function ExtractKeyTerms(
  job_description: string
) -> JobKeyTerms {
  client "openai-responses/gpt-5-mini"

  prompt #"
    You are analyzing a job description to identify the MOST IMPORTANT keywords
    that a candidate should include in their resume to pass ATS (Applicant Tracking System)
    and catch a recruiter's eye.

    **Job Description:**
    {{ job_description }}

    **Instructions:**
    1. Extract specific technical skills (languages, frameworks, libraries)
       - Be precise: "React" not "JavaScript frameworks", "TypeScript" not "programming"
       - Include version numbers if mentioned (e.g., "Node.js 18+")

    2. Identify tools and platforms mentioned
       - Cloud services (AWS Lambda, S3, etc.)
       - DevOps tools (Jenkins, GitHub Actions, Docker)
       - Business software (Salesforce, Jira, etc.)

    3. Extract domain knowledge requirements
       - Industry terms (e-commerce, fintech, SaaS)
       - Methodologies (Agile, CI/CD, microservices)
       - Concepts (high-traffic systems, data pipelines)

    4. Note important soft skills
       - Leadership (mentoring, leading teams)
       - Communication (cross-functional, stakeholder management)
       - Only include if explicitly emphasized

    5. Capture required certifications or qualifications
       - Degrees ("Bachelor's in Computer Science")
       - Certifications ("AWS Certified Solutions Architect")
       - Years of experience with specific tech

    **Important:**
    - Prioritize terms that appear multiple times or are emphasized
    - Use the exact terms from the job description (preserve capitalization)
    - Exclude generic words like "experience", "team player", "strong"
    - Focus on what a resume should contain to match this job
    - Limit each category to the top 5-10 most important terms

    {{ ctx.output_format }}
  "#
}

// ========== USER PROFILE EXTRACTION ==========

class ExtractedExperience {
  role string
  company string
  duration string // e.g., "2 years", "Jan 2020 - Dec 2022"
  keyAchievements string[]
  technologies string[]
  highlights string[] // Standout accomplishments
}

class ExtractedUserProfile {
  name string?
  currentRole string?
  yearsOfExperience int?

  // Core competencies
  technicalSkills string[]
  domainExpertise string[]
  softSkills string[]
  certifications string[]

  // Career narrative
  experiences ExtractedExperience[]
  careerHighlights string[] // Top 3-5 achievements across career

  // Inferred preferences
  targetRoles string[]
  locationPreferences string[]
}

// Extract structured user profile from resume text
function ExtractUserProfile(
  resume_text: string
) -> ExtractedUserProfile {
  client "openai-responses/gpt-5-mini"

  prompt #"
    You are helping someone build a "memory" of themselves for job applications.
    This person is experiencing job search burnout and needs help managing
    the cognitive load of recalling and adapting their story for each application.

    Your task is to extract a structured profile from their resume that can be
    used to intelligently customize applications without them having to re-think
    their entire career each time.

    **Resume Text:**
    {{ resume_text }}

    **Extraction Instructions:**

    1. **Basic Info**: Extract name, current/most recent role, total years of experience

    2. **Technical Skills**: List specific technologies, languages, frameworks
       - Be precise: "React", "TypeScript", "PostgreSQL" (not "web development")
       - Include proficiency levels if mentioned
       - Group related skills (e.g., all cloud platforms together)

    3. **Domain Expertise**: Industry knowledge, methodologies, business domains
       - e.g., "e-commerce", "fintech", "healthcare", "B2B SaaS"
       - e.g., "Agile", "CI/CD", "microservices architecture"

    4. **Soft Skills**: Leadership, communication, collaboration
       - Only include if explicitly demonstrated (not just claimed)
       - e.g., "team mentoring" if they mention training juniors
       - e.g., "cross-functional leadership" if they led multi-team projects

    5. **Certifications**: Degrees, certificates, licenses

    6. **Experiences**: For each role, extract:
       - Role title and company
       - Duration (convert to readable format like "2 years" or "Jan 2020 - Dec 2022")
       - Key achievements (convert bullets into clear accomplishments)
       - Technologies used in this role
       - Highlights (1-2 most impressive things from this role)

    7. **Career Highlights**: Identify the top 3-5 achievements across their entire career
       - Focus on impact, scale, innovation
       - These should be the "greatest hits" they can pull from for applications

    8. **Target Roles**: Infer what roles they're likely applying for
       - Based on their career trajectory
       - e.g., if they're a "Senior Engineer", likely targeting "Staff Engineer", "Tech Lead"

    9. **Location Preferences**: If mentioned

    **Important:**
    - Focus on facts, not fluff
    - Preserve metrics and numbers (e.g., "reduced latency by 40%")
    - Make it easy to match against job requirements
    - This is a knowledge base, not marketing copy

    {{ ctx.output_format }}
  "#
}

// ========== CUSTOMIZATION GENERATION ==========

class CustomizationPoint {
  category string // "highlight", "experience", "skill_emphasis", "talking_point"
  title string // Short label (e.g., "Led 5-person team")
  description string // Full context
  relevance string // Why this matters for THIS job
  prompt_instruction string // HATEOAS: instruction for LLM if user selects this
}

class JobApplicationSynergy {
  matchScore int // 0-100: how well user profile matches job
  strengths string[] // What aligns well (be specific)
  gaps string[] // What's missing (honest but supportive)
  dealBreakerMatch bool // Do job requirements violate user's deal-breakers?

  // AI-suggested customization points
  customizationPoints CustomizationPoint[]

  // Strategic advice
  applicationStrategy string // How to approach this application (emphasize what, de-emphasize what)
}

// Analyze synergy between user profile and job, generate customization options
function GenerateCustomizationPoints(
  user_profile: string, // JSON stringified user profile
  job_description: string,
  job_title: string,
  job_company: string
) -> JobApplicationSynergy {
  client "openai-responses/gpt-5-mini"

  prompt #"
    You are helping someone customize their application for a specific job.
    They are experiencing job search burnout and need to reduce the cognitive
    load of "recalling, adapting, and couriering information among too many organizations."

    **User Profile (Their "Memory"):**
    {{ user_profile }}

    **Job They're Applying For:**
    Company: {{ job_company }}
    Title: {{ job_title }}
    Description: {{ job_description }}

    **Your Task:**

    1. **Assess Match** (0-100):
       - How well do their skills/experience align with the job?
       - Be realistic, not harsh

    2. **Identify Strengths** (short phrases, not sentences):
       - Start with the skill/experience, not "Your" or "You"
       - e.g., "3 years React experience" (not "Your 3 years of React experience matches their requirement")
       - e.g., "E-commerce platform builds" (not "You've built e-commerce platforms")

    3. **Identify Gaps** (actionable phrases):
       - Frame as what to DO, not what's missing
       - e.g., "Add Vue.js examples to resume" (not "Missing Vue.js experience")
       - e.g., "Highlight transferable leadership skills" (not "Less management experience than ideal")

    4. **Check Deal-Breakers**:
       - Does this job violate any of their stated deal-breakers?
       - If yes, flag it clearly

    5. **Generate Customization Points** (6-10 options):
       For each point:
       - **Category**: "highlight", "experience", "skill_emphasis", "talking_point"
       - **Title**: Short, scannable label (e.g., "Led 5-person team at Acme")
       - **Description**: Full context from their profile
       - **Relevance**: Why THIS point matters for THIS job
       - **Prompt Instruction** (HATEOAS): Embedded instruction for LLM if user selects this
         * Example: "Emphasize leadership of cross-functional teams in cover letter"
         * Example: "Rewrite this bullet to highlight AWS Lambda experience"
         * Example: "Use this as opening hook in cover letter"

       The user will select which points to emphasize, and those instructions
       will be used to customize their resume/cover letter.

    6. **Application Strategy**:
       - High-level advice on how to approach this application
       - What to emphasize, what to de-emphasize
       - e.g., "Lead with your e-commerce experience. Downplay the healthcare work."

    **Important:**
    - Focus on actionable, specific customizations
    - Don't generate busywork ("Research the company") unless truly valuable
    - Embed LLM instructions in prompt_instruction for HATEOAS-style self-direction
    - Help them apply efficiently, not waste energy on fruitless activities

    {{ ctx.output_format }}
  "#
}

// ========== CONTEXTUAL ACTIVITY GENERATION ==========

class ContextualActivity {
  id string
  label string // User-facing: "Rewrite bullet about AWS Lambda experience"
  activeForm string // Present continuous: "Rewriting bullet about AWS Lambda experience"
  instruction string // HATEOAS: What the LLM should do with this
  category string // "essential", "high_value", "optional"
  reasoning string // WHY this activity contributes to kept work (anti-waste)
  estimatedMinutes int // Time commitment
}

class ActivityPlan {
  recommendation string // "proceed", "skip", "revise_approach"
  reasoning string // Why this recommendation (5 Whys-style)
  wasteSignals string[] // Red flags that suggest this is low-value (deal-breakers, poor fit)
  activities ContextualActivity[] // ONLY activities worth doing (no busywork)
}

// Generate activities that contribute to KEPT WORK (Toyota Production System)
function GenerateContextualActivities(
  user_profile: string,
  job_description: string,
  job_title: string,
  job_company: string,
  match_score: int,
  strengths: string[],
  gaps: string[],
  deal_breaker_match: bool
) -> ActivityPlan {
  client "openai-responses/gpt-5-mini"

  prompt #"
    You are applying Toyota Production System principles to job applications.
    Your goal: ELIMINATE WASTE. Only suggest activities that contribute to "kept work."

    **Context:**
    Job: {{ job_title }} at {{ job_company }}
    Match Score: {{ match_score }}/100
    Strengths: {{ strengths }}
    Gaps: {{ gaps }}
    Deal-breaker Issues: {{ deal_breaker_match }}

    **User Profile:**
    {{ user_profile }}

    **Job Description:**
    {{ job_description }}

    **Toyota Production System Applied to Job Search:**

    1. **Jidoka (Stop the Line)**: Don't proceed if defects are obvious
       - Deal-breakers? Recommend "skip"
       - Match < 50%? Recommend "skip" or "revise_approach"

    2. **Muda (Waste Elimination)**: No activities that don't lead to kept work
       - DON'T suggest: "Research the company" (generic busywork)
       - DO suggest: "Find connection at company who worked on [specific project]" (specific, actionable)
       - DON'T suggest: "Tailor resume" (vague)
       - DO suggest: "Rewrite bullet about AWS Lambda to emphasize serverless architecture" (specific)

    3. **Just-in-Time**: Only do work when it has clear value
       - If match is poor, recommend skipping entirely
       - If match is good, generate 3-5 HIGH-VALUE activities

    4. **Andon (Make Problems Visible)**: Surface waste signals clearly
       - List specific reasons this might be a waste of time
       - Be honest about likelihood of success

    **5 Whys Analysis:**
    - WHY apply to lots of jobs? → To increase chances
    - WHY low individual chances? → Because applications aren't tailored
    - WHY not tailored? → Because tailoring takes energy
    - WHY spray-and-pray? → Because can't assess fit
    - **ROOT CAUSE**: Need to assess fit FIRST, then only invest energy if worthwhile

    **Your Task:**

    1. **Recommendation**: "proceed", "skip", or "revise_approach"
       - "proceed" if match >= 70% and no deal-breakers
       - "skip" if match < 50% OR deal-breakers present
       - "revise_approach" if match 50-69% (suggest how to improve fit)

    2. **Reasoning**: 1-2 sentences max. Direct, no fluff.
       - SKIP: "They need 10+ years; you have 5. Low chance of success."
       - PROCEED: "Your e-commerce experience matches their needs directly. ~30 min to tailor."
       - REVISE: "Good skills match but missing [X]. Address this first."

    3. **Waste Signals**: List red flags
       - Deal-breakers violated
       - Skills gap too large
       - Location mismatch
       - Unrealistic requirements

    4. **Activities** (ONLY IF recommendation is "proceed"):
       - Generate 3-5 activities MAX
       - Each must be SPECIFIC and ACTIONABLE
       - Each must have clear HATEOAS instruction
       - Each must explain WHY it contributes to kept work
       - Estimate time commitment honestly
       - Categories: "essential" (must do), "high_value" (should do), "optional" (nice to have)

    **Examples of GOOD Activities:**
    - Label: "Rewrite AWS Lambda bullet to match their serverless needs"
      Instruction: "Take the user's bullet about AWS Lambda experience and rewrite it to emphasize serverless architecture, cost optimization, and event-driven design, which are highlighted in the job requirements"
      Reasoning: "They specifically need serverless experience. Highlighting this increases ATS match and shows direct relevance."
      Category: "essential"

    - Label: "Find mutual connection who worked on their e-commerce platform"
      Instruction: "Search LinkedIn for connections who worked at {{ job_company }} on e-commerce projects, prioritizing those who overlap with user's network"
      Reasoning: "Referrals increase success rate by 40%. This is high-leverage networking."
      Category: "high_value"

    **Examples of BAD Activities (DON'T GENERATE THESE):**
    - "Research the company" (too generic, no clear action)
    - "Tailor your resume" (vague, no specific instruction)
    - "Write a cover letter" (busywork unless they specifically ask for one)

    **Important:**
    - Be HONEST about waste
    - Protect the user's energy
    - Only recommend "proceed" if genuinely worth their time
    - Activities should be specific enough that an LLM can execute them

    {{ ctx.output_format }}
  "#
}

// ========== TESTS ==========

test extract_key_terms_gallup {
  functions [ExtractKeyTerms]
  args {
    job_description #"
      Full-Stack Web Engineer at Gallup

      We need someone with 5+ years building production web applications.

      Required:
      - 5+ years TypeScript and Node.js
      - 3+ years AWS (S3, Lambda, SNS/SQS)
      - 3+ years CI/CD (Jenkins, GitHub Actions)
      - 3+ years MySQL/RDS
      - Experience with e-commerce platforms

      Preferred:
      - Salesforce Commerce Cloud (Apex, Lightning Web Components)
      - B2B e-commerce experience
      - Mentoring junior engineers

      Bachelor's in CS or equivalent required.
    "#
  }
}

test resume_fit_analysis {
  functions [AnalyzeResumeFit]
  args {
    job_description #"
      Senior Full-Stack Engineer
      We need someone with 5+ years building production React applications,
      experience with TypeScript, AWS (Lambda, S3), and CI/CD pipelines.
      Must have led teams and shipped products to millions of users.
    "#
    resume_text #"
      Software Engineer, 6 years experience.
      - Built web applications using JavaScript and Node.js
      - Worked with databases and APIs
      - Collaborated with designers and product managers
    "#
  }
}

test tailor_bullet_point {
  functions [TailorBulletPoint]
  args {
    original_bullet "Built web features for the platform"
    job_requirements "React, TypeScript, AWS Lambda, high-traffic systems"
    user_instruction "Emphasize the scale and tech stack"
  }
}

test gallup_fullstack_engineer {
  functions [ExtractJobPosting]
  args {
    source_url "https://www.indeed.com/jobs?q=full+stack+engineer"
    raw_html #"
      Job details
      Pay

      $150,000 - $200,000 a year

      Benefits
      Pulled from the full job description

      401(k)
      Health insurance
      401(k) matching
      Vision insurance
      Dental insurance
      Employee assistance program

      Full job description

      Be a part of Gallup's e-commerce evolution and growth strategy.

      Gallup is adding an experienced full-stack web engineer to support our new e-commerce platform and migration. Ideal applicants will have experience building high-traffic public websites, customizing solutions to meet unique business needs, building multiple integrations, and delivering a simple and elegant digital experience.

      What You'll Do

      Implement e-commerce features such as product catalogs, storefronts and checkout processes
      Integrate with third-party systems (e.g., payment gateways, AWS)
      Use proofs of concept (spike solutions) to validate cost/time estimates, identify risks, and confirm business value and usability of new features
      Collaborate with cross-functional teams to deliver end-to-end solutions
      Troubleshoot, test and optimize system performance

      What Makes You Stand Out

      Broad engineering experience: You have the experience and aptitude to work across many systems, platforms and languages.
      Leadership in major initiatives: You are known for your expertise in launching successful web projects.
      Innovative problem-solving: You have a proven track record of developing software platforms through multiple iterations, new features and customizations.
      Early-stage company experience: Whether at a startup or during an intense period of product development, you gravitate toward roles with great opportunities and big impact.

      What You Need

      Bachelor's degree in computer science, MIS or a related field or equivalent experience required
      At least five years of experience in one or more back-end languages such as Java, C#, Python, Ruby or Node.js required
      At least five years of experience with modern JavaScript/TypeScript and semantic HTML required
      At least three years of experience with cloud platforms is required, with a strong preference for AWS services such as S3, Lambda, and SNS/SQS
      At least three years of experience with CI/CD solutions such as Jenkins, GitHub Actions or Azure DevOps required
      At least three years of experience with RDS (Mysql or SQL generally) required
      At least three years of experience in a high-velocity growth or product-led team environment required
      Proven experience working in a senior engineer capacity required
      Demonstrated ability in mentoring junior engineers preferred
      Professional experience with B2B e-commerce preferred
      Salesforce Commerce Cloud experience (Apex, Flows, Actions, Lightning Web Components) preferred
      Experience with data lakehouse, MarTech, DTC, ADS toolchain, BI toolchain or user experimentation a plus
      Must live within a 60-mile radius of San Francisco
      A commitment to working on-site at a local Gallup workspace in San Francisco at least three days a week required

      What You'll Experience

      Mission-driven work: Make a meaningful difference for organizations, governments and individuals with your unique contributions, commitment to service and exceptional outcomes.
      Engaged teams: Join world-class managers, highly productive colleagues and knowledgeable mentors who are enthusiastic about their work.
      Learning opportunities: Focus on continuous growth by developing your strengths, feeding your curiosity, challenging conventional thinking and experimenting.
      Brand strength, startup energy: Thrive in an innovative culture backed by a trusted brand.
      A collaborative environment: Work where your ideas, perspectives and experiences are welcome and valued.

      Learn more about life at Gallup.

      Gallup offers a robust benefits package that includes medical, dental, vision, life and other insurance options; a fully vested 401(k) retirement savings plan with company matching; an employee stock ownership program; mass transit reimbursement; family-building benefits; an employee assistance program; and various reimbursements and activities that enhance our associates' wellbeing. We also offer an estimated annual salary range of $150,000-$200,000 for this role. Salaries are based on a variety of factors, including an individual's education, experience and skills.

      Gallup is an equal opportunity employer. We consider all qualified applicants without regard to race, color, religion, sex, national origin, disability, protected veteran status, sexual orientation, gender identity, or any other legally protected basis, in accordance with applicable law.
    "#
  }
}
