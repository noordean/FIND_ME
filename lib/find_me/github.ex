defmodule FindMe.Github do
  @headers ["User-agent": Application.get_env(:find_me, :user_agent),
    "Authorization": "token #{Application.get_env(:find_me, :token)}",
    "Accept": "application/vnd.github.v3.text-match+json"]

  def fetch(project, query, count) do
    HTTPoison.get("https://api.github.com/search/issues?q=#{query}+type:pr+user:#{project}", @headers)
      |> handle_response
      |> IO.inspect
  end

  def handle_response({:ok, %{status_code: 200, body: body}}), do: { :ok, body }

  def handle_response({:ok, %{status_code: _, body: body}}), do: { :error, body }
end
