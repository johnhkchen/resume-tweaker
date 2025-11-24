defmodule ResumeTweaker.Resumes.TweakResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tweak_results" do
    field :tweaked_content, :string
    field :model_used, :string
    field :prompt_tokens, :integer
    field :completion_tokens, :integer
    field :processing_time_ms, :integer

    belongs_to :resume, ResumeTweaker.Resumes.Resume

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tweak_result, attrs) do
    tweak_result
    |> cast(attrs, [:tweaked_content, :model_used, :prompt_tokens, :completion_tokens, :processing_time_ms, :resume_id])
    |> validate_required([:tweaked_content, :model_used, :resume_id])
  end
end
