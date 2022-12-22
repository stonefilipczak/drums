defmodule DrumsWeb.MachineLive.Show do
  use DrumsWeb, :live_view

  # alias Drums.Machines
  alias Drums.Machines.MachineState, as: State
  alias Phoenix.PubSub
  alias DrumsWeb.Presence

  @topic State.topic()
  @presence "machine:presence"

  @impl true
  def mount(_params, _session, socket) do
    ## Subscribe to state changes
    PubSub.subscribe(Drums.PubSub, @topic)

    ## Subscribe to presence changes
    PubSub.subscribe(Drums.PubSub, @presence)

    ## Set this process to be tracked by presence
    Presence.track(self(), @presence, socket.id, %{})

    {:ok,
     assign(socket,
       state: State.current(),
       active_tab: 0,
       playing: false,
       expanded: false,
       active_users: Enum.count(Presence.list(@presence))
     )}
  end

  # @impl true
  # def handle_params(%{"id" => id}, _, socket) do
  #   {:noreply,
  #    socket
  #    |> assign(:page_title, page_title(socket.assigns.live_action))
  #    |> assign(:machine, Machines.get_machine!(id))}
  # end

  def handle_event("tab_click", %{"index" => tab}, socket) do
    {tab, ""} = Integer.parse(tab)
    {:noreply, assign(socket, active_tab: tab)}
  end

  def handle_event("toggle_playback", _params, %{assigns: %{playing: playing}} = socket) do
    {:noreply, assign(socket, playing: !playing)}
  end

  def handle_event("toggle_expanded", _params, %{assigns: %{expanded: expanded}} = socket) do
    {:noreply, assign(socket, expanded: !expanded)}
  end

  @impl true
  def handle_event(
        "toggle_beat",
        %{"part" => part, "beat" => beat},
        %{assigns: %{state: _state}} = socket
      ) do
    {part, ""} = Integer.parse(part)
    {beat, ""} = Integer.parse(beat)

    State.update(%{"part" => part, "beat" => beat})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:state, state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{active_users: count}} = socket
      ) do
    active_users = count + Enum.count(joins) - Enum.count(leaves)

    {:noreply, assign(socket, :active_users, active_users)}
  end

  defp page_title(:show), do: "Show Machine"
  defp page_title(:edit), do: "Edit Machine"
end
