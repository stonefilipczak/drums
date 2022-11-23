defmodule Drums.Repo.Migrations.CreateMachines do
  use Ecto.Migration

  def change do
    create table(:machines) do
      add :name, :string
      add :state, :map

      timestamps()
    end
  end
end
