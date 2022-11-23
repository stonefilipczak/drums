defmodule Drums.MachinesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Drums.Machines` context.
  """

  @doc """
  Generate a machine.
  """
  def machine_fixture(attrs \\ %{}) do
    {:ok, machine} =
      attrs
      |> Enum.into(%{
        name: "some name",
        state: %{}
      })
      |> Drums.Machines.create_machine()

    machine
  end
end
