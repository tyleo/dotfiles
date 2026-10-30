// This mod adds a prefix key like the herdr TUI's. `ctrl-b` opens this popup,
// and a bound key runs one of the commands below. Any other key, or Esc,
// closes it. The keys live in keys.json's "mod:prefix" section because a mod
// section wins over global bindings like `ctrl-1`.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, closeOverlay, focused, hc, home, keys, nextCommand, notify, openOverlay, props, run, theme } from "herdr";

// type "pane": the output shows in a dialog that closes when the command exits.
// type "shell": runs detached in the background.
const COMMANDS = {
  "code": { type: "shell", command: "code .", description: "code ." },
  "forklift": { type: "shell", command: "open -a ForkLift .", description: "open -a ForkLift ." },
  "git-ddth": { type: "shell", command: "git ddth", description: "git ddth" },
  "git-ddtp": { type: "shell", command: "git ddtp", description: "git ddtp" },
  "git-pull": { type: "pane", command: "git pull; echo; echo 'Press Enter to continue...'; read _", description: "git pull" },
  "git-push": { type: "pane", command: "git push; echo; echo 'Press Enter to continue...'; read _", description: "git push" },
  "git-push-force": { type: "pane", command: "git push --force-with-lease; echo; echo 'Press Enter to continue...'; read _", description: "git push --force-with-lease" },
};

const bindings = () => keys().filter((k) => k.section === "mod:prefix" && k.action.startsWith("prefix."));

export default class Prefix extends View {
  init(_props, cx) {
    this.cwd = focused()?.cwd ?? home();
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.spawn(async () => {
      const c = await nextCommand();
      // The command outlives this popup because herdr-core runs it.
      await this.dispatch(c).catch((e) => notify({ title: c, body: String(e), level: "error" }));
      closeOverlay(props().overlay);
    });
  }

  async dispatch(name) {
    const agent = /^agent-([1-9])$/.exec(name);
    if (agent) {
      const a = agents()[Number(agent[1]) - 1];
      if (a) run("agent.focus", { terminal: a.address });
      return;
    }
    const c = COMMANDS[name];
    if (!c) return;
    const r = await hc(["run", "--bg", "--json", "--rm", "--no-parent", "--cwd", this.cwd, "--", "sh", "-c", c.command]);
    if (r.code !== 0) throw new Error(r.stderr.trim());
    if (c.type === "pane") {
      const { address } = JSON.parse(r.stdout);
      openOverlay({ kind: "dialog", width: 0.8, height: 0.8, layout: { type: "block", content: { terminal: address } } });
    }
  }

  render(cx) {
    const t = theme();
    const bound = bindings();
    const keyed = new Set(bound.map((k) => k.keys));
    const row = (key, text) => h_flex().id(`k-${key}`).gap(12)
      .child(div().w(72).text_color(t.accent).child(key))
      .child(div().flex_1().truncate().text_color(t.foreground).child(text));
    return v_flex()
      .id("prefix")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (keyed.has(e.keystroke) || ["shift", "control", "alt", "platform", "function"].includes(e.key)) return;
        closeOverlay(props().overlay);
        cx.stop_propagation();
      })
      .size_full()
      .p(12)
      .gap(4)
      .bg(t.popover)
      .text_size(13)
      .child(div().pb(4).text_size(11).text_color(t.dim).child("Prefix"))
      .children(bound.filter((k) => !k.action.startsWith("prefix.agent-"))
        .map((k) => row(k.keys, COMMANDS[k.action.slice("prefix.".length)]?.description ?? k.action)))
      .child(row("ctrl-1..9", "focus agent"));
  }
}
