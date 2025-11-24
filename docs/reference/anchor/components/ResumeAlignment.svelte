<script lang="ts">
  /**
   * ResumeAlignment - Resume Keyword Tailoring Component
   *
   * Uses BAML to intelligently extract key terms from job descriptions,
   * then provides real-time feedback as users add them to their resume.
   */
  import { hasKeyword } from '../../lib/textAnalysis';
  import { getUserProfile } from '../../lib/db';
  import { onMount } from 'svelte';

  export let jobDescription: string;

  let resumeText = '';
  let keyTerms: string[] = [];
  let copiedFeedback = false;
  let isLoadingKeywords = true;
  let keywordsError = '';

  // Track extraction progress
  let extractionProgress = {
    analyzing: false,
    extracting: false,
    complete: false,
  };
  let characterCount = 0;

  // Reactive: Check which keywords are missing/present as user types
  $: keywordStatus = keyTerms.map(keyword => ({
    keyword,
    isPresent: hasKeyword(resumeText, keyword),
  }));

  // Reactive: Calculate coverage percentage
  $: coverage = keyTerms.length > 0
    ? Math.round((keywordStatus.filter(k => k.isPresent).length / keyTerms.length) * 100)
    : 0;

  // Reactive: Count missing keywords
  $: missingCount = keywordStatus.filter(k => !k.isPresent).length;

  async function fetchKeyTerms() {
    if (!jobDescription || jobDescription.trim().length < 50) {
      isLoadingKeywords = false;
      keywordsError = 'Job description too short to analyze';
      return;
    }

    try {
      isLoadingKeywords = true;
      keywordsError = '';

      // Reset progress
      extractionProgress = {
        analyzing: false,
        extracting: false,
        complete: false,
      };
      characterCount = jobDescription.length;

      // Step 1: Analyzing
      extractionProgress.analyzing = true;
      await new Promise(resolve => setTimeout(resolve, 300)); // Brief pause for visual feedback

      const response = await fetch('/api/extract-key-terms', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jobDescription }),
      });

      // Step 2: Extracting
      extractionProgress.extracting = true;

      const result = await response.json();

      if (result.success) {
        keyTerms = result.data.keywords;

        // Step 3: Complete
        extractionProgress.complete = true;
        await new Promise(resolve => setTimeout(resolve, 200)); // Brief pause to show completion
      } else {
        keywordsError = result.error || 'Failed to extract keywords';
      }
    } catch (error) {
      console.error('Failed to fetch key terms:', error);
      keywordsError = 'Network error - please try again';
    } finally {
      isLoadingKeywords = false;
    }
  }

  async function copyToClipboard() {
    try {
      await navigator.clipboard.writeText(resumeText);
      copiedFeedback = true;
      setTimeout(() => {
        copiedFeedback = false;
      }, 2000);
    } catch (error) {
      console.error('Failed to copy:', error);
    }
  }

  // Load user profile and fetch key terms when component mounts
  onMount(async () => {
    // Try to load user's profile resume text
    try {
      const profile = await getUserProfile();
      if (profile && profile.resumeText) {
        resumeText = profile.resumeText;
      }
    } catch (error) {
      console.error('Failed to load user profile:', error);
    }

    // Fetch key terms
    fetchKeyTerms();
  });
</script>

<div class="resume-alignment">
  <div class="header">
    <h4 class="title">Resume Resonance</h4>
    <div class="coverage-badge" class:high={coverage >= 80} class:medium={coverage >= 50 && coverage < 80}>
      {coverage}% match
    </div>
  </div>

  <p class="description">
    AI-powered keyword extraction. Paste your resume below and watch keywords turn green as you add them.
  </p>

  <!-- Loading/Error States -->
  {#if isLoadingKeywords}
    <div class="keywords-section loading-state">
      <div class="loading-header">
        <div class="loading-spinner"></div>
        <span class="loading-text">Extracting keywords from job description</span>
      </div>

      <div class="progress-dashboard">
        <div class="progress-item" class:received={extractionProgress.analyzing}>
          <span class="progress-icon">{extractionProgress.analyzing ? '✓' : '○'}</span>
          <span class="progress-label">
            {extractionProgress.analyzing ? `Analyzing ${characterCount.toLocaleString()} characters` : 'Preparing analysis...'}
          </span>
        </div>

        <div class="progress-item" class:received={extractionProgress.extracting}>
          <span class="progress-icon">{extractionProgress.extracting ? '✓' : '○'}</span>
          <span class="progress-label">
            {extractionProgress.extracting ? 'Extracting key terms with AI' : 'Waiting for AI extraction...'}
          </span>
        </div>

        <div class="progress-item" class:received={extractionProgress.complete}>
          <span class="progress-icon">{extractionProgress.complete ? '✓' : '○'}</span>
          <span class="progress-label">
            {extractionProgress.complete ? `Found ${keyTerms.length} keywords to match` : 'Processing results...'}
          </span>
        </div>
      </div>
    </div>
  {:else if keywordsError}
    <div class="keywords-section error-state">
      <p class="error-text">⚠️ {keywordsError}</p>
      <button class="btn-retry" on:click={fetchKeyTerms}>Retry</button>
    </div>
  {:else if keyTerms.length > 0}
    <!-- Keywords Summary & Pills -->
    <div class="keywords-section">
      <div class="keywords-header">
        <span class="keywords-label">
          {missingCount === 0 ? '✓ All keywords present!' : `${missingCount} missing keyword${missingCount === 1 ? '' : 's'}`}
        </span>
        <span class="keywords-count">
          {keyTerms.length} keyword{keyTerms.length === 1 ? '' : 's'} extracted
        </span>
      </div>

      <div class="keywords-pills">
        {#each keywordStatus as { keyword, isPresent }, index}
          <span
            class="keyword-pill"
            class:present={isPresent}
            class:missing={!isPresent}
            style="animation-delay: {index * 0.05}s"
          >
            {keyword}
          </span>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Resume Text Area -->
  <div class="resume-editor">
    <label for="resume-text" class="editor-label">
      Your Resume Text
    </label>
    <textarea
      id="resume-text"
      bind:value={resumeText}
      placeholder="Paste your resume text here...

Example:
Senior Software Engineer with 5+ years building scalable web applications using React, TypeScript, and AWS. Led cross-functional teams to deliver high-impact products..."
      rows="16"
      class="resume-textarea"
    ></textarea>

    <div class="editor-actions">
      <button
        class="btn-primary copy-btn"
        on:click={copyToClipboard}
        disabled={!resumeText.trim()}
      >
        {copiedFeedback ? 'Copied!' : 'Copy Tailored Text'}
      </button>
      <span class="char-count">
        {resumeText.length} characters
      </span>
    </div>
  </div>

  <!-- Supportive Guidance -->
  {#if missingCount > 0 && resumeText.length > 50}
    <div class="guidance">
      <p class="guidance-text">
        💡 <strong>Suggestion:</strong> Try incorporating {missingCount === 1 ? 'this keyword' : 'these keywords'} naturally into your resume.
        Focus on how you've used {keywordStatus.filter(k => !k.isPresent).slice(0, 3).map(k => k.keyword).join(', ')} in past projects.
      </p>
    </div>
  {/if}
</div>

<style>
  .resume-alignment {
    margin-top: var(--spacing-lg);
    padding: var(--spacing-lg);
    background-color: var(--color-bg-info); /* Soft blue background */
    border-left: 4px solid var(--color-sage);
    border-radius: var(--border-radius);
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-sm);
  }

  .title {
    font-family: var(--font-serif);
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--color-slate);
    margin: 0;
  }

  .coverage-badge {
    padding: var(--spacing-xs) var(--spacing-sm);
    border-radius: var(--border-radius);
    font-size: 0.875rem;
    font-weight: 700;
    background-color: var(--color-grey-light);
    color: var(--color-grey);
    transition: all var(--transition-medium);
    min-width: 80px;
    text-align: center;
  }

  .coverage-badge.medium {
    background-color: var(--color-bg-warning);
    color: var(--color-text-warning);
    animation: badge-update 0.4s ease;
  }

  .coverage-badge.high {
    background-color: var(--color-bg-success-muted);
    color: var(--color-text-success);
    animation: badge-update 0.4s ease;
  }

  @keyframes badge-update {
    0% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.1);
    }
    100% {
      transform: scale(1);
    }
  }

  .description {
    font-size: 0.9375rem;
    color: var(--color-slate-light);
    margin-bottom: var(--spacing-md);
  }

  /* Keywords Section */
  .keywords-section {
    margin-bottom: var(--spacing-lg);
  }

  .keywords-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-sm);
    gap: var(--spacing-sm);
    flex-wrap: wrap;
  }

  .keywords-label {
    font-size: 0.875rem;
    font-weight: 600;
    color: var(--color-slate);
  }

  .keywords-count {
    font-size: 0.8125rem;
    color: var(--color-slate-light);
    font-weight: 500;
    padding: var(--spacing-xs) var(--spacing-sm);
    background-color: var(--color-card);
    border-radius: var(--border-radius);
    border: 1px solid var(--color-grey-light);
  }

  .keywords-pills {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-xs);
  }

  .keyword-pill {
    padding: var(--spacing-xs) var(--spacing-sm);
    border-radius: var(--border-radius);
    font-size: 0.875rem;
    font-weight: 600;
    transition: all var(--transition-medium);
    animation: pill-fade-in 0.4s ease forwards;
    opacity: 0;
  }

  @keyframes pill-fade-in {
    from {
      opacity: 0;
      transform: translateY(-4px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .keyword-pill.missing {
    background-color: var(--color-grey-light);
    color: var(--color-slate-light);
  }

  .keyword-pill.present {
    background-color: var(--color-sage);
    color: white;
    animation: pill-fade-in 0.4s ease forwards, pillSuccess 0.3s ease;
  }

  @keyframes pillSuccess {
    0% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.1);
    }
    100% {
      transform: scale(1);
    }
  }

  /* Resume Editor */
  .resume-editor {
    margin-bottom: var(--spacing-md);
  }

  .editor-label {
    display: block;
    font-size: 0.875rem;
    font-weight: 600;
    color: var(--color-slate);
    margin-bottom: var(--spacing-xs);
  }

  .resume-textarea {
    width: 100%;
    padding: var(--spacing-md);
    border: 2px solid var(--color-grey-light);
    border-radius: var(--border-radius);
    font-family: var(--font-sans);
    font-size: 0.9375rem;
    color: var(--color-slate);
    line-height: 1.6;
    resize: vertical;
    transition: border-color var(--transition-fast);
  }

  .resume-textarea:focus {
    outline: none;
    border-color: var(--color-sage);
    box-shadow: 0 0 0 3px rgba(107, 144, 128, 0.1);
  }

  .resume-textarea::placeholder {
    color: var(--color-grey);
    line-height: 1.6;
  }

  .editor-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: var(--spacing-sm);
  }

  .copy-btn {
    padding: var(--spacing-sm) var(--spacing-lg);
  }

  .copy-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .char-count {
    font-size: 0.875rem;
    color: var(--color-slate-light);
  }

  /* Guidance */
  .guidance {
    padding: var(--spacing-md);
    background-color: var(--color-bg-warning);
    border-left: 4px solid var(--color-amber);
    border-radius: var(--border-radius);
  }

  .guidance-text {
    font-size: 0.9375rem;
    color: var(--color-slate);
    margin: 0;
    line-height: 1.6;
  }

  /* Loading State */
  .loading-state {
    padding: var(--spacing-lg);
    background-color: var(--color-bg-neutral);
    border-radius: var(--border-radius);
  }

  .loading-header {
    display: flex;
    align-items: center;
    gap: var(--spacing-sm);
    margin-bottom: var(--spacing-lg);
  }

  .loading-spinner {
    width: 20px;
    height: 20px;
    border: 2px solid var(--color-grey-light);
    border-top-color: var(--color-sage);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    flex-shrink: 0;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .loading-text {
    font-size: 0.9375rem;
    color: var(--color-slate);
    font-weight: 600;
  }

  /* Progress Dashboard */
  .progress-dashboard {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-sm);
  }

  .progress-item {
    display: flex;
    align-items: center;
    gap: var(--spacing-sm);
    padding: var(--spacing-sm) var(--spacing-md);
    background-color: var(--color-card);
    border-radius: var(--border-radius);
    border-left: 3px solid var(--color-grey-light);
    transition: all var(--transition-medium);
  }

  .progress-item.received {
    border-left-color: var(--color-sage);
    background-color: var(--color-bg-success);
  }

  .progress-item.received .progress-icon {
    color: var(--color-sage);
    font-weight: 700;
    animation: checkmark-pop 0.3s ease;
  }

  @keyframes checkmark-pop {
    0% {
      transform: scale(0.8);
      opacity: 0;
    }
    50% {
      transform: scale(1.2);
    }
    100% {
      transform: scale(1);
      opacity: 1;
    }
  }

  .progress-icon {
    font-size: 1.125rem;
    color: var(--color-grey);
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .progress-label {
    font-size: 0.875rem;
    color: var(--color-slate);
    font-weight: 500;
  }

  .progress-item:not(.received) .progress-label {
    color: var(--color-slate-light);
    font-style: italic;
  }

  /* Error State */
  .error-state {
    padding: var(--spacing-md);
    background-color: var(--color-bg-error);
    border-left: 4px solid var(--color-amber);
    border-radius: var(--border-radius);
    display: flex;
    flex-direction: column;
    gap: var(--spacing-sm);
  }

  .error-text {
    font-size: 0.9375rem;
    color: var(--color-slate);
    margin: 0;
  }

  .btn-retry {
    align-self: flex-start;
    padding: var(--spacing-xs) var(--spacing-md);
    background-color: var(--color-sage);
    color: white;
    border: none;
    border-radius: var(--border-radius);
    font-family: var(--font-sans);
    font-size: 0.875rem;
    font-weight: 600;
    cursor: pointer;
    transition: background-color var(--transition-fast);
  }

  .btn-retry:hover {
    background-color: var(--color-sage-light);
  }

  @media (prefers-reduced-motion: reduce) {
    .keyword-pill {
      animation: none;
      opacity: 1;
    }
    .keyword-pill.present {
      animation: none;
    }
    .loading-spinner {
      animation: none;
    }
    .progress-item.received .progress-icon {
      animation: none;
    }
    .coverage-badge.medium,
    .coverage-badge.high {
      animation: none;
    }
  }

  @media (max-width: 600px) {
    .header {
      flex-direction: column;
      align-items: flex-start;
      gap: var(--spacing-xs);
    }

    .editor-actions {
      flex-direction: column;
      align-items: stretch;
      gap: var(--spacing-sm);
    }

    .copy-btn {
      width: 100%;
    }
  }
</style>
