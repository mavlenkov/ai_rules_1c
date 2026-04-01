# Commands Specification — Delta

## MODIFIED Requirements

### Requirement: Поддержка серверных информационных баз
Команды должны работать с серверными ИБ через `/S` с аутентификацией. URL тестирования ДОЛЖЕН браться из `infobasesettings.md`, а не быть захардкожен.

#### Scenario: URL тестирования из настроек
- **WHEN** в `deploy_and_test.md` секция testing ссылается на URL
- **THEN** URL берётся из `infobasesettings.md` секции «URL тестирования»
- **AND** нет жёстко прописанных значений вроде `http://localhost/MyBase/ru/`

#### Scenario: URL тестирования не задан
- **WHEN** в `infobasesettings.md` нет URL тестирования
- **THEN** секция testing пропускается с уведомлением пользователя
