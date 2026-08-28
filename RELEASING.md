# Релиз и обновления

Этот форк = чистый upstream-код [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk)
плюс один файл сборки (`.github/workflows/build.yml`). Правок кода приложения нет —
поэтому новые версии разработчика подтягиваются merge'ем без конфликтов.

Сборки **ad-hoc** (без Apple Developer ID). Это бесплатно, но накладывает ограничения
на разрешения macOS — см. раздел «Ad-hoc налог».

---

## Для друзей (установка + обновления)

**Требования**: Apple Silicon (arm64), **macOS 14.4+**.

> Не путать: в `project.pbxproj` на уровне проекта стоит `MACOSX_DEPLOYMENT_TARGET = 15.0`,
> но app-таргет перекрывает его на `14.4`. Реальный минимум = `LSMinimumSystemVersion`
> собранного `.app`, откуда его и берёт `build.yml` для appcast.

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

## Подпись и разрешения macOS

Сборки подписываются **стабильным самоподписанным сертификатом** (`VoiceInk Fork Signing
(Vnedrenec)`, SHA-1 `D0DA8655…A1A4`, годен до 2046). Это делает designated requirement
приложения постоянным:

```
identifier "com.prakashjoshipax.VoiceInk" and certificate root = H"<sha1 сертификата>"
```

macOS TCC привязывает гранты Accessibility / Input Monitoring / Screen Recording именно
к этому требованию. Раньше сборки были ad-hoc: каждый билд давал новый cdhash → система
считала приложение «другим» и грант молча слетал после каждого обновления (симптом:
F13 не реагирует, вставка мажет, хотя тумблеры в Settings выглядят включёнными). Теперь
требование не меняется от сборки к сборке, и гранты переживают обновления.

Сертификат не имеет доверия в системе (`CSSMERR_TP_NOT_TRUSTED`) — это нормально:
`codesign` подписывает им без проблем, TCC доверия цепочки не требует, а Gatekeeper и
раньше обходился через `xattr -cr` в `scripts/install.sh`. Нотаризация по-прежнему
невозможна (нужен Apple Developer ID, $99/год).

### Секреты и бэкап ключа

- `MACOS_SIGN_CERT_P12` — .p12 в base64, `MACOS_SIGN_CERT_PASSWORD` — пароль к нему.
- Локальные копии: `~/VoiceInk-signing/` (`voiceink-signing.p12`, `p12-password.txt`).

**Потеря этого .p12 = новый сертификат = всем пользователям придётся один раз заново
выдать разрешения.** Держать бэкап в менеджере паролей.

### Формула сброса разрешений (нужна один раз при переходе на подписанные сборки)

Обновление с ad-hoc-версии на подписанную меняет подпись последний раз, поэтому гранты
слетят ещё один раз. Дальше — нет.

1. Сбросить грант:
   ```bash
   tccutil reset ListenEvent com.prakashjoshipax.VoiceInk
   tccutil reset Accessibility com.prakashjoshipax.VoiceInk
   ```
2. Включить приложение в System Settings → Privacy → Input Monitoring (и Accessibility).
   Если висит старая запись — удалить `−`, добавить заново.
3. **Quit + перезапуск приложения** — tap встаёт только на старте. Этот шаг забывают
   чаще всего; без него шорткат остаётся мёртвым.

Формула: **сбросил → включил → перезапустил.**
