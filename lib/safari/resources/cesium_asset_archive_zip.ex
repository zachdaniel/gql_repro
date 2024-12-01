defmodule Safari.Virtual.CesiumAssetArchiveZip do
  defstruct [:asset_id, :archive_id, :size]
  alias __MODULE__

  def new(asset_id, archive_id, size) do
    %CesiumAssetArchiveZip{asset_id: asset_id, archive_id: archive_id, size: size}
  end
end
