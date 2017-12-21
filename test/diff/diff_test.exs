defmodule Texas.DiffTest do
  use ExUnit.Case

  describe "can get patchset from diff" do
    test "when one child changes" do
      patchset = Texas.Diff.diff(old(), new(:single))
      assert patchset ==
        [ chat: { "div", [{"method", "POST"}, {"action", "/messages"}], [{"div", [], ["another"]}] } ]
    end

    test "when multiple children change" do
      patchset = Texas.Diff.diff(old(), new(:multi))
      assert patchset ==
        [ { :chat, { "div", [{"method", "POST"}, {"action", "/messages"}], [{"div", [], ["another"]}] } },
          { :message_input, {"input", [type: "text", name: "message", placeholder: "blahblahblah"], []} }
        ]
    end
  end

  defp old do
    [texas:
     %{chat: {"div", [{"method", "POST"}, {"action", "/messages"}], []},
       csrf: {"input", [type: "hidden", name: "_csrf_token",
             value: "KzIIJgEMBUsTOS5wMGEhAUFnWB5cAAAAEGMK4JqsKMm3W2Uc3Rmw1w=="], []},
       message_form: {"form", [action: "/add_message", method: "post"], []},
       message_input: {"input",
                        [type: "text", name: "message", placeholder: "Enter a message"], []}}]
  end

  defp new(:single) do
    [texas: %{chat: {"div", [{"method", "POST"}, {"action", "/messages"}],
        [{"div", [], ["another"]}]},
       csrf: {"input",
        [type: "hidden", name: "_csrf_token",
         value: "KzIIJgEMBUsTOS5wMGEhAUFnWB5cAAAAEGMK4JqsKMm3W2Uc3Rmw1w=="], []},
       message_form: {"form", [action: "/add_message", method: "post"], []},
       message_input: {"input",
        [type: "text", name: "message", placeholder: "Enter a message"], []}}]
  end
  defp new(:multi) do
    [texas: %{chat: {"div", [{"method", "POST"}, {"action", "/messages"}],
        [{"div", [], ["another"]}]},
       csrf: {"input",
        [type: "hidden", name: "_csrf_token",
         value: "KzIIJgEMBUsTOS5wMGEhAUFnWB5cAAAAEGMK4JqsKMm3W2Uc3Rmw1w=="], []},
       message_form: {"form", [action: "/add_message", method: "post"], []},
       message_input: {"input",
        [type: "text", name: "message", placeholder: "blahblahblah"], []}}]
  end
end
