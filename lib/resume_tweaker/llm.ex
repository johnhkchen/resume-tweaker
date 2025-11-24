defmodule ResumeTweaker.LLM do
  @moduledoc """
  LLM client wrapper using BAML for resume tweaking.
  Provides both synchronous and streaming support for LLM calls.
  """

  use BamlElixir.Client, path: "priv/baml_src"

  @doc """
  Tweaks a resume based on a job description using streaming.

  ## Parameters
    - resume_content: The original resume text
    - job_description: The target job description
    - callback: Function to handle streaming chunks (receives {:partial, data}, {:done, result}, or {:error, reason})

  ## Returns
    - {:ok, metadata} on success with token counts and processing time
    - {:error, reason} on failure
  """
  def tweak_resume_stream(resume_content, job_description, callback) when is_function(callback) do
    start_time = System.monotonic_time(:millisecond)

    resume = %{content: resume_content}
    job_desc = %{description: job_description}

    # Use sync_stream for blocking call with callbacks
    result =
      __MODULE__.TweakResume.sync_stream(
        %{resume: resume, job_description: job_desc},
        callback
      )

    end_time = System.monotonic_time(:millisecond)
    processing_time = end_time - start_time

    case result do
      {:ok, tweaked_resume} ->
        metadata = %{
          model_used: "gpt-4o-mini",
          processing_time_ms: processing_time,
          # Note: BAML may provide token counts in the result
          prompt_tokens: nil,
          completion_tokens: nil,
          result: tweaked_resume
        }

        {:ok, metadata}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Tweaks a resume synchronously (without streaming).

  ## Parameters
    - resume_content: The original resume text
    - job_description: The target job description

  ## Returns
    - {:ok, {result, metadata}} on success
    - {:error, reason} on failure
  """
  def tweak_resume(resume_content, job_description) do
    start_time = System.monotonic_time(:millisecond)

    resume = %{content: resume_content}
    job_desc = %{description: job_description}

    result = __MODULE__.TweakResume.call(%{resume: resume, job_description: job_desc})

    end_time = System.monotonic_time(:millisecond)
    processing_time = end_time - start_time

    case result do
      {:ok, tweaked_resume} ->
        metadata = %{
          model_used: "gpt-4o-mini",
          processing_time_ms: processing_time,
          prompt_tokens: nil,
          completion_tokens: nil
        }

        {:ok, {tweaked_resume, metadata}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
