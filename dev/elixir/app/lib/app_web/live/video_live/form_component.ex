defmodule AppWeb.VideoLive.FormComponent do
  use Phoenix.LiveComponent
  import AppWeb.CoreComponents

  @youtube_regex ~r/^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/)([\w-]{11})(&.*)?$/
  @fetch_replies :fetch_replies
  @loading :loading
  @invalid_url :invalid_url
  @base_url Application.compile_env(:app, [:fastapi_service,:base_url])

  def fetch_replies, do: @fetch_replies
  def loading, do: @loading
  def invalid_url, do: @invalid_url


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
          <p class="text-red-800"><%= @error %></p>
        </div>
      <% end %>

      <%= if @replies do %>
        <div class="mt-6">
          <h3 class="text-lg font-semibold mb-4">Replies Fetched: (<%= length(@replies) %>)</h3>
          <div class="space-y-4 max-h-96 overflow-y-auto">
            <%= for reply <- @replies do %>
              <div class="p-4 bg-gray-50 border border-gray-200 rounded-md">
                <div class="flex items-start space-x-3">
                  <div class="flex-1">
                    <div class="flex items-center space-x-2 mb-2">
                      <span class="font-medium text-gray-900"><%= reply["author"] || "Anonymous" %></span>
                      <%= if reply["published_at"] do %>
                        <span class="text-sm text-gray-500"><%= reply["published_at"] %></span>
                      <% end %>
                    </div>
                    <p class="text-gray-700"><%= reply["text"] || reply["content"] %></p>
                    <%= if reply["likes"] && reply["likes"] > 0 do %>
                      <div class="mt-2 text-sm text-gray-500">
                        👍 <%= reply["likes"] %> likes
                      </div>
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
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
      send(self(), {fetch_replies(), video_id})
      {:noreply,
       socket
       |> assign(:loading, true)
       |> assign(:error, nil)
       |> assign(:replies, nil)}
    else
      {:error, :invalid_url} ->
        {:noreply, assign(socket, :error, "Invalid YouTube URL format.")}


    end
  end


  def handle_info({:fetch_replies, video_id}, socket) do
    case fetch_replies(video_id) do
      {:ok, response_body} ->
        case decode_replies(response_body) do
          {:ok, replies} ->
            {:noreply,
             socket
             |> assign(:loading, false)}
        end
        {:noreply, assign(socket, :loading, false)}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(@loading, false)
         |> assign(:error, "Failed to fetch replies: #{reason}")}
    end
  end

  def fetch_replies(video_id) do
    case Req.post("#{@base_url}/api/v1/fetch-replies-by-video-id", json: %{video_id: video_id}) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status}} ->
        {:error, "Unexpected status code: #{status}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
      end
    end

  defp decode_replies(response_body) when is_map(response_body) do
    # If response_body is already a map, extract replies directly
    case response_body do
      %{"replies" => replies} when is_list(replies) -> {:ok, replies}
      
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
