# Extension Support Specification

## Purpose
Обеспечить автоматическое определение расширений конфигурации и корректную загрузку/выгрузку через `-Extension` / `ext2ib.sh`.

## Requirements

### Requirement: Автодетекция расширения по Configuration.xml
Команды развёртывания ДОЛЖНЫ автоматически определять, является ли проект расширением конфигурации.

#### Scenario: Проект является расширением
- **WHEN** в корне проекта `Configuration.xml` содержит элемент `ConfigurationExtensionCompatibilityMode`
- **THEN** система определяет проект как расширение и извлекает имя из `<Name>` в `Configuration.xml`

#### Scenario: Проект является основной конфигурацией
- **WHEN** в `Configuration.xml` отсутствует `ConfigurationExtensionCompatibilityMode`
- **THEN** система определяет проект как основную конфигурацию и использует стандартный режим загрузки

#### Scenario: Имя расширения из infobasesettings.md
- **WHEN** в `infobasesettings.md` указано поле «Расширение» с именем
- **THEN** используется имя из `infobasesettings.md` (приоритет над `Configuration.xml`)

### Requirement: Подтверждение пользователя перед загрузкой расширения
Перед первой загрузкой расширения система ДОЛЖНА уведомить пользователя и получить подтверждение.

#### Scenario: Первая загрузка расширения
- **WHEN** автодетекция определила расширение с именем `<ExtName>`
- **THEN** система уведомляет: «Проект является расширением конфигурации. Имя расширения: <ExtName>. Для загрузки будет использован ext2ib.sh / -Extension. Подтвердите.»
- **AND** после подтверждения загрузка выполняется автоматически

#### Scenario: Пользователь отклоняет автодетекцию
- **WHEN** пользователь отклоняет предложенное определение расширения
- **THEN** система запрашивает ручной выбор режима (конфигурация / расширение + имя)

### Requirement: Загрузка расширения через 1CFilesConverter
При наличии 1CFilesConverter загрузка расширения ДОЛЖНА делегироваться `ext2ib.sh`.

#### Scenario: Загрузка расширения через ext2ib.sh
- **WHEN** проект определён как расширение и 1CFilesConverter настроен
- **THEN** выполняется `ext2ib.sh <SRC_PATH> <IB_PATH> <EXT_NAME>` вместо `conf2ib.sh`

#### Scenario: Загрузка расширения через Designer fallback
- **WHEN** проект определён как расширение и 1CFilesConverter не настроен
- **THEN** выполняется `LoadConfigFromFiles -Extension <ExtName>` и `UpdateDBCfg -Extension <ExtName>`

### Requirement: Поле Extension в шаблоне infobasesettings.md
Шаблон `infobasesettings.md` ДОЛЖЕН содержать опциональную секцию для расширений.

#### Scenario: Генерация шаблона с секцией расширения
- **WHEN** `init-project.sh` создаёт `infobasesettings.md`
- **THEN** шаблон содержит закомментированную секцию «Расширение (если применимо)»

#### Scenario: Автозаполнение имени расширения
- **WHEN** в целевом проекте `Configuration.xml` содержит `ConfigurationExtensionCompatibilityMode`
- **THEN** секция расширения раскомментирована и заполнена именем из `<Name>`
