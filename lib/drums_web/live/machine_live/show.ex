defmodule DrumsWeb.MachineLive.Show do
  use DrumsWeb, :live_view

  alias Drums.Machines

  @default_state [
    %{
      sound: "kick",
      pattern: [1, 0, 1, 0, 1, 0, 1, 0]
    },
    %{
      sound: "snare",
      pattern: [0, 1, 0, 1, 0, 1, 0, 1]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, state: @default_state, active_tab: 0, playing: false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:machine, Machines.get_machine!(id))}
  end

  def handle_event("tab_click", %{"index" => tab}, socket) do
    {tab, ""} = Integer.parse(tab)
    {:noreply, assign(socket, active_tab: tab)}
  end

  def handle_event("toggle_playback", _params, %{assigns: %{playing: playing}} = socket) do
    {:noreply, assign(socket, playing: !playing)}
  end


  @impl true
  def handle_event("toggle_beat", %{"part" => part, "beat" => beat}, %{assigns: %{state: state}} = socket) do
    {part, ""} = Integer.parse(part)
    {beat, ""} = Integer.parse(beat)

    socket = assign(socket, state: toggle_beat(state, part, beat))
    {:noreply, socket}
  end

  defp toggle_beat(state, part_index, beat) do
   part = Enum.at(state, part_index)
   pattern = part.pattern
   new_pattern = List.replace_at(pattern, beat, flip(Enum.at(pattern, beat)))
   new_part = Map.put(part, :pattern, new_pattern)
   List.replace_at(state, part_index, new_part)
  end

  defp flip(bit) do
    if bit == 0, do: 1, else: 0
  end

  defp page_title(:show), do: "Show Machine"
  defp page_title(:edit), do: "Edit Machine"
end
