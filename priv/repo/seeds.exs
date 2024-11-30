# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GqlRepro.Repo.insert!(%GqlRepro.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

movie =
  AshGraphql.Test.Movie
  |> Ash.Changeset.for_create(:create, title: "The Bee movie")
  |> Ash.create!()

nomination_location =
  AshGraphql.Test.Location
  |> Ash.Changeset.for_create(:create, city: "Tokyo")
  |> Ash.create!()

celebration_location =
  AshGraphql.Test.Location
  |> Ash.Changeset.for_create(:create, city: "Hamar")
  |> Ash.create!()

nomination =
  AshGraphql.Test.OscarNomination
  |> Ash.Changeset.for_create(:create,
    title: "Best supporting actor: Zach Daniel",
    nomination_location_id: nomination_location.id,
    celebration_location_id: celebration_location.id,
    movie_id: movie.id
  )
  |> Ash.create!()
