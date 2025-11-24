defmodule ResumeTweaker.ResumesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ResumeTweaker.Resumes` context.
  """

  @doc """
  Generate a resume.
  """
  def resume_fixture(attrs \\ %{}) do
    {:ok, resume} =
      attrs
      |> Enum.into(%{
        job_description: "some job_description",
        metadata: %{},
        original_content: "some original_content",
        session_id: "some session_id"
      })
      |> ResumeTweaker.Resumes.create_resume()

    resume
  end

  @doc """
  Generate a tweak_result.
  """
  def tweak_result_fixture(attrs \\ %{}) do
    {:ok, tweak_result} =
      attrs
      |> Enum.into(%{
        completion_tokens: 42,
        model_used: "some model_used",
        processing_time_ms: 42,
        prompt_tokens: 42,
        tweaked_content: "some tweaked_content"
      })
      |> ResumeTweaker.Resumes.create_tweak_result()

    tweak_result
  end
end
