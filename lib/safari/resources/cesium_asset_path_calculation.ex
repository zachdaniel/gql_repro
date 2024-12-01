defmodule Safari.Virtual.CesiumAssetPathCalculation do
  # An example concatenation calculation, that accepts the delimiter as an argument,
  # and the fields to concatenate as options
  use Ash.Resource.Calculation

  # Optional callback that verifies the passed in options (and optionally transforms them)
  @impl true
  def init(opts) do
    if is_nil(opts[:type]) do
      {:error, "type missing"}
    else
      {:ok, opts}
    end
  end

  @impl true
  def calculate(records, opts, _context) do
    records =
      if opts[:type] == :tileset_embedded do
        Ash.load!(records, :tileset_token)
      else
        records
      end

    Enum.map(records, fn _record ->
      case opts[:type] do
        _ ->
          "http://path.com/foo"
      end
    end)
  end
end
