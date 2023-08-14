defmodule Revard.Card.Renderer do
  @moduledoc """
  Card renderer
  """

  import Bitwise
  alias Revard.Card.Utils

  def render(
        %{
          user:
            %{
              "username" => username,
              "discriminator" => discriminator
            } = user_data,
          avatar: avatar_base64,
          background: background_base64
        },
        options
      ) do
    # Background Color
    bg_color = if(Utils.hex_color?(options["bg_color"]), do: options["bg_color"], else: "333333")

    # Mask color
    mask_color =
      if(Utils.hex_color?(options["mask_color"]), do: options["mask_color"], else: "000000")

    # Badge elements
    badges = if(options["hide_badges"] != nil, do: [], else: render_badges(user_data))

    # Status element
    status =
      if(options["hide_status"] != nil, do: nil, else: render_status(user_data, mask_color))

    # SVG height
    height = if(status, do: 176, else: 126)

    """
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xhtml="http://www.w3.org/1999/xhtml" width="400" height="#{height}">
      <foreignObject x="0" y="0" width="400" height="#{height}">
        <div xmlns="http://www.w3.org/1999/xhtml" style="
            height: #{height - 1}px;
            background: ##{bg_color};
            #{if(options["hide_banner"] != nil, do: "", else: "background-image: url(data:image/png;base64,#{background_base64});")}
            background-position: center;
            background-size: cover;
            border-radius: 12px;
            font-family: 'Century Gothic', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
          <div style="
              height: 125px;
              background: ##{mask_color}cc;
              #{if(status, do: "border-top-right-radius: 12px; border-top-left-radius: 12px;", else: "border-radius: 12px;")}
              display: flex;
              align-items: center;">
            <img style="
                height: 64px;
                width: 64px;
                object-fit: cover;
                margin: 30px;
                margin-right: 20px;
                border: 4px solid #{get_status_color(user_data)};
                border-radius: 50%;" src="data:image/png;base64,#{avatar_base64}"/>
            <div style="max-width: 250px;">
              <h3 style="
                margin-bottom: 2px;
                color: #fff;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;">
                #{Utils.encode_string(user_data["display_name"] || username)}
              </h3>
              <h4 style="
                margin-top: 0;
                #{if(length(badges) > 0, do: "margin-bottom: 6px;", else: "")}
                color: #ffffffcc;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;">
                #{Utils.encode_string(username)}##{discriminator}
              </h4>
              <div style="
                  display: #{if(length(badges) > 0, do: "inline-block", else: "none")};
                  background: ##{mask_color}aa;
                  border: 1px solid #ffffff33;
                  border-radius: 8px;
                  height: 26px;
                  padding: 2px;">
                #{Enum.join(badges)}
              </div>
            </div>
          </div>
          #{status}
        </div>
      </foreignObject>
    </svg>
    """
  end

  defp get_status_color(%{"online" => true, "status" => %{"presence" => "Online"}}), do: "#3ABF7E"
  defp get_status_color(%{"online" => true, "status" => %{"presence" => "Idle"}}), do: "#F39F00"
  defp get_status_color(%{"online" => true, "status" => %{"presence" => "Focus"}}), do: "#4799F0"
  defp get_status_color(%{"online" => true, "status" => %{"presence" => "Busy"}}), do: "#F84848"
  defp get_status_color(%{"online" => true}), do: "#3ABF7E"
  defp get_status_color(_other), do: "#A5A5A5"

  defp render_badges(%{"badges" => badges}) do
    [
      (badges &&& 1) == 1 && "developer",
      (badges &&& 2) == 2 && "translator",
      (badges &&& 4) == 4 && "supporter",
      (badges &&& 8) == 8 && "responsible_disclosure",
      (badges &&& 16) == 16 && "founder",
      (badges &&& 32) == 32 && "moderation",
      (badges &&& 256) == 256 && "early_adopter"
    ]
    |> Enum.filter(&(&1 != false))
    |> Enum.map(
      &"""
      <img style="width: 20px; height: 20px; margin: 3px;"
        src="data:image/svg+xml;base64,#{Revard.Card.Badges.svg(&1)}" />
      """
    )
  end

  defp render_badges(_other) do
    []
  end

  defp render_status(%{"online" => true, "status" => %{"text" => status_text}}, mask_color) do
    """
    <div style="
      height: 50px;
      background: ##{mask_color}dd;
      box-shadow: 0 1px 0 #ffffff33 inset;
      font-weight: 600;
      color: #ffffffaa;
      border-bottom-right-radius: 12px;
      border-bottom-left-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;">
        <p style="
          padding: 0 1rem;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;">
          #{Utils.encode_string(status_text)}
        </p>
    </div>
    """
  end

  defp render_status(_other, _color) do
    nil
  end
end
