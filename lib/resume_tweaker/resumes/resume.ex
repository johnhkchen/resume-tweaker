defmodule ResumeTweaker.Resumes.Resume do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resumes" do
    field :original_content, :string
    field :job_description, :string
    field :session_id, :string
    field :metadata, :map

    has_many :tweak_results, ResumeTweaker.Resumes.TweakResult

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(resume, attrs) do
    resume
    |> cast(attrs, [:original_content, :job_description, :session_id, :metadata])
    |> validate_required([:original_content, :job_description, :session_id])
  end
end
