defmodule FindMe.Github do
  @headers ["User-agent": Application.get_env(:find_me, :user_agent),
    "Authorization": "token #{Application.get_env(:find_me, :token)}",
    "Accept": "application/vnd.github.v3.text-match+json"]

  def fetch(project, query, count) do
    HTTPoison.get("https://api.github.com/search/issues?q=#{query}+type:pr+user:#{project}&sort=created&order=desc&per_page=#{count}", @headers)
      |> handle_response
      |> extract_json_response
      |> extract_result_data
      |> draw_table
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}), do: { :ok, JSX.decode(body) }

  defp handle_response({:ok, %{status_code: _, body: body}}), do: { :error, JSX.decode(body) }

  defp handle_response({:error, _}) do
    IO.puts "Connection error!"
    System.halt(2)
  end

  defp extract_json_response({:ok, {:ok, json_results}}), do: json_results

  defp extract_json_response({:error, {:ok, json_error}}) do
    json_error["errors"]
      |> Enum.at(0)
      |> Map.get("message")
      |> IO.puts

    System.halt(2)
  end

  defp extract_result_data(json_results) do
    Enum.map(json_results["items"], fn(result) ->
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

  defp extract_comment_number(object_url) do
    split_object_url = String.split(object_url, "/")
    comment = split_object_url |> Enum.at(-2)
    if comment == "comments" do
      "#discussion_r#{Enum.at(split_object_url, -1)}"
    end
  end

  defp draw_table(result_data) do
    longest_user = columns(result_data, "User") |> longest_value
    longest_link = columns(result_data, "Link") |> longest_value
    longest_date = columns(result_data, "Date") |> longest_value

    user_header = String.pad_trailing("User", longest_user)
    date_header = String.pad_trailing("Date", longest_date)
    link_header = String.pad_trailing("Link", longest_link)

    user_dashes = String.duplicate("-", longest_user)
    date_dashes = String.duplicate("-", longest_date)
    link_dashes = String.duplicate("-", longest_link)

    IO.puts "|#{user_header}|#{date_header}|#{link_header}|"
    IO.puts "|#{user_dashes}|#{date_dashes}|#{link_dashes}|"
    for result <- result_data do
      IO.puts "|#{result["User"] |> String.pad_trailing(longest_user)}|#{result["Date"] |> String.pad_trailing(longest_date)}|#{result["Link"] |> String.pad_trailing(longest_link)}|"
    end
  end

  defp longest_value(columns), do: columns |> Enum.sort(&(String.length(&1) >= String.length(&2))) |> Enum.at(0) |> String.length

  defp columns(result_data, column_name) do
    for result <- result_data, do: result[column_name]
  end
end
