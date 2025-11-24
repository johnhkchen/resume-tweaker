defmodule ResumeTweaker.ResumesTest do
  use ResumeTweaker.DataCase

  alias ResumeTweaker.Resumes

  describe "resumes" do
    alias ResumeTweaker.Resumes.Resume

    import ResumeTweaker.ResumesFixtures

    @invalid_attrs %{metadata: nil, session_id: nil, original_content: nil, job_description: nil}

    test "list_resumes/0 returns all resumes" do
      resume = resume_fixture()
      assert Resumes.list_resumes() == [resume]
    end

    test "get_resume!/1 returns the resume with given id" do
      resume = resume_fixture()
      assert Resumes.get_resume!(resume.id) == resume
    end

    test "create_resume/1 with valid data creates a resume" do
      valid_attrs = %{metadata: %{}, session_id: "some session_id", original_content: "some original_content", job_description: "some job_description"}

      assert {:ok, %Resume{} = resume} = Resumes.create_resume(valid_attrs)
      assert resume.metadata == %{}
      assert resume.session_id == "some session_id"
      assert resume.original_content == "some original_content"
      assert resume.job_description == "some job_description"
    end

    test "create_resume/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resumes.create_resume(@invalid_attrs)
    end

    test "update_resume/2 with valid data updates the resume" do
      resume = resume_fixture()
      update_attrs = %{metadata: %{}, session_id: "some updated session_id", original_content: "some updated original_content", job_description: "some updated job_description"}

      assert {:ok, %Resume{} = resume} = Resumes.update_resume(resume, update_attrs)
      assert resume.metadata == %{}
      assert resume.session_id == "some updated session_id"
      assert resume.original_content == "some updated original_content"
      assert resume.job_description == "some updated job_description"
    end

    test "update_resume/2 with invalid data returns error changeset" do
      resume = resume_fixture()
      assert {:error, %Ecto.Changeset{}} = Resumes.update_resume(resume, @invalid_attrs)
      assert resume == Resumes.get_resume!(resume.id)
    end

    test "delete_resume/1 deletes the resume" do
      resume = resume_fixture()
      assert {:ok, %Resume{}} = Resumes.delete_resume(resume)
      assert_raise Ecto.NoResultsError, fn -> Resumes.get_resume!(resume.id) end
    end

    test "change_resume/1 returns a resume changeset" do
      resume = resume_fixture()
      assert %Ecto.Changeset{} = Resumes.change_resume(resume)
    end
  end

  describe "tweak_results" do
    alias ResumeTweaker.Resumes.TweakResult

    import ResumeTweaker.ResumesFixtures

    @invalid_attrs %{tweaked_content: nil, model_used: nil, prompt_tokens: nil, completion_tokens: nil, processing_time_ms: nil}

    test "list_tweak_results/0 returns all tweak_results" do
      tweak_result = tweak_result_fixture()
      assert Resumes.list_tweak_results() == [tweak_result]
    end

    test "get_tweak_result!/1 returns the tweak_result with given id" do
      tweak_result = tweak_result_fixture()
      assert Resumes.get_tweak_result!(tweak_result.id) == tweak_result
    end

    test "create_tweak_result/1 with valid data creates a tweak_result" do
      valid_attrs = %{tweaked_content: "some tweaked_content", model_used: "some model_used", prompt_tokens: 42, completion_tokens: 42, processing_time_ms: 42}

      assert {:ok, %TweakResult{} = tweak_result} = Resumes.create_tweak_result(valid_attrs)
      assert tweak_result.tweaked_content == "some tweaked_content"
      assert tweak_result.model_used == "some model_used"
      assert tweak_result.prompt_tokens == 42
      assert tweak_result.completion_tokens == 42
      assert tweak_result.processing_time_ms == 42
    end

    test "create_tweak_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resumes.create_tweak_result(@invalid_attrs)
    end

    test "update_tweak_result/2 with valid data updates the tweak_result" do
      tweak_result = tweak_result_fixture()
      update_attrs = %{tweaked_content: "some updated tweaked_content", model_used: "some updated model_used", prompt_tokens: 43, completion_tokens: 43, processing_time_ms: 43}

      assert {:ok, %TweakResult{} = tweak_result} = Resumes.update_tweak_result(tweak_result, update_attrs)
      assert tweak_result.tweaked_content == "some updated tweaked_content"
      assert tweak_result.model_used == "some updated model_used"
      assert tweak_result.prompt_tokens == 43
      assert tweak_result.completion_tokens == 43
      assert tweak_result.processing_time_ms == 43
    end

    test "update_tweak_result/2 with invalid data returns error changeset" do
      tweak_result = tweak_result_fixture()
      assert {:error, %Ecto.Changeset{}} = Resumes.update_tweak_result(tweak_result, @invalid_attrs)
      assert tweak_result == Resumes.get_tweak_result!(tweak_result.id)
    end

    test "delete_tweak_result/1 deletes the tweak_result" do
      tweak_result = tweak_result_fixture()
      assert {:ok, %TweakResult{}} = Resumes.delete_tweak_result(tweak_result)
      assert_raise Ecto.NoResultsError, fn -> Resumes.get_tweak_result!(tweak_result.id) end
    end

    test "change_tweak_result/1 returns a tweak_result changeset" do
      tweak_result = tweak_result_fixture()
      assert %Ecto.Changeset{} = Resumes.change_tweak_result(tweak_result)
    end
  end
end
