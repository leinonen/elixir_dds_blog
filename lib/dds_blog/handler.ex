# Docs
# https://ninenines.eu/docs/en/cowboy/2.0/manual/
# https://github.com/devinus/markdown

defmodule DdsBlog.Handler do
  def init({:tcp, :http}, req, opts) do
    {:ok, req, opts}
  end

  def handle(req, state) do
    {method, req} = :cowboy_req.method(req)
    {param, req} = :cowboy_req.binding(:filename, req)
    IO.inspect param
    {:ok, req} = get_file(method, param, req)
    {:ok, req, state}
  end

  def get_file("GET", :undefined, req) do
    headers = [{"content-type", "text/html"}]
    file_lists = File.ls! "priv/contents/"
    title = "Welcome to DDS Blog"
    content = print_articles file_lists, ""
    body = process_template "index", [content: content, title: title]
    {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
  end

  def get_file("GET", param, req) do
    headers = [{"content-type", "text/html"}]
    {:ok, file} = File.read "priv/contents/#{param}.md"
    title = String.capitalize param
    content = Markdown.to_html file
    body = process_template "index", [content: content, title: title]
    {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
  end

  def print_articles [h|t], index_contents do
    {:ok, article} = File.read "priv/contents/" <> h
    sliced = String.slice article, 0, 1000
    marked = Markdown.to_html sliced
    filename = String.slice(h, 0, String.length(h) - 3)
    more = process_template "more_button", [filename: filename]
    print_articles t, index_contents <> marked <> more
  end

  def process_template(template, data) do
    EEx.eval_file "priv/themes/#{template}.html.eex", data
  end

  def print_articles [], index_contents do
    index_contents
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end