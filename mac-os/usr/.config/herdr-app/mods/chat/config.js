// Settings for the chat. Saving this file applies them at once.
export default {
  // Size of the chat's body text in px, or null for the terminal's font size.
  // The chat's other text scales with it. Code and terminal text always shows
  // at the terminal's size. For scale, 14 looks the same size as a 13 px
  // terminal font, whose letters fill more of their size than Anthropic Sans's.
  font_size: 15,
  // Font of the chat: the first of these this machine has, else the layout's
  // interface font.
  font: ["Anthropic Sans"],
  // Font of the agent's replies, picked the same way. Empty uses `font`.
  reply_font: [],
  // How wide `font` runs next to a typical sans, for sizing your message
  // bubbles before they are drawn. Raise it if your messages wrap early, lower
  // it if bubbles leave space on the right.
  letter_width: 1.09,
};
