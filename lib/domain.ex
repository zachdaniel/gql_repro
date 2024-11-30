defmodule Domain do
  use Ash.Domain

  resources do
    resource AshGraphql.Test.OscarNomination
    resource AshGraphql.Test.Location
    resource AshGraphql.Test.Movie
  end
end
