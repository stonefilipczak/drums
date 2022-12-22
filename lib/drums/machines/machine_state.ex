defmodule Drums.Machines.MachineState do
  use GenServer

  alias Phoenix.PubSub

  @name :machine_state

  @default_state [
    %{
      sound: "kick",
      pattern: [1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0]
    },
    %{
      sound: "snare",
      pattern: [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]
    },
    %{
      sound: "hat closed",
      pattern: [0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0]
    },
    %{
      sound: "hat open",
      pattern: [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]
    },
    %{
      sound: "ride",
      pattern: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    },
    %{
      sound: "clap",
      pattern: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]
    },
    %{
      sound: "high tom",
      pattern: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]
    },
    %{
      sound: "low tom",
      pattern: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]
    }
  ]

  def init(init_arg) do
    {:ok, init_arg}
  end

  ## external API (runs in client process)
  def topic do
    "state"
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @default_state, name: @name)
  end

  def current(), do: GenServer.call(@name, :current)

  def update(%{"part" => part, "beat" => beat}),
    do: GenServer.call(@name, {:update, %{"part" => part, "beat" => beat}})

  ## implementation (runs in this genserver process)

  def handle_call(:current, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update, %{"part" => part, "beat" => beat}}, _from, state) do
    new_state = toggle_beat(state, part, beat)

    PubSub.broadcast(Drums.PubSub, topic(), {:state, new_state})
    {:reply, new_state, new_state}
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
end
