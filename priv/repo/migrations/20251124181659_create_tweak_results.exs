defmodule ResumeTweaker.Repo.Migrations.CreateTweakResults do
  use Ecto.Migration

  def change do
    create table(:tweak_results) do
      add :tweaked_content, :text
      add :model_used, :string
      add :prompt_tokens, :integer
      add :completion_tokens, :integer
      add :processing_time_ms, :integer
      add :resume_id, references(:resumes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tweak_results, [:resume_id])
  end
end
