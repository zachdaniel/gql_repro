defmodule Safari.Virtual.CesiumAssetPollChange do
  use Ash.Resource.Change

  @impl true
  def change(changeset = %{data: _ca = %{state: :uploading}}, _opts, _context) do
    changeset
  end

  def change(changeset = %{data: _ca = %{state: :processing}}, _opts, _context) do
    changeset
  end

  def change(changeset = %{data: _ca = %{state: :archiving}}, _opts, _context) do
    changeset
  end

  def change(changeset = %{data: _ca = %{state: :downloading}}, _opts, _context) do
    changeset
  end
end
