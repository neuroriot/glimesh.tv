defmodule GlimeshWeb.Users.PreferenceLive do
  use GlimeshWeb, :user_settings_live_view

  alias Glimesh.Accounts
  alias Glimesh.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="container">
      <h2 class="mt-4"><%= gettext("Preferences") %></h2>

      <div class="card">
        <div class="card-body">
          <.form
            :let={f}
            for={@preference_changeset}
            phx-submit="update"
            phx-change="validate"
            class="form"
          >
            <h3><%= gettext("Accessibility") %></h3>
            <p>
              <%= gettext(
                "More accessibility options are coming soon to make Glimesh more comfortable for everyone."
              ) %>
            </p>

            <h3 class="mt-4"><%= gettext("Site Content") %></h3>

            <div class="form-group">
              <%= label(f, gettext("Language:")) %>
              <%= select(f, :locale, Application.get_env(:glimesh, :locales), class: "custom-select") %>
              <%= error_tag(f, :locale) %>
            </div>

            <div class="form-group">
              <%= label(f, gettext("Mature Content Visibility:")) %>
              <div class="custom-control custom-switch">
                <%= checkbox(f, :show_mature_content, class: "custom-control-input") %>
                <label class="custom-control-label" for={input_id(f, :show_mature_content)}>
                  <%= gettext("Bypass Mature Content Warning") %>
                </label>
              </div>
              <%= error_tag(f, :show_mature_content) %>

              <small class="form-text text-muted">
                <%= gettext(
                  "Automatically bypass our Mature Content warning by enabling this preference."
                ) %>
              </small>
            </div>

            <div class="form-group">
              <%= label(f, gettext("Gift Subscription Options:")) %>
              <div class="custom-control custom-switch">
                <%= checkbox(f, :gift_subs_enabled, class: "custom-control-input") %>
                <label class="custom-control-label" for={input_id(f, :gift_subs_enabled)}>
                  <%= gettext("Receive Gift Subscriptions") %>
                </label>
              </div>
              <%= error_tag(f, :gift_subs_enabled) %>

              <small class="form-text text-muted">
                <%= gettext(
                  "By turning this off you will no longer be able to receive gift subscriptions"
                ) %>
              </small>
            </div>

            <h3 class="mt-4"><%= gettext("Look & Feel") %></h3>

            <div class="form-group">
              <%= label(f, gettext("Site Theme:")) %>
              <br />
              <div class="custom-control custom-radio custom-control-inline">
                <%= radio_button(f, :site_theme, "dark",
                  checked: input_value(f, :site_theme) == "dark",
                  class: "custom-control-input"
                ) %>
                <label class="custom-control-label" for={input_id(f, :site_theme, "dark")}>
                  <%= gettext("Dark") %>
                </label>
              </div>
              <div class="custom-control custom-radio custom-control-inline">
                <%= radio_button(f, :site_theme, "light",
                  checked: input_value(f, :site_theme) == "light",
                  class: "custom-control-input"
                ) %>
                <label class="custom-control-label" for={input_id(f, :site_theme, "light")}>
                  <%= gettext("Light") %>
                </label>
              </div>
              <%= error_tag(f, :site_theme) %>

              <small class="form-text text-muted">
                <%= gettext(
                  "Change your Glimesh experience to feel a little lighter, or a little darker."
                ) %>
              </small>
            </div>

            <div class="form-group">
              <%= label(f, gettext("Chat Timestamp Visibility:")) %>
              <div class="custom-control custom-switch">
                <%= checkbox(f, :show_timestamps, class: "custom-control-input") %>
                <%= label(f, :show_timestamps, gettext("Show Chat Timestamps"),
                  class: "custom-control-label"
                ) %>
              </div>
              <small class="form-text text-muted">
                <%= gettext("Show the time a message was posted in chat.") %>
              </small>
            </div>

            <div class="form-group">
              <%= label(f, gettext("Mod Icons Visibility:")) %>
              <div class="custom-control custom-switch">
                <%= checkbox(f, :show_mod_icons, class: "custom-control-input") %>
                <%= label(f, :show_mod_icons, gettext("Show Action Mod Icons"),
                  class: "custom-control-label"
                ) %>
              </div>
              <small class="form-text text-muted">
                <%= gettext("Shows the timeout / ban / etc icons on a chat message.") %>
              </small>
            </div>

            <%= submit(gettext("Update Settings"), class: "btn btn-primary mt-4") %>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(
        :preference_changeset,
        Accounts.change_user_preference(Accounts.get_user_preference!(user))
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"user_preference" => preference_params}, socket) do
    preference_changeset =
      Accounts.change_user_preference(
        Accounts.get_user_preference!(socket.assigns.current_user),
        preference_params
      )

    socket =
      assign(socket,
        preference_changeset: Map.put(preference_changeset, :action, :validate)
      )

    {:noreply, socket}
  end

  def handle_event("update", %{"user_preference" => preference_params}, socket) do
    current_user_pref = Accounts.get_user_preference!(socket.assigns.current_user)

    case Accounts.update_user_preference(current_user_pref, preference_params) do
      {:ok, applied_user} ->
        {:noreply, socket |> put_flash(:info, gettext("Preferences updated successfully."))}

      {:error, changeset} ->
        {:noreply, assign(socket, :preference_changeset, Map.put(changeset, :action, :insert))}
    end
  end
end