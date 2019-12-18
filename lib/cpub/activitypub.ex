defmodule CPub.ActivityPub do
  @moduledoc """
  ActivityPub context
  """

  alias Ecto.Multi
  alias Ecto.Changeset

  alias CPub.NS.ActivityStreams, as: AS

  alias CPub.ActivityPub.Activity
  alias CPub.Objects.Object
  alias CPub.LDP.BasicContainer
  alias CPub.Repo

  alias RDF.Description
  alias RDF.Graph

  @activitystreams RDF.Turtle.read_file!("./priv/vocabs/activitystreams2.ttl")
  @doc """
  The ActivityStreams 2.0 ontology
  """
  def activitystreams, do: @activitystreams

  @activity_types (SPARQL.execute_query(@activitystreams,
    SPARQL.query("""
    select ?activity_type
    where {
      ?activity_type rdfs:subClassOf as:Activity .
    }
    """
    ))).results |> Enum.map(&(&1["activity_type"]))
  @doc """
  List of all ActivityStreams Activity types
  """
  def activity_types, do: @activity_types

  @doc """
  Creates an ActivityPub activity, computes side-effects and runs everything in a transaction.
  """
  def create(%RDF.IRI{} = activity_id, %RDF.Graph{} = data) do
    # generate an id for an object that may be created
    object_id = CPub.ID.generate()

    # create the changeset to add the activity
    activity_changeset =
      Activity.changeset(%{data: data[activity_id], id: activity_id})
      # set the object id if it is a create activity
      |> Changeset.update_change(:data, &(set_object_id_if_create_activity(&1, object_id)))

    # create a transaction
    Multi.new

    # insert the activity
    |> Multi.insert(:activity, activity_changeset)

    # insert the object (if a Create activity)
    |> create_object(activity_id, object_id, data)

    # handle Add activity
    |> handle_add(activity_id, data)

    # deliver activity to local recipients
    |> deliver_local(activity_id, data)

    # run the transaction
    |> Repo.transaction
  end

  defp set_object_id_if_create_activity(activity, object_id) do
    if RDF.iri(AS.Create) in activity[RDF.type] do
      activity
      |> Description.delete_predicates(AS.object)
      |> Description.add(AS.object, object_id)
    else
      # don't do anything if not a Create activity
      activity
    end
  end

  # Creates an object if it is a Create activity
  defp create_object(multi, activity_id, object_id, data) do
    if RDF.iri(AS.Create) in data[activity_id][RDF.type] do
      case data[activity_id][AS.object] do

        [original_object_id] ->
          # replace subject
          multi
          |> Multi.insert(:object,
          Object.changeset(%{id: object_id,
                             data: data
                             # remove the activity description and the original object description
                             |> Graph.delete_subjects([original_object_id, activity_id])
                             # replace subject of object with new id and add to graph
                             |> Graph.add(%{data[original_object_id] | subject: object_id})}))

        _ ->
          multi
          |> Multi.error(:object, "could not find object")
      end
    else
      multi
    end
  end

  defp add_to_local(multi, element, to) do
    recipient = Repo.get(Object, to)
    cond do
      BasicContainer.is_basic_container?(recipient[to]) ->
        Multi.update(multi, :deliver_local,
          %BasicContainer{data: recipient[to], id: to}
          |> BasicContainer.add_changeset(element))

      true ->
        multi
        |> Multi.error(:deliver_local, "do not know how to add to local recipient " <> RDF.IRI.to_string(to))
    end
  end

  defp deliver_local(multi, activity_id, data) do
    [AS.to, AS.cc, AS.bcc, AS.bto]
    |> Enum.map(&(Access.get(data[activity_id], &1)))
    |> Enum.reject(&is_nil/1)
    |> Enum.concat()
    |> Enum.filter(&CPub.ID.is_local?/1)
    |> List.foldl(multi, &(add_to_local(&2, activity_id, &1)))
  end

  defp handle_add(multi, activity_id, data) do
    if RDF.iri(AS.Add) in data[activity_id][RDF.type] do
      # TODO: What to do with multiple objects or multiple targets?
      with object <- data[activity_id][AS.object] |> List.first(),
           target <- data[activity_id][AS.target] |> List.first() do
        multi
        |> add_to_local(object,target)
      end
    else
      multi
    end
  end

end
