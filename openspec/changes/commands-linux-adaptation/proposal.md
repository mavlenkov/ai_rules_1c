# Адаптация команд deploy_and_test и getconfigfiles для Linux

## Проблема

Команды `deploy_and_test.md` и `getconfigfiles.md` (а также правило `getconfigfiles.mdc`) написаны для Windows:
- PowerShell синтаксис (`& 'C:\Program Files\...'`)
- Windows-пути (`C:\Users\...`, `E:\Temp\...`)
- Версия платформы 8.3.23.1997

Рабочее окружение — Linux (ALT Linux, платформа 8.3.27).

## Цель

Перевести все команды на bash-синтаксис с Linux-путями, сохранив логику и структуру.

## Ожидаемый результат

- Команды работоспособны на Linux без ручной адаптации
- Настройки ИБ читаются из `infobasesettings.md`
- Версия платформы и пути соответствуют Linux-конвенциям
