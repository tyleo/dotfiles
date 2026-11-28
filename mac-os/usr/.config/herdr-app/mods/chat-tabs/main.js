import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, terminals, run, home, notify, nextCommand, openOverlay, theme, window, shared, layout, settings } from "herdr";
import { herdr, away, show } from "./backstage.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// Claude Code or Codex: the agents the chat mod can show.
function isAgent(pane) {
  const term = pane.terminal && terminals().find((x) => x.address === pane.terminal);
  const argv0 = term?.argv?.[0]?.split("/").pop() ?? "";
  const what = `${term?.report?.app ?? ""} ${term?.foreground?.name ?? ""} ${term?.program?.key ?? ""} ${argv0}`.toLowerCase();
  return what.includes("claude") || what.includes("codex");
}

// An agent terminal that moved out of its chat's tab (Hide terminal).
function hasChat(pane) {
  return Boolean(terminals().find((x) => x.address === pane.terminal)?.labels?.["chat.tab"]);
}

// The tab of the chat that agent terminal stepped out of, as tabs are named in
// the lists (with the machine in front for another machine's terminal).
function chatTabOf(pane) {
  const term = pane.terminal && terminals().find((x) => x.address === pane.terminal);
  const id = term?.labels?.["chat.tab"];
  if (!id) return null;
  return term.address.includes("/") ? `${term.address.split("/")[0]}/${id}` : id;
}

export default class Tabs extends View {
  init(_props, cx) {
    this.pressed = null;
    this.panels = JSON.parse(localStorage.getItem("panels") ?? "{}");
    // From a key or another mod: "chat-tabs.switch" flips the shown tab between
    // its chat and its agent's terminal, "chat-tabs.toggle" presses the Chat button.
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        const tab = spaces().find((s) => s.active)?.tabs.find((x) => x.active);
        if (command === "switch") this.switchChat(tab, cx);
        else if (command === "toggle") this.toggleChat(tab, cx);
      }
    });
  }

  // The side panel is remembered per space: switching shows that space's choice
  // (closed if it never had one), and opening or closing it records it.
  syncPanel(space, panel, body, enabled) {
    if (!space || !panel) return;
    const now = panel.hidden ? null : body?.active ?? null;
    if (space.id !== this.space) {
      const first = this.space === undefined;
      this.space = space.id; this.pending = null;
      if (!(first && !(space.id in this.panels))) {
        const stored = this.panels[space.id] ?? null, want = enabled.includes(stored) ? stored : null;
        if (want !== now) {
          this.pending = { want, until: Date.now() + 1000 };
          if (want) { run("layout.select", { stack: "panel-body", child: want }); run("layout.show", { id: "panel" }); }
          else run("layout.hide", { id: "panel" });
          return;
        }
      }
    }
    // Until the restore lands (or something else won), the old state isn't a choice.
    if (this.pending) {
      if (this.pending.want !== now && Date.now() < this.pending.until) return;
      this.pending = null;
    }
    if (this.panels[space.id] === now) return;
    this.panels[space.id] = now;
    localStorage.setItem("panels", JSON.stringify(this.panels));
  }

  // "Chat": shown while the tab has a chat, or a Claude or Codex terminal to
  // open one for. Puts the chat to the right of the agent's terminal, side by
  // side, and closes it from there. The pane header's switch buttons (chat-pane)
  // show one of the two alone.
  // "Back to chat": shown in the tab of an agent terminal that Hide terminal
  // moved out of its chat (Herdr shows that tab when the agent is picked from
  // the lists). Goes to the chat's tab and puts this one away again.
  chatIn(tab, space) {
    const inTab = panes().filter((p) => p.tab === tab?.id);
    const back = inTab.map(chatTabOf).find((id) => id && id !== tab?.id && space?.tabs?.some((x) => x.id === id));
    return {
      back,
      chat: inTab.find((p) => p.mod === "chat"),
      // Not an agent whose chat it hid from (Hide terminal): that one has a chat.
      agent: inTab.find((p) => p.focused && isAgent(p) && !hasChat(p)) ?? inTab.find((p) => isAgent(p) && !hasChat(p)),
      zoomed: inTab.find((p) => p.zoomed),
    };
  }

  // One step toward the chat sitting beside its agent, and from there it closes.
  toggleChat(tab, cx) {
    const { chat, agent, zoomed } = this.chatIn(tab);
    if (this.toggling || (!chat && !agent)) return;
    this.toggling = true;
    cx.spawn(async () => {
      try {
        // Side by side needs the tab unzoomed.
        if (zoomed) await herdr("pane.zoom", { pane: zoomed.pane });
        if (!chat) await herdr("pane.split", { direction: "right", pane: agent.pane, mod: "chat", props: { terminal: agent.terminal } });
        else if (!zoomed) await this.closeChat(chat);
      } catch (e) {
        notify({ title: "Couldn't toggle the chat", body: String(e?.message ?? e), level: "error" });
      }
      this.toggling = false;
    });
  }

  // Shows the chat alone, or the agent's terminal alone when the chat is the one
  // showing. The first time, it opens the chat. Same as the pane header's switch buttons.
  switchChat(tab, cx) {
    const { chat, agent, zoomed } = this.chatIn(tab);
    if (this.toggling || (!chat && !agent)) return;
    this.toggling = true;
    cx.spawn(async (cx) => {
      try {
        let to = chat?.pane;
        if (!chat) to = (await herdr("pane.split", { direction: "right", pane: agent.pane, mod: "chat", props: { terminal: agent.terminal } })).pane;
        else if (chat.zoomed || (!zoomed && chat.focused)) to = await this.terminalOf(chat, cx);
        // pane.zoom on the zoomed pane would unzoom it.
        if (to && !panes().find((p) => p.pane === to)?.zoomed) await herdr("pane.zoom", { pane: to });
      } catch (e) {
        notify({ title: "Couldn't switch", body: String(e?.message ?? e), level: "error" });
      }
      this.toggling = false;
    });
  }

  // The pane of a chat's agent terminal, back in the tab first if Hide terminal moved it out.
  async terminalOf(chat, cx) {
    const here = panes().find((p) => p.tab === chat.tab && isAgent(p));
    if (here) return here.pane;
    const id = chat.tab.split("/").pop();
    const term = terminals().find((x) => x.state === "live" && x.labels?.["chat.tab"] === id && away(x));
    if (!term) return null;
    await show(term);
    // Herdr adopts a returning terminal on its next look, last in the tab.
    for (let i = 0; i < 30; i++) {
      const pane = panes().find((p) => p.terminal === term.address && p.tab === chat.tab)?.pane;
      if (pane) {
        // Trade places so the chat stays on the right.
        await herdr("pane.swap", { pane, target: chat.pane }).catch(() => {});
        return pane;
      }
      await new Promise((r) => cx.timer.after(100, () => r()));
    }
    return null;
  }

  // Closes only the chat. Its terminal comes back first if Hide terminal moved it out of the tab.
  async closeChat(chat) {
    const id = chat.tab.split("/").pop();
    const term = terminals().find((x) => x.state === "live" && x.labels?.["chat.tab"] === id && away(x));
    if (term) await show(term);
    await herdr("pane.close", { pane: chat.pane });
  }

  render() {
    const t = theme();
    const space = spaces().find(p => p.active);
    // Settled tabs are put away (a chat's hidden agent terminal lives in one) unless shown.
    const shown = (space?.tabs ?? []).filter((x) => !x.settled || x.active);
    const stop = (_e, cx) => cx.stop_propagation();
    const button = (id, label, action) => div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", stop).on_click(action).child(label);
    const item = (c, i) => {
      const program = panes().find(p => p.tab === c.id && p.program?.agent)?.program ?? panes().find(p => p.tab === c.id)?.program;
      const name = /^tb\d+$/.test(c.name) ? program?.name ?? "Terminal" : c.name;
      return h_flex().id(`tab-${c.id}`).h(29).px(10).gap(7).rounded(7).items_center().flex_none().text_size(12.8)
        .border(1).border_color(c.active ? t.border : t.chrome).bg(c.active ? t.raised : t.chrome).text_color(c.active ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover))
        .on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.pressed = i; if (e.click_count === 2) run("tab.rename", { id: c.id }); })
        .on_mouse_up("left", () => {
          const from = this.pressed; this.pressed = null;
          if (from !== null && from !== i) run("tab.move", { id: shown[from].id, index: space.tabs.findIndex(x => x.id === c.id) + 1 });
          else run("tab.select", { id: c.id });
        })
        .on_mouse_down("right", (_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }); })
        .when(Boolean(program?.icon), el => el.child(program.tint ? svg(program.icon).size(14).text_color(t.muted) : image(program.icon).size(14)))
        .child(div().max_w(170).truncate().child(c.zoomed ? `${name} Z` : name))
        .when(c.status === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
        .when(c.status === "blocked" || c.status === "done", el => el.child(div().size(6).rounded(3).bg(t[c.status])))
        .when(c.active, el => el.child(div().id(`close-${c.id}`).text_color(t.dim).on_mouse_down("left", stop).on_click((_e, cx) => { cx.stop_propagation(); run("tab.close", { id: c.id }); }).child(svg("mods/pane/close.svg").size(12))));
    };
    const root = layout(), sidebar = find(root, "sidebar"), w = window();
    // Old saved rails and a dragged-narrow sidebar can be smaller than the window buttons.
    const lightsPadding = w?.platform === "macos" && w.titlebar === "none" && !w.fullscreen && root?.traffic_lights
      ? Math.max(10, (root.traffic_lights[0] + 64) / settings().zoom - (sidebar?.hidden ? 0 : sidebar?.size?.px ?? 0))
      : 10;
    const panel = find(root, "panel"), body = find(root, "panel-body");
    const enabled = shared("workspace.panels") ?? ["files", "changes"];
    this.syncPanel(space, panel, body, enabled);
    const panelButton = (id, label, icon) => {
      const on = panel && !panel.hidden && body?.active === id;
      return h_flex().id(`panel-${id}`).h(26).px(8).gap(5).flex_none().items_center().rounded(6)
        .text_size(12).bg(on ? t.selected : t.chrome).text_color(on ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
        .on_click(() => {
          if (on) run("layout.hide", { id: "panel" });
          else { run("layout.select", { stack: "panel-body", child: id }); run("layout.show", { id: "panel" }); }
        }).child(svg(icon).size(14)).child(label);
    };
    const tab = shown.find((c) => c.active);
    const { chat, agent, back, zoomed } = this.chatIn(tab, space);
    const beside = Boolean(chat && !zoomed);
    const chatToggle = h_flex().id("panel-chat").h(26).px(8).gap(5).flex_none().items_center().rounded(6)
      .text_size(12).bg(beside ? t.selected : t.chrome).text_color(beside ? t.foreground : t.muted)
      .hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
      .on_click((_e, cx) => this.toggleChat(tab, cx))
      .child(svg("mods/chat-tabs/chat.svg").size(14)).child("Chat");
    const backButton = h_flex().id("panel-back-chat").h(26).px(8).gap(5).flex_none().items_center().rounded(6)
      .text_size(12).bg(t.chrome).text_color(t.accent).border_1().border_color(t.accent)
      .hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
      .on_click(() => { run("tab.select", { id: back }); run("tab.settle", { id: tab.id }); })
      .child(svg("mods/chat-tabs/chat.svg").size(14)).child("Back to chat");
    return h_flex().size_full().min_w(0).px(10).pl(lightsPadding).gap(3).items_center().bg(t.chrome).border_b(1).border_color(t.border)
      .on_mouse_up("left", () => { this.pressed = null; })
      .on_scroll_wheel(e => { if (Math.abs(e.delta.y) >= 1) run(e.delta.y > 0 ? "tab.prev" : "tab.next"); })
      .child(h_flex().id("tab-scroll").flex_1().min_w(0).h_full().items_center().gap(3).overflow_x_scrollbar().children(shown.map(item)))
      .child(button("tab-new", "+", () => openOverlay({ mod: "new-menu", kind: "popup", width: 250, height: 512 })))
      .when(Boolean(chat || agent), el => el.child(chatToggle))
      .when(Boolean(back && !chat), el => el.child(backButton))
      .when(enabled.includes("files"), el => el.child(panelButton("files", "Files", "mods/files/file.svg")))
      .when(enabled.includes("changes"), el => el.child(panelButton("changes", "Changes", "mods/changes/changes.svg")))
      .when(w?.buttons, el => el.child(button("minimize", w.platform === "windows" ? svg("mods/chat-tabs/win-min.svg").size(16) : "−", () => run("window.minimize")))
        .child(button("maximize", w.platform === "windows" ? svg(`mods/chat-tabs/${w.maximized ? "win-restore" : "win-max"}.svg`).size(16) : "□", () => run("window.maximize")))
        .child(button("close-window", w.platform === "windows" ? svg("mods/chat-tabs/win-close.svg").size(16) : svg("mods/pane/close.svg").size(13), () => run("window.close"))));
  }
}
