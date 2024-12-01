defmodule Safari.Outcrop do
  use Ash.Domain, extensions: []

  resources do
    resource Safari.Outcrop.Outcrop
  end
end
