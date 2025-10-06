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
     socket
     |> assign(
       state: State.current(),
       active_tab: 0,
       playing: false,
       expanded: false,
       users: %{}
     )
     |> handle_joins(Presence.list(@presence))}
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

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {
      :noreply,
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    }
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      assign(socket, :users, Map.put(socket.assigns.users, user, meta))
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end
end
