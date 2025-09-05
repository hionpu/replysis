defmodule AppWeb.VideoLive.FormComponent do
  use Phoenix.LiveComponent
  import AppWeb.CoreComponents

  @youtube_regex ~r/^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/)([\w-]{11})(&.*)?$/

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-submit="fetch_replies" phx-target={@myself}>
        <.input
          field={@form[:youtube_url]}
          type="url"
          label="YouTube URL"
          placeholder="https://www.youtube.com/watch?v=..."
        />
        <div class="mt-4">> <.button phx-disable-with="Fetching replies...">Go</.button></div>
      </.form>

      <%= if @loading do %>
        <div class="mt-4 text-blue-600">
          <div class="animate-spin inline-block w-4 h-4 border-2 border-current border-t-transparent rounded-full mr-2">
          </div>
          Fetching YouTube replies...
        </div>
      <% end %>

      <%= if @error do %>
        <div class="mt-4 p-4 bg-red-50 border border-red-200 rounded-md">
          <p class="text-red-800">{@error}</p>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    form = to_form(%{"youtube_url" => ""})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, form)
     |> assign(:loading, false)
     |> assign(:error, nil)}
  end

  def handle_event("fetch_replies", %{"youtube_url" => url}, socket) do
    with {:ok, video_id} <- extract_video_id(url) do
      send(self(), {:fetch_replies, video_id})
      {:noreply, assign(socket, :loading, true)}
    else
      {:error, :invalid_url} ->
        {:noreply, assign(socket, :error, "Invalid YouTube URL format.")}


    end
  end


  # defp valid_youtube_url?(url) when is_binary(url) do
  #   url =~ @youtube_regex
  # end

  # defp valid_youtube_url?(_), do: false

  defp extract_video_id(url) do
    case Regex.run(@youtube_regex, url) do
      [_full_match, _protocol, _subdomain, _host, video_id, _query_string] -> {:ok, video_id}
      _ -> {:error, :invalid_url}
    end
  end

end
