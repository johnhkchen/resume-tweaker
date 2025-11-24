<script lang="ts">
  /**
   * AddJobForm - Svelte Island
   * Paste job text → Extract data → Save to local DB → Trigger Toyota Production System analysis
   */
  import { createJob, updateJob, getUserProfile, getJob } from "../../lib/db";

  let jobText = "";
  let jobUrl = "";
  let isLoading = false;
  let errorMessage = "";
  let successMessage = "";

  import { triggerJobAnalysis } from "../../lib/analysis";
  import { queue, type Task } from "../../lib/queue";
  import { triggerJobExtraction } from "../../lib/job-tasks";
  import { onMount } from "svelte";

  let activeTask: Task | null = null;
  let unsubscribeTask: (() => void) | null = null;

  async function handleSubmit(event: Event) {
    event.preventDefault();
    errorMessage = "";
    successMessage = "";

    if (!jobText.trim()) {
      errorMessage = "Please paste the job posting text";
      return;
    }

    isLoading = true;

    try {
      const task = await triggerJobExtraction(jobText.trim(), jobUrl.trim());
      localStorage.setItem("anchor_active_job_task", task.id);
      subscribeToTask(task);
    } catch (error) {
      errorMessage =
        error instanceof Error ? error.message : "Failed to start extraction";
      isLoading = false;
    }
  }

  function subscribeToTask(task: Task) {
    activeTask = task;
    isLoading = task.status === "pending" || task.status === "processing";

    if (unsubscribeTask) unsubscribeTask();

    unsubscribeTask = queue.subscribe(task.id, (updatedTask) => {
      activeTask = updatedTask;
      isLoading =
        updatedTask.status === "pending" || updatedTask.status === "processing";

      if (updatedTask.status === "completed") {
        localStorage.removeItem("anchor_active_job_task");
        if (updatedTask.result) {
          const job = updatedTask.result;

          // Success!
          successMessage = `Saved: ${job.title} at ${job.company}`;
          jobText = ""; // Clear the input
          jobUrl = "";

          // Dispatch event for dashboard to refresh
          window.dispatchEvent(
            new CustomEvent("job-added", {
              detail: { job },
            }),
          );

          // Clear success message after 3 seconds
          setTimeout(() => {
            successMessage = "";
          }, 3000);
        }
      } else if (updatedTask.status === "failed") {
        localStorage.removeItem("anchor_active_job_task");
        errorMessage = updatedTask.error || "Failed to extract job data";
      }
    });
  }

  async function checkActiveTasks() {
    const activeTaskId = localStorage.getItem("anchor_active_job_task");
    if (activeTaskId) {
      const task = await queue.getTask(activeTaskId);
      if (task && (task.status === "pending" || task.status === "processing")) {
        subscribeToTask(task);
      } else {
        localStorage.removeItem("anchor_active_job_task");
      }
    }
  }

  onMount(() => {
    checkActiveTasks();
  });
</script>

<div class="add-job-form">
  <h2 class="form-title">Add a Job</h2>
  <p class="form-description">
    Paste the job posting from anywhere—LinkedIn, Indeed, a PDF, even an email.
    We'll extract what matters.
  </p>

  <form on:submit={handleSubmit}>
    <div class="textarea-group">
      <textarea
        bind:value={jobText}
        placeholder="Paste the full job posting here...

Example:
Senior Software Engineer at Acme Corp
San Francisco, CA (Remote)

We're looking for an experienced engineer to join our platform team..."
        class="job-textarea"
        disabled={isLoading}
        aria-label="Job posting text"
        rows="12"
      ></textarea>
    </div>

    <div class="url-group">
      <label for="job-url" class="url-label">
        Job URL (optional - for your reference)
      </label>
      <input
        id="job-url"
        type="url"
        bind:value={jobUrl}
        placeholder="https://linkedin.com/jobs/view/..."
        class="url-input-small"
        disabled={isLoading}
      />
    </div>

    <button type="submit" class="btn-primary submit-btn" disabled={isLoading}>
      >
      {#if isLoading}
        <span class="spinner"></span> Extracting...
      {:else}
        Add Job
      {/if}
    </button>

    {#if errorMessage}
      <p class="message message-error" role="alert">{errorMessage}</p>
    {/if}

    {#if successMessage}
      <p class="message message-success" role="status">{successMessage}</p>
    {/if}
  </form>
</div>

<style>
  .add-job-form {
    background: var(--color-card);
    border-radius: var(--border-radius-lg);
    padding: var(--spacing-xl);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    margin-bottom: var(--spacing-xl);
  }

  .form-title {
    font-family: var(--font-serif);
    font-size: 1.5rem;
    font-weight: 600;
    color: var(--color-slate);
    margin-bottom: var(--spacing-sm);
  }

  .form-description {
    font-size: 0.9375rem;
    color: var(--color-slate-light);
    margin-bottom: var(--spacing-lg);
  }

  .textarea-group {
    margin-bottom: var(--spacing-md);
  }

  .job-textarea {
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

  .job-textarea:focus {
    outline: none;
    border-color: var(--color-sage);
    box-shadow: 0 0 0 3px rgba(107, 144, 128, 0.1);
  }

  .job-textarea:disabled {
    background-color: var(--color-bg-input);
    cursor: not-allowed;
  }

  .job-textarea::placeholder {
    color: var(--color-grey);
    line-height: 1.6;
  }

  .url-group {
    margin-bottom: var(--spacing-md);
  }

  .url-label {
    display: block;
    font-size: 0.875rem;
    color: var(--color-slate-light);
    margin-bottom: var(--spacing-xs);
  }

  .url-input-small {
    width: 100%;
    padding: var(--spacing-sm) var(--spacing-md);
    border: 2px solid var(--color-grey-light);
    border-radius: var(--border-radius);
    font-family: var(--font-sans);
    font-size: 0.9375rem;
    color: var(--color-slate);
    transition: border-color var(--transition-fast);
  }

  .url-input-small:focus {
    outline: none;
    border-color: var(--color-sage);
  }

  .url-input-small:disabled {
    background-color: var(--color-bg-input);
    cursor: not-allowed;
  }

  .url-input-small::placeholder {
    color: var(--color-grey);
  }

  .submit-btn {
    width: 100%;
    font-size: 1rem;
    padding: var(--spacing-md) var(--spacing-lg);
  }

  .submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .message {
    margin-top: var(--spacing-md);
    padding: var(--spacing-sm) var(--spacing-md);
    border-radius: var(--border-radius);
    font-size: 0.9375rem;
  }

  .message-error {
    background-color: var(--color-bg-error);
    color: var(--color-text-error);
    border-left: 4px solid var(--color-border-error);
  }

  .message-success {
    background-color: var(--color-bg-success-muted);
    color: var(--color-text-success);
    border-left: 4px solid var(--color-border-success);
  }

  .spinner {
    display: inline-block;
    width: 1em;
    height: 1em;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 1s ease-in-out infinite;
    margin-right: 0.5em;
    vertical-align: middle;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>
