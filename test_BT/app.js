const routes = {
  obzor: {
    title: "Обзор",
    path: "/obzor",
    ready: "overview",
  },
  configurator: {
    title: "Конфигуратор",
    path: "/configurator",
    ready: "configurator",
  },
  network: {
    title: "Сеть",
    path: "/network",
    ready: "section",
    notice: "Сетевые параметры контроллера на этом экране не редактируются.",
  },
  logs: {
    title: "Журналы",
    path: "/logs",
    ready: "section",
    notice: "Просмотр журналов и diagnostic bundle входят в отдельный результат.",
  },
};

const savedName = "Контроллер переговорной";
const state = {
  route: "obzor",
  view: "ready",
  savedName,
  pendingRoute: null,
};

const contentBody = document.querySelector("#content-body");
const sectionTitle = document.querySelector("#section-title");
const sectionRoute = document.querySelector("#section-route");
const contourDot = document.querySelector("#contour-dot");
const contourLabel = document.querySelector("#contour-label");
const dialog = document.querySelector("#dirty-dialog");
const saveError = document.querySelector("#save-error");
const dirtyMessage = document.querySelector("#dirty-message");

function currentName() {
  const input = document.querySelector("#controller-name");
  return input ? input.value : state.savedName;
}

function projectDirty() {
  return typeof configurator !== "undefined" && configurator.isDirty();
}

function isDirty() {
  return currentName() !== state.savedName || projectDirty();
}

function setPressed(selector, value) {
  document.querySelectorAll(selector).forEach((button) => {
    const key = button.dataset.route || button.dataset.state;
    button.setAttribute("aria-pressed", String(key === value));
    if (button.dataset.route) {
      if (key === value) button.setAttribute("aria-current", "page");
      else button.removeAttribute("aria-current");
    }
  });
}

function render() {
  const route = routes[state.route];
  sectionTitle.textContent = route.title;
  sectionRoute.textContent = route.path;
  setPressed("[data-route]", state.route);
  setPressed("[data-state]", state.view);
  contourDot.dataset.tone = state.view === "offline" ? "bad" : "good";
  contourLabel.textContent = state.view === "offline" ? "Нет связи с сервером" : "Локальный контур";
  contentBody.classList.toggle("content-body-configurator", state.route === "configurator" && state.view === "ready");
  contentBody.innerHTML = templates[state.view](route);
  if (state.route === "configurator" && state.view === "ready") {
    configurator.mount(document.querySelector("#configurator-root"));
  }
  const input = document.querySelector("#controller-name");
  if (input) {
    input.addEventListener("input", () => {
      document.querySelector("#dirty-flag").textContent = isDirty() ? "Есть несохранённое изменение" : "";
    });
  }
}

const templates = {
  ready(route) {
    if (route.ready === "overview") return overview();
    if (route.ready === "configurator") return `<div id="configurator-root"></div>`;
    return `
      <article class="panel state-panel">
        <h3>${route.title}</h3>
        <p>${route.notice}</p>
        <p>Оболочка и боковая навигация остаются на месте.</p>
      </article>`;
  },
  loading() {
    return `
      <article class="panel state-panel">
        <h3>Загрузка раздела</h3>
        <p>Данные ещё не получены. Это не пустой результат и не ошибка.</p>
      </article>`;
  },
  empty() {
    return `
      <article class="panel state-panel">
        <h3>Нет данных</h3>
        <p>Сервер подтвердил пустой ответ. Оболочка доступна.</p>
        <button class="action" type="button" id="back-to-ready">Вернуться к обзору</button>
      </article>`;
  },
  error() {
    return `
      <article class="panel state-panel">
        <span class="severity" data-level="error">Ошибка</span>
        <h3>Раздел не открылся</h3>
        <p>Не удалось получить данные раздела. Повторите запрос или останьтесь в оболочке.</p>
        <button class="action" type="button" id="retry-ready">Повторить</button>
        <p class="tech">Контекст для роли с правом диагностики: route=${routes[state.route].path}; code=section-load-failed</p>
      </article>`;
  },
  offline() {
    return `
      <article class="panel state-panel">
        <span class="severity" data-level="offline">Нет связи</span>
        <h3>Сервер недоступен</h3>
        <p>Команды не ставятся в очередь. После восстановления нужен повторный запрос состояния.</p>
        <button class="action" type="button" disabled>Повторить сейчас нельзя</button>
      </article>`;
  },
  denied() {
    return `
      <article class="panel state-panel">
        <span class="severity" data-level="denied">Нет доступа</span>
        <h3>Раздел не разрешён</h3>
        <p>Сервер не подтвердил право на этот маршрут. Данные раздела не показаны.</p>
        <button class="action" type="button" id="back-to-ready">К разрешённому обзору</button>
      </article>`;
  },
};

function overview() {
  return `
    <div class="grid">
      <article class="panel">
        <h3>Контроллер</h3>
        <label class="field">
          <span>Отображаемое имя</span>
          <input id="controller-name" value="${escapeHtml(state.savedName)}">
        </label>
        <p class="dirty-flag" id="dirty-flag"></p>
        <dl class="facts">
          <div><dt>Контур</dt><dd>Локальный, без облака</dd></div>
          <div><dt>Локаль</dt><dd>Русский</dd></div>
          <div><dt>Сессия</dt><dd>Подтверждена сервером</dd></div>
          <div><dt>Внешние ресурсы</dt><dd>Не требуются</dd></div>
        </dl>
      </article>
      <article class="panel">
        <h3>Текущий раздел</h3>
        <ul class="status-list">
          <li><span>Состояние</span><span class="tone-good">Готово</span></li>
          <li><span>Активный маршрут</span><span>/obzor</span></li>
          <li><span>Источник прав</span><span>Сервер</span></li>
          <li><span>Акцентный цвет</span><span class="tone-warn">Черновик</span></li>
          <li><span>Конфигуратор</span><span>Черновик OUT-UI-002</span></li>
        </ul>
        <button class="action" type="button" id="open-configurator">Открыть конфигуратор</button>
      </article>
    </div>`;
}

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function setDirtyDialog(open) {
  dialog.classList.toggle("hidden", !open);
  dialog.setAttribute("aria-hidden", open ? "false" : "true");
}

function openDirtyDialog() {
  const parts = [];
  if (projectDirty()) parts.push(configurator.dirtyMessage());
  if (currentName() !== state.savedName) parts.push("Имя контроллера изменено.");
  dirtyMessage.textContent = `${parts.join(" ")} Переход возможен только после явного выбора.`;
  saveError.classList.add("hidden");
  setDirtyDialog(true);
  document.querySelector("#save-and-leave").focus();
}

function requestRoute(nextRoute) {
  if (nextRoute === state.route) return;
  if (isDirty()) {
    state.pendingRoute = nextRoute;
    state.pendingView = null;
    openDirtyDialog();
    return;
  }
  state.route = nextRoute;
  state.view = "ready";
  render();
}

document.querySelectorAll("[data-route]").forEach((button) => {
  button.addEventListener("click", () => requestRoute(button.dataset.route));
});

document.querySelectorAll("[data-state]").forEach((button) => {
  button.addEventListener("click", () => {
    if (isDirty()) {
      state.pendingRoute = state.route;
      state.pendingView = button.dataset.state;
      openDirtyDialog();
      return;
    }
    state.view = button.dataset.state;
    render();
  });
});

contentBody.addEventListener("click", (event) => {
  if (event.target.id === "open-configurator") {
    requestRoute("configurator");
    return;
  }
  if (event.target.id === "back-to-ready" || event.target.id === "retry-ready") {
    state.route = "obzor";
    state.view = "ready";
    render();
  }
});

document.querySelector("#cancel-leave").addEventListener("click", () => {
  state.pendingRoute = null;
  state.pendingView = null;
  setDirtyDialog(false);
});

document.querySelector("#discard-and-leave").addEventListener("click", () => {
  if (projectDirty()) configurator.discard();
  finishLeave();
});

document.querySelector("#save-and-leave").addEventListener("click", () => {
  if (state.view === "offline" || state.pendingView === "offline") {
    saveError.classList.remove("hidden");
    return;
  }
  if (projectDirty()) configurator.save();
  const input = document.querySelector("#controller-name");
  if (input) state.savedName = input.value;
  finishLeave();
});

function finishLeave() {
  if (state.pendingRoute) state.route = state.pendingRoute;
  state.view = state.pendingView || "ready";
  state.pendingRoute = null;
  state.pendingView = null;
  setDirtyDialog(false);
  render();
}

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && !dialog.classList.contains("hidden")) {
    document.querySelector("#cancel-leave").click();
  }
});

render();
