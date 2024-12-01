defmodule Safari.Virtual.CesiumAssetGenerateTilesetTokenCalculcation do
  # An example concatenation calculation, that accepts the delimiter as an argument,
  # and the fields to concatenate as options
  use Ash.Resource.Calculation

  # Optional callback that verifies the passed in options (and optionally transforms them)
  @impl true
  def init(opts) do
    {:ok, opts}
  end

  # @impl true
  # # A callback to tell Ash what keys must be loaded/selected when running this calculation
  # # you can include related data here, but be sure to include the attributes you need from said related data
  # # i.e `posts: [:title, :body]`.
  # def load(_query, opts, _context) do

  # end

  @impl true
  def calculate(records, _opts, _context) do
    Enum.map(records, fn _record ->
      %{token: "jwt", expiry_in_seconds: 1}
    end)
  end

  # You can implement this callback to make this calculation possible in the data layer
  # *and* in elixir. Ash expressions are already executable in Elixir or in the data layer, but this gives you fine grain control over how it is done
  # @impl true
  # def expression(opts, context) do
  # end
end
