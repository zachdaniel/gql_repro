defmodule Safari.Virtual do
  use Ash.Domain, extensions: []

  resources do
    resource Safari.Virtual.CesiumAsset
    resource Safari.Virtual.CesiumLocation
    resource Safari.Virtual.CesiumAssetArchiveZipDownload
    resource Safari.Virtual.CesiumAssetFileCopy
    resource Safari.Virtual.VirtualOutcropModel
  end
end
