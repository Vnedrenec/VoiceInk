# Релиз и обновления

Этот форк = чистый upstream-код [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk)
плюс один файл сборки (`.github/workflows/build.yml`). Правок кода приложения нет —
поэтому новые версии разработчика подтягиваются merge'ем без конфликтов.

Сборки **ad-hoc** (без Apple Developer ID). Это бесплатно, но накладывает ограничения
на разрешения macOS — см. раздел «Ad-hoc налог».

---

## Для друзей (установка + обновления)

**Установка** — одна команда в Terminal:

```bash
curl -sL https://github.com/Vnedrenec/VoiceInk/releases/latest/download/install.sh | bash
```

Скрипт качает последний релиз, снимает карантин Gatekeeper, ставит в `/Applications`,
запускает.

**Первый запуск** — выдать разрешения в System Settings → Privacy & Security:

- **Microphone** — запись голоса
- **Input Monitoring** — глобальный шорткат (F13 и т.п.)
- **Accessibility** — вставка текста в курсор

После включения **Input Monitoring обязательно перезапустить приложение** — иначе
шорткод не работает (event tap ставится только при старте).

**Обновления** — автоматически через Sparkle. В приложении появится «Update available»
(или меню → «Check for Updates…»). Без предупреждений Gatekeeper.

> ⚠️ После каждого обновления разрешения слетают (см. ниже) — нужно пере-выдать
> Input Monitoring/Accessibility и перезапустить приложение.

---

## Для мейнтейнера (выпуск новой версии)

Подтянуть свежий код разработчика и выпустить релиз:

```bash
git fetch upstream
git merge upstream/main          # новая версия разработчика (без конфликтов)
git push origin main

# тег = MARKETING_VERSION из проекта после merge:
grep -m1 'MARKETING_VERSION = ' VoiceInk.xcodeproj/project.pbxproj
git tag v1.80                    # подставь актуальную версию
git push origin v1.80
```

Дальше CI (`build.yml`) делает всё сам по тегу `v*`:

1. Собирает `make local` → `LOCAL_BUILD` → licensed (без trial-баннера)
2. Подписывает обновление Sparkle EdDSA-ключом (secret `SPARKLE_PRIVATE_KEY`)
3. Создаёт GitHub Release с `VoiceInk-vX.YZ.zip` + `install.sh`
4. Обновляет `appcast.xml` на ветке `gh-pages` → друзьям прилетает авто-апдейт

**Тег должен совпадать с `MARKETING_VERSION`** в `project.pbxproj`, иначе версии в
релизе и в проекте разойдутся.

### Первичная настройка (уже сделана, для справки)

- `main` = `upstream/main` + `build.yml` (force-reset, история форка вычищена)
- Remote `upstream` = `https://github.com/Beingpax/VoiceInk.git`
- Secret `SPARKLE_PRIVATE_KEY` в GitHub Actions (EdDSA-ключ Sparkle)
- `build.yml` патчит `Info.plist`: `SUFeedURL` → fork appcast, `SUPublicEDKey` → fork-ключ
- `gh-pages` хостит `appcast.xml` (канал авто-обновлений)

---

## Ad-hoc налог (почему слетают разрешения)

macOS TCC привязывает гранты Accessibility / Input Monitoring к подписи кода. Ad-hoc
подпись даёт новый cdhash при **каждой** сборке → после любого обновления система
считает приложение «другим» и грант молча инвалидируется.

Симптом: после апдейта F13 не реагирует, вставка мажет, хотя тумблеры в Settings
выглядят включёнными.

**Лечение (каждый раз после обновления):**

1. Сбросить грант:
   ```bash
   tccutil reset ListenEvent com.prakashjoshipax.VoiceInk
   tccutil reset Accessibility com.prakashjoshipax.VoiceInk
   ```
2. Включить приложение в System Settings → Privacy → Input Monitoring (и Accessibility).
   Если висит старая запись — удалить `−`, добавить заново.
3. **Quit + перезапуск приложения** — tap встаёт только на старте. Этот шаг забывают
   чаще всего; без него шорткод остаётся мёртвым.

Формула: **сбросил → включил → перезапустил.**

**Постоянное решение** (не сделано): Apple Developer ID ($99/год) → стабильная подпись
→ гранты держатся между обновлениями, без танца. Самоподписанный сертификат тоже
стабилизирует, но друзьям пришлось бы повторять настройку на каждой машине — поэтому
отвергнут.
