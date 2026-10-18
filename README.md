# BionicPRO

## Описание решения заданий

1. [Повышение безопасности системы](Task1)  
2. [Разработка сервиса отчётов](Task2)  
3. [Снижение нагрузки на базу данных](Task3)  
4. [Повышение оперативности и стабильности работы CRM](Task4)  

## Список сервисов

| Сервис | Порт | Назначение |
|---|---|---|
| `ldap` | 389 | OpenLDAP представительства |
| `frontend` | 3000 | Веб-приложение (React) |
| `keycloak_db` | 5433 | База Keycloak |
| `auth_db` | 5434 | База профилей пользователей |
| `core_db` | 5435 | Телеметрия протезов |
| `crm_db` | 5436 | CRM-система (клиенты) |
| `redis` | 6379 | Сессии и токены |
| `bionicpro-api` | 8000 | Сервис отчётов (`/reports`) |
| `nginx-cdn` | 8082 | CDN: кеширующий reverse proxy к MinIO |
| `kafka-connect` | 8083 | Kafka Connect с коннектором Debezium |
| `kafka-ui` | 8085 | Просмотр топиков Kafka |
| `keycloak` | 8080 | Удостоверяющая служба (realm `reports-realm`) |
| `bionicpro-auth` | 8081 | Вход, серверные сессии, профили |
| `airflow-webserver` | 8088 | Интерфейс Airflow (`admin` / `admin`) |
| `clickhouse` | 8123 | OLAP-витрина отчётности |
| `minio` | 9000 / 9001 | Объектное хранилище отчётов (S3 API) |
| `kafka` | 9092 | Поток изменений CRM (CDC) |
| `airflow-scheduler` | — | Расписание и запуск ETL |

## Запуск инфраструктуры

```bash
cp .env.example .env      # при необходимости укажите ключи Яндекс ID
docker compose up -d --build
```

После старта `keycloak-setup` досоздаёт в realm то, что нельзя описать в файле импорта: LDAP-федерацию, маппинг ролей и обязательный OTP.
Витрина отчётности собирается DAG-ом `bionicpro_reports_mart` по расписанию, запустить его вручную можно так:

```bash
docker compose exec airflow-scheduler airflow dags trigger bionicpro_reports_mart
```

Полная выгрузка realm:

```bash
sh keycloak/setup/export-realm.sh
```

## Учётные записи

| Пользователь | Пароль | Источник | Роль |
| --- | --- | --- | --- |
| `admin1` | `admin123` | realm | `administrator` |
| `user1`, `user2` | `password123` | realm | `user` |
| `prothetic1`…`prothetic3` | `prothetic123` | realm | `prothetic_user` |
| `jane.smith` | `password` | LDAP | `user` |
| `john.doe`, `alex.johnson` | `password` | LDAP | `prothetic_user` |

При первом входе Keycloak попросит настроить одноразовый пароль (Google Authenticator или FreeOTP), при следующих — запросит код.

## Ключи Яндекс ID

Приложение регистрируется на <https://oauth.yandex.ru>. Полученные `ClientID` и `Client secret` передаются переменными окружения `YANDEX_CLIENT_ID` и `YANDEX_CLIENT_SECRET`, после чего применяются к Identity Provider `yandex`.
