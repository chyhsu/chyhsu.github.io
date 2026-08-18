const tabGroups = [...document.querySelectorAll("[data-tabs]")];

function panelFor(button, group) {
  const target = button.dataset.tabTarget;
  return target ? group.querySelector(`#${CSS.escape(target)}`) : null;
}

function activate(group, index, focus = false) {
  const buttons = [...group.querySelectorAll("[data-tab-button]")];
  const panels = buttons.map((button) => panelFor(button, group));
  if (!buttons[index] || panels.some((panel) => !panel)) return;

  buttons.forEach((button, buttonIndex) => {
    const selected = buttonIndex === index;
    button.setAttribute("aria-selected", String(selected));
    button.tabIndex = selected ? 0 : -1;
    panels[buttonIndex].hidden = !selected;
  });
  if (focus) buttons[index].focus();
}

function indexForFragment(group) {
  if (!window.location.hash) return -1;
  let fragment;
  try {
    fragment = decodeURIComponent(window.location.hash.slice(1));
  } catch {
    return -1;
  }
  const target = document.getElementById(fragment);
  if (!target) return -1;
  const panels = [...group.querySelectorAll("[data-tab-panel]")];
  return panels.findIndex((panel) => panel === target || panel.contains(target));
}

function initialize(group) {
  const list = group.querySelector("[data-tab-list]");
  const buttons = [...group.querySelectorAll("[data-tab-button]")];
  const panels = buttons.map((button) => panelFor(button, group));
  if (!list || buttons.length < 2 || panels.some((panel) => !panel)) return;

  list.setAttribute("role", "tablist");
  list.setAttribute("aria-label", group.dataset.tabsLabel || "Choose content");
  buttons.forEach((button, index) => {
    button.setAttribute("role", "tab");
    button.setAttribute("aria-controls", panels[index].id);
    panels[index].setAttribute("role", "tabpanel");
    panels[index].setAttribute("aria-labelledby", button.id);

    button.addEventListener("click", () => activate(group, index));
    button.addEventListener("keydown", (event) => {
      const keys = ["ArrowLeft", "ArrowRight", "Home", "End"];
      if (!keys.includes(event.key)) return;
      event.preventDefault();
      const next = event.key === "Home" ? 0
        : event.key === "End" ? buttons.length - 1
          : (index + (event.key === "ArrowRight" ? 1 : -1) + buttons.length) % buttons.length;
      activate(group, next, true);
    });
  });

  group.classList.add("tabs-ready");
  activate(group, Math.max(0, indexForFragment(group)));
}

tabGroups.forEach(initialize);
window.addEventListener("hashchange", () => {
  tabGroups.forEach((group) => {
    const index = indexForFragment(group);
    if (index >= 0) activate(group, index);
  });
});
