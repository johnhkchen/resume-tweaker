defmodule ResumeTweaker.Repo.Migrations.CreateResumes do
  use Ecto.Migration

  def change do
    create table(:resumes) do
      add :original_content, :text
      add :job_description, :text
      add :session_id, :string
      add :metadata, :map

      timestamps(type: :utc_datetime)
    end
  end
end
