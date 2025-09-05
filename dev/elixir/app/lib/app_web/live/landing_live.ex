defmodule AppWeb.LandingLive do
  use AppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Replysis")}
  end

  def render(assigns) do
    ~H"""
    <div class="landing-page">
      <header class="hero-section">
        <h1>Welcome to Replysis</h1>
        <p>Your go-to platform for managing replies efficiently.</p>
      </header>

      <main class="content">
        <div class="video-form-section">
          <.live_component
            module={AppWeb.VideoLive.FormComponent}
            id="video-form"
            action={:new}
          />
        </div>

        <div class="video-list-section">
          <!-- Placeholder for replies list -->
          <p class="text-gray-500">Replies will be displayed here after fetching.</p>
        </div>
      </main>
      <footer class="footer">
        <p>&copy; 2024 Replysis. All rights reserved.</p>
      </footer>
    </div>
    """
  end
end
