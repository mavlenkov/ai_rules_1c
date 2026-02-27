# Задачи по интеграции 1CFilesConverter

## Документация

- [x] Создать `proposal.md` — формальное сравнение возможностей
- [x] Создать `design.md` — архитектурные решения
- [ ] Создать `test-plan.md` — план тестирования интеграции

## Конфигурация

- [ ] Обновить шаблон `infobasesettings.md` в `scripts/init-project.sh`
  - Добавить секцию "1CFilesConverter (опционально)"
  - Поля: путь, версия платформы, инструмент конвертации

## Команды: обновление существующих

- [ ] `.cursor/commands/deploy_and_test.md`:
  - Добавить секцию "1CFilesConverter mode" (перед текущими командами)
  - Инструкции для `conf2ib.sh` с `V8_UPDATE_DB=1`
  - Обработка Windows (без `V8_UPDATE_DB`)
  - Fallback на Designer (текущие команды без изменений)

- [ ] `.cursor/commands/getconfigfiles.md`:
  - Добавить секцию "1CFilesConverter mode"
  - Инструкции для `conf2xml.sh`
  - Пометка: выборочная выгрузка (`-listFile`) только в fallback
  - Fallback на Designer

- [ ] `.cursor/rules/getconfigfiles.mdc`:
  - Синхронизировать с обновленным `getconfigfiles.md`

## Команды: создание новых

- [ ] `.cursor/commands/extensions.md`:
  - Загрузка расширения в ИБ (`ext2ib`)
  - Выгрузка расширения в XML (`ext2xml`)
  - Сборка CFE (`ext2cfe`)
  - Fallback: Designer с `-Extension` (только для выгрузки)

- [ ] `.cursor/commands/dataprocessors.md`:
  - Сборка EPF/ERF (`dp2epf`)
  - Выгрузка в XML (`dp2xml`)
  - Конвертация в EDT (`dp2edt`)
  - Требование: наличие `V8_BASE_IB` или `V8_BASE_CONFIG`
  - Без fallback (только через 1CFilesConverter)

## OpenSpec спецификации

- [ ] `openspec/specs/commands/spec.md`:
  - Добавить requirement "Делегирование 1CFilesConverter"
  - Добавить requirement "Операции с расширениями"
  - Добавить requirement "Операции с обработками"
  - Обновить таблицу команд (добавить extensions, dataprocessors)

## Тестирование

- [ ] Создать `test-plan.md`:
  - Тесты для 1CFilesConverter mode (все операции)
  - Тесты для fallback mode
  - Тесты трансляции форматов (серверные ИБ, пустой пароль)
  - Тесты обработки ошибок (невалидный путь к конвертеру)
  - Кросс-проверка: Windows vs Linux

## Финализация

- [ ] Коммит и пуш всех изменений
- [ ] Обновить `README.md` (упоминание 1CFilesConverter в разделе "Команды")
