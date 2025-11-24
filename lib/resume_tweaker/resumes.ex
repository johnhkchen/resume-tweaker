defmodule ResumeTweaker.Resumes do
  @moduledoc """
  The Resumes context.
  """

  import Ecto.Query, warn: false
  alias ResumeTweaker.Repo

  alias ResumeTweaker.Resumes.Resume

  @doc """
  Returns the list of resumes.

  ## Examples

      iex> list_resumes()
      [%Resume{}, ...]

  """
  def list_resumes do
    Repo.all(Resume)
  end

  @doc """
  Gets a single resume.

  Raises `Ecto.NoResultsError` if the Resume does not exist.

  ## Examples

      iex> get_resume!(123)
      %Resume{}

      iex> get_resume!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resume!(id), do: Repo.get!(Resume, id)

  @doc """
  Creates a resume.

  ## Examples

      iex> create_resume(%{field: value})
      {:ok, %Resume{}}

      iex> create_resume(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resume(attrs) do
    %Resume{}
    |> Resume.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a resume.

  ## Examples

      iex> update_resume(resume, %{field: new_value})
      {:ok, %Resume{}}

      iex> update_resume(resume, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resume(%Resume{} = resume, attrs) do
    resume
    |> Resume.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a resume.

  ## Examples

      iex> delete_resume(resume)
      {:ok, %Resume{}}

      iex> delete_resume(resume)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resume(%Resume{} = resume) do
    Repo.delete(resume)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resume changes.

  ## Examples

      iex> change_resume(resume)
      %Ecto.Changeset{data: %Resume{}}

  """
  def change_resume(%Resume{} = resume, attrs \\ %{}) do
    Resume.changeset(resume, attrs)
  end

  alias ResumeTweaker.Resumes.TweakResult

  @doc """
  Returns the list of tweak_results.

  ## Examples

      iex> list_tweak_results()
      [%TweakResult{}, ...]

  """
  def list_tweak_results do
    Repo.all(TweakResult)
  end

  @doc """
  Gets a single tweak_result.

  Raises `Ecto.NoResultsError` if the Tweak result does not exist.

  ## Examples

      iex> get_tweak_result!(123)
      %TweakResult{}

      iex> get_tweak_result!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tweak_result!(id), do: Repo.get!(TweakResult, id)

  @doc """
  Creates a tweak_result.

  ## Examples

      iex> create_tweak_result(%{field: value})
      {:ok, %TweakResult{}}

      iex> create_tweak_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tweak_result(attrs) do
    %TweakResult{}
    |> TweakResult.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tweak_result.

  ## Examples

      iex> update_tweak_result(tweak_result, %{field: new_value})
      {:ok, %TweakResult{}}

      iex> update_tweak_result(tweak_result, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tweak_result(%TweakResult{} = tweak_result, attrs) do
    tweak_result
    |> TweakResult.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tweak_result.

  ## Examples

      iex> delete_tweak_result(tweak_result)
      {:ok, %TweakResult{}}

      iex> delete_tweak_result(tweak_result)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tweak_result(%TweakResult{} = tweak_result) do
    Repo.delete(tweak_result)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tweak_result changes.

  ## Examples

      iex> change_tweak_result(tweak_result)
      %Ecto.Changeset{data: %TweakResult{}}

  """
  def change_tweak_result(%TweakResult{} = tweak_result, attrs \\ %{}) do
    TweakResult.changeset(tweak_result, attrs)
  end

  @doc """
  Creates a new resume submission with session tracking.

  ## Parameters
    - original_content: The original resume text
    - job_description: The target job description
    - session_id: Anonymous session identifier

  ## Examples

      iex> create_submission("resume text", "job desc", "session123")
      {:ok, %Resume{}}

  """
  def create_submission(original_content, job_description, session_id) do
    create_resume(%{
      original_content: original_content,
      job_description: job_description,
      session_id: session_id,
      metadata: %{}
    })
  end

  @doc """
  Saves a tweak result for a given resume.

  ## Parameters
    - resume_id: The ID of the resume being tweaked
    - tweaked_content: The LLM-generated tweaked resume
    - metadata: Map containing model_used, processing_time_ms, prompt_tokens, completion_tokens

  ## Examples

      iex> save_tweak_result(1, "tweaked text", %{model_used: "gpt-4o-mini", ...})
      {:ok, %TweakResult{}}

  """
  def save_tweak_result(resume_id, tweaked_content, metadata) do
    create_tweak_result(%{
      resume_id: resume_id,
      tweaked_content: tweaked_content,
      model_used: metadata[:model_used] || "unknown",
      prompt_tokens: metadata[:prompt_tokens],
      completion_tokens: metadata[:completion_tokens],
      processing_time_ms: metadata[:processing_time_ms]
    })
  end

  @doc """
  Gets a resume with its tweak results preloaded.

  ## Examples

      iex> get_resume_with_results!(123)
      %Resume{tweak_results: [%TweakResult{}, ...]}

  """
  def get_resume_with_results!(id) do
    Resume
    |> Repo.get!(id)
    |> Repo.preload(:tweak_results)
  end

  @doc """
  Gets all resumes for a given session.

  ## Examples

      iex> list_resumes_by_session("session123")
      [%Resume{}, ...]

  """
  def list_resumes_by_session(session_id) do
    Resume
    |> where([r], r.session_id == ^session_id)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
  end
end
