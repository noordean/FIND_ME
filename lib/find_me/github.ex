defmodule FindMe.Github do
  @headers ["User-agent": Application.get_env(:find_me, :user_agent),
    "Authorization": "token #{Application.get_env(:find_me, :token)}",
    "Accept": "application/vnd.github.v3.text-match+json"]

  def fetch(project, query, count) do
    HTTPoison.get("https://api.github.com/search/issues?q=#{query}+type:pr+user:#{project}", @headers)
      |> handle_response
      |> extract_json_response
      |> extract_result_data
  end

  def handle_response({:ok, %{status_code: 200, body: body}}), do: { :ok, JSX.decode(body) }

  def handle_response({:ok, %{status_code: _, body: body}}), do: { :error, JSX.decode(body) }

  def handle_response({:error, _}) do
    IO.puts "Connection error!"
    System.halt(2)
  end

  def extract_json_response({:ok, {:ok, json_results}}), do: json_results

  def extract_json_response({:error, {:ok, json_error}}) do
    json_error["errors"]
      |> Enum.at(0)
      |> Map.get("message")
      |> IO.puts

    System.halt(2)
  end

  def extract_result_data(json_results) do
    IO.inspect Enum.map(json_results["items"], fn(result) ->
      matches = result["text_matches"] |> Enum.at(0)
      object_url = matches |> Map.get("object_url")
      fragment = matches |> Map.get("fragment")
      comment_number = extract_comment_number(object_url)

      %{
        "Date" => result["created_at"],
        "Link" => "#{result["html_url"]}/#{comment_number}",
        "User" => result["user"]["login"],
        "Content" => fragment
      }
    end)
  end

  def extract_comment_number(object_url) do
    split_object_url = String.split(object_url, "/")
    comment = split_object_url |> Enum.at(-2)
    if comment == "comments" do
      "#discussion_r#{Enum.at(split_object_url, -1)}"
    end
  end
end
