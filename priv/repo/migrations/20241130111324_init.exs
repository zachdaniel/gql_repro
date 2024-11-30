defmodule GqlRepro.Repo.Migrations.Init do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:oscar_nominations, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :title, :text
      add :movie_id, :uuid
      add :nomination_location_id, :uuid
      add :celebration_location_id, :uuid
    end

    create table(:movies, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:oscar_nominations) do
      modify :movie_id,
             references(:movies,
               column: :id,
               name: "oscar_nominations_movie_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:movies) do
      add :title, :text
    end

    create table(:locations, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:oscar_nominations) do
      modify :nomination_location_id,
             references(:locations,
               column: :id,
               name: "oscar_nominations_nomination_location_id_fkey",
               type: :uuid,
               prefix: "public"
             )

      modify :celebration_location_id,
             references(:locations,
               column: :id,
               name: "oscar_nominations_celebration_location_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:locations) do
      add :city, :text
    end
  end

  def down do
    alter table(:locations) do
      remove :city
    end

    drop constraint(:oscar_nominations, "oscar_nominations_nomination_location_id_fkey")

    drop constraint(:oscar_nominations, "oscar_nominations_celebration_location_id_fkey")

    alter table(:oscar_nominations) do
      modify :celebration_location_id, :uuid
      modify :nomination_location_id, :uuid
    end

    drop table(:locations)

    alter table(:movies) do
      remove :title
    end

    drop constraint(:oscar_nominations, "oscar_nominations_movie_id_fkey")

    alter table(:oscar_nominations) do
      modify :movie_id, :uuid
    end

    drop table(:movies)

    drop table(:oscar_nominations)
  end
end