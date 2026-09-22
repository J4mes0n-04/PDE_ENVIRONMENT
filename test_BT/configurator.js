const configurator = (() => {
  let project = null;
  const ui = {
    mode: "start",
    wizardChoice: "standard",
    wizardError: "",
    deviceChoice: "camera",
    filter: "",
    sortAsc: true,
    collapsed: { device: false, scenario: false },
    dragId: null,
    dialog: null,
    returnFocus: null,
    focusField: null,
    mutation: "Мутаций ещё не было.",
    previewOn: {},
    previewSession: 0,
    caret: null,
    deployFault: false,
    deployLog: "",
    acceptWarnings: false,
    importFail: false,
    exportText: "",
    fieldError: "",
  };

  function escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;");
  }

  function clone(value) {
    return JSON.parse(JSON.stringify(value));
  }

  function isDirty() {
    return Boolean(project && project.dirty);
  }

  function dirtyMessage() {
    return project ? `Проект «${project.name}» содержит несохранённые изменения.` : "";
  }

  function save() {
    if (!project) return { ok: true };
    project.saveCount += 1;
    project.savedRevision = `rev-${project.saveCount}`;
    project.dirty = false;
    project.snapshot = clone({
      name: project.name,
      entities: project.entities,
      links: project.links,
      protection: project.protection,
    });
    if (project.preflight) project.preflight.stale = true;
    ui.mutation = `Сервер подтвердил сохранение ${project.savedRevision}.`;
    return { ok: true };
  }

  function discard() {
    if (!project) return;
    if (!project.snapshot) {
      project = null;
      ui.mode = "start";
      ui.dialog = null;
      ui.mutation = "Несохранённый черновик отброшен.";
      return;
    }
    const snap = clone(project.snapshot);
    project.name = snap.name;
    project.entities = snap.entities;
    project.links = snap.links;
    project.protection = snap.protection;
    project.dirty = false;
    if (!entity(project.selectionId)) project.selectionId = "root";
    if (project.preflight) project.preflight.stale = true;
    ui.dialog = null;
    ui.mutation = `Отброшены изменения после ${project.savedRevision}.`;
  }

  function entity(id) {
    return project ? project.entities.find((item) => item.id === id) || null : null;
  }

  function touch(message) {
    project.dirty = true;
    project.session += 1;
    if (project.preflight) project.preflight.stale = true;
    ui.mutation = message;
    ui.fieldError = "";
  }

  function nameTaken(name, exceptId) {
    return project.entities.some((item) => item.id !== exceptId && item.name.trim().toLowerCase() === name.trim().toLowerCase());
  }

  function createBase(name, origin) {
    project = {
      name,
      origin,
      dirty: true,
      session: 1,
      saveCount: 0,
      savedRevision: null,
      snapshot: null,
      selectionId: "root",
      activeVersion: null,
      rollbackPoint: null,
      emulator: false,
      protection: false,
      entities: [
        { id: "root", parentId: null, type: "root", name, origin: "system", address: "", driver: "" },
      ],
      links: [],
      preflight: null,
      nextId: 1,
    };
    ui.mode = "workspace";
    ui.dialog = null;
    ui.filter = "";
    ui.deployLog = "";
    ui.exportText = "";
    ui.acceptWarnings = false;
    ui.previewSession = 0;
  }

  function addEntity(spec) {
    const id = `${spec.type}-${project.nextId}`;
    project.nextId += 1;
    project.entities.push({
      id,
      parentId: "root",
      type: spec.type,
      name: spec.name,
      origin: spec.origin,
      address: spec.address || "",
      driver: spec.driver || "",
    });
    project.selectionId = id;
    return id;
  }

  function applyStandardRoom() {
    createBase("Переговорная, 6 мест", "wizard");
    addEntity({ type: "device", name: "Дисплей", origin: "wizard", driver: "display.local" });
    addEntity({ type: "device", name: "Кодек ВКС", origin: "wizard", driver: "codec.local" });
    addEntity({ type: "device", name: "Микрофон", origin: "wizard", driver: "mic.local" });
    addEntity({ type: "scenario", name: "Начало встречи", origin: "wizard" });
    project.selectionId = "device-1";
    ui.mutation = "Мастер записал один черновик. Deploy не запускался. Мутаций состава: 1.";
  }

  function addLink(fromId, toId) {
    if (project.links.some((link) => link.from === fromId && link.to === toId)) {
      ui.mutation = "Повтор не создал дубль. Мутаций: 0.";
      return;
    }
    project.links.push({ id: `link-${project.nextId}`, from: fromId, to: toId });
    project.nextId += 1;
    const from = entity(fromId);
    const to = entity(toId);
    touch(`Связь «${from.name}» → «${to.name}». Мутаций: 1.`);
  }

  function describeDrop(sourceId, targetId) {
    const source = entity(sourceId);
    const target = entity(targetId);
    if (!source || !target) return "Цель не найдена. Мутаций: 0.";
    if (project.protection) return "Сервер запретил изменение защищённого проекта. Мутаций: 0.";
    if (source.type !== "device" || target.type !== "device" || source.id === target.id) {
      return `Нельзя связать «${source.name}» и «${target.name}»: связь допускается только между разными устройствами. Мутаций: 0.`;
    }
    return `Связать «${source.name}» с «${target.name}».`;
  }

  function applyDrop(sourceId, targetId) {
    const hint = describeDrop(sourceId, targetId);
    if (!hint.startsWith("Связать")) {
      ui.mutation = hint;
      return;
    }
    addLink(sourceId, targetId);
  }

  function revisionText() {
    const saved = project.savedRevision || "не сохранено";
    return project.dirty ? `сессия изменена · сохранено: ${saved}` : `сохранено: ${saved}`;
  }

  function hardwareText() {
    if (project.emulator) return "эмулятор: simulated";
    return "оборудование недоступно";
  }

  function sorted(type) {
    return project.entities
      .filter((item) => item.type === type)
      .sort((a, b) => {
        const order = a.name.localeCompare(b.name, "ru");
        return ui.sortAsc ? order : -order;
      });
  }

  function matchesFilter(item) {
    const query = ui.filter.trim().toLowerCase();
    if (!query) return true;
    return item.name.toLowerCase().includes(query);
  }

  function selectionHidden() {
    const selected = entity(project.selectionId);
    return Boolean(selected && selected.type !== "root" && !matchesFilter(selected));
  }

  function runPreflight() {
    ui.mode = "preflight";
    if (!project.savedRevision || project.dirty) {
      ui.mutation = "Preflight не запущен: нужна сохранённая ревизия без несохранённых изменений.";
      return;
    }
    const blockers = [];
    const warnings = [];
    const devices = project.entities.filter((item) => item.type === "device");
    if (devices.length === 0) {
      blockers.push({
        id: "no-devices",
        entityId: "root",
        field: null,
        title: "Нет устройств",
        text: "Пример проверки макета: в проекте нет устройств. Обязательный состав ещё не утверждён.",
      });
    }
    devices.forEach((item) => {
      if (!item.address.trim()) {
        blockers.push({
          id: `address-${item.id}`,
          entityId: item.id,
          field: "address",
          title: "Не задан адрес",
          text: `У «${item.name}» пустой адрес. Deploy этой ревизии заблокирован.`,
        });
      }
    });
    warnings.push(project.emulator
      ? {
          id: "emulator",
          entityId: devices[0] ? devices[0].id : "root",
          field: null,
          title: "Эмуляция не заменяет объект",
          text: "Simulated-состояния не подтверждают совместимость реального оборудования.",
        }
      : {
          id: "hardware",
          entityId: devices[0] ? devices[0].id : "root",
          field: null,
          title: "Оборудование недоступно",
          text: "Проверка связи не выполнена. Это предупреждение, не ошибка схемы.",
        });
    project.preflight = {
      revision: project.savedRevision,
      stale: false,
      blockers,
      warnings,
    };
    ui.acceptWarnings = false;
    ui.mutation = `Preflight для ${project.savedRevision}: блокеров ${blockers.length}, предупреждений ${warnings.length}.`;
  }

  function deployBlockReason() {
    if (!project.savedRevision || project.dirty) return "Сначала сохраните ревизию.";
    if (!project.preflight || project.preflight.stale || project.preflight.revision !== project.savedRevision) {
      return "Нужен актуальный preflight этой сохранённой ревизии.";
    }
    if (project.preflight.blockers.length > 0) return "Блокер запрещает deploy.";
    if (project.preflight.warnings.length > 0 && !ui.acceptWarnings) {
      return "Предупреждение остаётся видимым. Продолжение требует явного подтверждения.";
    }
    return "";
  }

  function canDeploy() {
    return deployBlockReason() === "";
  }

  function runDeploy(kind) {
    const reason = deployBlockReason();
    if (reason) {
      ui.deployLog = reason;
      return;
    }
    const previous = project.activeVersion || "нет активной версии";
    if (kind === "unknown") {
      ui.deployLog = "Запрос принят. Связь потеряна до итога. Успех и rollback не предполагаются.";
      return;
    }
    if (kind === "fault" || ui.deployFault) {
      ui.deployLog = `Запрос принят. Применение прервано. Новая версия не активирована. Активна прежняя версия: ${previous}. Rollback выполнен и подтверждён сервером. Черновик сохранён.`;
      return;
    }
    const nextNumber = project.activeVersion ? Number(project.activeVersion.slice(4)) + 1 : 1;
    project.activeVersion = `act-${nextNumber}`;
    project.rollbackPoint = `rb-${project.saveCount}`;
    ui.deployLog = `Запрос принят. Применение завершено целиком. Активная версия: ${project.activeVersion}. Точка возврата: ${project.rollbackPoint}.`;
  }

  function note() {
    return `<p class="cfg-note">Макет по OUT-UI-002, статус draft. Состав сущностей и контракты сервера не утверждены. Облако, CDN и внешние шрифты не используются.</p>`;
  }

  function startPage() {
    return `
      ${note()}
      <div class="cfg-choices">
        <button class="cfg-choice" type="button" id="open-wizard" data-action="open-wizard">
          <strong>Готовая комната</strong>
          <span class="choice-copy">Мастер показывает состав до записи и создаёт редактируемый черновик, не активный проект.</span>
        </button>
        <button class="cfg-choice" type="button" id="create-manual" data-action="create-manual">
          <strong>Вручную</strong>
          <span class="choice-copy">Пустая структура без скрытых устройств, связей и сценариев. Дальше только явные действия.</span>
        </button>
      </div>`;
  }

  function wizardPage() {
    const missing = ui.wizardChoice === "missing-driver";
    const items = missing
      ? ["Дисплей — драйвер есть", "Кодек ВКС — обязательный драйвер отсутствует", "Микрофон — драйвер есть", "Сценарий «Начало встречи»"]
      : ["Дисплей", "Кодек ВКС", "Микрофон", "Сценарий «Начало встречи»"];
    return `
      ${note()}
      <article class="panel stack">
        <h3>Мастер готовой комнаты</h3>
        <label><input type="radio" name="wizard-choice" value="standard" ${ui.wizardChoice === "standard" ? "checked" : ""}> Переговорная, 6 мест</label>
        <label><input type="radio" name="wizard-choice" value="missing-driver" ${missing ? "checked" : ""}> Комната без драйвера кодека</label>
        <p class="hint">Состав ниже — пример макета, не утверждённый контракт. Запись произойдёт одним change-set только после подтверждения.</p>
        <ul>${items.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>
        <p class="modal-error ${ui.wizardError ? "" : "hidden"}">${escapeHtml(ui.wizardError)}</p>
        <div class="cfg-tools">
          <button class="primary" type="button" id="confirm-room" data-action="confirm-room">Создать черновик</button>
          <button type="button" id="cancel-wizard" data-action="cancel-wizard">Отмена</button>
        </div>
      </article>`;
  }

  function badge(item) {
    if (project.emulator && item.type === "device") return `<span class="badge" data-kind="simulated">simulated</span>`;
    if (item.origin === "wizard") return `<span class="badge">мастер</span>`;
    if (item.origin === "template") return `<span class="badge">шаблон</span>`;
    return "";
  }

  function treeButton(item) {
    const selected = item.id === project.selectionId;
    const drag = item.type === "device" ? ` draggable="true" data-drag="${item.id}"` : "";
    const drop = item.type === "root" ? "" : ` data-drop="${item.id}"`;
    return `<button class="tree-item" type="button" id="tree-item-${item.id}" role="treeitem" data-select="${item.id}"${drag}${drop}${selected ? ' aria-current="true"' : ""}><span>${escapeHtml(item.name)}</span>${badge(item)}</button>`;
  }

  function group(type, title) {
    const items = sorted(type).filter(matchesFilter);
    const collapsed = ui.collapsed[type];
    const selected = entity(project.selectionId);
    const hiddenSelection = selected && selected.type === type && collapsed;
    return `
      <div class="group-label">${title}</div>
      <button type="button" data-action="collapse" data-group="${type}">${collapsed ? "Развернуть" : "Свернуть"}</button>
      ${hiddenSelection ? `<p class="hint">Выбран «${escapeHtml(selected.name)}», группа свёрнута. Selection не перенесён.</p>` : ""}
      ${collapsed ? "" : items.map(treeButton).join("")}
      ${!collapsed && items.length === 0 ? `<p class="hint">В этой группе ничего нет.</p>` : ""}`;
  }

  function workspacePage() {
    const selected = entity(project.selectionId);
    const devices = sorted("device");
    const scenarios = sorted("scenario");
    const links = project.links.map((link) => {
      const from = entity(link.from);
      const to = entity(link.to);
      return `<li>${escapeHtml(from ? from.name : "?")} → ${escapeHtml(to ? to.name : "?")}</li>`;
    }).join("");
    return `
      <div class="cfg-workspace">
        <section class="cfg-pane" aria-label="Дерево проекта">
          <h3>Дерево</h3>
          <p class="hint">${escapeHtml(revisionText())}</p>
          <div class="cfg-tools">
            <input id="tree-filter" data-field="filter" placeholder="Фильтр по имени" value="${escapeHtml(ui.filter)}" aria-label="Фильтр дерева">
            <button type="button" data-action="sort">${ui.sortAsc ? "Имя А–Я" : "Имя Я–А"}</button>
            <button type="button" data-action="clear-filter">Сбросить фильтр</button>
          </div>
          <div id="project-tree" role="tree">
            ${treeButton(entity("root"))}
            ${group("device", "Устройства")}
            ${group("scenario", "Сценарии")}
          </div>
        </section>
        <section class="cfg-pane" aria-label="Рабочая область">
          <h3>Рабочая область</h3>
          <p class="hint">${escapeHtml(revisionText())}. Перетащите устройство на другое устройство, чтобы создать одну связь.</p>
          <div class="group-label">Устройства</div>
          ${devices.map((item) => nodeButton(item)).join("") || `<p class="hint">Устройств нет.</p>`}
          <div class="group-label">Сценарии</div>
          ${scenarios.map((item) => nodeButton(item)).join("") || `<p class="hint">Сценариев нет.</p>`}
          <div class="group-label">Связи</div>
          <ul>${links || "<li>Связей нет.</li>"}</ul>
          <p id="drop-hint" class="log-line">${escapeHtml(ui.mutation)}</p>
        </section>
        <section class="cfg-pane" aria-label="Инспектор">
          <h3>Инспектор</h3>
          <p class="hint">${escapeHtml(revisionText())}</p>
          ${inspector(selected)}
        </section>
      </div>`;
  }

  function nodeButton(item) {
    const selected = item.id === project.selectionId;
    const drag = item.type === "device" ? ` draggable="true" data-drag="${item.id}"` : "";
    return `<button class="node" type="button" data-select="${item.id}" data-drop="${item.id}"${drag} aria-pressed="${selected ? "true" : "false"}"><span>${escapeHtml(item.name)}</span>${badge(item)}</button>`;
  }

  function inspector(selected) {
    if (!selected) return `<p class="hint">Объект не выбран.</p>`;
    if (selectionHidden()) {
      return `<p class="hint">Объект «${escapeHtml(selected.name)}» скрыт фильтром. Selection остался на нём.</p><button type="button" data-action="clear-filter">Показать объект</button>`;
    }
    const locked = project.protection;
    const origin = {
      wizard: "Создано мастером. Само по себе это не запрещает правку.",
      manual: "Добавлено явным ручным действием.",
      template: "Получено из шаблона и редактируется теми же средствами.",
      system: "Системный корень. Предметные сущности сами не появились.",
    }[selected.origin] || "";
    const hardware = selected.type === "device"
      ? (project.emulator
        ? `<p><span class="badge" data-kind="simulated">simulated</span> Нет подтверждённого реального устройства.</p>`
        : `<p class="hint">Оборудование недоступно. Это не ошибка схемы.</p>`)
      : "";
    return `
      <div class="stack">
        <p class="hint">${escapeHtml(origin)}</p>
        ${locked ? `<p><span class="badge" data-kind="blocked">ограничено</span> Сервер запретил правку внутри AV Control. Это не шифрование и не защита файла вне продукта.</p>` : ""}
        <label class="field"><span>Имя</span><input id="field-name" data-field="name" value="${escapeHtml(selected.name)}" ${locked ? "disabled" : ""}></label>
        ${selected.type === "device" ? `<label class="field"><span>Адрес</span><input id="field-address" data-field="address" value="${escapeHtml(selected.address)}" ${locked ? "disabled" : ""}></label><p class="hint">Драйвер: ${escapeHtml(selected.driver || "не задан")}</p>` : ""}
        ${hardware}
        <p class="modal-error ${ui.fieldError ? "" : "hidden"}">${escapeHtml(ui.fieldError)}</p>
        <div class="cfg-tools">
          ${selected.type === "device" ? `<button type="button" id="link-entity" data-action="open-link" ${locked ? "disabled" : ""}>Связать</button>` : ""}
          ${selected.type !== "root" ? `<button type="button" id="delete-entity" data-action="open-delete" ${locked ? "disabled" : ""}>Удалить</button>` : ""}
        </div>
      </div>`;
  }

  function preflightPage() {
    const valid = project.preflight && !project.dirty && !project.preflight.stale && project.preflight.revision === project.savedRevision;
    const block = valid ? project.preflight.blockers.map(issue).join("") || `<p class="hint">Блокеров нет.</p>` : "";
    const warn = valid ? project.preflight.warnings.map(issue).join("") || `<p class="hint">Предупреждений нет.</p>` : "";
    return `
      <article class="panel">
        <h3>Preflight${valid ? ` ${escapeHtml(project.preflight.revision)}` : ""}</h3>
        <p class="hint">Проверка относится только к сохранённой ревизии. Блокер запрещает deploy, предупреждение остаётся видимым.</p>
        <button type="button" id="run-preflight" data-action="run-preflight">Запустить preflight</button>
        ${valid ? `<div class="group-label">Блокеры</div>${block}<div class="group-label">Предупреждения</div>${warn}` : `<p>${escapeHtml(ui.mutation)}</p><p class="hint">Актуального результата для сохранённой ревизии нет.</p>`}
      </article>`;
  }

  function issue(item) {
    return `
      <article class="issue" data-level="${item.id.startsWith("address") || item.id === "no-devices" ? "blocker" : "warning"}">
        <h4>${escapeHtml(item.title)}</h4>
        <p>${escapeHtml(item.text)}</p>
        <button type="button" data-action="jump" data-entity="${item.entityId}" data-field="${item.field || ""}">Перейти к объекту</button>
      </article>`;
  }

  function previewPage() {
    const stale = project.session !== ui.previewSession;
    const source = project.dirty ? "несохранённая сессия" : project.savedRevision || "несохранённая сессия";
    const light = ui.previewOn.light ? "включен" : "выключен";
    const screen = ui.previewOn.screen ? "включен" : "выключен";
    return `
      <article class="panel">
        <div class="preview-banner">
          <strong>PREVIEW · только просмотр</strong>
          <span>Проект «${escapeHtml(project.name)}». Ревизия источника: ${escapeHtml(source)}. ${stale ? "Preview устарел после изменения проекта." : "Preview построен из текущей сессии."} Команды реальному оборудованию не отправляются и deploy этим экраном не подтверждается.</span>
        </div>
        <label class="field"><span>Профиль клиента</span>
          <select aria-label="Профиль клиента"><option>Панель 10 дюймов</option></select>
        </label>
        <div class="room-preview">
          <button type="button" data-action="preview-toggle" data-lamp="light" aria-pressed="${ui.previewOn.light ? "true" : "false"}">Свет: ${light}</button>
          <button type="button" data-action="preview-toggle" data-lamp="screen" aria-pressed="${ui.previewOn.screen ? "true" : "false"}">Экран: ${screen}</button>
        </div>
        <p class="log-line" id="command-log">Журнал команд оборудованию: пусто</p>
        ${project.emulator ? `<p><span class="badge" data-kind="simulated">simulated</span> Показания эмулятора не являются реальными.</p>` : ""}
      </article>`;
  }

  function deployPage() {
    const reason = deployBlockReason();
    const warnings = project.preflight && !project.preflight.stale ? project.preflight.warnings : [];
    return `
      <article class="panel stack">
        <h3>Deploy</h3>
        <p class="hint">Активная версия меняется только после целого подтверждённого применения. Сейчас активна: ${escapeHtml(project.activeVersion || "нет активной версии")}.</p>
        <p>Сохранённая ревизия: ${escapeHtml(project.savedRevision || "нет")}. Preflight: ${project.preflight ? escapeHtml(project.preflight.revision + (project.preflight.stale ? ", устарел" : "")) : "не запускался"}.</p>
        ${warnings.map((item) => `<p class="hint">${escapeHtml(item.title)}: ${escapeHtml(item.text)}</p>`).join("")}
        <label><input id="accept-warnings" type="checkbox" ${ui.acceptWarnings ? "checked" : ""}> Продолжить, оставив предупреждения видимыми</label>
        <label><input id="deploy-fault" type="checkbox" ${ui.deployFault ? "checked" : ""}> Внести отказ на этапе применения</label>
        <p class="${reason ? "modal-error" : "hint"}">${escapeHtml(reason || "Условия deploy выполнены.")}</p>
        <div class="cfg-tools">
          <button class="primary" type="button" id="run-deploy" data-action="run-deploy" ${reason ? "disabled" : ""}>Активировать ревизию</button>
          <button type="button" id="lose-link" data-action="deploy-unknown" ${reason ? "disabled" : ""}>Потерять связь</button>
          <button type="button" id="reconcile-deploy" data-action="reconcile-deploy">Сверить версию с сервером</button>
        </div>
        <p class="log-line">${escapeHtml(ui.deployLog || "Итог ещё не получен.")}</p>
      </article>`;
  }

  function exchangePage() {
    const entities = project.entities.filter((item) => item.type !== "root").map((item) => item.name).join(", ") || "предметных сущностей нет";
    return `
      <article class="panel stack">
        <h3>Обмен, шаблон и защита</h3>
        <p class="hint">Серверная и клиентская части выбираются раздельно. Секреты в экспорт не входят. Защита ограничивает обычные действия внутри AV Control и не обещает криптографическую гарантию.</p>
        <p>Политика: ${project.protection ? "правка и копирование внутри продукта ограничены сервером" : "ограничение не включено"}.</p>
        <div class="cfg-tools">
          <button type="button" data-action="export-part" data-part="server">Экспорт серверной части</button>
          <button type="button" data-action="export-part" data-part="client">Экспорт клиентской части</button>
          <button type="button" id="toggle-protection" data-action="toggle-protection">${project.protection ? "Снять ограничение" : "Ограничить копирование"}</button>
          <button type="button" id="open-template" data-action="open-template">Сохранить как шаблон</button>
        </div>
        <label><input id="import-fail" type="checkbox" ${ui.importFail ? "checked" : ""}> Сбой на применении import</label>
        <div class="cfg-tools">
          <button type="button" id="run-import" data-action="run-import">Импортировать серверную часть</button>
        </div>
        <p class="hint">Предпросмотр файла: server-part, сущности «Коммутатор». Конфликтов имени нет. Применение атомарное.</p>
        <p class="log-line">${escapeHtml(ui.exportText || ui.mutation)}</p>
        <p class="hint">Текущий состав: ${escapeHtml(entities)}.</p>
      </article>`;
  }

  function page() {
    if (ui.mode === "preflight") return preflightPage();
    if (ui.mode === "preview") return previewPage();
    if (ui.mode === "deploy") return deployPage();
    if (ui.mode === "exchange") return exchangePage();
    return workspacePage();
  }

  function shell(body) {
    const pressed = (mode) => ui.mode === mode ? "true" : "false";
    return `
      ${note()}
      <div class="cfg-bar">
        <button type="button" data-mode="workspace" aria-pressed="${pressed("workspace")}">Рабочая область</button>
        <button type="button" data-mode="preflight" aria-pressed="${pressed("preflight")}">Preflight</button>
        <button type="button" data-mode="preview" aria-pressed="${pressed("preview")}">Preview</button>
        <button type="button" data-mode="deploy" aria-pressed="${pressed("deploy")}">Deploy</button>
        <button type="button" data-mode="exchange" aria-pressed="${pressed("exchange")}">Обмен</button>
        <button type="button" id="save-project" data-action="save-project">Сохранить</button>
        <button type="button" id="discard-project" data-action="open-discard">Отменить изменения</button>
        <button type="button" id="add-device" data-action="open-device">Добавить устройство</button>
        <button type="button" id="add-manual" data-action="open-manual">Добавить вручную</button>
        <button type="button" id="toggle-emulator" data-action="toggle-emulator">${project.emulator ? "Остановить эмулятор" : "Запустить эмулятор"}</button>
      </div>
      <div class="cfg-meta">
        <span>Проект: ${escapeHtml(project.name)}</span>
        <span>${escapeHtml(revisionText())}</span>
        <span>Активная версия: ${escapeHtml(project.activeVersion || "нет")}</span>
        <span>${escapeHtml(hardwareText())}</span>
      </div>
      ${body}
      ${dialogHtml()}
    `;
  }

  function dialogHtml() {
    if (!ui.dialog) return "";
    const error = ui.dialog.error ? `<p class="modal-error">${escapeHtml(ui.dialog.error)}</p>` : "";
    let body = "";
    if (ui.dialog.type === "device") {
      body = `
        <h2>Мастер устройств</h2>
        <label><input type="radio" name="device-choice" value="camera" ${ui.deviceChoice === "camera" ? "checked" : ""}> Камера PTZ и связанный пресет</label>
        <label><input type="radio" name="device-choice" value="empty" ${ui.deviceChoice === "empty" ? "checked" : ""}> Каталог пуст</label>
        <p class="hint">Подтверждение добавит один change-set в текущий проект. Облачный каталог не запрашивается.</p>
        ${error}
        <div class="modal-actions">
          <button class="primary" type="button" data-action="confirm-device">Подтвердить</button>
          <button type="button" data-action="close-dialog">Отмена</button>
        </div>`;
    } else if (ui.dialog.type === "manual") {
      body = `
        <h2>Явное добавление</h2>
        <label class="field"><span>Имя</span><input id="manual-name" value="${escapeHtml(ui.dialog.draft || "")}"></label>
        <label class="field"><span>Тип</span><select id="manual-type"><option value="device">Устройство</option><option value="scenario">Сценарий</option></select></label>
        <p class="hint">Автозаполнения нет.</p>
        ${error}
        <div class="modal-actions">
          <button class="primary" type="button" data-action="confirm-manual">Добавить</button>
          <button type="button" data-action="close-dialog">Отмена</button>
        </div>`;
    } else if (ui.dialog.type === "link") {
      const options = sorted("device").filter((item) => item.id !== project.selectionId);
      body = `
        <h2>Связать устройство</h2>
        <label class="field"><span>Цель</span><select id="link-target">${options.map((item) => `<option value="${item.id}">${escapeHtml(item.name)}</option>`).join("")}</select></label>
        ${options.length === 0 ? `<p class="hint">Другого устройства нет.</p>` : ""}
        ${error}
        <div class="modal-actions">
          <button class="primary" type="button" data-action="confirm-link" ${options.length === 0 ? "disabled" : ""}>Связать</button>
          <button type="button" data-action="close-dialog">Отмена</button>
        </div>`;
    } else if (ui.dialog.type === "delete") {
      const current = entity(ui.dialog.entityId);
      const related = project.links.filter((link) => link.from === ui.dialog.entityId || link.to === ui.dialog.entityId);
      body = `
        <h2>Удалить «${escapeHtml(current ? current.name : "")}»</h2>
        <p>Вместе с объектом будут сняты связи: ${related.length}. Selection перейдёт к корню.</p>
        <div class="modal-actions">
          <button class="primary" type="button" data-action="confirm-delete">Удалить</button>
          <button type="button" data-action="close-dialog">Отмена</button>
        </div>`;
    } else if (ui.dialog.type === "discard") {
      body = `
        <h2>Отменить несохранённые изменения</h2>
        <p>${project.snapshot ? `Будет возвращена ${escapeHtml(project.savedRevision)}.` : "Черновик ещё не сохранялся и будет закрыт."}</p>
        <div class="modal-actions">
          <button class="primary" type="button" data-action="confirm-discard">Отменить изменения</button>
          <button type="button" data-action="close-dialog">Остаться</button>
        </div>`;
    } else if (ui.dialog.type === "template") {
      const names = project.entities.filter((item) => item.type !== "root").map((item) => item.name);
      body = `
        <h2>Шаблон комнаты</h2>
        <p>В шаблон войдёт: ${escapeHtml(names.join(", ") || "только пустой корень")}. Секреты исключены.</p>
        <p class="hint">Применение добавит одну новую сущность «Блок освещения» и не перезапишет остальные.</p>
        ${error}
        <div class="modal-actions">
          <button class="primary" type="button" data-action="confirm-template">Применить шаблон</button>
          <button type="button" data-action="close-dialog">Отмена</button>
        </div>`;
    }
    return `<div class="cfg-dialog" role="dialog" aria-modal="true">${`<div class="modal">${body}</div>`}</div>`;
  }

  function render(focusId) {
    const root = document.querySelector("#configurator-root");
    if (!root) return;
    let selector = typeof focusId === "string" ? focusId : "";
    if (ui.focusField) {
      selector = ui.focusField;
      ui.focusField = null;
    }
    root.innerHTML = !project ? (ui.mode === "wizard" ? wizardPage() : startPage()) : shell(page());
    if (selector) {
      const node = root.querySelector(selector);
      if (node) {
        node.focus();
        if (typeof ui.caret === "number" && node.setSelectionRange) {
          node.setSelectionRange(ui.caret, ui.caret);
          ui.caret = null;
        }
      }
    } else if (ui.dialog) {
      const first = root.querySelector(".cfg-dialog button, .cfg-dialog input, .cfg-dialog select");
      if (first) first.focus();
    }
  }

  function openDialog(type, extra) {
    const active = document.activeElement;
    ui.returnFocus = active && active.id ? active.id : null;
    ui.dialog = { type, error: "", ...extra };
    render();
  }

  function closeDialog() {
    const returnId = ui.returnFocus;
    ui.dialog = null;
    render(returnId ? `#${CSS.escape(returnId)}` : "");
  }

  function ensureEditable() {
    if (!project.protection) return true;
    ui.mutation = "Сервер запретил изменение. Ограничение действует внутри AV Control и не является шифрованием.";
    return false;
  }

  function onClick(event) {
    if (event.target.classList.contains("cfg-dialog")) {
      closeDialog();
      return;
    }
    const actionEl = event.target.closest("[data-action], [data-select], [data-mode]");
    if (!actionEl) return;
    if (actionEl.dataset.mode) {
      ui.mode = actionEl.dataset.mode;
      if (ui.mode === "preview") ui.previewSession = project.session;
      if (ui.mode === "preflight" && project.preflight && (project.dirty || project.preflight.stale)) {
        ui.mutation = "Preflight устарел или проект не сохранён. Запустите проверку заново.";
      }
      render();
      return;
    }
    if (actionEl.dataset.select && !actionEl.dataset.action) {
      project.selectionId = actionEl.dataset.select;
      ui.fieldError = "";
      ui.mutation = "Selection обновлён в дереве, рабочей области и инспекторе. Проект не изменён.";
      render();
      return;
    }
    const action = actionEl.dataset.action;
    if (action === "open-wizard") {
      ui.mode = "wizard";
      ui.wizardError = "";
      render();
    } else if (action === "cancel-wizard") {
      ui.mode = "start";
      ui.wizardError = "";
      render();
    } else if (action === "confirm-room") {
      if (ui.wizardChoice === "missing-driver") {
        ui.wizardError = "Нет совместимого драйвера codec. Ни одна сущность не записана. Облачный поиск не выполняется.";
        render();
        return;
      }
      applyStandardRoom();
      render();
    } else if (action === "create-manual") {
      createBase("Новый проект", "manual");
      ui.mutation = "Открыта пустая структура. Скрытых устройств и сценариев нет.";
      render();
    } else if (action === "save-project") {
      save();
      render();
    } else if (action === "run-preflight") {
      runPreflight();
      render();
    } else if (action === "open-discard") {
      openDialog("discard");
    } else if (action === "confirm-discard") {
      discard();
      render();
    } else if (action === "open-device") {
      if (!ensureEditable()) {
        render();
        return;
      }
      openDialog("device");
    } else if (action === "confirm-device") {
      if (ui.deviceChoice === "empty") {
        ui.dialog.error = "Локальный каталог пуст. Можно добавить сущность вручную. Облачный поиск не выполняется.";
        render();
        return;
      }
      if (nameTaken("Камера PTZ") || nameTaken("Пресет обзора")) {
        ui.dialog.error = "Имя уже занято. Change-set не записан, проект не изменён.";
        render();
        return;
      }
      addEntity({ type: "device", name: "Камера PTZ", origin: "wizard", driver: "camera.local" });
      addEntity({ type: "scenario", name: "Пресет обзора", origin: "wizard" });
      touch("Добавлены камера и пресет одним change-set. Остальной проект не перезаписан. Мутаций: 1.");
      ui.dialog = null;
      render();
    } else if (action === "open-manual") {
      if (!ensureEditable()) {
        render();
        return;
      }
      openDialog("manual");
    } else if (action === "confirm-manual") {
      const name = document.querySelector("#manual-name").value.trim();
      const type = document.querySelector("#manual-type").value;
      if (!name || nameTaken(name)) {
        ui.dialog.draft = name;
        ui.dialog.error = !name ? "Укажите имя. Запись не выполнена." : "Имя уже есть. Запись не выполнена.";
        render();
        return;
      }
      addEntity({ type, name, origin: "manual", driver: type === "device" ? "generic.local" : "" });
      touch(`Добавлено «${name}» явным действием. Мутаций: 1.`);
      ui.dialog = null;
      render();
    } else if (action === "open-link") {
      openDialog("link");
    } else if (action === "confirm-link") {
      const target = document.querySelector("#link-target");
      if (!target || !ensureEditable()) {
        closeDialog();
        return;
      }
      addLink(project.selectionId, target.value);
      ui.dialog = null;
      render();
    } else if (action === "open-delete") {
      openDialog("delete", { entityId: project.selectionId });
    } else if (action === "confirm-delete") {
      const current = entity(ui.dialog.entityId);
      if (!current || current.type === "root" || !ensureEditable()) {
        closeDialog();
        return;
      }
      const name = current.name;
      project.entities = project.entities.filter((item) => item.id !== current.id);
      project.links = project.links.filter((link) => link.from !== current.id && link.to !== current.id);
      project.selectionId = "root";
      touch(`Удалён «${name}». Selection переведён на корень. Мутаций: 1.`);
      ui.dialog = null;
      ui.focusField = "#tree-item-root";
      render();
    } else if (action === "collapse") {
      const groupName = actionEl.dataset.group;
      ui.collapsed[groupName] = !ui.collapsed[groupName];
      ui.mutation = "Группа свёрнута или развёрнута. Selection остался на прежнем объекте.";
      render();
    } else if (action === "sort") {
      ui.sortAsc = !ui.sortAsc;
      ui.mutation = "Порядок списка изменён. Selection остался на прежнем объекте.";
      render();
    } else if (action === "clear-filter") {
      ui.filter = "";
      ui.mutation = "Фильтр снят. Selection не переносился на соседнюю строку.";
      render();
    } else if (action === "jump") {
      const target = entity(actionEl.dataset.entity);
      if (!target) return;
      project.selectionId = target.id;
      ui.mode = "workspace";
      if (target.type !== "root" && !matchesFilter(target)) {
        ui.filter = "";
        ui.mutation = `Фильтр снят, чтобы показать «${target.name}».`;
      } else {
        ui.mutation = `Открыт объект проблемы «${target.name}».`;
      }
      ui.focusField = actionEl.dataset.field === "address" ? "#field-address" : `#tree-item-${target.id}`;
      render();
    } else if (action === "preview-toggle") {
      const lamp = actionEl.dataset.lamp;
      ui.previewOn[lamp] = !ui.previewOn[lamp];
      ui.mutation = "Изменён только локальный вид preview. Команд оборудованию: 0.";
      render();
    } else if (action === "run-deploy") {
      runDeploy("normal");
      render();
    } else if (action === "deploy-unknown") {
      runDeploy("unknown");
      render();
    } else if (action === "reconcile-deploy") {
      ui.deployLog = `Сервер подтвердил активную версию: ${project.activeVersion || "нет активной версии"}. Частичной активации нет.`;
      render();
    } else if (action === "toggle-emulator") {
      project.emulator = !project.emulator;
      ui.mutation = project.emulator
        ? "Эмулятор запущен отдельной командой. Значения помечены simulated и не записаны как реальные."
        : "Эмулятор остановлен. Проект на месте, simulated-значения не стали реальными.";
      render();
    } else if (action === "toggle-protection") {
      if (project.dirty || !project.savedRevision) {
        ui.mutation = "Политика не изменена: сначала сохраните проект.";
        render();
        return;
      }
      project.protection = !project.protection;
      if (project.snapshot) project.snapshot.protection = project.protection;
      ui.mutation = project.protection
        ? "Сервер ограничил правку и копирование внутри AV Control. Это не криптографическая гарантия."
        : "Сервер снял ограничение для этой сессии.";
      render();
    } else if (action === "export-part") {
      const part = actionEl.dataset.part === "client" ? "клиентская" : "серверная";
      if (actionEl.dataset.part === "client" && project.protection) {
        ui.exportText = "Сервер отклонил экспорт клиентской части. Ограничение действует внутри продукта даже при повторном запросе. Файл вне продукта этим не защищён.";
        render();
        return;
      }
      const names = project.entities.filter((item) => item.type !== "root").map((item) => item.name).join(", ") || "пусто";
      ui.exportText = `Экспорт, часть: ${part}. Ревизия: ${project.savedRevision || "не сохранено"}. Состав: ${names}. Секреты не включены.`;
      render();
    } else if (action === "run-import") {
      if (project.dirty) {
        ui.exportText = "Import не начат: сначала сохраните или отбросьте изменения. Ревизия не изменилась.";
        render();
        return;
      }
      if (ui.importFail) {
        ui.exportText = "Import прерван. Текущая ревизия не изменилась, файл не импортирован.";
        render();
        return;
      }
      if (nameTaken("Коммутатор")) {
        ui.exportText = "Конфликт имени «Коммутатор». Import не применён.";
        render();
        return;
      }
      addEntity({ type: "device", name: "Коммутатор", origin: "manual", driver: "switch.local", address: "192.168.1.40" });
      touch("Import применил одну сущность атомарно. Мутаций: 1.");
      ui.exportText = ui.mutation;
      render();
    } else if (action === "open-template") {
      openDialog("template");
    } else if (action === "confirm-template") {
      if (project.dirty) {
        ui.dialog.error = "Шаблон не применён: сначала сохраните или отбросьте изменения.";
        render();
        return;
      }
      if (nameTaken("Блок освещения")) {
        ui.dialog.error = "Конфликт имени. Проект не изменён.";
        render();
        return;
      }
      addEntity({ type: "device", name: "Блок освещения", origin: "template", driver: "light.local", address: "192.168.1.41" });
      touch("Шаблон применил один change-set. Сущность редактируется обычными средствами. Мутаций: 1.");
      ui.dialog = null;
      render();
    } else if (action === "close-dialog") {
      closeDialog();
    }
  }

  function onInput(event) {
    if (event.target.id === "tree-filter") {
      ui.filter = event.target.value;
      ui.caret = event.target.selectionStart;
      ui.mutation = "Фильтр изменён. Selection не перешёл на другую строку.";
      render("#tree-filter");
      return;
    }
    if (!project || !event.target.dataset.field || event.target.dataset.field === "filter") return;
    const selected = entity(project.selectionId);
    if (!selected || project.protection) return;
    const field = event.target.dataset.field;
    const value = event.target.value;
    ui.caret = event.target.selectionStart;
    if (field === "name") {
      if (!value.trim() || nameTaken(value, selected.id)) {
        ui.fieldError = !value.trim() ? "Имя не может быть пустым. Прежнее значение сохранено." : "Имя уже занято. Прежнее значение сохранено.";
        render("#field-name");
        return;
      }
      selected.name = value;
      if (selected.id === "root") project.name = value;
    } else if (field === "address") {
      selected.address = value;
    } else {
      return;
    }
    touch(`Изменено поле «${field}». Мутаций: 1.`);
    render(field === "name" ? "#field-name" : "#field-address");
  }

  function onChange(event) {
    if (event.target.name === "wizard-choice") {
      ui.wizardChoice = event.target.value;
      ui.wizardError = "";
      render();
    }
    if (event.target.name === "device-choice") ui.deviceChoice = event.target.value;
    if (event.target.id === "accept-warnings") ui.acceptWarnings = event.target.checked;
    if (event.target.id === "deploy-fault") ui.deployFault = event.target.checked;
    if (event.target.id === "import-fail") ui.importFail = event.target.checked;
    if (event.target.id === "accept-warnings" || event.target.id === "deploy-fault" || event.target.id === "import-fail") {
      render(`#${event.target.id}`);
    }
  }

  function onDragStart(event) {
    const node = event.target.closest("[data-drag]");
    if (!node) return;
    ui.dragId = node.dataset.drag;
    event.dataTransfer.effectAllowed = "link";
    event.dataTransfer.setData("text/plain", ui.dragId);
  }

  function onDragOver(event) {
    const zone = event.target.closest("[data-drop]");
    if (!zone || !ui.dragId) return;
    event.preventDefault();
    const hint = document.querySelector("#drop-hint");
    if (hint) hint.textContent = describeDrop(ui.dragId, zone.dataset.drop);
  }

  function onDrop(event) {
    const zone = event.target.closest("[data-drop]");
    if (!zone || !ui.dragId) return;
    event.preventDefault();
    applyDrop(ui.dragId, zone.dataset.drop);
    ui.dragId = null;
    render();
  }

  function onKeyDown(event) {
    if (event.key === "Escape" && ui.dialog) {
      event.stopPropagation();
      closeDialog();
      return;
    }
    if (!project || (event.key !== "ArrowDown" && event.key !== "ArrowUp")) return;
    const item = event.target.closest("#project-tree [data-select]");
    if (!item) return;
    const items = [...document.querySelectorAll("#project-tree [data-select]")];
    const index = items.indexOf(item);
    const next = items[index + (event.key === "ArrowDown" ? 1 : -1)];
    if (!next) return;
    event.preventDefault();
    project.selectionId = next.dataset.select;
    ui.mutation = "Selection обновлён с клавиатуры. Проект не изменён.";
    render(`#${CSS.escape(next.id)}`);
  }

  function mount(root) {
    root.addEventListener("click", onClick);
    root.addEventListener("input", onInput);
    root.addEventListener("change", onChange);
    root.addEventListener("dragstart", onDragStart);
    root.addEventListener("dragover", onDragOver);
    root.addEventListener("drop", onDrop);
    root.addEventListener("dragend", () => {
      ui.dragId = null;
    });
    root.addEventListener("keydown", onKeyDown);
    render();
  }

  return { isDirty, dirtyMessage, save, discard, mount };
})();
