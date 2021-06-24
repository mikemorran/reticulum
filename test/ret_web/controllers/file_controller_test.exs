defmodule RetWeb.FileControllerTest do
  use RetWeb.ConnCase
  import Ret.TestHelpers

  test "Uploaded HTML files are served as plain text", %{conn: conn} do
    uuid = store_file(content: "hello", content_type: "text/html", token: "secret")
    conn |> assert_file_content_type(expected_content_type: "text/plain", uuid: uuid, token: "secret")
  end

  test "Uploaded JavaScript files are served as plain text", %{conn: conn} do
    uuid = store_file(content: "alert('hello')", content_type: "application/javascript", token: "secret")
    conn |> assert_file_content_type(expected_content_type: "text/plain", uuid: uuid, token: "secret")
  end

  defp store_file(content: content, content_type: content_type, token: token) do
    temp_file = generate_temp_file(content)
    {:ok, uuid} = Ret.Storage.store(%Plug.Upload{path: temp_file}, content_type, token)
    uuid
  end

  defp assert_file_content_type(conn, expected_content_type: expected_content_type, uuid: uuid, token: token) do
    req = conn |> file_path(:show, uuid, token: token)
    resp = conn |> get("#{RetWeb.Endpoint.url()}#{req}")
    [content_type] = resp |> Plug.Conn.get_resp_header("content-type")

    assert content_type == expected_content_type
  end
end
