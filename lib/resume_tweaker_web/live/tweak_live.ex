defmodule ResumeTweakerWeb.TweakLive do
  use ResumeTweakerWeb, :live_view

  alias ResumeTweaker.{Resumes, LLM}

  @impl true
  def mount(_params, session, socket) do
    # Get or create session ID for anonymous tracking
    session_id = session["session_id"] || generate_session_id()

    {:ok,
     socket
     |> assign(:session_id, session_id)
     |> assign(:resume_content, "")
     |> assign(:job_description, "")
     |> assign(:tweaked_output, "")
     |> assign(:streaming, false)
     |> assign(:error, nil)
     |> assign(:resume_id, nil)}
  end

  @impl true
  def handle_event("update_resume", %{"resume" => resume}, socket) do
    {:noreply, assign(socket, :resume_content, resume)}
  end

  @impl true
  def handle_event("update_job_desc", %{"job_desc" => job_desc}, socket) do
    {:noreply, assign(socket, :job_description, job_desc)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    resume_content = socket.assigns.resume_content
    job_description = socket.assigns.job_description

    # Validate inputs
    cond do
      String.trim(resume_content) == "" ->
        {:noreply, assign(socket, :error, "Please enter your resume")}

      String.trim(job_description) == "" ->
        {:noreply, assign(socket, :error, "Please enter the job description")}

      true ->
        # Create submission record
        case Resumes.create_submission(resume_content, job_description, socket.assigns.session_id) do
          {:ok, resume} ->
            # Start streaming
            socket =
              socket
              |> assign(:streaming, true)
              |> assign(:tweaked_output, "")
              |> assign(:error, nil)
              |> assign(:resume_id, resume.id)

            # Spawn async task for LLM call
            parent = self()

            Task.start(fn ->
              callback = fn
                {:partial, chunk} ->
                  send(parent, {:llm_partial, chunk})

                {:done, result} ->
                  send(parent, {:llm_done, result})

                {:error, error} ->
                  send(parent, {:llm_error, error})
              end

              case LLM.tweak_resume_stream(resume_content, job_description, callback) do
                {:ok, metadata} ->
                  send(parent, {:llm_complete, metadata})

                {:error, reason} ->
                  send(parent, {:llm_error, reason})
              end
            end)

            {:noreply, socket}

          {:error, _changeset} ->
            {:noreply, assign(socket, :error, "Failed to save submission")}
        end
    end
  end

  @impl true
  def handle_info({:llm_partial, chunk}, socket) do
    # Append chunk to output
    updated_output = socket.assigns.tweaked_output <> extract_text(chunk)
    {:noreply, assign(socket, :tweaked_output, updated_output)}
  end

  @impl true
  def handle_info({:llm_done, result}, socket) do
    # Final result received, update output if needed
    final_output = extract_final_result(result)
    {:noreply, assign(socket, :tweaked_output, final_output)}
  end

  @impl true
  def handle_info({:llm_complete, metadata}, socket) do
    # Save the result to database
    if socket.assigns.resume_id do
      Resumes.save_tweak_result(
        socket.assigns.resume_id,
        socket.assigns.tweaked_output,
        metadata
      )
    end

    {:noreply, assign(socket, :streaming, false)}
  end

  @impl true
  def handle_info({:llm_error, reason}, socket) do
    {:noreply,
     socket
     |> assign(:streaming, false)
     |> assign(:error, "Error: #{inspect(reason)}")}
  end

  # Helper to extract text from chunk
  defp extract_text(chunk) when is_binary(chunk), do: chunk
  defp extract_text(%{content: content}), do: content
  defp extract_text(_), do: ""

  # Helper to extract final result
  defp extract_final_result(%{content: content}) when is_binary(content), do: content
  defp extract_final_result(result) when is_binary(result), do: result
  defp extract_final_result(_), do: ""

  defp generate_session_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto p-6">
      <h1 class="text-3xl font-bold mb-6">Resume Tweaker</h1>

      <%= if @error do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          <%= @error %>
        </div>
      <% end %>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <div>
          <label class="block text-sm font-medium mb-2">Your Resume</label>
          <textarea
            phx-change="update_resume"
            name="resume"
            class="w-full h-64 p-3 border rounded-lg"
            placeholder="Paste your resume here..."
            disabled={@streaming}
          ><%= @resume_content %></textarea>
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Job Description</label>
          <textarea
            phx-change="update_job_desc"
            name="job_desc"
            class="w-full h-64 p-3 border rounded-lg"
            placeholder="Paste the job description here..."
            disabled={@streaming}
          ><%= @job_description %></textarea>
        </div>
      </div>

      <div class="mb-6">
        <button
          phx-click="submit"
          disabled={@streaming}
          class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          <%= if @streaming, do: "Processing...", else: "Tweak Resume" %>
        </button>
      </div>

      <%= if @tweaked_output != "" or @streaming do %>
        <div class="mt-6">
          <h2 class="text-xl font-semibold mb-3">Tweaked Resume</h2>
          <div class="bg-gray-50 p-4 rounded-lg border min-h-64">
            <pre class="whitespace-pre-wrap font-mono text-sm"><%= @tweaked_output %></pre>
            <%= if @streaming do %>
              <span class="inline-block animate-pulse">▊</span>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
