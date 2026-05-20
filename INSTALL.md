# Установка VoiceInk (форк)

Этот форк собран из открытого кода [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk) с патчами на приватность. Подпись ad-hoc (не Apple Developer ID), поэтому macOS при первом запуске покажет предупреждение. Это нормально и безопасно — ниже три способа установки, выбери удобный.

## Быстрая установка (рекомендуется, 10 секунд)

Открой Terminal (`Spotlight → Terminal`) и вставь одну строку:

```bash
curl -sL https://github.com/Vnedrenec/VoiceInk/releases/latest/download/install.sh | bash
```

Скрипт сам скачает, распакует, снимет карантин и откроет VoiceInk. Без предупреждений.

После запуска macOS попросит **три разрешения** — выдай каждое:
1. **Микрофон** — для записи голоса
2. **Accessibility** — чтобы вставить расшифровку в курсор
3. **Input Monitoring** — чтобы ловить шорткат записи

## Ручная установка через Finder

1. Скачай [последний релиз `.zip`](https://github.com/Vnedrenec/VoiceInk/releases/latest)
2. Распакуй (двойной клик)
3. Перетащи `VoiceInk.app` в `/Applications`
4. **Удерживая `Ctrl`, кликни** на `VoiceInk.app` в `/Applications` → выбери **Open**
5. macOS покажет окно «Apple не удалось подтвердить, что файл не содержит вредоносного ПО»:
   - Жми **Open** (НЕ Move to Trash)
   - Введи пароль если попросит
6. App откроется. В будущем — обычный двойной клик.

## Почему появляется предупреждение

macOS подписан "ad-hoc" — без сертификата Apple Developer ID ($99/год). Это не вирус, не вредонос. Весь код открыт:
- Исходники форка: https://github.com/Vnedrenec/VoiceInk
- Сборка автоматически через GitHub Actions из публичного кода
- Можешь сам собрать и сверить хеш

Upstream версия с tryvoiceink.com подписана сертификатом Apple — там предупреждения нет, но есть платная лицензия и trial-сообщение в каждой расшифровке. Этот форк убирает trial и сетевые phone-home запросы.

## Обновления

После первой установки **новые версии ставятся автоматически** через меню VoiceInk → "Check for Updates...". Никаких повторных предупреждений Gatekeeper не будет.

## Проблемы

- App не открывается даже после Open Anyway: `xattr -cr /Applications/VoiceInk.app && open /Applications/VoiceInk.app`
- Шорткат не работает: System Settings → Privacy & Security → Accessibility → проверь что VoiceInk в списке и включён
- Текст не вставляется: то же самое, проверь Accessibility и Input Monitoring
- Не записывается аудио: System Settings → Privacy & Security → Microphone → включи VoiceInk

## Откатиться или удалить

```bash
# Остановить
pkill -f /Applications/VoiceInk.app

# Удалить app + данные
rm -rf /Applications/VoiceInk.app
rm -rf ~/Library/Application\ Support/com.prakashjoshipax.VoiceInk
rm -rf ~/Library/Application\ Support/VoiceInk
rm -rf ~/Library/Caches/com.prakashjoshipax.VoiceInk
rm -rf ~/Library/Caches/CloudKit/com.prakashjoshipax.VoiceInk
rm -rf ~/Library/WebKit/com.prakashjoshipax.VoiceInk
rm -rf ~/Library/HTTPStorages/com.prakashjoshipax.VoiceInk
```
