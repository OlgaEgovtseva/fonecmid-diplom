﻿#language: ru

@tree

Функционал: Массовое создание актов от имени Бухгалтера

Как тестировщик я хочу
показать процесс создания простого сценария тестирования 
чтобы разобрать процесс созданий актов    

Сценарий: Массовое создание актов от имени Бухгалтера
И я подключаю TestClient "Диплом123" логин "КовальчукНН" пароль ""
И В командном интерфейсе я выбираю 'Обслуживание клиентов' 'Массовое создание актов'
Тогда открылось окно 'Массовое создание актов'
И я нажимаю кнопку выбора у поля с именем "Период"
Тогда открылось окно 'Выбор периода'
И я нажимаю на кнопку с именем 'ВыбратьМесяц9'
Тогда открылось окно 'Массовое создание актов'
И я нажимаю на кнопку с именем 'ФормаСоздатьАкты'


